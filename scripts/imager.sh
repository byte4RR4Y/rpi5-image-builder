#! /bin/bash

if [ "$UID" -ne 0 ]; then 
    echo "This program needs sudo rights."
    echo "Run it with 'sudo $0'"
    exit 1
elif [[ "$1" == "-h" ]]; then
	echo "Usage: $0 <mbr/gpt> <boot-image> <root-image> <output-filename>"
	echo "E.g.: '$0 gpt boot.img rootfs.img mysdcard.img'" 
	exit 1
elif [[ "$1" == "--help" ]]; then
	echo "Usage: $0 <mbr/gpt> <boot-image> <root-image> <output-filename>"
	echo "E.g.: '$0 mbr boot.img rootfs.img mysdcard.img'" 
	exit 1
elif [ "$#" -ne 4 ]; then
    echo "Usage: $0 <mbr/gpt> <boot-image> <root-image> <output-filename>"
    exit 0
fi

# Dateinamen für das Image und die Quellpartitionen und Image groesse ermitteln
TIMESTAMP=$(date +%s)
echo $TIMESTAMP > .TIMESTAMP

TMP=$(cat .TIMESTAMP)
table=$1
boot_image=$2
root_image=$3
image_name=$4
reserved_spaceMB=2
boot_sizeMB=$((($(stat -c %s ${boot_image}) / 1024 / 1024)))
root_sizeMB=$((($(stat -c %s ${root_image}) / 1024 / 1024)))
image_sizeMB=$((boot_sizeMB + root_sizeMB + reserved_spaceMB))
start_part2=$((0 + boot_sizeMB))

# Erstellen Sie ein leeres Image
dd if=/dev/zero of=$TMP bs=1M count=$image_sizeMB

# Erstellen Sie Loopback-Geräte für das leere Image
loop_device=$(sudo losetup -f --show $TMP)

sleep 1

if [[ "$table" == "mbr" ]]; then
# Erstellen Sie eine neue Partitionstabelle auf dem leeren Image
	sudo parted --script $loop_device mktable msdos
elif [[ "$table" == "gpt" ]]; then
	sudo parted --script $loop_device mktable gpt
fi

sleep 1

sudo parted -a optimal $loop_device mkpart primary fat32 2MB ${boot_sizeMB}MB
sudo parted -a optimal $loop_device mkpart primary ext4 ${start_part2}MB 100%
sudo partprobe $loop_device

sleep 1

# Formatieren Sie die Partitionen mit den gewünschten Dateisystemen
sudo mkfs.vfat ${loop_device}p1 -n BOOT -F 32
sudo mkfs.ext4 ${loop_device}p2 -L rootfs -F

sleep 1

sudo fsck -f -y ${loop_device}p1
sudo e2fsck -f -y ${loop_device}p2
sudo resize2fs -p ${loop_device}p2
sudo partprobe $loop_device

sleep 1

# Mount-Verzeichnisse erstellen
sudo mkdir -p loop loop/1 loop/2 loop/boot loop/root


sleep 1

# Mounten Sie die neu erstellten Partitionen
sudo mount ${loop_device}p1 loop/1
sudo mount ${loop_device}p2 loop/2
sudo mount $boot_image loop/boot
sudo mount $root_image loop/root

sleep 1

# Kopieren Sie den Inhalt der Quellpartitionen in die neu erstellten Partitionen
sudo cp -r loop/boot/* loop/1
sudo cp -r loop/root/* loop/2


sleep 1

# Demounten Sie die neu erstellten Partitionen
sudo umount loop/1
sudo umount loop/2
sudo umount loop/root
sudo umount loop/boot

sleep 1

# Entfernen Sie die Mount-Verzeichnisse
sudo rm -rf loop

# Erstelle das kombinierte Image
echo "---------------------------"
echo "Creating the final image..."
echo "---------------------------"

sudo dd if=$loop_device of=$image_name bs=1M conv=noerror status=progress

sleep 1

rm $TMP
rm .TIMESTAMP
# Entfernen Sie die Loopback-Geräte
sudo losetup -d $loop_device
