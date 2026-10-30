# The cups-pdf printer, if there is one.
P=$(lpstat -v 2>/dev/null | awk '$NF ~ /^cups-pdf:/ {sub(/:$/, "", $3); print $3; exit}')
GJ=$(mktemp)
trap 'rm -f "$GJ"' EXIT
cat >"$GJ" <<'X'
{
OPERATION Get-Jobs
GROUP operation-attributes-tag
ATTR charset attributes-charset utf-8
ATTR naturalLanguage attributes-natural-language en
ATTR uri printer-uri $uri
ATTR keyword which-jobs completed
ATTR keyword requested-attributes job-id,job-state
DISPLAY job-id
DISPLAY job-state
}
X
# canceled: how many of the printer's jobs were canceled.
canceled() { ipptool -c "ipp://localhost/printers/$P" "$GJ" 2>/dev/null | grep -c ',canceled$'; }
PDF=$(head -n1 /root/lab-answers/1 2>/dev/null)

task 1 "CUPS with a PDF printer, and a PDF printed"
need "CUPS is running" 'active cups'
need "CUPS starts at boot" 'enabled cups || enabled cups.socket'
need "lpstat -v shows a cups-pdf printer" '[ -n "$P" ]'
need "/root/lab-answers/1 names a PDF file that exists" '[ -f "$PDF" ] && head -c 5 "$PDF" | grep -q "%PDF"'
need "the PDF was printed during the lab" '[ "$PDF" -nt "$LAB_STATE/stamp" ]'

task 2 "Two jobs removed while the printer was disabled; printer back in service"
need "two of the printer's jobs were canceled (lprm, cancel)" '[ "$(canceled)" -ge 2 ]'
need "the printer is enabled" 'lpstat -p "$P" | grep -q enabled'
need "the printer accepts jobs" 'lpstat -a "$P" | grep -q "accepting requests"'

task 3 "CUPS debug logging on"
need "cupsd.conf has LogLevel debug" 'grep -Eqi "^[[:space:]]*LogLevel[[:space:]]+debug2?\b" /etc/cups/cupsd.conf'
need "cupsctl shows _debug_logging=1" 'cupsctl 2>/dev/null | grep -qx "_debug_logging=1"'
