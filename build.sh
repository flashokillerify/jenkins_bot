#!/usr/bin/env bash

#                   GNU GENERAL PUBLIC LICENSE
#                       Version 3, 29 June 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.
#
# Script by @mrjarvis698

. $(pwd)/export.sh

# Telegram Bot
sendMessage() {
    MESSAGE=$1
    curl -s "https://api.telegram.org/bot${BOT_API_KEY}/sendmessage" --data "text=$MESSAGE&chat_id=${BOT_CHAT_ID}" 1>/dev/null
    echo -e
}

# Repo Init
sendMessage "Repo Initializing."
repo init --depth=1 -u ${android_manifest_url} -b ${manifest_branch} -g default,-darwin,-device,-mips
sendMessage "Repo Initialised Successfully."

# Repo Sync
sendMessage "Repo Synchronizing."
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j 300
sendMessage "Repo Synchronized Successfully."

# ccache
ccache_dir=$(pwd)/junk/ccache
max_ccache=25G
export CCACHE_DIR=$ccache_dir
ccache -M $max_ccache
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
export _JAVA_OPTIONS=-Xmx50g

# Build Environment
. $(pwd)/build/envsetup.sh

# Lunch device
sendMessage "Lunching ${device_name}, Check Progress here-> ${BUILD_URL}"
lunch "${device_prefix}_${device_name}"-"${build_variant}"
sendMessage "Lunched ${device_name} Successfully."

# Build Rom
sendMessage "Starting Build for ${device_name}."
${make_rom}
sendMessage "${make_rom} Finished. Check for your Build."
