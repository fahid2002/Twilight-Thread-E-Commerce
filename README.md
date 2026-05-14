# Twilight E-Commerce Platform

<div align="center">

![Twilight Logo](frontend/images/logo.png)

**An E-Commerce Platform for Handmade crochet Products**

Built with HTML, Tailwind CSS, JavaScript, Bash, and SQLite

</div>

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Security Features](#security-features)
- [Admin Panel](#admin-panel)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🌟 Overview

Twilight is a fully functional e-commerce platform designed specifically for selling handmade women's products. The platform features a beautiful, responsive frontend built with Tailwind CSS, and a robust backend powered by Bash scripts and SQLite database.

### Key Highlights

- ✨ **Beautiful UI/UX** - Modern, professional design with Tailwind CSS
- 🔐 **Secure Authentication** - Password hashing with SHA-256
- 🛒 **Full Shopping Cart** - Add, update, remove items with real-time updates
- 📦 **Order Management** - Complete checkout and order tracking system
- 👑 **Admin Dashboard** - Comprehensive product and order management
- 📱 **Responsive Design** - Works perfectly on all devices
- ⚡ **Fast & Lightweight** - No heavy frameworks, pure performance

## ✨ Features

### Customer Features

- **User Registration & Authentication**
  - Secure registration with email validation
  - SHA-256 password hashing
  - Session-based authentication
  - Remember me functionality

- **Product Browsing**
  - Beautiful product catalog with high-quality images
  - Category-based filtering
  - Search functionality
  - Price range filters
  - Sort by price, name, or date

- **Shopping Experience**
  - Add products to cart
  - Update quantities
  - Remove items
  - Real-time cart updates
  - Stock availability checks

- **Checkout & Orders**
  - Secure checkout process
  - Shipping information form
  - Order confirmation
  - Order history tracking

### Admin Features

- **Dashboard Overview**
  - Total products, orders, customers stats
  - Revenue tracking
  - Quick analytics

- **Product Management**
  - Add new products
  - Edit existing products
  - Delete products
  - Stock management
  - Category assignment
  - Image management

- **Order Management**
  - View all orders
  - Order status tracking
  - Customer information
  - Order details

## 🛠 Technology Stack

### Frontend
- **HTML5** - Semantic markup
- **Tailwind CSS** - Utility-first CSS framework
- **JavaScript (ES6+)** - Modern vanilla JavaScript
- **Font Awesome** - Icon library
- **Google Fonts** - Playfair Display & Poppins

### Backend
- **Bash (Bourne Again Shell)** - Server-side scripting
- **SQLite** - Lightweight database
- **CGI** - Common Gateway Interface for backend communication

### Security
- **SHA-256** - Password hashing
- **Session Tokens** - Secure session management
- **Input Sanitization** - SQL injection prevention
- **Input Validation** - Data integrity

## 📁 Project Structure

```
Twilight/
├── frontend/                    # Frontend files
│   ├── index.html              # Landing page
│   ├── products.html           # Product listing
│   ├── product-detail.html     # Product details
│   ├── cart.html               # Shopping cart
│   ├── checkout.html           # Checkout page
│   ├── login.html              # Login page
│   ├── register.html           # Registration page
│   ├── admin/
│   │   └── dashboard.html      # Admin dashboard
│   ├── js/
│   │   └── main.js             # Main JavaScript file
│   ├── css/                    # Additional CSS (if any)
│   └── images/                 # Product and site images
│
├── scripts/                     # Backend Bash scripts
│   ├── init_db.sh              # Database initialization
│   ├── utils.sh                # Utility functions
│   ├── register.sh             # User registration
│   ├── login.sh                # User login
│   ├── logout.sh               # User logout
│   ├── show_products.sh        # Get products
│   ├── add_product.sh          # Add product (admin)
│   ├── update_product.sh       # Update product (admin)
│   ├── delete_product.sh       # Delete product (admin)
│   ├── cart_handler.sh         # Cart operations
│   ├── checkout.sh             # Checkout processing
│   └── orders.sh               # Order management
│
├── cgi-bin/                     # CGI scripts
│   └── api.sh                  # Main API router
│
├── database/                    # SQLite database
│   └── twilight.db            # Main database file
│
├── sessions/                    # Session storage
│   └── *.session               # Session files
│
├── run.sh                       # Server launcher
└── README.md                    # This file
```

## 🚀 Installation & Setup

### Prerequisites

- **Bash** (version 4.0 or higher)
- **SQLite3** (version 3.0 or higher)
- **Python 3** (for running the development server)
- **Git** (optional, for cloning)

### Installation Steps

1. **Clone or download the project**
   ```bash
   cd "d:\os project"
   # If using Git:
   # git clone <repository-url> Twilight
   ```

2. **Navigate to the project directory**
   ```bash
   cd Twilight
   ```

3. **Make scripts executable**
   ```bash
   chmod +x run.sh
   chmod +x scripts/*.sh
   chmod +x cgi-bin/*.sh
   ```

4. **Initialize the database** (optional - will be done automatically on first run)
   ```bash
   bash scripts/init_db.sh
   ```

5. **Start the server**
   ```bash
   bash run.sh
   ```

6. **Access the website**
   - Open your browser and go to: `http://localhost:8080`
   - Admin panel: `http://localhost:8080/admin/dashboard.html`

## 📖 Usage

### Customer Workflow

1. **Browse Products**
   - Visit the homepage
   - Click "Shop Now" or navigate to products page
   - Filter by category or search for specific items

2. **Create Account**
   - Click "Login" in the navigation
   - Click "Sign Up" link
   - Fill in registration form
   - Submit to create account

3. **Add to Cart**
   - Click on a product to view details
   - Select quantity
   - Click "Add to Cart"

4. **Checkout**
   - Click cart icon in navigation
   - Review items in cart
   - Click "Proceed to Checkout"
   - Fill in shipping information
   - Complete order

### Admin Workflow

1. **Login as Admin**
   - Username: `admin`
   - Password: `admin123`
   - Navigate to: `http://localhost:8080/admin/dashboard.html`

2. **Manage Products**
   - Click "Add Product" to add new items
   - Click edit icon to modify existing products
   - Click delete icon to remove products

3. **View Orders**
   - Click "Orders" tab
   - View all customer orders
   - See order details and status

## 🔌 API Documentation

### Base URL
```
http://localhost:8080/cgi-bin/api.sh
```

### Authentication Endpoints

#### Register User
```bash
POST /cgi-bin/api.sh?action=register
Content-Type: application/x-www-form-urlencoded

username=johndoe&password=secret123&email=john@example.com&full_name=John Doe&role=customer
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful",
  "token": "abc123...",
  "user": {
    "id": 1,
    "username": "johndoe",
    "role": "customer"
  }
}
```

#### Login
```bash
POST /cgi-bin/api.sh?action=login
Content-Type: application/x-www-form-urlencoded

username=admin&password=admin123
```

#### Logout
```bash
GET /cgi-bin/api.sh?action=logout&token=<session_token>
```

### Product Endpoints

#### Get All Products
```bash
GET /cgi-bin/api.sh?action=show_products
```

#### Get Product by ID
```bash
GET /cgi-bin/api.sh?action=show_products&id=1
```

#### Get Products by Category
```bash
GET /cgi-bin/api.sh?action=show_products&category=Jewelry
```

#### Add Product (Admin Only)
```bash
POST /cgi-bin/api.sh?action=add_product
Content-Type: application/x-www-form-urlencoded

token=<admin_token>&name=Product Name&description=Description&price=29.99&stock=50&category=Jewelry&image=product.jpg
```

#### Update Product (Admin Only)
```bash
POST /cgi-bin/api.sh?action=update_product
Content-Type: application/x-www-form-urlencoded

token=<admin_token>&id=1&name=Updated Name&price=39.99&stock=45
```

#### Delete Product (Admin Only)
```bash
POST /cgi-bin/api.sh?action=delete_product
Content-Type: application/x-www-form-urlencoded

token=<admin_token>&id=1
```

### Cart Endpoints

#### View Cart
```bash
GET /cgi-bin/api.sh?action=cart_handler&token=<session_token>&action=view
```

#### Add to Cart
```bash
POST /cgi-bin/api.sh?action=cart_handler
Content-Type: application/x-www-form-urlencoded

token=<session_token>&action=add&product_id=1&quantity=2
```

#### Update Cart Item
```bash
POST /cgi-bin/api.sh?action=cart_handler
Content-Type: application/x-www-form-urlencoded

token=<session_token>&action=update&product_id=1&quantity=3
```

#### Remove from Cart
```bash
POST /cgi-bin/api.sh?action=cart_handler
Content-Type: application/x-www-form-urlencoded

token=<session_token>&action=remove&product_id=1
```

### Order Endpoints

#### Checkout
```bash
POST /cgi-bin/api.sh?action=checkout
Content-Type: application/x-www-form-urlencoded

token=<session_token>&shipping_address=123 Main St, City, State 12345
```

#### View Orders
```bash
GET /cgi-bin/api.sh?action=orders&token=<session_token>
```

## 🔒 Security Features

### Password Security
- **SHA-256 Hashing** - All passwords are hashed before storage
- **No Plain Text** - Passwords are never stored in plain text
- **Minimum Length** - Enforced 6-character minimum

### Session Management
- **Random Token Generation** - 64-character random tokens
- **Session Expiration** - 24-hour session timeout
- **Secure Storage** - Session files with restricted permissions

### Input Validation
- **Username Validation** - 3-20 alphanumeric characters
- **Email Validation** - Proper email format checking
- **SQL Injection Prevention** - Input sanitization
- **XSS Protection** - HTML entity encoding

### Access Control
- **Role-Based Access** - Admin vs. Customer roles
- **Admin-Only Actions** - Product management restricted to admins
- **Session Verification** - All protected routes require valid session

## 👑 Admin Panel

### Default Admin Credentials
```
Username: admin
Password: admin123
```

⚠️ **Important:** Change the default admin password after first login!

### Admin Features

1. **Dashboard Statistics**
   - Total products count
   - Total orders count
   - Total customers
   - Revenue tracking

2. **Product Management**
   - Add new products with all details
   - Edit existing product information
   - Delete products
   - Manage inventory/stock levels

3. **Order Viewing**
   - View all customer orders
   - See order status
   - Track order history
   - View customer information

## 🐛 Troubleshooting

### Database Issues

**Problem:** Database not found
```bash
# Solution: Initialize the database
bash scripts/init_db.sh
```

**Problem:** Permission denied on database
```bash
# Solution: Fix permissions
chmod 664 database/twilight.db
chmod 755 database
```

### Server Issues

**Problem:** Port 8080 already in use
```bash
# Solution: Change port in run.sh
# Edit run.sh and change PORT=8080 to another port like PORT=3000
```

**Problem:** Scripts not executable
```bash
# Solution: Make scripts executable
chmod +x run.sh scripts/*.sh cgi-bin/*.sh
```

### Session Issues

**Problem:** Session expired or invalid
```bash
# Solution: Clear sessions and re-login
rm -rf sessions/*.session
```

### Common Errors

**Error:** `sqlite3: command not found`
```bash
# Solution: Install SQLite3
# On Ubuntu/Debian:
sudo apt-get install sqlite3

# On Windows (Git Bash):
# Download SQLite from https://www.sqlite.org/download.html
```

**Error:** `bash: ./run.sh: Permission denied`
```bash
# Solution: Make script executable
chmod +x run.sh
```

## 🎨 Customization

### Changing Colors

Edit the Tailwind classes in HTML files:
- Primary color: `purple-600` → Change to any Tailwind color
- Replace `bg-purple-600`, `text-purple-600`, etc.

### Adding Products

1. **Via Admin Panel** (Recommended)
   - Login as admin
   - Click "Add Product"
   - Fill in product details

2. **Via Database**
   ```bash
   sqlite3 database/twilight.db
   INSERT INTO products (name, description, price, stock, category, image) 
   VALUES ('Product Name', 'Description', 29.99, 100, 'Category', 'image.jpg');
   ```

### Adding Images

1. Place product images in `frontend/images/`
2. Use the filename when adding products
3. For placeholder images, the system uses Unsplash fallbacks

## 📝 Database Schema

### Users Table
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('admin', 'customer')),
    full_name TEXT,
    phone TEXT,
    address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Products Table
```sql
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL CHECK(price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK(stock >= 0),
    category TEXT,
    image TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Cart Table
```sql
CREATE TABLE cart (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE(user_id, product_id)
);
```

### Orders Table
```sql
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    total_price REAL NOT NULL,
    status TEXT DEFAULT 'pending',
    shipping_address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Tailwind CSS for the amazing utility-first CSS framework
- Font Awesome for the comprehensive icon library
- Unsplash for placeholder images
- SQLite for the lightweight database engine

## 📧 Contact

For questions, issues, or suggestions:
- Create an issue on GitHub
- Email: support@twilight.com

---

<div align="center">

**Developed as my final project for the Operating System Lab**

⭐ Star this repository if you find it helpful!

</div>
