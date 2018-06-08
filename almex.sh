#!/bin/bash
# MadStu's Small Install Script
cd ~
wget https://raw.githubusercontent.com/MadStu/ALMEX/master/newalmexmn.sh
chmod 777 newalmexmn.sh
sed -i -e 's/\r$//' newalmexmn.sh
./newalmexmn.sh
