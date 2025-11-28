<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="dashboard.aspx.cs" Inherits="Opton.Pages.Admin.dashboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --color-dark: #2C3639;
            --color-gray: #3F4E4F;
            --color-accent: #A27B5C;
            --color-light: #DCD7C9;
            --color-background: #f5f5f5;
        }

        .dashboard-container {
            width: 95%;
            margin: 20px auto;
            padding: 20px;
            background-color: var(--color-background);
        }

        .dashboard-title {
            font-size: 2em;
            font-weight: bold;
            margin-bottom: 30px;
            color: var(--color-dark);
        }

        .dashboard-row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .dashboard-card {
            background: #fff;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(44, 54, 57, 0.1);
            flex: 1;
            min-width: 300px;
            border-top: 3px solid var(--color-accent);
        }

        .dashboard-card.small {
            flex: 0 0 calc(33.333% - 14px);
            min-width: 250px;
        }

        .dashboard-card.large {
            flex: 0 0 calc(66.666% - 14px);
        }

        .card-title {
            font-size: 1.2em;
            font-weight: bold;
            margin-bottom: 15px;
            color: var(--color-gray);
        }

        .stat-number {
            font-size: 2.5em;
            font-weight: bold;
            color: var(--color-accent);
        }

        .chart-container {
            position: relative;
            height: 300px;
            margin-top: 10px;
        }

        .chart-container.small {
            height: 200px;
        }

        .filter-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .filter-section select {
            padding: 8px 12px;
            font-size: 14px;
            border-radius: 8px;
            border: 1px solid var(--color-light);
        }

        .btn-add {
            background-color: var(--color-accent);
            color: #fff;
            border-radius: 8px;
            padding: 10px 20px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s ease;
        }

        .btn-add:hover {
            background-color: var(--color-gray);
        }

        .staff-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }

        .staff-table th {
            background-color: var(--color-gray);
            color: #fff;
            padding: 12px;
            text-align: left;
            font-weight: bold;
            border-bottom: 2px solid var(--color-accent);
        }

        .staff-table td {
            padding: 10px 12px;
            border-bottom: 1px solid #eee;
        }

        .staff-table tr:hover {
            background-color: #f9f9f9;
        }

        .staff-table td[contenteditable="true"] {
            cursor: text;
        }

        .staff-table td[contenteditable="true"]:focus {
            outline: 2px solid var(--color-accent);
            background-color: #fffef0;
        }

        .staff-table select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        .btn-delete {
            background: none;
            border: none;
            color: #dc3545;
            cursor: pointer;
            font-size: 18px;
            transition: all 0.2s ease;
        }

        .btn-delete:hover {
            color: #a71d2a;
        }

        .new-row {
            background-color: #e7f3ff !important;
        }

        .validation-error {
            border: 2px solid #dc3545 !important;
        }

        .btn-save {
            background-color: var(--color-gray);
            color: #fff;
            border-radius: 8px;
            padding: 10px 20px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            margin-left: 10px;
            transition: all 0.2s ease;
        }

        .btn-save:hover {
            background-color: var(--color-dark);
        }

        .btn-save:disabled {
            background-color: #ccc;
            cursor: not-allowed;
            opacity: 0.6;
        }

        .loading {
            text-align: center;
            padding: 20px;
            color: var(--color-gray);
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        <h1 class="dashboard-title">Dashboard</h1>

        <!-- Row 1: Yearly Sales, Monthly Sales, Total Users -->
        <div class="dashboard-row">
            <div class="dashboard-card large">
                <div class="card-title">
                    Yearly Sales (RM)
                </div>
                <div class="chart-container">
                    <canvas id="yearlySalesChart"></canvas>
                </div>
            </div>
            <div class="dashboard-card small">
                <div class="card-title">
                    Monthly Sales (RM)
                </div>
                <div class="chart-container small">
                    <canvas id="monthlySalesChart"></canvas>
                </div>
            </div>
            <div class="dashboard-card small">
                <div class="card-title">Total Users</div>
                <div class="stat-number" id="totalUsersCount">-</div>
            </div>
        </div>

        <!-- Row 2: Best Sellers and Sales by Retailer -->
        <div class="dashboard-row">
            <div class="dashboard-card">
                <div class="card-title">
                    Best Sellers (Top 5)
                </div>
                <div class="chart-container small">
                    <canvas id="bestSellersChart"></canvas>
                </div>
            </div>
            <div class="dashboard-card">
                <div class="card-title">
                    Sales - R1
                </div>
                <div class="chart-container small">
                    <canvas id="salesR1Chart"></canvas>
                </div>
            </div>
            <div class="dashboard-card">
                <div class="card-title">
                    Sales - R2
                </div>
                <div class="chart-container small">
                    <canvas id="salesR2Chart"></canvas>
                </div>
            </div>
            <div class="dashboard-card">
                <div class="card-title">
                    Sales - R3
                </div>
                <div class="chart-container small">
                    <canvas id="salesR3Chart"></canvas>
                </div>
            </div>
        </div>

        <!-- Row 3: Staff Management -->
        <div class="dashboard-row">
            <div class="dashboard-card" style="flex: 1 1 100%;">
                <div class="card-title">Staff Management</div>
                <div class="filter-section">
                    <select id="retailerFilter">
                        <option value="">All Retailers</option>
                        <option value="R1">R1</option>
                        <option value="R2">R2</option>
                        <option value="R3">R3</option>
                    </select>
                    <div>
                        <button type="button" class="btn-save" id="saveStaffBtn" disabled>Save Changes</button>
                        <button type="button" class="btn-add" id="addStaffBtn">Add Staff</button>
                    </div>
                </div>
                <div id="staffTableContainer">
                    <p class="loading">Loading staff...</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        let orders = [];
        let staff = [];
        let users = [];
        let originalStaffData = {};
        let editedStaffData = {};
        const saveStaffBtn = document.getElementById('saveStaffBtn');
        const retailerFilter = document.getElementById('retailerFilter');

        // Hardcoded historical sales data
        const historicalSales = {
            2023: {
                total: 450000,
                monthly: [32000, 35000, 38000, 42000, 39000, 40000, 43000, 41000, 38000, 37000, 40000, 45000],
                R1: 150000,
                R2: 180000,
                R3: 120000
            },
            2024: {
                total: 520000,
                monthly: [38000, 41000, 44000, 47000, 45000, 48000, 50000, 49000, 46000, 44000, 48000, 52000],
                R1: 175000,
                R2: 210000,
                R3: 135000
            }
        };

        // Calculate sales from orders
        function calculateOrderTotal(order) {
            let total = 0;
            if (order.price && typeof order.price === 'object') {
                for (const [pid, p] of Object.entries(order.price)) {
                    const itemPrice = parseFloat(p.price) || 0;
                    const itemQty = parseInt(p.quantity) || 1;
                    total += itemPrice * itemQty;
                }
            }
            if (order.discount != null) {
                let discountAmount = 0;
                const discountStr = order.discount.toString();
                if (discountStr.includes('%')) {
                    const percent = parseFloat(discountStr.replace('%', '')) || 0;
                    discountAmount = (total * percent) / 100;
                } else {
                    discountAmount = parseFloat(discountStr) || 0;
                }
                total -= discountAmount;
            }
            return total < 0 ? 0 : total;
        }

        // Load orders data
        async function loadOrders() {
            try {
                const res = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: "getOrdersList" })
                });
                const data = await res.json();
                console.log('Orders response:', data);
                if (data.success && data.orders?.length) {
                    orders = data.orders;
                    renderCharts();
                } else {
                    console.error('No orders found');
                }
            } catch (err) {
                console.error('Error loading orders:', err);
            }
        }

        // Load users data
        async function loadUsers() {
            try {
                const res = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: "getUsersList" })
                });
                const data = await res.json();
                console.log('Users response:', data);
                if (data.success && data.users?.length) {
                    users = data.users;
                    document.getElementById('totalUsersCount').textContent = users.length;
                } else {
                    console.error('Failed to load users:', data.message);
                    document.getElementById('totalUsersCount').textContent = '0';
                }
            } catch (err) {
                console.error('Error loading users:', err);
                document.getElementById('totalUsersCount').textContent = '0';
            }
        }

        // Load staff data
        async function loadStaff() {
            const container = document.getElementById('staffTableContainer');
            container.innerHTML = '<p class="loading">Loading staff...</p>';
            try {
                const res = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: "getStaffList" })
                });
                const data = await res.json();
                console.log('Staff response:', data);
                if (data.success && data.staff?.length) {
                    staff = data.staff;
                    originalStaffData = {};
                    staff.forEach(s => originalStaffData[s.staffId] = JSON.parse(JSON.stringify(s)));
                    renderStaffTable(staff);
                } else {
                    container.innerHTML = '<p>No staff found.</p>';
                }
            } catch (err) {
                container.innerHTML = `<p>Error loading staff: ${err.message}</p>`;
            }
        }

        // Render all charts
        function renderCharts() {
            const currentYear = 2025;

            // Calculate 2025 sales from orders
            let sales2025 = { total: 0, monthly: new Array(12).fill(0), R1: 0, R2: 0, R3: 0 };
            let productSales = {}; // Track sales by product

            orders.forEach(order => {
                const orderDate = new Date(order.orderTime);
                const year = orderDate.getFullYear();
                const month = orderDate.getMonth();
                const total = calculateOrderTotal(order);

                if (year === currentYear) {
                    sales2025.total += total;
                    sales2025.monthly[month] += total;

                    const retailer = order.deliveredFrom;
                    if (retailer === 'R1') sales2025.R1 += total;
                    else if (retailer === 'R2') sales2025.R2 += total;
                    else if (retailer === 'R3') sales2025.R3 += total;

                    // Track product sales for best sellers
                    if (order.items && typeof order.items === 'object') {
                        for (const [productId, item] of Object.entries(order.items)) {
                            if (!productSales[productId]) {
                                productSales[productId] = { quantity: 0, revenue: 0 };
                            }

                            const quantity = (order.price?.[productId]?.quantity) || 1;
                            const itemRevenue = (order.price?.[productId]?.price || 0) * quantity;

                            productSales[productId].quantity += quantity;
                            productSales[productId].revenue += itemRevenue;
                        }
                    }
                }
            });

            // Log data sources
            console.log('📊 DASHBOARD DATA SOURCES:');
            console.log('Yearly Sales - 2023: Hardcoded (RM ' + historicalSales[2023].total + ')');
            console.log('Yearly Sales - 2024: Hardcoded (RM ' + historicalSales[2024].total + ')');
            console.log('Yearly Sales - 2025: From Orders DB (RM ' + sales2025.total.toFixed(2) + ', ' + orders.filter(o => new Date(o.orderTime).getFullYear() === 2025).length + ' orders)');
            console.log('Monthly Sales 2025: From Orders DB (' + orders.filter(o => new Date(o.orderTime).getFullYear() === 2025).length + ' orders)');
            console.log('Best Sellers: From Orders DB (' + Object.keys(productSales).length + ' unique products)');
            console.log('Retailer Sales R1 - 2023/2024: Hardcoded, 2025: From Orders DB (RM ' + sales2025.R1.toFixed(2) + ')');
            console.log('Retailer Sales R2 - 2023/2024: Hardcoded, 2025: From Orders DB (RM ' + sales2025.R2.toFixed(2) + ')');
            console.log('Retailer Sales R3 - 2023/2024: Hardcoded, 2025: From Orders DB (RM ' + sales2025.R3.toFixed(2) + ')');

            // Yearly Sales Chart
            const yearlySalesCtx = document.getElementById('yearlySalesChart').getContext('2d');
            new Chart(yearlySalesCtx, {
                type: 'bar',
                data: {
                    labels: ['2023', '2024', '2025'],
                    datasets: [{
                        label: 'Yearly Sales (RM)',
                        data: [historicalSales[2023].total, historicalSales[2024].total, sales2025.total],
                        backgroundColor: ['#A27B5C', '#3F4E4F', '#2C3639']
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });

            // Monthly Sales Chart (Current Year)
            const monthlySalesCtx = document.getElementById('monthlySalesChart').getContext('2d');
            new Chart(monthlySalesCtx, {
                type: 'line',
                data: {
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                    datasets: [{
                        label: '2025 Monthly Sales',
                        data: sales2025.monthly,
                        borderColor: '#A27B5C',
                        backgroundColor: 'rgba(162, 123, 92, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });

            // Best Sellers Chart
            const sortedProducts = Object.entries(productSales)
                .sort((a, b) => b[1].quantity - a[1].quantity)
                .slice(0, 5);

            const bestSellersCtx = document.getElementById('bestSellersChart').getContext('2d');
            new Chart(bestSellersCtx, {
                type: 'bar',
                data: {
                    labels: sortedProducts.map(p => p[0]),
                    datasets: [{
                        label: 'Units Sold',
                        data: sortedProducts.map(p => p[1].quantity),
                        backgroundColor: '#A27B5C'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: 'y',
                    scales: {
                        x: { beginAtZero: true }
                    }
                }
            });

            // Sales by Retailer Charts
            const retailerCharts = [
                { id: 'salesR1Chart', label: 'R1', data: [historicalSales[2023].R1, historicalSales[2024].R1, sales2025.R1] },
                { id: 'salesR2Chart', label: 'R2', data: [historicalSales[2023].R2, historicalSales[2024].R2, sales2025.R2] },
                { id: 'salesR3Chart', label: 'R3', data: [historicalSales[2023].R3, historicalSales[2024].R3, sales2025.R3] }
            ];

            retailerCharts.forEach(chart => {
                const ctx = document.getElementById(chart.id).getContext('2d');
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['2023', '2024', '2025'],
                        datasets: [{
                            data: chart.data,
                            backgroundColor: ['#A27B5C', '#3F4E4F', '#2C3639']
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false
                    }
                });
            });
        }

        // Render staff table
        function renderStaffTable(data) {
            const container = document.getElementById('staffTableContainer');

            const filterValue = retailerFilter.value.toLowerCase();
            const filteredData = data.filter(s => {
                if (!filterValue) return true;
                const storeIds = (s.storeId || '').toLowerCase().split(',').map(id => id.trim());
                return storeIds.includes(filterValue);
            });

            if (!filteredData.length) {
                container.innerHTML = '<p>No staff found.</p>';
                return;
            }

            let tableHTML = `
                <table class="staff-table">
                    <thead>
                        <tr>
                            <th>Staff ID</th>
                            <th>User ID</th>
                            <th>Email</th>
                            <th>Name</th>
                            <th>Phone No</th>
                            <th>Store ID</th>
                            <th>Role</th>
                            <th>Added On</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="staffTableBody">
            `;

            filteredData.forEach(s => {
                const isNew = !s.staffId;
                tableHTML += `
                    <tr data-staff-id="${s.staffId || ''}" ${isNew ? 'class="new-row"' : ''}>
                        <td>${s.staffId || 'NEW'}</td>
                        <td contenteditable="true" data-field="userId">${s.userId || ''}</td>
                        <td contenteditable="true" data-field="email">${s.email || ''}</td>
                        <td contenteditable="true" data-field="name">${s.name || ''}</td>
                        <td contenteditable="true" data-field="phoneNo">${s.phoneNo || ''}</td>
                        <td contenteditable="true" data-field="storeId">${s.storeId || ''}</td>
                        <td data-field="role">
                            <select class="role-select">
                                <option value="Staff" ${s.role === 'Staff' ? 'selected' : ''}>Staff</option>
                                <option value="Admin" ${s.role === 'Admin' ? 'selected' : ''}>Admin</option>
                            </select>
                        </td>
                        <td>${s.addedOn || ''}</td>
                        <td><button class="btn-delete" onclick="deleteStaff('${s.staffId || ''}')"><i class="ri-delete-bin-line"></i></button></td>
                    </tr>
                `;
            });

            tableHTML += '</tbody></table>';
            container.innerHTML = tableHTML;

            // Add event listeners for editable cells
            document.querySelectorAll('.staff-table td[contenteditable="true"]').forEach(cell => {
                cell.addEventListener('blur', handleCellEdit);
                cell.addEventListener('keydown', (e) => {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        cell.blur();
                    }
                });
            });

            // Add event listeners for role dropdowns
            document.querySelectorAll('.role-select').forEach(select => {
                select.addEventListener('change', (e) => {
                    const row = e.target.closest('tr');
                    const staffId = row.getAttribute('data-staff-id');
                    const newValue = e.target.value;

                    const original = originalStaffData[staffId]?.role || '';
                    if (original !== newValue) {
                        editedStaffData[staffId] = editedStaffData[staffId] || {};
                        editedStaffData[staffId].role = newValue;
                    } else {
                        if (editedStaffData[staffId]) {
                            delete editedStaffData[staffId].role;
                            if (Object.keys(editedStaffData[staffId]).length === 0) {
                                delete editedStaffData[staffId];
                            }
                        }
                    }
                    saveStaffBtn.disabled = Object.keys(editedStaffData).length === 0;
                });
            });
        }

        // Handle cell editing
        function handleCellEdit(e) {
            const cell = e.target;
            const row = cell.closest('tr');
            const staffId = row.getAttribute('data-staff-id');
            const field = cell.getAttribute('data-field');
            const newValue = cell.textContent.trim();

            // Remove any previous validation errors
            cell.classList.remove('validation-error');

            // Check if value changed
            const original = originalStaffData[staffId]?.[field] || '';
            if (original.toString().trim() !== newValue) {
                editedStaffData[staffId] = editedStaffData[staffId] || {};
                editedStaffData[staffId][field] = newValue;
            } else {
                if (editedStaffData[staffId]) {
                    delete editedStaffData[staffId][field];
                    if (Object.keys(editedStaffData[staffId]).length === 0) {
                        delete editedStaffData[staffId];
                    }
                }
            }

            saveStaffBtn.disabled = Object.keys(editedStaffData).length === 0;
        }

        // Validation functions
        function validateEmail(email) {
            if (!email) return false;
            return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
        }

        function validatePhone(phone) {
            if (!phone) return false;
            return /^60\d{9,10}$/.test(phone);
        }

        function validateStaffData(staffData) {
            const errors = [];

            if (!staffData.email || !validateEmail(staffData.email)) {
                errors.push('Valid email is required');
            }

            if (!staffData.name || staffData.name.trim() === '') {
                errors.push('Name is required');
            }

            if (!staffData.phoneNo || staffData.phoneNo.trim() === '') {
                errors.push('Phone number is required');
            } else if (!validatePhone(staffData.phoneNo)) {
                errors.push('Phone number must be in format 60XXXXXXXXX');
            }

            if (!staffData.storeId || staffData.storeId.trim() === '') {
                errors.push('Store ID is required');
            }

            if (!staffData.role || staffData.role.trim() === '') {
                errors.push('Role is required');
            }

            return errors;
        }

        // Add new staff row
        document.getElementById('addStaffBtn').onclick = () => {
            const newStaff = {
                staffId: '',
                userId: '',
                email: '',
                name: '',
                phoneNo: '',
                storeId: '',
                role: 'Staff',
                addedOn: new Date().toLocaleDateString('en-US')
            };
            staff.unshift(newStaff);
            editedStaffData[''] = newStaff;
            saveStaffBtn.disabled = false;
            renderStaffTable(staff);
        };

        // Delete staff
        function deleteStaff(staffId) {
            if (!confirm('Are you sure you want to delete this staff member?')) return;

            staff = staff.filter(s => s.staffId !== staffId);
            delete editedStaffData[staffId];
            delete originalStaffData[staffId];
            renderStaffTable(staff);

            // If it's an existing staff, mark for deletion
            if (staffId) {
                editedStaffData[staffId] = { _deleted: true };
                saveStaffBtn.disabled = false;
            }
        }

        // Save staff changes
        saveStaffBtn.onclick = async () => {
            if (!confirm('Are you sure you want to save changes?')) return;

            try {
                // Process each change individually
                for (const staffId in editedStaffData) {
                    if (editedStaffData[staffId]._deleted) {
                        // Delete staff
                        const res = await fetch('/Handlers/db_handler.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({
                                action: "deleteStaff",
                                staffId: staffId
                            })
                        });
                        const result = await res.json();
                        if (!result.success) {
                            throw new Error(`Failed to delete staff ${staffId}: ${result.message}`);
                        }
                    } else if (!staffId) {
                        // New staff - get all values from the row
                        const row = document.querySelector(`tr[data-staff-id=""]`);
                        if (row) {
                            const staffData = {
                                action: "addStaff",
                                userId: row.querySelector('[data-field="userId"]')?.textContent.trim() || '',
                                email: row.querySelector('[data-field="email"]')?.textContent.trim() || '',
                                name: row.querySelector('[data-field="name"]')?.textContent.trim() || '',
                                phoneNo: row.querySelector('[data-field="phoneNo"]')?.textContent.trim() || '',
                                storeId: row.querySelector('[data-field="storeId"]')?.textContent.trim() || '',
                                role: row.querySelector('.role-select')?.value || 'Staff'
                            };

                            const errors = validateStaffData(staffData);
                            if (errors.length > 0) {
                                alert('Please fix the following errors:\n' + errors.join('\n'));
                                return;
                            }

                            const res = await fetch('/Handlers/db_handler.ashx', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify(staffData)
                            });
                            const result = await res.json();
                            if (!result.success) {
                                throw new Error(`Failed to add staff: ${result.message}`);
                            }
                        }
                    } else {
                        // Update existing staff
                        const staffData = {
                            action: "updateStaff",
                            staffId: staffId,
                            ...originalStaffData[staffId],
                            ...editedStaffData[staffId]
                        };

                        const errors = validateStaffData(staffData);
                        if (errors.length > 0) {
                            alert('Please fix the following errors for staff ' + staffId + ':\n' + errors.join('\n'));
                            return;
                        }

                        const res = await fetch('/Handlers/db_handler.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify(staffData)
                        });
                        const result = await res.json();
                        if (!result.success) {
                            throw new Error(`Failed to update staff ${staffId}: ${result.message}`);
                        }
                    }
                }

                // Success - reset and reload
                editedStaffData = {};
                saveStaffBtn.disabled = true;
                await loadStaff();

                if (typeof showToast === 'function') {
                    showToast("Staff changes saved successfully!");
                } else {
                    alert("Staff changes saved successfully!");
                }
            } catch (err) {
                alert("Error saving changes: " + err.message);
            }
        };

        // Event listeners
        retailerFilter.addEventListener('change', () => renderStaffTable(staff));

        // Load all data on page load
        loadOrders();
        loadUsers();
        loadStaff();
    </script>
</asp:Content>