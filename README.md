# WebOps Task – Rails API

## 📌 Overview

This is a Ruby on Rails 8 API-only application built for a WebOps task.
It offers a full-featured backend for user authentication, post management with tagging, and nested commenting.
The app is containerized with Docker, uses JWT for secure access, and includes a Postman collection for easy API testing.

---

## 🚀 Features

### 🔐 Authentication & Authorization

- **JWT-Based Authentication**

  - Secure login/signup with email and password.
  - All API routes require a valid JWT token.

- **User Model Fields**
  - `name`
  - `email`
  - `password_digest`
  - `image` (optional)

---

### 📝 Post Management

- **Post Model Fields**

  - `title`
  - `body`
  - `user_id` (author)
  - `tags` (at least one required)
  - Auto-expiry: posts are deleted **24 hours** after creation via background job.

- **CRUD Capabilities**
  - Create, update, and delete (only your own posts).
  - Add/update tags dynamically.
  - Posts auto-deleted via background job (demo below).

---

### 💬 Commenting System

- Users can comment on any post.
- Only comment authors can update or delete their comments.

---

## 🛠️ Technology Stack

- **Backend**: Ruby on Rails 8 (API mode)
- **Database**: PostgreSQL
- **Authentication**: JWT
- **Background Jobs**: Sidekiq
- **Testing**: RSpec
- **Containerization**: Docker & Docker Compose

---

## ⚙️ Setup Instructions

1. **Clone the Repository**

```bash
git clone https://github.com/PaulaMagdi0/Blog-Application.git
cd Blog-Application

## How to run?
- have docker installed on your machine
- run `docker-compose up` command


- you can use the command `rspec` to test your API end points.
bundle exec rspec spec/requests/api_spec.rb --format documentation
```
