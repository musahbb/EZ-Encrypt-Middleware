# API Proxy Server

一个基于Go语言开发的API代理服务器，支持路径加密解密、订阅路径转发、CORS跨域处理、支付回调免验证等功能。

部署教程 👉 [查看](https://github.com/codeman857/EZ-Encrypt-Middleware/wiki/aapanel-%E9%83%A8%E7%BD%B2%E6%95%99%E7%A8%8B)

## 功能特性

1. **路径加密解密**：对请求路径进行AES解密后再转发到后端API
2. **订阅路径转发**：自动识别订阅请求，去掉标记前缀后直接转发（不拼 API 前缀）
3. **API 前缀可配置**：支持不同面板版本的 API 路径前缀（`/api/v1`、`/api/v2` 等）
4. **CORS跨域支持**：支持通配符和特定域名的跨域配置
5. **支付回调免验证**：特定路径不进行加密解密直接转发
6. **请求超时控制**：可配置的请求超时时间
7. **日志记录**：可开关的请求日志记录功能
8. **环境配置**：通过.env文件进行配置管理

## 项目结构

```
.
├── main.go                 # 主程序入口
├── build.sh                # 一键双架构打包脚本
├── go.mod                  # Go模块定义
├── go.sum                  # Go模块校验和
├── .env                    # 环境配置文件
├── README.md               # 项目说明文档
├── config/
│   └── config.go           # 配置管理
├── proxy/
│   └── proxy.go            # 代理处理逻辑
└── utils/
    └── encryption.go       # 加密解密工具
```

## 配置说明

### 环境变量配置 (.env文件)

```bash
# 1. 基础服务器设置
PORT=3000                                  # 服务器监听端口
BACKEND_API_URL=https://example.com        # 后端真实 API 根地址（无尾斜杠）
PATH_PREFIX=/ez/ez                         # 路径前缀，为空则处理所有路径

# API 路径前缀，解密后普通请求会拼上此前缀转发
API_PREFIX=/api/v1

# 订阅请求标记前缀，与客户端 app_config.json 中的 subscriptionPrefix 保持一致
SUBSCRIPTION_PREFIX=/sub

# 2. CORS / 安全设置
CORS_ORIGIN=*                              # 允许的 CORS 源；* 表示全部
ALLOWED_ORIGINS=*                          # 请求来源白名单，逗号分隔或 * 通配
REQUEST_TIMEOUT=30000                      # 请求超时(ms)
ENABLE_LOGGING=false                       # 是否输出请求日志
DEBUG_MODE=false                           # 是否输出调试日志

# 3. 支付回调免验证路径（多条用英文逗号分隔）
ALLOWED_PAYMENT_NOTIFY_PATHS=

# 4. AES 加解密配置（16位16进制字符串，须与客户端一致）
AES_KEY=4c6f8e5f9467dc71
```

### 配置项详解

| 配置项 | 默认值 | 说明 |
|---|---|---|
| `PORT` | `3000` | 服务器监听端口 |
| `BACKEND_API_URL` | — (必填) | 后端 API 根地址，不含 `/api/v1` |
| `PATH_PREFIX` | 空 | 路径前缀，为空则处理所有路径 |
| `API_PREFIX` | `/api/v1` | 普通 API 请求拼接的前缀，按面板版本修改 |
| `SUBSCRIPTION_PREFIX` | `/sub` | 订阅请求标记前缀，与客户端保持一致 |
| `CORS_ORIGIN` | `*` | CORS 允许来源 |
| `ALLOWED_ORIGINS` | `*` | 请求来源白名单，逗号分隔 |
| `REQUEST_TIMEOUT` | `30000` | 请求超时(ms) |
| `ENABLE_LOGGING` | `false` | 是否启用请求日志 |
| `DEBUG_MODE` | `false` | 是否启用调试模式 |
| `ALLOWED_PAYMENT_NOTIFY_PATHS` | 空 | 支付回调免验证路径，逗号分隔 |
| `AES_KEY` | — (必填) | 16位16进制 AES 密钥 |

## 运行方式

### 一键打包

```bash
./build.sh
```

输出到 `dist/` 目录：
- `proxy-server-amd64` — x86_64
- `proxy-server-arm64` — ARM64
- `.env.example` — 配置模板

### 手动编译

```bash
# arm64
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -o proxy-server .

# amd64
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o proxy-server .

# 运行
./proxy-server
```

### 开发运行

```bash
go run main.go
```

## 请求转发逻辑

### 普通 API 请求
```
客户端: /user/info → 加密
中间件: 解密 → /user/info → 无订阅前缀 → 拼 API_PREFIX → /api/v1/user/info → 转发后端 ✅
```

### 支付回调
```
第三方: /api/v1/guest/payment/notify/EPay/12345 → 直接转发后端（免加密） ✅
```

## 依赖库

- [Gin](https://github.com/gin-gonic/gin) — Web框架
- [gin-contrib/cors](https://github.com/gin-contrib/cors) — CORS中间件
- [joho/godotenv](https://github.com/joho/godotenv) — 环境变量加载
- [deatil/go-cryptobin](https://github.com/deatil/go-cryptobin) — 加密解密库

## 部署建议

1. 生产环境将 `DEBUG_MODE` 设为 `false`
2. 根据实际需求配置 `REQUEST_TIMEOUT`
3. 合理配置 CORS 策略，避免安全风险
4. 定期更新 `AES_KEY` 提高安全性
5. 确保 `SUBSCRIPTION_PREFIX` 与客户端 `app_config.json` 中的 `subscriptionPrefix` 一致
