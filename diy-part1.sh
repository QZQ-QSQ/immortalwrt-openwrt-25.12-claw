#!/bin/bash
# ============================================================================
# diy-part1.sh - OpenWrt 自定义脚本 (准备阶段)
# 只编译核心基础插件，不要 LuCI 界面
# ============================================================================

set -e

echo "=========================================="
echo "💕 强哥专属固件 - diy-part1.sh"
echo "=========================================="

# 配置 Git
git config --global user.email "qiangge@example.com"
git config --global user.name "QiangGe"

cd openwrt

# ============================================================================
# 1. 添加第三方软件包源
# ============================================================================
echo "📦 添加第三方软件包源..."

# 添加 feeds.conf.default
cat >> feeds.conf.default << 'EOF'
src-git immortalwrt_packages https://github.com/immortalwrt/packages.git;openwrt-24.10
EOF

# ============================================================================
# 2. 克隆第三方插件（只克隆核心插件）
# ============================================================================
echo "📦 克隆第三方插件..."

# OpenClash（核心）
git clone --depth 1 -b master https://github.com/vernesong/OpenClash.git package/OpenClash

# ============================================================================
# 3. 替换默认配置
# ============================================================================
echo "⚙️ 替换默认配置..."

# 修改主机名
sed -i 's/ImmortalWrt/ImmortalWrt-QiangGe/g' package/base-files/files/bin/config_generate

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 修改时区
sed -i 's/timezone=\"UTC\"/timezone=\"CST-8\"/g' package/base-files/files/bin/config_generate
sed -i '/timezone=\"CST-8\"/a\set system.@system[-1].zonename=\"Asia/Shanghai\"' package/base-files/files/bin/config_generate

# 添加 DNS
sed -i '/set network.lan.dns/d' package/base-files/files/bin/config_generate
sed -i '/set network.lan.ipaddr/a\set network.lan.dns=\"223.5.5.5 114.114.114.114\"' package/base-files/files/bin/config_generate

# ============================================================================
# 4. 清理缓存
# ============================================================================
echo "🧹 清理缓存..."

rm -rf ./tmp
rm -rf ./feeds/*.index

cd ..

echo "=========================================="
echo "✅ diy-part1.sh 完成"
echo "=========================================="
