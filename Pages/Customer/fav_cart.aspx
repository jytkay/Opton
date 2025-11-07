<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="fav_cart.aspx.cs" Inherits="Opton.Pages.Customer.fav_cart" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <script type="module" src="https://unpkg.com/@google/model-viewer@latest/dist/model-viewer.min.js"></script>

    <style>
        /* Div 1: header-buttons */
        .header-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            padding: 12px 20px;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

            .header-buttons button {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                background-color: var(--color-accent);
                color: white;
                border: none;
                border-radius: 8px;
                padding: 8px 12px;
                font-size: 14px;
                cursor: pointer;
                transition: background-color 0.2s;
            }

                .header-buttons button:hover {
                    background-color: #8f6646;
                }

                .header-buttons button:disabled {
                    background-color: #ccc;
                    cursor: not-allowed;
                }

                .header-buttons button i {
                    font-size: 18px;
                }

        /* Div 2: header-options */
        .header-options {
            position: sticky;
            top: 55px;
            display: flex;
            justify-content: center;
            gap: 20px;
            background-color: white;
            padding: 12px 0;
            border-bottom: 1px solid var(--color-light);
            z-index: 10;
        }

            .header-options .option {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                cursor: pointer;
                padding: 6px 12px;
                border-radius: 8px;
                font-weight: 500;
                font-size: 14px;
                color: var(--color-dark);
                transition: all 0.2s;
            }

                .header-options .option.selected {
                    background-color: var(--color-accent);
                    color: white;
                }

                .header-options .option i {
                    font-size: 18px;
                }

        /* Div 3: products-list styling */
        .product-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
            padding: 16px 20px;
            min-height: 400px;
        }

        /* Empty state */
        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 60px 20px;
            color: #999;
            text-align: center;
        }

            .empty-state i {
                font-size: 64px;
                margin-bottom: 16px;
            }

            .empty-state h3 {
                margin: 0 0 8px 0;
                color: #666;
            }

            .empty-state p {
                margin: 0 0 20px 0;
            }

            .empty-state a {
                background-color: var(--color-accent);
                color: white;
                padding: 10px 24px;
                border-radius: 8px;
                text-decoration: none;
                transition: background-color 0.2s;
            }

                .empty-state a:hover {
                    background-color: #8f6646;
                }

        /* Div 3.1: favourites grid */
        .favourites-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
        }

        .favourite-item {
            position: relative;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 12px;
            text-align: center;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }

            .favourite-item:hover {
                transform: scale(1.02);
                box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            }

            .favourite-item model-viewer {
                width: 100%;
                height: 200px;
            }

            .favourite-item img {
                max-width: 100%;
                max-height: 200px;
                object-fit: contain;
                border-radius: 4px;
            }

            /* Checkbox for favourite items */
            .favourite-item .select-checkbox {
                position: absolute;
                top: 8px;
                left: 8px;
                width: 24px;
                height: 24px;
                cursor: pointer;
                z-index: 5;
                accent-color: var(--color-accent);
            }

            .favourite-item .unlike-btn {
                position: absolute;
                top: 8px;
                right: 8px;
                color: red;
                font-size: 24px;
                cursor: pointer;
                background: white;
                border-radius: 50%;
                width: 32px;
                height: 32px;
                display: flex;
                align-items: center;
                justify-content: center;
                box-shadow: 0 2px 4px rgba(0,0,0,0.2);
                z-index: 5;
            }

                .favourite-item .unlike-btn:hover {
                    transform: scale(1.1);
                }

            .favourite-item .product-name {
                margin-top: 8px;
                font-weight: 500;
                color: #2C3639;
            }

            .favourite-item .product-price {
                color: var(--color-accent);
                font-weight: 600;
                font-family: var(--font-price);
                font-size: 1.1rem;
            }

        /* Div 3.2: cart grid/list */
        .cart-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .cart-item {
            display: flex;
            align-items: center;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 12px;
            gap: 12px;
        }

            .cart-item input[type="checkbox"] {
                flex-shrink: 0;
                width: 18px;
                height: 18px;
                cursor: pointer;
                accent-color: var(--color-accent);
            }

            .cart-item model-viewer {
                width: 80px;
                height: 80px;
                flex-shrink: 0;
            }

            .cart-item img {
                width: 80px;
                height: 80px;
                object-fit: contain;
                border-radius: 4px;
                flex-shrink: 0;
            }

            .cart-item .cart-details {
                display: flex;
                flex-direction: column;
                gap: 4px;
                flex: 1;
            }

            .cart-item .cart-name {
                font-weight: 500;
                color: #2C3639;
            }

            .cart-item .cart-price {
                color: var(--color-accent);
                font-weight: 600;
                font-family: var(--font-price);
            }

            .cart-item .cart-meta {
                font-size: 12px;
                color: #666;
            }

            .cart-item .cart-quantity {
                display: flex;
                align-items: center;
                gap: 8px;
            }

                .cart-item .cart-quantity button {
                    width: 28px;
                    height: 28px;
                    border: 1px solid var(--color-light);
                    background-color: white;
                    cursor: pointer;
                    border-radius: 4px;
                    font-weight: bold;
                    transition: background-color 0.2s;
                }

                    .cart-item .cart-quantity button:hover {
                        background-color: #f0f0f0;
                    }

                .cart-item .cart-quantity input {
                    width: 40px;
                    text-align: center;
                    border: 1px solid var(--color-light);
                    border-radius: 4px;
                    padding: 4px;
                }

            .cart-item .cart-actions {
                display: flex;
                flex-direction: column;
                gap: 8px;
                flex-shrink: 0;
            }

            .cart-item .cart-edit {
                color: var(--color-accent);
                cursor: pointer;
                font-size: 20px;
                transition: transform 0.2s;
            }

                .cart-item .cart-edit:hover {
                    transform: scale(1.2);
                }

            .cart-item .cart-remove {
                color: red;
                cursor: pointer;
                font-size: 20px;
                transition: transform 0.2s;
            }

                .cart-item .cart-remove:hover {
                    transform: scale(1.2);
                }

        /* Cart summary */
        .cart-summary {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 16px;
            margin-top: 16px;
        }

            .cart-summary .summary-row {
                display: flex;
                justify-content: space-between;
                margin-bottom: 8px;
            }

                .cart-summary .summary-row.total {
                    font-weight: bold;
                    font-size: 1.2rem;
                    border-top: 2px solid var(--color-light);
                    padding-top: 8px;
                    margin-top: 8px;
                }

        /* Edit Modal */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }

            .modal-overlay.active {
                display: flex;
            }

        .modal-content {
            background: white;
            border-radius: 12px;
            padding: 30px;
            max-width: 600px;
            width: 90%;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--color-accent);
        }

            .modal-header h2 {
                margin: 0;
                color: var(--color-dark);
                font-size: 22px;
            }

        .modal-close {
            cursor: pointer;
            font-size: 28px;
            color: #666;
            transition: color 0.2s;
        }

            .modal-close:hover {
                color: var(--color-dark);
            }

        .modal-section {
            margin-bottom: 25px;
        }

            .modal-section h3 {
                font-size: 18px;
                color: var(--color-dark);
                margin-bottom: 12px;
            }

        .modal-options {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .modal-option {
            display: flex;
            align-items: center;
            padding: 12px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
        }

            .modal-option:hover {
                border-color: var(--color-accent);
                background: #f8f9fa;
            }

            .modal-option.selected {
                border-color: var(--color-accent);
                background: rgba(162, 123, 92, 0.05);
            }

            .modal-option input {
                margin-right: 10px;
                accent-color: var(--color-accent);
            }

        .modal-option-label {
            flex: 1;
            display: flex;
            justify-content: space-between;
        }

        .modal-option-price {
            font-weight: 600;
            color: var(--color-accent);
        }

        .modal-actions {
            display: flex;
            gap: 15px;
            margin-top: 25px;
        }

        .modal-btn {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }

        .modal-btn-cancel {
            background: #fff;
            color: #666;
            border: 2px solid #dee2e6;
        }

            .modal-btn-cancel:hover {
                background: #f8f9fa;
            }

        .modal-btn-save {
            background: var(--color-accent);
            color: white;
        }

            .modal-btn-save:hover {
                background: #8f6646;
            }

        /* Loading state */
        .loading {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 60px;
        }

            .loading i {
                font-size: 48px;
                color: var(--color-accent);
                animation: spin 1s linear infinite;
            }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }

        @media (max-width: 900px) {
            .favourites-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .cart-item img,
            .cart-item model-viewer {
                width: 60px;
                height: 60px;
            }
        }

        @media (max-width: 600px) {
            .favourites-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="header-buttons">
        <button id="tryOnButton" style="display: none;"><i class="ri-camera-fill"></i>Try-On (<span id="tryOnCount">0</span>)</button>
        <button id="actionButton"><i class="ri-shopping-cart-2-fill"></i>Add to Cart (<span id="actionCount">0</span>)</button>
    </div>

    <div class="header-options">
        <div class="option selected" id="favouritesOption">
            <i class="ri-heart-fill"></i>Favourites (<span id="favouritesCount">0</span>)
       
        </div>
        <div class="option" id="cartOption">
            <i class="ri-shopping-cart-2-fill"></i>Cart (<span id="cartCount">0</span>)
       
        </div>
    </div>

    <div class="product-list">
        <!-- Loading State -->
        <div class="loading" id="loadingState">
            <i class="ri-loader-4-line"></i>
        </div>

        <!-- Div 3.1: Favourites Grid -->
        <div class="favourites-grid" id="favouritesGrid" style="display: none;">
            <!-- Dynamically populated -->
        </div>

        <!-- Div 3.2: Cart List -->
        <div class="cart-list" id="cartList" style="display: none;">
            <!-- Dynamically populated -->
        </div>

        <!-- Cart Summary -->
        <div class="cart-summary" id="cartSummary" style="display: none;">
            <div class="summary-row">
                <span>Subtotal:</span>
                <span id="subtotal">RM0.00</span>
            </div>
            <div class="summary-row total">
                <span>Total:</span>
                <span id="total">RM0.00</span>
            </div>
        </div>
    </div>

    <!-- Edit Modal -->
<div class="modal-overlay" id="editModal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Edit Cart Item</h2>
            <span class="modal-close" onclick="closeEditModal()">×</span>
        </div>

        <div class="modal-section">
            <h3>Package</h3>
            <div class="modal-options" id="packageOptions">
                <div class="modal-option" onclick="selectModalPackage('frameOnly', 0, this)">
                    <input type="radio" name="modalPackage" value="frameOnly">
                    <div class="modal-option-label">
                        <span>Frame Only</span>
                        <span class="modal-option-price">Included</span>
                    </div>
                </div>
                <div class="modal-option" onclick="selectModalPackage('prescription', 150, this)">
                    <input type="radio" name="modalPackage" value="prescription">
                    <div class="modal-option-label">
                        <span>Single Vision Prescription</span>
                        <span class="modal-option-price">+ RM 150.00</span>
                    </div>
                </div>
                <div class="modal-option" onclick="selectModalPackage('readers', 100, this)">
                    <input type="radio" name="modalPackage" value="readers">
                    <div class="modal-option-label">
                        <span>Reading Glasses</span>
                        <span class="modal-option-price">+ RM 100.00</span>
                    </div>
                </div>
                <div class="modal-option" onclick="selectModalPackage('bifocal', 250, this)">
                    <input type="radio" name="modalPackage" value="bifocal">
                    <div class="modal-option-label">
                        <span>Bifocal / Progressive</span>
                        <span class="modal-option-price">+ RM 250.00</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Prescription Section -->
        <div class="modal-section" id="prescriptionSection" style="display: none;">
            <h3>Prescription Details <span style="color: #dc3545;">*</span></h3>
            
            <div class="prescription-mode" style="display: flex; gap: 20px; margin-bottom: 15px;">
                <input type="radio" id="modalUploadMode" name="modalPrescriptionMode" checked style="display: none;">
                <label for="modalUploadMode" style="cursor: pointer; padding: 8px 0; font-weight: 500; color: #666; border-bottom: 2px solid transparent; transition: all 0.2s;">Upload Prescription</label>
                <input type="radio" id="modalManualMode" name="modalPrescriptionMode" style="display: none;">
                <label for="modalManualMode" style="cursor: pointer; padding: 8px 0; font-weight: 500; color: #666; border-bottom: 2px solid transparent; transition: all 0.2s;">Manual Input</label>
            </div>

            <div style="margin-bottom: 15px;">
                <select id="modalPrescriptionType" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px;">
                    <option value="">-- Select Type --</option>
                    <option value="nearsightedness">Nearsightedness (Myopia)</option>
                    <option value="farsightedness">Farsightedness (Hyperopia)</option>
                    <option value="reading">Reading Glasses</option>
                    <option value="multifocal">Multifocal / Progressive</option>
                </select>
            </div>

            <div id="modalUploadPrescription">
                <input type="file" id="modalPrescriptionFile" accept=".png,.jpg,.jpeg,.pdf" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">
                <small style="color: #666;">Allowed: PNG, JPG, JPEG, PDF</small>
            </div>

            <div id="modalManualPrescription" style="display: none;">
                <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
                    <thead>
                        <tr>
                            <th style="padding: 8px; text-align: center; background: #f8f9fa; font-weight: 600; border: 1px solid #e9ecef;"></th>
                            <th style="padding: 8px; text-align: center; background: #f8f9fa; font-weight: 600; border: 1px solid #e9ecef;">Right Eye (OD)</th>
                            <th style="padding: 8px; text-align: center; background: #f8f9fa; font-weight: 600; border: 1px solid #e9ecef;">Left Eye (OS)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td style="padding: 8px; text-align: center; border: 1px solid #e9ecef;"><strong>Sphere (SPH)</strong></td>
                            <td style="padding: 8px; border: 1px solid #e9ecef;"><input type="text" id="modalRightEyeSphere" placeholder="e.g., -2.00" style="width: 100%; padding: 6px 8px; border: 1px solid #ddd; border-radius: 4px; text-align: center;"></td>
                            <td style="padding: 8px; border: 1px solid #e9ecef;"><input type="text" id="modalLeftEyeSphere" placeholder="e.g., -2.00" style="width: 100%; padding: 6px 8px; border: 1px solid #ddd; border-radius: 4px; text-align: center;"></td>
                        </tr>
                        <tr>
                            <td style="padding: 8px; text-align: center; border: 1px solid #e9ecef;"><strong>Cylinder (CYL)</strong></td>
                            <td style="padding: 8px; border: 1px solid #e9ecef;"><input type="text" id="modalRightEyeCylinder" placeholder="e.g., -0.50" style="width: 100%; padding: 6px 8px; border: 1px solid #ddd; border-radius: 4px; text-align: center;"></td>
                            <td style="padding: 8px; border: 1px solid #e9ecef;"><input type="text" id="modalLeftEyeCylinder" placeholder="e.g., -0.50" style="width: 100%; padding: 6px 8px; border: 1px solid #ddd; border-radius: 4px; text-align: center;"></td>
                        </tr>
                        <tr>
                            <td style="padding: 8px; text-align: center; border: 1px solid #e9ecef;"><strong>Axis</strong></td>
                            <td style="padding: 8px; border: 1px solid #e9ecef;"><input type="text" id="modalRightEyeAxis" placeholder="e.g., 180" style="width: 100%; padding: 6px 8px; border: 1px solid #ddd; border-radius: 4px; text-align: center;"></td>
                            <td style="padding: 8px; border: 1px solid #e9ecef;"><input type="text" id="modalLeftEyeAxis" placeholder="e.g., 180" style="width: 100%; padding: 6px 8px; border: 1px solid #ddd; border-radius: 4px; text-align: center;"></td>
                        </tr>
                        <tr>
                            <td style="padding: 8px; text-align: center; border: 1px solid #e9ecef;"><strong>PD</strong></td>
                            <td colspan="2" style="padding: 8px; border: 1px solid #e9ecef;"><input type="text" id="modalPd" placeholder="e.g., 63" style="width: 100%; padding: 6px 8px; border: 1px solid #ddd; border-radius: 4px; text-align: center;"></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="modal-section">
            <h3>Add-ons (Optional)</h3>
            <div class="modal-options" id="addonOptions">
                <div class="modal-option" onclick="toggleModalAddon('blueLight', 50, this)">
                    <input type="checkbox" value="blueLight">
                    <div class="modal-option-label">
                        <span>Blue Light Filter</span>
                        <span class="modal-option-price">+ RM 50.00</span>
                    </div>
                </div>
                <div class="modal-option" onclick="toggleModalAddon('transition', 120, this)">
                    <input type="checkbox" value="transition">
                    <div class="modal-option-label">
                        <span>Transition Lenses</span>
                        <span class="modal-option-price">+ RM 120.00</span>
                    </div>
                </div>
                <div class="modal-option" onclick="toggleModalAddon('polarized', 100, this)">
                    <input type="checkbox" value="polarized">
                    <div class="modal-option-label">
                        <span>Polarized</span>
                        <span class="modal-option-price">+ RM 100.00</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal-actions">
            <button class="modal-btn modal-btn-cancel" onclick="closeEditModal()">Cancel</button>
            <button class="modal-btn modal-btn-save" onclick="saveCartItemEdit()">Save Changes</button>
        </div>
    </div>
</div>

    <script type="module">
        import { FirebaseManager } from "/Scripts/firebase-init.js";

        // Make Firebase methods available globally for non-module scripts
        window.getIdToken = async function () {
            return await FirebaseManager.getIdToken();
        };

        window.getCurrentUser = async function () {
            return await FirebaseManager.getCurrentUser();
        };

        // Initialize page when Firebase is ready
        FirebaseManager.onReady(async () => {
            console.log('[fav_cart] Firebase ready, initializing page...');
            await window.initializeFavCartPage();
        });
    </script>

    <script>
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

        // STORAGE KEYS
        const STORAGE_KEYS = {
            guestSaved: 'guestSaved',
            guestCart: 'guestCart'
        };

        // AUTH CHECKING
        async function getCurrentUserId() {
            const user = await window.getCurrentUser();
            return user ? user.uid : null;
        }

        async function isAuthenticated() {
            const userId = await getCurrentUserId();
            return userId !== null;
        }

        // GUEST DATA FUNCTIONS (localStorage only)
        function getGuestData(key) {
            const data = localStorage.getItem(key);
            return data ? JSON.parse(data) : [];
        }

        function setGuestData(key, data) {
            localStorage.setItem(key, JSON.stringify(data));
        }

        // Elements
        const favouritesOption = document.getElementById('favouritesOption');
        const cartOption = document.getElementById('cartOption');
        const favouritesGrid = document.getElementById('favouritesGrid');
        const cartList = document.getElementById('cartList');
        const cartSummary = document.getElementById('cartSummary');
        const actionButton = document.getElementById('actionButton');
        const loadingState = document.getElementById('loadingState');

        let currentView = 'favourites'; // 'favourites' or 'cart'
        let selectedFavourites = new Set();
        let selectedCartItems = new Set();
        let allProducts = {}; // Cache for product details
        let currentEditItem = null;
        let modalPackage = { type: null, price: 0 };
        let modalAddons = [];
        let modalPrescription = null;

        // Fetch product details from fire_handler
        async function fetchProductDetails(productId) {
            if (allProducts[productId]) {
                return allProducts[productId];
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
                    const product = {
                        productId: productId,
                        name: data.product.name || '',
                        price: parseFloat(data.product.price) || 0,
                        model: data.product.model || '',
                        shape: data.product.shape || '',
                        availableColors: []
                    };

                    // Extract available colors from inventory
                    if (data.product.inventory) {
                        product.availableColors = Object.keys(data.product.inventory);
                    }

                    allProducts[productId] = product;
                    return product;
                }
            } catch (error) {
                console.error('Error fetching product:', error);
            }
            return null;
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

        // Load favourites
        async function loadFavourites() {
            favouritesGrid.innerHTML = '';
            loadingState.style.display = 'flex';
            selectedFavourites.clear();

            const isAuth = await isAuthenticated();
            let savedItems = [];

            console.log('[loadFavourites] Authenticated:', isAuth);

            if (isAuth) {
                // Fetch from Firestore
                try {
                    const idToken = await window.getIdToken();
                    const response = await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: 'getSaved',
                            idToken: idToken
                        })
                    });
                    const result = await response.json();
                    console.log('[loadFavourites] Firestore result:', result);
                    if (result.success) {
                        savedItems = result.items || [];
                    }
                } catch (error) {
                    console.error('Error loading favourites:', error);
                }
            } else {
                // Get from localStorage
                savedItems = getGuestData(STORAGE_KEYS.guestSaved);
                console.log('[loadFavourites] localStorage items:', savedItems);
            }

            loadingState.style.display = 'none';

            if (savedItems.length === 0) {
                favouritesGrid.innerHTML = `
                    <div class="empty-state" style="grid-column: 1 / -1;">
                        <i class="ri-heart-line"></i>
                        <h3>No Favourites Yet</h3>
                        <p>Start adding products you love!</p>
                        <a href="catalogue.aspx">Browse Products</a>
                    </div>
                `;
                favouritesGrid.style.display = 'grid';
                document.getElementById('favouritesCount').textContent = '0';
                document.getElementById('actionCount').textContent = '0';
                actionButton.disabled = true;
                return;
            }

            // Fetch product details for each saved item
            for (const item of savedItems) {
                const productId = typeof item === 'string' ? item : item.productId;
                const product = await fetchProductDetails(productId);

                if (product) {
                    const itemDiv = createFavouriteItem(product);
                    favouritesGrid.appendChild(itemDiv);
                }
            }

            favouritesGrid.style.display = 'grid';
            document.getElementById('favouritesCount').textContent = savedItems.length;
            document.getElementById('actionCount').textContent = '0';
            actionButton.disabled = true;
        }

        // Create favourite item element
        function createFavouriteItem(product) {
            const div = document.createElement('div');
            div.className = 'favourite-item';
            div.dataset.productId = product.productId;
            div.dataset.price = product.price;

            // Get first available color
            const firstColor = product.availableColors && product.availableColors.length > 0
                ? product.availableColors[0]
                : 'black';

            let mediaHtml = '';
            if (product.model) {
                const files = product.model.split(', ');
                const glbFiles = files.filter(f => f.toLowerCase().endsWith('.glb'));

                if (glbFiles.length > 0) {
                    // Find color-specific model or use first one
                    let modelFile = glbFiles[0];
                    for (const file of glbFiles) {
                        if (file.toLowerCase().includes(firstColor.toLowerCase())) {
                            modelFile = file;
                            break;
                        }
                    }

                    const modelUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/Products%2F${encodeURIComponent(product.productId)}%2F${encodeURIComponent(modelFile)}?alt=media`;
                    const modelId = `model-fav-${product.productId}`;

                    mediaHtml = `
                        <model-viewer 
                            id="${modelId}"
                            src="${modelUrl}"
                            camera-orbit="0deg 75deg auto"
                            disable-pan
                            disable-zoom
                            interaction-prompt="none"
                            loading="eager"
                            style="width: 100%; height: 200px;">
                        </model-viewer>
                    `;

                    // Apply color after model loads
                    setTimeout(() => {
                        const modelViewer = document.getElementById(modelId);
                        if (modelViewer) {
                            modelViewer.addEventListener('load', () => {
                                applyColorToModel(modelViewer, firstColor);
                            });
                        }
                    }, 100);
                } else {
                    const imageFiles = files.filter(f => /\.(png|jpg|jpeg)$/i.test(f));
                    if (imageFiles.length > 0) {
                        const imageUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/Products%2F${encodeURIComponent(product.productId)}%2F${encodeURIComponent(imageFiles[0])}?alt=media`;
                        mediaHtml = `<img src="${imageUrl}" alt="${product.name}" />`;
                    }
                }
            }

            div.innerHTML = `
                <input type="checkbox" class="select-checkbox" onclick="event.stopPropagation(); toggleFavouriteSelection('${product.productId}')" />
                ${mediaHtml}
                <i class="ri-heart-fill unlike-btn" onclick="event.stopPropagation(); unlikeProduct('${product.productId}')"></i>
                <div class="product-name">${product.name}</div>
                <div class="product-price">RM${product.price.toFixed(2)}</div>
            `;

            // Make clickable to view product
            div.addEventListener('click', (e) => {
                if (!e.target.classList.contains('select-checkbox') &&
                    !e.target.classList.contains('unlike-btn')) {
                    window.location.href = `product.aspx?id=${product.productId}`;
                }
            });

            return div;
        }

        // Toggle favourite selection
        function toggleFavouriteSelection(productId) {
            if (selectedFavourites.has(productId)) {
                selectedFavourites.delete(productId);
            } else {
                selectedFavourites.add(productId);
            }

            document.getElementById('actionCount').textContent = selectedFavourites.size;
            actionButton.disabled = selectedFavourites.size === 0;
        }

        // Unlike product
        async function unlikeProduct(productId) {
            if (!confirm('Remove this item from favourites?')) return;

            const isAuth = await isAuthenticated();

            if (isAuth) {
                try {
                    const idToken = await window.getIdToken();
                    await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: 'unlike',
                            productId: productId,
                            idToken: idToken
                        })
                    });
                } catch (error) {
                    console.error('Error unliking product:', error);
                }
            } else {
                let savedItems = getGuestData(STORAGE_KEYS.guestSaved);
                savedItems = savedItems.filter(id => id !== productId);
                setGuestData(STORAGE_KEYS.guestSaved, savedItems);
            }

            selectedFavourites.delete(productId);
            await loadFavourites();
        }

        // Add selected favourites to cart
        async function addFavouritesToCart() {
            if (selectedFavourites.size === 0) {
                alert('Please select items to add to cart');
                return;
            }

            const isAuth = await isAuthenticated();
            const itemsToAdd = Array.from(selectedFavourites);

            for (const productId of itemsToAdd) {
                if (isAuth) {
                    try {
                        const idToken = await window.getIdToken();
                        await fetch('/Handlers/fire_handler.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({
                                action: 'addToCart',
                                idToken: idToken,
                                productId: productId,
                                quantity: 1,
                                package: { type: 'frameOnly', price: 0 },
                                addons: []
                            })
                        });
                    } catch (error) {
                        console.error('Error adding to cart:', error);
                    }
                } else {
                    let cartItems = getGuestData(STORAGE_KEYS.guestCart);
                    const existingItem = cartItems.find(item => item.productId === productId);

                    if (existingItem) {
                        existingItem.quantity += 1;
                    } else {
                        cartItems.push({
                            productId: productId,
                            quantity: 1,
                            package: { type: 'frameOnly', price: 0 },
                            addons: []
                        });
                    }

                    setGuestData(STORAGE_KEYS.guestCart, cartItems);
                }
            }

            alert(`Added ${itemsToAdd.length} item(s) to cart!`);
            selectedFavourites.clear();

            // Switch to cart view
            cartOption.click();
        }

        // Load cart
        async function loadCart() {
            cartList.innerHTML = '';
            loadingState.style.display = 'flex';
            selectedCartItems.clear();

            const isAuth = await isAuthenticated();
            let cartItems = [];

            console.log('[loadCart] Authenticated:', isAuth);

            if (isAuth) {
                // Fetch from Firestore
                try {
                    const idToken = await window.getIdToken();
                    const response = await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: 'getCart',
                            idToken: idToken
                        })
                    });
                    const result = await response.json();
                    console.log('[loadCart] Firestore result:', result);
                    if (result.success) {
                        cartItems = result.items || [];
                    }
                } catch (error) {
                    console.error('Error loading cart:', error);
                }
            } else {
                // Get from localStorage
                cartItems = getGuestData(STORAGE_KEYS.guestCart);
                console.log('[loadCart] localStorage items:', cartItems);
            }

            loadingState.style.display = 'none';

            if (cartItems.length === 0) {
                cartList.innerHTML = `
                    <div class="empty-state">
                        <i class="ri-shopping-cart-2-line"></i>
                        <h3>Your Cart is Empty</h3>
                        <p>Add some products to get started!</p>
                        <a href="catalogue.aspx">Browse Products</a>
                    </div>
                `;
                cartList.style.display = 'flex';
                cartSummary.style.display = 'none';
                document.getElementById('cartCount').textContent = '0';
                document.getElementById('actionCount').textContent = '0';
                actionButton.disabled = true;
                return;
            }

            // Fetch product details for each cart item
            for (const item of cartItems) {
                const product = await fetchProductDetails(item.productId);

                if (product) {
                    const itemDiv = await createCartItem({
                        ...product,
                        quantity: item.quantity,
                        package: item.package || { type: 'frameOnly', price: 0 },
                        addons: item.addons || [],
                        color: item.color || (product.availableColors && product.availableColors[0]) || 'black'
                    });
                    cartList.appendChild(itemDiv);
                }
            }

            cartList.style.display = 'flex';
            document.getElementById('cartCount').textContent = cartItems.length;
            updateCartSummary();
        }

        // Create cart item element
        async function createCartItem(item) {
            const div = document.createElement('div');
            div.className = 'cart-item';
            div.dataset.productId = item.productId;

            // Calculate total price for this item
            const packagePrice = item.package ? item.package.price : 0;
            const addonsPrice = item.addons ? item.addons.reduce((sum, addon) => sum + addon.price, 0) : 0;
            const totalItemPrice = item.price + packagePrice + addonsPrice;

            div.dataset.price = totalItemPrice;
            div.dataset.quantity = item.quantity;

            const color = item.color || 'black';

            let mediaHtml = '';
            if (item.model) {
                const files = item.model.split(', ');
                const glbFiles = files.filter(f => f.toLowerCase().endsWith('.glb'));

                if (glbFiles.length > 0) {
                    // Find color-specific model or use first one
                    let modelFile = glbFiles[0];
                    for (const file of glbFiles) {
                        if (file.toLowerCase().includes(color.toLowerCase())) {
                            modelFile = file;
                            break;
                        }
                    }

                    const modelUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/Products%2F${encodeURIComponent(item.productId)}%2F${encodeURIComponent(modelFile)}?alt=media`;
                    const modelId = `model-cart-${item.productId}`;

                    mediaHtml = `
                        <model-viewer 
                            id="${modelId}"
                            src="${modelUrl}"
                            camera-orbit="0deg 75deg auto"
                            disable-pan
                            disable-zoom
                            interaction-prompt="none"
                            loading="eager">
                        </model-viewer>
                    `;

                    // Apply color after model loads
                    setTimeout(() => {
                        const modelViewer = document.getElementById(modelId);
                        if (modelViewer) {
                            modelViewer.addEventListener('load', () => {
                                applyColorToModel(modelViewer, color);
                            });
                        }
                    }, 100);
                } else {
                    const imageFiles = files.filter(f => /\.(png|jpg|jpeg)$/i.test(f));
                    if (imageFiles.length > 0) {
                        const imageUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/Products%2F${encodeURIComponent(item.productId)}%2F${encodeURIComponent(imageFiles[0])}?alt=media`;
                        mediaHtml = `<img src="${imageUrl}" alt="${item.name}" />`;
                    }
                }
            }

            // Build meta info
            let metaInfo = `Color: ${color.charAt(0).toUpperCase() + color.slice(1)}`;
            if (item.package && item.package.type !== 'frameOnly') {
                metaInfo += ` | Package: ${getPackageName(item.package.type)}`;
            }
            if (item.addons && item.addons.length > 0) {
                metaInfo += ` | Add-ons: ${item.addons.map(a => getAddonName(a.type)).join(', ')}`;
            }

            div.innerHTML = `
                <input type="checkbox" onchange="toggleCartSelection('${item.productId}')" />
                ${mediaHtml}
                <div class="cart-details">
                    <div class="cart-name">${item.name}</div>
                    <div class="cart-price">RM${totalItemPrice.toFixed(2)}</div>
                    <div class="cart-meta">${metaInfo}</div>
                    <div class="cart-quantity">
                        <button type="button" onclick="updateQuantity('${item.productId}', -1)">-</button>
                        <input type="text" value="${item.quantity}" readonly />
                        <button type="button" onclick="updateQuantity('${item.productId}', 1)">+</button>
                    </div>
                </div>
                <div class="cart-actions">
                    <i class="ri-pencil-fill cart-edit" onclick="openEditModal('${item.productId}')" title="Edit"></i>
                    <i class="ri-delete-bin-5-fill cart-remove" onclick="removeFromCart('${item.productId}')" title="Remove"></i>
                </div>
            `;

            return div;
        }

        // Helper functions for package and addon names
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

        // Toggle cart item selection
        function toggleCartSelection(productId) {
            if (selectedCartItems.has(productId)) {
                selectedCartItems.delete(productId);
            } else {
                selectedCartItems.add(productId);
            }
            updateCartSummary();
        }

        // Update quantity
        async function updateQuantity(productId, delta) {
            const isAuth = await isAuthenticated();
            const cartItemDiv = document.querySelector(`.cart-item[data-product-id="${productId}"]`);
            let currentQty = parseInt(cartItemDiv.dataset.quantity);
            let newQty = currentQty + delta;

            if (newQty < 1) newQty = 1;

            if (isAuth) {
                try {
                    const idToken = await window.getIdToken();
                    await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: 'updateCartQuantity',
                            productId: productId,
                            quantity: newQty,
                            idToken: idToken
                        })
                    });
                } catch (error) {
                    console.error('Error updating quantity:', error);
                    return;
                }
            } else {
                let cartItems = getGuestData(STORAGE_KEYS.guestCart);
                const item = cartItems.find(i => i.productId === productId);
                if (item) {
                    item.quantity = newQty;
                    setGuestData(STORAGE_KEYS.guestCart, cartItems);
                }
            }

            cartItemDiv.dataset.quantity = newQty;
            cartItemDiv.querySelector('.cart-quantity input').value = newQty;
            updateCartSummary();
        }

        // Remove from cart
        async function removeFromCart(productId) {
            if (!confirm('Remove this item from cart?')) return;

            const isAuth = await isAuthenticated();

            if (isAuth) {
                try {
                    const idToken = await window.getIdToken();
                    await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: 'removeFromCart',
                            productId: productId,
                            idToken: idToken
                        })
                    });
                } catch (error) {
                    console.error('Error removing from cart:', error);
                }
            } else {
                let cartItems = getGuestData(STORAGE_KEYS.guestCart);
                cartItems = cartItems.filter(item => item.productId !== productId);
                setGuestData(STORAGE_KEYS.guestCart, cartItems);
            }

            selectedCartItems.delete(productId);
            await loadCart();
        }

        // Update cart summary
        function updateCartSummary() {
            let subtotal = 0;
            let count = 0;

            document.querySelectorAll('.cart-item').forEach(item => {
                const checkbox = item.querySelector('input[type="checkbox"]');
                if (checkbox.checked) {
                    const price = parseFloat(item.dataset.price);
                    const quantity = parseInt(item.dataset.quantity);
                    subtotal += price * quantity;
                    count++;
                }
            });

            document.getElementById('subtotal').textContent = `RM${subtotal.toFixed(2)}`;
            document.getElementById('total').textContent = `RM${subtotal.toFixed(2)}`;
            document.getElementById('actionCount').textContent = count;

            cartSummary.style.display = count > 0 ? 'block' : 'none';
            actionButton.disabled = count === 0;
        }

        function selectModalPackage(type, price, element) {
            document.querySelectorAll('#packageOptions .modal-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            element.classList.add('selected');
            element.querySelector('input').checked = true;

            modalPackage = { type: type, price: price };

            // Show/hide prescription section
            const prescriptionSection = document.getElementById('prescriptionSection');
            if (type !== 'frameOnly') {
                prescriptionSection.style.display = 'block';
            } else {
                prescriptionSection.style.display = 'none';
            }
        }

        // Add prescription mode toggle handlers
        document.addEventListener('DOMContentLoaded', () => {
            const uploadRadio = document.getElementById('modalUploadMode');
            const manualRadio = document.getElementById('modalManualMode');
            const uploadDiv = document.getElementById('modalUploadPrescription');
            const manualDiv = document.getElementById('modalManualPrescription');

            if (uploadRadio && manualRadio) {
                uploadRadio.addEventListener('change', () => {
                    if (uploadDiv) uploadDiv.style.display = 'block';
                    if (manualDiv) manualDiv.style.display = 'none';
                });

                manualRadio.addEventListener('change', () => {
                    if (uploadDiv) uploadDiv.style.display = 'none';
                    if (manualDiv) manualDiv.style.display = 'block';
                });
            }

            // Style for prescription mode labels
            const prescriptionModeLabels = document.querySelectorAll('.prescription-mode label');
            prescriptionModeLabels.forEach(label => {
                label.addEventListener('click', function () {
                    prescriptionModeLabels.forEach(l => {
                        l.style.borderBottom = '2px solid transparent';
                        l.style.color = '#666';
                        l.style.fontWeight = '500';
                    });
                    this.style.borderBottom = '2px solid var(--color-accent)';
                    this.style.color = 'var(--color-dark)';
                    this.style.fontWeight = '600';
                });
            });
        });

        // Update openEditModal to load prescription data
        async function openEditModal(productId) {
            currentEditItem = productId;

            // Get current cart item data
            const isAuth = await isAuthenticated();
            let cartItems = [];

            if (isAuth) {
                const idToken = await window.getIdToken();
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'getCart',
                        idToken: idToken
                    })
                });
                const result = await response.json();
                if (result.success) {
                    cartItems = result.items || [];
                }
            } else {
                cartItems = getGuestData(STORAGE_KEYS.guestCart);
            }

            const item = cartItems.find(i => i.productId === productId);

            if (item) {
                // Set current package
                modalPackage = item.package || { type: 'frameOnly', price: 0 };
                modalAddons = item.addons || [];
                modalPrescription = item.prescription || null;

                // Reset modal
                document.querySelectorAll('.modal-option').forEach(opt => {
                    opt.classList.remove('selected');
                    const input = opt.querySelector('input');
                    if (input) {
                        input.checked = false;
                    }
                });

                // Reset prescription fields
                document.getElementById('modalPrescriptionType').value = '';
                document.getElementById('modalPrescriptionFile').value = '';
                document.getElementById('modalRightEyeSphere').value = '';
                document.getElementById('modalLeftEyeSphere').value = '';
                document.getElementById('modalRightEyeCylinder').value = '';
                document.getElementById('modalLeftEyeCylinder').value = '';
                document.getElementById('modalRightEyeAxis').value = '';
                document.getElementById('modalLeftEyeAxis').value = '';
                document.getElementById('modalPd').value = '';

                // Select current package
                const packageInput = document.querySelector(`input[name="modalPackage"][value="${modalPackage.type}"]`);
                if (packageInput) {
                    packageInput.checked = true;
                    packageInput.closest('.modal-option').classList.add('selected');
                }

                // Show/hide prescription section
                const prescriptionSection = document.getElementById('prescriptionSection');
                if (modalPackage.type !== 'frameOnly') {
                    prescriptionSection.style.display = 'block';

                    // Load prescription data if exists
                    if (modalPrescription) {
                        document.getElementById('modalPrescriptionType').value = modalPrescription.type || '';

                        if (modalPrescription.mode === 'upload') {
                            document.getElementById('modalUploadMode').checked = true;
                            document.getElementById('modalUploadMode').dispatchEvent(new Event('change'));
                        } else if (modalPrescription.mode === 'manual') {
                            document.getElementById('modalManualMode').checked = true;
                            document.getElementById('modalManualMode').dispatchEvent(new Event('change'));

                            // Fill manual fields
                            if (modalPrescription.rightEye) {
                                document.getElementById('modalRightEyeSphere').value = modalPrescription.rightEye.sphere || '';
                                document.getElementById('modalRightEyeCylinder').value = modalPrescription.rightEye.cylinder || '';
                                document.getElementById('modalRightEyeAxis').value = modalPrescription.rightEye.axis || '';
                            }
                            if (modalPrescription.leftEye) {
                                document.getElementById('modalLeftEyeSphere').value = modalPrescription.leftEye.sphere || '';
                                document.getElementById('modalLeftEyeCylinder').value = modalPrescription.leftEye.cylinder || '';
                                document.getElementById('modalLeftEyeAxis').value = modalPrescription.leftEye.axis || '';
                            }
                            document.getElementById('modalPd').value = modalPrescription.pd || '';
                        }
                    }
                } else {
                    prescriptionSection.style.display = 'none';
                }

                // Select current addons
                modalAddons.forEach(addon => {
                    const addonInput = document.querySelector(`input[type="checkbox"][value="${addon.type}"]`);
                    if (addonInput) {
                        addonInput.checked = true;
                        addonInput.closest('.modal-option').classList.add('selected');
                    }
                });
            }

            document.getElementById('editModal').classList.add('active');
        }

        // Update saveCartItemEdit to include prescription
        async function saveCartItemEdit() {
            if (!currentEditItem) return;

            // Collect prescription data if package requires it
            let prescriptionData = null;
            if (modalPackage.type !== 'frameOnly') {
                const prescriptionType = document.getElementById('modalPrescriptionType').value;

                if (!prescriptionType) {
                    alert('Please select a prescription type');
                    return;
                }

                const uploadMode = document.getElementById('modalUploadMode').checked;

                if (uploadMode) {
                    const fileInput = document.getElementById('modalPrescriptionFile');
                    if (fileInput.files.length > 0) {
                        prescriptionData = {
                            type: prescriptionType,
                            mode: 'upload',
                            fileName: fileInput.files[0].name
                        };
                    } else if (!modalPrescription || modalPrescription.mode !== 'upload') {
                        alert('Please upload a prescription file');
                        return;
                    } else {
                        // Keep existing uploaded prescription
                        prescriptionData = modalPrescription;
                    }
                } else {
                    // Manual mode
                    const rightSphere = document.getElementById('modalRightEyeSphere').value.trim();
                    const leftSphere = document.getElementById('modalLeftEyeSphere').value.trim();

                    if (!rightSphere || !leftSphere) {
                        alert('Please fill in at least the Sphere values for both eyes');
                        return;
                    }

                    prescriptionData = {
                        type: prescriptionType,
                        mode: 'manual',
                        rightEye: {
                            sphere: rightSphere,
                            cylinder: document.getElementById('modalRightEyeCylinder').value.trim(),
                            axis: document.getElementById('modalRightEyeAxis').value.trim()
                        },
                        leftEye: {
                            sphere: leftSphere,
                            cylinder: document.getElementById('modalLeftEyeCylinder').value.trim(),
                            axis: document.getElementById('modalLeftEyeAxis').value.trim()
                        },
                        pd: document.getElementById('modalPd').value.trim()
                    };
                }
            }

            const isAuth = await isAuthenticated();

            if (isAuth) {
                try {
                    const idToken = await window.getIdToken();
                    await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: 'updateCartItem',
                            productId: currentEditItem,
                            package: modalPackage,
                            addons: modalAddons,
                            prescription: prescriptionData,
                            idToken: idToken
                        })
                    });
                } catch (error) {
                    console.error('Error updating cart item:', error);
                    alert('Failed to update cart item');
                    return;
                }
            } else {
                let cartItems = getGuestData(STORAGE_KEYS.guestCart);
                const item = cartItems.find(i => i.productId === currentEditItem);
                if (item) {
                    item.package = modalPackage;
                    item.addons = modalAddons;
                    item.prescription = prescriptionData;
                    setGuestData(STORAGE_KEYS.guestCart, cartItems);
                }
            }

            closeEditModal();
            await loadCart();
        }

        // Update closeEditModal
        function closeEditModal() {
            document.getElementById('editModal').classList.remove('active');
            currentEditItem = null;
            modalPackage = { type: null, price: 0 };
            modalAddons = [];
            modalPrescription = null;
        }

        // Show Favourites
        favouritesOption.addEventListener('click', async () => {
            currentView = 'favourites';
            favouritesOption.classList.add('selected');
            cartOption.classList.remove('selected');

            favouritesGrid.style.display = 'none';
            cartList.style.display = 'none';
            cartSummary.style.display = 'none';

            actionButton.innerHTML = '<i class="ri-shopping-cart-2-fill"></i> Add to Cart (<span id="actionCount">0</span>)';

            await loadFavourites();
        });

        // Show Cart
        cartOption.addEventListener('click', async () => {
            currentView = 'cart';
            cartOption.classList.add('selected');
            favouritesOption.classList.remove('selected');

            favouritesGrid.style.display = 'none';
            cartList.style.display = 'none';

            actionButton.innerHTML = '<i class="ri-shopping-cart-2-fill"></i> Checkout (<span id="actionCount">0</span>)';

            await loadCart();
        });

        // Action button handler
        actionButton.addEventListener('click', () => {
            if (currentView === 'favourites') {
                addFavouritesToCart();
            } else {
                // Proceed to checkout
                if (selectedCartItems.size > 0) {
                    // TODO: Implement checkout with selected items
                    alert('Checkout functionality - to be implemented');
                    // window.location.href = 'checkout.aspx';
                } else {
                    alert('Please select items to checkout');
                }
            }
        });

        // Initialize page
        window.initializeFavCartPage = async function () {
            console.log('[fav_cart] Initializing page...');
            await loadFavourites();
        };

        // Expose functions globally
        window.toggleFavouriteSelection = toggleFavouriteSelection;
        window.unlikeProduct = unlikeProduct;
        window.toggleCartSelection = toggleCartSelection;
        window.updateQuantity = updateQuantity;
        window.removeFromCart = removeFromCart;
        window.openEditModal = openEditModal;
        window.closeEditModal = closeEditModal;
        window.selectModalPackage = selectModalPackage;
        window.toggleModalAddon = toggleModalAddon;
        window.saveCartItemEdit = saveCartItemEdit;
    </script>
</asp:Content>
