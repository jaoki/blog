#!/bin/bash

set -e -x -u

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export IMAGE_NAME="pivotal/engineering-blog-hugo"

pushd ${SCRIPT_DIR}

docker build --rm=true -t ${IMAGE_NAME} .

popd

if [ "$(uname -s)" == "Linux" ]; then
  USER_NAME=${SUDO_USER:=$USER}
  USER_ID=$(id -u "${USER_NAME}")
  GROUP_ID=$(id -g "${USER_NAME}")
else # boot2docker uid and gid
  USER_NAME=$USER
  USER_ID=1000
  GROUP_ID=50
fi

docker build -t "${IMAGE_NAME}-${USER_NAME}" - <<UserSpecificDocker
FROM ${IMAGE_NAME}
RUN groupadd --non-unique -g ${GROUP_ID} ${USER_NAME} && \
  useradd -g ${GROUP_ID} -u ${USER_ID} -k /root -m ${USER_NAME}
ENV  HOME /home/${USER_NAME}
UserSpecificDocker


docker run -i -t \
  --rm=true \
  -v "${HOME}:${HOME}" \
  -w ${PWD} \
  -u "${USER}" \
  -p 1313:1313 \
  ${IMAGE_NAME}-${USER_NAME} \
  bash

