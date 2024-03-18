Dotfile of my Wayland/Sway on Arch Linux

# Arch Linux bassic install

## 1. disable reflector service

```bash
systemctl stop reflector.service
```

## 2. verify we are in UEFI mode

```bash
ls /sys/firmware/efi/efivars
```

should output efi variables

## 3. connect to network

## 4. update system clock

```bash
timedatectl set-ntp true
```

## 5. partition and disk formating

a general partition plan

- 512M for UEFI partition (placed at the begining of a disk)
- at least 128G for system
- (optional) swap space of about 60% running memory
- all rest space for home

change disk partition with
```bash
cfdisk /dev/sda
cfdisk /dev/sdb
```

say, the partition is
```
# UEFI, 512M
/dev/sda1 

# system, 128G
/dev/sda2

# home, 1T
/dev/sdb1
```

format disk partition with the following command

```bash
# format the UEFI partition
mkfs.vfat /dev/sda1

# format system partition (-L specifies the partition label, name whatever legal)
mkfs.btrfs -L ArchSystem /dev/sda2

#format the home partition
mkfs.btrfs -L ArchHome /dev/sdb1
```

### 5.1 if you have only one disk

partition

```
# UEFI, 512M
/dev/sda1

# system+home, all rest space
/dev/sda2
```

format the disk with Btrfs subvolume feature

```bash
# format the partition to btrfs
mkfs.btrfs -L myarch /dev/sda2

# create a mount point and mount
mkdir ./mnt
mount -t btrfs -o compress=zstd /dev/sda2 ./mnt

# create subvolume
btrfs subvolume create ./mnt/@  # root subvolume
btrfs subvolume create ./mnt/@home  # home subvolume

# the subvolume can be mounted by
# mount -t btrfs -o subvol=/@,compress=zstd /dev/sda2 ./mnt
# mkdir ./mnt/home
# mount -t btrfs -o subvol=/@home,compress=zstd /dev/sda2 ./mnt/home

# umount the partition
umount ./mnt
```

## 6. bootstrap a filesystem

mount the partition (refer to 5.1 if using Btrfs subvolume)

```bash
mkdir ./mnt
mount -t btrfs -o compress=zstd /dev/sda2 ./mnt
mkdir -p ./mnt/home
mount -t btrfs -o compress=zstd /dev/sdb1 ./mnt/home
mkdir ./mnt/boot
mount -p /dev/sda1 ./mnt/boot

# mount swap space if have one
swapon /dev/sdxn
```

start bootstraping filesystem
```bash
pacstrap ./mnt base base-devel linux linux-firmware btrfs-progs dhcpcd networkmanager vim sudo zsh zsh-completions
```

## 7. generate fstab file

generate a fstab file according to current mount state

```bash
genfstab -U ./mnt > ./mnt/etc/fstab
```

## 8. post setups

change root to the new filesystem root

```bash
chroot ./mnt
```

### set host name

```bash
echo "myArch" > /etc/hostname
```

### set known host info
add the following line to `/etc/hosts`

```text
127.0.0.1   localhost
::1         localhost
127.0.1.1   myarch.localdomain myarch
```

### set time zone

```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### sync hardware time

```bash
hwclock --systohc
```

### set charactor encoding

uncomment the following two line in `/etc/locale.gen`

```text
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
```

generate locale

```bash
locale-gen
```

append the following line to `/etc/locale.conf`

```text
LANG=en_US.UTF-8
```

### set password for root, add new user , set non-passwd sudo

```bash
passwd root
useradd -m newuser

# if visudo report editor not found error
ln -s /usr/bin/vim /usr/bin/vi

visudo
```

add the following line in `visudo`

```text
# User privilege specification
<username> ALL=(ALL:ALL) NOPASSWD: ALL
```

### install chip manufacturer micro code

```bash
pacman -S intel-ucode

# if on AMD
pacman -S amd-ucode
```


## 9. install boot loader

install `GRUB` to EFI patition

```bash
pacman -S grub efibootloader os-prober

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
```

modify the following line in `/etc/default/grub` for verbose booting

```text
# GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=5"
```

generate GRUB config file

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

## 10. finish installation and reboot

```bash
exit # exit the chroot env

umount -R ./mnt  # unmount the partition
reboot
```

# Arch Linux graphic env

install the following package

```bash
sudo pacman -S sway swayidle swaylock swaybg alacritty waybar wofi qt5-wayland glfw-wayland
```

fonts

```bash
sudo pacman -S noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-firacode-nerd
```

pull the dotfile repo and move it to `~/.config`
