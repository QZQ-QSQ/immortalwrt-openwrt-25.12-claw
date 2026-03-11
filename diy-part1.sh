#!/bin/bash
# ============================================================================
# diy-part1.sh - ImmortalWrt 自定义脚本 (准备阶段)
# ============================================================================

set -e

echo "=========================================="
echo "💕 强哥专属固件 - diy-part1.sh 执行中"
echo "=========================================="

cd openwrt

# ============================================================================
# 1. 添加第三方软件源 (kenzok8/small)
# ============================================================================
echo "📦 添加第三方软件源 (kenzok8/small)..."

git clone --depth 1 https://github.com/kenzok8/small.git package/small
git clone --depth 1 https://github.com/kenzok8/small-package.git package/small-package

# ============================================================================
# 2. 添加其他常用第三方源
# ============================================================================
echo "📦 添加其他第三方软件源..."

git clone --depth 1 https://github.com/immortalwrt/packages.git package/immortalwrt-packages
git clone --depth 1 https://github.com/Lienol/openwrt-package.git package/lienol
git clone --depth 1 -b master https://github.com/vernesong/OpenClash.git package/OpenClash
git clone --depth 1 -b master https://github.com/lisaac/luci-app-diskman.git package/luci-app-diskman
git clone --depth 1 https://github.com/kiddin9/openwrt-docker.git package/openwrt-docker

# ============================================================================
# 3. 修复依赖问题
# ============================================================================
echo "🔧 修复依赖问题..."

if [ -f "feeds/packages/lang/rust/Makefile" ]; then
    sed -i 's/download-ci-llvm = true/download-ci-llvm = false/g' feeds/packages/lang/rust/Makefile
    echo "✅ Rust LLVM 修复完成"
fi

if [ -f "package/small/Makefile" ]; then
    sed -i '/fchomo/d' package/small/Makefile 2>/dev/null || true
    sed -i '/nikki/d' package/small/Makefile 2>/dev/null || true
fi

# ============================================================================
# 4. 替换默认配置
# ============================================================================
echo "⚙️ 替换默认配置..."

sed -i 's/ImmortalWrt/ImmortalWrt-QiangGe/g' package/base-files/files/bin/config_generate
sed -i 's/timezone=\"UTC\"/timezone=\"CST-8\"/g' package/base-files/files/bin/config_generate
sed -i '/timezone=\"CST-8\"/a\set system.@system[-1].zonename=\"Asia/Shanghai\"' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='ImmortalWrt-QiangGe'/g" package/base-files/files/bin/config_generate

# ============================================================================
# 5. 添加自定义脚本
# ============================================================================
echo "📝 添加自定义脚本..."

mkdir -p files/root/scripts

cat > files/root/scripts/update-plugins.sh << 'EOF'
#!/bin/sh
echo "更新插件列表..."
opkg update
echo "更新完成！"
EOF
chmod +x files/root/scripts/update-plugins.sh

# ============================================================================
# 6. 优化配置
# ============================================================================
echo "⚡ 优化配置..."

echo 'CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y' >> .config
echo 'CONFIG_PACKAGE_dnsmasq_full_ra=y' >> .config
echo 'CONFIG_PACKAGE_kmod-usb-core=y' >> .config
echo 'CONFIG_PACKAGE_kmod-usb2=y' >> .config
echo 'CONFIG_PACKAGE_kmod-usb3=y' >> .config
echo 'CONFIG_PACKAGE_kmod-ata-core=y' >> .config
echo 'CONFIG_PACKAGE_kmod-ata-ahci=y' >> .config
echo 'CONFIG_PACKAGE_kmod-ata-ahci-platform=y' >> .config

# ============================================================================
# 7. 清理临时文件
# ============================================================================
echo "🧹 清理临时文件..."

find package -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true

cd ..

echo "=========================================="
echo "✅ diy-part1.sh 执行完成！"
echo "=========================================="
