# Windows 的 Grub 2 引导项手动配置

```sh
# 设置超时时间和默认选项
set timeout=5
set default=0

# 设置语言
set gfxterm_font=unicode
set lang=zh_CN # 设置为中文
set locale_dir=/EFI/grub/locale # 设置翻译文件目录（不设置则无法使用中文）
loadfont /EFI/grub/fonts/unicode.pf2

# 加载文件系统模块
## 两种最流行的磁盘分区格式
insmod part_gpt
insmod part_msdos
## 常见文件系统驱动
insmod btrfs
insmod exfat
insmod ext2
insmod fat
insmod iso9660
insmod jfs
insmod ntfs
insmod reiserfs
insmod udf
insmod xfs
insmod zfs

# 图形终端（主题）相关
set gfxmode=1920x1080,1280x720,auto # 分辨率设置
set gfxpayload=keep # Linux 内核的视频模式（不明白什么意思，不加也可以）
insmod gfxterm   # 加载图形模式终端
insmod gfxmenu   # 加载图形模式菜单（不知道有没有用，Ubuntu 里看到的）
insmod all_video # 加载所有视频驱动
insmod gettext   # 应该是有关文本的（尤其是中文）（不知道有没有用，Ubuntu 里看到的）
insmod png       # 加载PNG图片支持（背景图片）
terminal_output gfxterm # 使用 gfxterm 图形终端（必须在最后）

# 设置为 sleek 主题
set theme=/EFI/grub/themes/sleek/theme.txt # 设置主题
export theme # 导出变量，使其作为全局变量（在 submenu 中可用，否则 submenu 无法获取该变量导致异常，下同）

## 加载字体
loadfont /EFI/grub/themes/sleek/Poppins-14.pf2
loadfont /EFI/grub/themes/sleek/Poppins-16.pf2
loadfont /EFI/grub/themes/sleek/Poppins-18.pf2
loadfont /EFI/grub/themes/sleek/Poppins-48.pf2
loadfont /EFI/grub/themes/sleek/terminus-14.pf2
loadfont /EFI/grub/themes/sleek/terminus-16.pf2
loadfont /EFI/grub/themes/sleek/WenQuanYi-16.pf2
loadfont /EFI/grub/themes/sleek/WenQuanYi-32.pf2

# 自定义函数
## add_os_if_exists: 如果 OS 存在，添加到启动项中
### $1 EFI to chainload
### $2 OS name
### $3 Class
function add_os_if_exists {
    for d in hd0,gpt1 hd0,gpt2 hd1,gpt1 hd1,gpt2 hd0,msdos1 hd0,msdos2 hd1,msdos1 hd1,msdos2; do
        if [ -e ($d)$1 ]; then # 判断 OS 对应的 efi 存在
            menuentry "$2" "$d" "$1" --class "$3" { # 注：`"$2"`后面的作为参数传入，故内部的`$2`实际上代表这里的`$d`
                chainloader ($2)$3
            }
            break
        fi
    done
}

## add_android_tv_entry: 添加有关 Andorid TV 的启动项
### $1 Title
### $2 Class
### $3... Kernel cmdline，即各种启动选项
function add_android_tv_entry {
    set title="$1"
    set class="$2"
    shift 2
    menuentry "$title" "$@" --class "$class" {
        set root=$android_tv_os_root
        shift 1
        linux $kdir/kernel root=/dev/ram0 $@
        initrd $kdir/initrd.img
    }
}

# 添加各个系统的引导项
## Windows
add_os_if_exists /EFI/Microsoft/Boot/bootmgfw.efi "Windows 11" windows # 注：可能添加 Windows 10，但这里直接指定为 Widnwos 11
## Linux
set grub=grubx64 # 针对以下 Linux 系统在 64 位下的引导文件
export grub
add_os_if_exists /EFI/ubuntu/${grub}.efi Ubuntu ubuntu
add_os_if_exists /EFI/steamos/${grub}.efi SteamOS steamos
add_os_if_exists /EFI/fedora/${grub}.efi Fedora fedora
add_os_if_exists /EFI/debian/${grub}.efi Debian debian
add_os_if_exists /EFI/gentoo/${grub}.efi Gentoo gentoo
add_os_if_exists /EFI/opensuse/${grub}.efi openSUSE opensuse
add_os_if_exists /EFI/linuxmint/${grub}.efi "Linux Mint" linuxmint
add_os_if_exists /EFI/CLO2020-03-30/${grub}.efi macOS macosx
## Android TV
set kdir=/android-2020-03-30 # 设置 Android TV 内核所在路径
search --no-floppy --set android_tv_os_root -f $kdir/kernel # 搜索 Android TV 系统内核所在分区，写入到 android_tv_os_root 变量（从而指定后续`linux`命令加载内核的分区，如`hd0,gpt2`）
export kdir android_tv_os_root
add_android_tv_entry "Android TV" "android" quiet
submenu "Android TV (More options)" --class submenu {
    add_android_tv_entry "Android TV - Laptop mode" "android" quiet video=eDP-1:d video=HDMI-A-1:e
    add_android_tv_entry "Android TV - DEBUG mode" "android" DEBUG=2
    add_android_tv_entry "Android TV - No Hardware Acceleration" "android" quiet nomodeset HWACCEL=0 # 注意：在 VM 虚拟机中，只能使用该选项（禁用硬件加速）以启动系统
    add_android_tv_entry "Android TV - TWRP Recovery" "recovery" quiet androidboot.selinux=permissive RAMDISK=ramdisk-recovery.img
}
## 高级选项
submenu "#Advanced options" --class submenu {
    add_os_if_exists /EFI/BOOT/$bootefi "UEFI OS" efi
    add_os_if_exists /EFI/BOOT/fallback.efi "UEFI Fallback" efi
    add_os_if_exists /EFI/BOOT/fallback_x64.efi "UEFI Fallback" efi
    menuentry "Reboot" --class restart { reboot }
    menuentry "Poweroff" --class shutdown { halt }
    menuentry "UEFI firmware settings" --class driver { fwsetup }
}
```