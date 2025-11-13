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
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border: 1px solid #ccc;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 16px;
            background: #fff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            position: relative;
        }

        .order-id {
            font-size: 1.3em; /* adjust size as needed */
            font-weight: bold;
        }

        .order-status {
            padding: 8px 12px;
            border-radius: 12px;
            font-weight: bold;
            min-width: 130px;
            text-align: center;
            height: fit-content;
        }

        .status-Ordered {
            background-color: #AED6F1;
            color: #03396C;
        }

        .status-Packed {
            background-color: #fff0b3;
            color: #aa6;
        }

        .status-InTransit {
            background-color: #ffd699;
            color: #a60;
        }

        .status-OutForDelivery {
            background-color: #d4f0d4;
            color: #080;
        }

        .status-Delivered {
            background-color: #b3e6b3;
            color: #060;
        }

        .status-RefundReturn {
            background-color: #f5cccc;
            color: #900;
        }

        .editable-field {
            border-bottom: 1px dotted #888;
            cursor: text;
        }

            .editable-field:focus {
                outline: none;
                background: #ffffcc;
            }

        ul {
            margin: 0;
            padding-left: 18px;
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
        </div>
        <div id="buttonsRight">
            <button type="button" id="saveChangesBtn" disabled>Save</button>
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

        const packagePrices = {
            "Frame Only Included": 0,
            "Single Vision Prescription": 150,
            "Reading Glasses": 100,
            "Bifocal / Progressive": 250
        };

        const addOnPrices = {
            "Blue Light Filter": 50,
            "Transition Lenses": 120,
            "Polarized": 100
        };

        function parseItemDescription(desc) {
            const result = { package: null, addOn: [] };
            if (!desc) return result;
            const parts = desc.split(' + ').map(p => p.trim());
            for (const p of parts) {
                if (packagePrices[p] != null) result.package = p;
                else if (addOnPrices[p] != null) result.addOn.push(p);
            }
            return result;
        }

        function calculateItemPrice(item) {
            let total = 0;
            let pkg = null, addons = [];
            let quantity = 1;

            if (typeof item === 'object') {
                pkg = item.package || null;
                addons = item.addOn || [];
                if (item.quantity != null) quantity = parseInt(item.quantity) || 1;
                if (item.price != null) total += parseFloat(item.price) || 0;
            } else if (typeof item === 'string') {
                const parsed = parseItemDescription(item);
                pkg = parsed.package;
                addons = parsed.addOn;
            }

            if (pkg && packagePrices[pkg] != null) total += packagePrices[pkg];
            if (Array.isArray(addons)) {
                for (const addon of addons) {
                    if (addOnPrices[addon] != null) total += addOnPrices[addon];
                }
            }

            total *= quantity;
            return total;
        }

        function calculateOrderTotal(order) {
            let total = 0;

            // Check if order.price exists
            if (order.price && typeof order.price === 'object') {
                for (const [pid, p] of Object.entries(order.price)) {
                    const itemPrice = parseFloat(p.price) || 0;
                    const itemQty = parseInt(p.quantity) || 1;
                    total += itemPrice * itemQty;
                }
            } else if (order.items && typeof order.items === 'object') {
                // fallback for items without price object
                for (const [pid, item] of Object.entries(order.items)) {
                    total += calculateItemPrice(item);
                }
            }

            // Apply discount if any
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

            if (total < 0) total = 0;
            return total.toFixed(2);
        }

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
                if (!data.success || !data.orders?.length) {
                    contentDiv.innerHTML = '<p>No orders found.</p>';
                    return;
                }

                orders = data.orders;

                originalData = {};
                orders.forEach(o => originalData[o.orderId] = JSON.parse(JSON.stringify(o)));

                renderOrderCards(orders);
            } catch (err) {
                contentDiv.innerHTML = `<p>Error loading orders: ${err.message}</p>`;
            }
        }

        function hasChanges(orderId, field, newValue) {
            const original = originalData[orderId]?.[field] || '';
            return original.toString().trim() !== newValue.trim();
        }

        function renderOrderCards(data) {
            const container = document.getElementById('ordersGrid');
            container.innerHTML = '';

            const searchTerm = searchBar.value.trim().toLowerCase();
            const filterValStr = String(statusFilter.value || '').toLowerCase();

            const filteredData = data.filter(order => {
                // status filter
                const statusStr = String(order.status || '').toLowerCase();
                if (filterValStr && statusStr !== filterValStr) return false;

                // search filter
                if (!searchTerm) return true;
                return (
                    String(order.orderId || '').toLowerCase().includes(searchTerm) ||
                    String(order.email || '').toLowerCase().includes(searchTerm) ||
                    String(order.phoneNo || '').toLowerCase().includes(searchTerm) ||
                    String(order.address || '').toLowerCase().includes(searchTerm)
                );
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
                switch ((String(order.status || '').toLowerCase())) {
                    case 'ordered': statusClass = 'status-Ordered'; break;
                    case 'packed': statusClass = 'status-Packed'; break;
                    case 'in transit': statusClass = 'status-InTransit'; break;
                    case 'out for delivery': statusClass = 'status-OutForDelivery'; break;
                    case 'delivered': statusClass = 'status-Delivered'; break;
                    case 'returned':
                    case 'refunded':
                    case 'refund/return': statusClass = 'status-RefundReturn'; break;
                }

                // Editable field generator
                const makeEditable = (field, value) => {
                    const isEmpty = !value || value.toString().trim() === '';

                    if (field === 'arrivalTime' || field === 'returnRefundTime') {
                        let dtValue = '';
                        if (!value) {
                            dtValue = '';
                        } else if (value instanceof Date) {
                            dtValue = value.toISOString().slice(0, 16);
                        } else if (value.seconds != null) {
                            dtValue = new Date(value.seconds * 1000).toISOString().slice(0, 16);
                        } else if (typeof value === 'string') {
                            const parsed = new Date(value);
                            if (!isNaN(parsed)) dtValue = parsed.toISOString().slice(0, 16);
                        }
                        return `<input class="editable-field" data-field="${field}" type="datetime-local" value="${dtValue}" placeholder="Click to edit">`;
                    } else if (field === 'deliveredFrom') {
                        const options = ['R1', 'R2', 'R3', 'Main'];
                        let optsHtml = '<option value="">Select...</option>' + options.map(opt => `<option value="${opt}" ${opt === value ? 'selected' : ''}>${opt}</option>`).join('');
                        return `<select class="editable-field" data-field="${field}">${optsHtml}</select>`;
                    } else {
                        return `<span class="editable-field${isEmpty ? ' empty' : ''}" data-field="${field}" contenteditable="true">${isEmpty ? 'Click to edit' : value}</span>`;
                    }
                };

                // Items HTML
                let itemsHTML = '<ul>';
                if (order.items && typeof order.items === 'object') {
                    for (const [pid, item] of Object.entries(order.items)) {
                        itemsHTML += `<li><strong>${pid}</strong>: `;
                        const parts = [];
                        if (typeof item === 'object') {
                            if (item.package) parts.push(item.package);
                            if (Array.isArray(item.addOn)) parts.push(item.addOn.join(', '));
                            if (item.prescription) {
                                const presParts = [];
                                for (const eye in item.prescription) {
                                    if (item.prescription[eye] && typeof item.prescription[eye] === 'object') {
                                        for (const side in item.prescription[eye]) {
                                            presParts.push(`${eye} ${side}: ${item.prescription[eye][side]}`);
                                        }
                                    }
                                }
                                if (presParts.length) parts.push(`Prescription: ${presParts.join(' | ')}`);
                            }
                            if (item.quantity != null) parts.push(`Quantity: ${item.quantity}`);
                        } else { parts.push(item); }
                        itemsHTML += parts.join(' + ') + '</li>';
                    }
                }
                itemsHTML += '</ul>';

                // Price & total
                let priceParts = [];
                if (order.price && typeof order.price === 'object') {
                    for (const [pid, p] of Object.entries(order.price)) {
                        if (p.price != null && p.quantity != null) priceParts.push(`${pid} => price: ${p.price}, quantity: ${p.quantity}`);
                    }
                }
                const totalPaymentHTML = `<strong>Total:</strong> RM ${calculateOrderTotal(order)} | <strong>Payment Type:</strong> ${order.paymentType || ''}`;
                const priceHTML = `<strong>Price:</strong> ${priceParts.join(' | ')}${order.discount ? ` | <strong>Discount:</strong> ${order.discount}` : ''}`;

                card.innerHTML = `
        <div class="order-info">
            <p style="font-size:1.2em;"><strong>${order.orderId || ''}</strong>${order.orderTime ? ` | Time: ${order.orderTime}` : ''} | Email: ${order.email || ''}${order.phoneNo ? ` | Phone: ${order.phoneNo}` : ''} | Address: ${order.address || ''}</p>
            <p><strong>Items:</strong><br>${itemsHTML}</p>
            <p>${priceHTML}</p>
            <p>${totalPaymentHTML}</p>
            <p>
                <strong>Delivered From:</strong> ${makeEditable('deliveredFrom', order.deliveredFrom)} |
                <strong>Tracking No:</strong> ${makeEditable('trackingNo', order.trackingNo)} |
                <strong>Arrival Time:</strong> ${makeEditable('arrivalTime', order.arrivalTime)}
            </p>
            <p>
                <strong>Refund Reason:</strong> ${makeEditable('refundReason', order.refundReason)} |
                <strong>Refund Time:</strong> ${makeEditable('returnRefundTime', order.returnRefundTime)} |
                <strong>Processed By:</strong> ${makeEditable('processedBy', order.processedBy)}
            </p>
        </div>
        <div class="order-status ${statusClass}">${makeEditable('status', order.status)}</div>
        `;

                // Editable field event listeners
                card.querySelectorAll('.editable-field').forEach(el => {
                    // Handle click on empty fields
                    if (el.classList.contains('empty') && el.getAttribute('contenteditable')) {
                        el.addEventListener('focus', () => {
                            if (el.textContent === 'Click to edit') {
                                el.textContent = '';
                                el.classList.remove('empty');
                            }
                        });
                    }

                    const updateValue = () => {
                        const field = el.getAttribute('data-field');
                        let newValue = '';
                        if (el.tagName === 'INPUT' || el.tagName === 'SELECT') {
                            newValue = el.value;
                        } else {
                            newValue = el.innerText.trim();
                        }

                        // Don't save "Click to edit" as value
                        if (newValue === 'Click to edit') {
                            newValue = '';
                        }

                        if (hasChanges(order.orderId, field, newValue)) {
                            editedData[order.orderId] = editedData[order.orderId] || {};
                            editedData[order.orderId][field] = newValue;
                        } else {
                            if (editedData[order.orderId]) delete editedData[order.orderId][field];
                            if (Object.keys(editedData[order.orderId] || {}).length === 0) delete editedData[order.orderId];
                        }
                        saveBtn.disabled = Object.keys(editedData).length === 0;
                    };

                    el.addEventListener('blur', updateValue);
                    el.addEventListener('change', updateValue);
                });

                container.appendChild(card);
            });
        }

        saveBtn.onclick = async () => {
            if (!confirm("Are you sure you want to save changes?")) return;

            // Apply changes to original data
            for (const orderId in editedData) {
                if (originalData[orderId]) {
                    Object.assign(originalData[orderId], editedData[orderId]);
                }
                // Also update the orders array
                const order = orders.find(o => o.orderId === orderId);
                if (order) {
                    Object.assign(order, editedData[orderId]);
                }
            }

            // Clear edited data and disable save button
            editedData = {};
            saveBtn.disabled = true;

            // Re-render to show updated data
            renderOrderCards(orders);

            if (typeof showToast === 'function') {
                showToast("Orders saved successfully!");
            } else {
                alert("Orders saved successfully!");
            }
        };

        // Event listeners
        statusFilter.addEventListener('change', () => renderOrderCards(orders));
        searchBar.addEventListener('input', () => renderOrderCards(orders));

        // Load orders on page load
        loadOrders();
    </script>
</asp:Content>
