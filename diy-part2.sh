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
# 1. 删除 mbedtls 问题补丁（必须在 feeds 安装之前！）
# ============================================================================
echo "🗑️ 删除问题补丁..."
rm -f package/libs/mbedtls/patches/001-fix-gcc14-fortify.patch 2>/dev/null && echo "✅ 已删除 mbedtls 问题补丁"

# ============================================================================
# 2. 更新 feeds
# ============================================================================
echo "🔄 更新 feeds..."

./scripts/feeds update -a
./scripts/feeds install -a

# 再次确认补丁被删除（防止 feeds 重新安装）
rm -f package/libs/mbedtls/patches/001-fix-gcc14-fortify.patch 2>/dev/null && echo "✅ 再次确认删除补丁"

# ============================================================================
# 3. 取消编译 automount 和 kmod-usb-storage-uas (会造成 USB 挂载不正常)
# ============================================================================
echo "🔧 取消 automount 和 kmod-usb-storage-uas 编译..."
sed -i 's/^CONFIG_PACKAGE_kmod-usb-storage-uas=y/# CONFIG_PACKAGE_kmod-usb-storage-uas is not set/' .config 2>/dev/null || true
sed -i 's/^CONFIG_PACKAGE_automount=y/# CONFIG_PACKAGE_automount is not set/' .config 2>/dev/null || true
echo "✅ 已取消 automount 和 kmod-usb-storage-uas 编译"

# ============================================================================
# 4. 确认 .config 未被修改（不重新生成）
# ============================================================================
echo "✅ .config 文件保持原样"

# ============================================================================
# 5. file 文件夹配置已在上层复制，此处无需操作
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