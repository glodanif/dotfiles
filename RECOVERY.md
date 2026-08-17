# Recovery

What to do when the machine won't boot. Kept in git so it's readable from a
phone, the NAS, or Forgejo while you're staring at a Limine menu.

## The three boot entries

| Entry | Kernel | Initramfs |
|---|---|---|
| `Artix Linux` | `vmlinuz-linux` | `initramfs-linux.img` |
| `Artix Linux (fallback)` | `vmlinuz-linux` — **the same one** | `initramfs-linux-fallback.img` |
| `Artix Linux (LTS)` | `vmlinuz-linux-lts` | `initramfs-linux-lts.img` |

The fallback entry only swaps the initramfs. It cannot rescue you from a broken
kernel or a failed NVIDIA build — that is what the LTS entry is for.

The default initramfs is built with `autodetect`, so it contains modules only
for hardware present when it was built. The fallback is built with `-S
autodetect`, so it contains everything.

## Which entry to pick

| Symptom | Boot | Why |
|---|---|---|
| Fails **before** the LUKS passphrase prompt — "device not found", "waiting for device", busybox shell | fallback | initramfs lacks a driver needed to reach the disk |
| Passphrase accepted, then panic / freeze / reboot loop | LTS | past the initramfs, so it's the kernel |
| Boots, but black screen instead of a desktop | LTS | NVIDIA DKMS failed or regressed against the new kernel |
| Hardware or BIOS storage setting just changed | fallback | `autodetect` never bundled the new driver |
| Update just touched `linux` or `nvidia-open-dkms` | LTS | the exact case it exists for |
| Nothing changed, disk not detected at all | neither | hardware failure — use a USB rescue |

## Read the error first

The default entry has `quiet splash`, which hides the failure. The fallback and
LTS entries deliberately don't. Booting fallback purely to *see* the error is a
legitimate first move even when you suspect the kernel.

Or press `e` in the Limine menu to edit any entry's cmdline for a single boot
and drop `quiet splash`. Nothing is written to disk.

## Where you landed

```sh
uname -r        # 7.1.8-artix1-3 = mainline, 6.18.44-1-lts = rescue kernel
nvidia-smi      # should report the RTX 4070; if not, graphics is not kernel-specific
```

## Repair, by which path saved you

**Fallback saved you** — the default initramfs is missing a driver:

```sh
sudo mkinitcpio -P      # rebuilds both images against current hardware
```

**LTS saved you** — the mainline kernel or its NVIDIA module is bad. The
`paccache -rk2` policy in `sys-maintenance` keeps the previous version for
exactly this:

```sh
ls /var/cache/pacman/pkg/linux-*
sudo pacman -U /var/cache/pacman/pkg/linux-<previous-version>.pkg.tar.zst
```

Then hold it back until the next release fixes the regression.

## Black screen on both kernels

If the machine is otherwise alive (SSH answers, disks spin), suspect the GPU
rather than software. The Ryzen 9 7900 has a working iGPU (`amdgpu`, already
loaded) — move the cable to the motherboard's DisplayPort to confirm.

Note that the iGPU's connectors are currently named `DP-4` / `HDMI-A-2` only
because the NVIDIA card claims `DP-1`–`DP-3` first. With the card removed they
will likely renumber, and `hypr/monitors.lua` hardcodes `DP-1`/`DP-2`/
`HDMI-A-1` — so expect the wrong mode or offset until those rules are adjusted.

## Network: is it the firewall?

The tell is **how** it fails:

| Symptom | Meaning |
|---|---|
| hangs, then times out | packets are being *dropped* — firewall is the prime suspect |
| "connection refused", instantly | nothing is listening on that port — not the firewall |
| "no route to host" | routing, not filtering |

Ask what's loaded first, because there are two and their scope differs:

```sh
sudo nft list tables
```

- `inet filter` — always on, filters **inbound only**. It cannot break connections
  *you* initiate.
- `inet vpnkill` — present only while the VPN is up, filters **outbound**, policy
  drop. This one can break your own traffic, and is meant to. `vpn-run off`
  removes it.

Blocked packets are logged. This is usually the fastest answer:

```sh
sudo dmesg | grep nft-drop
```

`nft-drop-in:` is the inbound firewall, `nft-drop-out:` is the killswitch. The
line names the interface, source, destination and port. Rate-limited to 5/min,
and it lives in the kernel ring buffer, so it answers "why is this failing right
now", not "what happened last week".

Ten-second isolation test — flushing can't lock you out, since no rules means
everything is permitted:

```sh
sudo nft flush ruleset      # retest whatever was broken
sudo nft -f /etc/nftables.conf
```

Opening a port for a dev server, live only until the next reload or reboot:

```sh
sudo nft add rule inet filter input tcp dport 3000 accept
```

Remember a service must also be *listening* on `0.0.0.0`, not `127.0.0.1`, for
anything outside this machine to reach it. That's a separate gate from the
firewall, and it's the one that produces an instant refusal rather than a hang.

## VPN won't connect

If `wg-quick` reports a resolvconf "signature mismatch" and tears the interface
back down, the config has a `DNS =` line. `/etc/resolv.conf` is deliberately
immutable and points at dnscrypt-proxy, so wg-quick can't rewrite it. Comment
the line out — every config regenerated from the provider ships one:

```sh
sudo sed -i 's/^DNS/#DNS/' ~/.config/wireguard/*.conf
```

DNS still resolves through dnscrypt, and with `AllowedIPs = 0.0.0.0/0` those
queries travel inside the tunnel anyway. `06-vpn.sh` checks for this.

If everything stops working right after a VPN drop, the killswitch outlived its
tunnel:

```sh
sudo nft delete table inet vpnkill
```

## What none of this covers

A damaged LUKS header, a wiped `/boot`, or a missing `limine.conf` needs an
Artix USB. Restic snapshots on the NAS are the backstop for data; the header
and bootloader are not in them.
