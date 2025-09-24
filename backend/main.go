package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	"todolist-backend/config"
	"todolist-backend/database"
	"todolist-backend/handlers"
	"todolist-backend/middleware"

	"github.com/gin-gonic/gin"
)

// 版本信息，构建时通过 -ldflags 注入 / Version information, injected via -ldflags during build
var (
	version = "dev"
	commit  = "unknown"
	date    = "unknown"
)

func main() {
	// 处理版本参数 / Handle version parameter
	var showVersion = flag.Bool("version", false, "show version information")
	flag.Parse()

	if *showVersion {
		fmt.Printf("ToDoList Backend\n")
		fmt.Printf("Version: %s\n", version)
		fmt.Printf("Commit: %s\n", commit)
		fmt.Printf("Build Date: %s\n", date)
		os.Exit(0)
	}

	// 加载配置 / Load configuration
	cfg, err := config.LoadConfig("config/config.yaml")
	if err != nil {
		log.Fatalf("无法加载配置文件 / Unable to load configuration file: %v", err)
	}

	// 初始化数据库 / Initialize database
	db, err := database.InitDB(cfg)
	if err != nil {
		log.Fatalf("数据库初始化失败 / Database initialization failed: %v", err)
	}
	defer db.Close()

	// 运行数据库迁移 / Run database migration
	if err := database.Migrate(db); err != nil {
		log.Fatalf("数据库迁移失败 / Database migration failed: %v", err)
	}

	// 设置Gin模式 / Set Gin mode
	if cfg.Server.Mode == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 创建路由
	r := gin.Default()

	// 中间件
	r.Use(middleware.CORS())
	r.Use(middleware.Logger())

	// 根路径健康检查
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "ToDoList Backend API",
			"version": version,
			"status":  "running",
		})
	})

	// API路由组
	api := r.Group("/api/v1")
	{
		// 健康检查
		api.GET("/health", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"status":  "ok",
				"version": version,
				"commit":  commit,
				"date":    date,
			})
		})

		// 版本信息
		api.GET("/version", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"version": version,
				"commit":  commit,
				"date":    date,
			})
		})

		// 认证相关路由
		auth := api.Group("/auth")
		{
			authHandler := handlers.NewAuthHandler(db, cfg)
			auth.POST("/login", authHandler.Login)
			if cfg.Features.EnableRegistration {
				auth.POST("/register", authHandler.Register)
			}
		}

		// 需要认证的路由
		protected := api.Group("/")
		protected.Use(middleware.AuthMiddleware(cfg.JWT.Secret))
		{
			todoHandler := handlers.NewTodoHandler(db)

			// 大事件相关
			protected.GET("/events", todoHandler.GetEvents)
			protected.POST("/events", todoHandler.CreateEvent)
			protected.PUT("/events/:id", todoHandler.UpdateEvent)
			protected.DELETE("/events/:id", todoHandler.DeleteEvent)

			// 小事件相关
			protected.GET("/events/:eventId/tasks", todoHandler.GetTasks)
			protected.POST("/events/:eventId/tasks", todoHandler.CreateTask)
			protected.PUT("/tasks/:id", todoHandler.UpdateTask)
			protected.DELETE("/tasks/:id", todoHandler.DeleteTask)
		}
	}

	log.Printf("服务器启动在端口 %s", cfg.Server.Port)
	log.Fatal(r.Run(cfg.Server.Port))
}
