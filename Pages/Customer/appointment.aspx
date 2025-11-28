<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="appointment.aspx.cs" Inherits="Opton.Pages.Customer.appointment" MasterPageFile="~/Site.Master" Async="true" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <style>
        /* General Page Layout */
        .appointments-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }

        hr.thick-dark {
            border: 0;
            border-top: 5px solid #2C3639;
            width: 100%;
            margin: 20px 0;
        }

        /* Div 1 - Product Hold Section */
        .product-hold {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.2rem;
            cursor: pointer;
            color: #2C3639;
        }

            .product-hold i {
                font-size: 2rem;
            }

        /* Div 2 - Map + User Info */
        .user-info-map {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            justify-content: center;
        }

        .map-preview {
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid #ccc;
            height: 250px;
            width: 250px;
        }

        .user-form {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

            .user-form input,
            .user-form textarea {
                padding: 8px 10px;
                border-radius: 6px;
                border: 1px solid #ccc;
                font-size: 1rem;
                width: 100%;
                box-sizing: border-box;
            }

            .user-form input.error {
                border-color: #dc3545;
            }

            .user-form .error-message {
                color: #dc3545;
                font-size: 0.875rem;
                margin-top: -5px;
            }

            .user-form textarea {
                height: 80px;
            }

        /* Prescription */
        .collapsible-prescription {
            border: 1px solid #ccc;
            border-radius: 6px;
            padding: 8px;
            margin: 10px 0;
        }

        .collapsible-header {
            display: flex;
            justify-content: space-between;
            cursor: pointer;
            font-size: 1rem;
            color: #2C3639;
        }

        .toggle-indicator {
            font-weight: bold;
        }

        /* Prescription switch */
        .prescription-mode {
            display: flex;
            gap: 20px;
            margin: 10px 0;
        }

            .prescription-mode label {
                cursor: pointer;
                padding: 6px 0;
                border: none;
                background: none;
                font-weight: 500;
                text-decoration: none;
                color: #2C3639;
                transition: all 0.2s ease;
                border-bottom: 2px solid transparent;
            }

            .prescription-mode input[type="radio"]:checked + label {
                border-bottom: 2px solid var(--color-accent);
                font-weight: 600;
            }

            .prescription-mode label:hover {
                border-bottom: 2px solid var(--color-accent);
                opacity: 0.8;
            }

            .prescription-mode input[type="radio"] {
                display: none;
            }

        /* Manual prescription fields */
        .manual-prescription-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

            .manual-prescription-table th,
            .manual-prescription-table td {
                padding: 6px;
                border: none;
                text-align: center;
            }

            .manual-prescription-table input {
                width: 90%;
                padding: 4px 6px;
                border-radius: 6px;
                border: 1px solid #ccc;
            }

        /* Div 3 - Retailer Info */
        .retailer-info {
            margin-top: 20px;
            text-align: center;
        }

            .retailer-info .retailer-name {
                font-weight: bold;
                font-size: 1.1rem;
            }

            .retailer-info .retailer-phone i {
                margin-right: 5px;
            }

        hr.short {
            border: 0;
            border-top: 2px solid #2C3639;
            width: 90%;
            margin: 15px auto;
        }

        /* Div 4 - Appointment Section */
        .appointment-section {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
            margin-top: 20px;
        }

        .calendar-container {
            display: flex;
            justify-content: center;
        }

        .appointment-details {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
        }

        .appointment-times {
            display: grid;
            grid-template-columns: repeat(10, auto);
            gap: 10px;
            justify-content: center;
        }

            .appointment-times label {
                padding: 6px 10px;
                border: 1px solid #2C3639;
                border-radius: 6px;
                cursor: pointer;
                display: inline-flex;
                justify-content: center;
                align-items: center;
                min-width: 50px;
                transition: all 0.2s ease;
                background-color: white;
                color: #2C3639;
            }

            .appointment-times input[type="radio"] {
                display: none;
            }

        /* Book button */
        .book-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            background-color: #A27B5C;
            color: white;
            cursor: pointer;
            font-size: 1rem;
            margin: 20px auto 0 auto;
            display: block;
            width: fit-content;
        }

            .book-btn:disabled {
                background-color: #ccc;
                cursor: not-allowed;
            }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="appointments-container">

        <!-- Div 1: Product Hold -->
      <div class="product-hold" onclick="showUserProductList()">
    <i class="ri-add-circle-line"></i>
    <span id="productHoldText">Found something you like? Let us hold onto it for you!</span>
    <span id="selectedCount" style="display: none; margin-left: 10px; background: #A27B5C; color: white; padding: 4px 12px; border-radius: 12px; font-size: 0.9rem;"></span>
</div>
        <hr class="thick-dark" />

        <!-- Div 2: Map + User Info -->
        <div class="user-info-map">
            <!-- Map -->
            <div class="map-preview" id="mapPreview"></div>

            <!-- User Form -->
            <div class="user-form">
                <input type="text" id="userName" placeholder="Full Name" required />
                <div>
                    <input type="email" id="userEmail" placeholder="Email Address" required />
                    <div id="emailError" class="error-message" style="display: none;"></div>
                </div>
                <input type="tel" id="userPhone" placeholder="Phone Number" required />

                <!-- Collapsible Prescription Section -->
                <div class="collapsible-prescription">
                    <div class="collapsible-header" onclick="togglePrescription(this)">
                        <strong>Prescription (Optional)</strong>
                        <span class="toggle-indicator">▼</span>
                    </div>

                    <div class="collapsible-body" style="display: none; margin-top: 10px;">
                        <!-- Prescription mode toggle -->
                        <div class="prescription-mode">
                            <input type="radio" id="uploadMode" name="prescriptionMode" checked>
                            <label for="uploadMode">Upload Prescription</label>
                            <input type="radio" id="manualMode" name="prescriptionMode">
                            <label for="manualMode">Manual Input</label>
                        </div>

                        <!-- Prescription Type Dropdown -->
                        <div id="prescriptionTypeContainer" style="display: block;">
                            <label for="prescriptionType" style="font-weight: 500;">Prescription Type</label>
                            <select id="prescriptionType" style="padding: 6px 8px; border-radius: 6px; border: 1px solid #ccc; width: 100%;">
                                <option value="">-- Select Type --</option>
                                <option value="nearsightedness">Nearsightedness (Myopia)</option>
                                <option value="farsightedness">Farsightedness (Hyperopia)</option>
                                <option value="reading">Reading Glasses</option>
                                <option value="multifocal">Multifocal / Progressive</option>
                            </select>
                        </div>

                        <!-- Upload Prescription -->
                        <div id="uploadPrescription">
                            <input type="file" id="prescriptionFile" accept=".png,.jpg,.jpeg,.pdf" />
                            <small>Allowed file types: PNG, JPG, JPEG, PDF</small>
                        </div>

                        <!-- Manual Prescription -->
                        <div id="manualPrescription" style="display: none;">
                            <table class="manual-prescription-table">
                                <thead>
                                    <tr>
                                        <th></th>
                                        <th>Left Eye</th>
                                        <th>Right Eye</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>Sphere</td>
                                        <td><input type="text" id="leftEyeSphere" placeholder="Sphere" /></td>
                                        <td><input type="text" id="rightEyeSphere" placeholder="Sphere" /></td>
                                    </tr>
                                    <tr>
                                        <td>Cylinder</td>
                                        <td><input type="text" id="leftEyeCylinder" placeholder="Cylinder" /></td>
                                        <td><input type="text" id="rightEyeCylinder" placeholder="Cylinder" /></td>
                                    </tr>
                                    <tr>
                                        <td>Axis</td>
                                        <td><input type="text" id="leftEyeAxis" placeholder="Axis" /></td>
                                        <td><input type="text" id="rightEyeAxis" placeholder="Axis" /></td>
                                    </tr>
                                    <tr>
                                        <td>PD</td>
                                        <td colspan="2"><input type="text" id="pd" placeholder="Pupillary Distance" /></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <textarea id="userRemarks" placeholder="Remarks (optional)"></textarea>
            </div>
        </div>

        <!-- Div 3: Retailer Info -->
        <div class="retailer-info">
            <div class="retailer-name">
                <asp:Literal ID="retailerNameLiteral" runat="server" Text="Retailer Name"></asp:Literal>
            </div>
            <div class="retailer-address" id="retailerAddress" runat="server" ClientIDMode="Static"></div>
            <div class="retailer-phone" id="retailerPhone" runat="server" ClientIDMode="Static"><i class="ri-phone-fill"></i></div>
        </div>
        <hr class="short" />

        <!-- Div 4: Appointment Selection -->
        <div class="appointment-section">
            <div class="calendar-container">
                <input type="date" id="appointmentDate" onchange="updateAppointmentTimes()" />
            </div>

            <div class="appointment-details">
                <!-- Appointment type dropdown -->
                <select id="appointmentType">
                    <option value="prescription">Prescription</option>
                    <option value="consultation">Consultation</option>
                    <option value="other">Other</option>
                </select>

                <div id="appointmentPrompt">Pick a Date to Start!</div>
                <div class="appointment-times" id="appointmentTimes"></div>
            </div>
        </div>

        <!-- Book Appointment button -->
        <button type="button" class="book-btn" id="bookAppointmentBtn" disabled onclick="bookAppointment()">Book Appointment</button>
    </div>
    <!-- Product Selection Modal -->
<div id="productModal" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 9999; overflow-y: auto;">
    <div style="max-width: 1000px; margin: 50px auto; background: white; border-radius: 8px; padding: 20px; position: relative;">
        <button onclick="closeProductModal()" style="position: absolute; top: 10px; right: 10px; background: none; border: none; font-size: 24px; cursor: pointer;">&times;</button>
        
        <h2 style="text-align: center; margin-bottom: 20px;">Select Products to Hold (Max 3)</h2>
        
        <!-- Search and Filter -->
        <div style="display: flex; gap: 10px; margin-bottom: 20px;">
            <input type="text" id="modalSearch" placeholder="Search products..." style="flex: 1; padding: 8px; border: 1px solid #ccc; border-radius: 6px;" oninput="filterModalProducts()" />
        </div>
        
        <!-- Selected Products Display -->
        <div id="selectedProductsDisplay" style="margin-bottom: 20px; padding: 10px; background: #f5f5f5; border-radius: 6px; min-height: 50px;">
            <strong>Selected Products (0/3):</strong>
            <div id="selectedProductsList"></div>
        </div>
        
        <!-- Product Grid -->
        <div id="modalProductGrid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 15px; max-height: 500px; overflow-y: auto;">
            <!-- Products will be loaded here -->
        </div>
        
        <button type="button" onclick="confirmProductSelection()" style="margin-top: 20px; padding: 10px 20px; background: #A27B5C; color: white; border: none; border-radius: 6px; cursor: pointer; display: block; margin-left: auto; margin-right: auto;">Confirm Selection</button>
    </div>
</div>

<!-- Product Configuration Modal -->
<div id="configModal" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 10000;">
    <div style="max-width: 500px; margin: 100px auto; background: white; border-radius: 8px; padding: 20px;">
        <h3 id="configProductName" style="text-align: center; margin-bottom: 20px;"></h3>
        
        <div style="margin-bottom: 15px;">
            <label style="display: block; margin-bottom: 5px; font-weight: 600;">Color:</label>
            <select id="configColor" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 6px;"></select>
        </div>
        
        <div style="margin-bottom: 15px;">
            <label style="display: block; margin-bottom: 5px; font-weight: 600;">Size:</label>
            <select id="configSize" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 6px;">
                <option value="Default">Default</option>
                <option value="Small">Small</option>
                <option value="Medium">Medium</option>
                <option value="Large">Large</option>
            </select>
        </div>
        
        <div style="display: flex; gap: 10px; justify-content: center;">
            <button type="button" onclick="closeConfigModal()" style="padding: 8px 16px; background: #ccc; border: none; border-radius: 6px; cursor: pointer;">Cancel</button>
            <button type="button"  onclick="saveProductConfig()" style="padding: 8px 16px; background: #A27B5C; color: white; border: none; border-radius: 6px; cursor: pointer;">Save</button>
        </div>
    </div>
</div>

    <script type="module">
        let retailerOpeningHours = {};

        async function loadRetailerData() {
            const params = new URLSearchParams(window.location.search);
            const retailerId = params.get('retailerId');
            if (!retailerId) {
                console.error("No retailerId in query string");
                return;
            }

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ getRetailers: true })
                });

                const data = await response.json();
                console.log("Handler response:", data);

                const retailers = data.retailers || data;
                if (!Array.isArray(retailers)) {
                    console.error("Retailer data invalid", data);
                    return;
                }

                const retailer = retailers.find(r => r.id == retailerId);
                if (!retailer) {
                    console.error("Retailer not found:", retailerId);
                    return;
                }

                retailerOpeningHours = retailer.openingHours || {};

                const nameEl = document.querySelector('.retailer-name');
                const addressEl = document.getElementById('retailerAddress');
                const phoneEl = document.getElementById('retailerPhone');

                if (nameEl) nameEl.innerHTML = retailer.name || 'Unknown Retailer';
                if (addressEl) addressEl.textContent = retailer.address || 'No address available';
                if (phoneEl) phoneEl.innerHTML = `<i class="ri-phone-fill"></i> ${retailer.phoneNo || 'N/A'}`;

                return {
                    name: retailer.name,
                    lat: parseFloat(retailer.latitude),
                    lng: parseFloat(retailer.longitude)
                };
            } catch (err) {
                console.error("Error fetching retailer data:", err);
            }
        }

        async function initializeMap(lat, lng, retailerName) {
            const apiKey = await fetch('/Handlers/get_keys.ashx')
                .then(res => res.json())
                .then(data => data.apiKeys.GOOGLE_API_KEY)
                .catch(err => {
                    console.error('Failed to get Google API key:', err);
                    return null;
                });

            if (!apiKey) return;

            await new Promise((resolve, reject) => {
                if (window.google && window.google.maps) return resolve();
                const script = document.createElement('script');
                script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}`;
                script.async = true;
                script.defer = true;
                script.onload = resolve;
                script.onerror = reject;
                document.head.appendChild(script);
            });

            const map = new google.maps.Map(document.getElementById('mapPreview'), {
                center: { lat, lng },
                zoom: 15,
            });

            const marker = new google.maps.Marker({
                position: { lat, lng },
                map,
                title: retailerName,
            });

            const infoWindow = new google.maps.InfoWindow({
                content: `
                <div style="font-family: Arial; text-align: center;">
                    <strong>${retailerName}</strong><br>
                    <button id="directionsBtn"
                        style="
                            margin-top: 8px;
                            padding: 6px 12px;
                            background-color: #A27B5C;
                            color: white;
                            border: none;
                            border-radius: 6px;
                            font-weight: bold;
                            cursor: pointer;
                            transition: background 0.2s;
                        "
                        onmouseover="this.style.backgroundColor='#8f6b4f'"
                        onmouseout="this.style.backgroundColor='#A27B5C'">
                        Go Now
                    </button>
                </div>
            `
            });

            infoWindow.open(map, marker);

            google.maps.event.addListener(infoWindow, 'domready', () => {
                const btn = document.getElementById('directionsBtn');
                if (btn) {
                    btn.onclick = () => {
                        const destination = `${lat},${lng}`;
                        window.open(
                            `https://www.google.com/maps/dir/?api=1&destination=${destination}&travelmode=driving`,
                            '_blank'
                        );
                    };
                }
            });
        }

        window.addEventListener('load', async () => {
            const retailer = await loadRetailerData();
            if (retailer && retailer.lat && retailer.lng) {
                initializeMap(retailer.lat, retailer.lng, retailer.name);
            }
        });
    </script>
    <script>
        // Email validation function
        function validateEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        // Add email validation on input
        document.addEventListener('DOMContentLoaded', () => {
            const emailInput = document.getElementById('userEmail');
            const emailError = document.getElementById('emailError');

            emailInput.addEventListener('blur', () => {
                const email = emailInput.value.trim();
                if (email && !validateEmail(email)) {
                    emailInput.classList.add('error');
                    emailError.textContent = 'Please enter a valid email address';
                    emailError.style.display = 'block';
                } else {
                    emailInput.classList.remove('error');
                    emailError.style.display = 'none';
                }
            });

            emailInput.addEventListener('input', () => {
                if (emailInput.classList.contains('error')) {
                    const email = emailInput.value.trim();
                    if (validateEmail(email)) {
                        emailInput.classList.remove('error');
                        emailError.style.display = 'none';
                    }
                }
            });
        });

        function togglePrescription(headerEl) {
            const body = headerEl.nextElementSibling;
            if (!body) return;

            if (body.style.display === 'none') {
                body.style.display = 'block';
                headerEl.querySelector('.toggle-indicator').textContent = '▲';
            } else {
                body.style.display = 'none';
                headerEl.querySelector('.toggle-indicator').textContent = '▼';
            }
        }

        const uploadRadio = document.getElementById('uploadMode');
        const manualRadio = document.getElementById('manualMode');
        const uploadDiv = document.getElementById('uploadPrescription');
        const manualDiv = document.getElementById('manualPrescription');

        uploadRadio.addEventListener('change', () => {
            uploadDiv.style.display = 'block';
            manualDiv.style.display = 'none';
        });

        manualRadio.addEventListener('change', () => {
            uploadDiv.style.display = 'none';
            manualDiv.style.display = 'block';
        });

        const prescriptionType = document.getElementById('prescriptionType');
        const pdInput = document.getElementById('pd');

        prescriptionType.addEventListener('change', () => {
            const type = prescriptionType.value;
            pdInput.style.display = 'table-cell';
            if (type === 'reading') {
                pdInput.style.display = 'none';
            }
        });

        let selectedProducts = [];
        let allStoreProducts = [];
        let currentConfigProductId = null;
        let currentRetailerId = null;

        // Extract colors and sizes from inventory for specific retailer
        function extractColorsAndSizes(product, retailerId) {
            // Determine which inventory column to use
            let inventorySource = product.inventory || {};

            if (retailerId === 'R1' && product.R1) {
                inventorySource = product.R1;
            } else if (retailerId === 'R2' && product.R2) {
                inventorySource = product.R2;
            } else if (retailerId === 'R3' && product.R3) {
                inventorySource = product.R3;
            }

            const colorsSet = new Set();
            const sizesSet = new Set();

            if (!inventorySource || typeof inventorySource !== 'object') {
                return { colors: ['Default'], sizes: ['Default'] };
            }

            // Check if it's nested structure with Adults/Kids
            if (inventorySource.Adults || inventorySource.Kids) {
                // Process Adults
                if (inventorySource.Adults && typeof inventorySource.Adults === 'object') {
                    Object.keys(inventorySource.Adults).forEach(key => {
                        const quantity = inventorySource.Adults[key];
                        if (typeof quantity === 'number' && quantity > 0) {
                            // Extract color from key (e.g., "black", "silver", "black23")
                            const colorMatch = key.match(/^([a-z]+)(\d*)$/i);
                            if (colorMatch) {
                                const colorName = colorMatch[1].toLowerCase();
                                const size = colorMatch[2];

                                colorsSet.add(colorName);
                                if (size) {
                                    sizesSet.add(size);
                                } else {
                                    sizesSet.add('Adults');
                                }
                            }
                        }
                    });
                }

                // Process Kids
                if (inventorySource.Kids && typeof inventorySource.Kids === 'object') {
                    Object.keys(inventorySource.Kids).forEach(key => {
                        const quantity = inventorySource.Kids[key];
                        if (typeof quantity === 'number' && quantity > 0) {
                            const colorMatch = key.match(/^([a-z]+)(\d*)$/i);
                            if (colorMatch) {
                                const colorName = colorMatch[1].toLowerCase();
                                const size = colorMatch[2];

                                colorsSet.add(colorName);
                                if (size) {
                                    sizesSet.add(size);
                                } else {
                                    sizesSet.add('Kids');
                                }
                            }
                        }
                    });
                }
            } else {
                // Flat structure: {"black":200,"white":183}
                Object.keys(inventorySource).forEach(key => {
                    const quantity = inventorySource[key];
                    if (typeof quantity === 'number' && quantity > 0) {
                        const colorMatch = key.match(/^([a-z]+)(\d*)$/i);
                        if (colorMatch) {
                            const colorName = colorMatch[1].toLowerCase();
                            const size = colorMatch[2];

                            colorsSet.add(colorName);
                            if (size) {
                                sizesSet.add(size);
                            }
                        }
                    }
                });
            }

            return {
                colors: colorsSet.size > 0 ? Array.from(colorsSet) : ['Default'],
                sizes: sizesSet.size > 0 ? Array.from(sizesSet).sort((a, b) => {
                    // Sort: Kids, Adults, then numeric
                    if (a === 'Kids') return -1;
                    if (b === 'Kids') return 1;
                    if (a === 'Adults') return -1;
                    if (b === 'Adults') return 1;
                    return parseInt(a) - parseInt(b);
                }) : ['Default']
            };
        }

        async function showUserProductList() {
            const params = new URLSearchParams(window.location.search);
            const retailerId = params.get('retailerId');

            if (!retailerId) {
                alert('No retailer selected');
                return;
            }

            currentRetailerId = retailerId;

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'getProductsList'
                    })
                });

                const data = await response.json();
                console.log('Products response:', data);

                if (data.success && data.products) {
                    // Filter products available at this specific retailer
                    allStoreProducts = data.products.filter(p => {
                        const productId = p.productId || p.id;

                        // Check if product has inventory for this retailer
                        if (retailerId === 'R1' && p.R1) return true;
                        if (retailerId === 'R2' && p.R2) return true;
                        if (retailerId === 'R3' && p.R3) return true;
                        if (p.inventory) return true; // Always include inventory

                        return false;
                    });

                    console.log('Loaded products for retailer:', allStoreProducts.length);
                    displayProductModal(allStoreProducts);
                } else {
                    alert('No products available');
                }
            } catch (err) {
                console.error('Error loading products:', err);
                alert('Failed to load products');
            }
        }

        function displayProductModal(products) {
            const modal = document.getElementById('productModal');
            const grid = document.getElementById('modalProductGrid');

            grid.innerHTML = '';

            products.forEach(product => {
                const productId = product.productId || product.id;
                const isSelected = selectedProducts.some(p => p.id === productId);
                const { colors, sizes } = extractColorsAndSizes(product, currentRetailerId);

                const card = document.createElement('div');
                card.style.cssText = `
            border: 2px solid ${isSelected ? '#A27B5C' : '#ddd'};
            border-radius: 8px;
            padding: 10px;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s;
            background: ${isSelected ? '#f5f5f5' : 'white'};
            opacity: ${selectedProducts.length >= 3 && !isSelected ? '0.5' : '1'};
            pointer-events: ${selectedProducts.length >= 3 && !isSelected ? 'none' : 'auto'};
        `;

                // Simple display - just icon
                const displayContent = `
            <div class="product-card-display">
                <i class="ri-glasses-2-line"></i>
            </div>
        `;

                card.innerHTML = `
            ${displayContent}
            <div style="font-weight: 600; margin-bottom: 5px; font-size: 14px;">${product.name}</div>
            <div style="color: #A27B5C; font-size: 16px; font-weight: 600;">RM ${product.price}</div>
            <div style="font-size: 12px; color: #666; margin-top: 5px;">
                ${colors.length} color(s) • ${sizes.length} size(s)
            </div>
            ${isSelected ? '<div style="color: #A27B5C; font-weight: 600; margin-top: 5px;">✓ Selected</div>' : ''}
        `;

                card.onclick = () => selectProduct(product);
                grid.appendChild(card);
            });

            modal.style.display = 'block';
            updateSelectedDisplay();
        }

        function selectProduct(product) {
            const productId = product.productId || product.id;
            const existingIndex = selectedProducts.findIndex(p => p.id === productId);

            if (existingIndex >= 0) {
                // Deselect
                selectedProducts.splice(existingIndex, 1);
                displayProductModal(allStoreProducts);
            } else if (selectedProducts.length < 3) {
                // Show configuration modal
                currentConfigProductId = productId;
                showConfigModal(product);
            } else {
                alert('You can only select up to 3 products');
            }
        }

        function showConfigModal(product) {
            const modal = document.getElementById('configModal');
            const nameEl = document.getElementById('configProductName');
            const colorSelect = document.getElementById('configColor');
            const sizeSelect = document.getElementById('configSize');

            const productId = product.productId || product.id;
            const { colors, sizes } = extractColorsAndSizes(product, currentRetailerId);

            nameEl.textContent = product.name;

            // Populate colors
            colorSelect.innerHTML = '';
            colors.forEach(color => {
                const option = document.createElement('option');
                option.value = color;
                option.textContent = color.charAt(0).toUpperCase() + color.slice(1);
                colorSelect.appendChild(option);
            });

            // Populate sizes
            sizeSelect.innerHTML = '';
            sizes.forEach(size => {
                const option = document.createElement('option');
                option.value = size;
                option.textContent = size === 'Adults' ? 'Adults' : size === 'Kids' ? 'Kids' : `Size ${size}`;
                sizeSelect.appendChild(option);
            });

            modal.style.display = 'block';
        }

        function closeConfigModal() {
            document.getElementById('configModal').style.display = 'none';
            currentConfigProductId = null;
        }

        function saveProductConfig() {
            const color = document.getElementById('configColor').value;
            const size = document.getElementById('configSize').value;

            const product = allStoreProducts.find(p => {
                const pid = p.productId || p.id;
                return pid === currentConfigProductId;
            });

            if (product) {
                const productId = product.productId || product.id;

                selectedProducts.push({
                    id: productId,
                    name: product.name,
                    price: product.price,
                    color: color,
                    size: size
                });

                updateSelectedDisplay();
                displayProductModal(allStoreProducts);
            }

            closeConfigModal();
        }

        function updateSelectedDisplay() {
            const displayDiv = document.getElementById('selectedProductsList');
            const countSpan = document.getElementById('selectedCount');
            const productHoldText = document.getElementById('productHoldText');

            // Update the modal header count
            const modalHeader = document.querySelector('#selectedProductsDisplay strong');
            if (modalHeader) {
                modalHeader.textContent = `Selected Products (${selectedProducts.length}/3):`;
            }

            if (selectedProducts.length === 0) {
                displayDiv.innerHTML = '<div style="color: #999; padding: 5px;">No products selected yet</div>';
                countSpan.style.display = 'none';
                productHoldText.textContent = 'Found something you like? Let us hold onto it for you!';
            } else {
                displayDiv.innerHTML = '';
                selectedProducts.forEach(p => {
                    const productDiv = document.createElement('div');
                    productDiv.style.cssText = 'display: flex; justify-content: space-between; align-items: center; padding: 8px; background: white; margin-top: 8px; border-radius: 6px;';

                    productDiv.innerHTML = `
                <div style="display: flex; align-items: center; gap: 10px;">
                    <i class="ri-glasses-2-line" style="font-size: 24px; color: #A27B5C;"></i>
                    <div>
                        <div style="font-weight: 600;">${p.name}</div>
                        <div style="font-size: 0.85rem; color: #666;">${p.color} | ${p.size}</div>
                    </div>
                </div>
            `;

                    const removeBtn = document.createElement('button');
                    removeBtn.textContent = 'Remove';
                    removeBtn.style.cssText = 'background: #dc3545; color: white; border: none; border-radius: 4px; padding: 4px 8px; cursor: pointer;';
                    removeBtn.onclick = () => removeSelectedProduct(p.id);

                    productDiv.appendChild(removeBtn);
                    displayDiv.appendChild(productDiv);
                });

                countSpan.textContent = `${selectedProducts.length} selected`;
                countSpan.style.display = 'inline-block';
                productHoldText.textContent = `${selectedProducts.length} product(s) selected to hold`;
            }

            // Update main page counter
            const mainCount = document.querySelector('.product-hold #selectedCount');
            if (mainCount) {
                mainCount.textContent = `${selectedProducts.length} selected`;
                mainCount.style.display = selectedProducts.length > 0 ? 'inline-block' : 'none';
            }
        }

        function removeSelectedProduct(productId) {
            selectedProducts = selectedProducts.filter(p => p.id !== productId);
            updateSelectedDisplay();
            displayProductModal(allStoreProducts);
        }

        function filterModalProducts() {
            const searchTerm = document.getElementById('modalSearch').value.toLowerCase();
            const filtered = allStoreProducts.filter(p => {
                const name = (p.name || '').toLowerCase();
                const id = ((p.productId || p.id) || '').toLowerCase();
                return name.includes(searchTerm) || id.includes(searchTerm);
            });
            displayProductModal(filtered);
        }

        function closeProductModal() {
            document.getElementById('productModal').style.display = 'none';
        }

        function confirmProductSelection() {
            if (selectedProducts.length === 0) {
                alert('Please select at least one product');
                return;
            }

            closeProductModal();

            // Update the main display counter
            const countSpan = document.getElementById('selectedCount');
            const productHoldText = document.getElementById('productHoldText');

            if (countSpan && productHoldText) {
                countSpan.textContent = `${selectedProducts.length} selected`;
                countSpan.style.display = 'inline-block';
                productHoldText.textContent = `${selectedProducts.length} product(s) selected to hold`;
            }

            console.log('Confirmed products:', selectedProducts);
        }

        async function updateAppointmentTimes() {
            const dateInput = document.getElementById('appointmentDate').value;
            const timesContainer = document.getElementById('appointmentTimes');
            const prompt = document.getElementById('appointmentPrompt');
            const bookBtn = document.getElementById('bookAppointmentBtn');

            timesContainer.innerHTML = '';

            if (!dateInput) {
                prompt.innerHTML = "Pick a Date to Start!";
                bookBtn.disabled = true;
                return;
            }

            prompt.innerHTML = `<strong>Select a Time for ${dateInput}</strong>`;

            const dayOfWeek = new Date(dateInput).toLocaleDateString('en-US', { weekday: 'long' });
            const hours = retailerOpeningHours[dayOfWeek];

            if (!hours || hours === "Closed") {
                timesContainer.innerHTML = `<div style="text-align:center; font-weight:bold;">Retailer is closed on this day.</div>`;
                bookBtn.disabled = true;
                return;
            }

            // Get retailer ID
            const params = new URLSearchParams(window.location.search);
            const retailerId = params.get('retailerId');

            try {
                // Fetch booked times for this date
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'getAppointmentTimes',
                        storeId: retailerId,
                        date: dateInput
                    })
                });

                const data = await response.json();
                const bookedTimes = data.success ? data.bookedTimes : [];

                console.log('Booked times:', bookedTimes);

                const [startHour, endHour] = hours.split('-').map(Number);

                for (let h = startHour; h < endHour; h++) {
                    for (let m = 0; m < 60; m += 30) {
                        const slotHour = h.toString().padStart(2, '0');
                        const slotMin = m.toString().padStart(2, '0');
                        const timeValue = `${slotHour}:${slotMin}`;

                        // Skip if this time slot is already booked
                        if (bookedTimes.includes(timeValue)) {
                            console.log(`Skipping booked time: ${timeValue}`);
                            continue;
                        }

                        const label = document.createElement('label');
                        const radio = document.createElement('input');
                        radio.type = "radio";
                        radio.name = "appointmentTime";
                        radio.value = timeValue;

                        const span = document.createElement('span');
                        span.textContent = timeValue;

                        label.appendChild(radio);
                        label.appendChild(span);
                        timesContainer.appendChild(label);

                        radio.addEventListener('change', () => {
                            document.querySelectorAll('.appointment-times label').forEach(l => {
                                l.style.backgroundColor = 'white';
                                l.style.color = '#2C3639';
                            });

                            label.style.backgroundColor = 'var(--color-dark)';
                            label.style.color = 'white';

                            bookBtn.disabled = false;
                        });
                    }
                }

                if (timesContainer.children.length === 0) {
                    timesContainer.innerHTML = `<div style="text-align:center; font-weight:bold; color: #dc3545;">All time slots are booked for this day.</div>`;
                    bookBtn.disabled = true;
                }

            } catch (err) {
                console.error('Error fetching booked times:', err);
                // Continue showing all times if fetch fails
                const [startHour, endHour] = hours.split('-').map(Number);
                for (let h = startHour; h < endHour; h++) {
                    for (let m = 0; m < 60; m += 30) {
                        const slotHour = h.toString().padStart(2, '0');
                        const slotMin = m.toString().padStart(2, '0');
                        const timeValue = `${slotHour}:${slotMin}`;

                        const label = document.createElement('label');
                        const radio = document.createElement('input');
                        radio.type = "radio";
                        radio.name = "appointmentTime";
                        radio.value = timeValue;

                        const span = document.createElement('span');
                        span.textContent = timeValue;

                        label.appendChild(radio);
                        label.appendChild(span);
                        timesContainer.appendChild(label);

                        radio.addEventListener('change', () => {
                            document.querySelectorAll('.appointment-times label').forEach(l => {
                                l.style.backgroundColor = 'white';
                                l.style.color = '#2C3639';
                            });

                            label.style.backgroundColor = 'var(--color-dark)';
                            label.style.color = 'white';

                            bookBtn.disabled = false;
                        });
                    }
                }
            }
        }

        async function bookAppointment() {
            const name = document.getElementById('userName').value.trim();
            const email = document.getElementById('userEmail').value.trim();
            const phone = document.getElementById('userPhone').value.trim();
            const date = document.getElementById('appointmentDate').value;
            const time = document.querySelector('input[name="appointmentTime"]:checked')?.value;
            const type = document.getElementById('appointmentType').value;
            const prescriptionTypeValue = document.getElementById('prescriptionType').value;
            let prescriptionData = null;

            // Validate email
            if (!validateEmail(email)) {
                document.getElementById('userEmail').classList.add('error');
                document.getElementById('emailError').textContent = 'Please enter a valid email address';
                document.getElementById('emailError').style.display = 'block';
                alert("Please enter a valid email address.");
                return;
            }

            // Validate required fields
            if (!name || !email || !phone || !date || !time || !type) {
                alert("Please fill all required fields and select a time.");
                return;
            }

            // Build prescription data object matching Firebase structure
            if (uploadRadio.checked) {
                const fileInput = document.getElementById('prescriptionFile');
                if (fileInput.files.length > 0) {
                    prescriptionData = {
                        Prescription: {
                            type: prescriptionTypeValue || 'unspecified',
                            file: fileInput.files[0].name
                        }
                    };
                }
            } else if (manualRadio.checked) {
                const leftSphere = document.getElementById('leftEyeSphere').value.trim();
                const leftCylinder = document.getElementById('leftEyeCylinder').value.trim();
                const leftAxis = document.getElementById('leftEyeAxis').value.trim();
                const rightSphere = document.getElementById('rightEyeSphere').value.trim();
                const rightCylinder = document.getElementById('rightEyeCylinder').value.trim();
                const rightAxis = document.getElementById('rightEyeAxis').value.trim();
                const pd = document.getElementById('pd').value.trim();

                if (leftSphere || leftCylinder || leftAxis || rightSphere || rightCylinder || rightAxis || pd) {
                    const prescriptionObj = {
                        type: prescriptionTypeValue || 'unspecified'
                    };

                    if (prescriptionTypeValue === 'nearsightedness' || prescriptionTypeValue === 'farsightedness') {
                        prescriptionObj.Near = {
                            left: leftSphere || '0',
                            right: rightSphere || '0'
                        };
                        prescriptionObj.Far = {
                            left: leftCylinder || '0',
                            right: rightCylinder || '0'
                        };
                    } else if (prescriptionTypeValue === 'reading') {
                        prescriptionObj.Reading = {
                            left: leftSphere || '0',
                            right: rightSphere || '0'
                        };
                    } else {
                        prescriptionObj.Left = {
                            sphere: leftSphere || '0',
                            cylinder: leftCylinder || '0',
                            axis: leftAxis || '0'
                        };
                        prescriptionObj.Right = {
                            sphere: rightSphere || '0',
                            cylinder: rightCylinder || '0',
                            axis: rightAxis || '0'
                        };
                    }

                    if (pd) {
                        prescriptionObj.PD = pd;
                    }

                    prescriptionData = {
                        Prescription: prescriptionObj
                    };
                }
            }

            const remarks = document.getElementById('userRemarks').value.trim();

            // Build holdItems object
            const holdItems = {};
            selectedProducts.forEach(p => {
                if (!holdItems[p.id]) {
                    holdItems[p.id] = {};
                }
                holdItems[p.id][p.size] = p.color;
            });

            // Get retailer ID
            const params = new URLSearchParams(window.location.search);
            const retailerId = params.get('retailerId');

            // Create proper timestamp format for dateTime
            const dateTimeISO = `${date}T${time}:00`;

            // Disable button to prevent double submission
            const bookBtn = document.getElementById('bookAppointmentBtn');
            bookBtn.disabled = true;
            bookBtn.textContent = 'Booking...';

            try {
                console.log('Saving appointment via db_handler...');

                // Get user ID if authenticated
                let userId = null;
                if (typeof window.getCurrentUser === 'function') {
                    const user = await window.getCurrentUser();
                    userId = user ? user.uid : null;
                }

                // Prepare payload for db_handler
                const payload = {
                    action: 'addAppointment',
                    storeId: retailerId,
                    userId: userId || '',
                    email: email,
                    name: name,
                    phoneNo: phone,
                    details: remarks || '',
                    type: type.charAt(0).toUpperCase() + type.slice(1),
                    dateTime: dateTimeISO,
                    remarks: remarks || '',
                    status: 'Booked',
                    staffId: '',
                    cancelReason: ''
                };

                // Add prescription if exists
                if (prescriptionData) {
                    payload.prescription = JSON.stringify(prescriptionData);
                }

                // Add holdItems if exists (changed from holdItem to match db_handler)
                if (Object.keys(holdItems).length > 0) {
                    payload.holdItem = JSON.stringify(holdItems);
                }

                console.log('Payload:', JSON.stringify(payload, null, 2));

                // Save appointment using db_handler
                const saveResponse = await fetch('/Handlers/db_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });

                const saveData = await saveResponse.json();
                console.log('Save response:', saveData);

                if (!saveData.success) {
                    throw new Error(saveData.message || 'Failed to save appointment');
                }

                // Send email notification
                console.log('Sending email notification...');
                const emailResponse = await fetch('/Handlers/send_email_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'sendAppointmentEmail',
                        userEmail: email,
                        userName: name,
                        appointmentType: type,
                        appointmentDate: date,
                        appointmentTime: time,
                        retailerName: document.querySelector('.retailer-name').textContent,
                        retailerAddress: document.getElementById('retailerAddress').textContent,
                        holdProducts: selectedProducts,
                        remarks: remarks,
                        prescriptionData: prescriptionData
                    })
                });

                const emailData = await emailResponse.json();
                console.log('Email response:', emailData);

                // Show success message
                alert('Appointment booked successfully! A confirmation email has been sent to ' + email);

                // Redirect back to retailers page
                setTimeout(() => {
                    window.location.href = '/Pages/Customer/find_retailers.aspx';
                }, 1500);

            } catch (err) {
                console.error('Error booking appointment:', err);
                alert('Error booking appointment: ' + err.message);
                bookBtn.disabled = false;
                bookBtn.textContent = 'Book Appointment';
            }
        }
    </script>
</asp:Content>