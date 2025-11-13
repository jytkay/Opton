<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="lenses.aspx.cs" Inherits="Opton.Pages.Customer.lenses" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <script type="module" src="https://unpkg.com/@google/model-viewer@latest/dist/model-viewer.min.js"></script>

    <style>
        .lenses-container {
            display: flex;
            gap: 40px;
            padding: 40px;
            max-width: 1400px;
            margin: 0 auto;
        }

        /* Left Side - Model & Price */
        .lenses-left {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .model-display {
            width: 100%;
            height: 500px;
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

            .model-display model-viewer {
                width: 100%;
                height: 100%;
            }

        .product-info {
            padding: 0 10px;
        }

        .product-name {
            font-size: 24px;
            font-weight: bold;
            color: var(--color-dark);
            margin-bottom: 8px;
        }

        .product-meta {
            font-size: 14px;
            color: #666;
            margin-bottom: 20px;
        }

        .price-breakdown {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 20px;
            border: 2px solid #e9ecef;
        }

        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            font-size: 16px;
        }

            .price-row.total {
                border-top: 2px solid var(--color-dark);
                margin-top: 10px;
                padding-top: 15px;
                font-weight: bold;
                font-size: 20px;
                color: var(--color-dark);
            }

            .price-row .label {
                color: #666;
            }

            .price-row .amount {
                font-weight: 600;
                color: var(--color-dark);
            }

            .price-row.total .amount {
                color: var(--color-accent);
            }

        /* Right Side - Options */
        .lenses-right {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 30px;
        }

        .option-section {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

            .option-section h3 {
                font-size: 20px;
                font-weight: bold;
                color: var(--color-dark);
                margin-bottom: 20px;
                border-bottom: 3px solid var(--color-accent);
                padding-bottom: 10px;
            }

        /* Radio Button Styling */
        .package-options,
        .addon-options {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .option-item {
            display: flex;
            align-items: center;
            padding: 15px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }

            .option-item:hover {
                border-color: var(--color-accent);
                background: #f8f9fa;
            }

            .option-item input[type="radio"],
            .option-item input[type="checkbox"] {
                margin-right: 12px;
                width: 20px;
                height: 20px;
                cursor: pointer;
                accent-color: var(--color-accent);
            }

            .option-item.selected {
                border-color: var(--color-accent);
                background: rgba(162, 123, 92, 0.05);
            }

        .option-label {
            flex: 1;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
        }

        .option-name {
            font-weight: 600;
            color: var(--color-dark);
        }

        .option-price {
            font-weight: 700;
            color: var(--color-accent);
            font-size: 16px;
        }

        /* Prescription Section */
        .prescription-section {
            margin-top: 20px;
            padding: 20px;
            background: #fff9f5;
            border: 2px dashed var(--color-accent);
            border-radius: 8px;
            display: none;
        }

            .prescription-section.active {
                display: block;
            }

            .prescription-section h4 {
                font-size: 16px;
                font-weight: bold;
                color: var(--color-dark);
                margin-bottom: 15px;
            }

        .prescription-mode {
            display: flex;
            gap: 20px;
            margin-bottom: 15px;
        }

            .prescription-mode label {
                cursor: pointer;
                padding: 8px 0;
                font-weight: 500;
                color: #666;
                border-bottom: 2px solid transparent;
                transition: all 0.2s ease;
            }

            .prescription-mode input[type="radio"] {
                display: none;
            }

                .prescription-mode input[type="radio"]:checked + label {
                    border-bottom: 2px solid var(--color-accent);
                    color: var(--color-dark);
                    font-weight: 600;
                }

        .prescription-type-select {
            margin-bottom: 15px;
        }

            .prescription-type-select select,
            .prescription-section input[type="file"] {
                width: 100%;
                padding: 10px;
                border: 1px solid #ddd;
                border-radius: 6px;
                font-size: 14px;
            }

        .manual-prescription-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

            .manual-prescription-table th,
            .manual-prescription-table td {
                padding: 8px;
                text-align: center;
                border: 1px solid #e9ecef;
            }

            .manual-prescription-table th {
                background: #f8f9fa;
                font-weight: 600;
                color: var(--color-dark);
            }

            .manual-prescription-table input {
                width: 100%;
                padding: 6px 8px;
                border: 1px solid #ddd;
                border-radius: 4px;
                text-align: center;
            }

        #manualPrescription {
            display: none;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 20px;
        }

        .action-btn {
            flex: 1;
            padding: 16px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

            .action-btn:disabled {
                background: #ccc;
                color: #666;
                cursor: not-allowed;
                transform: none;
            }

        .save-btn {
            background: #fff;
            color: var(--color-accent);
            border: 2px solid var(--color-accent);
        }

            .save-btn:hover:not(:disabled) {
                background: var(--color-accent);
                color: white;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(162, 123, 92, 0.3);
            }

        .checkout-btn {
            background: var(--color-accent);
            color: white;
        }

            .checkout-btn:hover:not(:disabled) {
                background: #8f6b4f;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(162, 123, 92, 0.4);
            }

        .loading {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 400px;
            font-size: 18px;
        }

        .error-message {
            color: #dc3545;
            font-size: 14px;
            margin-top: 5px;
            display: none;
        }

            .error-message.show {
                display: block;
            }

        @media (max-width: 900px) {
            .lenses-container {
                flex-direction: column;
                padding: 20px;
            }

            .model-display {
                height: 350px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div id="loadingDiv" class="loading">
        <p>Loading product...</p>
    </div>

    <div class="lenses-container" id="lensesContainer" style="display: none;">
        <!-- Left Side -->
        <div class="lenses-left">
            <div class="model-display">
                <model-viewer
                    id="productModel"
                    camera-orbit="0deg 75deg auto"
                    auto-rotate
                    rotation-per-second="20deg"
                    interaction-prompt="none">
                </model-viewer>
            </div>

            <div class="product-info">
                <div class="product-name" id="productName">Loading...</div>
                <div class="product-meta">
                    <span id="productId">#...</span> • <span id="productShape">...</span> • <span id="productColor">...</span>
                </div>

                <div class="price-breakdown">
                    <div class="price-row">
                        <span class="label">Frame Price:</span>
                        <span class="amount" id="framePrice">RM 0.00</span>
                    </div>
                    <div class="price-row" id="packagePriceRow" style="display: none;">
                        <span class="label" id="packageLabel">Package:</span>
                        <span class="amount" id="packagePrice">RM 0.00</span>
                    </div>
                    <div class="price-row" id="addonsPriceRow" style="display: none;">
                        <span class="label">Add-ons:</span>
                        <span class="amount" id="addonsPrice">RM 0.00</span>
                    </div>
                    <div class="price-row total">
                        <span class="label">Total:</span>
                        <span class="amount" id="totalPrice">RM 0.00</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Side -->
        <div class="lenses-right">
            <!-- Package Selection -->
            <div class="option-section">
                <h3>Select Package</h3>
                <div class="package-options">
                    <div class="option-item" onclick="selectPackage('frameOnly', 0)">
                        <input type="radio" name="package" id="pkgFrameOnly" value="frameOnly">
                        <label class="option-label" for="pkgFrameOnly">
                            <span class="option-name">Frame Only</span>
                            <span class="option-price">Included</span>
                        </label>
                    </div>
                    <div class="option-item" onclick="selectPackage('prescription', 150)">
                        <input type="radio" name="package" id="pkgPrescription" value="prescription">
                        <label class="option-label" for="pkgPrescription">
                            <span class="option-name">Single Vision Prescription</span>
                            <span class="option-price">+ RM 150.00</span>
                        </label>
                    </div>
                    <div class="option-item" onclick="selectPackage('readers', 100)">
                        <input type="radio" name="package" id="pkgReaders" value="readers">
                        <label class="option-label" for="pkgReaders">
                            <span class="option-name">Reading Glasses</span>
                            <span class="option-price">+ RM 100.00</span>
                        </label>
                    </div>
                    <div class="option-item" onclick="selectPackage('bifocal', 250)">
                        <input type="radio" name="package" id="pkgBifocal" value="bifocal">
                        <label class="option-label" for="pkgBifocal">
                            <span class="option-name">Bifocal / Progressive</span>
                            <span class="option-price">+ RM 250.00</span>
                        </label>
                    </div>
                </div>

                <!-- Prescription Input -->
                <div class="prescription-section" id="prescriptionSection">
                    <h4>Prescription Details <span style="color: #dc3545;">*</span></h4>

                    <div class="prescription-mode">
                        <input type="radio" id="uploadMode" name="prescriptionMode" checked>
                        <label for="uploadMode">Upload Prescription</label>
                        <input type="radio" id="manualMode" name="prescriptionMode">
                        <label for="manualMode">Manual Input</label>
                    </div>

                    <div class="prescription-type-select">
                        <select id="prescriptionType">
                            <option value="">-- Select Type --</option>
                            <option value="nearsightedness">Nearsightedness (Myopia)</option>
                            <option value="farsightedness">Farsightedness (Hyperopia)</option>
                            <option value="reading">Reading Glasses</option>
                            <option value="multifocal">Multifocal / Progressive</option>
                        </select>
                        <div class="error-message" id="prescriptionTypeError">Please select prescription type</div>
                    </div>

                    <div id="uploadPrescription">
                        <input type="file" id="prescriptionFile" accept=".png,.jpg,.jpeg,.pdf">
                        <small style="color: #666;">Allowed: PNG, JPG, JPEG, PDF</small>
                        <div class="error-message" id="uploadError">Please upload prescription file</div>
                    </div>

                    <div id="manualPrescription">
                        <table class="manual-prescription-table">
                            <thead>
                                <tr>
                                    <th></th>
                                    <th>Right Eye (OD)</th>
                                    <th>Left Eye (OS)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><strong>Sphere (SPH)</strong></td>
                                    <td>
                                        <input type="text" id="rightEyeSphere" placeholder="e.g., -2.00"></td>
                                    <td>
                                        <input type="text" id="leftEyeSphere" placeholder="e.g., -2.00"></td>
                                </tr>
                                <tr>
                                    <td><strong>Cylinder (CYL)</strong></td>
                                    <td>
                                        <input type="text" id="rightEyeCylinder" placeholder="e.g., -0.50"></td>
                                    <td>
                                        <input type="text" id="leftEyeCylinder" placeholder="e.g., -0.50"></td>
                                </tr>
                                <tr>
                                    <td><strong>Axis</strong></td>
                                    <td>
                                        <input type="text" id="rightEyeAxis" placeholder="e.g., 180"></td>
                                    <td>
                                        <input type="text" id="leftEyeAxis" placeholder="e.g., 180"></td>
                                </tr>
                                <tr>
                                    <td><strong>PD</strong></td>
                                    <td colspan="2">
                                        <input type="text" id="pd" placeholder="e.g., 63"></td>
                                </tr>
                            </tbody>
                        </table>
                        <div class="error-message" id="manualError">Please fill in at least Sphere values</div>
                    </div>
                </div>
            </div>

            <!-- Add-ons Selection -->
            <div class="option-section">
                <h3>Select Add-ons (Optional)</h3>
                <div class="addon-options">
                    <div class="option-item" onclick="toggleAddon('blueLight', 50, this)">
                        <input type="checkbox" id="addonBlueLight" value="blueLight">
                        <label class="option-label" for="addonBlueLight">
                            <span class="option-name">Blue Light Filter</span>
                            <span class="option-price">+ RM 50.00</span>
                        </label>
                    </div>
                    <div class="option-item" onclick="toggleAddon('transition', 120, this)">
                        <input type="checkbox" id="addonTransition" value="transition">
                        <label class="option-label" for="addonTransition">
                            <span class="option-name">Transition Lenses</span>
                            <span class="option-price">+ RM 120.00</span>
                        </label>
                    </div>
                    <div class="option-item" onclick="toggleAddon('polarized', 100, this)">
                        <input type="checkbox" id="addonPolarized" value="polarized">
                        <label class="option-label" for="addonPolarized">
                            <span class="option-name">Polarized</span>
                            <span class="option-price">+ RM 100.00</span>
                        </label>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="action-buttons">
                <button type="button" class="action-btn save-btn" id="saveToCartBtn" disabled onclick="saveToCart()">
                    <i class="ri-shopping-cart-line"></i>Save to Cart
               
                </button>
                <button type="button" class="action-btn checkout-btn" id="checkoutBtn" disabled onclick="checkout()">
                    <i class="ri-secure-payment-line"></i>Checkout
               
                </button>
            </div>
        </div>
    </div>

    <script>
        let productData = null;
        let selectedColor = null;
        let basePrice = 0;
        let packagePrice = 0;
        let addonsPrice = 0;
        let selectedPackage = null;
        let selectedAddons = [];

        // Color map from product.aspx
        const colorMap = {
            black: [0, 0, 0, 1],
            brown: [0.235, 0.129, 0, 0.8],
            white: [1, 1, 1, 1],
            red: [0.8, 0.1, 0.1, 1],
            orange: [1, 0.561, 0.024, 0.8],
            green: [0.1, 0.5, 0.1, 1],
            blue: [0.1, 0.3, 0.8, 1],
            purple: [0.6, 0.2, 0.8, 1],
            pink: [1, 0.4, 0.7, 1],
            gold: [0.85, 0.7, 0.3, 1],
            silver: [0.75, 0.75, 0.75, 1]
        };

        // Get parameters from URL
        function getURLParams() {
            const params = new URLSearchParams(window.location.search);
            return {
                productId: params.get('id'),
                color: params.get('color') || 'black'
            };
        }

        // Fetch product data
        async function fetchProduct() {
            const { productId, color } = getURLParams();
            selectedColor = color;

            if (!productId) {
                alert('No product ID provided');
                window.location.href = '/Pages/Customer/catalogue.aspx';
                return;
            }

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'getProduct',
                        productId: productId
                    })
                });

                const data = await response.json();

                if (data.success && data.product) {
                    productData = data.product;
                    basePrice = productData.price || 0;
                    populateProductData();
                    await loadModel();
                } else {
                    alert('Product not found');
                    window.location.href = '/Pages/Customer/catalogue.aspx';
                }
            } catch (error) {
                console.error('Error fetching product:', error);
                alert('Failed to load product');
            }
        }

        // Populate product information
        function populateProductData() {
            document.getElementById('productName').textContent = productData.name || 'Unknown Product';
            document.getElementById('productId').textContent = `#${productData.productId || productData.id || ''}`;
            document.getElementById('productShape').textContent = productData.shape || '';
            document.getElementById('productColor').textContent = selectedColor.charAt(0).toUpperCase() + selectedColor.slice(1);
            document.getElementById('framePrice').textContent = `RM ${basePrice.toFixed(2)}`;
            document.getElementById('totalPrice').textContent = `RM ${basePrice.toFixed(2)}`;

            document.getElementById('loadingDiv').style.display = 'none';
            document.getElementById('lensesContainer').style.display = 'flex';
        }

        // Load 3D model
        async function loadModel() {
            const productId = productData.productId || productData.id;
            const modelFiles = productData.model ? productData.model.split(', ') : [];
            const glbFiles = modelFiles.filter(f => f.toLowerCase().endsWith('.glb'));

            if (glbFiles.length === 0) {
                console.log('No 3D model available');
                return;
            }

            // Find color-specific model or use default
            let modelFile = glbFiles[0];
            for (const file of glbFiles) {
                if (file.toLowerCase().includes(selectedColor.toLowerCase())) {
                    modelFile = file;
                    break;
                }
            }

            const path = `Products/${productId}/${modelFile}`;
            const modelUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(path)}?alt=media`;

            const modelViewer = document.getElementById('productModel');
            modelViewer.src = modelUrl;

            modelViewer.addEventListener('load', () => {
                applyColorToModel(modelViewer, selectedColor);
            });
        }

        // Apply color to model
        async function applyColorToModel(modelViewer, color) {
            await modelViewer.updateComplete;
            const materials = modelViewer.model?.materials || [];
            const frameColor = colorMap[color.toLowerCase()] || [0, 0, 0, 1];

            materials.forEach(mat => {
                if (!mat.pbrMetallicRoughness) return;
                const alpha = mat.pbrMetallicRoughness.baseColorFactor?.[3] ?? 1;

                if (alpha < 1) {
                    mat.pbrMetallicRoughness.setBaseColorFactor([1, 1, 1, 0.25]);
                } else {
                    mat.pbrMetallicRoughness.setBaseColorFactor(frameColor);
                }
            });
        }

        // Select package
        function selectPackage(packageType, price) {
            // Remove previous selection
            document.querySelectorAll('.package-options .option-item').forEach(item => {
                item.classList.remove('selected');
            });

            // Add selection to clicked item
            event.currentTarget.classList.add('selected');

            selectedPackage = packageType;
            packagePrice = price;

            // Update price display
            const packagePriceRow = document.getElementById('packagePriceRow');
            const packageLabel = document.getElementById('packageLabel');

            if (price > 0) {
                packagePriceRow.style.display = 'flex';
                packageLabel.textContent = `Package (${getPackageName(packageType)}):`;
                document.getElementById('packagePrice').textContent = `RM ${price.toFixed(2)}`;
            } else {
                packagePriceRow.style.display = 'none';
            }

            // Show/hide prescription section
            const prescriptionSection = document.getElementById('prescriptionSection');
            if (packageType !== 'frameOnly') {
                prescriptionSection.classList.add('active');
            } else {
                prescriptionSection.classList.remove('active');
                clearPrescriptionErrors();
            }

            updateTotalPrice();
            validateForm();
        }

        function getPackageName(type) {
            const names = {
                'prescription': 'Single Vision',
                'readers': 'Reading Glasses',
                'bifocal': 'Bifocal/Progressive'
            };
            return names[type] || type;
        }

        // Toggle addon
        function toggleAddon(addonType, price, element) {
            const checkbox = element.querySelector('input[type="checkbox"]');
            checkbox.checked = !checkbox.checked;

            if (checkbox.checked) {
                element.classList.add('selected');
                selectedAddons.push({ type: addonType, price: price });
            } else {
                element.classList.remove('selected');
                selectedAddons = selectedAddons.filter(a => a.type !== addonType);
            }

            // Update addons price
            addonsPrice = selectedAddons.reduce((sum, addon) => sum + addon.price, 0);

            const addonsPriceRow = document.getElementById('addonsPriceRow');
            if (addonsPrice > 0) {
                addonsPriceRow.style.display = 'flex';
                document.getElementById('addonsPrice').textContent = `RM ${addonsPrice.toFixed(2)}`;
            } else {
                addonsPriceRow.style.display = 'none';
            }

            updateTotalPrice();
        }

        // Update total price
        function updateTotalPrice() {
            const total = basePrice + packagePrice + addonsPrice;
            document.getElementById('totalPrice').textContent = `RM ${total.toFixed(2)}`;
        }

        // Prescription mode toggle
        document.getElementById('uploadMode').addEventListener('change', function () {
            if (this.checked) {
                document.getElementById('uploadPrescription').style.display = 'block';
                document.getElementById('manualPrescription').style.display = 'none';
                clearPrescriptionErrors();
            }
        });

        document.getElementById('manualMode').addEventListener('change', function () {
            if (this.checked) {
                document.getElementById('uploadPrescription').style.display = 'none';
                document.getElementById('manualPrescription').style.display = 'block';
                clearPrescriptionErrors();
            }
        });

        // Form validation
        function validateForm() {
            let isValid = true;

            // Check if package is selected
            if (!selectedPackage) {
                isValid = false;
            }

            // If package requires prescription, validate it
            if (selectedPackage && selectedPackage !== 'frameOnly') {
                isValid = validatePrescription();
            }

            // Enable/disable buttons
            document.getElementById('saveToCartBtn').disabled = !isValid;
            document.getElementById('checkoutBtn').disabled = !isValid;

            return isValid;
        }

        function validatePrescription() {
            clearPrescriptionErrors();

            const prescriptionType = document.getElementById('prescriptionType').value;
            if (!prescriptionType) {
                document.getElementById('prescriptionTypeError').classList.add('show');
                return false;
            }

            const uploadMode = document.getElementById('uploadMode').checked;

            if (uploadMode) {
                const fileInput = document.getElementById('prescriptionFile');
                if (!fileInput.files.length) {
                    document.getElementById('uploadError').classList.add('show');
                    return false;
                }
            } else {
                // Manual mode - check if at least sphere values are filled
                const rightSphere = document.getElementById('rightEyeSphere').value.trim();
                const leftSphere = document.getElementById('leftEyeSphere').value.trim();

                if (!rightSphere || !leftSphere) {
                    document.getElementById('manualError').classList.add('show');
                    return false;
                }
            }

            return true;
        }

        function clearPrescriptionErrors() {
            document.querySelectorAll('.error-message').forEach(el => {
                el.classList.remove('show');
            });
        }

        // Add event listeners for validation
        document.getElementById('prescriptionType').addEventListener('change', validateForm);
        document.getElementById('prescriptionFile').addEventListener('change', validateForm);
        document.querySelectorAll('#manualPrescription input').forEach(input => {
            input.addEventListener('input', validateForm);
        });

        // Save to cart
        function saveToCart() {
            if (!validateForm()) {
                alert('Please complete all required fields');
                return;
            }

            const cartData = collectFormData();
            console.log('Saving to cart:', cartData);
            alert('Product configuration saved to cart!');
            // TODO: Implement actual cart saving logic
        }

        // Checkout
        function checkout() {
            if (!validateForm()) {
                alert('Please complete all required fields');
                return;
            }

            const formData = collectFormData();

            // Format data to match fav_cart.aspx structure (array of items)
            const orderData = {
                items: [{
                    product: formData.product,
                    package: formData.package,
                    addons: formData.addons,
                    prescription: formData.prescription,
                    quantity: 1,
                    prices: formData.prices
                }]
            };

            // Store order data in sessionStorage for checkout page
            sessionStorage.setItem('checkoutData', JSON.stringify(orderData));

            // Redirect to checkout
            window.location.href = '/Pages/Customer/checkout.aspx';
        }

        // Collect form data
        function collectFormData() {
            const data = {
                product: {
                    id: productData.productId || productData.id,
                    name: productData.name,
                    color: selectedColor
                },
                package: {
                    type: selectedPackage,
                    price: packagePrice
                },
                addons: selectedAddons,
                prices: {
                    base: basePrice,
                    package: packagePrice,
                    addons: addonsPrice,
                    total: basePrice + packagePrice + addonsPrice
                }
            };

            // Add prescription if applicable
            if (selectedPackage !== 'frameOnly') {
                data.prescription = {
                    type: document.getElementById('prescriptionType').value
                };

                if (document.getElementById('uploadMode').checked) {
                    const fileInput = document.getElementById('prescriptionFile');
                    data.prescription.mode = 'upload';
                    data.prescription.fileName = fileInput.files[0]?.name;
                } else {
                    data.prescription.mode = 'manual';
                    data.prescription.rightEye = {
                        sphere: document.getElementById('rightEyeSphere').value.trim(),
                        cylinder: document.getElementById('rightEyeCylinder').value.trim(),
                        axis: document.getElementById('rightEyeAxis').value.trim()
                    };
                    data.prescription.leftEye = {
                        sphere: document.getElementById('leftEyeSphere').value.trim(),
                        cylinder: document.getElementById('leftEyeCylinder').value.trim(),
                        axis: document.getElementById('leftEyeAxis').value.trim()
                    };
                    data.prescription.pd = document.getElementById('pd').value.trim();
                }
            }

            return data;
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', fetchProduct);
    </script>
</asp:Content>
