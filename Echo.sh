#!/bin/bash

detect_distro() {
    if [[ "$OSTYPE" == linux-android* ]]; then
        distro="termux"
    fi

    if [ -z "$distro" ]; then
        # Simplified distro detection using /etc/os-release as primary method
        if [ -f "/etc/os-release" ]; then
            distro="$(source /etc/os-release && echo "$ID")"
        elif [ "$OSTYPE" == "darwin" ]; then
            distro="darwin"
        else 
            # Fallback to basic detection
            distro=$(ls /etc/*-release 2>/dev/null | head -n1 | cut -d'/' -f3 | cut -d'-' -f1)
            if [ -z "$distro" ]; then
                distro="invalid"
            fi
        fi
    fi
}

pause() {
    read -n1 -r -p "Press any key to continue..." key
}

banner() {
    clear
    echo -e "\e[1;31m"
    if ! [ -x "$(command -v figlet)" ]; then
        echo 'The Echoer'
    else
        figlet "Echo"
    fi
    if ! [ -x "$(command -v toilet)" ]; then
        echo -e "\e[4;34m> . \e[1;32m< \e[0m"
    else
        echo -e "\e[1;34m>.< \e[1;34m"
        toilet -f mono12 -F border "Echo"
    fi
    echo " "
    echo " "
}

init_environ(){
    declare -A backends=(
        ["arch"]="pacman -S --noconfirm"
        ["debian"]="apt-get -y install"
        ["ubuntu"]="apt -y install"
        ["termux"]="apt -y install"
        ["fedora"]="yum -y install"
        ["redhat"]="yum -y install"
        ["SuSE"]="zypper -n install"
        ["sles"]="zypper -n install"
        ["darwin"]="brew install"
        ["alpine"]="apk add"
    )

    INSTALL="${backends[$distro]}"

    if [ "$distro" = "termux" ]; then
        PYTHON="python"
        SUDO=""
    else
        PYTHON="python3"
        SUDO="sudo"
    fi
    PIP="$PYTHON -m pip"
}

install_deps(){
    packages=(openssl git "$PYTHON" "$PYTHON-pip" figlet toilet)
    if [ -n "$INSTALL" ]; then
        for package in "${packages[@]}"; do
            "$SUDO" "$INSTALL" "$package"
        done
        "$PIP" install -r requirements.txt
    else
        echo "We could not install dependencies."
        echo "Please make sure you have git, python3, pip3 and requirements installed."
        echo "Then you can execute bomber.py ."
        exit 1
    fi
}

banner
pause
detect_distro
init_environ

if [ -f ".update" ]; then
    echo "All Requirements Found...."
else
    echo 'Installing Requirements....'
    echo .
    echo .
    install_deps
    echo '^^ > .update'
    echo 'Requirements Installed....'
    pause
fi

while :
do
    banner
    echo -e "\e[4;31m Please Read Instruction Carefully !!! \e[0m"
    echo " "
    echo "Press 1 To  Start SMS  Echoer "
    echo "Press 2 To  Start CALL Echoer "
    echo "Press 3 To  Start MAIL Echoer (Not Yet Available)"
    echo "Press 4 To  Update (Works On Linux And Linux Emulators) "
    echo "Press 5 To  Exit "
    read -r ch
    clear

    case "$ch" in
        "1")
            "$PYTHON" bomber.py --sms
            exit
            ;;
        "2")
            "$PYTHON" bomber.py --call
            exit
            ;;
        "3")
            "$PYTHON" bomber.py --mail
            exit
            ;;
        "4")
            echo -e "\e[1;34m Downloading Latest Files..."
            rm -f ".update"
            "$PYTHON" bomber.py --update
            echo -e "\e[1;34m RUN Echo Again..."
            pause
            exit
            ;;
        "5")
            banner
            exit
            ;;
        *)
            echo -e "\e[4;32m Invalid Input !!! \e[0m"
            pause
            ;;
    esac
done