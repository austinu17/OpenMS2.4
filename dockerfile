From: mafreitas/singularity-openms:contrib
BootStrap: shub

%environment
LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
export PATH=/usr/local/openms_thirdparty/All/:$PATH
export PATH=/usr/local/openms_thirdparty/All/LuciPHOr2:$PATH
export PATH=/usr/local/openms_thirdparty/All/MSGFPlus:$PATH
export PATH=/usr/local/openms_thirdparty/All/Sirius:$PATH
export PATH=/usr/local/openms_thirdparty/Linux/64bit/:$PATH
export PATH=/usr/local/openms_thirdparty/Linux/64bit/Comet:$PATH
export PATH=/usr/local/openms_thirdparty/Linux/64bit/Fido:$PATH
export PATH=/usr/local/openms_thirdparty/Linux/64bit/MyriMatch:$PATH
export PATH=/usr/local/openms_thirdparty/Linux/64bit/OMSSA:$PATH
export PATH=/usr/local/openms_thirdparty/Linux/64bit/Percolator:$PATH
export PATH=/usr/local/openms_thirdparty/Linux/64bit/Sirius:$PATH
export PATH=/usr/local/openms_thirdparty/Linux/64bit/SpectraST:$PATH
export PATH=/usr/local/openms_thirdparty/Linux/64bit/XTandem:$PATH
export PATH=/usr/local/bin/:$PATH
export OPENMS_DATA_PATH=/usr/local/share/OpenMS
export JAVA_HOME=/usr/lib/jvm/java-8-oracle


%post
RUN apt-get update && install -y \
    build-essential cmake autoconf \
    patch libtool git automake -y 
RUN apt-get install qtbase5-dev libqt5svg5-dev -y 
RUN apt-get install libeigen3-dev libsqlite3-dev \
    libwildmagic-dev libboost-random1.62-dev \
    libboost-regex1.62-dev libboost-iostreams1.62-dev \
    libboost-date-time1.62-dev libboost-math1.62-dev \
    libxerces-c-dev libglpk-dev zlib1g-dev libsvm-dev \
    libbz2-dev seqan-dev coinor-libcoinmp-dev -y 
RUN apt install python3-pip -y 

RUN apt install openjdk-11-jdk -y 

cd $HOME
git clone https://github.com/OpenMS/OpenMS.git
cd OpenMS
git checkout tags/Release2.4.0
hash=`git log | head -n 1 | cut -f 2 -d ' '`
sed -i "s/OPENMS_GIT_SHA1/\"$hash\"/" src/openms/source/CONCEPT/VersionInfo.cpp
rm -rf .git/ share/OpenMS/examples/

cd /usr/local/

git clone https://github.com/OpenMS/THIRDPARTY.git openms_thirdparty
cd openms_thirdparty
rm -rf .git Windows MacOS Linux/32bit

cd $HOME
mkdir openms-build
cd openms-build

cmake -DCMAKE_PREFIX_PATH="$HOME/contrib-build/;/usr/;/usr/local" \
        -DCMAKE_INSTALL_PREFIX=/usr/local/ \
        -DBOOST_USE_STATIC=OFF \
        -DHAS_XSERVER=Off ../OpenMS

make TOPP -j 4
make UTILS -j 4
make install -j 4
rm -rf src doc CMakeFiles

cd $HOME

pip3 install snakemake matplotlib pandas numpy psutil

rm -rf contrib contrib-build openms-build
