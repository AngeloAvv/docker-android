FROM ubuntu:19.10

## Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

## Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

## Update package lists
RUN apt update

## Install dependencies
RUN apt-get install --no-install-recommends -y \
  openjdk-11-jdk \
  git \
  wget \
  build-essential \
  zlib1g-dev \
  libssl-dev \
  libreadline-dev \
  unzip

## Clean dependencies
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

## Install rbenv
ENV RBENV_HOME "/root/.rbenv"
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_HOME
ENV PATH "$PATH:$RBENV_HOME/bin"
ENV PATH "$PATH:$RBENV_HOME/shims"

# Install ruby-build (rbenv plugin)
RUN mkdir -p "$RBENV_HOME"/plugins
RUN git clone https://github.com/rbenv/ruby-build.git "$RBENV_HOME"/plugins/ruby-build

# Install default ruby env
RUN echo “install: --no-document” > ~/.gemrc
ENV RUBY_CONFIGURE_OPTS=--disable-install-doc
RUN rbenv install 2.7.0

## Install Android SDK
ARG sdk_version=commandlinetools-linux-6200805_latest.zip
ARG android_home=/opt/android/sdk
ARG android_api=android-29
ARG android_ndk=false
ARG ndk_version=21.0.6113669
ARG cmake=3.10.2.4988404
RUN mkdir -p ${android_home} && \
    wget --quiet --output-document=/tmp/${sdk_version} https://dl.google.com/android/repository/${sdk_version} && \
    unzip -q /tmp/${sdk_version} -d ${android_home} && \
    rm /tmp/${sdk_version}

# Set environmental variables
ENV ANDROID_HOME ${android_home}
ENV PATH=${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg

RUN yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses
RUN sdkmanager --sdk_root=$ANDROID_HOME --install \
  "platform-tools" \
  "build-tools;29.0.3" \
  "platforms;${android_api}"
RUN if [ "$android_ndk" = true ] ; \
  then \
    echo "Installing Android NDK ($ndk_version, cmake: $cmake)"; \
    sdkmanager --sdk_root="$ANDROID_HOME" --install \
    "ndk;${ndk_version}" \
    "cmake;${cmake}" ; \
  else \
    echo "Skipping NDK installation"; \
  fi
