📱 SocialChat Flutter App

Flutter · Dart · REST · WebSocket (STOMP) · JWT

A production-ready Flutter frontend for the SocialChat API, providing a modern, real-time social networking and messaging experience across Android, iOS, and Web.

📋 Table of Contents

Overview

Features

Architecture

Tech Stack

Getting Started

Configuration

Backend Integration

WebSocket Integration

State Management

Project Structure

Development

Deployment

Troubleshooting

Contributing

License

🎯 Overview

SocialChat Flutter App is a scalable, clean-architecture frontend built with Flutter and Dart, designed to consume the SocialChat Spring Boot backend.

It supports JWT-based authentication, real-time messaging via WebSocket (STOMP + SockJS), social feeds, notifications, presence tracking, and full chat functionality.

Key Highlights

🔐 Secure JWT authentication with refresh handling

🚀 Real-time chat using STOMP over WebSocket

🔔 Live notifications and presence updates

👥 Friends system & social feed

📱 Cross-platform: Android, iOS, Web

🧱 Clean architecture with feature-based structure

✨ Features
Authentication & Security

Login / Register

Secure token storage

Automatic token refresh

Logout & session invalidation

Social Networking

User profiles (avatar, bio, display name)

Create, edit, delete posts

Likes & nested comments

User discovery & search

Friend requests and blocking

Real-Time Messaging

One-to-one & group conversations

Message persistence

Typing indicators

Read receipts

Delivery confirmation

Image messages (backend-supported)

Presence & Notifications

Online / offline presence

Friends-only visibility

Real-time notifications:

Messages

Friend requests

Likes & comments

🏗️ Architecture
High-Level Architecture
Flutter UI
   ↓
Riverpod (State Management)
   ↓
Repositories
   ↓
REST API (Dio)  +  WebSocket (STOMP)
   ↓
Spring Boot SocialChat API

Architecture Principles

Feature-based folder structure

Separation of UI, state, and data layers

Immutable state models

Centralized API & WebSocket services

🛠️ Tech Stack
Frontend

Flutter 3.x

Dart

Material 3

Riverpod – state management

Dio – REST API client

STOMP Dart Client – WebSocket messaging

GoRouter – navigation

Flutter Secure Storage – JWT storage

Backend (External)

Java Spring Boot 3.x

MySQL

JWT Authentication

STOMP over SockJS WebSocket

🚀 Getting Started
Prerequisites

Ensure you have:

flutter --version   # Flutter 3.x+
dart --version

Installation

Clone the repository:

git clone https://github.com/your-username/socialchat-flutter.git
cd socialchat-flutter


Install dependencies:

flutter pub get


Run the app:

flutter run

⚙️ Configuration
Environment Configuration

Edit lib/core/constants/app_constants.dart:

class AppConstants {
  static const String baseUrl = 'http://localhost:8080/api';
  static const String wsUrl = 'http://localhost:8080/ws';

  static const Duration wsReconnectDelay = Duration(seconds: 5);
}

🔌 Backend Integration
REST API

All REST calls use Dio

JWT added automatically via interceptors

Unified API response handling

Error mapping to UI-friendly messages

Example Login Request
final response = await dio.post(
  '/auth/login',
  data: {
    'usernameOrEmail': username,
    'password': password,
  },
);

🔌 WebSocket Integration
Connection Details

Protocol: STOMP over WebSocket

Transport: SockJS-compatible

Auth: JWT via headers

WebSocket Service

lib/core/network/stomp_service.dart

Supported:

Message events

Typing indicators

Read receipts

Presence updates

Notifications

Auto-reconnect with backoff

Subscriptions
Destination	Description
/user/queue/notifications	Personal notifications
/user/queue/presence	Friends presence
/topic/conversations/{id}/messages	Chat messages
/topic/conversations/{id}/typing	Typing indicators
/topic/conversations/{id}/read-receipts	Read receipts
🧠 State Management
Riverpod

StateNotifier for business logic

Immutable state classes

Feature-scoped providers

Example:

final authProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);

📁 Project Structure
lib/
├── core/
│   ├── constants/
│   ├── network/
│   ├── storage/
│   └── utils/
├── features/
│   ├── auth/
│   ├── chat/
│   ├── posts/
│   ├── friends/
│   ├── notifications/
│   └── profile/
├── router/
├── theme/
└── main.dart

🧪 Development
Run in Debug
flutter run

Web (Local)
flutter run -d web-server

Format Code
flutter format .

🚀 Deployment
Android
flutter build apk

iOS
flutter build ios

Web
flutter build web

🛠️ Troubleshooting
WebSocket Issues

Ensure backend /ws endpoint is reachable

Confirm JWT is valid

Check CORS configuration on backend

Web Browser Launch Error

If Chrome/Edge fails:

flutter run -d web-server

🤝 Contributing

Contributions are welcome:

Fork the repository

Create a feature branch

Submit a pull request

📄 License

MIT License
