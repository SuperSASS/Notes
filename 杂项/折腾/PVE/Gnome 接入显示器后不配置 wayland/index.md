# Gnome 接入显示器后不配置 wayland

* 问题：在没插入显示器启动并进入 Gnome 后，`$WAYLAND_DISPLAY`为空，不存在`/run/user/1000/wayland-0`，会导致 waydroid 无法运行。  
  而在这之后插入显示器，也不会配置好，需要注销重新登陆后才可以。
* 方法：

## 🧰 步骤一：创建 udev 热插拔检测规则

### 📄 文件路径：`/etc/udev/rules.d/99-monitor-first-plug.rules`

```ini
SUBSYSTEM=="drm", ACTION=="change", RUN+="/usr/local/bin/monitor-first-plug.sh"
```

---

## 🧰 步骤二：写检测 HDMI 插入并重新登陆的脚本

### 📄 文件路径：`/usr/local/bin/monitor-first-plug.sh`

```bash
#!/bin/bash

# 确保日志输出
exec >> /tmp/monitor-first-plug.log 2>&1
echo "HDMI hotplug event at $(date)"

# 检查是否有物理显示连接
CONNECTED=$(grep -H ^connected /sys/class/drm/card*-*/status | grep ":connected" | wc -l)

# 检查是否已经有 Wayland socket
USER_ID=1000  # 你的用户ID（可以用 `id -u` 查看）
WAYLAND_SOCKET="/run/user/${USER_ID}/wayland-0"

if [ "$CONNECTED" -ge 1 ]; then
    echo "HDMI display connected."

    if [ ! -S "$WAYLAND_SOCKET" ]; then
        echo "No Wayland session found. Restarting GDM..."

        # 等一会，确保系统识别到 HDMI 显示器
        sleep 5

        systemctl restart gdm
    else
        echo "Wayland session already running, no need to restart GDM."
    fi
else
    echo "No HDMI display connected."
fi
```

> 🔐 记得给这个脚本加执行权限：

```bash
sudo chmod +x /usr/local/bin/monitor-first-plug.sh
```
