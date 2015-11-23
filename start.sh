#!/bin/bash
rm main.luac
luac -o main.luac main.lua
#screen -dm arch -i386 python2.7 reciever.py
arch -i386 python2.7 reciever.py