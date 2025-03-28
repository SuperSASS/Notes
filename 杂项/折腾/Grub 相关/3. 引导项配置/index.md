# Windows 的 Grub 2 引导项手动配置

```sh
### 注意: 如果启用了 Secure Boot，则不可以使用 insmod 加载 mod（而要在 grub-install 时通过`--modules=`预加载 mod），原因可见"wiki.archlinuxcn.org/wiki/GRUB"的"2.2.2 Shim-lock"

# 设置超时时间和默认选项
set timeout=5
set default=0

# 设置语言
set gfxterm_font=unicode
set lang=zh_CN # 设置为中文
set locale_dir=/EFI/grub/locale # 设置翻译文件目录（不设置则无法使用中文）
loadfont /EFI/grub/fonts/unicode.pf2

# 图形终端（主题）相关
set gfxmode=1920x1080,1280x720,auto # 分辨率设置
set gfxpayload=keep # Linux 内核的视频模式（不明白什么意思，不加也可以）
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
    set os_root="" # 清空局部变量
    if [ search --no-floppy -f "$1" ]; then # 判断该 OS 对应的 efi 文件所在分区是否存在（如果不加这个判断，则会导致在进入 submenu 时如果找不到、会弹出报错信息）
        search --no-floppy --set os_root -f "$1" # 搜索该 OS 对应的 efi 文件所在分区，写入到 os_root 变量，如`hd0,gpt1`
        menuentry "$2" "$os_root" "$1" --class "$3" { # 注：`"$2"`后面的作为参数传入，故内部的`$2`实际上代表这里的`$os_root`
            chainloader "($2)$3"
        }
    fi
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
        set root="$android_tv_os_root"
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
## Mac OS
add_os_if_exists /EFI/CLO2020-03-30/${grub}.efi macOS macosx
## Android TV
set kdir=/android-2020-03-30 # 设置 Android TV 内核所在路径
search --no-floppy --set android_tv_os_root -f "$kdir/kernel" # 搜索 Android TV 系统内核所在分区，写入到 android_tv_os_root 变量（从而指定后续`linux`命令加载内核的分区，如`hd0,gpt2`）
if [ -n "$android_tv_os_root" ]; then # 如果存在 Android TV 系统
    export kdir android_tv_os_root
    add_android_tv_entry "Android TV" "android" quiet
    submenu "Android TV (More options)" --class submenu {
        add_android_tv_entry "Android TV - Laptop mode" "android" quiet video=eDP-1:d video=HDMI-A-1:e
        add_android_tv_entry "Android TV - DEBUG mode" "android" DEBUG=2
        add_android_tv_entry "Android TV - No Hardware Acceleration" "android" quiet nomodeset HWACCEL=0 # 注意：在 VM 虚拟机中，只能使用该选项（禁用硬件加速）以启动系统
    	add_android_tv_entry "Android TV - Vulkan support (experimental)" "android" quiet VULKAN=1
    	add_android_tv_entry "Android TV - No Setup Wizard" "android" quiet SETUPWIZARD=0
        add_android_tv_entry "Android TV - TWRP Recovery" "recovery" quiet androidboot.selinux=permissive RAMDISK=ramdisk-recovery.img
    }
fi
## Batocera
set disk_label="Batocera-OS" # Batocera 系统所在分区的卷标
search --no-floppy --set batocera_os_root --label "$disk_label"
if [ -n "$batocera_os_root" ]; then
    menuentry "Batocera" --class "batocera" {
        set root="$batocera_os_root"
        linux /boot/linux label="$disk_label" console=tty3 quiet loglevel=0 vt.global_cursor_default=0
        initrd /boot/initrd.gz
    }
fi
## 高级选项
submenu "# Advanced options" --class submenu {
    add_os_if_exists /EFI/BOOT/$bootefi "UEFI OS" efi
    add_os_if_exists /EFI/BOOT/fallback.efi "UEFI Fallback" efi
    add_os_if_exists /EFI/BOOT/fallback_x64.efi "UEFI Fallback" efi
    menuentry "Reboot" --class restart { reboot }
    menuentry "Poweroff" --class shutdown { halt }
    menuentry "UEFI firmware settings" --class driver { fwsetup }
}
```