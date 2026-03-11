#!/bin/bash
# ==============================================================================
# ImmortalWrt DIY Script Part 1
# 用于在 feeds 更新前执行自定义操作
# ==============================================================================

set -e

echo "=============================================="
echo "ImmortalWrt DIY Script Part 1"
echo "=============================================="

# 添加第三方软件源 - kenzok8/small
echo "Adding third-party feeds (kenzok8/small)..."
cat >> feeds.conf.default <<EOF

# kenzok8/small packages
src-git small https://github.com/kenzok8/small.git;main

# PassWall packages
src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main
src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;main

# OpenClash
src-git openclash https://github.com/vernesong/OpenClash.git;master

# AdGuardHome
src-git adguardhome https://github.com/rufengsuixing/luci-app-adguardhome.git;main
EOF

# 更新版本信息
echo "Updating version information..."
sed -i 's/DISTRIB_REVISION=.*/DISTRIB_REVISION="ImmortalWrt-$(date +%Y%m%d)"/g' package/base-files/files/etc/openwrt_release

# 修改默认主机名
echo "Setting default hostname to ImmortalWrt..."
sed -i 's/OpenWrt/ImmortalWrt/g' package/base-files/files/etc/config/system 2>/dev/null || sed -i 's/OpenWrt/ImmortalWrt/g' package/base-files/files/etc/system.conf 2>/dev/null || true

# 修改默认时区
echo "Setting timezone to Asia/Shanghai..."
sed -i 's/UTC/CST-8/g' package/base-files/files/etc/config/system 2>/dev/null || sed -i 's/UTC/CST-8/g' package/base-files/files/etc/system.conf 2>/dev/null || true

# 添加自定义文件目录
echo "Creating files directory..."
mkdir -p files/etc/init.d
mkdir -p files/etc/config
mkdir -p files/etc/ssl/certs
mkdir -p files/usr/bin
mkdir -p files/root

# 创建开机自启动脚本
cat > files/etc/init.d/custom-start <<'EOF'
#!/bin/sh /etc/rc.common
START=99

start() {
    logger "Custom start script executed"
    echo "nameserver 223.5.5.5" > /etc/resolv.conf
    echo "nameserver 114.114.114.114" >> /etc/resolv.conf
    echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
    echo 1 > /proc/sys/net/ipv4/tcp_fastopen
    logger "Custom start script completed"
}
EOF
chmod +x files/etc/init.d/custom-start

# 添加中国地区 NTP 服务器
cat > files/etc/config/timeserver <<'EOF'
config timeserver 'ntp'
    list server 'ntp.aliyun.com'
    list server 'ntp.tencent.com'
    list server 'ntp.ntsc.ac.cn'
    option enabled '1'
    option enable_server '0'
EOF

echo "=============================================="
echo "DIY Part 1 Completed"
echo "=============================================="
