package main

import (
	"log"
	"net/http"

	"todolist-backend/config"
	"todolist-backend/database"
	"todolist-backend/handlers"
	"todolist-backend/middleware"

	"github.com/gin-gonic/gin"
)

func main() {
	// 加载配置
	cfg, err := config.LoadConfig("config/config.yaml")
	if err != nil {
		log.Fatalf("无法加载配置文件: %v", err)
	}

	// 初始化数据库
	db, err := database.InitDB(cfg)
	if err != nil {
		log.Fatalf("数据库初始化失败: %v", err)
	}
	defer db.Close()

	// 运行数据库迁移
	if err := database.Migrate(db); err != nil {
		log.Fatalf("数据库迁移失败: %v", err)
	}

	// 设置Gin模式
	if cfg.Server.Mode == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 创建路由
	r := gin.Default()

	// 中间件
	r.Use(middleware.CORS())
	r.Use(middleware.Logger())

	// 静态文件服务
	r.Static("/static", "./static")

	// API路由组
	api := r.Group("/api/v1")
	{
		// 健康检查
		api.GET("/health", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "ok"})
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