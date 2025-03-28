# AX 101 解决蓝牙问题

* PVE：8.1.3
* Debian：12
* Linux pve 6.8.12-8-pve #1 SMP PREEMPT_DYNAMIC PMX 6.8.12-8 (2025-01-24T12:32Z) x86_64 GNU/Linux

## 解决方法

1. 从"https://deb.debian.org/debian/pool/non-free-firmware/f/firmware-nonfree/"下载"firmware-iwlwifi_20241210-1_all.deb"。  
   *可能没有这个版本，下载最新版本即可。*
2. 然后用 deb 解包工具，得到"data.tar.xz"。
3. 上传到主机中，解压
4. 将解压后的`./usr/lib/firmware/intel`中`ibt-0040-1050.sfi`和`ibt-0040-1050.ddc`通过`cp`复制到`/usr/lib/firmware/intel`。
