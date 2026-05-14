# 🎯 Twilight - Complete Installation & Usage Guide

## ✅ What You've Got

A **complete, professional e-commerce platform** with:
- Beautiful responsive website (Tailwind CSS)
- Functional shopping cart
- User authentication & registration  
- Admin dashboard for product management
- SQLite database with sample products
- Bash backend scripts
- Complete security features

---

## 🚀 Quick Start (3 Steps)

### For Windows Users:

#### Step 1: Open Git Bash or Command Prompt
```bash
cd "d:\os project\Twilight"
```

#### Step 2: Initialize Database (First Time Only)
If you have SQLite3 installed:
```bash
bash scripts/init_db.sh
```

If you don't have SQLite3, download it from: https://www.sqlite.org/download.html

#### Step 3: Start Server
```bash
# Using Bash:
bash run.sh

# Or using Windows batch file:
run.bat
```

### For Linux/Mac Users:

```bash
cd /path/to/Twilight
chmod +x setup.sh run.sh scripts/*.sh
bash setup.sh
bash run.sh
```

---

## 🌐 Access the Platform

Once the server is running:

- **Main Website**: http://localhost:8080
- **Product Catalog**: http://localhost:8080/products.html
- **Admin Dashboard**: http://localhost:8080/admin/dashboard.html

---

## 🔑 Default Login Credentials

### Admin Account
- **Username**: `admin`
- **Password**: `admin123`
- **Access**: Full admin panel access

⚠️ **Important**: Change this password after first login!

---

## 📖 Step-by-Step User Guide

### For Customers:

#### 1. Create an Account
1. Click "Login" in top navigation
2. Click "Sign Up" link
3. Fill in:
   - Full Name
   - Username (3-20 characters)
   - Email
   - Password (minimum 6 characters)
4. Click "Create Account"

#### 2. Browse Products
1. Go to "Shop" or click "Shop Now"
2. Use filters on left sidebar:
   - Search by name
   - Filter by category
   - Filter by price range
3. Sort products:
   - Newest First
   - Price: Low to High
   - Price: High to Low
   - Name: A to Z

#### 3. View Product Details
1. Click any product card
2. See full description and details
3. Select quantity
4. Click "Add to Cart"

#### 4. Manage Shopping Cart
1. Click cart icon (top right)
2. View all items
3. Update quantities using +/- buttons
4. Remove items with trash icon
5. See total price update in real-time

#### 5. Checkout
1. Click "Proceed to Checkout" from cart
2. Fill in shipping information:
   - Full Name
   - Phone Number
   - Email
   - Complete Address
3. Select payment method (Cash on Delivery)
4. Click "Place Order"
5. You'll see order confirmation with Order ID

---

### For Administrators:

#### 1. Login to Admin Panel
1. Go to http://localhost:8080/admin/dashboard.html
2. Login with admin credentials
3. You'll see the dashboard with stats

#### 2. View Dashboard Statistics
- Total Products count
- Total Orders placed
- Total Customers registered
- Total Revenue generated

#### 3. Manage Products

**Add New Product:**
1. Click "Add Product" button
2. Fill in product details:
   - Product Name
   - Description
   - Price (in dollars)
   - Stock quantity
   - Category (select from dropdown)
   - Image filename (e.g., product1.jpg)
3. Click "Save Product"

**Edit Product:**
1. Find product in list
2. Click edit icon (pencil)
3. Modify any fields
4. Click "Save Product"

**Delete Product:**
1. Find product in list
2. Click delete icon (trash)
3. Confirm deletion

#### 4. View Orders
1. Click "Orders" tab
2. See all customer orders with:
   - Order ID
   - Customer username
   - Total amount
   - Order status
   - Order date

---

## 🎨 Customization Guide

### Change Website Colors

1. Open any HTML file
2. Find `purple-600` class
3. Replace with your color:
   - `blue-600` for blue
   - `red-600` for red
   - `green-600` for green
   - `pink-600` for pink
   - Any Tailwind color

### Add Your Product Images

1. Place images in: `frontend/images/`
2. Recommended size: 800x800px
3. Formats: JPG, PNG
4. Use filenames when adding products

### Edit Sample Products

Option 1 - Via Admin Panel:
- Login as admin
- Edit products directly

Option 2 - Via Database:
```bash
sqlite3 database/twilight.db
SELECT * FROM products;
UPDATE products SET name='New Name' WHERE id=1;
.quit
```

### Change Website Text

Edit these files:
- `frontend/index.html` - Homepage
- `frontend/products.html` - Product page
- Other HTML files as needed

---

## 🛠 Troubleshooting

### Problem: "Command not found: bash"
**Solution**: 
- Windows: Install Git Bash from https://git-scm.com/
- Or use Command Prompt and run `run.bat`

### Problem: "sqlite3: command not found"
**Solution**:
- Download SQLite from: https://www.sqlite.org/download.html
- Windows: Extract to C:\sqlite and add to PATH
- Linux: `sudo apt-get install sqlite3`
- Mac: `brew install sqlite3`

### Problem: "Python not found"
**Solution**:
- Download Python 3.x from https://www.python.org/
- During installation, check "Add Python to PATH"

### Problem: Port 8080 already in use
**Solution**:
- Change port in `run.sh`: Change `PORT=8080` to `PORT=3000`
- Or stop the application using port 8080

### Problem: Can't login
**Solution**:
- Make sure database is initialized: `bash scripts/init_db.sh`
- Use correct default credentials (admin/admin123)
- Check browser console for errors (F12)

### Problem: Products not showing
**Solution**:
- Check if database exists: `ls database/`
- Reinitialize: `bash scripts/init_db.sh`
- Check browser console (F12) for API errors

### Problem: Cart not working
**Solution**:
- Make sure you're logged in
- Check session token in localStorage (F12 > Application > Local Storage)
- Clear browser cache and try again

---

## 🔧 Advanced Configuration

### Change Server Port

Edit `run.sh`:
```bash
PORT=3000  # Change from 8080 to your preferred port
```

### Database Location

Default: `database/twilight.db`

To change, edit all scripts and update:
```bash
DB_FILE="your/new/path/twilight.db"
```

### Session Timeout

Edit `scripts/utils.sh`:
```bash
# Change from 86400 (24 hours) to your value in seconds
if [ $age -lt 43200 ]; then  # 12 hours
```

---

## 📊 Database Management

### View Database Contents

```bash
sqlite3 database/twilight.db

# View all products
SELECT * FROM products;

# View all users
SELECT id, username, email, role FROM users;

# View all orders
SELECT * FROM orders;

# Exit
.quit
```

### Backup Database

```bash
cp database/twilight.db database/backup_$(date +%Y%m%d).db
```

### Reset Database

```bash
rm database/twilight.db
bash scripts/init_db.sh
```

---

## 🧪 Testing Guide

### Test Customer Workflow:
1. ✓ Register new account
2. ✓ Login with credentials
3. ✓ Browse and search products
4. ✓ Add products to cart
5. ✓ Update cart quantities
6. ✓ Remove items from cart
7. ✓ Proceed to checkout
8. ✓ Complete order

### Test Admin Workflow:
1. ✓ Login as admin
2. ✓ View dashboard statistics
3. ✓ Add new product
4. ✓ Edit existing product
5. ✓ Delete product
6. ✓ View orders

---

## 📝 File Descriptions

| File/Folder | Purpose |
|------------|---------|
| `frontend/` | All website HTML pages |
| `scripts/` | Backend Bash scripts |
| `database/` | SQLite database storage |
| `cgi-bin/` | CGI API router |
| `sessions/` | User session files |
| `run.sh` | Server launcher (Unix/Linux/Mac) |
| `run.bat` | Server launcher (Windows) |
| `setup.sh` | Initial setup script |
| `README.md` | Full documentation |
| `QUICKSTART.md` | Quick start guide |
| `PROJECT_SUMMARY.md` | Project overview |

---

## 🎓 Learning Resources

### Bash Scripting
- Official Bash Guide: https://www.gnu.org/software/bash/manual/
- Learn Shell: https://www.learnshell.org/

### SQLite
- SQLite Tutorial: https://www.sqlitetutorial.net/
- Official Docs: https://www.sqlite.org/docs.html

### Tailwind CSS
- Documentation: https://tailwindcss.com/docs
- Components: https://tailwindui.com/components

### JavaScript
- MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/JavaScript

---

## 🤝 Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review browser console (F12) for errors
3. Check `twilight.log` file for server errors
4. Ensure all prerequisites are installed

---

## ✨ Features Summary

✅ User registration and authentication  
✅ Product catalog with categories  
✅ Advanced search and filters  
✅ Shopping cart management  
✅ Secure checkout process  
✅ Order history and tracking  
✅ Admin dashboard  
✅ Product management (CRUD)  
✅ Responsive design  
✅ Professional UI/UX  
✅ Password security (SHA-256)  
✅ Session management  
✅ Input validation  
✅ SQL injection prevention  

---

## 🎉 You're All Set!

Your Twilight e-commerce platform is ready to use!

**To start**: Run `bash run.sh` and visit http://localhost:8080

**Have fun selling handmade products!** 🛍️✨

---

*Last updated: November 23, 2025*
