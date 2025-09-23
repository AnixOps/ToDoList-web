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

## [v0.1] - 2024-09-23

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

[Unreleased]: https://github.com/zdwtest/ToDoList-web/compare/v0.1...HEAD
[v0.1]: https://github.com/zdwtest/ToDoList-web/releases/tag/v0.1