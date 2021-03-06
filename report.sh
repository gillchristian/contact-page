#!/bin/bash

set -e

# --max-items=
# --date-spec=<date|hr>

LOGS='sudo find /var/log/nginx -name "*access*"'
if [ -z "$1" ]
then
    SINCE="cat"
else
    SINCE="sed -n '/'\$(date '+%d\/%b\/%Y' -d '$1')'/,$ p'"
fi
FILTER="awk '\$9==\"200\" { print \$0 }'"
HTML_PREFS='"{\"autoHideTables\":true,\"layout\":\"vertical\",\"perPage\":10,\"theme\":\"darkPurple\",\"visitors\":{\"plot\":{\"chartType\":\"area-spline\",\"metric\":\"hits-visitors\"},\"columns\":{}},\"requests\":{\"plot\":{\"chartType\":\"area-spline\",\"metric\":\"hits-visitors\"},\"columns\":{},\"chart\":true},\"visit_time\":{\"plot\":{\"metric\":\"hits-visitors\",\"chartType\":\"area-spline\"}},\"browsers\":{\"plot\":{\"metric\":\"hits-visitors\"}},\"static_requests\":{\"plot\":{\"chartType\":\"area-spline\",\"metric\":\"hits-visitors\"}},\"not_found\":{\"plot\":{\"chartType\":\"area-spline\",\"metric\":\"hits-visitors\"}},\"hosts\":{\"plot\":{\"chartType\":\"area-spline\",\"metric\":\"hits-visitors\"}},\"os\":{\"plot\":{\"chartType\":\"area-spline\",\"metric\":\"hits-visitors\"}},\"referring_sites\":{\"plot\":{\"metric\":\"hits-visitors\"}},\"status_codes\":{\"plot\":{\"metric\":\"hits-visitors\"}},\"geolocation\":{\"plot\":{\"metric\":\"hits-visitors\"}}}"'
NOW=$(date +%s)
REPORT_NAME="report-$NOW.html"
COMMAND="\
    $LOGS |\
    sort -t. -k1,1r -k4,4nr |\
    sudo xargs zcat -f |\
    $SINCE |\
    $FILTER |\
    goaccess \
      -a --log-format=COMBINED -o $REPORT_NAME --ignore-crawlers\
      --html-prefs=$HTML_PREFS\
      --http-protocol=no -\
    "
ssh riccardo@odone.io "$COMMAND"

REPORT_PATH="$HOME/Desktop/$REPORT_NAME"
scp "riccardo@odone.io:~/$REPORT_NAME" "$REPORT_PATH"
open "$REPORT_PATH"

sleep 3
rm "$REPORT_PATH"
