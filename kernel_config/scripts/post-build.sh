#!/bin/bash
# 后构建脚本

echo "运行后构建自定义脚本..."

# 生成构建信息
BUILD_INFO_FILE="out/build_info.txt"
echo "=== 内核构建信息 ===" > $BUILD_INFO_FILE
echo "内核版本: $(make kernelversion)" >> $BUILD_INFO_FILE
echo "构建时间: $(date)" >> $BUILD_INFO_FILE
echo "工具链: $(clang --version | head -1)" >> $BUILD_INFO_FILE
echo "架构: arm64" >> $BUILD_INFO_FILE

# 计算内核大小
KERNEL_SIZE=$(stat -c%s out/arch/arm64/boot/Image.gz 2>/dev/null || echo "N/A")
echo "内核大小: $KERNEL_SIZE 字节" >> $BUILD_INFO_FILE

# 生成模块依赖
if [ -d "out/modules" ]; then
    depmod -b out/ -a $(make kernelversion)
    echo "模块依赖已生成" >> $BUILD_INFO_FILE
fi

# 签名检查
echo "检查模块签名..." >> $BUILD_INFO_FILE
find out -name "*.ko" -exec modinfo {} \; 2>/dev/null | grep "signature" | head -3 >> $BUILD_INFO_FILE

echo "后构建脚本完成"
