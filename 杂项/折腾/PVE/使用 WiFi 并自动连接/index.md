# PVE 使用 WiFi 并自动连接

说明：并不需要在 PVE 中连接 WiFi，将 WiFi 网卡直通给 OpenWRT，然后作为 WWAN，从而引出同一网段的 LAN 和 WiFi。

参考教程：[PVE 8.x 折腾WiFi](https://www.yibin.blog/article/d40bebc1-8b67-4760-a007-b343c7086e56)

## 其他问题

### 1. 开机时，会等待连接好 WiFi 才进入系统，如果无法连接 WiFi 会阻塞开机

**原因**：`systemd-networkd-wait-online`服务导致的。  
该服务会等待所有被`systemd-networkd`所管理的接口达到可路由的状态。因为之前设置了 WiFi 的 DHCP 服务，但这里因为连不上 WiFi 无法配置，故会一直堵塞直至超过最大重连次数。

**解决方法**：

1. 直接禁用该服务：输入命令`sudo systemctl disable systemd-networkd-wait-online.service`
2. 如果要达成这样的效果：如果连接上有线 / 无线中的任意一个，则该服务通过。  
   此时需要首先添加有关有线（管理网口）的`network`服务配置：
   1. 输入命令`nano /etc/systemd/network/10-vmbr0-dhcp.network`，添加有关管理网口（`vmbr0`虚拟网桥）的配置，在其中输入以下内容：

      ```conf
      [Match]
      Name=vmbr0
      
      [Network]
      Address=192.168.1.2/24
      Gateway=192.168.1.1
      DNS=192.168.1.1
      ```

      其中有关 IP 应当保持在安装 PVE 时所设置的固定 IP，网关、DNS 也应当根据有线网络正确配置（**可以首先在这步之前输入`ip a`查看现在的配置，然后保持一致即可**），
      输入完毕后保存退出。
   2. 输入命令`systemctl edit systemd-networkd-wait-online.service`，配置`systemd-networkd-wait-online`服务，让其有一个管理网口上线即可，输入以下内容：

      ```conf
      [Service]
      ExecStart=
      ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any
      ```

      注：第一行`ExecStart=`是必要的，用于清空配置（具体原因也不知道）  
      *参考自"[Boot process hangs at systemd-networkd-wait-online](https://askubuntu.com/questions/1217252/boot-process-hangs-at-systemd-networkd-wait-online)"。*

重启后问题应当解决。
