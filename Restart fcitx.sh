pkill fcitx5-bin
flatpak run org.fcitx.Fcitx5 -d 2> /dev/null

# 删除端口，可以输入端口的名称或 ID
    openstack image create <IMAGE_NAME> --file <FILE_PATH> --disk-format <DISK_FORMAT> --container-format <CONTAINER_FORMAT> --public --progress
    # <IMAGE_NAME>: 精选的名称
    # <FILE_PATH>: 镜像文件路径
    # <DISK_FORMAT>: 镜像格式
    # <CONTAINER_FORMAT>:  镜像容器的格式
    # --public / private: 镜像能否被其它用户访问
    # --progress: 显示上传的进度条

openstack server resize confirm <SERVER_NAME_OR_ID>
openstack server resize revert <SERVER_NAME_OR_ID>

