#!/bin/bash

# Define a function to print error messages
PrintError() {
    tput setaf 1    # Set text color to red
    #tput setab 7    # Set background color to white
    tput bold       # Set text to bold
    echo -e "\e[47mError: $1\e[0m\e[K\n"
    #tput setab 0
    tput sgr0       # Reset text and background colors, and remove bold
}

FLAVOR=$(uname -s)
LSB_RELEASE=$(command -v lsb_release 2> /dev/null)

echo "FLAVOR: $FLAVOR"
echo "LSB_RELEASE: $LSB_RELEASE"

if [ "$FLAVOR" = "Linux" ]; then
    if [ -n "$LSB_RELEASE" ]; then
        DISTRIBUTION=$(lsb_release -si | sed 's/Linux//')
    else
        DISTRIBUTUTION="Other"
    fi

    echo "DISTRIBUTION: $DISTRIBUTION"

    case "$DISTRIBUTION" in
        "Manjaro" | "ManjaroLinux")
            if ! command -v httpd -v &>/dev/null; then
                PrintError "Apache is not found on Manjaro."
                echo "To install Apache, run: sudo pacman -S apache"
            else
                httpd -v
                sudo systemctl start httpd.service
            fi
            ;;
        "Ubuntu" | "Debian")
            if ! command -v apache2 &>/dev/null; then
                PrintError "Apache is not found on Ubuntu/Debian."

                echo -e "To install Apache, run: sudo apt-get install apache2"
                echo
            else
                sudo service apache2 start
            fi
            ;;
        *)
            PrintError "Unsupported distribution: $DISTRIBUTION"
            ;;
    esac
else
    PrintError "Unsupported operating system: $FLAVOR"
fi
