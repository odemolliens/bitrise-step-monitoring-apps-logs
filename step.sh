#!/bin/bash
set -ex
fi

if [[ ${check_android} == "yes" ]]; then
    if [ ! -d "apk_decompiled" ]; then
        echo "ERROR: Cannot find any decompiled apk"
        exit 1
    fi

    COUNT_ANDROID_LOGS=$(echo $(grep -ri "Landroid/util/Log;->v(\|Landroid/util/Log;->i(\|Landroid/util/Log;->w(\|Landroid/util/Log;->d(\|Landroid/util/Log;->e(" apk_decompiled/. | wc -l))
fi

echo "---- REPORT ----"

if [ ! -f "quality_report.txt" ]; then
    printf "QUALITY REPORT\n\n\n" > quality_report.txt
fi

printf ">>>>>>>>>>  APP LOGS  <<<<<<<<<<\n" >> quality_report.txt


if [[ ${COUNT_ANDROID_LOGS} == "" && ${COUNT_IOS_LOGS} == "" ]]; then
    printf "0 log in your native code \n" >> quality_report.txt
else
    if [[ ${COUNT_ANDROID_LOGS} != "" && ${COUNT_ANDROID_LOGS} -gr "0" ]]; then
        printf "You have : $COUNT_ANDROID_LOGS in your Android code \n" >> quality_report.txt
    fi
    if [[ ${COUNT_IOS_LOGS} != "" && ${COUNT_IOS_LOGS} -gr "0" ]]; then
        printf "You have : $COUNT_IOS_LOGS in your iOS code \n" >> quality_report.txt
    fi
fi

printf "\n\n" >> quality_report.txt

cp quality_report.txt /Users/vagrant/deploy/quality_report.txt || true

if [[ ${COUNT_ANDROID_LOGS} != "" && ${COUNT_ANDROID_LOGS} -gr "0" || ${COUNT_IOS_LOGS} != "" && ${COUNT_IOS_LOGS} -gr "0" ]]; then
    echo "Generate an error due to logs in your native codes"
    exit 1
fi
exit 0