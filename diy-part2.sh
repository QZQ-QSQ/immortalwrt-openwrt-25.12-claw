#!/bin/bash
# ============================================================================
# diy-part2.sh - OpenWrt 自定义脚本 (配置阶段)
# 参考：P3TERX/Actions-OpenWrt 成功案例
# ============================================================================

set -e

echo "=========================================="
echo "💕 强哥专属固件 - diy-part2.sh"
echo "=========================================="

cd openwrt

# ============================================================================
# 1. 更新 feeds 并安装所有包
# ============================================================================
echo "🔄 更新 feeds..."

./scripts/feeds update -a
./scripts/feeds install -a

# ============================================================================
# 2. 写入自定义配置
# ============================================================================
echo "⚙️ 写入自定义配置..."

cat >> .config << 'EOF'
# LuCI 中文
CONFIG_LUCI_LANG_zh-cn=y

# 必装插件 (不要 PassWall，不要 SSR-Plus)
CONFIG_PACKAGE_luci-app-adguardhome=y
CONFIG_PACKAGE_luci-app-cloudflared=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_luci-app-qbittorrent=y
CONFIG_PACKAGE_luci-app-dockerman=y
CONFIG_PACKAGE_luci-app-filebrowser=y
CONFIG_PACKAGE_luci-app-sqm=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-vlmcsd=y
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-reboot=y
CONFIG_PACKAGE_luci-app-lxc=y
CONFIG_PACKAGE_luci-app-filemanager=y
CONFIG_PACKAGE_luci-app-daed=y

# Docker
CONFIG_PACKAGE_docker=y
CONFIG_PACKAGE_dockerd=y
CONFIG_PACKAGE_containerd=y
CONFIG_PACKAGE_runc=y
CONFIG_PACKAGE_libseccomp=y

# USB 支持
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb3=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-usb-ohci=y
CONFIG_PACKAGE_kmod-usb-ehci=y
CONFIG_PACKAGE_kmod-usb-xhci=y

# SATA 支持
CONFIG_PACKAGE_kmod-ata-core=y
CONFIG_PACKAGE_kmod-ata-ahci=y
CONFIG_PACKAGE_kmod-ata-ahci-platform=y
CONFIG_PACKAGE_kmod-scsi-core=y

# 文件系统
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-vfat=y
CONFIG_PACKAGE_kmod-fs-ntfs3=y
CONFIG_PACKAGE_kmod-fs-exfat=y
CONFIG_PACKAGE_kmod-fuse=y

# 基础工具
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_git=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_tmux=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_ca-certificates=y

# 禁用不需要的包
# CONFIG_PACKAGE_automount is not set
# CONFIG_PACKAGE_kmod-usb-storage-uas is not set
EOF

# ============================================================================
# 3. Files 方法 - 预配置
# ============================================================================
echo "📁 配置 Files 方法..."

mkdir -p files/etc/config
mkdir -p files/etc/uci-defaults

# LuCI 配置
cat > files/etc/config/luci << 'EOF'
config core 'main'
    option lang 'zh_cn'
    option mediaurlbase '/luci-static/bootstrap'
EOF

# 系统配置
cat > files/etc/config/system << 'EOF'
config system
    option hostname 'ImmortalWrt-QiangGe'
    option timezone 'CST-8'
    option zonename 'Asia/Shanghai'

config timeserver 'ntp'
    list server 'ntp.aliyun.com'
    list server 'ntp.tencent.com'
    list server 'ntp.ntsc.ac.cn'
    option enabled '1'
    option enable_server '0'
EOF

# 网络配置
cat > files/etc/config/network << 'EOF'
config interface 'loopback'
    option device 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'

config interface 'lan'
    option device 'br-lan'
    option proto 'static'
    option ipaddr '192.168.1.1'
    option netmask '255.255.255.0'
    option ip6assign '60'
    option dns '223.5.5.5 114.114.114.114'

config interface 'wan'
    option device 'eth0'
    option proto 'dhcp'

config device
    option name 'br-lan'
    option type 'bridge'
    list ports 'eth1'
EOF

# 防火墙配置
cat > files/etc/config/firewall << 'EOF'
config defaults
    option input 'REJECT'
    option output 'ACCEPT'
    option forward 'REJECT'
    option synflood_protect '1'

config zone
    option name 'lan'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'ACCEPT'
    list network 'lan'

config zone
    option name 'wan'
    option input 'REJECT'
    option output 'ACCEPT'
    option forward 'REJECT'
    option masq '1'
    option mtu_fix '1'
    list network 'wan'

config forwarding
    option src 'lan'
    option dest 'wan'
EOF

# 开机自动配置
cat > files/etc/uci-defaults/99-qiangge-custom << 'EOF'
#!/bin/sh
uci set luci.main.lang='zh_cn'
uci commit luci
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
exit 0
EOF
chmod +x files/etc/uci-defaults/99-qiangge-custom

# ============================================================================
# 4. 清理
# ============================================================================
echo "🧹 清理..."

rm -rf ./tmp
rm -rf ./feeds/*.index

cd ..

echo "=========================================="
echo "✅ diy-part2.sh 完成"
echo "=========================================="
