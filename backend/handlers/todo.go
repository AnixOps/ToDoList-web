package handlers

import (
	"net/http"
	"strconv"

	"todolist-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/jinzhu/gorm"
)

// TodoHandler ToDoList处理器
type TodoHandler struct {
	db *gorm.DB
}

// NewTodoHandler 创建ToDoList处理器
func NewTodoHandler(db *gorm.DB) *TodoHandler {
	return &TodoHandler{db: db}
}

// GetEvents 获取用户的所有大事件
func (h *TodoHandler) GetEvents(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var events []models.Event
	if err := h.db.Where("user_id = ?", userID).
		Preload("Tasks").
		Order("created_at DESC").
		Find(&events).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取事件列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"events": events,
	})
}

// CreateEvent 创建大事件
func (h *TodoHandler) CreateEvent(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req models.CreateEventRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	event := models.Event{
		UserID:      userID.(uint),
		Title:       req.Title,
		Description: req.Description,
		Priority:    req.Priority,
		DueDate:     req.DueDate,
	}

	if event.Priority == "" {
		event.Priority = "medium"
	}

	if err := h.db.Create(&event).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建事件失败"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "事件创建成功",
		"event":   event,
	})
}

// UpdateEvent 更新大事件
func (h *TodoHandler) UpdateEvent(c *gin.Context) {
	userID, _ := c.Get("user_id")
	eventID := c.Param("id")

	var req models.UpdateEventRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var event models.Event
	if err := h.db.Where("id = ? AND user_id = ?", eventID, userID).First(&event).Error; err != nil {
		if gorm.IsRecordNotFoundError(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "事件不存在"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "查询事件失败"})
		}
		return
	}

	// 更新字段
	if req.Title != "" {
		event.Title = req.Title
	}
	if req.Description != "" {
		event.Description = req.Description
	}
	if req.Status != "" {
		event.Status = req.Status
	}
	if req.Priority != "" {
		event.Priority = req.Priority
	}
	if req.DueDate != nil {
		event.DueDate = req.DueDate
	}

	if err := h.db.Save(&event).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新事件失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "事件更新成功",
		"event":   event,
	})
}

// DeleteEvent 删除大事件
func (h *TodoHandler) DeleteEvent(c *gin.Context) {
	userID, _ := c.Get("user_id")
	eventID := c.Param("id")

	var event models.Event
	if err := h.db.Where("id = ? AND user_id = ?", eventID, userID).First(&event).Error; err != nil {
		if gorm.IsRecordNotFoundError(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "事件不存在"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "查询事件失败"})
		}
		return
	}

	// 开始事务
	tx := h.db.Begin()

	// 删除关联的任务
	if err := tx.Where("event_id = ?", eventID).Delete(&models.Task{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除关联任务失败"})
		return
	}

	// 删除事件
	if err := tx.Delete(&event).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除事件失败"})
		return
	}

	tx.Commit()

	c.JSON(http.StatusOK, gin.H{
		"message": "事件删除成功",
	})
}

// GetTasks 获取大事件的所有小事件
func (h *TodoHandler) GetTasks(c *gin.Context) {
	userID, _ := c.Get("user_id")
	eventID := c.Param("eventId")

	// 验证事件是否属于当前用户
	var event models.Event
	if err := h.db.Where("id = ? AND user_id = ?", eventID, userID).First(&event).Error; err != nil {
		if gorm.IsRecordNotFoundError(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "事件不存在"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "查询事件失败"})
		}
		return
	}

	var tasks []models.Task
	if err := h.db.Where("event_id = ?", eventID).
		Order("created_at DESC").
		Find(&tasks).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取任务列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"tasks": tasks,
	})
}

// CreateTask 创建小事件
func (h *TodoHandler) CreateTask(c *gin.Context) {
	userID, _ := c.Get("user_id")
	eventID := c.Param("eventId")

	// 验证事件是否属于当前用户
	var event models.Event
	if err := h.db.Where("id = ? AND user_id = ?", eventID, userID).First(&event).Error; err != nil {
		if gorm.IsRecordNotFoundError(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "事件不存在"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "查询事件失败"})
		}
		return
	}

	var req models.CreateTaskRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	eventIDUint, err := strconv.ParseUint(eventID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的事件ID"})
		return
	}

	task := models.Task{
		EventID:     uint(eventIDUint),
		Title:       req.Title,
		Description: req.Description,
		Priority:    req.Priority,
		DueDate:     req.DueDate,
	}

	if task.Priority == "" {
		task.Priority = "medium"
	}

	if err := h.db.Create(&task).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建任务失败"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "任务创建成功",
		"task":    task,
	})
}

// UpdateTask 更新小事件
func (h *TodoHandler) UpdateTask(c *gin.Context) {
	userID, _ := c.Get("user_id")
	taskID := c.Param("id")

	var req models.UpdateTaskRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var task models.Task
	if err := h.db.Preload("Event").Where("id = ?", taskID).First(&task).Error; err != nil {
		if gorm.IsRecordNotFoundError(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "任务不存在"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "查询任务失败"})
		}
		return
	}

	// 验证任务是否属于当前用户
	if task.Event.UserID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "无权限访问此任务"})
		return
	}

	// 更新字段
	if req.Title != "" {
		task.Title = req.Title
	}
	if req.Description != "" {
		task.Description = req.Description
	}
	if req.Status != "" {
		task.Status = req.Status
	}
	if req.Priority != "" {
		task.Priority = req.Priority
	}
	if req.DueDate != nil {
		task.DueDate = req.DueDate
	}

	if err := h.db.Save(&task).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新任务失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "任务更新成功",
		"task":    task,
	})
}

// DeleteTask 删除小事件
func (h *TodoHandler) DeleteTask(c *gin.Context) {
	userID, _ := c.Get("user_id")
	taskID := c.Param("id")

	var task models.Task
	if err := h.db.Preload("Event").Where("id = ?", taskID).First(&task).Error; err != nil {
		if gorm.IsRecordNotFoundError(err) {
			c.JSON(http.StatusNotFound, gin.H{"error": "任务不存在"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "查询任务失败"})
		}
		return
	}

	// 验证任务是否属于当前用户
	if task.Event.UserID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "无权限访问此任务"})
		return
	}

	if err := h.db.Delete(&task).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除任务失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "任务删除成功",
	})
}