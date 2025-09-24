# 🚀 分支管理快速参考

## 📌 分支用途一览表

| 分支 | 用途 | 特点 | 更新策略 |
|------|------|------|----------|
| `main` | 生产稳定代码 | 相对稳定，落后于dev，领先于release | 从dev合并 |
| `dev` | 日常开发集成 | 最新功能，允许BUG，宽松管理 | 直接开发 |
| `deploy` | Cloudflare Workers部署 | **纯前端代码** 🆕 | 从main同步前端 |
| `release/x.x.x` | 正式发布版本 | 稳定发行，保护分支 | 从main创建 |

## ⚡ 常用命令

### 使用分支管理工具 (推荐)
```bash
./branch-manager.sh status              # 查看所有分支状态
./branch-manager.sh sync-deploy         # 同步前端到deploy分支
./branch-manager.sh create-feature auth # 创建功能分支
./branch-manager.sh create-release v1.1.0 # 创建发布分支
./branch-manager.sh deploy-cf           # 部署到Cloudflare Workers
./branch-manager.sh cleanup             # 清理已合并分支
```

### 手动操作
```bash
# 查看分支状态
git branch -a
git log --oneline --graph --all -10

# 切换分支
git checkout main/dev/deploy

# 创建功能分支 (从dev)
git checkout dev
git checkout -b feature/your-feature

# 创建发布分支 (从main)  
git checkout main
git checkout -b release/v1.0.0
```

## 🔄 典型工作流

### 1. 日常功能开发
```
dev → feature/xxx → dev → main
```

### 2. 发布流程
```
main → release/vx.x.x → tag vx.x.x
```

### 3. Cloudflare Workers部署
```
main (frontend changes) → deploy → Cloudflare Workers
```

## 🛡️ 分支保护

- **main**: 保护分支，需要PR审查
- **release/x.x.x**: 发布后只读保护
- **deploy**: 专用部署分支，定期同步

## 📍 重要提醒

1. **deploy分支已优化** ✨
   - 移除了所有后端代码和Docker配置
   - 专门用于Cloudflare Workers前端部署
   - 保持轻量化和部署专用

2. **合并策略**
   - 使用merge commit保持历史
   - 避免rebase公共分支
   - dev定期合并到main

3. **命名规范**
   - 功能: `feature/功能名`
   - 修复: `fix/问题描述`  
   - 发布: `release/v版本号`

---
💡 **提示**: 使用 `./branch-manager.sh help` 查看完整工具说明