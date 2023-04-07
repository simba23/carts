#!/usr/bin/env bash

set -ev

SCRIPT_DIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`
SSH_OPTS=-oStrictHostKeyChecking=no

if [[ "$(uname)" == "Darwin" ]]; then
    DOCKER_CMD=docker
else
    DOCKER_CMD="sudo docker"
fi

if [[ -z $($DOCKER_CMD images | grep test-container) ]] ; then
    echo "Building test container"
    docker build -t test-container $SCRIPT_DIR > /dev/null
fi

echo "Testing $1"
CODE_DIR=$(cd $SCRIPT_DIR/..; pwd)
echo "$@"
# $DOCKER_CMD run \
docker run \
	    --rm \
	    --name test \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    -v $CODE_DIR:$CODE_DIR -w $CODE_DIR \
	    -e COVERALLS_TOKEN=$COVERALLS_TOKEN \
	    -e TRAVIS_JOB_ID=$TRAVIS_JOB_ID \
	    -e TRAVIS_BRANCH=$TRAVIS_BRANCH \
	    -e TRAVIS_PULL_REQUEST=$TRAVIS_PULL_REQUEST \
	    -e TRAVIS=$TRAVIS \
	    -e TAG=$TAG \
	    -e COMMIT=$COMMIT \
            -e CIRCLECI=true \ 
            -e CIRCLE_JOB=$CIRCLE_JOB \ 
            -e CIRCLE_BRANCH=$CIRCLE_BRANCH \ 
            -e CIRCLE_PULL_REQUEST=$CIRCLE_PULL_REQUEST \ 
            -e CIRCLE_BUILD_NUM=$CIRCLE_BUILD_NUM \ 
            -e CIRCLE_SHA1=$CIRCLE_SHA1 \ 
            -e CIRCLE_TAG=$CIRCLE_TAG \ 
	    test-container \
	    sh -c "export PYTHONPATH=\$PYTHONPATH:\$PWD/test ; python test/$@"
