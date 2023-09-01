#!/bin/bash
CWD=$(pwd)
#sudo apt-get update
sudo apt-get install -y \
        python3-dev \
        python3-pip \
        python3-pillow \
        libxml2-dev \
        libopenjp2-7

sudo python3 -m pip install -r requirements.txt


 git clone https://github.com/hzeller/rpi-rgb-led-matrix.git matrix
 cd matrix
 git pull
 make build-python #PYTHON=$(which python3)
 sudo make install-python #PYTHON=$(which python3)

echo "Running rgbmatrix installation..."
#cd bindings
#sudo pip install -e python/

cd $CWD



#rm -rf scoreboard
#git clone https://github.com/bsodergren/scoreboard.git 
#cd scoreboard/scripts

#cat nfl-led-scoreboard.service | sed "s|WORKING_DIR|$CWD|g" > nfl-led-scoreboard.service
#sudo mkdir /etc/scoreboard -p
#sudo cp led.conf /etc/scoreboard/
#sudo cp nfl-led-scoreboard.service /lib/systemd/system/

#sudo systemctl daemon-reload
#sudo systemctl enable nfl-led-scoreboard.service

#cp 
