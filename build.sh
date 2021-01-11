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
export rom_dir=/home/k/aex/aex
export BOT_API_KEY="1336436573:AAFpaGsPLEc90A9LBObk6kSXDvjrySmQH14"
export j=20
export ccache_dir=${rom_dir}/junk/ccache
export max_ccache=25G

. $(pwd)/export.sh

# Telegram Bot
sendMessage() {
    MESSAGE=$1
    curl -s "https://api.telegram.org/bot${BOT_API_KEY}/sendmessage" --data "text=$MESSAGE&chat_id=${BOT_CHAT_ID}" 1>/dev/null
    echo -e
}

# Repo Init
cd $rom_dir
sendMessage "Repo Initializing."
repo init --depth=1 -u ${android_manifest_url} -b ${manifest_branch} -g default,-darwin,-device,-mips
git clone --depth=1 ${local_manifest_url} ${rom_dir}/.repo/local_manifests -b ${local_manifest_branch}
cd ${rom_dir}/.repo/local_manifests
git remote add tmp ${local_manifest_url}
git fetch tmp
git checkout -f remotes/tmp/${local_manifest_branch}
git remote remove tmp
cd $rom_dir
sendMessage "Repo Initialised Successfully."

# Repo Sync
sendMessage "Repo Synchronizing."
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j 300
sendMessage "Repo Synchronized Successfully."

# ccache
export CCACHE_DIR=$ccache_dir
ccache -M $max_ccache
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
export _JAVA_OPTIONS=-Xmx50g

# Build Environment
. $(rom_dir)/build/envsetup.sh

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
time ${make_rom} -j ${j} | tee ./$LOGFILE &

# LAUNCH PROGRESS OBSERVER
sleep 60
while test ! -z "$(pidof soong_ui)"; do
        sleep 300
        # Get latest percentage
        PERCENTAGE=$(cat "$LOGFILE" | tail -n 1 | awk '{ print $2 }')
        # REPORT PerCentage to the Group
        sendMessage "Current percentage: $PERCENTAGE"
done

sendMessage "${make_rom} Finished. Check for your Build."
