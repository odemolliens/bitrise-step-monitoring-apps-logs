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

if [[ ${check_ios} == "yes" ]]; then
    if [[ ${ios_app_name} == "" ]]; then
        echo "ERROR: Didn't find any ios app name ios_app_name: $ios_app_name"
        exit 1
    fi
    if [ ! -d "ipa_unzipped" ]; then
        echo "ERROR: Cannot find any decompiled apk"
        exit 1
    fi

    # PERMISSION CHECK - count permissions which are into current info.plist
    CURRENT_IOS_BUILDS_PERMISSIONS_COUNT=$(echo $(grep -o -i "UsageDescription</key>" ipa_unzipped/Payload/$ios_app_name.app/Info.plist | wc -l))
    if [ $CURRENT_IOS_BUILDS_PERMISSIONS_COUNT -gt $ios_permission_count ]; then
        IOS_PERMISSION_COUNT=$CURRENT_IOS_BUILDS_PERMISSIONS_COUNT
        envman add --key IOS_PERMISSION_COUNT --value $IOS_PERMISSION_COUNT
        grep "UsageDescription</key>" "ipa_unzipped/Payload/$ios_app_name.app/Info.plist" > list_ios_permissions.txt
        gsed -ri 's/<key>//g' list_ios_permissions.txt
        gsed -ri 's/<\/key>//g' list_ios_permissions.txt
        cp list_ios_permissions.txt /Users/vagrant/deploy/list_ios_permissions.txt
    fi
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