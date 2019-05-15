From ubuntu:18.04


RUN sudo apt-get -y update
RUN install -y  build-essential cmake autoconf \
Run install -y patch libtool git automake
RUN apt-get install -y qtbase5-dev libqt5svg5-dev
RUN apt-get install libeigen3-dev libsqlite3-dev \
    libwildmagic-dev libboost-random1.62-dev \
    libboost-regex1.62-dev libboost-iostreams1.62-dev \
    libboost-date-time1.62-dev libboost-math1.62-dev \
    libxerces-c-dev libglpk-dev zlib1g-dev libsvm-dev \
    libbz2-dev seqan-dev coinor-libcoinmp-dev -y 
RUN apt install python3-pip -y 

RUN apt install openjdk-11-jdk -y 

WORKDIR /
RUN git clone https://github.com/OpenMS/OpenMS.git && cd OpenMS && git checkout tags/Release2.4.0 && hash=`git log | head -n 1 | cut -f 2 -d ' '` && sed -i "s/OPENMS_GIT_SHA1/\"$hash\"/" src/openms/source/CONCEPT/VersionInfo.cpp && rm -rf .git/ share/OpenMS/examples/

WORKDIR /usr/local/

RUN git clone https://github.com/OpenMS/THIRDPARTY.git openms_thirdparty
WORKDIR /openms_thirdparty && rm -rf .git Windows MacOS Linux/32bit

WORKDIR /
RUN mkdir openms-build
WORKDIR /openms-build

RUN cmake -DCMAKE_PREFIX_PATH="$HOME/contrib-build/;/usr/;/usr/local" \
        -DCMAKE_INSTALL_PREFIX=/usr/local/ \
        -DBOOST_USE_STATIC=OFF \
        -DHAS_XSERVER=Off ../OpenMS

RUN make TOPP -j 4
RUN make UTILS -j 4
RUN make install -j 4 && rm -rf src doc CMakeFiles

WORKDIR /

RUN pip3 install snakemake matplotlib pandas numpy psutil && rm -rf contrib contrib-build openms-build