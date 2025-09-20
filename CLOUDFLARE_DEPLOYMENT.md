# Cloudflare Pages 部署指南

这个版本的 ToDoList-web 前端已经配置为可以部署到 Cloudflare Pages，后端需要单独部署。

## 🚀 快速开始

```bash
cd frontend
npm install
# 编辑 .env.production 设置您的后端 API 地址
npm run build
npm run deploy  # 或使用 Cloudflare Dashboard
```

## 前端部署步骤

### 1. 安装依赖
```bash
cd frontend
npm install
```

**注意**: 如果遇到 package-lock.json 不同步的错误，请确保运行 `npm install` 而不是 `npm ci`。

### 2. 配置后端 API 地址
在 `frontend/.env.production` 文件中，将 `VITE_API_BASE_URL` 替换为您的实际后端部署地址：
```
VITE_API_BASE_URL=https://your-backend-domain.com/api/v1
```

### 3. 构建项目
```bash
npm run build
```

### 4. 部署到 Cloudflare Pages

#### 方法一：通过 Wrangler CLI
```bash
# 安装最新版本的 wrangler（如果还没有安装）
npm install -g wrangler@latest

# 登录 Cloudflare
wrangler login

# 部署
npm run deploy
```

#### 方法二：通过 Cloudflare Dashboard
1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 进入 Pages 页面
3. 点击 "Create a project"
4. 连接到您的 Git 仓库
5. 设置构建配置：
   - 构建命令：`npm install && npm run build`
   - 构建输出目录：`dist`
   - 根目录：`frontend`
   - Node.js 版本：`18` 或更高版本
6. 添加环境变量：
   - `VITE_API_BASE_URL`: 您的后端 API 地址

## 后端部署

后端仍然是 Go 应用，可以部署到任何支持 Go 的平台：

### 推荐部署平台：
1. **Railway**: 简单易用，支持 Go
2. **Render**: 免费套餐，自动部署
3. **Heroku**: 成熟的平台服务
4. **VPS**: 如 DigitalOcean, Linode 等
5. **云服务器**: 如 AWS EC2, Google Cloud Compute Engine 等

### 后端部署要点：
1. 确保开启 CORS 支持前端域名
2. 配置正确的数据库连接
3. 设置正确的环境变量
4. 确保端口配置正确

## 环境变量说明

### 前端环境变量
- `VITE_API_BASE_URL`: 后端 API 的完整地址，包括协议和端口

### 后端环境变量（参考）
根据您选择的部署平台，可能需要配置：
- `PORT`: 服务端口
- `DATABASE_URL`: 数据库连接地址
- `JWT_SECRET`: JWT 密钥
- `GIN_MODE`: Gin 框架模式（release/debug）

## 域名和 SSL

Cloudflare Pages 会自动为您提供：
- 免费的 SSL 证书
- 自定义域名支持
- CDN 加速
- DDoS 保护

## 故障排除

### 1. Wrangler 版本问题
- 如果遇到 "Workers-specific command in a Pages project" 错误，确保使用 `wrangler pages deploy` 命令
- 如果 wrangler 版本过旧，运行 `npm install -g wrangler@latest` 更新到最新版本
- 推荐使用 `npx wrangler` 来确保使用项目本地的 wrangler 版本

### 2. API 连接问题
- 检查 `.env.production` 中的 API 地址是否正确
- 确保后端已正确部署并可访问
- 检查后端的 CORS 配置

### 3. 构建失败
- 确保所有依赖都已正确安装
- 检查 Node.js 版本兼容性
- 查看构建日志获取详细错误信息

### 4. 部署后页面空白
- 检查控制台是否有 JavaScript 错误
- 确认构建产物在 `dist` 目录中
- 检查路由配置是否正确

## 更新部署

每次更新代码后：
1. 更新 `.env.production` 中的配置（如有必要）
2. 运行 `npm run build` 重新构建
3. 运行 `npm run deploy` 重新部署

或者如果使用 Git 集成，直接推送到连接的分支即可自动部署。