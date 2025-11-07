<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="checkout.aspx.cs" Inherits="Opton.Pages.Customer.checkout" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <script type="module" src="https://unpkg.com/@google/model-viewer@latest/dist/model-viewer.min.js"></script>
    <script src="https://js.stripe.com/v3/"></script>
    
    <style>
        .checkout-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 20px;
        }

        .checkout-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .checkout-header h1 {
            font-size: 32px;
            font-weight: bold;
            color: var(--color-dark);
            margin-bottom: 10px;
        }

        .checkout-header p {
            color: #666;
            font-size: 16px;
        }

        .checkout-content {
            display: flex;
            flex-direction: column;
            gap: 30px;
        }

        .checkout-section {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

        .section-title {
            font-size: 22px;
            font-weight: bold;
            color: var(--color-dark);
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 3px solid var(--color-accent);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title i {
            font-size: 24px;
            color: var(--color-accent);
        }

        /* Shipping Details */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            font-weight: 600;
            color: var(--color-dark);
            font-size: 14px;
        }

        .form-group label .required {
            color: #dc3545;
            margin-left: 4px;
        }

        .form-group input,
        .form-group textarea {
            padding: 12px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.2s ease;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: var(--color-accent);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        /* Items Section */
        .order-items {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .order-item {
            display: flex;
            gap: 20px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 12px;
            border: 2px solid #e9ecef;
        }

        .item-model {
            flex: 0 0 200px;
            height: 200px;
            background: white;
            border-radius: 8px;
            padding: 10px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .item-model model-viewer {
            width: 100%;
            height: 100%;
        }

        .item-details {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .item-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
        }

        .item-name {
            font-size: 20px;
            font-weight: bold;
            color: var(--color-dark);
        }

        .item-price {
            font-size: 20px;
            font-weight: bold;
            color: var(--color-accent);
        }

        .item-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            color: #666;
            font-size: 14px;
        }

        .item-meta .meta-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .item-meta .meta-item strong {
            color: var(--color-dark);
        }

        .item-specs {
            display: flex;
            flex-direction: column;
            gap: 8px;
            padding-top: 10px;
            border-top: 1px solid #dee2e6;
        }

        .spec-row {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
        }

        .spec-label {
            color: #666;
            font-weight: 500;
        }

        .spec-value {
            color: var(--color-dark);
            font-weight: 600;
        }

        .prescription-details {
            background: #fff9f5;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #ffc107;
            margin-top: 10px;
        }

        .prescription-details h4 {
            font-size: 14px;
            font-weight: bold;
            color: var(--color-dark);
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .prescription-details h4 i {
            color: #ffc107;
        }

        .prescription-table {
            width: 100%;
            font-size: 13px;
            margin-top: 8px;
        }

        .prescription-table td {
            padding: 4px 8px;
        }

        .prescription-table td:first-child {
            color: #666;
            font-weight: 500;
        }

        .prescription-table td:last-child {
            color: var(--color-dark);
            font-weight: 600;
            text-align: right;
        }

        /* Payment Options */
        .payment-options {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }

        .payment-option {
            padding: 20px;
            border: 2px solid #e9ecef;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
            text-align: center;
        }

        .payment-option:hover {
            border-color: var(--color-accent);
            background: #f8f9fa;
        }

        .payment-option.selected {
            border-color: var(--color-accent);
            background: rgba(162, 123, 92, 0.05);
        }

        .payment-option input[type="radio"] {
            display: none;
        }

        .payment-option i {
            font-size: 36px;
            color: var(--color-accent);
        }

        .payment-option .payment-name {
            font-weight: 600;
            color: var(--color-dark);
        }

        /* Stripe Card Element Container */
        #card-element {
            padding: 12px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            background: white;
            margin-top: 15px;
            display: none;
        }

        #card-element.show {
            display: block;
        }

        #card-errors {
            color: #dc3545;
            font-size: 14px;
            margin-top: 10px;
            display: none;
        }

        #card-errors.show {
            display: block;
        }

        /* FPX/Online Banking Options */
        #fpx-options {
            display: none;
            margin-top: 15px;
        }

        #fpx-options.show {
            display: block;
        }

        .bank-options {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 10px;
            margin-top: 10px;
        }

        .bank-option {
            padding: 15px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            cursor: pointer;
            text-align: center;
            transition: all 0.2s ease;
        }

        .bank-option:hover {
            border-color: var(--color-accent);
            background: #f8f9fa;
        }

        .bank-option.selected {
            border-color: var(--color-accent);
            background: rgba(162, 123, 92, 0.05);
        }

        .bank-option input[type="radio"] {
            display: none;
        }

        /* Order Summary */
        .order-summary {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 12px;
            border: 2px solid #e9ecef;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            font-size: 16px;
        }

        .summary-row.subtotal {
            border-top: 1px solid #dee2e6;
            margin-top: 10px;
            padding-top: 15px;
        }

        .summary-row.total {
            border-top: 2px solid var(--color-dark);
            margin-top: 10px;
            padding-top: 15px;
            font-size: 22px;
            font-weight: bold;
            color: var(--color-dark);
        }

        .summary-row.total .amount {
            color: var(--color-accent);
        }

        .summary-label {
            color: #666;
            font-weight: 500;
        }

        .summary-amount {
            font-weight: 600;
            color: var(--color-dark);
        }

        /* Action Buttons */
        .checkout-actions {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 40px;
        }

        .checkout-btn {
            padding: 16px 40px;
            border: none;
            border-radius: 10px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .cancel-btn {
            background: #fff;
            color: #666;
            border: 2px solid #dee2e6;
        }

        .cancel-btn:hover {
            background: #f8f9fa;
            border-color: #adb5bd;
            transform: translateY(-2px);
        }

        .confirm-btn {
            background: var(--color-accent);
            color: white;
        }

        .confirm-btn:hover {
            background: #8f6b4f;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(162, 123, 92, 0.4);
        }

        .confirm-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        .loading {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 400px;
            font-size: 18px;
        }

        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }

            .order-item {
                flex-direction: column;
            }

            .item-model {
                flex: 0 0 auto;
                width: 100%;
                height: 250px;
            }

            .checkout-actions {
                flex-direction: column;
            }

            .checkout-btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div id="loadingDiv" class="loading">
        <p>Loading checkout...</p>
    </div>

    <div class="checkout-container" id="checkoutContainer" style="display: none;">
        <div class="checkout-header">
            <h1>Checkout</h1>
            <p>Complete your order details below</p>
        </div>

        <div class="checkout-content">
            <!-- Shipping Details Section -->
            <div class="checkout-section">
                <div class="section-title">
                    <i class="ri-truck-line"></i>
                    Shipping Details
                </div>
                <div class="form-grid">
                    <div class="form-group">
                        <label>Full Name <span class="required">*</span></label>
                        <input type="text" id="fullName" placeholder="John Doe" required>
                    </div>
                    <div class="form-group">
                        <label>Email Address <span class="required">*</span></label>
                        <input type="email" id="email" placeholder="john@example.com" required>
                    </div>
                    <div class="form-group">
                        <label>Phone Number <span class="required">*</span></label>
                        <input type="tel" id="phone" placeholder="60123456789" required>
                    </div>
                    <div class="form-group">
                        <label>Postal Code <span class="required">*</span></label>
                        <input type="text" id="postalCode" placeholder="10250" required>
                    </div>
                    <div class="form-group full-width">
                        <label>Street Address <span class="required">*</span></label>
                        <input type="text" id="address" placeholder="123 Jalan Example" required>
                    </div>
                    <div class="form-group">
                        <label>City <span class="required">*</span></label>
                        <input type="text" id="city" placeholder="George Town" required>
                    </div>
                    <div class="form-group">
                        <label>State <span class="required">*</span></label>
                        <input type="text" id="state" placeholder="Penang" required>
                    </div>
                    <div class="form-group full-width">
                        <label>Additional Notes (Optional)</label>
                        <textarea id="notes" placeholder="Any special delivery instructions..."></textarea>
                    </div>
                </div>
            </div>

            <!-- Items Section -->
            <div class="checkout-section">
                <div class="section-title">
                    <i class="ri-shopping-bag-3-line"></i>
                    Order Items
                </div>
                <div class="order-items" id="orderItems">
                    <!-- Items will be dynamically loaded here -->
                </div>
            </div>

            <!-- Payment Options Section -->
            <div class="checkout-section">
                <div class="section-title">
                    <i class="ri-bank-card-line"></i>
                    Payment Method
                </div>
                <div class="payment-options">
                    <div class="payment-option" onclick="selectPayment('card', this)">
                        <input type="radio" name="payment" id="payCard" value="card">
                        <i class="ri-bank-card-2-line"></i>
                        <span class="payment-name">Credit/Debit Card</span>
                    </div>
                    <div class="payment-option" onclick="selectPayment('ewallet', this)">
                        <input type="radio" name="payment" id="payEwallet" value="ewallet">
                        <i class="ri-wallet-3-line"></i>
                        <span class="payment-name">E-Wallet</span>
                    </div>
                    <div class="payment-option" onclick="selectPayment('online', this)">
                        <input type="radio" name="payment" id="payOnline" value="online">
                        <i class="ri-bank-line"></i>
                        <span class="payment-name">Online Banking</span>
                    </div>
                    <div class="payment-option" onclick="selectPayment('cod', this)">
                        <input type="radio" name="payment" id="payCod" value="cod">
                        <i class="ri-hand-coin-line"></i>
                        <span class="payment-name">Cash on Delivery</span>
                    </div>
                </div>

                <!-- Stripe Card Element (for card payments) -->
                <div id="card-element"></div>
                <div id="card-errors"></div>

                <!-- FPX/Online Banking Options -->
                <div id="fpx-options">
                    <p style="font-weight: 600; margin-bottom: 10px;">Select your bank:</p>
                    <div class="bank-options">
                        <div class="bank-option" onclick="selectBank('maybank2u', this)">
                            <input type="radio" name="bank" value="maybank2u">
                            <span>Maybank2u</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('cimb', this)">
                            <input type="radio" name="bank" value="cimb">
                            <span>CIMB Clicks</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('public_bank', this)">
                            <input type="radio" name="bank" value="public_bank">
                            <span>Public Bank</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('rhb', this)">
                            <input type="radio" name="bank" value="rhb">
                            <span>RHB Now</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('hong_leong_bank', this)">
                            <input type="radio" name="bank" value="hong_leong_bank">
                            <span>Hong Leong Bank</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('ambank', this)">
                            <input type="radio" name="bank" value="ambank">
                            <span>AmBank</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('affin_bank', this)">
                            <input type="radio" name="bank" value="affin_bank">
                            <span>Affin Bank</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('alliance_bank', this)">
                            <input type="radio" name="bank" value="alliance_bank">
                            <span>Alliance Bank</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('bank_islam', this)">
                            <input type="radio" name="bank" value="bank_islam">
                            <span>Bank Islam</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('bank_rakyat', this)">
                            <input type="radio" name="bank" value="bank_rakyat">
                            <span>Bank Rakyat</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('hsbc', this)">
                            <input type="radio" name="bank" value="hsbc">
                            <span>HSBC Bank</span>
                        </div>
                        <div class="bank-option" onclick="selectBank('ocbc', this)">
                            <input type="radio" name="bank" value="ocbc">
                            <span>OCBC Bank</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Order Summary Section -->
            <div class="checkout-section">
                <div class="section-title">
                    <i class="ri-file-list-3-line"></i>
                    Order Summary
                </div>
                <div class="order-summary">
                    <div class="summary-row">
                        <span class="summary-label">Frame Price:</span>
                        <span class="summary-amount" id="summaryFrame">RM 0.00</span>
                    </div>
                    <div class="summary-row" id="summaryPackageRow" style="display: none;">
                        <span class="summary-label" id="summaryPackageLabel">Package:</span>
                        <span class="summary-amount" id="summaryPackage">RM 0.00</span>
                    </div>
                    <div class="summary-row" id="summaryAddonsRow" style="display: none;">
                        <span class="summary-label">Add-ons:</span>
                        <span class="summary-amount" id="summaryAddons">RM 0.00</span>
                    </div>
                    <div class="summary-row subtotal">
                        <span class="summary-label">Subtotal:</span>
                        <span class="summary-amount" id="summarySubtotal">RM 0.00</span>
                    </div>
                    <div class="summary-row">
                        <span class="summary-label">Shipping:</span>
                        <span class="summary-amount" id="summaryShipping">RM 15.00</span>
                    </div>
                    <div class="summary-row total">
                        <span class="summary-label">Total:</span>
                        <span class="amount" id="summaryTotal">RM 0.00</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="checkout-actions">
            <button class="checkout-btn cancel-btn" onclick="cancelCheckout()">
                <i class="ri-close-line"></i>
                Cancel
            </button>
            <button class="checkout-btn confirm-btn" id="confirmBtn" disabled onclick="confirmPayment()">
                <i class="ri-secure-payment-line"></i>
                Confirm Payment
            </button>
        </div>
    </div>

    <script>
        let checkoutData = null;
        let selectedPayment = null;
        let selectedBank = null;
        let stripe = null;
        let cardElement = null;
        let stripePublishableKey = null;
        const SHIPPING_COST = 15.00;

        // Color map
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

        // Load checkout data
        async function loadCheckoutData() {
            const data = sessionStorage.getItem('checkoutData');

            if (!data) {
                alert('No order data found. Redirecting to catalogue...');
                window.location.href = '/Pages/Customer/catalogue.aspx';
                return;
            }

            checkoutData = JSON.parse(data);
            console.log('Checkout data loaded:', checkoutData);

            // Initialize Stripe
            await initializeStripe();

            populateOrderItems();
            populateOrderSummary();
            loadUserData();

            document.getElementById('loadingDiv').style.display = 'none';
            document.getElementById('checkoutContainer').style.display = 'block';
        }

        // Initialize Stripe
        async function initializeStripe() {
            try {
                const response = await fetch('/Handlers/get_keys.ashx');
                const data = await response.json();

                if (data.success && data.apiKeys.STRIPE_PUBLISHABLE_KEY) {
                    stripePublishableKey = data.apiKeys.STRIPE_PUBLISHABLE_KEY;
                    stripe = Stripe(stripePublishableKey);

                    // Create card element
                    const elements = stripe.elements();
                    cardElement = elements.create('card', {
                        style: {
                            base: {
                                fontSize: '16px',
                                color: '#2C3639',
                                '::placeholder': {
                                    color: '#adb5bd',
                                },
                            },
                            invalid: {
                                color: '#dc3545',
                            },
                        },
                    });

                    cardElement.mount('#card-element');

                    // Handle card errors
                    cardElement.on('change', (event) => {
                        const displayError = document.getElementById('card-errors');
                        if (event.error) {
                            displayError.textContent = event.error.message;
                            displayError.classList.add('show');
                        } else {
                            displayError.textContent = '';
                            displayError.classList.remove('show');
                        }
                    });

                    console.log('Stripe initialized successfully');
                } else {
                    console.error('Failed to load Stripe key');
                }
            } catch (error) {
                console.error('Error initializing Stripe:', error);
            }
        }

        // Load user data if logged in
        async function loadUserData() {
            const idToken = localStorage.getItem('idToken');
            if (!idToken) return;

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'getUserProfile',
                        idToken: idToken
                    })
                });

                const data = await response.json();
                if (data.success && data.user) {
                    // Pre-fill form with user data
                    document.getElementById('fullName').value = data.user.name || '';
                    document.getElementById('email').value = data.user.email || '';
                    document.getElementById('phone').value = data.user.phone || '';
                }
            } catch (error) {
                console.error('Error loading user data:', error);
            }
        }

        // Populate order items
        async function populateOrderItems() {
            const container = document.getElementById('orderItems');
            const product = checkoutData.product;

            // Fetch full product data
            const response = await fetch('/Handlers/fire_handler.ashx', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    action: 'getProduct',
                    productId: product.id
                })
            });

            const productDataResponse = await response.json();
            const fullProduct = productDataResponse.product;

            // Build item HTML
            const itemHTML = `
                <div class="order-item">
                    <div class="item-model">
                        <model-viewer 
                            id="orderModel" 
                            camera-orbit="0deg 75deg auto" 
                            interaction-prompt="none">
                        </model-viewer>
                    </div>
                    <div class="item-details">
                        <div class="item-header">
                            <div>
                                <div class="item-name">${product.name}</div>
                                <div class="item-meta">
                                    <div class="meta-item">
                                        <strong>ID:</strong> #${product.id}
                                    </div>
                                    <div class="meta-item">
                                        <strong>Color:</strong> ${capitalizeFirst(product.color)}
                                    </div>
                                    <div class="meta-item">
                                        <strong>Shape:</strong> ${fullProduct.shape || 'N/A'}
                                    </div>
                                    <div class="meta-item">
                                        <strong>Qty:</strong> 1
                                    </div>
                                </div>
                            </div>
                            <div class="item-price">RM ${checkoutData.prices.total.toFixed(2)}</div>
                        </div>

                        <div class="item-specs">
                            <div class="spec-row">
                                <span class="spec-label">Frame Price:</span>
                                <span class="spec-value">RM ${checkoutData.prices.base.toFixed(2)}</span>
                            </div>
                            ${checkoutData.package.price > 0 ? `
                            <div class="spec-row">
                                <span class="spec-label">Package (${getPackageName(checkoutData.package.type)}):</span>
                                <span class="spec-value">RM ${checkoutData.package.price.toFixed(2)}</span>
                            </div>
                            ` : ''}
                            ${checkoutData.addons.length > 0 ? `
                            <div class="spec-row">
                                <span class="spec-label">Add-ons (${checkoutData.addons.map(a => getAddonName(a.type)).join(', ')}):</span>
                                <span class="spec-value">RM ${checkoutData.prices.addons.toFixed(2)}</span>
                            </div>
                            ` : ''}
                        </div>

                        ${checkoutData.prescription ? `
                        <div class="prescription-details">
                            <h4><i class="ri-eye-line"></i> Prescription Details</h4>
                            <table class="prescription-table">
                                <tr>
                                    <td>Type:</td>
                                    <td>${getPrescriptionTypeName(checkoutData.prescription.type)}</td>
                                </tr>
                                ${checkoutData.prescription.mode === 'manual' ? `
                                <tr>
                                    <td>Right Eye (SPH):</td>
                                    <td>${checkoutData.prescription.rightEye.sphere || 'N/A'}</td>
                                </tr>
                                <tr>
                                    <td>Left Eye (SPH):</td>
                                    <td>${checkoutData.prescription.leftEye.sphere || 'N/A'}</td>
                                </tr>
                                <tr>
                                    <td>Right Eye (CYL):</td>
                                    <td>${checkoutData.prescription.rightEye.cylinder || 'N/A'}</td>
                                </tr>
                                <tr>
                                    <td>Left Eye (CYL):</td>
                                    <td>${checkoutData.prescription.leftEye.cylinder || 'N/A'}</td>
                                </tr>
                                <tr>
                                    <td>Right Eye (AXIS):</td>
                                    <td>${checkoutData.prescription.rightEye.axis || 'N/A'}</td>
                                </tr>
                                <tr>
                                    <td>Left Eye (AXIS):</td>
                                    <td>${checkoutData.prescription.leftEye.axis || 'N/A'}</td>
                                </tr>
                                <tr>
                                    <td>PD:</td>
                                    <td>${checkoutData.prescription.pd || 'N/A'}</td>
                                </tr>
                                ` : `
                                <tr>
                                    <td>File:</td>
                                    <td>${checkoutData.prescription.fileName}</td>
                                </tr>
                                `}
                            </table>
                        </div>
                        ` : ''}
                    </div>
                </div>
            `;

            container.innerHTML = itemHTML;

            // Load 3D model
            await loadProductModel(fullProduct, product.color);
        }

        // Load product model
        async function loadProductModel(productData, color) {
            const modelFiles = productData.model ? productData.model.split(', ') : [];
            const glbFiles = modelFiles.filter(f => f.toLowerCase().endsWith('.glb'));

            if (glbFiles.length === 0) return;

            let modelFile = glbFiles[0];
            for (const file of glbFiles) {
                if (file.toLowerCase().includes(color.toLowerCase())) {
                    modelFile = file;
                    break;
                }
            }

            const path = `Products/${productData.productId || productData.id}/${modelFile}`;
            const modelUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(path)}?alt=media`;

            const modelViewer = document.getElementById('orderModel');
            modelViewer.src = modelUrl;

            modelViewer.addEventListener('load', () => {
                applyColorToModel(modelViewer, color);
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

        // Populate order summary
        function populateOrderSummary() {
            document.getElementById('summaryFrame').textContent = `RM ${checkoutData.prices.base.toFixed(2)}`;

            if (checkoutData.prices.package > 0) {
                document.getElementById('summaryPackageRow').style.display = 'flex';
                document.getElementById('summaryPackageLabel').textContent = `Package (${getPackageName(checkoutData.package.type)}):`;
                document.getElementById('summaryPackage').textContent = `RM ${checkoutData.prices.package.toFixed(2)}`;
            }

            if (checkoutData.prices.addons > 0) {
                document.getElementById('summaryAddonsRow').style.display = 'flex';
                document.getElementById('summaryAddons').textContent = `RM ${checkoutData.prices.addons.toFixed(2)}`;
            }

            const subtotal = checkoutData.prices.total;
            document.getElementById('summarySubtotal').textContent = `RM ${subtotal.toFixed(2)}`;

            const total = subtotal + SHIPPING_COST;
            document.getElementById('summaryTotal').textContent = `RM ${total.toFixed(2)}`;
        }

        // Select payment method
        function selectPayment(method, element) {
            document.querySelectorAll('.payment-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            element.classList.add('selected');
            element.querySelector('input').checked = true;
            selectedPayment = method;

            // Show/hide card element
            const cardElementDiv = document.getElementById('card-element');
            const fpxOptionsDiv = document.getElementById('fpx-options');

            if (method === 'card') {
                cardElementDiv.classList.add('show');
                fpxOptionsDiv.classList.remove('show');
            } else if (method === 'ewallet' || method === 'online') {
                cardElementDiv.classList.remove('show');
                fpxOptionsDiv.classList.add('show');
            } else {
                cardElementDiv.classList.remove('show');
                fpxOptionsDiv.classList.remove('show');
            }

            validateForm();
        }

        // Select bank
        function selectBank(bank, element) {
            document.querySelectorAll('.bank-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            element.classList.add('selected');
            element.querySelector('input').checked = true;
            selectedBank = bank;
            validateForm();
        }

        // Validate form
        function validateForm() {
            const fullName = document.getElementById('fullName').value.trim();
            const email = document.getElementById('email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const address = document.getElementById('address').value.trim();
            const city = document.getElementById('city').value.trim();
            const state = document.getElementById('state').value.trim();
            const postalCode = document.getElementById('postalCode').value.trim();

            let isFormValid = fullName && email && phone && address && city && state && postalCode && selectedPayment;

            // For FPX payments, also check if bank is selected
            if ((selectedPayment === 'ewallet' || selectedPayment === 'online') && !selectedBank) {
                isFormValid = false;
            }

            document.getElementById('confirmBtn').disabled = !isFormValid;
        }

        // Add event listeners for form validation
        document.addEventListener('DOMContentLoaded', () => {
            const formInputs = ['fullName', 'email', 'phone', 'address', 'city', 'state', 'postalCode'];
            formInputs.forEach(id => {
                const element = document.getElementById(id);
                if (element) {
                    element.addEventListener('input', validateForm);
                }
            });
        });

        // Cancel checkout
        function cancelCheckout() {
            if (confirm('Are you sure you want to cancel this order?')) {
                sessionStorage.removeItem('checkoutData');
                window.location.href = '/Pages/Customer/catalogue.aspx';
            }
        }

        // Confirm payment
        async function confirmPayment() {
            const confirmBtn = document.getElementById('confirmBtn');
            confirmBtn.disabled = true;
            confirmBtn.innerHTML = '<i class="ri-loader-4-line"></i> Processing...';

            try {
                // Collect order data
                const orderData = {
                    customer: {
                        fullName: document.getElementById('fullName').value.trim(),
                        email: document.getElementById('email').value.trim(),
                        phone: document.getElementById('phone').value.trim(),
                        address: {
                            street: document.getElementById('address').value.trim(),
                            city: document.getElementById('city').value.trim(),
                            state: document.getElementById('state').value.trim(),
                            postalCode: document.getElementById('postalCode').value.trim()
                        },
                        notes: document.getElementById('notes').value.trim()
                    },
                    product: checkoutData.product,
                    package: checkoutData.package,
                    addons: checkoutData.addons,
                    prescription: checkoutData.prescription,
                    payment: {
                        method: selectedPayment,
                        amount: checkoutData.prices.total + SHIPPING_COST,
                        bank: selectedBank
                    },
                    prices: {
                        base: checkoutData.prices.base,
                        package: checkoutData.prices.package,
                        addons: checkoutData.prices.addons,
                        subtotal: checkoutData.prices.total,
                        shipping: SHIPPING_COST,
                        total: checkoutData.prices.total + SHIPPING_COST
                    },
                    orderDate: new Date().toISOString(),
                    status: 'pending'
                };

                console.log('Processing payment...', orderData);

                // Handle different payment methods
                if (selectedPayment === 'cod') {
                    // Cash on delivery - no payment processing needed
                    await createOrder(orderData, null);
                } else if (selectedPayment === 'card') {
                    // Card payment via Stripe
                    await processCardPayment(orderData);
                } else if (selectedPayment === 'ewallet' || selectedPayment === 'online') {
                    // FPX payment via Stripe
                    await processFPXPayment(orderData);
                }

            } catch (error) {
                console.error('Payment error:', error);
                alert('Payment failed: ' + error.message);
                confirmBtn.disabled = false;
                confirmBtn.innerHTML = '<i class="ri-secure-payment-line"></i> Confirm Payment';
            }
        }

        // Process card payment
        async function processCardPayment(orderData) {
            try {
                // Create payment intent
                const intentResponse = await fetch('/Handlers/payment_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'createPaymentIntent',
                        paymentMethod: 'card',
                        amount: orderData.payment.amount,
                        currency: 'myr'
                    })
                });

                const intentData = await intentResponse.json();

                if (!intentData.success) {
                    throw new Error(intentData.message || 'Failed to create payment intent');
                }

                // Confirm card payment
                const { error, paymentIntent } = await stripe.confirmCardPayment(
                    intentData.clientSecret,
                    {
                        payment_method: {
                            card: cardElement,
                            billing_details: {
                                name: orderData.customer.fullName,
                                email: orderData.customer.email,
                            },
                        },
                    }
                );

                if (error) {
                    throw new Error(error.message);
                }

                if (paymentIntent.status === 'succeeded') {
                    // Payment successful, create order
                    orderData.payment.transactionId = paymentIntent.id;
                    orderData.payment.status = 'paid';
                    await createOrder(orderData, paymentIntent.id);
                } else {
                    throw new Error('Payment was not successful');
                }

            } catch (error) {
                throw error;
            }
        }

        // Process FPX payment
        async function processFPXPayment(orderData) {
            try {
                // Store checkout data for payment success page
                sessionStorage.setItem('pendingOrderData', JSON.stringify(orderData));

                // Create payment intent
                const intentResponse = await fetch('/Handlers/payment_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'createPaymentIntent',
                        paymentMethod: selectedPayment,
                        amount: orderData.payment.amount,
                        currency: 'myr'
                    })
                });

                const intentData = await intentResponse.json();

                if (!intentData.success) {
                    throw new Error(intentData.message || 'Failed to create payment intent');
                }

                // Redirect to FPX authentication
                const { error } = await stripe.confirmFpxPayment(
                    intentData.clientSecret,
                    {
                        payment_method: {
                            fpx: {
                                bank: selectedBank,
                            },
                        },
                        return_url: window.location.origin + '/Pages/Customer/payment_success.aspx',
                    }
                );

                if (error) {
                    throw new Error(error.message);
                }

                // User will be redirected to bank for authentication
                // Order will be created on return_url page after payment verification

            } catch (error) {
                throw error;
            }
        }

        // Create order in database
        async function createOrder(orderData, paymentIntentId) {
            try {
                const response = await fetch('/Handlers/payment_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'createOrder',
                        orderData: orderData,
                        idToken: localStorage.getItem('idToken')
                    })
                });

                const result = await response.json();

                if (result.success) {
                    alert('Payment confirmed! Your order has been placed successfully.\n\nOrder ID: ' + result.orderId);
                    sessionStorage.removeItem('checkoutData');
                    window.location.href = '/Pages/Customer/catalogue.aspx';
                } else {
                    throw new Error(result.message || 'Failed to create order');
                }
            } catch (error) {
                throw error;
            }
        }

        // Helper functions
        function capitalizeFirst(str) {
            return str.charAt(0).toUpperCase() + str.slice(1);
        }

        function getPackageName(type) {
            const names = {
                'frameOnly': 'Frame Only',
                'prescription': 'Single Vision',
                'readers': 'Reading Glasses',
                'bifocal': 'Bifocal/Progressive'
            };
            return names[type] || type;
        }

        function getAddonName(type) {
            const names = {
                'blueLight': 'Blue Light Filter',
                'transition': 'Transition Lenses',
                'polarized': 'Polarized'
            };
            return names[type] || type;
        }

        function getPrescriptionTypeName(type) {
            const names = {
                'nearsightedness': 'Nearsightedness (Myopia)',
                'farsightedness': 'Farsightedness (Hyperopia)',
                'reading': 'Reading Glasses',
                'multifocal': 'Multifocal / Progressive'
            };
            return names[type] || type;
        }

        // Initialize on page load
        window.addEventListener('load', loadCheckoutData);
    </script>
</asp:Content>