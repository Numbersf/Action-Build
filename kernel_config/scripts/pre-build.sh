#!/bin/bash
# 预构建脚本

echo "运行预构建自定义脚本..."

# 设置内核版本字符串
export KBUILD_BUILD_VERSION="1"
export KBUILD_BUILD_USER="github-actions"
export KBUILD_BUILD_HOST="github.com"

# 修改Makefile中的版本信息
sed -i "s/EXTRAVERSION =/EXTRAVERSION = -custom-$(date +%Y%m%d)/" Makefile

# 创建版本文件
echo "# Custom Kernel Build" > version
echo "Kernel: $(make kernelversion)" >> version
echo "Build Date: $(date)" >> version
echo "Build User: $KBUILD_BUILD_USER" >> version

# 应用额外配置
if [ -f "../../kernel_config/extra_config" ]; then
    echo "应用额外配置..."
    cat ../../kernel_config/extra_config >> .config
fi

# 检查依赖
echo "检查工具链..."
which ${CROSS_COMPILE}gcc
which clang

echo "预构建脚本完成"
