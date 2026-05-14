/**
 * Main JavaScript file for Twilight E-Commerce Platform
 * Handles authentication, cart management, and common functionality
 */

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    updateUserNav();
    updateCartCount();
});

/**
 * Update user navigation based on authentication status
 */
function updateUserNav() {
    const userNav = document.getElementById('userNav');
    if (!userNav) return;
    
    const token = localStorage.getItem('token');
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    
    if (token && user.username) {
        userNav.innerHTML = `
            <div class="flex items-center space-x-4">
                <span class="text-gray-700">Hello, <strong>${user.username}</strong></span>
                ${user.role === 'admin' ? 
                    '<a href="admin/dashboard.html" class="text-purple-600 hover:text-purple-700 font-medium">Admin Panel</a>' : 
                    '<a href="orders.html" class="text-gray-700 hover:text-purple-600 font-medium">My Orders</a>'}
                <button onclick="logout()" class="bg-red-500 text-white px-6 py-2 rounded-full hover:bg-red-600 transition font-medium">
                    Logout
                </button>
            </div>
        `;
    } else {
        userNav.innerHTML = `
            <a href="login.html" class="bg-purple-600 text-white px-6 py-2 rounded-full hover:bg-purple-700 transition font-medium">
                Login
            </a>
        `;
    }
}

/**
 * Update cart count badge
 */
async function updateCartCount() {
    const cartCountEl = document.getElementById('cartCount');
    if (!cartCountEl) return;
    
    const token = localStorage.getItem('token');
    if (!token) {
        cartCountEl.textContent = '0';
        return;
    }
    
    try {
        const response = await fetch(`/cgi-bin/api.sh?action=cart_handler&token=${token}&action=count`);
        const data = await response.json();
        
        if (data.success) {
            cartCountEl.textContent = data.count || '0';
            localStorage.setItem('cartCount', data.count || '0');
        }
    } catch (error) {
        console.error('Error updating cart count:', error);
        cartCountEl.textContent = '0';
    }
}

/**
 * Logout user
 */
async function logout() {
    const token = localStorage.getItem('token');
    
    if (token) {
        try {
            await fetch(`/cgi-bin/api.sh?action=logout&token=${token}`);
        } catch (error) {
            console.error('Logout error:', error);
        }
    }
    
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    localStorage.removeItem('cartCount');
    
    window.location.href = 'index.html';
}

/**
 * Format currency
 */
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(amount);
}

/**
 * Show notification
 */
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 z-50 px-6 py-4 rounded-lg shadow-lg text-white ${
        type === 'success' ? 'bg-green-500' : 
        type === 'error' ? 'bg-red-500' : 
        'bg-blue-500'
    }`;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

/**
 * Check if user is authenticated
 */
function isAuthenticated() {
    return !!localStorage.getItem('token');
}

/**
 * Check if user is admin
 */
function isAdmin() {
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    return user.role === 'admin';
}

/**
 * Require authentication
 */
function requireAuth(redirectUrl = 'login.html') {
    if (!isAuthenticated()) {
        window.location.href = redirectUrl;
        return false;
    }
    return true;
}

/**
 * Require admin access
 */
function requireAdmin(redirectUrl = 'index.html') {
    if (!isAdmin()) {
        window.location.href = redirectUrl;
        return false;
    }
    return true;
}

/**
 * Debounce function
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Format date
 */
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}
