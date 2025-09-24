package config

import (
	"fmt"
	"io/ioutil"

	"gopkg.in/yaml.v2"
)

// Config 应用配置结构 / Application configuration structure
type Config struct {
	Server   ServerConfig   `yaml:"server"`
	Database DatabaseConfig `yaml:"database"`
	JWT      JWTConfig      `yaml:"jwt"`
	Features FeatureConfig  `yaml:"features"`
}

// ServerConfig 服务器配置 / Server configuration
type ServerConfig struct {
	Port string `yaml:"port"`
	Mode string `yaml:"mode"` // debug, release
}

// DatabaseConfig 数据库配置 / Database configuration
type DatabaseConfig struct {
	Type     string         `yaml:"type"` // sqlite, postgres
	SQLite   SQLiteConfig   `yaml:"sqlite"`
	Postgres PostgresConfig `yaml:"postgres"`
}

// SQLiteConfig SQLite配置
type SQLiteConfig struct {
	Path string `yaml:"path"`
}

// PostgresConfig PostgreSQL配置
type PostgresConfig struct {
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	Username string `yaml:"username"`
	Password string `yaml:"password"`
	Database string `yaml:"database"`
	SSLMode  string `yaml:"sslmode"`
}

// JWTConfig JWT配置
type JWTConfig struct {
	Secret    string `yaml:"secret"`
	ExpiresIn int    `yaml:"expires_in"` // 小时
}

// FeatureConfig 功能特性配置
type FeatureConfig struct {
	EnableRegistration bool `yaml:"enable_registration"`
}

// LoadConfig 从文件加载配置
func LoadConfig(path string) (*Config, error) {
	data, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("读取配置文件失败: %w", err)
	}

	var config Config
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		return nil, fmt.Errorf("解析配置文件失败: %w", err)
	}

	// 设置默认值
	if config.Server.Port == "" {
		config.Server.Port = ":8080"
	}
	if config.Server.Mode == "" {
		config.Server.Mode = "debug"
	}
	if config.Database.Type == "" {
		config.Database.Type = "sqlite"
	}
	if config.Database.SQLite.Path == "" {
		config.Database.SQLite.Path = "./data/todolist.db"
	}
	if config.JWT.Secret == "" {
		config.JWT.Secret = "your-secret-key-change-this-in-production"
	}
	if config.JWT.ExpiresIn == 0 {
		config.JWT.ExpiresIn = 24 // 24小时
	}

	return &config, nil
}
