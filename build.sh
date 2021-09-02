#!/usr/bin/env bash

#                   GNU GENERAL PUBLIC LICENSE
#                       Version 3, 29 June 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.
#
# Script by @mrjarvis698

# Personal variables
export BOT_API_KEY="1974396028:AAEL1lWTmncnkeMltNEdtbDYOM_4JQyEQP4"
export BOT_CHAT_ID2="-1001336891256"

. $(pwd)/variables.sh

# Telegram Bot
sendMessage() {
    MESSAGE=$1
    curl -s "https://api.telegram.org/bot${BOT_API_KEY}/sendmessage" --data "text=$MESSAGE&chat_id=${BOT_CHAT_ID}" 1>/dev/null
    echo -e
    curl -s "https://api.telegram.org/bot${BOT_API_KEY}/sendmessage" --data "text=$MESSAGE&chat_id=${BOT_CHAT_ID2}" 1>/dev/null
    echo -e
}

# Repo Init
cd randit
sendMessage "Repo Initializing."
repo init --depth=1 -u ${android_manifest_url} -b ${manifest_branch} -g default,-darwin,-device,-mips
git clone --depth=1 ${local_manifest_url} .repo/local_manifests -b ${local_manifest_branch}
cd randit
sendMessage "Repo Initialised Successfully."

# Repo Sync
sendMessage "Repo Synchronizing."
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j 300
sendMessage "Repo Synchronized Successfully."

# Build Environment
. build/envsetup.sh

# Lunch device
sendMessage "Lunching ${device_name}"
lunch "${device_prefix}_${device_name}"-"${build_variant}"
sendMessage "Lunched ${device_name} Successfully."

# Log
# Date and time
export BUILDDATE=$(date +%Y%m%d)
export BUILDTIME=$(date +%H%M)
export LOGFILE=log-$BUILDDATE-$BUILDTIME.txt

# Build Rom
sendMessage "Starting Build for ${device_name}."
time ${make_rom}

# LAUNCH PROGRESS OBSERVER
while test ! -z "$(pidof soong_ui)"; do
        sleep 300
        # Get latest percentage
        PERCENTAGE=$(cat "$LOGFILE" | tail -n 1 | awk '{ print $2 }')
        # REPORT PerCentage to the Group
        sendMessage "Current percentage: $PERCENTAGE"
done


up4 () 
{ 
	    curl --upload-file $1 https://transfer.sh/$(basename $1);
	        echo
	}

trim=${tail }



sendMessage "${make_rom} Finished. Check for your Build."
