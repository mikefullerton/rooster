#!/bin/sh

#  IncrementVersion.sh
#  Rooster
#
#  Created by Mike Fullerton on 1/3/21.
#  


MY_PATH="`dirname "$0"`"
MY_PATH="`( cd "$MY_PATH" && pwd )`"
MY_NAME="`basename "$0"`"

VERSION_NUMBER=0
BUILD_NUMBER=0
REVISION_NUMBER=0

INFO_FILE_PATH="${MY_PATH}/Info.plist"

FRAMEWORK_PATH="`( cd "$MY_PATH/../../RoosterCore/Other Files" && pwd )`" || {
    echo "Can't find plugin dir"
    exit 1
}

FRAMEWORK_INFO_FILE_PATH="${FRAMEWORK_PATH}/Info.plist"

function check_git_status() {
    GIT_STATUS="`( cd "$MY_PATH/.." && git status )`"

    if [[ "${GIT_STATUS}" != *"nothing to commit"* ]]; then
        echo "Please commit changes before building a release!"
        exit 1
    fi
}

function get_version_number() {
    local SHORT_VERSION="$(defaults read "${INFO_FILE_PATH}" CFBundleShortVersionString)" || {
        echo "Unable to read CFBundleShortVersionString from file: ${INFO_FILE_PATH}"
        exit 1
    }

    IFS="."; read -ra TOKENS <<< "${SHORT_VERSION}"

    TOKENS_COUNT=${#TOKENS[@]}

    if [ ${TOKENS_COUNT} != 3 ]; then
        echo "Expecting 3 parts to Version: ${SHORT_VERSION}, got ${TOKENS_COUNT}"
        exit 1
    fi

    VERSION_NUMBER=${TOKENS[0]}
    BUILD_NUMBER=${TOKENS[1]}
}

function get_revision_number() {
    REVISION_NUMBER="$(defaults read "${INFO_FILE_PATH}" CFBundleVersion)" || {
        echo "Unable to read CFBundleVersion from file: ${INFO_FILE_PATH}"
        exit 1
    }
}

function write_build_number_to_file() {
    
    FILE_PATH="$1"

    defaults write "${FILE_PATH}" CFBundleShortVersionString "${VERSION_NUMBER}.${BUILD_NUMBER}.${REVISION_NUMBER}" || {
        echo "Unable to write to CFBundleShortVersionString in file: ${FILE_PATH}"
        exit 1
    }
    
    defaults write "${FILE_PATH}" CFBundleVersion ${REVISION_NUMBER} || {
        echo "Unable to write to CFBundleVersion in file: ${FILE_PATH}"
        exit 1
    }
 
    plutil -convert xml1 "${FILE_PATH}" || {
        echo "Failed to convert "$FILE_PATH" to xml"
        exit 1
    }
 
    echo "Wrote ${VERSION_NUMBER}.${BUILD_NUMBER}.${REVISION_NUMBER} to CFBundleShortVersionString in ${FILE_PATH}"
    echo "Wrote ${REVISION_NUMBER} to CFBundleVersion in ${FILE_PATH}"
}

#check_git_status

get_version_number
get_revision_number

echo "Current Version: ${VERSION_NUMBER}.${BUILD_NUMBER}.${REVISION_NUMBER}"
((REVISION_NUMBER+=1))

echo "New Version: ${VERSION_NUMBER}.${BUILD_NUMBER}.${REVISION_NUMBER}"

write_build_number_to_file "${INFO_FILE_PATH}"

write_build_number_to_file "${FRAMEWORK_INFO_FILE_PATH}"

set -x

exit 0

cd "${MY_PATH}/.."
git add "${INFO_FILE_PATH}" || {
    echo "Adding ${INFO_FILE_PATH} to git failed"
    exit 1
}

git add "${FRAMEWORK_INFO_FILE_PATH}" || {
    echo "Adding ${PLUGIN_INFO_FILE_PATH} to git failed"
    exit 1
}

git status

GIT_TAG="v${VERSION_NUMBER}.${BUILD_NUMBER}.${REVISION_NUMBER}"

git commit -m "Updated plist files for release: ${GIT_TAG}" || {
    echo "Commiting updated plist files failed"
    exit 1
}

echo "Committed plist files to git ok"

git tag -a "${GIT_TAG}" -m "${GIT_TAG}" || {
    echo "Tagging release failed"
    exit 1
}

echo "Tagged release ok: ${GIT_TAG}"

