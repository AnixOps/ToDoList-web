# 分支管理策略 (Branch Management Strategy)

## 📋 分支概述

本项目采用多分支开发模式，每个分支都有特定的用途和管理规则。

## 🌿 分支结构

### 1. `main` 分支 (主分支)
- **用途**: 生产环境稳定代码
- **特点**: 相对稳定，但通常落后于dev，领先于release版本
- **规则**: 
  - 只接受来自dev分支经过测试的PR
  - 禁止直接推送
  - 所有合并必须经过代码审查
  - 保护分支设置

### 2. `dev` 分支 (开发分支)
- **用途**: 日常开发和功能集成
- **特点**: 拥有最宽松的版本管理，允许存在重大BUG，最新的版本
- **规则**:
  - 新功能开发的集成点
  - 可以包含未完全测试的功能
  - 定期合并到main分支
  - 自动化测试和持续集成

### 3. `deploy` 分支 (部署分支) 🆕 已优化
- **用途**: 专门用于Cloudflare Workers前端部署
- **特点**: 
  - **只包含前端代码**
  - **已移除后端代码和Docker相关内容**
  - 针对Cloudflare Workers优化
- **规则**:
  - 从main分支定期同步前端变更
  - 专注于前端部署配置
  - 独立的部署流水线

### 4. `release/x.x.x` 分支 (发布分支)
- **用途**: 正式发布版本
- **特点**: 通过协商或拥有者决定的稳定发行版，通常由main版本merge得来
- **规则**:
  - 从main分支创建
  - 只允许关键bug修复
  - 发布后打标签
  - 保护分支，防止意外修改

## 🔄 工作流程

### 日常开发流程
```bash
# 1. 从dev分支创建功能分支
git checkout dev
git pull origin dev
git checkout -b feature/your-feature-name

# 2. 开发完成后合并到dev
git checkout dev
git merge feature/your-feature-name
git push origin dev

# 3. dev测试稳定后合并到main
git checkout main
git merge dev
git push origin main
```

### 发布流程
```bash
# 1. 从main创建release分支
git checkout main
git pull origin main
git checkout -b release/v1.0.0

# 2. 进行发布准备和bug修复
# ... 修复关键问题 ...

# 3. 打标签并推送
git tag v1.0.0
git push origin release/v1.0.0
git push origin v1.0.0
```

### Cloudflare Workers部署流程
```bash
# 1. 切换到deploy分支
git checkout deploy
git pull origin deploy

# 2. 如果需要同步main的前端变更
git merge main --strategy-option=subtree=frontend

# 3. 部署到Cloudflare Workers
cd frontend
npm install
npm run build
npm run deploy
```

## 🛡️ 分支保护规则

### main分支保护
- 启用分支保护
- 要求PR审查
- 要求状态检查通过
- 不允许强制推送

### release分支保护
- 发布后设置为只读
- 只允许关键bug修复的PR
- 需要维护者审批

## 📊 分支状态监控

定期检查各分支状态：
```bash
# 查看所有分支
git branch -a

# 查看分支提交历史
git log --oneline --graph --all -10

# 查看分支间差异
git log main..dev --oneline
```

## 🚨 注意事项

1. **deploy分支特殊性**: 
   - 已专门优化为纯前端部署分支
   - 不包含后端代码和Docker配置
   - 专用于Cloudflare Workers部署

2. **合并策略**:
   - dev → main: 使用merge commit保持历史
   - main → release: 使用merge commit
   - 避免使用rebase改写公共历史

3. **命名规范**:
   - 功能分支: `feature/功能名称`
   - 修复分支: `fix/问题描述`
   - 发布分支: `release/v版本号`

## 🔧 分支维护

### 定期清理
- 删除已合并的功能分支
- 清理过期的远程跟踪分支
```bash
git branch -d feature/completed-feature
git remote prune origin
```

### 同步更新
- 定期将main的前端变更同步到deploy分支
- 保持dev分支与最新开发进度一致

---

**最后更新**: 2024年9月23日
**维护者**: zdwtest