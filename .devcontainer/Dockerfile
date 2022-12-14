FROM ubuntu:latest as builder

ARG ANDROID_SDK_ROOT
ARG USERNAME
ARG USER_UID
ARG USER_GID=$USER_UID

# [Option] Install zsh
ARG INSTALL_ZSH="true"

# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget

WORKDIR /home/${USERNAME}

#Installing Android SDK
RUN mkdir -p ${ANDROID_SDK_ROOT}
ENV ANDROID_SDK_ROOT ${ANDROID_SDK_ROOT}
RUN mkdir -p .android && touch .android/repositories.cfg
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest
RUN mv cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest
RUN cd ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin && yes | ./sdkmanager --licenses
RUN cd ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin && ./sdkmanager "build-tools;30.0.3" "patcher;v4" "platform-tools" "platforms;android-30" "sources;android-30"
ENV PATH "$PATH:$ANDROID_SDK_ROOT/platform-tools"
ENV PATH "$PATH:$ANDROID_SDK_ROOT/emulator"
ENV PATH "$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"

# Downloading Flutter SDK
RUN git clone https://github.com/flutter/flutter.git --depth=1 --branch=stable
# Installing DART SDK
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

ENV FLUTTER_HOME "/home/${USERNAME}/flutter"
ENV DART_SDK="${FLUTTER_HOME}/bin/cache/dart-sdk"
ENV PUB_CACHE="/usr/local/share/pub-cache"
ENV PUB_CACHE="/home/${USERNAME}/.pub-cache"
ENV PATH "${PATH}:${FLUTTER_HOME}/bin:${DART_SDK}:${PUB_CACHE}/bin"

RUN if ! cat /etc/group | grep -e "^pub-cache:" > /dev/null 2>&1; then groupadd -r pub-cache; fi \
    && usermod -a -G pub-cache ${USERNAME} \
    && umask 0002 \
    && mkdir -p ${PUB_CACHE} \
    && chown :pub-cache ${PUB_CACHE} \
    && sed -i -e "s/export PATH=/export PATH=\/usr\/local\/share\/pub-cache:/" /etc/profile.d/00-restore-env.sh \
    #
    # Fix incorrect privs if present on directories - https://github.com/dart-lang/dart-docker/issues/62, https://github.com/dart-lang/sdk/issues/47093
    && chmod 755 "$DART_SDK" "$DART_SDK/bin"

RUN flutter channel stable
RUN flutter config --no-analytics
ENV SHELL /bin/bash
RUN flutter upgrade
RUN flutter doctor
RUN adb kill-server && adb start-server
RUN adb tcpip 5555