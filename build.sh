#!/bin/bash

TIMESTAMP=$(date +%s)

usage() {
    echo "Usage: $0 [-h|--help] [-s|--suite SUITE] [-k|--kernelbranch KERNELBRANCH] [-d|--desktop DESKTOP] [-a|--additional ADDITIONAL] [-u|--username USERNAME] [-p|--password PASSWORD] [-b]"
    echo "-------------------------------------------------------------------------------------------------"
    echo "Options:"
    echo "  -h, --help                      Show this help message and exit"
    echo "  -s, --suite SUITE               Choose the Debian suite (e.g., testing, experimental, trixie)"
    echo "  -k, --kernelbranch KERNELBRANCH Choose the Kernel branch (e.g., rpi-6.1.y, rpi-6.2.y)"
    echo "  -d, --desktop DESKTOP           Choose the desktop environment (e.g., xfce, none)"
    echo "  -a, --additional ADDITIONAL     Choose whether to install additional software (yes/no)"
    echo "                                  This only has an effect in combination with --desktop(or -d)"
    echo "  -u, --username USERNAME         Enter the username for the sudo user"
    echo "  -p, --password PASSWORD         Enter the password for the sudo user"
    echo "  -b                              Build the image with the specified configuration without asking"
    echo "-------------------------------------------------------------------------------------------------"
    exit 1
}

# Check if running with sudo
if [ "$UID" -ne 0 ]; then
    echo "This program needs sudo rights."
    echo "Run it with 'sudo $0'"
    exit 1
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) usage;;
        -s|--suite) SUITE="$2"; shift ;;
        -k|--kernelbranch) BRANCH="$2"; shift ;;
        -d|--desktop) DESKTOP="$2"; shift ;;
        -a|--additional) ADDITIONAL="$2"; shift ;;
        -u|--username) USERNAME="$2"; shift ;;
        -p|--password) PASSWORD="$2"; shift ;;
        -b) BUILD="yes" ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Check if arguments are missing
if [ -z "$SUITE" ] || [ -z "$BRANCH" ] || [ -z "$DESKTOP" ] || [ -z "$ADDITIONAL" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Missing arguments!"
    usage
fi

echo "cleaning build area..."
sleep 2
rm .config
rm .boot.img
rm .rootfs.img
rm .rootfs.tar
rm files/firmware/initrd.img
rm files/firmware/kernel_2712.img
rm -f files/kernel/*.zip
rm -rf .rootfs/
rm config/rootfs_size.txt

docker rmi rpi:latest

clear
echo "Choose the Debian Suite:"
echo ""
echo "1. Testing"
echo "2. Experimental"
echo "3. Trixie"
echo "4. Sid"
echo "5. Bookworm"
echo "6. Bullseye"
echo ""
read -p "Enter the number of your choice: " choice
if [[ "$choice" -eq 1 ]]; then
    echo "SUITE=testing" > .config
elif [[ "$choice" -eq 2 ]]; then
    echo "SUITE=experimental" > .config
elif [[ "$choice" -eq 3 ]]; then
    echo "SUITE=trixie" > .config
elif [[ "$choice" -eq 4 ]]; then
    echo "SUITE=sid" > .config
elif [[ "$choice" -eq 5 ]]; then
    echo "SUITE=bookworm" > .config
elif [[ "$choice" -eq 6 ]]; then
    echo "SUITE=bullseye" > .config
else
	exit 1
fi
clear
echo "Choose your Kernel branch:"
echo ""
echo "1. rpi-6.1.y"
echo "2. rpi-6.2.y"
echo "3. rpi-6.3.y"
echo "4. rpi-6.4.y"
echo "5. rpi-6.5.y"
echo "6. rpi-6.6.y"
echo "7. rpi-6.7.y"
echo "8. rpi-6.8.y"
echo "9. Custom(see branches on https://github.com/raspberrypi/linux)"
read -p "Enter the number of your choice: " choice
if [[ "$choice" -eq 1 ]]; then
    BRANCH="rpi-6.1.y"
elif [[ "$choice" -eq 2 ]]; then
    BRANCH="rpi-6.2.y"
elif [[ "$choice" -eq 3 ]]; then
    BRANCH="rpi-6.3.y"
elif [[ "$choice" -eq 4 ]]; then
    BRANCH="rpi-6.4.y"
elif [[ "$choice" -eq 5 ]]; then
    BRANCH="rpi-6.5.y"
elif [[ "$choice" -eq 6 ]]; then
    BRANCH="rpi-6.6.y"
elif [[ "$choice" -eq 7 ]]; then
    BRANCH="rpi-6.7.y"
elif [[ "$choice" -eq 8 ]]; then
    BRANCH="rpi-6.8.y"
elif [[ "$choice" -eq 9 ]]; then
    echo "---------------------------------------------------------------"
    read -p "Enter custom branch(e.g.: 'rpi-4.19.y-rt'): " custombranch
    BRANCH="$custombranch"
fi
clear
echo "Choose the Desktop of your choice:"
echo ""
echo "1. xfce"
echo "2. none"
echo ""
read -p "Enter the number of your choice: " choice
if [[ "$choice" -eq 1 ]]; then
    echo "DESKTOP=xfce" >> .config
else
    echo "DESKTOP=none" >> .config
fi
if [[ "$choice" -eq 1 ]]; then
	clear
	echo "Do you want to install additional software?"
	echo ""
	echo "1. yes"
	echo "2. no"
	echo ""
	read -p "Enter the number of your choice: " choice2
	if [[ "$choice2" -eq 1 ]]; then
	    echo "ADDITIONAL=yes" >> .config
	else
	    echo "ADDITIONAL=no" >> .config
	fi
else
	echo "ADDITIONAL=no" >> .config
fi
clear
echo "Let's create a sudo user..."
echo ""
read -p "Enter Username: " choice

    echo "USERNAME=$choice" >> .config
echo ""
read -p "Enter Password: " choice

    echo "PASSWORD=$choice" >> .config
clear
echo "Writing '.config'..."
while IFS='=' read -r key value; do
    case "$key" in
    	SUITE)
    		SUITE="$value"
    		;;
        DESKTOP)
            DESKTOP="$value"
            ;;
        ADDITIONAL)
            ADDITIONAL="$value"
            ;;
        USERNAME)
            USERNAME="$value"
            ;;
        PASSWORD)
            PASSWORD="$value"
            ;;
        *)
            ;;
    esac
done < .config
echo "------------------------------"
echo "SUITE="$SUITE
echo "BRANCH="$BRANCH
echo "DESKTOP="$DESKTOP
echo "ADDITIONAL="$ADDITIONAL
echo "USERNAME="$USERNAME
echo "PASSWORD="$PASSWORD
echo "------------------------------"
# Proceed with building image if -b option provided or ask for confirmation
if [[ "$BUILD" == "yes" ]]; then
    echo "Building image with the specified configuration..."
else
    clear
	echo "Do you want to build the image with this configuration?"
	echo ""
	echo "1. yes"
	echo "2. no"
	echo ""
	read -p "Enter the number of your choice: " choice2
	if [[ "$choice2" -eq 1 ]]; then
	    BUILD="yes"
	else
	    exit 1
	fi
fi

if [[ "$BUILD" == "yes" ]]; then
echo "---------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------"

echo "Reading .config file..."
while IFS='=' read -r key value; do
    case "$key" in
        DESKTOP)
            DESKTOP="$value"
            ;;
        ADDITIONAL)
            ADDITIONAL="$value"
            ;;
        USERNAME)
            USERNAME="$value"
            ;;
        PASSWORD)
            PASSWORD="$value"
            ;;
        *)
            ;;
    esac
done < .config

echo "0" > config/kernel_status
# Cloning and building the Kernel in an extra routine
xfce4-terminal --title="Building Kernel $BRANCH" --command="scripts/kernelbuilder.sh -x -c 5 -f -j $(($(nproc))) -p -s 'byte4rr4y' -b $BRANCH -u" &



# Führe den Docker-Build-Befehl aus
echo "Building Docker image..."
sleep 1
docker build --build-arg "SUITE="$SUITE --build-arg "DESKTOP="$DESKTOP --build-arg "ADDITIONAL="$ADDITIONAL --build-arg "USERNAME="$USERNAME --build-arg "PASSWORD="$PASSWORD -t rpi:latest -f docker/Dockerfile .

echo "---------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------"


mkdir -p .rootfs

while [[ "$(cat config/kernel_status)" != "1" ]]; do
	clear
    echo "Waiting for Kernel compilation..."
    sleep 10  
done

docker run --platform linux/arm64/v8 -dit --rm --name rpicontainer rpi:latest /bin/bash
echo "------------------------"
echo "| Installing Kernel... |"
echo "------------------------"


docker cp files/kernel/kernel.zip rpicontainer:/
docker cp scripts/installkernel.sh rpicontainer:/
docker exec rpicontainer ./installkernel.sh kernel.zip
docker cp rpicontainer:/boot/firmware/kernel_2712.img files/firmware/kernel_2712.img
docker exec rpicontainer rm /boot/firmware/kernel_2712.img
docker exec rpicontainer rm -rf /installkernel.sh
docker exec rpicontainer rm -rf /kernel.zip


docker exec rpicontainer bash -c 'cp /boot/initrd.img-* /tmp/initrd.img'
docker cp rpicontainer:/tmp/initrd.img files/firmware/initrd.img
docker exec rpicontainer bash -c 'rm /tmp/initrd.img'

docker exec rpicontainer echo $(($(du -s -m --exclude=/proc / | awk '{print $1}') / 10)) > config/rootfs_size.txt

echo "Creating an empty boot image..."
dd if=/dev/zero of=.boot.img bs=1M count=512 status=progress
mkfs.vfat -n BOOT .boot.img -F 32 

echo "Creating an empty rootfs image..."
rootfs_size=$(cat config/rootfs_size.txt)
dd if=/dev/zero of=.rootfs.img bs=1M count=$((${rootfs_size} + 256)) status=progress
mkfs.ext4 -L rootfs .rootfs.img -F

mkdir -p .rootfs
mount .rootfs.img .rootfs/
sleep 2

echo "Extracting the rootfilesystem of the container..."
docker export -o .rootfs.tar rpicontainer
docker kill rpicontainer
echo "---------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------"
tar -xvf .rootfs.tar -C .rootfs/
sleep 1

mkdir -p .bootfs/
sleep 1

mount .boot.img .bootfs/
sleep 2

cp -r files/firmware/* .bootfs/
sleep 2

umount .rootfs/
umount .bootfs/
rm -rf .rootfs/
sleep 2

rm -rf linux/
rm -rf .rootfs
rm -rf .bootfs
fsck -f -y .boot.img
e2fsck -f .rootfs.img
resize2fs -M .rootfs.img
sleep 1

mkdir -p output
scripts/imager.sh mbr .boot.img .rootfs.img "output/Build-${TIMESTAMP}.img"
fi
exit 0
