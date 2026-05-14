# Twilight - Quick Start Guide

## Installation (3 Simple Steps)

### Step 1: Navigate to the project
```bash
cd "d:\os project\Twilight"
```

### Step 2: Run setup (optional but recommended)
```bash
bash setup.sh
```

### Step 3: Start the server
```bash
bash run.sh
```

## Access the Website

- **Main Site**: http://localhost:8080
- **Admin Panel**: http://localhost:8080/admin/dashboard.html

## Default Login

**Admin Account:**
- Username: `admin`
- Password: `admin123`

## Common Tasks

### Create a Customer Account
1. Go to http://localhost:8080
2. Click "Login" → "Sign Up"
3. Fill in the registration form
4. Start shopping!

### Add Products (Admin)
1. Login as admin
2. Go to Admin Dashboard
3. Click "Add Product"
4. Fill in product details
5. Save

### Process an Order (Customer)
1. Browse products
2. Click "Add to Cart"
3. View cart
4. Proceed to checkout
5. Fill shipping info
6. Place order

## Troubleshooting

### Server won't start?
```bash
# Make scripts executable
chmod +x run.sh setup.sh
chmod +x scripts/*.sh
chmod +x cgi-bin/*.sh

# Then try again
bash run.sh
```

### Database issues?
```bash
# Reinitialize database
bash scripts/init_db.sh
```

### Need help?
Check the full README.md for detailed documentation.

## Project Features

✓ User authentication & registration  
✓ Product catalog with categories  
✓ Shopping cart functionality  
✓ Checkout process  
✓ Order management  
✓ Admin dashboard  
✓ Responsive design  
✓ Search & filters  

## Technology

- **Frontend**: HTML, Tailwind CSS, JavaScript
- **Backend**: Bash scripts
- **Database**: SQLite
- **Server**: Python CGI

---

**Enjoy using Twilight! 🎨✨**
