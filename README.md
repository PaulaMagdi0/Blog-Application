# 🌐 WebOps Task – Rails API

## 📌 Overview

This is an **API-only Ruby on Rails 8** application developed for a WebOps task.  
It features robust user authentication, post creation with tagging, and nested commenting functionality.  
The app is containerized with **Docker**, leverages **JWT** for secure access, and includes a **Postman** collection for easy API testing.

---

## 🚀 Features

### 🔐 Authentication & Authorization

- Secure JWT-based login/signup using email and password.
- All API routes are protected and require a valid token.
- **User Model Fields:**
  - `name`
  - `email`
  - `password_digest`
  - `image` (optional)

### 📝 Post Management

- **Post Model Fields:**
  - `title`
  - `body`
  - `user_id` (author)
  - `tags` (at least one required)
- Only post owners can update/delete their posts.
- Posts **auto-delete 24 hours after creation** using background jobs.

### 💬 Commenting System

- Users can comment on any post.
- Only the comment author can edit or delete a comment.

---

## 🛠️ Tech Stack

| Layer          | Tech                       |
| -------------- | -------------------------- |
| **Backend**    | Ruby on Rails 8 (API mode) |
| **Database**   | PostgreSQL                 |
| **Auth**       | JWT                        |
| **Background** | Sidekiq                    |
| **Testing**    | RSpec                      |
| **Container**  | Docker & Docker Compose    |

---

## ⚙️ Getting Started

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/PaulaMagdi0/Blog-Application.git
cd Blog-Application
```

### 2️⃣ Run the App

Make sure Docker is installed, then run:

```bash
docker-compose up
```

### 3️⃣ Run Tests

To run RSpec tests for API endpoints:

```bash
bundle exec rspec spec/requests/api_spec.rb --format documentation
```

---

## 📫 Contact

For any questions, feel free to open an issue or contact the repository owner.

---

Happy coding! 💻✨
