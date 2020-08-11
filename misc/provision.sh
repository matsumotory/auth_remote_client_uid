#/bin/bash

MYHOST=`hostname`
SRC_DIR=~/auth_remote_client_uid
BUILD_DIR=$SRC_DIR/build
TEST_DIR=$SRC_DIR/test
MYSQL_BUILD_DIR=$SRC_DIR/mysql_build
REPO=https://github.com/matsumotory/auth_remote_client_uid.git

# use ccache
HOSTCXX=g++
CC=gcc
THREAD=2

# download tcpriv
if [ -d $SRC_DIR ]; then
  rm -rf $SRC_DIR
fi
git clone $REPO $SRC_DIR

# setup build enviroment
sudo apt-get update
sudo apt-get -y install build-essential rake bison git gperf automake m4 \
                autoconf libtool cmake pkg-config libcunit1-dev ragel \
                libpcre3-dev clang-format-6.0
sudo apt-get -y remove nano
sudo apt-get -y install gawk chrpath socat libsdl1.2-dev xterm libncurses5-dev lzop flex libelf-dev kmod

sudo update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-6.0 1000
sudo sed -i s/#\ deb-src/deb-src/ /etc/apt/sources.list
sudo apt update
sudo apt install -y dpkg-dev

if [ -d $BUILD_DIR ]; then
  rm -rf $BUILD_DIR
fi
mkdir $BUILD_DIR

if [ -d $MYSQL_BUILD_DIR ]; then
  rm -rf $MYSQL_BUILD_DIR
fi
mkdir $MYSQL_BUILD_DIR

if [ $MYHOST = "server" ]; then
  # Build MySQL
  cd $MYSQL_BUILD_DIR
  apt source mysql-server
  cd $MYSQL_BUILD_DIR/mysql-8.0-8.0.21
  wget https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz
  cmake -DFORCE_INSOURCE_BUILD=1 -DWITH_BOOST=./boost .
  make

  cd $TEST_DIR
  make clean
  make
  exit $?
fi