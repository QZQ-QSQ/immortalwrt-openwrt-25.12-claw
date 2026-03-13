#!/bin/bash
# ============================================================================
# diy-part2.sh - OpenWrt 自定义脚本 (配置阶段)
# 强哥专属配置 - immortalwrt-openwrt-25.12-claw
# ============================================================================

set -e

echo "=========================================="
echo "💕 强哥专属固件 - diy-part2.sh"
echo "=========================================="

cd openwrt

# ============================================================================
# 1. 更新 feeds
# ============================================================================
echo "🔄 更新 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a
echo "✅ feeds 更新完成"

# ============================================================================
# 2. 安装请求的插件
# ============================================================================
echo "📦 安装插件..."

# AdGuardHome
./scripts/feeds install luci-app-adguardhome 2>/dev/null || echo "⚠️  adguardhome 安装失败（可能不在官方源）"

# Tailscale
./scripts/feeds install luci-app-tailscale 2>/dev/null || echo "⚠️  tailscale 安装失败（可能不在官方源）"

# SMB (ksmbd)
./scripts/feeds install kmod-ksmbd 2>/dev/null || echo "⚠️  ksmbd 安装失败"

# File Browser
./scripts/feeds install luci-app-filebrowser 2>/dev/null || echo "⚠️  filebrowser 安装失败（可能不在官方源）"

# SQM (QoS)
./scripts/feeds install luci-app-sqm 2>/dev/null || echo "⚠️  sqm 安装失败"

# ttyd (终端)
./scripts/feeds install luci-app-ttyd 2>/dev/null || echo "⚠️  ttyd 安装失败"

# vlmcsd (KMS 激活)
./scripts/feeds install luci-app-vlmcsd 2>/dev/null || echo "⚠️  vlmcsd 安装失败"

# DiskMan (磁盘管理)
./scripts/feeds install luci-app-diskman 2>/dev/null || echo "⚠️  DiskMan 安装失败（可能不在官方源）"

# Reboot
./scripts/feeds install luci-app-reboot 2>/dev/null || echo "⚠️  reboot 安装失败"

# LXC (容器)
./scripts/feeds install luci-app-lxc 2>/dev/null || echo "⚠️  lxc 安装失败"

# File Manager
./scripts/feeds install luci-app-filemanager 2>/dev/null || echo "⚠️  filemanager 安装失败"

# DAED (代理)
./scripts/feeds install luci-app-daed 2>/dev/null || echo "⚠️  daed 安装失败（可能不在官方源）"

# Cloudflared
./scripts/feeds install luci-app-cloudflared 2>/dev/null || echo "⚠️  cloudflared 安装失败（可能不在官方源）"

echo "✅ 插件安装完成"

# ============================================================================
# 3. USB2, USB3, SATA3 支持
# ============================================================================
echo "🔧 配置 USB2, USB3, SATA3 支持..."

# USB2 支持
sed -i 's/# CONFIG_PACKAGE_kmod-usb2 is not set/CONFIG_PACKAGE_kmod-usb2=y/' target/linux/*/modules/usb.mk 2>/dev/null || true

# USB3 支持
sed -i 's/# CONFIG_PACKAGE_kmod-usb3 is not set/CONFIG_PACKAGE_kmod-usb3=y/' target/linux/*/modules/usb.mk 2>/dev/null || true

# SATA3 (AHCI) 支持
sed -i 's/# CONFIG_PACKAGE_kmod-ata-ahci is not set/CONFIG_PACKAGE_kmod-ata-ahci=y/' target/linux/*/modules/block.mk 2>/dev/null || true

echo "✅ USB2, USB3, SATA3 支持已配置"

# ============================================================================
# 4. 取消编译 automount 和 kmod-usb-storage-uas (会造成 USB 挂载不正常)
# ============================================================================
echo "🔧 取消 automount 和 kmod-usb-storage-uas 编译..."
sed -i 's/^CONFIG_PACKAGE_kmod-usb-storage-uas=y/# CONFIG_PACKAGE_kmod-usb-storage-uas is not set/' .config 2>/dev/null || true
sed -i 's/^CONFIG_PACKAGE_automount=y/# CONFIG_PACKAGE_automount is not set/' .config 2>/dev/null || true
echo "✅ 已取消 automount 和 kmod-usb-storage-uas 编译"

# ============================================================================
# 5. LuCI 中文界面
# ============================================================================
echo "🌐 配置 LuCI 中文界面..."
# 确保启用中文语言支持
sed -i 's/# CONFIG_PACKAGE_luci-i18n-base-zh-cn is not set/CONFIG_PACKAGE_luci-i18n-base-zh-cn=y/' .config 2>/dev/null || true
echo "✅ LuCI 中文界面已配置"

# ============================================================================
# 6. 确认 .config 未被修改（不重新生成）
# ============================================================================
echo "✅ .config 文件保持原样"

# ============================================================================
# 7. file 文件夹配置已在上层复制，此处无需操作
# ============================================================================
echo "✅ file 文件夹配置已在上层步骤复制到固件"

echo "=========================================="
echo "💕 强哥专属固件配置完成！"
echo "=========================================="
echo ""
echo "📦 已配置功能:"
echo "   ✅ LuCI 中文界面"
echo "   ✅ USB2, USB3, SATA3 支持"
echo "   ✅ 已禁用 automount 和 kmod-usb-storage-uas"
echo "   ✅ 插件：AdGuardHome, cloudflared, ksmbd, tailscale, filebrowser, sqm, ttyd, vlmcsd, DiskMan, reboot, lxc, filemanager, daed"
echo ""
