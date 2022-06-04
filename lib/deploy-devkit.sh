#!/bin/bash
set -ex

NEXUS_PATH=https://common.repositories.cloud.sap/artifactory/sapmachine-mvn
DEVKIT_GROUP=$1
DEVKIT_GROUP_SLASH=`echo $DEVKIT_GROUP | tr . /`
DEVKIT_ARTEFACT=$2
DEVKIT_VERSION=$3
DEVKIT_BASENAME=${DEVKIT_ARTEFACT}-${DEVKIT_VERSION}
DEVKIT_ARCHIVE=${DEVKIT_BASENAME}.tar.gz
# On Mac we try to avoid some downloads by keeping the devkit in a folder below the workdir.
# This is not necessary/possible on other ephemeral Jenkins clients.
if [[ $(uname) == Darwin ]]; then
    DEVKIT_ARCHIVE_PATH="../${DEVKIT_ARCHIVE}"
else
    DEVKIT_ARCHIVE_PATH=${DEVKIT_ARCHIVE}
fi


if [ -d ${DEVKIT_BASENAME} ]; then
  echo Directory ${DEVKIT_BASENAME} already exists.
  exit 0
fi

if [ ! -f ${DEVKIT_ARCHIVE_PATH} ]; then
  echo ${DEVKIT_ARCHIVE} does not exist, downloading...
  HTTPRC=`curl -L -s -I -u ${ART_USER}:${ART_PASSWORD} ${NEXUS_PATH}/${DEVKIT_GROUP_SLASH}/${DEVKIT_ARTEFACT}/${DEVKIT_VERSION}/${DEVKIT_ARCHIVE} | head -n 1 | cut -d$' ' -f2`
  if [[ $HTTPRC -eq 200 ]]; then
    echo File seems to be downloadable, request returned $HTTPRC.
  else
    echo Error: File not downloadable, request returned $HTTPRC.
    return -1
  fi
  curl -L -s -o ${DEVKIT_ARCHIVE_PATH} -u ${ART_USER}:${ART_PASSWORD} ${NEXUS_PATH}/${DEVKIT_GROUP_SLASH}/${DEVKIT_ARTEFACT}/${DEVKIT_VERSION}/${DEVKIT_ARCHIVE}
fi

echo Extracting ${DEVKIT_ARCHIVE} to ${DEVKIT_BASENAME}...
mkdir ${DEVKIT_BASENAME}
pushd ${DEVKIT_BASENAME}
tar xzf ../${DEVKIT_ARCHIVE_PATH}
popd
echo Extracted devkit.
