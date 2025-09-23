# ToDoList-web Frontend (Cloudflare Workers)

这是ToDoList-web项目的前端部署分支，专门用于部署到Cloudflare Workers。

## 🚀 快速部署

```bash
cd frontend
npm install
npm run build
npm run deploy
```

## 📖 详细部署指南

请查看 [CLOUDFLARE_DEPLOYMENT.md](./CLOUDFLARE_DEPLOYMENT.md) 获取完整的部署说明。

## 🔗 相关链接

- [主项目仓库](https://github.com/zdwtest/ToDoList-web)
- [后端部署说明](https://github.com/zdwtest/ToDoList-web/blob/main/README.md)

## 📝 分支说明

此分支(`deploy`)专门用于Cloudflare Workers部署：
- 只包含前端代码和相关配置
- 不包含后端代码和Docker配置
- 定期从主分支同步前端变更
