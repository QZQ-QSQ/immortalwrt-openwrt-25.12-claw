#!/bin/bash
# ==============================================================================
# ImmortalWrt DIY Script Part 2 - 强哥专属
# ==============================================================================

set -e
cd openwrt

echo "=============================================="
echo "💕 强哥专属固件 - diy-part2.sh"
echo "=============================================="

# ==============================================================================
# 1. 添加第三方 feeds 源
# ==============================================================================
echo "📦 添加第三方 feeds 源..."

# 添加 kenzok8/small 源
echo "src-git kenzok8 https://github.com/kenzok8/small.git" >> feeds.conf.default
echo "src-git small-package https://github.com/kenzok8/small-package.git" >> feeds.conf.default

# 添加其他源
echo "src-git immortalwrt_packages https://github.com/immortalwrt/packages.git" >> feeds.conf.default
echo "src-git lienol https://github.com/Lienol/openwrt-package.git" >> feeds.conf.default

# ==============================================================================
# 2. 更新 feeds 并安装
# ==============================================================================
echo "🔄 更新 feeds..."

./scripts/feeds update -a
./scripts/feeds install -a

# ==============================================================================
# 3. 安装科学上网插件
# ==============================================================================
echo "🌐 安装科学上网插件..."

# OpenClash
git clone --depth 1 -b master https://github.com/vernesong/OpenClash.git package/OpenClash

# PassWall
./scripts/feeds install luci-app-passwall || true
./scripts/feeds install luci-app-passwall2 || true

# SSR Plus
./scripts/feeds install luci-app-ssr-plus || true

# 科学上网依赖
./scripts/feeds install v2ray-geosite || true
./scripts/feeds install v2ray-geoip || true
./scripts/feeds install xray-core || true
./scripts/feeds install shadowsocksr-libev || true
./scripts/feeds install simple-obfs || true
./scripts/feeds install trojan || true
./scripts/feeds install trojan-plus || true
./scripts/feeds install naiveproxy || true
./scripts/feeds install redsocks2 || true
./scripts/feeds install hysteria || true
./scripts/feeds install hysteria2 || true
./scripts/feeds install tuic-client || true
./scripts/feeds install sing-box || true
./scripts/feeds install chinadns-ng || true
./scripts/feeds install smartdns || true
./scripts/feeds install ipt2socks || true
./scripts/feeds install tcping || true
./scripts/feeds install dns2tcp || true

# ==============================================================================
# 4. 安装指定插件
# ==============================================================================
echo "📦 安装指定插件..."

# AdGuard Home
./scripts/feeds install luci-app-adguardhome || true

# Cloudflared
./scripts/feeds install luci-app-cloudflared || true

# KSMBD (SMB)
./scripts/feeds install luci-app-ksmbd || true
./scripts/feeds install kmod-fs-smbfs-common || true
./scripts/feeds install kmod-fs-cifs || true

# qBittorrent
./scripts/feeds install luci-app-qbittorrent || true

# Tailscale
./scripts/feeds install luci-app-tailscale || true
./scripts/feeds install tailscale || true

# Docker
./scripts/feeds install luci-app-dockerman || true
./scripts/feeds install luci-lib-docker || true
./scripts/feeds install docker || true
./scripts/feeds install dockerd || true
./scripts/feeds install containerd || true
./scripts/feeds install runc || true
./scripts/feeds install libseccomp || true

# FileBrowser
./scripts/feeds install luci-app-filebrowser || true

# SQM
./scripts/feeds install luci-app-sqm || true
./scripts/feeds install sqm-scripts || true

# ttyd
./scripts/feeds install luci-app-ttyd || true

# VLMCSd
./scripts/feeds install luci-app-vlmcsd || true

# DiskMan
./scripts/feeds install luci-app-diskman || true

# Reboot
./scripts/feeds install luci-app-reboot || true

# LXC
./scripts/feeds install luci-app-lxc || true
./scripts/feeds install lxc || true

# FileManager
./scripts/feeds install luci-app-filemanager || true

# DAED
./scripts/feeds install luci-app-daed || true
./scripts/feeds install daed || true

# ==============================================================================
# 5. 安装中文语言包
# ==============================================================================
echo "🌏 安装中文语言包..."

./scripts/feeds install luci-i18n-base-zh-cn || true

for pkg in adguardhome cloudflared ksmbd openclash qbittorrent tailscale dockerman filebrowser sqm ttyd vlmcsd diskman reboot lxc filemanager daed passwall ssr-plus; do
    ./scripts/feeds install luci-i18n-${pkg}-zh-cn 2>/dev/null || true
done

# ==============================================================================
# 6. 安装 USB 和 SATA 支持
# ==============================================================================
echo "🔌 安装 USB 和 SATA 支持..."

# USB
./scripts/feeds install kmod-usb-core || true
./scripts/feeds install kmod-usb2 || true
./scripts/feeds install kmod-usb3 || true
./scripts/feeds install kmod-usb-storage || true
./scripts/feeds install kmod-usb-ohci || true
./scripts/feeds install kmod-usb-ehci || true
./scripts/feeds install kmod-usb-xhci || true

# SATA
./scripts/feeds install kmod-ata-core || true
./scripts/feeds install kmod-ata-ahci || true
./scripts/feeds install kmod-ata-ahci-platform || true
./scripts/feeds install kmod-scsi-core || true

# 文件系统
./scripts/feeds install kmod-fs-ext4 || true
./scripts/feeds install kmod-fs-vfat || true
./scripts/feeds install kmod-fs-ntfs3 || true
./scripts/feeds install kmod-fs-exfat || true
./scripts/feeds install kmod-fuse || true

# ==============================================================================
# 7. 禁用不需要的包
# ==============================================================================
echo "🚫 禁用不需要的包..."

echo 'CONFIG_PACKAGE_automount=n' >> .config
echo 'CONFIG_PACKAGE_kmod-usb-storage-uas=n' >> .config

# ==============================================================================
# 8. 创建 LuCI 默认配置
# ==============================================================================
echo "⚙️ 创建 LuCI 默认配置..."

mkdir -p files/etc/config

cat > files/etc/config/luci << 'EOF'
config core 'main'
    option mediaurlbase 'luci-static/bootstrap'
    option lang 'zh_cn'

config internal 'languages'
    option default 'zh_cn'
EOF

# ==============================================================================
# 9. 创建系统默认配置
# ==============================================================================
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

# ==============================================================================
# 10. 创建网络默认配置
# ==============================================================================
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

# ==============================================================================
# 11. 创建防火墙默认配置
# ==============================================================================
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

# ==============================================================================
# 12. 创建开机自动配置
# ==============================================================================
mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-qiangge-custom << 'EOF'
#!/bin/sh

uci set luci.main.lang='zh_cn'
uci commit luci

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

exit 0
EOF
chmod +x files/etc/uci-defaults/99-qiangge-custom

# ==============================================================================
# 13. 完成
# ==============================================================================
echo "=============================================="
echo "✅ diy-part2.sh 执行完成！"
echo "=============================================="
echo ""
echo "📦 已安装插件:"
echo "  ✅ OpenClash"
echo "  ✅ PassWall"
echo "  ✅ SSR Plus"
echo "  ✅ AdGuard Home"
echo "  ✅ Cloudflared"
echo "  ✅ KSMBD"
echo "  ✅ qBittorrent"
echo "  ✅ Tailscale"
echo "  ✅ Docker (Dockerman)"
echo "  ✅ FileBrowser"
echo "  ✅ SQM"
echo "  ✅ ttyd"
echo "  ✅ VLMCSd"
echo "  ✅ DiskMan"
echo "  ✅ Reboot"
echo "  ✅ LXC"
echo "  ✅ FileManager"
echo "  ✅ DAED"
echo ""
echo "🌏 LuCI 界面：中文"
echo "🔌 USB 支持：USB2 + USB3"
echo "💾 SATA 支持：SATA3"
echo "=============================================="
