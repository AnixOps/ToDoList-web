# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Automated release workflow for version tags
- Multi-platform Docker images (linux/amd64, linux/arm64)
- Binary releases for Linux x64 and Windows x64

### Changed
- Cleaned up development files, keeping only production configuration
- Simplified deployment options in documentation

### Fixed
- Frontend API baseURL configuration for production builds
- Nginx proxy configuration for backend services

## [v0.1.0] - 2025-09-21

### Added
- Complete todo list management system
- User authentication (login/register)
- Dual mode operation (online/offline)
- Two-level task management (events -> tasks)
- Multiple database support (SQLite/PostgreSQL)
- Docker containerization
- Vue 3 frontend with Element Plus
- Go backend with Gin framework
- Data import/export functionality
- Responsive design for mobile devices

### Features
- **Backend**: RESTful API, JWT authentication, GORM ORM
- **Frontend**: Vue 3, Pinia state management, IndexedDB for offline storage
- **Deployment**: Docker Compose, multi-environment support
- **Database**: SQLite (default), PostgreSQL optional

[v0.1]: https://github.com/AnixOps/ToDoList-web/releases/tag/v0.1.0

## [v0.1.1] - 2025-09-23

### Added / 新增功能
- Docker image published to Docker Hub (docker.io) / 在 Docker Hub (docker.io) 上发布了 Docker 镜像
- Internationalization (i18n) support / 国际化 (i18n) 支持
- Automated Docker image build and push workflow / 自动化 Docker 镜像构建和推送工作流
- Automated release workflow for GitHub releases / 自动化 GitHub 版本发布工作流
- Multi-platform Docker images support (linux/amd64, linux/arm64) / 多平台 Docker 镜像支持 (linux/amd64, linux/arm64)

### Improved / 改进
- Enhanced CI/CD pipeline automation / 增强的 CI/CD 流水线自动化
- Streamlined deployment process / 简化的部署流程

[v0.1.1]: https://github.com/AnixOps/ToDoList-web/releases/tag/v0.1.1

