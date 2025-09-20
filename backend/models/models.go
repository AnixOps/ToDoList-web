package models

import (
	"time"

	"github.com/jinzhu/gorm"
	"golang.org/x/crypto/bcrypt"
)

// User 用户模型
type User struct {
	ID        uint      `json:"id" gorm:"primary_key"`
	Username  string    `json:"username" gorm:"unique;not null"`
	Email     string    `json:"email" gorm:"unique;not null"`
	Password  string    `json:"-" gorm:"not null"` // JSON中不返回密码
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// 关联
	Events []Event `json:"events,omitempty" gorm:"foreignkey:UserID"`
}

// Event 大事件模型
type Event struct {
	ID          uint      `json:"id" gorm:"primary_key"`
	UserID      uint      `json:"user_id" gorm:"not null"`
	Title       string    `json:"title" gorm:"not null"`
	Description string    `json:"description"`
	Status      string    `json:"status" gorm:"default:'pending'"` // pending, completed, cancelled
	Priority    string    `json:"priority" gorm:"default:'medium'"` // low, medium, high
	DueDate     *time.Time `json:"due_date"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联
	User  User   `json:"user,omitempty" gorm:"foreignkey:UserID"`
	Tasks []Task `json:"tasks,omitempty" gorm:"foreignkey:EventID"`
}

// Task 小事件模型（属于某个大事件）
type Task struct {
	ID          uint      `json:"id" gorm:"primary_key"`
	EventID     uint      `json:"event_id" gorm:"not null"`
	Title       string    `json:"title" gorm:"not null"`
	Description string    `json:"description"`
	Status      string    `json:"status" gorm:"default:'pending'"` // pending, completed, cancelled
	Priority    string    `json:"priority" gorm:"default:'medium'"` // low, medium, high
	DueDate     *time.Time `json:"due_date"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联
	Event Event `json:"event,omitempty" gorm:"foreignkey:EventID"`
}

// CreateUserRequest 创建用户请求
type CreateUserRequest struct {
	Username string `json:"username" binding:"required,min=3,max=50"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

// LoginRequest 登录请求
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// CreateEventRequest 创建大事件请求
type CreateEventRequest struct {
	Title       string     `json:"title" binding:"required,max=200"`
	Description string     `json:"description"`
	Priority    string     `json:"priority" binding:"omitempty,oneof=low medium high"`
	DueDate     *time.Time `json:"due_date"`
}

// UpdateEventRequest 更新大事件请求
type UpdateEventRequest struct {
	Title       string     `json:"title" binding:"omitempty,max=200"`
	Description string     `json:"description"`
	Status      string     `json:"status" binding:"omitempty,oneof=pending completed cancelled"`
	Priority    string     `json:"priority" binding:"omitempty,oneof=low medium high"`
	DueDate     *time.Time `json:"due_date"`
}

// CreateTaskRequest 创建小事件请求
type CreateTaskRequest struct {
	Title       string     `json:"title" binding:"required,max=200"`
	Description string     `json:"description"`
	Priority    string     `json:"priority" binding:"omitempty,oneof=low medium high"`
	DueDate     *time.Time `json:"due_date"`
}

// UpdateTaskRequest 更新小事件请求
type UpdateTaskRequest struct {
	Title       string     `json:"title" binding:"omitempty,max=200"`
	Description string     `json:"description"`
	Status      string     `json:"status" binding:"omitempty,oneof=pending completed cancelled"`
	Priority    string     `json:"priority" binding:"omitempty,oneof=low medium high"`
	DueDate     *time.Time `json:"due_date"`
}

// HashPassword 加密密码
func (u *User) HashPassword() error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	u.Password = string(hashedPassword)
	return nil
}

// CheckPassword 验证密码
func (u *User) CheckPassword(password string) error {
	return bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
}

// BeforeCreate GORM钩子 - 创建前加密密码
func (u *User) BeforeCreate(scope *gorm.Scope) error {
	return u.HashPassword()
}