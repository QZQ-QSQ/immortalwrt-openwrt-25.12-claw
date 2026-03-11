#!/bin/bash
# ==============================================================================
# ImmortalWrt DIY Script Part 2
# 用于在 feeds 更新后执行自定义操作（安装软件包等）
# ==============================================================================

set -e
cd openwrt

echo "=============================================="
echo "ImmortalWrt DIY Script Part 2"
echo "=============================================="

# 安装 kenzok8/small 软件包
echo "Installing packages from kenzok8/small..."
./scripts/feeds update small
./scripts/feeds install -a -p small

# 安装第三方插件
echo "Installing third-party plugins..."
./scripts/feeds update adguardhome
./scripts/feeds install luci-app-adguardhome

./scripts/feeds update openclash
./scripts/feeds install luci-app-openclash

# 安装所有指定插件
./scripts/feeds install AdGuardHome
./scripts/feeds install cloudflared
./scripts/feeds install luci-app-cloudflared
./scripts/feeds install ksmbd
./scripts/feeds install luci-app-ksmbd
./scripts/feeds install luci-app-openclash
./scripts/feeds install qbittorrent
./scripts/feeds install luci-app-qbittorrent
./scripts/feeds install tailscale
./scripts/feeds install luci-app-tailscale
./scripts/feeds install docker
./scripts/feeds install dockerd
./scripts/feeds install containerd
./scripts/feeds install runc
./scripts/feeds install luci-app-dockerman
./scripts/feeds install filebrowser
./scripts/feeds install luci-app-filebrowser
./scripts/feeds install sqm-scripts
./scripts/feeds install sqm-scripts-extra
./scripts/feeds install luci-app-sqm
./scripts/feeds install ttyd
./scripts/feeds install luci-app-ttyd
./scripts/feeds install vlmcsd
./scripts/feeds install luci-app-vlmcsd
./scripts/feeds install luci-app-diskman
./scripts/feeds install luci-app-reboot
./scripts/feeds install lxc
./scripts/feeds install luci-app-lxc
./scripts/feeds install luci-app-filemanager
./scripts/feeds install daed
./scripts/feeds install luci-app-daed

# 安装中文语言包
echo "Installing Chinese language packs..."
./scripts/feeds install luci-i18n-base-zh-cn
./scripts/feeds install luci-i18n-admin-zh-cn
./scripts/feeds install luci-i18n-firewall-zh-cn
./scripts/feeds install luci-i18n-network-zh-cn
./scripts/feeds install luci-i18n-system-zh-cn
./scripts/feeds install luci-i18n-services-zh-cn
./scripts/feeds install luci-i18n-status-zh-cn
./scripts/feeds install luci-i18n-nas-zh-cn
./scripts/feeds install luci-i18n-docker-zh-cn
./scripts/feeds install luci-i18n-ddns-zh-cn
./scripts/feeds install luci-i18n-upnp-zh-cn
./scripts/feeds install luci-i18n-vpn-zh-cn
./scripts/feeds install luci-i18n-samba-zh-cn
./scripts/feeds install luci-i18n-commands-zh-cn
./scripts/feeds install luci-i18n-filetransfer-zh-cn

# 安装 USB 和 SATA 支持
echo "Installing USB and SATA support..."
./scripts/feeds install kmod-usb-core kmod-usb2 kmod-usb3 kmod-usb-storage
./scripts/feeds install kmod-usb-ohci kmod-usb-uhci kmod-usb-ehci kmod-usb-xhci
./scripts/feeds install kmod-sata-ahci kmod-sata-sil kmod-sata-sil24
./scripts/feeds install kmod-ahci kmod-libata kmod-scsi-core

# 安装文件系统支持
./scripts/feeds install kmod-fs-ext4 kmod-fs-vfat kmod-fs-ntfs kmod-fs-ntfs3
./scripts/feeds install kmod-fs-exfat kmod-fs-btrfs kmod-fuse

# 安装科学上网插件依赖
echo "Installing VPN proxy dependencies..."
./scripts/feeds install v2ray-geosite v2ray-geoip xray-core xray-plugin
./scripts/feeds install sing-box sing-box-plugins
./scripts/feeds install shadowsocksr-libev ssr-libev-server simple-obfs
./scripts/feeds install trojan trojan-go trojan-plus
./scripts/feeds install naiveproxy redsocks2 haproxy
./scripts/feeds install microsocks shadow-tls hysteria hysteria2
./scripts/feeds install tuic-client tuic-server dns2tcp
./scripts/feeds install ipt2socks tcping
./scripts/feeds install luci-app-ssr-plus luci-app-xray luci-app-sing-box
./scripts/feeds install luci-app-openclash luci-app-passwall luci-app-passwall2
./scripts/feeds install chinadns-ng smartdns luci-app-smartdns

# 禁用不需要的包
echo "Disabling unwanted packages..."
sed -i 's/CONFIG_PACKAGE_automount=y/CONFIG_PACKAGE_automount=n/' .config 2>/dev/null || true
sed -i 's/CONFIG_PACKAGE_kmod-usb-storage-uas=y/CONFIG_PACKAGE_kmod-usb-storage-uas=n/' .config 2>/dev/null || true

# 创建 LuCI 默认配置
mkdir -p files/etc/config
cat > files/etc/config/luci <<EOF
config core 'main'
    option mediaurlbase 'luci-static/bootstrap'
    option lang 'zh_cn'

config internal 'languages'
    option default 'zh_cn'
EOF

# 创建系统默认配置
cat > files/etc/config/system <<EOF
config system
    option hostname 'ImmortalWrt'
    option timezone 'CST-8'
    option timezone_name 'Asia/Shanghai'

config timeserver 'ntp'
    list server 'ntp.aliyun.com'
    list server 'ntp.tencent.com'
    list server 'ntp.ntsc.ac.cn'
    option enabled '1'
    option enable_server '0'
EOF

# 创建网络默认配置
cat > files/etc/config/network <<EOF
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
    option device 'eth1'
    option proto 'dhcp'

config device
    option name 'br-lan'
    option type 'bridge'
    list ports 'eth0'
EOF

# 创建防火墙默认配置
cat > files/etc/config/firewall <<EOF
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

echo "=============================================="
echo "DIY Part 2 Completed"
echo "=============================================="