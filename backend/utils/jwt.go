package utils

import (
	"time"

	"todolist-backend/middleware"

	"github.com/golang-jwt/jwt/v4"
)

// GenerateJWT 生成JWT token
func GenerateJWT(userID uint, username, secretKey string, expiresIn int) (string, error) {
	// 设置过期时间
	expirationTime := time.Now().Add(time.Duration(expiresIn) * time.Hour)

	// 创建声明
	claims := &middleware.JWTClaims{
		UserID:   userID,
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}

	// 创建token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// 签名token
	tokenString, err := token.SignedString([]byte(secretKey))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}