#!/bin/bash
CWD=$(pwd)

usage() {
    cat <<USAGE

    Usage: $0 [-a] [-c] [-m] [-p]

    Options:
        -c, --skip-config:  Skip updating JSON configuration files.
        -m, --skip-matrix:  Skip building matrix driver dependency. Video display will default to emulator mode.
        -p, --skip-python:  Skip Python 3 installation. Requires manual Python 3 setup if not already installed.

        -a, --skip-all:     Skip all dependencies and config installation (equivalent to -c -p -m).

        --emulator-only:    Do not install dependencies under sudo. Skips building matrix dependencies (equivalent to -m)

USAGE
    exit 1
}

SKIP_PYTHON=false
SKIP_CONFIG=false
SKIP_MATRIX=false
NO_SUDO=false

for arg in "$@"; do
    case $arg in
    -p | --skip-python)
        SKIP_PYTHON=true
        shift # Remove -p / --skip-python from `$@`
        ;;
    -c | --skip-config)
        SKIP_CONFIG=true
        shift # Remove -c / --skip-config from `$@`
        ;;
    -m | --skip-matrix)
        SKIP_MATRIX=true
        shift # Remove -m / --skip-matrix from `$@`
        ;;
    -a | --skip-all)
        SKIP_CONFIG=true
        SKIP_MATRIX=true
        SKIP_PYTHON=true
        shift # Remove -a / --skip-all from `$@`
        ;;
    --emulator-only)
        SKIP_MATRIX=true
        NO_SUDO=true
        shift # remove --emulator-only from `$@`
        ;;
    -h | --help)
        usage # run usage function on help
        ;;
    *)
        usage # run usage function if wrong argument provided
        ;;
    esac
done

if [ "$SKIP_PYTHON" = false ]; then
    echo
    echo "------------------------------------"
    echo "  Installing python 3..."
    echo "------------------------------------"
    echo



    sudo apt-get update
    sudo apt-get install -y \
            python3-dev \
            python3-pip \
            python3-pillow \
            libxml2-dev \
            libopenjp2-7
    echo
    echo "------------------------------------"
    echo "  Installing dependencies..."
    echo "------------------------------------"
    echo

    if [ "$NO_SUDO" = false ]; then
        sudo python3 -m pip install -r requirements.txt
    else
        python3 -m pip install -r requirements.txt
    fi

fi



if [ "$SKIP_MATRIX" = false ]; then
    echo "Running rgbmatrix installation..."
    rm -rf matrix
    git clone https://github.com/hzeller/rpi-rgb-led-matrix.git matrix
    cd matrix
    git pull
    make build-python #PYTHON=$(which python3)
    sudo make install-python #PYTHON=$(which python3)
    #cd bindings
    #sudo pip install -e python/
fi

if [ "$SKIP_CONFIG" = true ]; then
    echo
    echo "------------------------------------"
    echo "  Skipping configuration updates"
    echo "------------------------------------"
    echo
else

    cd $CWD

    rm -rf scoreboard
    git clone https://github.com/bsodergren/scoreboard.git 
    cd scoreboard/scripts

    sed -i -e "s|WORKING_DIR|$CWD|g"  nfl-led-scoreboard.service

    # cat nfl-led-scoreboard.service 

    sudo mkdir /etc/scoreboard -p
    sudo cp -u led.conf /etc/scoreboard/
    sudo cp -u nfl-led-scoreboard.service /lib/systemd/system/
    sudo cp -u nfl-scoreboard.py /usr/local/bin/
    sudo chmod +x /usr/local/bin/nfl-scoreboard.py   
   
    mapfile -t crontabArray < <( crontab -l)

    for line in "${crontabArray[@]}"; do
    if [[  ${line} =~ "scoreboard.py" ]]; then
        cron_array+="@reboot /usr/local/bin/nfl-scoreboard.py \n"
        else
        cron_array+="$line \n"
        fi
    done 
    echo -e ${cron_array[*]} | crontab -

    sudo systemctl daemon-reload
    sudo systemctl enable nfl-led-scoreboard.service

fi

echo "Installation finished!"