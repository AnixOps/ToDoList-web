# ToDoList - 待办事项管理系统

[English](#english) | [中文](#chinese)

---

<a id="english"></a>
## English

# ToDoList - Task Management System

A full-featured todo list management system that supports both online and offline modes, built with Go backend and Vue 3 frontend.

### 🚀 Core Features
- **Dual Mode Operation**: Online mode (requires login) and offline mode (local storage)
- **Two-Level Task Management**: Major events -> Sub-tasks hierarchical structure
- **User Authentication**: Registration/Login functionality, registration can be disabled via configuration
- **Multi-Database Support**: SQLite (default) and PostgreSQL
- **Data Synchronization**: Import/Export data between online/offline modes

### 📋 Task Management
- Create, edit, delete major events
- Add multiple sub-tasks for each major event
- Task status management (pending, completed, cancelled)
- Priority settings (high, medium, low)
- Due date settings
- Task progress statistics

### 💾 Data Storage
- **Online Mode**: Data stored in server database
- **Offline Mode**: Data stored in browser IndexedDB
- Data import/export functionality
- Cross-device data synchronization

### 🔧 Technical Features
- Responsive design, mobile-friendly
- Containerized deployment (Docker)
- Configurable feature toggles
- RESTful API design
- JWT authentication

## Tech Stack

### Backend
- **Language**: Go 1.21+
- **Framework**: Gin
- **Database**: SQLite / PostgreSQL
- **ORM**: GORM
- **Authentication**: JWT
- **Configuration**: YAML

### Frontend
- **Framework**: Vue 3
- **Build Tool**: Vite
- **UI Library**: Element Plus
- **State Management**: Pinia
- **Router**: Vue Router
- **Offline Storage**: Dexie (IndexedDB)
- **HTTP Client**: Axios

## Quick Start

### Using Docker (Recommended)

1. **Clone the project**
```bash
git clone <repository-url>
cd ToDoList-web
```

2. **Using SQLite (Default)**
```bash
# Start the application
docker-compose up -d

# Access the application
http://localhost:8080
```

3. **Using PostgreSQL**
```bash
# Start application with PostgreSQL
docker-compose --profile postgres up -d

# Modify config file backend/config/config.yaml
# Change database.type to "postgres"

# Restart application
docker-compose restart todolist-app
```

4. **Using Nginx Reverse Proxy**
```bash
# Start complete service stack
docker-compose --profile postgres --profile nginx up -d

# Access application
http://localhost
```

### Local Development

#### Backend Development

1. **Install dependencies**
```bash
cd backend
go mod download
```

2. **Configure database**
Edit `backend/config/config.yaml`:
```yaml
database:
  type: "sqlite"  # or "postgres"
  sqlite:
    path: "./data/todolist.db"
```

3. **Run backend**
```bash
go run main.go
```

Backend service will start at http://localhost:8080

#### Frontend Development

1. **Install dependencies**
```bash
cd frontend
npm install
```

2. **Start development server**
```bash
npm run dev
```

Frontend service will start at http://localhost:3000

## Configuration

### Server Configuration
```yaml
server:
  port: ":8080"
  mode: "debug"  # debug or release
```

### Database Configuration
```yaml
database:
  type: "sqlite"  # sqlite or postgres
  sqlite:
    path: "./data/todolist.db"
  postgres:
    host: "localhost"
    port: 5432
    username: "todolist"
    password: "password"
    database: "todolist"
    sslmode: "disable"
```

### JWT Configuration
```yaml
jwt:
  secret: "your-jwt-secret-key"
  expires_in: 24  # hours
```

### Feature Configuration
```yaml
features:
  enable_registration: true  # Enable registration functionality
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration (configurable)

### Events
- `GET /api/v1/events` - Get all user events
- `POST /api/v1/events` - Create new event
- `PUT /api/v1/events/:id` - Update event
- `DELETE /api/v1/events/:id` - Delete event

### Tasks
- `GET /api/v1/events/:eventId/tasks` - Get all tasks for an event
- `POST /api/v1/events/:eventId/tasks` - Create new task
- `PUT /api/v1/tasks/:id` - Update task
- `DELETE /api/v1/tasks/:id` - Delete task

## Deployment Options

### 1. Production Deployment (Recommended)
```bash
# Production deployment with all services
docker compose -f docker-compose.prod.yml up -d
```

### 2. Binary Deployment
Download pre-built binaries from [Releases](https://github.com/zdwtest/ToDoList-web/releases):

```bash
# Linux
wget https://github.com/zdwtest/ToDoList-web/releases/download/v1.0.0/todolist-backend-v1.0.0-linux-amd64.tar.gz
tar -xzf todolist-backend-v1.0.0-linux-amd64.tar.gz
cd linux-amd64
./start.sh

# Windows
# Download todolist-backend-v1.0.0-windows-amd64.zip
# Extract and run start.bat
```

### 3. Manual Deployment
```bash
# Build image
docker build -t todolist .

# Run container
docker run -d -p 8080:8080 \
  -v todolist_data:/app/data \
  todolist
```

### 4. Manual Deployment
```bash
# Build backend
cd backend && go build -o todolist

# Build frontend
cd frontend && npm run build

# Configure Nginx or other web server
# Run backend service
./todolist
```

## Usage

### Offline Mode
1. Access the application directly, no login required
2. Data stored locally in browser
3. Support data export for backup
4. Can switch to online mode anytime

### Online Mode
1. Register an account or login with existing account
2. Data stored on server
3. Support multi-device synchronization
4. Can export data locally

### Data Management
- **Export**: Export data as JSON file
- **Import**: Import data from JSON file
- **Clear**: Clear all local or online data

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Issues and Pull Requests are welcome!

---

<a id="chinese"></a>
## 中文

# ToDoList - 待办事项管理系统

一个功能完整的待办事项管理系统，支持在线和离线两种模式，使用Go语言作为后端，Vue 3作为前端。

### 🚀 核心功能
- **双模式运行**: 支持在线模式（需登录）和离线模式（本地存储）
- **两级任务管理**: 大事件 -> 小任务的层级结构
- **用户认证**: 注册/登录功能，可通过配置关闭注册
- **多数据库支持**: SQLite（默认）和PostgreSQL
- **数据同步**: 在线/离线数据导入导出

### 📋 任务管理
- 创建、编辑、删除大事件
- 为每个大事件添加多个子任务
- 任务状态管理（待完成、已完成、已取消）
- 优先级设置（高、中、低）
- 截止日期设置
- 任务进度统计

### 💾 数据存储
- **在线模式**: 数据存储在服务器数据库中
- **离线模式**: 数据存储在浏览器IndexedDB中
- 数据导入/导出功能
- 跨设备数据同步

### 🔧 技术特性
- 响应式设计，支持移动端
- 容器化部署（Docker）
- 可配置的功能开关
- RESTful API设计
- JWT身份验证

## 技术栈

### 后端
- **语言**: Go 1.21+
- **框架**: Gin
- **数据库**: SQLite / PostgreSQL
- **ORM**: GORM
- **认证**: JWT
- **配置**: YAML

### 前端
- **框架**: Vue 3
- **构建工具**: Vite
- **UI库**: Element Plus
- **状态管理**: Pinia
- **路由**: Vue Router
- **离线存储**: Dexie (IndexedDB)
- **HTTP客户端**: Axios

## 快速开始

### 使用Docker（推荐）

1. **克隆项目**
```bash
git clone <repository-url>
cd ToDoList-web
```

2. **使用SQLite（默认）**
```bash
# 启动应用
docker-compose up -d

# 访问应用
http://localhost:8080
```

3. **使用PostgreSQL**
```bash
# 启动应用和PostgreSQL
docker-compose --profile postgres up -d

# 修改配置文件 backend/config/config.yaml
# 将 database.type 改为 "postgres"

# 重启应用
docker-compose restart todolist-app
```

4. **使用Nginx反向代理**
```bash
# 启动完整服务栈
docker-compose --profile postgres --profile nginx up -d

# 访问应用
http://localhost
```

### 本地开发

#### 后端开发

1. **安装依赖**
```bash
cd backend
go mod download
```

2. **配置数据库**
编辑 `backend/config/config.yaml`:
```yaml
database:
  type: "sqlite"  # 或 "postgres"
  sqlite:
    path: "./data/todolist.db"
```

3. **运行后端**
```bash
go run main.go
```

后端服务将在 http://localhost:8080 启动

#### 前端开发

1. **安装依赖**
```bash
cd frontend
npm install
```

2. **启动开发服务器**
```bash
npm run dev
```

前端服务将在 http://localhost:3000 启动

## 配置说明

### 服务器配置
```yaml
server:
  port: ":8080"
  mode: "debug"  # debug 或 release
```

### 数据库配置
```yaml
database:
  type: "sqlite"  # sqlite 或 postgres
  sqlite:
    path: "./data/todolist.db"
  postgres:
    host: "localhost"
    port: 5432
    username: "todolist"
    password: "password"
    database: "todolist"
    sslmode: "disable"
```

### JWT配置
```yaml
jwt:
  secret: "your-jwt-secret-key"
  expires_in: 24  # 小时
```

### 功能配置
```yaml
features:
  enable_registration: true  # 是否启用注册功能
```

## API接口

### 认证接口
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/register` - 用户注册（可配置关闭）

### 事件接口
- `GET /api/v1/events` - 获取用户的所有事件
- `POST /api/v1/events` - 创建新事件
- `PUT /api/v1/events/:id` - 更新事件
- `DELETE /api/v1/events/:id` - 删除事件

### 任务接口
- `GET /api/v1/events/:eventId/tasks` - 获取事件的所有任务
- `POST /api/v1/events/:eventId/tasks` - 创建新任务
- `PUT /api/v1/tasks/:id` - 更新任务
- `DELETE /api/v1/tasks/:id` - 删除任务

## 部署方式

### 1. 生产环境部署（推荐）
```bash
# 生产环境部署所有服务
docker compose -f docker-compose.prod.yml up -d
```

### 2. 二进制部署
从 [Releases](https://github.com/zdwtest/ToDoList-web/releases) 下载预构建的二进制文件：

```bash
# Linux
wget https://github.com/zdwtest/ToDoList-web/releases/download/v1.0.0/todolist-backend-v1.0.0-linux-amd64.tar.gz
tar -xzf todolist-backend-v1.0.0-linux-amd64.tar.gz
cd linux-amd64
./start.sh

# Windows
# 下载 todolist-backend-v1.0.0-windows-amd64.zip
# 解压并运行 start.bat
```

### 3. 手动部署
```bash
# 构建后端
cd backend && go build -o todolist

# 构建前端
cd frontend && npm run build

# 配置Nginx或其他Web服务器
# 运行后端服务
./todolist
```

## 使用说明

### 离线模式
1. 直接访问应用，无需登录
2. 数据存储在浏览器本地
3. 支持数据导出备份
4. 可随时切换到在线模式

### 在线模式
1. 注册账号或登录现有账号
2. 数据存储在服务器
3. 支持多设备同步
4. 可导出数据到本地

### 数据管理
- **导出**: 将数据导出为JSON文件
- **导入**: 从JSON文件导入数据
- **清空**: 清空所有本地或在线数据

## 开发指南

### 项目结构
```
ToDoList-web/
├── backend/              # Go后端
│   ├── config/          # 配置管理
│   ├── models/          # 数据模型
│   ├── handlers/        # HTTP处理器
│   ├── middleware/      # 中间件
│   ├── database/        # 数据库操作
│   └── utils/           # 工具函数
├── frontend/            # Vue前端
│   ├── src/
│   │   ├── api/        # API接口
│   │   ├── components/ # Vue组件
│   │   ├── stores/     # Pinia状态管理
│   │   ├── utils/      # 工具函数
│   │   └── views/      # 页面组件
│   └── public/         # 静态资源
├── Dockerfile          # Docker构建文件
├── docker-compose.yml  # Docker编排文件
└── nginx.conf          # Nginx配置文件
```

### 开发环境设置
1. 安装Go 1.21+和Node.js 18+
2. 配置开发数据库
3. 启动后端和前端开发服务器
4. 使用热重载进行开发

## 版本管理和发布

### 发布流程
本项目使用自动化工作流进行版本发布：

1. **创建版本标签**
```bash
# 创建版本标签
git tag v1.0.0
git push origin v1.0.0
```

2. **自动构建发布**
   - GitHub Actions 自动检测 `v*.*.*` 格式的标签
   - 构建 Linux x64 和 Windows x64 二进制文件
   - 构建并推送 Docker 镜像
   - 创建 GitHub Release 并上传构建产物

3. **本地测试构建**
```bash
# 测试发布构建
./test-release.sh v1.0.0

# 测试构建包含 Docker 镜像
./test-release.sh v1.0.0 --docker
```

### 版本信息
```bash
# 查看后端版本
./todolist-backend -version

# API 查看版本
curl http://localhost:8080/api/v1/version
```

## 许可证

本项目采用MIT许可证，详见LICENSE文件。

## 贡献

欢迎提交Issue和Pull Request！

## 更新日志

详见 [CHANGELOG.md](CHANGELOG.md)

---

## 🚀 项目状态

**当前状态**: ✅ 开发完成，服务运行中

- **后端服务**: http://localhost:8080 (Go + Gin)
- **前端服务**: http://localhost:3000 (Vue 3 + Vite)
- **健康检查**: http://localhost:8080/api/v1/health

### 快速体验
1. 访问 http://localhost:3000
2. 选择"使用离线模式"立即开始
3. 或注册账号体验在线模式

详细状态请查看 [PROJECT_STATUS.md](./PROJECT_STATUS.md)