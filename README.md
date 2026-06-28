# 💰 FinTrack

FinTrack is a full-stack personal finance management application designed to help users manage their financial activities efficiently. The application provides features for wallet management, income and expense tracking, budgeting, saving goals, and financial analytics through an intuitive mobile interface powered by a Laravel REST API.

---

## 📱 Features

### Authentication
- User registration
- User login
- Secure authentication using Laravel Sanctum

### Wallet Management
- Create multiple wallets
- Update wallet information
- Delete wallets
- Track wallet balances

### Transaction Management
- Record income
- Record expenses
- Filter transactions
- Transaction history

### Category Management
- Default categories
- Custom categories
- CRUD operations

### Budget Management
- Monthly budgets
- Budget monitoring
- Budget usage tracking

### Saving Goals
- Create saving goals
- Update saving progress
- Monitor target achievement

### Dashboard
- Total balance
- Income summary
- Expense summary
- Monthly trend
- Expense visualization

### Financial Analytics
- Spending Alert
- Budget Risk Analysis
- Financial Health Score
- Spending Prediction
- Saving Recommendation
- Monthly Review
- No Spend Day
- Anomaly Detection

---

# 🏗 Project Structure

```
fintrack
│
├── backend
│   └── Laravel REST API
│
├── mobile
│   └── Flutter Application
│
└── docs
    └── Documentation
```

---

# 🛠 Tech Stack

## Backend

- Laravel 12
- PHP 8.3+
- Laravel Sanctum
- MySQL
- Repository Pattern
- Service Layer
- REST API

## Mobile

- Flutter
- Riverpod
- Dio
- Go Router
- Flutter Secure Storage
- FL Chart

---

# 🚀 Getting Started

## Clone Repository

```bash
git clone https://github.com/yogatarg/fintrack.git

cd fintrack
```

---

# Backend Setup

```bash
cd backend

composer install

cp .env.example .env

php artisan key:generate

php artisan migrate --seed

php artisan serve
```

---

# Mobile Setup

```bash
cd mobile

flutter pub get

flutter run
```

---

# REST API

The backend exposes RESTful APIs for:

- Authentication
- Wallet
- Transaction
- Category
- Budget
- Saving Goal
- Dashboard
- Analytics

---

# Architecture

```
Flutter Mobile
        │
        ▼
 REST API (Laravel)
        │
        ▼
    MySQL Database
```

---

# Screenshots

Coming Soon

---

# Future Improvements

- Push Notification
- Recurring Transactions
- Export PDF Report
- Multi Currency Support
- Dark Mode
- Cloud Backup
- AI Financial Insights

---

# License

This project is intended for educational and portfolio purposes.

---

# Author

**Yogata Rama**

Information Systems Student

GitHub:
https://github.com/yogatarg
