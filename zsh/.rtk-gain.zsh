# RTK per-setup savings helpers
#
# rtk only records project_path (cwd), not which CLAUDE_CONFIG_DIR ran a
# command, so "work vs personal" is split by directory tree instead:
#   work     == everything under Development/Work
#   personal == everything else
# The filter excludes phantom grep rows (>500k "input tokens" for one grep)
# that otherwise inflate the totals wildly.
#
#   work-gain      -> work: N cmds, X.XK saved (YY.Y%)
#   personal-gain  -> personal: ...
#   rtk-gain       -> both

_rtk_db="$HOME/.local/share/rtk/history.db"
_rtk_gain() {
  local label="$1" where="$2"
  local guard="NOT (rtk_cmd LIKE 'rtk grep%' AND input_tokens > 500000)"
  sqlite3 "$_rtk_db" "
    SELECT '$label: ' ||
           COUNT(*) || ' cmds, ' ||
           printf('%.1fK', SUM(saved_tokens)/1000.0) || ' saved (' ||
           printf('%.1f', 100.0*SUM(saved_tokens)/NULLIF(SUM(input_tokens),0)) || '%)'
    FROM commands WHERE $guard AND ($where);"
}
work-gain()     { _rtk_gain "work"     "project_path LIKE '$HOME/Development/Work%'"; }
personal-gain() { _rtk_gain "personal" "project_path NOT LIKE '$HOME/Development/Work%'"; }
rtk-gain()      { work-gain; personal-gain; }
