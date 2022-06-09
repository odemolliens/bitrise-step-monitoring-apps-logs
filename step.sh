#!/bin/bash
set -ex

if [[ ${log_count} != "" ]]; then
    LIMIT="$log_count"
else
    LIMIT="0"
fi

if [[ ${check_android} == "yes" ]]; then
    if [ ! -d "apk_decompiled" ]; then
        echo "ERROR: Cannot find any decompiled apk"
        exit 1
    fi

    ALL_LOGS=$(grep -ri "Landroid/util/Log;->i(\|Landroid/util/Log;->v(\|Landroid/util/Log;->w(\|Landroid/util/Log;->d(\|Landroid/util/Log;->e(" apk_decompiled/.)

    if [[ ${filter_path} != "" ]]; then
        echo "Filtered path 2: $filter_path"

        LOGS=$(echo "$ALL_LOGS" | grep -v $filter_path || true)
        COUNT_ANDROID_LOGS=$(echo "$ALL_LOGS" | grep -v $filter_path | wc -l)
    else
        LOGS="$ALL_LOGS"
        COUNT_ANDROID_LOGS=$(echo "$ALL_LOGS" | wc -l)
    fi
fi

COUNT_ANDROID_LOGS=`echo $COUNT_ANDROID_LOGS | sed 's/ *$//g'`
echo "COUNT_ANDROID_LOGS: $COUNT_ANDROID_LOGS"

echo "---- REPORT ----"

if [ ! -f "quality_report.json" ]; then
  touch "quality_report.json"
  echo "{}" > "quality_report.json"
fi

STEP_KEY="Logs"
JSON_OBJECT='{ }'
JSON_OBJECT=$(echo "$(jq ". + { "\"$STEP_KEY\"": {} }" <<<"$JSON_OBJECT")")

JSON_OBJECT=$(echo "$(jq ".$STEP_KEY += { "androidApp": { "oldValue": "$LIMIT", "value": "$COUNT_ANDROID_LOGS", "displayAlert": true, "artifactName": \"android_app_logs.txt\" } }" <<<"$JSON_OBJECT")")

echo "$(jq ". + $JSON_OBJECT" <<< cat quality_report.json)" > quality_report.json
cp quality_report.json $BITRISE_DEPLOY_DIR/quality_report.json || true
printf "Reported logs: \n$LOGS\n" > android_app_logs.txt

if [[ ${COUNT_ANDROID_LOGS} != "" && ${COUNT_ANDROID_LOGS} -gt $LIMIT ]]; then
    echo "Generate an error due to logs in your native codes"
    exit 1
fi
exit 0