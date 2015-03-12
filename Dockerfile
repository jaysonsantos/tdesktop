FROM ubuntu:trusty
RUN apt-get update && apt-get install -y wget build-essential git \
    libexif-dev liblzma-dev libz-dev libssl-dev libappindicator-dev libunity-dev \
    libxcb1-dev libxcb-image0-dev libxcb-keysyms1-dev libxcb-icccm4-dev \
    libxcb-render-util0-dev libxcb-util0-dev libxrender-dev libasound-dev \
    libpulse-dev libxcb-sync0-dev libxcb-xfixes0-dev libxcb-randr0-dev libx11-xcb-dev \
    libffi-dev cmake && \
    apt-get clean

ENV ogg_version 1.3.2

RUN mkdir /deps
RUN wget http://downloads.xiph.org/releases/ogg/libogg-${ogg_version}.tar.xz -O \
        /deps/libogg-${ogg_version}.tar.xz && \
    cd /deps && tar xvf libogg-${ogg_version}.tar.xz && rm libogg-${ogg_version}.tar.xz && \
    cd libogg-${ogg_version} && ./configure && make install && \
    rm -rf /deps/libogg-${ogg_version}

ENV opus_version 1.1
RUN wget http://downloads.xiph.org/releases/opus/opus-${opus_version}.tar.gz -O \
        /deps/opus-${opus_version}.tar.gz && \
    cd /deps && tar xvf opus-${opus_version}.tar.gz && rm opus-${opus_version}.tar.gz && \
    cd opus-${opus_version} && ./configure && make install && \
    rm -rf /deps/opus-${opus_version}

ENV opusfile_version 0.6
RUN wget http://downloads.xiph.org/releases/opus/opusfile-${opusfile_version}.tar.gz -O \
        /deps/opusfile-${opusfile_version}.tar.gz && \
    cd /deps && tar xvf opusfile-${opusfile_version}.tar.gz && rm opusfile-${opusfile_version}.tar.gz && \
    cd opusfile-${opusfile_version} && ./configure && make install && \
    rm -rf /deps/opusfile-${opusfile_version}

ENV portaudio_version 19
RUN wget http://www.portaudio.com/archives/pa_stable_v${portaudio_version}_20140130.tgz -O \
        /deps/portaudio-${portaudio_version}.tar.gz && \
    cd /deps && tar xvf portaudio-${portaudio_version}.tar.gz && rm portaudio-${portaudio_version}.tar.gz && \
    cd /deps/portaudio && ./configure && make install && \
    rm -rf /deps/portaudio

RUN git clone git://repo.or.cz/openal-soft.git /deps/openal && \
    mkdir -p /deps/openal/build && \
    cd /deps/openal/build && cmake -DLIBTYPE:STRING=STATIC ../ && make install && \
    rm -rf /deps/openal

ENV qt_major_version 5.4
ENV qt_version ${qt_major_version}.0

COPY Telegram/_qt_* deps/qt-everywhere-opensource-src-${qt_version}/

RUN wget http://download.qt-project.org/official_releases/qt/${qt_major_version}/${qt_version}/single/qt-everywhere-opensource-src-${qt_version}.tar.gz \
        -O /deps/qt-everywhere-opensource-src-${qt_version}.tar.gz && \
    cd /deps && \
    tar xvf qt-everywhere-opensource-src-${qt_version}.tar.gz && \
    cd qt-everywhere-opensource-src-${qt_version} && \
    git apply _qt_5_4_0_patch.diff && \
    ./configure -release -opensource -confirm-license -qt-xcb -no-opengl -static -nomake examples \
        -nomake tests -skip qtquick1 -skip qtdeclarative && \
    make -j8 module-qtbase module-qtimageformats && \
    make -j8 module-qtbase-install_subtargets module-qtimageformats-install_subtargets && \
    rm -rf /deps/qt-everywhere-opensource-src-${qt_version}

ADD . /tdesktop
RUN cd /tdesktop && qmake && make
