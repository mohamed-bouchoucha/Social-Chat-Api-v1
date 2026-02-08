# SocialChat Flutter App

A production-ready Flutter frontend for a real-time social networking and messaging platform powered by a Spring Boot backend.

This project implements a modern social chat application with JWT-based authentication, real-time messaging using WebSockets (STOMP with SockJS), live notifications, presence tracking, and a full social system including posts, likes, comments, and friends.

## 🚀 Features

### Authentication & Users
- JWT-based login and registration
- Secure token storage
- Profile management (avatar, bio, display name)
- Logout and session handling

### Social Networking
- Create and view posts
- Like and comment on posts
- User discovery and search
- Friend requests and friend list management
- Block / unblock users

### Real-Time Communication
- One-to-one and group chat
- Message persistence
- Typing indicators
- Read receipts
- Delivery confirmation
- Online / offline presence tracking
- Friends-only visibility

### Real-Time Notifications
- New messages
- Friend requests
- Likes and comments
- Instant delivery via WebSocket

## 🧱 Tech Stack

**Frontend**
- Flutter 3.x
- Dart
- Riverpod (state management)
- Dio (REST API client)
- STOMP over WebSocket (SockJS compatible)
- GoRouter
- Material 3

**Backend (separate repository)**
- Java Spring Boot
- MySQL
- JWT Authentication
- WebSocket (STOMP)

## 🔌 Backend Integration

The app connects to a Spring Boot backend using:
- REST APIs for authentication and social features
- WebSocket (STOMP) for chat, presence, and notifications

All backend URLs are configurable and can be adjusted to match your environment.

## 📦 Project Status

This repository provides a scalable, clean-architecture Flutter starter that is ready for:
- Android
- iOS
- Web

It is designed to be extended with additional features such as push notifications, media uploads, and advanced moderation tools.

## 📄 License

MIT License
