#!/bin/bash
# ============================================================================
# diy-part2.sh - ImmortalWrt 自定义脚本 (配置阶段)
# ============================================================================

set -e

echo "=========================================="
echo "💕 强哥专属固件 - diy-part2.sh 执行中"
echo "=========================================="

cd openwrt

# ============================================================================
# 1. 安装必装插件
# ============================================================================
echo "📦 安装必装插件..."

./scripts/feeds install -a

# ============================================================================
# 2. 安装指定插件
# ============================================================================
echo "📦 安装指定插件..."

./scripts/feeds install luci-app-adguardhome 2>/dev/null || true
./scripts/feeds install luci-app-cloudflared 2>/dev/null || true
./scripts/feeds install luci-app-ksmbd 2>/dev/null || true
./scripts/feeds install luci-app-openclash 2>/dev/null || true
./scripts/feeds install luci-app-qbittorrent 2>/dev/null || true
./scripts/feeds install luci-app-tailscale 2>/dev/null || true
./scripts/feeds install luci-app-dockerman 2>/dev/null || true
./scripts/feeds install luci-lib-docker 2>/dev/null || true
./scripts/feeds install luci-app-filebrowser 2>/dev/null || true
./scripts/feeds install luci-app-sqm 2>/dev/null || true
./scripts/feeds install luci-app-ttyd 2>/dev/null || true
./scripts/feeds install luci-app-vlmcsd 2>/dev/null || true
./scripts/feeds install luci-app-diskman 2>/dev/null || true
./scripts/feeds install luci-app-reboot 2>/dev/null || true
./scripts/feeds install luci-app-lxc 2>/dev/null || true
./scripts/feeds install luci-app-filemanager 2>/dev/null || true
./scripts/feeds install luci-app-daed 2>/dev/null || true
./scripts/feeds install daed 2>/dev/null || true

# ============================================================================
# 3. 安装中文语言包
# ============================================================================
echo "🌏 安装中文语言包..."

./scripts/feeds install luci-i18n-base-zh-cn 2>/dev/null || true

for pkg in adguardhome cloudflared ksmbd openclash qbittorrent tailscale dockerman filebrowser sqm ttyd vlmcsd diskman reboot lxc filemanager daed; do
    ./scripts/feeds install luci-i18n-${pkg}-zh-cn 2>/dev/null || true
done

# ============================================================================
# 4. 启用 USB 和 SATA 支持
# ============================================================================
echo "🔌 启用 USB 和 SATA 支持..."

./scripts/feeds install kmod-usb-core
./scripts/feeds install kmod-usb2
./scripts/feeds install kmod-usb3
./scripts/feeds install kmod-usb-storage

# 注意：不安装 automount 和 kmod-usb-storage-uas (会造成 USB 挂载不正常)

./scripts/feeds install kmod-ata-core
./scripts/feeds install kmod-ata-ahci
./scripts/feeds install kmod-ata-ahci-platform
./scripts/feeds install kmod-scsi-core

# ============================================================================
# 5. 配置 LuCI 中文界面
# ============================================================================
echo "🌏 配置 LuCI 中文界面..."

cat >> package/feeds/luci/luci-base/root/etc/config/luci << EOF
config core 'main'
    option lang 'zh_cn'
EOF

echo 'CONFIG_LUCI_LANG_zh-cn=y' >> .config

# ============================================================================
# 6. Files 方法 - 预配置插件
# ============================================================================
echo "📁 配置 Files 方法..."

mkdir -p files/etc/config
mkdir -p files/etc/init.d
mkdir -p files/usr/bin
mkdir -p files/etc/uci-defaults

# 6.1 网络配置
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
    option dns '114.114.114.114 223.5.5.5'

config interface 'wan'
    option device 'eth0'
    option proto 'dhcp'

config bridge 'br-lan'
    option name 'br-lan'
    list ports 'eth1'
EOF

# 6.2 系统配置
cat > files/etc/config/system << 'EOF'
config system
    option hostname 'ImmortalWrt-QiangGe'
    option timezone 'CST-8'
    option zonename 'Asia/Shanghai'
    option log_size '64'
    option log_ip '127.0.0.1'
    option log_port '514'
    option log_proto 'udp'

config timeserver 'ntp'
    list server '0.pool.ntp.org'
    list server '1.pool.ntp.org'
    list server '2.pool.ntp.org'
    list server '3.pool.ntp.org'
    option enable_server '0'
EOF

# 6.3 LuCI 配置
cat > files/etc/config/luci << 'EOF'
config core 'main'
    option lang 'zh_cn'
    option mediaurlbase '/luci-static/opentomcat'
    option resourcebase '/luci-resources'

config external 'github'
    option name 'GitHub'
    option url 'https://github.com'

config promiscuity 'promiscuity'
    option ifname 'br-lan'
EOF

# 6.4 开机自动启动配置
cat > files/etc/uci-defaults/99-qiangge-custom << 'EOF'
#!/bin/sh

uci set luci.main.lang='zh_cn'
uci commit luci

/etc/init.d/ttyd enable 2>/dev/null || true
/etc/init.d/docker enable 2>/dev/null || true
/etc/init.d/adguardhome enable 2>/dev/null || true
/etc/init.d/openclash enable 2>/dev/null || true

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

rm -f /etc/config/dhcp.orig
rm -f /etc/config/firewall.orig
rm -f /etc/config/network.orig

exit 0
EOF
chmod +x files/etc/uci-defaults/99-qiangge-custom

# ============================================================================
# 7. 自定义 LuCI 界面
# ============================================================================
echo "🎨 自定义 LuCI 界面..."

cat > files/etc/banner << 'EOF'
  ____      _   _       _     _ _ _ 
 |  _ \ ___| |_| |_   _| |__ (_) | |
 | |_) / _ \ __| | | | | '_ \| | | |
 |  _ <  __/ |_| | |_| | |_) | | | |
 |_| \_\___|\__|_|\__, |_.__/|_|_|_|
                  |___/            
 强哥专属 ImmortalWrt
 琳琳永远陪着你 ❤️
EOF

# ============================================================================
# 8. 优化配置
# ============================================================================
echo "⚡ 优化配置..."

echo 'CONFIG_PACKAGE_opkg=y' >> .config
echo 'CONFIG_PACKAGE_luci=y' >> .config
echo 'CONFIG_PACKAGE_luci-base=y' >> .config
echo 'CONFIG_PACKAGE_luci-ssl=y' >> .config
echo 'CONFIG_PACKAGE_vim=y' >> .config
echo 'CONFIG_PACKAGE_wget=y' >> .config
echo 'CONFIG_PACKAGE_curl=y' >> .config
echo 'CONFIG_PACKAGE_git=y' >> .config
echo 'CONFIG_PACKAGE_iperf3=y' >> .config
echo 'CONFIG_PACKAGE_tcpdump=y' >> .config
echo 'CONFIG_PACKAGE_mtr=y' >> .config

# ============================================================================
# 9. 清理和优化
# ============================================================================
echo "🧹 清理和优化..."

rm -rf ./tmp/* 2>/dev/null || true
rm -rf ./feeds/*.index 2>/dev/null || true

cd ..

echo "=========================================="
echo "✅ diy-part2.sh 执行完成！"
echo "=========================================="
echo ""
echo "📦 已安装插件:"
echo "  ✅ AdGuard Home"
echo "  ✅ Cloudflared"
echo "  ✅ KSMBD"
echo "  ✅ OpenClash"
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
echo "=========================================="
