<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="orders.aspx.cs" Inherits="Opton.Pages.Worker.orders" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <style>
        :root {
            --color-dark: #333;
        }

        #searchContainer {
            text-align: center;
            margin: 30px 0 15px 0;
        }

        #searchWrapper {
            position: relative;
            display: inline-block;
        }

        #searchBar {
            padding: 10px 36px 10px 12px;
            width: 320px;
            font-size: 14px;
            border-radius: 12px;
            border: 1px solid #ccc;
            outline: none;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: all 0.2s ease;
        }

            #searchBar:focus {
                border-color: #888;
                box-shadow: 0 2px 6px rgba(0,0,0,0.2);
            }

        #searchIcon {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 18px;
            color: #888;
            pointer-events: none;
        }

        #buttonsContainer {
            width: 90%;
            margin: 0 auto 10px auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        #buttonsLeft {
            display: flex;
            gap: 10px;
        }

        #buttonsLeft select {
            padding: 6px 12px;
            font-size: 14px;
            border-radius: 8px;
        }

        #buttonsRight button {
            margin-left: 8px;
            background-color: var(--color-accent, #007bff);
            color: #fff;
            border-radius: 12px;
            padding: 8px 16px;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }

            #buttonsRight button:disabled {
                background-color: #ccc;
                cursor: not-allowed;
                opacity: 0.6;
            }

        #ordersGrid {
            width: 90%;
            margin: 0 auto 30px auto;
        }

        .order-card {
            border: 1px solid #ccc;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            background: #fff;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            position: relative;
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }

        .order-id {
            font-size: 1.4em;
            font-weight: bold;
            color: var(--color-dark);
        }

        .order-status {
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            min-width: 140px;
            text-align: center;
            font-size: 14px;
        }

        .status-Ordered {
            background-color: #AED6F1;
            color: #03396C;
        }

        .status-Packed {
            background-color: #fff0b3;
            color: #8a6d3b;
        }

        .status-InTransit {
            background-color: #ffd699;
            color: #e67e22;
        }

        .status-OutForDelivery {
            background-color: #d4f0d4;
            color: #27ae60;
        }

        .status-Delivered {
            background-color: #b3e6b3;
            color: #2e8b57;
        }

        .status-RefundReturn {
            background-color: #f5cccc;
            color: #c0392b;
        }

        .order-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 15px;
        }

        .order-section {
            margin-bottom: 15px;
        }

        .section-title {
            font-weight: bold;
            color: var(--color-dark);
            margin-bottom: 8px;
            font-size: 16px;
        }

        .customer-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 15px;
        }

        .items-list {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
        }

        .item-card {
            background: white;
            padding: 12px;
            margin-bottom: 10px;
            border-radius: 6px;
            border-left: 4px solid var(--color-accent);
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .item-header {
            display: flex;
            justify-content: space-between;
            font-weight: bold;
            margin-bottom: 8px;
            color: var(--color-dark);
        }

        .item-details {
            font-size: 14px;
            color: #666;
        }

        .item-details > div {
            padding: 3px 0;
        }

        .item-details strong {
            color: #333;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
            padding: 2px 0;
        }

        .editable-field {
            border-bottom: 1px dotted #888;
            cursor: text;
            padding: 2px 4px;
            min-width: 80px;
            display: inline-block;
        }

        .editable-field:focus {
            outline: none;
            background: #ffffcc;
            border-bottom: 1px solid #007bff;
        }

        .empty-field {
            color: #999;
            font-style: italic;
        }

        .price-summary {
            background: #e8f4fd;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
        }

        .total-row {
            font-size: 18px;
            font-weight: bold;
            color: var(--color-dark);
            padding-top: 10px;
            border-top: 2px solid #ccc;
            margin-top: 10px;
        }

        @media (max-width: 768px) {
            .order-details {
                grid-template-columns: 1fr;
            }
            
            .order-header {
                flex-direction: column;
                gap: 10px;
            }
            
            .order-status {
                align-self: flex-start;
            }
            
            #buttonsLeft {
                flex-direction: column;
                gap: 5px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div id="searchContainer">
        <div id="searchWrapper">
            <input type="text" id="searchBar" placeholder="Search orders..." />
            <i id="searchIcon" class="ri-search-line"></i>
        </div>
    </div>

    <div id="buttonsContainer">
        <div id="buttonsLeft">
            <select id="statusFilter">
                <option value="">All Statuses</option>
                <option value="Ordered">Ordered</option>
                <option value="Packed">Packed</option>
                <option value="In Transit">In Transit</option>
                <option value="Out for Delivery">Out for Delivery</option>
                <option value="Delivered">Delivered</option>
                <option value="Returned">Refund/Return</option>
            </select>
            <select id="sortOrder">
                <option value="latest">Sort: Latest First</option>
                <option value="oldest">Sort: Oldest First</option>
            </select>
        </div>
        <div id="buttonsRight">
            <button type="button" id="saveChangesBtn" disabled>Save Changes</button>
        </div>
    </div>

    <div id="ordersGrid">
        <p>Loading orders...</p>
    </div>

    <script>
        let orders = [];
        let originalData = {};
        let editedData = {};
        const saveBtn = document.getElementById('saveChangesBtn');
        const statusFilter = document.getElementById('statusFilter');
        const searchBar = document.getElementById('searchBar');
        const sortOrder = document.getElementById('sortOrder');

        // Helper function to format date
        function formatDate(dateValue) {
            if (!dateValue) return 'Not set';

            try {
                let date;
                if (dateValue.seconds) {
                    // Firestore timestamp
                    date = new Date(dateValue.seconds * 1000);
                } else if (typeof dateValue === 'string') {
                    date = new Date(dateValue);
                } else {
                    date = new Date(dateValue);
                }

                if (isNaN(date.getTime())) return 'Invalid date';

                return date.toLocaleString('en-MY', {
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                });
            } catch (e) {
                return 'Invalid date';
            }
        }

        // Helper function to format currency
        function formatCurrency(amount) {
            return `RM ${parseFloat(amount || 0).toFixed(2)}`;
        }

        // Calculate order total
        function calculateOrderTotal(order) {
            let total = 0;

            if (order.price && typeof order.price === 'object') {
                Object.values(order.price).forEach(itemPrice => {
                    const price = parseFloat(itemPrice.price || 0);
                    const quantity = parseInt(itemPrice.quantity || 1);
                    total += price * quantity;
                });
            }

            // Apply discount
            if (order.discount) {
                const discount = parseFloat(order.discount) || 0;
                total -= discount;
            }

            return total > 0 ? total : 0;
        }

        // Parse prescription data
        function parsePrescription(prescription) {
            if (!prescription || typeof prescription !== 'object') return '';

            console.log('Prescription data:', prescription); // Debug log

            const parts = [];

            // Handle different prescription structures
            if (prescription.Near && typeof prescription.Near === 'object') {
                const left = prescription.Near.left || prescription.Near.Left || 'N/A';
                const right = prescription.Near.right || prescription.Near.Right || 'N/A';
                parts.push(`Near: L ${left} | R ${right}`);
            }

            if (prescription.Reading && typeof prescription.Reading === 'object') {
                const left = prescription.Reading.left || prescription.Reading.Left || 'N/A';
                const right = prescription.Reading.right || prescription.Reading.Right || 'N/A';
                parts.push(`Reading: L ${left} | R ${right}`);
            }

            if (prescription.Distance && typeof prescription.Distance === 'object') {
                const left = prescription.Distance.left || prescription.Distance.Left || 'N/A';
                const right = prescription.Distance.right || prescription.Distance.Right || 'N/A';
                parts.push(`Distance: L ${left} | R ${right}`);
            }

            // Handle manual prescription format (from checkout)
            if (prescription.leftEye && typeof prescription.leftEye === 'object') {
                const leftSphere = prescription.leftEye.sphere || 'N/A';
                const leftCylinder = prescription.leftEye.cylinder || 'N/A';
                const leftAxis = prescription.leftEye.axis || 'N/A';
                parts.push(`Left: SPH ${leftSphere} CYL ${leftCylinder} AXIS ${leftAxis}`);
            }

            if (prescription.rightEye && typeof prescription.rightEye === 'object') {
                const rightSphere = prescription.rightEye.sphere || 'N/A';
                const rightCylinder = prescription.rightEye.cylinder || 'N/A';
                const rightAxis = prescription.rightEye.axis || 'N/A';
                parts.push(`Right: SPH ${rightSphere} CYL ${rightCylinder} AXIS ${rightAxis}`);
            }

            if (prescription.pd) {
                parts.push(`PD: ${prescription.pd}`);
            }

            return parts.length > 0 ? parts.join(' | ') : 'No prescription data';
        }

        // Load orders from server
        async function loadOrders() {
            const contentDiv = document.getElementById('ordersGrid');
            contentDiv.innerHTML = '<p>Loading orders...</p>';

            try {
                const res = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: "getOrdersList" })
                });

                const data = await res.json();
                console.log('Orders data:', data); // Debug log

                if (!data.success || !data.orders?.length) {
                    contentDiv.innerHTML = '<p>No orders found.</p>';
                    return;
                }

                orders = data.orders;
                originalData = {};
                orders.forEach(o => {
                    originalData[o.orderId] = JSON.parse(JSON.stringify(o));
                });

                renderOrderCards(orders);
            } catch (err) {
                console.error('Error loading orders:', err);
                contentDiv.innerHTML = `<p>Error loading orders: ${err.message}</p>`;
            }
        }

        // Check if field has changes
        function hasChanges(orderId, field, newValue) {
            const original = originalData[orderId]?.[field] || '';
            return original.toString().trim() !== newValue.trim();
        }

        // Render order cards
        function renderOrderCards(data) {
            const container = document.getElementById('ordersGrid');
            container.innerHTML = '';

            const searchTerm = searchBar.value.trim().toLowerCase();
            const filterVal = statusFilter.value;
            const sortVal = sortOrder.value;

            let filteredData = data.filter(order => {
                // Status filter
                if (filterVal && order.status !== filterVal) return false;

                // Search filter
                if (!searchTerm) return true;

                const searchFields = [
                    order.orderId,
                    order.name,
                    order.email,
                    order.phoneNo,
                    order.address,
                    order.trackingNo,
                    order.paymentType
                ];

                return searchFields.some(field =>
                    field && field.toString().toLowerCase().includes(searchTerm)
                );
            });

            // Sort data by order time
            filteredData.sort((a, b) => {
                const dateA = new Date(a.orderTime);
                const dateB = new Date(b.orderTime);
                return sortVal === 'latest' ? dateB - dateA : dateA - dateB;
            });

            if (!filteredData.length) {
                container.innerHTML = '<p>No orders found.</p>';
                return;
            }

            filteredData.forEach(order => {
                const card = document.createElement('div');
                card.className = 'order-card';

                // Determine status class
                let statusClass = '';
                const status = (order.status || '').toLowerCase();
                switch (status) {
                    case 'ordered':
                    case 'paid':
                        statusClass = 'status-Ordered';
                        break;
                    case 'packed':
                    case 'processing':
                        statusClass = 'status-Packed';
                        break;
                    case 'in transit':
                    case 'shipped':
                        statusClass = 'status-InTransit';
                        break;
                    case 'out for delivery':
                        statusClass = 'status-OutForDelivery';
                        break;
                    case 'delivered':
                    case 'completed':
                        statusClass = 'status-Delivered';
                        break;
                    case 'returned':
                    case 'refunded':
                    case 'cancelled':
                        statusClass = 'status-RefundReturn';
                        break;
                    default:
                        statusClass = 'status-Ordered';
                }

                // Create editable field
                const makeEditable = (field, value, type = 'text') => {
                    const isEmpty = !value || value.toString().trim() === '';

                    if (type === 'datetime') {
                        let dtValue = '';
                        if (value) {
                            let date;
                            if (value.seconds) {
                                date = new Date(value.seconds * 1000);
                            } else {
                                date = new Date(value);
                            }
                            if (!isNaN(date.getTime())) {
                                dtValue = date.toISOString().slice(0, 16);
                            }
                        }
                        return `<input class="editable-field" data-field="${field}" type="datetime-local" value="${dtValue}">`;
                    } else if (type === 'select') {
                        const options = {
                            status: ['Ordered', 'Packed', 'In Transit', 'Out for Delivery', 'Delivered', 'Returned'],
                            deliveredFrom: ['R1', 'R2', 'R3', 'Main']
                        }[field] || [];

                        let optsHtml = options.map(opt =>
                            `<option value="${opt}" ${opt === value ? 'selected' : ''}>${opt}</option>`
                        ).join('');
                        return `<select class="editable-field" data-field="${field}">${optsHtml}</select>`;
                    } else {
                        const displayValue = isEmpty ? 'Click to edit' : value;
                        return `<span class="editable-field ${isEmpty ? 'empty-field' : ''}" data-field="${field}" contenteditable="true">${displayValue}</span>`;
                    }
                };

                // Build items HTML
                let itemsHTML = '';
                if (order.items && typeof order.items === 'object') {
                    console.log('Order items:', order.items); // Debug log

                    Object.entries(order.items).forEach(([productId, item]) => {
                        console.log(`Processing item ${productId}:`, item); // Debug log

                        // Handle different item structures
                        let productName = '';
                        let packageType = '';
                        let addOns = [];
                        let prescriptionData = '';
                        let color = '';
                        let quantity = 1;

                        if (typeof item === 'object') {
                            // Extract product name
                            productName = item.product || productId;

                            // Extract color
                            color = item.color || '';

                            // Extract quantity
                            quantity = parseInt(item.quantity) || 1;

                            // Extract package
                            if (item.package) {
                                packageType = item.package;
                            }

                            // Extract add-ons (handle both array and object formats)
                            if (Array.isArray(item.addOn)) {
                                addOns = item.addOn;
                            } else if (item.addOn && typeof item.addOn === 'object') {
                                addOns = Object.values(item.addOn);
                            }

                            // Extract prescription
                            if (item.prescription) {
                                prescriptionData = parsePrescription(item.prescription);
                            }
                        }

                        const itemPrice = order.price?.[productId]?.price || 0;
                        const itemQuantity = order.price?.[productId]?.quantity || quantity;

                        itemsHTML += `
                            <div class="item-card">
                                <div class="item-header">
                                    <span>${productName || productId} ${color ? `- ${color}` : ''}</span>
                                    <span>${formatCurrency(itemPrice)} × ${itemQuantity}</span>
                                </div>
                                <div class="item-details">
                                    ${packageType ? `<div><strong>Package:</strong> ${packageType}</div>` : ''}
                                    ${addOns.length ? `<div><strong>Add-ons:</strong> ${addOns.join(', ')}</div>` : ''}
                                    ${prescriptionData ? `<div><strong>Prescription:</strong> ${prescriptionData}</div>` : ''}
                                    <div><strong>Total:</strong> ${formatCurrency(itemPrice * itemQuantity)}</div>
                                </div>
                            </div>
                        `;
                    });
                } else {
                    itemsHTML = '<p>No items found or invalid items structure</p>';
                    console.log('Invalid items structure:', order.items); // Debug log
                }

                // Calculate totals
                const subtotal = calculateOrderTotal(order);
                const discount = parseFloat(order.discount || 0);
                const finalTotal = subtotal - discount;

                card.innerHTML = `
                    <div class="order-header">
                        <div>
                            <div class="order-id">${order.orderId || 'No ID'}</div>
                            <div style="color: #666; font-size: 14px; margin-top: 5px;">
                                Ordered: ${formatDate(order.orderTime)}
                            </div>
                        </div>
                        <div class="order-status ${statusClass}">
                            ${makeEditable('status', order.status, 'select')}
                        </div>
                    </div>

                    <div class="customer-info">
                        <div class="section-title">Customer Information</div>
                        <div class="detail-row">
                            <span><strong>Name:</strong> ${order.name || 'N/A'}</span>
                            <span><strong>Email:</strong> ${order.email || 'N/A'}</span>
                            <span><strong>Phone:</strong> ${order.phoneNo || 'N/A'}</span>
                        </div>
                        <div><strong>Address:</strong> ${order.address || 'N/A'}</div>
                        ${order.userId ? `<div style="margin-top: 5px;"><strong>User ID:</strong> ${order.userId}</div>` : ''}
                    </div>

                    <div class="order-details">
                        <div class="order-section">
                            <div class="section-title">Order Items</div>
                            <div class="items-list">
                                ${itemsHTML || '<p>No items found</p>'}
                            </div>
                        </div>

                        <div class="order-section">
                            <div class="section-title">Payment & Shipping</div>
                            <div class="price-summary">
                                <div class="detail-row">
                                    <span>Subtotal:</span>
                                    <span>${formatCurrency(subtotal)}</span>
                                </div>
                                ${discount > 0 ? `
                                <div class="detail-row">
                                    <span>Discount:</span>
                                    <span>-${formatCurrency(discount)}</span>
                                </div>
                                ` : ''}
                                <div class="detail-row total-row">
                                    <span>Total:</span>
                                    <span>${formatCurrency(finalTotal)}</span>
                                </div>
                                <div style="margin-top: 10px;">
                                    <strong>Payment Type:</strong> ${order.paymentType || 'N/A'}
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="order-section">
                        <div class="section-title">Shipping & Tracking</div>
                        <div class="detail-row">
                            <span><strong>Delivered From:</strong> ${makeEditable('deliveredFrom', order.deliveredFrom, 'select')}</span>
                            <span><strong>Tracking No:</strong> ${makeEditable('trackingNo', order.trackingNo)}</span>
                        </div>
                        <div class="detail-row">
                            <span><strong>Arrival Time:</strong> ${makeEditable('arrivalTime', order.arrivalTime, 'datetime')}</span>
                            <span><strong>Processed By:</strong> ${makeEditable('processedBy', order.processedBy)}</span>
                        </div>
                    </div>

                    ${order.refundReason || order.returnRefundTime ? `
                    <div class="order-section">
                        <div class="section-title">Refund Information</div>
                        <div class="detail-row">
                            <span><strong>Refund Reason:</strong> ${makeEditable('refundReason', order.refundReason)}</span>
                            <span><strong>Refund Time:</strong> ${makeEditable('returnRefundTime', order.returnRefundTime, 'datetime')}</span>
                        </div>
                    </div>
                    ` : ''}
                `;

                // Add event listeners for editable fields
                card.querySelectorAll('.editable-field').forEach(el => {
                    // Handle empty fields
                    if (el.classList.contains('empty-field') && el.getAttribute('contenteditable')) {
                        el.addEventListener('focus', () => {
                            if (el.textContent === 'Click to edit') {
                                el.textContent = '';
                                el.classList.remove('empty-field');
                            }
                        });

                        el.addEventListener('blur', () => {
                            if (!el.textContent.trim()) {
                                el.textContent = 'Click to edit';
                                el.classList.add('empty-field');
                            }
                        });
                    }

                    const updateValue = () => {
                        const field = el.getAttribute('data-field');
                        let newValue = '';

                        if (el.tagName === 'INPUT' || el.tagName === 'SELECT') {
                            newValue = el.value;
                        } else {
                            newValue = el.textContent.trim();
                        }

                        // Don't save "Click to edit" as value
                        if (newValue === 'Click to edit') {
                            newValue = '';
                        }

                        if (hasChanges(order.orderId, field, newValue)) {
                            editedData[order.orderId] = editedData[order.orderId] || {};
                            editedData[order.orderId][field] = newValue;
                        } else {
                            if (editedData[order.orderId]) {
                                delete editedData[order.orderId][field];
                                if (Object.keys(editedData[order.orderId]).length === 0) {
                                    delete editedData[order.orderId];
                                }
                            }
                        }

                        saveBtn.disabled = Object.keys(editedData).length === 0;
                    };

                    el.addEventListener('blur', updateValue);
                    el.addEventListener('change', updateValue);
                    el.addEventListener('input', updateValue);
                });

                container.appendChild(card);
            });
        }

        // Save changes
        saveBtn.onclick = async () => {
            if (!confirm("Are you sure you want to save all changes?")) return;

            saveBtn.disabled = true;
            saveBtn.textContent = 'Saving...';

            try {
                let savedCount = 0;
                let failedCount = 0;
                const errors = [];

                // Helper function to convert datetime-local input to ISO UTC string
                const toUTCString = (dateValue) => {
                    if (!dateValue) return null;

                    try {
                        let date;
                        if (dateValue.seconds) {
                            // Already a Firestore timestamp
                            date = new Date(dateValue.seconds * 1000);
                        } else if (typeof dateValue === 'string') {
                            // Could be ISO string or datetime-local format
                            date = new Date(dateValue);
                        } else {
                            date = new Date(dateValue);
                        }

                        if (isNaN(date.getTime())) return null;

                        // Return as ISO UTC string
                        return date.toISOString();
                    } catch (e) {
                        console.error('Error converting date:', e);
                        return null;
                    }
                };

                // Process each edited order
                for (const orderId in editedData) {
                    try {
                        const changes = editedData[orderId];
                        const originalOrder = originalData[orderId];

                        // Prepare payload for db_handler
                        const payload = {
                            action: 'updateOrder',
                            orderId: orderId
                        };

                        // Add all fields from original order (to maintain structure)
                        // Then override with edited fields
                        const fieldsToSend = [
                            'userId', 'email', 'phoneNo', 'address', 'paymentType',
                            'trackingNo', 'status', 'deliveredFrom', 'refundReason',
                            'processedBy', 'discount'
                        ];

                        fieldsToSend.forEach(field => {
                            if (changes.hasOwnProperty(field)) {
                                payload[field] = changes[field];
                            } else if (originalOrder.hasOwnProperty(field)) {
                                payload[field] = originalOrder[field];
                            }
                        });

                        // Handle timestamps specially - convert to UTC ISO strings
                        if (changes.orderTime) {
                            const utcTime = toUTCString(changes.orderTime);
                            if (utcTime) payload.orderTime = utcTime;
                        } else if (originalOrder.orderTime) {
                            const utcTime = toUTCString(originalOrder.orderTime);
                            if (utcTime) payload.orderTime = utcTime;
                        }

                        if (changes.arrivalTime) {
                            const utcTime = toUTCString(changes.arrivalTime);
                            if (utcTime) payload.arrivalTime = utcTime;
                        } else if (originalOrder.arrivalTime) {
                            const utcTime = toUTCString(originalOrder.arrivalTime);
                            if (utcTime) payload.arrivalTime = utcTime;
                        }

                        if (changes.returnRefundTime) {
                            const utcTime = toUTCString(changes.returnRefundTime);
                            if (utcTime) payload.returnRefundTime = utcTime;
                        } else if (originalOrder.returnRefundTime) {
                            const utcTime = toUTCString(originalOrder.returnRefundTime);
                            if (utcTime) payload.returnRefundTime = utcTime;
                        }

                        // Include items and price (these shouldn't be edited, but include for completeness)
                        if (originalOrder.items) {
                            payload.items = JSON.stringify(originalOrder.items);
                        }
                        if (originalOrder.price) {
                            payload.price = JSON.stringify(originalOrder.price);
                        }

                        console.log('Updating order:', orderId, payload);

                        // Send to db_handler
                        const response = await fetch('/Handlers/db_handler.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify(payload)
                        });

                        const result = await response.json();

                        if (result.success) {
                            savedCount++;

                            // Update local data
                            if (originalData[orderId]) {
                                Object.assign(originalData[orderId], changes);
                            }
                            const order = orders.find(o => o.orderId === orderId);
                            if (order) {
                                Object.assign(order, changes);
                            }
                        } else {
                            failedCount++;
                            errors.push(`${orderId}: ${result.message || 'Unknown error'}`);
                            console.error('Failed to update order:', orderId, result);
                        }
                    } catch (err) {
                        failedCount++;
                        errors.push(`${orderId}: ${err.message}`);
                        console.error('Error updating order:', orderId, err);
                    }
                }

                // Clear edited data
                editedData = {};
                saveBtn.disabled = true;
                saveBtn.textContent = 'Save Changes';

                // Re-render to show updated data
                renderOrderCards(orders);

                // Show result message
                let message = `Successfully saved ${savedCount} order(s).`;
                if (failedCount > 0) {
                    message += `\n\nFailed to save ${failedCount} order(s):\n${errors.join('\n')}`;
                }
                alert(message);

            } catch (error) {
                console.error('Error saving changes:', error);
                alert("Error saving changes: " + error.message);
                saveBtn.disabled = Object.keys(editedData).length === 0;
                saveBtn.textContent = 'Save Changes';
            }
        };

        // Event listeners for filtering and sorting
        statusFilter.addEventListener('change', () => renderOrderCards(orders));
        searchBar.addEventListener('input', () => renderOrderCards(orders));
        sortOrder.addEventListener('change', () => renderOrderCards(orders));

        // Load orders on page load
        loadOrders();
    </script>
</asp:Content>