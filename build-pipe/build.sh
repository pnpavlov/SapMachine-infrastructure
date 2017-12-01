#!/bin/bash
set -ex

if [ -d SapMachine ]; then
    rm -rf SapMachine;
fi
export GIT_COMMITTER_NAME=$GIT_USER
export GIT_COMMITTER_EMAIL="sapmachine@sap.com"
git clone -b $SAPMACHINE_GIT_BRANCH "http://$GIT_USER:$GIT_PASSWORD@$SAPMACHINE_GIT_REPO" SapMachine

cd SapMachine

if [[ ! -z $GIT_TAG_NAME ]] && [[ $GIT_TAG_NAME == jdk-* ]]; then
  git checkout $GIT_TAG_NAME
  bash ./configure --with-boot-jdk=$BOOT_JDK --with-version-string=${GIT_TAG_NAME: 4} --with-version-opt="sapmachine"
else
  bash ./configure --with-boot-jdk=$BOOT_JDK --with-version-opt="sapmachine"
fi

make JOBS=12 images test-image

tar czf ../build.tar.gz build

cd build
cd "$(ls)"/images

tar czf ../../../../"${SAPMACHINE_ARCHIVE_NAME_PREFIX}-jdk.tar.gz" jdk
tar czf ../../../../"${SAPMACHINE_ARCHIVE_NAME_PREFIX}-jre.tar.gz" jre
