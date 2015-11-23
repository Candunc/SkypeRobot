#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

type port --help >/dev/null 2>&1 || { echo >&2 "I require macports but it is not installed. Aborting."; exit 1; }
type cmake >/dev/null 2>&1 || { clear; echo "Installing cmake"; sleep 2; port install cmake; }
clear
echo "Installing Lua"
sleep 2
cd ~
curl -O http://www.lua.org/ftp/lua-5.3.1.tar.gz
tar -xzf lua-5.3.1.tar.gz
rm lua-5.3.1.tar.gz
cd lua-5.3.1/
make macosx
make install
cd ~
rm -r lua-5.3.1/

clear
echo "Installing Luarocks"
sleep 2
curl -O http://keplerproject.github.io/luarocks/releases/luarocks-2.2.2.tar.gz
tar -xzf luarocks-2.2.2.tar.gz
rm luarocks-2.2.2.tar.gz
cd luarocks-2.2.2/
./configure
make
make install
cd ~
rm -r luarocks-2.2.2/

clear
echo "Installing required luarocks modules"
sleep 2
luarocks install xml
luarocks install luajson
luarocks install luasocket
