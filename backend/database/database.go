package database

import (
	"fmt"
	"os"
	"path/filepath"

	"todolist-backend/config"
	"todolist-backend/models"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
	_ "github.com/jinzhu/gorm/dialects/sqlite"
)

// InitDB 初始化数据库连接
func InitDB(cfg *config.Config) (*gorm.DB, error) {
	var db *gorm.DB
	var err error

	switch cfg.Database.Type {
	case "sqlite":
		db, err = initSQLite(cfg.Database.SQLite)
	case "postgres":
		db, err = initPostgres(cfg.Database.Postgres)
	default:
		return nil, fmt.Errorf("不支持的数据库类型: %s", cfg.Database.Type)
	}

	if err != nil {
		return nil, err
	}

	// 设置连接池
	db.DB().SetMaxIdleConns(10)
	db.DB().SetMaxOpenConns(100)

	// 启用日志（仅在debug模式下）
	if cfg.Server.Mode == "debug" {
		db.LogMode(true)
	}

	return db, nil
}

// initSQLite 初始化SQLite数据库
func initSQLite(cfg config.SQLiteConfig) (*gorm.DB, error) {
	// 确保数据目录存在
	dir := filepath.Dir(cfg.Path)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return nil, fmt.Errorf("创建数据目录失败: %w", err)
	}

	db, err := gorm.Open("sqlite3", cfg.Path)
	if err != nil {
		return nil, fmt.Errorf("连接SQLite数据库失败: %w", err)
	}

	return db, nil
}

// initPostgres 初始化PostgreSQL数据库
func initPostgres(cfg config.PostgresConfig) (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
		cfg.Host, cfg.Port, cfg.Username, cfg.Password, cfg.Database, cfg.SSLMode)

	db, err := gorm.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("连接PostgreSQL数据库失败: %w", err)
	}

	return db, nil
}

// Migrate 执行数据库迁移
func Migrate(db *gorm.DB) error {
	// 自动迁移模型
	err := db.AutoMigrate(
		&models.User{},
		&models.Event{},
		&models.Task{},
	).Error

	if err != nil {
		return fmt.Errorf("数据库迁移失败: %w", err)
	}

	return nil
}