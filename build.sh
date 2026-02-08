#!/bin/bash
set -e

OUTPUT_DIR="dist"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "🔨 构建 linux/amd64 ..."
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o "${OUTPUT_DIR}/proxy-server-amd64" .

echo "🔨 构建 linux/arm64 ..."
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o "${OUTPUT_DIR}/proxy-server-arm64" .

# 复制 .env 示例到 dist
cp .env "${OUTPUT_DIR}/.env.example"

echo ""
echo "✅ 构建完成！输出目录: ${OUTPUT_DIR}/"
ls -lh "${OUTPUT_DIR}/"
