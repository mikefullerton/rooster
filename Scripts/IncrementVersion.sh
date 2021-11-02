#!/bin/sh

#  IncrementVersion.sh
#  Rooster
#
#  Created by Mike Fullerton on 1/3/21.
#  


MY_PATH="`dirname "$0"`"
MY_PATH="`( cd "$MY_PATH" && pwd )`"
MY_NAME="`basename "$0"`"
ROOT_PATH="`( cd "$MY_PATH/.." && pwd )`"

VERSION_NUMBER=0
BUILD_NUMBER=0
REVISION_NUMBER=0

APP_INFO_FILE_PATH=""
ROOSTER_CORE_INFO_FILE_PATH=""

if [[ ! -d "${ROOT_PATH}/Rooster.xcodeproj" ]]; then
    echo "unable to find root dir of rooster repo in ${ROOT_PATH}"
    exit 1
fi

echo "# Found root path: ${ROOT_PATH}"

function find_rooster_core_info_file_path() {
    local ROOSTER_CORE_OTHER_FILES_PATH="`( cd "${ROOT_PATH}/RoosterCore/Other Files" && pwd )`" || {
        echo "Can't find RoosterCore 'other files' dir (contains RoosterCore .info file)"
        exit 1
    }

    ROOSTER_CORE_INFO_FILE_PATH="${ROOSTER_CORE_OTHER_FILES_PATH}/Info.plist"

    if [[ ! -f "${ROOSTER_CORE_INFO_FILE_PATH}" ]]; then
        echo "Can't find RoosterCore info file: ${ROOSTER_CORE_INFO_FILE_PATH}"
        exit 1
    fi

    echo "# Found Rooster core info file: ${ROOSTER_CORE_INFO_FILE_PATH}"
}

function find_app_info_file_path() {
    APP_INFO_FILE_PATH="${ROOT_PATH}/Rooster-macOS/Other Files/info.plist"

    if [[ ! -f "${APP_INFO_FILE_PATH}" ]]; then
        echo "Can't find app .info file: ${APP_INFO_FILE_PATH}"
        exit 1
    fi

    echo "# Found app info file: ${APP_INFO_FILE_PATH}"
}

function check_git_status() {
    GIT_STATUS="`( cd "$MY_PATH/.." && git status )`"

    if [[ "${GIT_STATUS}" != *"nothing to commit"* ]]; then
        echo "Please commit changes before building a release!"
        exit 1
    fi

    echo "# Git status is ok, no pending modifications found..."
}

function get_version_number() {
    local SHORT_VERSION="$(defaults read "${APP_INFO_FILE_PATH}" CFBundleShortVersionString)" || {
        echo "Unable to read CFBundleShortVersionString from file: ${APP_INFO_FILE_PATH}"
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

#    echo "# Found existing version number: ${VERSION_NUMBER}.${BUILD_NUMBER}"
}

function get_revision_number() {
    REVISION_NUMBER="$(defaults read "${APP_INFO_FILE_PATH}" CFBundleVersion)" || {
        echo "Unable to read CFBundleVersion from file: ${APP_INFO_FILE_PATH}"
        exit 1
    }
#    echo "# Found existing revisiion number: ${REVISION_NUMBER}"
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
 
    echo "# Wrote CFBundleShortVersionString='${VERSION_NUMBER}.${BUILD_NUMBER}.${REVISION_NUMBER}' in ${FILE_PATH}"
    echo "# Wrote CFBundleVersion='${REVISION_NUMBER}' in ${FILE_PATH}"
}

function update_git_repo() {
    set -x

    cd "${ROOT_DIR}"

    git add "${APP_INFO_FILE_PATH}" || {
        echo "Adding ${APP_INFO_FILE_PATH} to git failed"
        exit 1
    }

    git add "${ROOSTER_CORE_INFO_FILE_PATH}" || {
        echo "Adding ${ROOSTER_CORE_INFO_FILE_PATH} to git failed"
        exit 1
    }

    git status

    exit 0

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

    echo "# Tagged release ok: ${GIT_TAG}"
}

function update_revision_number() {
    echo "# Current Version: ${VERSION_NUMBER}.${BUILD_NUMBER}.${REVISION_NUMBER}"
    ((REVISION_NUMBER+=1))

    echo "# New Version: ${VERSION_NUMBER}.${BUILD_NUMBER}.${REVISION_NUMBER}"

    write_build_number_to_file "${APP_INFO_FILE_PATH}"

    write_build_number_to_file "${ROOSTER_CORE_INFO_FILE_PATH}"
}

find_rooster_core_info_file_path

find_app_info_file_path

check_git_status

get_version_number

get_revision_number

update_revision_number

update_git_repo




