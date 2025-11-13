<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="product.aspx.cs" Inherits="Opton.Pages.Customer.product" MasterPageFile="~/Site.Master" Async="true" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <script type="module" src="https://unpkg.com/@google/model-viewer@latest/dist/model-viewer.min.js"></script>
    <!-- THREE.js + MindAR for AR -->
    <script src="https://cdn.jsdelivr.net/npm/three@0.150.1/build/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.150.1/examples/js/loaders/GLTFLoader.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mind-ar@1.1.4/dist/mindar-face.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/mind-ar@1.1.4/dist/mindar-face-three.prod.js"></script>
    <!-- Babylon.js Core -->
    <script src="https://cdn.babylonjs.com/babylon.js"></script>
    <!-- Babylon.js Loaders (for GLB/GLTF files) -->
    <script src="https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js"></script>
    <!-- Optional Babylon.js GUI or Additional Modules -->
    <script src="https://cdn.babylonjs.com/gui/babylon.gui.min.js"></script>

    <style>
        .product-page {
            display: flex;
            flex-direction: column;
            gap: 40px;
            padding: 20px;
        }

        .product-main {
            display: flex;
            gap: 20px;
            align-items: stretch;
            justify-content: space-between;
            width: 100%;
        }

        .view-options {
            flex: 0 1 160px;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .product-display-wrapper {
            flex: 2 1 0%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: center;
            background: white;
            border-radius: 64px;
            overflow: hidden;
            padding: 20px;
            min-height: 500px;
            max-height: 600px;
        }

        .product-display:fullscreen {
            background: white;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .product-display {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            width: 100%;
            height: 100%;
            position: relative;
        }

            .product-display img {
                max-width: 90%;
                max-height: 90%;
                object-fit: contain;
            }

            .product-display model-viewer {
                width: 100%;
                height: 100%;
            }

        .product-details {
            flex: 1 1 0%;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .view-options .option-box,
        .product-display-wrapper {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .view-options .option-box {
            width: 100%;
            height: 140px;
            display: flex;
            justify-content: center;
            align-items: center;
            font-weight: bold;
            font-size: 32px;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

            .view-options .option-box.hidden {
                display: none;
            }

            .view-options .option-box:hover {
                transform: scale(1.05);
                box-shadow: 0 4px 8px rgba(0,0,0,0.2);
            }

            .view-options .option-box.active {
                border: 3px solid var(--color-accent);
            }

        .view-options model-viewer {
            width: 100%;
            height: 100%;
            pointer-events: none;
        }

        .view-options img {
            max-width: 90%;
            max-height: 90%;
            border-radius: 12px;
        }

        .display-actions {
            align-self: flex-end;
            display: flex;
            gap: 10px;
        }

        .icon-btn {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            border: none;
            background: transparent;
            color: inherit;
            font-size: 24px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

            .icon-btn:hover {
                background: rgba(0,0,0,0.05);
            }

        .product-name {
            font-size: 28px;
            font-weight: bold;
        }

        .product-meta {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
        }

        .price {
            font-size: 20px;
            font-weight: bold;
        }

        .circles {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }

        .circle {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            border: 2px solid transparent;
            transition: all 0.2s ease;
        }

            .circle:hover {
                border-color: var(--color-accent);
            }

            .circle.selected {
                border-color: var(--color-accent);
                box-shadow: 0 0 0 2px white, 0 0 0 4px var(--color-accent);
            }

        .stock {
            text-align: right;
            font-style: italic;
        }

        .action-buttons .action-row {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-top: 10px;
        }

        .main-btn {
            flex: 1;
            height: 60px;
            background: var(--color-accent);
            border: none;
            border-radius: 12px;
            color: white;
            font-size: 18px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

            .main-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.2);
            }

            .main-btn:disabled {
                background: #ccc;
                cursor: not-allowed;
            }

        .cart-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background: #e74c3c;
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: none;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: bold;
            z-index: 10;
        }

        .circle-btn {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            border: none;
            background: transparent;
            color: var(--color-accent);
            font-size: 24px;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }

            .circle-btn:hover {
                background: rgba(0,0,0,0.05);
            }

            .circle-btn.liked {
                color: #e74c3c;
            }

        .details-reviews .tabs {
            display: flex;
            gap: 20px;
            font-size: 20px;
        }

        .tab {
            cursor: pointer;
            padding: 8px 0;
        }

            .tab.active {
                border-bottom: 3px solid var(--color-accent);
                font-weight: bold;
            }

        .recommendations {
            text-align: center;
        }

            .recommendations h3 {
                font-size: 20px;
                font-weight: bold;
            }

            .recommendations .catalogue-line {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 15px;
            }

        .loading {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 400px;
            font-size: 18px;
        }

        .face-shape-label {
            position: absolute;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(255, 255, 255, 0.9);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 16px;
            font-weight: bold;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
            z-index: 10;
        }

        .camera-controls-inline {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 10px;
        }

            .camera-controls-inline .main-btn {
                flex: 0 1 auto;
                height: 48px;
                padding: 0 20px;
                background: rgba(0, 0, 0, 0.7);
                backdrop-filter: blur(10px);
            }

                .camera-controls-inline .main-btn:hover {
                    background: rgba(0, 0, 0, 0.85);
                }

        #arCanvas {
            width: 100%;
            height: 100%;
            border-radius: 8px;
            object-fit: cover;
        }

        #cameraVideo {
            object-fit: cover;
        }

        .dimension-label {
            position: absolute;
            color: var(--color-accent);
            font-size: 14px;
            font-weight: bold;
            white-space: nowrap;
            pointer-events: none;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .dimension-line {
            position: absolute;
            background: var(--color-accent);
            pointer-events: none;
        }

        /* Fullscreen AR styles */
        #ar-container.fullscreen-ar {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            z-index: 9999;
            background: #000;
        }

            #ar-container.fullscreen-ar canvas {
                width: 100% !important;
                height: 100% !important;
                object-fit: contain; /* This prevents stretching */
            }

            #ar-container.fullscreen-ar .camera-controls-inline {
                position: fixed;
                bottom: 30px;
                left: 50%;
                transform: translateX(-50%);
                z-index: 10000;
                background: rgba(0, 0, 0, 0.7);
                padding: 15px;
                border-radius: 12px;
                backdrop-filter: blur(10px);
            }

            #ar-container.fullscreen-ar .main-btn {
                background: rgba(255, 255, 255, 0.9);
                color: #000;
                border: 2px solid rgba(255, 255, 255, 0.3);
            }

                #ar-container.fullscreen-ar .main-btn:hover {
                    background: rgba(255, 255, 255, 1);
                    transform: translateY(-2px);
                }

            /* Fullscreen exit button */
            #ar-container.fullscreen-ar .fullscreen-exit-btn {
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 10000;
                width: 50px;
                height: 50px;
                border-radius: 50%;
                background: rgba(0, 0, 0, 0.7);
                border: 2px solid rgba(255, 255, 255, 0.3);
                color: white;
                font-size: 20px;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                backdrop-filter: blur(10px);
            }

                #ar-container.fullscreen-ar .fullscreen-exit-btn:hover {
                    background: rgba(0, 0, 0, 0.9);
                    transform: scale(1.1);
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
            .product-main {
                flex-wrap: wrap;
            }

            .view-options {
                flex: 0 1 120px;
                order: 1;
            }

            .product-display-wrapper {
                flex: 1 1 calc(100% - 140px);
                order: 2;
                min-height: 300px;
            }

            .product-details {
                flex: 1 1 100%;
                order: 3;
                margin-top: 20px;
            }
        }

        /* Review Multiple Images Styles */
        .review-image {
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
            border: 2px solid #e0e0e0;
        }

            .review-image:hover {
                transform: scale(1.05);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
                border-color: var(--color-accent);
            }

        /* Modal navigation styles */
        .nav-btn:hover {
            background: rgba(255,255,255,0.3) !important;
            transform: scale(1.1);
        }

        .close-btn:hover {
            background: rgba(255,255,255,1) !important;
            transform: scale(1.1);
        }

        /* Image grid for multiple images */
        .review-images-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 10px;
            margin-top: 10px;
        }

        /* Modal animation */
        #imageModal {
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
            }

            to {
                opacity: 1;
            }
        }

        /* Responsive design for review images */
        @media (max-width: 768px) {
            .review-image {
                width: 100px !important;
                height: 100px !important;
            }

            .nav-btn {
                width: 40px !important;
                height: 40px !important;
                font-size: 16px !important;
            }

            .nav-prev {
                left: 10px !important;
            }

            .nav-next {
                right: 10px !important;
            }

            .close-btn {
                top: 10px !important;
                right: 10px !important;
                width: 35px !important;
                height: 35px !important;
            }
        }

        /* Loading state for images */
        .review-image.loading {
            background: #f0f0f0;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .review-image.loading::after {
                content: 'Loading...';
                font-size: 12px;
                color: #999;
            }
        /* Fullscreen Review Image Styles */
        #reviewFullscreenOverlay {
            animation: fadeIn 0.3s ease;
        }

            #reviewFullscreenOverlay img {
                transition: transform 0.3s ease;
            }

                #reviewFullscreenOverlay img:hover {
                    transform: scale(1.02);
                }

        .nav-btn:hover, .close-btn:hover {
            transform: scale(1.1);
            transition: transform 0.2s ease;
        }

        .nav-btn:active, .close-btn:active {
            transform: scale(0.95);
        }

        /* Touch-friendly buttons for mobile */
        @media (max-width: 768px) {
            .nav-btn, .close-btn {
                width: 50px !important;
                height: 50px !important;
                font-size: 20px !important;
            }

            .nav-prev {
                left: 10px !important;
            }

            .nav-next {
                right: 10px !important;
            }

            .close-btn {
                top: 10px !important;
                right: 10px !important;
            }

            .image-counter {
                font-size: 14px !important;
                padding: 6px 16px !important;
            }
        }

        /* Smooth transitions */
        .review-image {
            transition: all 0.3s ease;
        }

            .review-image:hover {
                transform: scale(1.05);
                box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
            }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="product-page" id="productPage" style="display: none;">
        <div class="product-main">
            <div class="view-options">
                <div class="option-box active" data-view="static" id="option1">
                    <model-viewer id="modelOption1" camera-orbit="0deg 75deg auto" disable-pan disable-zoom interaction-prompt="none"></model-viewer>
                </div>
                <div class="option-box" data-view="angle" id="option2">
                    <model-viewer id="modelOption2" camera-orbit="-45deg 75deg auto" disable-pan disable-zoom interaction-prompt="none"></model-viewer>
                </div>
                <div class="option-box" data-view="interactive" id="option3">
                    <span>360°</span>
                </div>
                <div class="option-box hidden" data-view="camera" id="option4">
                    <i class="ri-camera-ai-fill"></i>
                </div>
            </div>

            <div class="product-display-wrapper">
                <div class="product-display" id="mainDisplay">
                    <model-viewer id="modelMain" camera-orbit="0deg 75deg auto" interaction-prompt="none"></model-viewer>
                </div>
                <div class="display-actions">
                    <button type="button" class="icon-btn" id="actionBtn" style="display: none;">
                        <i class="ri-refresh-line"></i>
                    </button>
                    <button type="button" class="icon-btn" id="dimensionBtn" style="display: none;">
                        <i class="ri-ruler-fill"></i>
                    </button>
                    <button type="button" class="icon-btn" id="fullscreenBtn">
                        <i class="ri-fullscreen-line"></i>
                    </button>
                </div>
            </div>

            <div class="product-details">
                <h2 class="product-name" id="productName">Loading...</h2>
                <div class="product-meta">
                    <span class="product-id" id="productId">#...</span>
                    <span class="product-shape" id="productShape">...</span>
                </div>
                <p class="price" id="productPrice">RM0.00</p>

                <div class="color-options">
                    <strong>Colours</strong>
                    <div class="circles" id="colorCircles">
                    </div>
                </div>

                <div class="size-section" id="sizeSelectionSection" style="display: none;">
                    <strong>Sizes</strong>
                    <div class="size-options" id="sizeOptions">
                    </div>
                </div>

                <p class="stock" id="productStock">Loading stock...</p>

                <div class="action-buttons">
                    <div class="action-row">
                        <button type="button" class="main-btn" id="findRetailerBtn"
                            onclick="window.location.href='<%: ResolveUrl("~/Pages/Customer/find_retailers.aspx") %>'">
                            Find Retailer
                        </button>
                        <button type="button" class="circle-btn" id="likeBtn">
                            <i class="ri-heart-line"></i>
                        </button>
                    </div>
                    <div class="action-row">
                        <button type="button" class="main-btn" id="chooseLensesBtn">Choose Lenses</button>
                        <button type="button" class="circle-btn" id="addToCartBtn">
                            <i class="ri-shopping-cart-2-line"></i>
                            <span class="cart-badge" id="cartBadge">0</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="details-reviews">
            <div class="tabs">
                <span class="tab active" data-tab="details">Details</span>
                <span class="tab" data-tab="reviews">Reviews</span>
            </div>
            <hr style="width: 900px">
            <div class="tab-content" id="tabContent">
                <p id="productDescription">Loading description...</p>
            </div>
        </div>

        <div style="height: 40px;"></div>

        <div class="recommendations" style="background-color: #f5f5f5; padding: 40px 20px; border-radius: 16px;">
            <h3 style="margin-bottom: 20px;">You May Also Like</h3>
            <hr style="width: 900px; margin: 0 auto 30px auto; border: none; border-top: 2px solid var(--color-accent);">
            <div class="catalogue-line" id="recommendations">
            </div>
        </div>

        <div style="text-align: center;">
            <a href="catalogue.aspx" class="main-btn" style="display: inline-block; width: 200px; height: 50px; line-height: 50px; font-size: 16px; text-decoration: none; text-align: center;">Browse More
            </a>
        </div>
    </div>

    <div style="height: 60px;"></div>

    <div class="loading" id="loadingDiv">
        <p>Loading product...</p>
    </div>

    <script type="module">
        import { colourMap, getColour } from '/Scripts/colours.js';

        // Make available globally for the main script
        window.colourMap = colourMap;
        window.getColour = getColour;
</script>
    <script>
        let productData = null;
        let currentView = 'static';
        let isLiked = false;
        let selectedColor = null;
        let colorStockMap = {};
        let totalStock = 0;
        let showingDimensions = false;
        let colorGlassesImages = {};
        let isARActive = false;

        // AR/Try-on variables using MindAR
        let mindarThree = null;
        let arAnchor = null;
        let glassesImageUrl = null; // Store the generated PNG URL

        // Color map from catalogue
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

        const STORAGE_KEYS = {
            guestSaved: 'guestSaved',
            guestCart: 'guestCart'
        };

        async function getCurrentUserId() {
            if (typeof window.getCurrentUser === 'function') {
                const user = await window.getCurrentUser();
                return user ? user.uid : null;
            }
            return null;
        }

        async function isAuthenticated() {
            const userId = await getCurrentUserId();
            return userId !== null;
        }

        function getGuestSaved() {
            const data = localStorage.getItem(STORAGE_KEYS.guestSaved);
            return data ? JSON.parse(data) : [];
        }

        function setGuestSaved(items) {
            localStorage.setItem(STORAGE_KEYS.guestSaved, JSON.stringify(items));
        }

        function getGuestCart() {
            const data = localStorage.getItem(STORAGE_KEYS.guestCart);
            return data ? JSON.parse(data) : [];
        }

        function setGuestCart(items) {
            localStorage.setItem(STORAGE_KEYS.guestCart, JSON.stringify(items));
        }

        function showNotification(message) {
            let toast = document.querySelector('.toast');
            if (!toast) {
                toast = document.createElement('div');
                toast.className = 'toast';
                document.body.appendChild(toast);
            }
            toast.textContent = message;
            toast.classList.add('show');
            setTimeout(() => toast.classList.remove('show'), 2000);
        }

        async function likeProduct() {
            const productId = getProductIdFromURL();
            if (!productId) return;

            const isAuth = await isAuthenticated();
            const likeBtn = document.getElementById('likeBtn');
            const heartIcon = likeBtn.querySelector('i');
            const currentlyLiked = heartIcon.classList.contains('ri-heart-fill');
            const action = isLiked ? 'unlike' : 'like';

            console.log(`${action.toUpperCase()} - Product: ${productId}, Auth: ${isAuth}`);

            if (isAuth) {
                const idToken = await window.getIdToken();

                try {
                    const response = await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: action,
                            productId: productId,
                            idToken: idToken
                        })
                    });

                    const result = await response.json();

                    if (result.success) {
                        toggleHeartIcon(heartIcon, isLiked);
                        showNotification(result.message);
                        isLiked = !isLiked;
                    } else {
                        alert(result.message || 'Failed to update favorites');
                    }
                } catch (error) {
                    console.error('Error:', error);
                    alert('Failed to update favorites');
                }
            } else {
                let savedItems = getGuestSaved();

                if (isLiked) {
                    savedItems = savedItems.filter(id => id !== productId);
                } else {
                    if (!savedItems.includes(productId)) {
                        savedItems.push(productId);
                    }
                }

                setGuestSaved(savedItems);
                toggleHeartIcon(heartIcon, isLiked);
                showNotification(isLiked ? 'Removed from favorites' : 'Added to favorites');
                isLiked = !isLiked;
            }
        }

        function toggleHeartIcon(icon, isCurrentlyLiked) {
            if (isCurrentlyLiked) {
                icon.classList.remove('ri-heart-fill');
                icon.classList.add('ri-heart-line');
            } else {
                icon.classList.remove('ri-heart-line');
                icon.classList.add('ri-heart-fill');
            }
        }

        async function addToCart() {
            const productId = getProductIdFromURL();
            if (!productId) return;

            const isAuth = await isAuthenticated();

            // Get selected color and size
            const selectedColor = window.selectedColor || 'Default';
            const selectedSize = window.selectedSize || 'Default';

            console.log('ADD TO CART - Product:', productId, 'Auth:', isAuth, 'Color:', selectedColor, 'Size:', selectedSize);

            if (isAuth) {
                const idToken = await window.getIdToken();

                try {
                    const response = await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: 'addToCart',
                            productId: productId,
                            quantity: 1,
                            colour: selectedColor,
                            size: selectedSize,
                            idToken: idToken
                        })
                    });

                    const result = await response.json();

                    if (result.success) {
                        showNotification(result.message);
                        await updateCartUI();
                    } else {
                        alert(result.message || 'Failed to add to cart');
                    }
                } catch (error) {
                    console.error('Error:', error);
                    alert('Failed to add to cart');
                }
            } else {
                let cartItems = getGuestCart();
                const existingItem = cartItems.find(item =>
                    item.productId === productId &&
                    item.colour === selectedColor &&
                    item.size === selectedSize
                );

                if (existingItem) {
                    existingItem.quantity += 1;
                } else {
                    cartItems.push({
                        productId: productId,
                        quantity: 1,
                        colour: selectedColor,
                        size: selectedSize,
                        addedOn: new Date().toISOString()
                    });
                }

                setGuestCart(cartItems);
                showNotification(existingItem ? 'Cart updated' : 'Added to cart');
                await updateCartUI();
            }
        }

        async function updateCartUI() {
            const isAuth = await isAuthenticated();
            let cartData = {};

            if (isAuth) {
                const idToken = await window.getIdToken();

                try {
                    const response = await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: 'getCart',
                            idToken: idToken
                        })
                    });

                    const result = await response.json();

                    if (result.success && result.items) {
                        result.items.forEach(item => {
                            cartData[item.productId] = item.quantity;
                        });
                    }
                } catch (error) {
                    console.error('Error fetching cart:', error);
                }
            } else {
                const cartItems = getGuestCart();
                cartItems.forEach(item => {
                    cartData[item.productId] = item.quantity;
                });
            }

            // Update cart badge for current product
            const productId = getProductIdFromURL();
            const cartBadge = document.getElementById('cartBadge');
            const cartIcon = document.getElementById('addToCartBtn').querySelector('i');

            if (cartBadge && cartIcon) {
                const quantity = cartData[productId] || 0;

                if (quantity > 0) {
                    cartIcon.classList.remove('ri-shopping-cart-2-line');
                    cartIcon.classList.add('ri-shopping-cart-2-fill');
                    cartBadge.textContent = quantity;
                    cartBadge.style.display = 'inline-block';
                } else {
                    cartIcon.classList.remove('ri-shopping-cart-2-fill');
                    cartIcon.classList.add('ri-shopping-cart-2-line');
                    cartBadge.style.display = 'none';
                }
            }

            // Update global cart count
            const totalCount = Object.values(cartData).reduce((sum, qty) => sum + qty, 0);
            const globalCartBadge = document.querySelector('.cart-count');
            if (globalCartBadge) {
                globalCartBadge.textContent = totalCount;
                globalCartBadge.style.display = totalCount > 0 ? 'inline-block' : 'none';
            }
        }

        async function checkIfLiked() {
            const productId = getProductIdFromURL();
            if (!productId) return;

            const isAuth = await isAuthenticated();
            const likeBtn = document.getElementById('likeBtn');
            const heartIcon = likeBtn.querySelector('i');

            if (isAuth) {
                const idToken = await window.getIdToken();

                try {
                    const response = await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            checkLiked: true,
                            productId: productId,
                            idToken: idToken
                        })
                    });

                    const result = await response.json();

                    if (result.success && result.isLiked) {
                        heartIcon.classList.remove('ri-heart-line');
                        heartIcon.classList.add('ri-heart-fill');
                        window.isLiked = true;
                    } else {
                        heartIcon.classList.remove('ri-heart-fill');
                        heartIcon.classList.add('ri-heart-line');
                        window.isLiked = false;
                    }
                } catch (error) {
                    console.error('Error checking liked status:', error);
                }
            } else {
                const savedItems = getGuestSaved();

                if (savedItems.includes(productId)) {
                    heartIcon.classList.remove('ri-heart-line');
                    heartIcon.classList.add('ri-heart-fill');
                    window.isLiked = true;
                } else {
                    heartIcon.classList.remove('ri-heart-fill');
                    heartIcon.classList.add('ri-heart-line');
                    window.isLiked = false;
                }
            }
        }

        // Get product ID from URL
        function getProductIdFromURL() {
            const params = new URLSearchParams(window.location.search);
            return params.get('id');
        }

        // Extract colors and stock from inventory
        function extractColorsAndStock(product) {
            const sources = {
                inventory: product.inventory || {},
                R1: product.R1 || {},
                R2: product.R2 || {},
                R3: product.R3 || {}
            };

            const colorStockTemp = {};
            let totalStockTemp = 0;
            const colorsSet = new Set();

            Object.values(sources).forEach(source => {
                if (!source || typeof source !== 'object') return;

                // Check if flat structure (color: quantity)
                const isFlatStructure = Object.values(source).every(v => typeof v === 'number');

                if (isFlatStructure) {
                    // Format: {"black":200,"white":183,"brown":90}
                    Object.entries(source).forEach(([key, quantity]) => {
                        if (typeof quantity === 'number') {
                            // Extract color name from key (handle "black23" -> "black")
                            const colorName = key.replace(/[0-9]/g, '').toLowerCase();
                            if (colorMap[colorName]) {
                                colorStockTemp[colorName] = (colorStockTemp[colorName] || 0) + quantity;
                                totalStockTemp += quantity;
                                colorsSet.add(colorName);
                            }
                        }
                    });
                } else {
                    // Format: {"Adults":{"black":8}} or {"Adults":{"black23":19}}
                    Object.values(source).forEach(ageGroup => {
                        if (typeof ageGroup === 'object') {
                            Object.entries(ageGroup).forEach(([key, value]) => {
                                // Extract color name from key
                                const colorName = key.replace(/[0-9]/g, '').toLowerCase();

                                if (typeof value === 'number') {
                                    if (colorMap[colorName]) {
                                        colorStockTemp[colorName] = (colorStockTemp[colorName] || 0) + value;
                                        totalStockTemp += value;
                                        colorsSet.add(colorName);
                                    }
                                } else if (typeof value === 'object') {
                                    // Nested structure with sizes
                                    Object.values(value).forEach(qty => {
                                        if (typeof qty === 'number' && colorMap[colorName]) {
                                            colorStockTemp[colorName] = (colorStockTemp[colorName] || 0) + qty;
                                            totalStockTemp += qty;
                                            colorsSet.add(colorName);
                                        }
                                    });
                                }
                            });
                        }
                    });
                }
            });

            return {
                colorStock: colorStockTemp,
                totalStock: totalStockTemp,
                colors: Array.from(colorsSet)
            };
        }

        // Fetch product data
        async function fetchProduct() {
            const productId = getProductIdFromURL();
            if (!productId) {
                alert('No product ID provided');
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

                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const text = await response.text();
                console.log('Raw response:', text);

                let data;
                try {
                    data = JSON.parse(text);
                } catch (parseError) {
                    console.error('JSON parse error:', parseError);
                    console.error('Response text:', text);
                    alert('Invalid response from server. Check console for details.');
                    return;
                }

                if (data.success && data.product) {
                    productData = data.product;

                    // Extract colors and stock
                    const stockInfo = extractColorsAndStock(productData);
                    colorStockMap = stockInfo.colorStock;
                    totalStock = stockInfo.totalStock;
                    productData.availableColors = stockInfo.colors;

                    populateProductData();
                    await loadModels();
                    await loadRecommendations();
                    checkIfLiked();
                } else {
                    alert('Product not found: ' + (data.message || 'Unknown error'));
                }
            } catch (error) {
                console.error('Error fetching product:', error);
                alert('Failed to load product: ' + error.message);
            }
        }

        // Load 3D models
        async function loadModels() {
            const productId = productData.productId || productData.id;
            const modelFiles = productData.model ? productData.model.split(', ') : [];
            const glbFiles = modelFiles.filter(f => f.toLowerCase().endsWith('.glb'));
            const imageFiles = modelFiles.filter(f => {
                const ext = f.toLowerCase();
                return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.webp');
            });

            const is3DModel = glbFiles.length > 0;
            const isImageModel = imageFiles.length > 0;

            // Show/hide elements based on model type
            const cameraOption = document.getElementById('option4');
            const angleOption = document.getElementById('option2');
            const interactiveOption = document.getElementById('option3');
            const dimensionBtn = document.getElementById('dimensionBtn');
            const chooseLensesBtn = document.getElementById('chooseLensesBtn');
            const likeBtn = document.getElementById('likeBtn');
            const cartBtn = document.getElementById('addToCartBtn');

            if (is3DModel) {
                cameraOption.classList.remove('hidden');
                angleOption.classList.remove('hidden');
                interactiveOption.classList.remove('hidden');
                dimensionBtn.style.display = 'flex';
                chooseLensesBtn.style.display = 'block';

                // Original button layout
                likeBtn.parentElement.style.display = 'flex';
                cartBtn.parentElement.style.display = 'flex';
            } else {
                cameraOption.classList.add('hidden');
                angleOption.classList.add('hidden');
                interactiveOption.classList.add('hidden');
                dimensionBtn.style.display = 'none';
                chooseLensesBtn.style.display = 'none';

                // Move buttons under Find Retailer
                const findRetailerRow = document.getElementById('findRetailerBtn').parentElement;
                likeBtn.parentElement.style.display = 'none';
                cartBtn.parentElement.style.display = 'none';

                // Add buttons to find retailer row
                findRetailerRow.appendChild(likeBtn);
                findRetailerRow.appendChild(cartBtn);
            }

            // Handle image models
            if (isImageModel && !is3DModel) {
                const imageFile = imageFiles[0];
                const path = `Products/${productId}/${imageFile}`;
                const imageUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(path)}?alt=media`;

                const modelMain = document.getElementById('modelMain');
                const modelOption1 = document.getElementById('modelOption1');

                if (modelMain && modelMain.parentElement) {
                    modelMain.parentElement.innerHTML = `<img src="${imageUrl}" alt="${productData.name}" style="max-width: 90%; max-height: 90%; object-fit: contain;">`;
                }
                if (modelOption1 && modelOption1.parentElement) {
                    modelOption1.parentElement.innerHTML = `<img src="${imageUrl}" alt="${productData.name}">`;
                }
                return;
            }

            if (glbFiles.length === 0) {
                console.log('No GLB models found');
                return;
            }

            // Determine if we have multiple color-specific models
            const colorModels = {};
            let defaultModel = null;

            glbFiles.forEach(file => {
                const fileName = file.toLowerCase().replace('.glb', '');
                const path = `Products/${productId}/${file}`;
                const url = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(path)}?alt=media`;

                let colorFound = false;
                productData.availableColors.forEach(color => {
                    if (fileName.includes(color.toLowerCase())) {
                        colorModels[color] = url;
                        colorFound = true;
                    }
                });

                if (!colorFound && !defaultModel) {
                    defaultModel = url;
                }
            });

            const currentColor = selectedColor || productData.availableColors[0] || 'black';
            const initialModelUrl = colorModels[currentColor] || defaultModel || glbFiles[0];

            // Set models
            const modelMain = document.getElementById('modelMain');
            const modelOption1 = document.getElementById('modelOption1');
            const modelOption2 = document.getElementById('modelOption2');

            if (Object.keys(colorModels).length > 1) {
                // Multiple color models - switch model files
                modelMain.src = initialModelUrl;
                modelOption1.src = initialModelUrl;
                modelOption2.src = initialModelUrl;

                modelMain.setAttribute('data-color-models', JSON.stringify(colorModels));
                modelOption1.setAttribute('data-color-models', JSON.stringify(colorModels));
                modelOption2.setAttribute('data-color-models', JSON.stringify(colorModels));

                // Still initialize color for lens transparency
                modelMain.addEventListener('load', async () => {
                    await initializeModelColor(modelMain, currentColor);
                    await generateImageOnLoad();
                });
                modelOption1.addEventListener('load', () => initializeModelColor(modelOption1, currentColor));
                modelOption2.addEventListener('load', () => initializeModelColor(modelOption2, currentColor));
            } else {
                // Single model - use color changing
                const modelUrl = defaultModel || initialModelUrl;
                modelMain.src = modelUrl;
                modelOption1.src = modelUrl;
                modelOption2.src = modelUrl;

                // Initialize color on load with the CURRENT selected color, not first color
                modelMain.addEventListener('load', async () => {
                    await initializeModelColor(modelMain, currentColor);
                    await generateImageOnLoad();
                });
                modelOption1.addEventListener('load', () => initializeModelColor(modelOption1, currentColor));
                modelOption2.addEventListener('load', () => initializeModelColor(modelOption2, currentColor));
            }

            // Don't force select first color if we already have a selected color
            if (!selectedColor) {
                const firstCircle = document.querySelector('.circle');
                if (firstCircle) {
                    firstCircle.click();
                }
            }

            modelMain.addEventListener('load', async () => {
                await initializeModelColor(modelMain, currentColor);
                await generateImageOnLoad();
            });
        }

        // Initialize model color
        async function initializeModelColor(modelViewer, color) {
            await modelViewer.updateComplete;
            const materials = modelViewer.model?.materials || [];

            const frameColor = colorMap[color.toLowerCase()] || [0, 0, 0, 1];

            console.log(`Initializing model color: ${color}`, frameColor);
            console.log('Materials to process:', materials.length);

            materials.forEach((mat, index) => {
                if (!mat.pbrMetallicRoughness) {
                    console.log(`Material ${index}: No PBR metallic roughness`);
                    return;
                }

                const currentColor = mat.pbrMetallicRoughness.baseColorFactor;
                const alpha = currentColor ? currentColor[3] : 1;

                console.log(`Material ${index}: Alpha = ${alpha}`);

                if (alpha < 1) {
                    // Transparent lens - make white/transparent
                    console.log(`Setting material ${index} as transparent lens`);
                    mat.pbrMetallicRoughness.setBaseColorFactor([1, 1, 1, 0.25]);
                    mat.pbrMetallicRoughness.setRoughnessFactor(0.1);
                    mat.pbrMetallicRoughness.setMetallicFactor(0);
                } else {
                    // Frame color
                    console.log(`Setting material ${index} as frame with color:`, color, frameColor);
                    mat.pbrMetallicRoughness.setBaseColorFactor(frameColor);
                }
            });
        }

        // Change model color
        async function changeModelColor(modelViewer, color) {
            if (!modelViewer) {
                console.error('Model viewer is null');
                return;
            }

            // Wait for model to be loaded and ready
            try {
                await modelViewer.updateComplete;

                // Additional wait for model to be fully loaded
                if (!modelViewer.model) {
                    console.log('Model not loaded yet, waiting...');
                    await new Promise((resolve) => {
                        const checkModel = () => {
                            if (modelViewer.model) {
                                resolve();
                            } else {
                                setTimeout(checkModel, 100);
                            }
                        };
                        checkModel();
                    });
                }

                const materials = modelViewer.model?.materials || [];
                const rgba = colorMap[color.toLowerCase()] || [0, 0, 0, 1];

                console.log(`Changing color to ${color} on ${materials.length} materials`);

                materials.forEach((mat, index) => {
                    if (!mat.pbrMetallicRoughness) {
                        console.log(`Material ${index}: No PBR metallic roughness`);
                        return;
                    }

                    const currentColor = mat.pbrMetallicRoughness.baseColorFactor;
                    const alpha = currentColor ? currentColor[3] : 1;

                    if (alpha < 1) {
                        // Check if we're in AR mode - if so, keep lenses completely transparent
                        // Otherwise use semi-transparent for regular display
                        const isARMode = currentView === 'camera';
                        const lensAlpha = isARMode ? 0 : 0.25;

                        console.log(`Setting material ${index} as ${isARMode ? 'COMPLETELY' : 'semi'} transparent lens`);
                        mat.pbrMetallicRoughness.setBaseColorFactor([1, 1, 1, lensAlpha]);
                        mat.pbrMetallicRoughness.setRoughnessFactor(0.1);
                        mat.pbrMetallicRoughness.setMetallicFactor(0);
                    } else {
                        // Frame color
                        mat.pbrMetallicRoughness.setBaseColorFactor(rgba);
                    }
                });

                console.log(`Color changed to ${color} successfully`);
            } catch (error) {
                console.error('Error changing model color:', error);
            }
        }

        // Change GLB model
        function changeGlbModel(color) {
            const modelMain = document.getElementById('modelMain');
            const modelOption1 = document.getElementById('modelOption1');
            const modelOption2 = document.getElementById('modelOption2');

            const colorModels = JSON.parse(modelMain.getAttribute('data-color-models') || '{}');

            if (colorModels[color]) {
                if (modelMain) modelMain.src = colorModels[color];
                if (modelOption1) modelOption1.src = colorModels[color];
                if (modelOption2) modelOption2.src = colorModels[color];

                // Generate AR image for new model after load
                if (!colorGlassesImages[color] && modelOption1) {
                    const handler = async function generateForColor() {
                        await new Promise(r => setTimeout(r, 1000));
                        colorGlassesImages[color] = await generateARImageFromModel();
                        glassesImageUrl = colorGlassesImages[color];
                        console.log('AR image generated for model color:', color);

                        // Update AR view if active
                        if (isARActive && arAnchor) {
                            updateARGlasses(glassesImageUrl);
                        }

                        modelOption1.removeEventListener('load', handler);
                    };

                    modelOption1.addEventListener('load', handler);
                } else {
                    glassesImageUrl = colorGlassesImages[color];
                    // Update AR view if active
                    if (isARActive && arAnchor) {
                        updateARGlasses(glassesImageUrl);
                    }
                }
            }
        }

        const generateImageOnLoad = async () => {
            console.log('Model loaded - generating AR image...');
            await new Promise(r => setTimeout(r, 1000)); // Wait for render
            const image = await generateARImageFromModel();
            if (image) {
                const currentColor = selectedColor || productData.availableColors[0] || 'black';
                colorGlassesImages[currentColor] = image;
                glassesImageUrl = image;
                console.log('AR image ready for try-on');
            }
        };

        // Populate product data into UI
        function populateProductData() {
            document.getElementById('productName').textContent = productData.name || 'Unknown Product';
            document.getElementById('productId').textContent = `#${productData.productId || productData.id || ''}`;
            document.getElementById('productShape').textContent = productData.shape || '';
            document.getElementById('productPrice').textContent = `RM${(productData.price || 0).toFixed(2)}`;
            document.getElementById('productStock').textContent = `${totalStock} in stock`;
            document.getElementById('productDescription').textContent = productData.description || 'No description available';

            // Populate colors
            const colorCircles = document.getElementById('colorCircles');
            colorCircles.innerHTML = '';

            if (productData.availableColors && productData.availableColors.length > 0) {
                productData.availableColors.forEach((color, index) => {
                    const circle = document.createElement('span');
                    circle.className = 'circle';
                    circle.style.background = color;
                    circle.title = `${color} (${colorStockMap[color] || 0} in stock)`;

                    if (index === 0) {
                        circle.classList.add('selected');
                        selectedColor = color;
                    }

                    circle.addEventListener('click', () => selectColor(circle, color));
                    colorCircles.appendChild(circle);
                });
            }

            // Populate size options if available
            populateSizeOptions();

            document.getElementById('loadingDiv').style.display = 'none';
            document.getElementById('productPage').style.display = 'flex';
        }

        // Add new function to populate size options
        let selectedSize = 'Default';

        function populateSizeOptions() {
            const sizeSection = document.getElementById('sizeSelectionSection');
            const sizeOptions = document.getElementById('sizeOptions');

            console.log('=== Populating size options ===');

            const sizes = new Set();

            // Gather all possible data sources (inventory maps)
            const sources = {
                inventory: productData.inventory || {},
                R1: productData.R1 || {},
                R2: productData.R2 || {},
                R3: productData.R3 || {}
            };

            // Loop through each source and extract size categories (Adults, Kids, etc.)
            Object.entries(sources).forEach(([sourceName, source]) => {
                console.log(`Checking source: ${sourceName}`, source);

                if (source && typeof source === 'object') {
                    Object.keys(source).forEach(sizeKey => {
                        const value = source[sizeKey];
                        if (typeof value === 'object') {
                            console.log(`Found size group: ${sizeKey}`);
                            sizes.add(sizeKey);
                        }
                    });
                } else {
                    console.log(`No valid data found in source: ${sourceName}`);
                }
            });

            console.log('Collected sizes:', Array.from(sizes));

            if (sizes.size > 0) {
                // Show size section and populate buttons
                sizeSection.style.display = 'block';
                sizeOptions.innerHTML = '';

                const sortedSizes = Array.from(sizes).sort();

                sortedSizes.forEach((size, index) => {
                    const sizeBtn = document.createElement('div');
                    sizeBtn.className = 'size-option';
                    sizeBtn.textContent = size;

                    if (index === 0) {
                        sizeBtn.classList.add('selected');
                        selectedSize = size;
                        console.log('Default selected size:', selectedSize);
                    }

                    sizeBtn.addEventListener('click', function () {
                        document.querySelectorAll('.size-option').forEach(opt => opt.classList.remove('selected'));
                        this.classList.add('selected');
                        selectedSize = size;
                        console.log('Size selected:', selectedSize);
                    });

                    sizeOptions.appendChild(sizeBtn);
                });
            } else {
                // No sizes available
                console.log('No size variations found; hiding size section.');
                sizeSection.style.display = 'none';
                selectedSize = 'Default';
            }

            console.log('=== Size population complete ===');
        }

        function selectColor(element, color) {
            // Save previous color and check if it's different
            const previousColor = selectedColor;

            // If clicking the same color, do nothing
            if (previousColor === color) {
                console.log('Same color selected, no change needed:', color);
                return;
            }

            document.querySelectorAll('.circle').forEach(c => c.classList.remove('selected'));
            element.classList.add('selected');
            selectedColor = color;

            console.log('Color selected:', color, 'Previous color:', previousColor, 'Current view:', currentView);

            // Update stock display
            const stockForColor = colorStockMap[color] || 0;
            document.getElementById('productStock').textContent = `${stockForColor} in stock (${color})`;

            // ALWAYS update the static models (option1, option2) regardless of current view
            const modelOption1 = document.getElementById('modelOption1');
            const modelOption2 = document.getElementById('modelOption2');

            if (modelOption1) {
                const colorModelsAttr = modelOption1.getAttribute('data-color-models');
                if (colorModelsAttr) {
                    // Multiple GLB files - switch model for static views
                    const colorModels = JSON.parse(colorModelsAttr);
                    if (colorModels[color]) {
                        modelOption1.src = colorModels[color];
                        if (modelOption2) modelOption2.src = colorModels[color];
                    }
                } else {
                    // Single model - change color
                    changeModelColor(modelOption1, color);
                    if (modelOption2) changeModelColor(modelOption2, color);
                }
            }

            // ALWAYS update the colours for ALL views and modes
            const modelMain = document.getElementById('modelMain');
            if (modelMain) {
                const colorModelsAttr = modelMain.getAttribute('data-color-models');

                if (colorModelsAttr) {
                    // Multiple GLB files - switch model
                    changeGlbModel(color);
                } else {
                    // Single model - change color
                    changeModelColor(modelMain, color);
                }
            }

            // ALWAYS generate new AR image for the selected color for camera modes
            generateARImageFromModel().then(newImage => {
                if (newImage) {
                    colorGlassesImages[color] = newImage;
                    glassesImageUrl = newImage;
                    console.log('AR image updated for color:', color);
                }
            });

            // Handle different view modes
            if (currentView === 'camera') {
                // Check if we're in camera AR mode or upload image mode
                const arContainer = document.getElementById('ar-container');
                const hasCanvas = arContainer && arContainer.querySelector('canvas');
                const hasVideo = arContainer && arContainer.querySelector('video');

                if (hasVideo && isARActive) {
                    // Camera AR mode - restart AR with new color
                    console.log('AR Camera mode active - restarting AR with new color:', color);

                    // Add loading overlay
                    const existingLoader = arContainer.querySelector('.color-change-loading');
                    if (!existingLoader) {
                        const loader = document.createElement('div');
                        loader.className = 'color-change-loading';
                        loader.style.cssText = `
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(255,255,255,0.9);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    z-index: 100;
                    flex-direction: column;
                    gap: 10px;
                `;
                        loader.innerHTML = `
                    <div class="spinner" style="
                        width: 40px;
                        height: 40px;
                        border: 4px solid #f3f3f3;
                        border-top: 4px solid var(--color-accent);
                        border-radius: 50%;
                        animation: spin 1s linear infinite;
                    "></div>
                    <p style="color: #333; font-weight: bold;">Updating color and restarting AR...</p>
                `;
                        arContainer.appendChild(loader);
                    }

                    // Stop current AR session
                    stopMindAR();

                    // Wait a moment then restart AR with new color
                    setTimeout(async () => {
                        console.log('Generating new AR image for color:', color);

                        // Generate new image for the selected color
                        const newImage = await generateARImageFromModel();
                        if (newImage) {
                            colorGlassesImages[color] = newImage;
                            glassesImageUrl = newImage;

                            // Restart AR session
                            await startMindAR();

                            // Remove loading spinner
                            const loader = arContainer.querySelector('.color-change-loading');
                            if (loader) {
                                loader.remove();
                            }

                            showNotification(`Color changed to ${color}`);
                        }
                    }, 500);
                } else if (hasCanvas) {
                    // Upload Image mode - just update the glasses image without restarting
                    console.log('Upload Image mode - updating glasses color:', color);

                    // Use existing image if available, otherwise generate new one
                    if (colorGlassesImages[color]) {
                        updateCanvasWithNewColor(colorGlassesImages[color]);
                    } else {
                        // Generate new image without blocking
                        generateARImageFromModel().then(newImage => {
                            if (newImage) {
                                colorGlassesImages[color] = newImage;
                                updateCanvasWithNewColor(newImage);
                            }
                        });
                    }

                    showNotification(`Color changed to ${color}`);
                }
                return;
            }

            // Update dimensions display if active
            if (showingDimensions) {
                displayDimensions();
            }
        }

        // Helper function to update canvas with new color
        function updateCanvasWithNewColor(imageUrl) {
            const arContainer = document.getElementById('ar-container');
            const canvas = arContainer.querySelector('canvas');
            if (canvas) {
                const colorChangeEvent = new CustomEvent('colorChanged', {
                    detail: { imageUrl: imageUrl }
                });
                canvas.dispatchEvent(colorChangeEvent);
            }
        }

        // View switching
        document.querySelectorAll('.option-box').forEach(box => {
            box.addEventListener('click', function () {
                const view = this.getAttribute('data-view');

                document.querySelectorAll('.option-box').forEach(b => b.classList.remove('active'));
                this.classList.add('active');

                const actionBtn = document.getElementById('actionBtn');
                const dimensionBtn = document.getElementById('dimensionBtn');
                const mainDisplay = document.getElementById('mainDisplay');

                // Store current color before switching - ALWAYS preserve the selected color
                const previousColor = selectedColor;

                // Stop AR if switching away from camera view
                if (currentView === 'camera' && view !== 'camera' && isARActive) {
                    stopMindAR();
                }

                // Clear main display
                mainDisplay.innerHTML = '';

                if (view === 'camera') {
                    // Show AR camera view directly in display
                    mainDisplay.innerHTML = `
                <div id="ar-container" style="position: relative; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center;">
                    <div class="loading" style="position: absolute; z-index: 5;">
                        <p>Initializing camera...</p>
                    </div>
                    <input type="file" id="uploadImageInput" accept="image/*" style="display: none;">
                    <div class="camera-controls-inline" style="position: absolute; bottom: 20px; left: 50%; transform: translateX(-50%); z-index: 20; flex-direction: column; gap: 10px;">
                        <button type="button" class="main-btn" id="startCameraBtn">Start Camera</button>
                        <button type="button" class="main-btn" id="uploadImageBtn">Upload Image</button>
                        <button type="button" class="main-btn" id="stopCameraBtn" style="display: none;">Stop Camera</button>
                    </div>
                </div>
            `;

                    actionBtn.style.display = 'none';
                    dimensionBtn.style.display = 'none';
                    showingDimensions = false;
                    clearDimensions();

                    // Attach camera event listeners
                    document.getElementById('startCameraBtn').addEventListener('click', startMindAR);
                    document.getElementById('stopCameraBtn').addEventListener('click', stopMindAR);
                    document.getElementById('uploadImageBtn').addEventListener('click', () => {
                        document.getElementById('uploadImageInput').click();
                    });
                    document.getElementById('uploadImageInput').addEventListener('change', handleImageUploadMindAR);

                    currentView = view;
                    return;
                }

                // For non-camera views, ALWAYS reapply the selected color
                if (view === 'static') {
                    mainDisplay.innerHTML = '<model-viewer id="modelMain" camera-orbit="0deg 75deg auto" disable-pan disable-zoom interaction-prompt="none"></model-viewer>';
                    actionBtn.style.display = 'none';
                    dimensionBtn.style.display = 'flex';
                } else if (view === 'angle') {
                    mainDisplay.innerHTML = '<model-viewer id="modelMain" camera-orbit="-45deg 75deg auto" disable-pan disable-zoom interaction-prompt="none"></model-viewer>';
                    actionBtn.style.display = 'none';
                    dimensionBtn.style.display = 'flex';
                } else if (view === 'interactive') {
                    mainDisplay.innerHTML = '<model-viewer id="modelMain" camera-orbit="0deg 75deg auto" camera-controls interaction-prompt="none"></model-viewer>';
                    actionBtn.style.display = 'flex';
                    actionBtn.innerHTML = '<i class="ri-refresh-line"></i>';
                    dimensionBtn.style.display = 'none';
                    showingDimensions = false;
                    clearDimensions();
                }

                currentView = view;

                // CRITICAL FIX: Always reapply the selected color after view switch
                // Wait a bit for the model-viewer to be initialized, then apply color
                setTimeout(async () => {
                    // First load the models
                    await loadModels();

                    // Then reapply the selected color
                    if (previousColor) {
                        console.log('Reapplying selected color after view switch:', previousColor);

                        // Update the UI to show the correct selected color
                        document.querySelectorAll('.circle').forEach(c => {
                            c.classList.remove('selected');
                            const circleColor = c.style.background || c.title.toLowerCase().split(' ')[0];
                            if (circleColor === previousColor || c.title.toLowerCase().includes(previousColor)) {
                                c.classList.add('selected');
                            }
                        });

                        // Apply the color to the model
                        await applyColorToCurrentView(previousColor);

                        // Update stock display
                        const stockForColor = colorStockMap[previousColor] || 0;
                        document.getElementById('productStock').textContent = `${stockForColor} in stock (${previousColor})`;

                        // Update dimensions if needed
                        if (showingDimensions && (view === 'static' || view === 'angle')) {
                            setTimeout(() => displayDimensions(), 500);
                        }
                    }
                }, 100);
            });
        });

        // Helper function to apply color without clicking
        async function applyColorToCurrentView(color) {
            const modelMain = document.getElementById('modelMain');
            if (!modelMain) {
                console.log('Model main not found yet, retrying...');
                setTimeout(() => applyColorToCurrentView(color), 100);
                return;
            }

            console.log('Applying color to current view:', color, 'View mode:', currentView);

            const colorModelsAttr = modelMain.getAttribute('data-color-models');

            if (colorModelsAttr && colorModelsAttr !== '{}') {
                // Multiple GLB files - switch model
                console.log('Switching GLB model for color:', color);
                changeGlbModel(color);
            } else {
                // Single model - change color
                console.log('Changing color on single model:', color);
                await changeModelColor(modelMain, color);
            }

            // Also update the option box models to maintain consistency
            const modelOption1 = document.getElementById('modelOption1');
            const modelOption2 = document.getElementById('modelOption2');

            if (modelOption1) {
                const option1ColorModels = modelOption1.getAttribute('data-color-models');
                if (option1ColorModels && option1ColorModels !== '{}') {
                    const colorModels = JSON.parse(option1ColorModels);
                    if (colorModels[color]) {
                        modelOption1.src = colorModels[color];
                    }
                } else {
                    changeModelColor(modelOption1, color);
                }
            }

            if (modelOption2) {
                const option2ColorModels = modelOption2.getAttribute('data-color-models');
                if (option2ColorModels && option2ColorModels !== '{}') {
                    const colorModels = JSON.parse(option2ColorModels);
                    if (colorModels[color]) {
                        modelOption2.src = colorModels[color];
                    }
                } else {
                    changeModelColor(modelOption2, color);
                }
            }
        }

        // Reset view button
        document.getElementById('actionBtn').addEventListener('click', function () {
            const modelMain = document.getElementById('modelMain');
            if (modelMain && currentView === 'interactive') {
                // Reset camera to initial position
                modelMain.cameraOrbit = '0deg 75deg auto';
                modelMain.fieldOfView = 'auto';
                modelMain.cameraTarget = 'auto auto auto';
                modelMain.resetTurntableRotation();
            }
        });

        // Dimension button
        document.getElementById('dimensionBtn').addEventListener('click', function () {
            showingDimensions = !showingDimensions;

            if (showingDimensions) {
                displayDimensions();
                this.style.background = 'rgba(0,0,0,0.1)';
            } else {
                clearDimensions();
                this.style.background = 'transparent';
            }
        });

        function displayDimensions() {
            if (!productData.dimensions) return;

            // Parse dimensions: "138 x 47 x 145" (width x height x temple length)
            const dims = productData.dimensions.split('x').map(d => d.trim());
            if (dims.length < 3) return;

            const width = dims[0];
            const height = dims[1];
            const templeLength = dims[2];

            const mainDisplay = document.querySelector('.product-display');
            const modelViewer = document.getElementById('modelMain');

            if (!modelViewer) return;

            // Clear existing dimensions
            clearDimensions();

            // Wait for model to be fully loaded
            setTimeout(() => {
                const displayRect = mainDisplay.getBoundingClientRect();
                const viewerRect = modelViewer.getBoundingClientRect();

                // Calculate center relative to display
                const centerX = viewerRect.width / 2;
                const centerY = viewerRect.height / 2;

                if (currentView === 'static') {
                    // Width dimension (horizontal across frame front) - moved down
                    const widthLabel = document.createElement('div');
                    widthLabel.className = 'dimension-label';
                    widthLabel.style.position = 'absolute';
                    widthLabel.style.left = '50%';
                    widthLabel.style.top = '36%'; // Moved from 30% to 40%
                    widthLabel.style.transform = 'translateX(-50%)';
                    widthLabel.innerHTML = `<span>|</span><span style="border-top: 2px solid var(--color-dark); width: 150px; display: inline-block; margin: 0 8px;"></span><span>|</span> <strong>${width}mm</strong>`;
                    mainDisplay.appendChild(widthLabel);

                    // Height dimension (vertical lens height) - moved down and left
                    const heightLabel = document.createElement('div');
                    heightLabel.className = 'dimension-label';
                    heightLabel.style.position = 'absolute';
                    heightLabel.style.right = '20%'; // Moved from 10% to 15%
                    heightLabel.style.top = '55%'; // Moved from 50% to 55%
                    heightLabel.style.transform = 'translateY(-50%)';
                    heightLabel.style.writingMode = 'vertical-rl';
                    heightLabel.style.textOrientation = 'mixed';
                    heightLabel.innerHTML = `<strong>${height}mm</strong> <span style="border-left: 2px solid var(--color-dark); height: 60px; display: inline-block; margin: 8px 0;"></span>`;
                    mainDisplay.appendChild(heightLabel);
                } else if (currentView === 'angle') {
                    // Temple length (side arm length) - moved left and angled
                    const templeLabel = document.createElement('div');
                    templeLabel.className = 'dimension-label';
                    templeLabel.style.position = 'absolute';
                    templeLabel.style.left = '35%'; // Moved from 50% to 35%
                    templeLabel.style.bottom = '25%';
                    templeLabel.style.transform = 'translateX(-50%) rotate(16deg)'; // Added rotation
                    templeLabel.innerHTML = `<span>|</span><span style="border-top: 2px solid var(--color-dark); width: 180px; display: inline-block; margin: 0 8px;"></span><span>|</span> <strong>${templeLength}mm</strong>`;
                    mainDisplay.appendChild(templeLabel);
                }

                console.log('Dimensions displayed for view:', currentView);
            }, 600);
        }

        function clearDimensions() {
            document.querySelectorAll('.dimension-label').forEach(el => el.remove());
        }

        // Fullscreen
        document.getElementById('fullscreenBtn').addEventListener('click', function () {
            const display = document.querySelector('.product-display');

            if (document.fullscreenElement) {
                document.exitFullscreen();
            } else {
                // Check if we're in camera view
                if (currentView === 'camera') {
                    const arContainer = document.getElementById('ar-container');
                    if (arContainer) {
                        // Enter fullscreen on the AR container specifically
                        arContainer.requestFullscreen().then(() => {
                            // Add fullscreen-specific styling
                            arContainer.classList.add('fullscreen-ar');
                        });
                    }
                } else {
                    // Regular fullscreen for other views
                    display.requestFullscreen();
                }
            }
        });

        // Handle fullscreen change events
        document.addEventListener('fullscreenchange', function () {
            const arContainer = document.getElementById('ar-container');

            if (!document.fullscreenElement && arContainer) {
                // Remove fullscreen styling when exiting fullscreen
                arContainer.classList.remove('fullscreen-ar');
            }
        });

        // Generate PNG snapshot from model-viewer
        async function generateARImageFromModel() {
            console.log('=== Generating AR Image from Model with Transparent Lenses ===');

            const modelOption1 = document.getElementById('modelOption1');

            if (!modelOption1) {
                console.error('Static model viewer not found');
                return null;
            }

            try {
                await modelOption1.updateComplete;

                // Store original material states
                const originalMaterials = [];
                const materials = modelOption1.model?.materials || [];

                materials.forEach((mat, index) => {
                    if (mat.pbrMetallicRoughness) {
                        const currentColor = mat.pbrMetallicRoughness.baseColorFactor;
                        originalMaterials[index] = currentColor ? [...currentColor] : null;
                    }
                });

                // Make lenses COMPLETELY transparent
                materials.forEach((mat, index) => {
                    if (!mat.pbrMetallicRoughness) return;

                    const currentColor = mat.pbrMetallicRoughness.baseColorFactor;
                    const alpha = currentColor ? currentColor[3] : 1;

                    if (alpha < 1) {
                        // COMPLETELY transparent lens for AR try-on
                        console.log(`Setting material ${index} as COMPLETELY transparent lens for AR`);
                        mat.pbrMetallicRoughness.setBaseColorFactor([1, 1, 1, 0]); // Alpha = 0
                    }
                });

                // Wait for render with transparent lenses
                await new Promise(r => setTimeout(r, 1500)); // Increased wait time

                console.log('Taking high-quality snapshot with transparent lenses...');

                // HIGH QUALITY settings
                const blob = await modelOption1.toBlob({
                    idealAspect: true,
                    mimeType: 'image/png',
                    quality: 1.0, // Maximum quality
                    resolutionScale: 2, // Double the resolution for sharper images
                });

                // Restore original material states
                materials.forEach((mat, index) => {
                    if (mat.pbrMetallicRoughness && originalMaterials[index]) {
                        mat.pbrMetallicRoughness.setBaseColorFactor(originalMaterials[index]);
                    }
                });

                if (!blob) {
                    console.error('Failed to create blob');
                    return null;
                }

                const url = URL.createObjectURL(blob);

                // Log the blob size to check quality
                console.log('AR Image Generated - Blob size:', (blob.size / 1024).toFixed(2), 'KB');
                console.log('AR Image URL:', url.substring(0, 50) + '...');

                return url;

            } catch (error) {
                console.error('Error generating AR image with transparent lenses:', error);
                return null;
            }
        }

        // MindAR Camera functionality - IMAGE-BASED (WORKING METHOD FROM TRYON.ASPX)
        async function startMindAR() {
            // Prevent multiple simultaneous starts
            if (isARActive && mindarThree) {
                console.log('AR already active, skipping start');
                return;
            }

            const container = document.getElementById('ar-container');
            const startBtn = document.getElementById('startCameraBtn');
            const uploadBtn = document.getElementById('uploadImageBtn');
            const stopBtn = document.getElementById('stopCameraBtn');
            const loadingDiv = container.querySelector('.loading');

            console.log('=== Starting MindAR (Image-Based) ===');

            try {
                // Generate image from current model if not already done
                if (!glassesImageUrl) {
                    console.log('Generating AR image first...');
                    const currentColor = selectedColor || productData.availableColors[0] || 'black';
                    if (colorGlassesImages[currentColor]) {
                        glassesImageUrl = colorGlassesImages[currentColor];
                    } else {
                        glassesImageUrl = await generateARImageFromModel();
                        colorGlassesImages[currentColor] = glassesImageUrl;
                    }
                }

                if (!glassesImageUrl) {
                    alert('Failed to generate AR image. Please reload the page and try again.');
                    return;
                }

                // Update UI - only if buttons exist (not during auto-restart)
                if (startBtn) startBtn.style.display = 'none';
                if (uploadBtn) uploadBtn.style.display = 'none';
                if (loadingDiv) loadingDiv.style.display = 'flex';

                // Initialize MindAR
                console.log('Initializing MindAR...');
                mindarThree = new window.MINDAR.FACE.MindARThree({
                    container: container
                });

                const { renderer, scene, camera } = mindarThree;

                // Anchor to face (168 is nose bridge landmark)
                arAnchor = mindarThree.addAnchor(168);
                console.log('MindAR initialized');

                // Load IMAGE texture
                console.log('Loading glasses image texture...');
                const textureLoader = new THREE.TextureLoader();
                textureLoader.load(glassesImageUrl, (texture) => {
                    console.log('Texture loaded');
                    const imageMesh = new THREE.Mesh(
                        new THREE.PlaneGeometry(1.2, 1.2), // Increased from 0.8 to 1.2
                        new THREE.MeshBasicMaterial({ map: texture, transparent: true })
                    );
                    imageMesh.scale.x = -1; // mirror horizontally
                    imageMesh.position.set(0, 0.04, 0); // Moved up from 0 to 0.08
                    arAnchor.group.clear();
                    arAnchor.group.add(imageMesh);
                    console.log('Glasses image positioned on face anchor');
                });

                // Start MindAR
                console.log('Starting face tracking...');
                await mindarThree.start();
                console.log('Face tracking started');

                isARActive = true;

                if (loadingDiv) loadingDiv.style.display = 'none';
                if (stopBtn) stopBtn.style.display = 'block';

                // Mirror video
                const videoEl = container.querySelector('video');
                if (videoEl) {
                    videoEl.style.zIndex = "1";
                    videoEl.style.transform = "scaleX(-1)";
                }
                if (renderer && renderer.domElement) {
                    renderer.domElement.style.transform = "scaleX(-1)";
                    renderer.domElement.style.zIndex = "2";
                }

                // Render loop
                if (renderer) {
                    renderer.setAnimationLoop(() => {
                        renderer.render(scene, camera);
                    });
                }

                console.log('✓✓AR Try-On Active! ✓✓✓');

            } catch (error) {
                console.error('MindAR error:', error);
                alert('Failed to start AR: ' + error.message);
                stopMindAR();
            }
        }

        function updateARGlasses(imageUrl) {
            if (!arAnchor || !mindarThree) {
                console.log('AR not active, skipping update');
                return;
            }

            console.log('Updating AR glasses with new color...');
            const textureLoader = new THREE.TextureLoader();

            // Force texture reload by adding timestamp
            const urlWithTimestamp = imageUrl.includes('?')
                ? `${imageUrl}&t=${Date.now()}`
                : `${imageUrl}?t=${Date.now()}`;

            textureLoader.load(urlWithTimestamp, (texture) => {
                const imageMesh = new THREE.Mesh(
                    new THREE.PlaneGeometry(1.2, 1.2),
                    new THREE.MeshBasicMaterial({
                        map: texture,
                        transparent: true,
                        alphaTest: 0.1
                    })
                );
                imageMesh.scale.x = -1;
                imageMesh.position.set(0, 0.04, 0);

                // Clear and add new mesh
                arAnchor.group.clear();
                arAnchor.group.add(imageMesh);

                console.log('AR glasses updated successfully');
            }, undefined, (error) => {
                console.error('Error loading new texture:', error);
            });
        }

        function stopMindAR() {
            console.log('=== Stopping MindAR ===');

            if (mindarThree) {
                // Properly clean up Three.js resources
                const { renderer, scene, camera } = mindarThree;

                // Stop the render loop first
                if (renderer) {
                    renderer.setAnimationLoop(null);
                }

                // Clean up the scene
                if (scene) {
                    while (scene.children.length > 0) {
                        scene.remove(scene.children[0]);
                    }
                }

                // Dispose of renderer
                if (renderer) {
                    renderer.dispose();
                    renderer.forceContextLoss();
                }

                // Now stop MindAR
                mindarThree.stop();
                mindarThree = null;
                arAnchor = null;
                console.log('MindAR stopped and cleaned up');
            }

            isARActive = false; // Reset flag

            const container = document.getElementById('ar-container');
            if (container) {
                // Check if this is an automatic restart (has loading spinner) or manual stop
                const isAutoRestart = container.querySelector('.color-change-loading');

                if (!isAutoRestart) {
                    // Only reset UI if this is a manual stop
                    container.innerHTML = `
                <div class="loading" style="position: absolute; z-index: 5; display: none; background-color: white;">
                    <p>Initializing camera...</p>
                </div>
                <input type="file" id="uploadImageInput" accept="image/*" style="display: none;">
                <div class="camera-controls-inline" style="position: absolute; bottom: 20px; left: 50%; transform: translateX(-50%); z-index: 20; flex-direction: column; gap: 10px;">
                    <button type="button" class="main-btn" id="startCameraBtn">Start Camera</button>
                    <button type="button" class="main-btn" id="uploadImageBtn">Upload Image</button>
                    <button type="button" class="main-btn" id="stopCameraBtn" style="display: none;">Stop Camera</button>
                </div>
            `;

                    document.getElementById('startCameraBtn').addEventListener('click', startMindAR);
                    document.getElementById('stopCameraBtn').addEventListener('click', stopMindAR);
                    document.getElementById('uploadImageBtn').addEventListener('click', () => {
                        document.getElementById('uploadImageInput').click();
                    });
                    document.getElementById('uploadImageInput').addEventListener('change', handleImageUploadMindAR);
                } else {
                    // For auto-restart, just clear the container completely
                    container.innerHTML = '';

                    // Recreate the basic container structure but keep the loading spinner
                    const loader = document.createElement('div');
                    loader.className = 'color-change-loading';
                    loader.style.cssText = `
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(255,255,255,0.9);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 100;
                flex-direction: column;
                gap: 10px;
            `;
                    loader.innerHTML = `
                <div class="spinner" style="
                    width: 40px;
                    height: 40px;
                    border: 4px solid #f3f3f3;
                    border-top: 4px solid var(--color-accent);
                    border-radius: 50%;
                    animation: spin 1s linear infinite;
                "></div>
                <p style="color: #333; font-weight: bold;">Updating color and restarting AR...</p>
            `;

                    const controlsDiv = document.createElement('div');
                    controlsDiv.className = 'camera-controls-inline';
                    controlsDiv.style.cssText = 'position: absolute; bottom: 20px; left: 50%; transform: translateX(-50%); z-index: 20; flex-direction: column; gap: 10px;';

                    const stopBtn = document.createElement('button');
                    stopBtn.type = 'button';
                    stopBtn.className = 'main-btn';
                    stopBtn.id = 'stopCameraBtn';
                    stopBtn.textContent = 'Stop Camera';
                    stopBtn.style.display = 'none';

                    controlsDiv.appendChild(stopBtn);

                    container.appendChild(loader);
                    container.appendChild(controlsDiv);

                    // Re-attach event listener
                    stopBtn.addEventListener('click', stopMindAR);
                }
            }

            console.log('AR stopped and cleaned up');
        }

        async function handleImageUploadMindAR(event) {
            const file = event.target.files[0];
            if (!file) return;

            console.log('=== Processing uploaded image ===');
            const container = document.getElementById('ar-container');
            const startBtn = document.getElementById('startCameraBtn');
            const uploadBtn = document.getElementById('uploadImageBtn');

            // Make glassesImg accessible for color changes
            let glassesImg = null;
            let userImg = null;

            try {
                // Get glasses image
                if (!glassesImageUrl) {
                    const currentColor = selectedColor || productData.availableColors[0] || 'black';
                    if (colorGlassesImages[currentColor]) {
                        glassesImageUrl = colorGlassesImages[currentColor];
                    } else {
                        glassesImageUrl = await generateARImageFromModel();
                        colorGlassesImages[currentColor] = glassesImageUrl;
                    }
                }

                if (!glassesImageUrl) {
                    alert('Failed to prepare glasses image');
                    return;
                }

                startBtn.style.display = 'none';
                uploadBtn.style.display = 'none';

                // Show loading
                container.innerHTML = '<div class="loading"><p>Loading image...</p></div>';

                // Load user's image
                const imageUrl = URL.createObjectURL(file);
                const userImg = new Image();
                await new Promise((resolve, reject) => {
                    userImg.onload = resolve;
                    userImg.onerror = reject;
                    userImg.src = imageUrl;
                });
                console.log('User image loaded:', userImg.width, 'x', userImg.height);

                // Load glasses image
                glassesImg = new Image();
                await new Promise((resolve, reject) => {
                    glassesImg.onload = resolve;
                    glassesImg.onerror = reject;
                    glassesImg.src = glassesImageUrl;
                });

                console.log('Glasses image loaded');

                // Setup container
                container.innerHTML = '';
                container.style.position = 'relative';
                container.style.display = 'flex';
                container.style.alignItems = 'center';
                container.style.justifyContent = 'center';
                container.style.overflow = 'hidden';
                container.style.backgroundColor = '#000';

                // Calculate original display size (non-fullscreen)
                const containerWidth = container.clientWidth;
                const containerHeight = container.clientHeight;
                const imgAspect = userImg.width / userImg.height;
                const containerAspect = containerWidth / containerHeight;

                let originalDisplayWidth, originalDisplayHeight;
                if (imgAspect > containerAspect) {
                    originalDisplayWidth = containerWidth;
                    originalDisplayHeight = containerWidth / imgAspect;
                } else {
                    originalDisplayHeight = containerHeight;
                    originalDisplayWidth = containerHeight * imgAspect;
                }

                // Current display dimensions (will change based on fullscreen state)
                let displayWidth = originalDisplayWidth;
                let displayHeight = originalDisplayHeight;

                // Create canvas
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');

                // Glasses state - store relative positions
                let glassesState = {
                    x: displayWidth / 2,
                    y: displayHeight / 2,
                    scale: 0.25,
                    rotation: 0,
                    isDragging: false,
                    dragStartX: 0,
                    dragStartY: 0,
                    // Store relative position for fullscreen transitions
                    relX: 0.5, // 50% from left
                    relY: 0.5  // 50% from top
                };

                // Initialize relative position
                glassesState.relX = glassesState.x / displayWidth;
                glassesState.relY = glassesState.y / displayHeight;

                // Draw function
                function draw() {
                    // Clear and draw user image
                    ctx.clearRect(0, 0, canvas.width, canvas.height);

                    // Calculate offset to center the image on canvas
                    const offsetX = (canvas.width - displayWidth) / 2;
                    const offsetY = (canvas.height - displayHeight) / 2;

                    ctx.drawImage(userImg, offsetX, offsetY, displayWidth, displayHeight);

                    // Draw glasses
                    ctx.save();
                    ctx.translate(glassesState.x + offsetX, glassesState.y + offsetY);
                    ctx.rotate(glassesState.rotation * Math.PI / 180);
                    ctx.scale(-1, 1); // Mirror

                    const glassesWidth = displayWidth * glassesState.scale;
                    const glassesHeight = glassesWidth * (glassesImg.height / glassesImg.width);

                    ctx.drawImage(
                        glassesImg,
                        -glassesWidth / 2,
                        -glassesHeight / 2,
                        glassesWidth,
                        glassesHeight
                    );
                    ctx.restore();
                }

                // Set canvas dimensions based on fullscreen state
                function setupCanvasDimensions() {
                    const isFullscreen = !!document.fullscreenElement;
                    const oldDisplayWidth = displayWidth;
                    const oldDisplayHeight = displayHeight;

                    if (isFullscreen) {
                        // Use full screen dimensions
                        canvas.width = window.screen.width;
                        canvas.height = window.screen.height;

                        // Recalculate display size for fullscreen
                        const screenAspect = canvas.width / canvas.height;
                        if (imgAspect > screenAspect) {
                            displayWidth = canvas.width;
                            displayHeight = canvas.width / imgAspect;
                        } else {
                            displayHeight = canvas.height;
                            displayWidth = canvas.height * imgAspect;
                        }

                        // Apply fullscreen styling
                        canvas.style.width = '100%';
                        canvas.style.height = '100%';
                        canvas.style.objectFit = 'contain';
                    } else {
                        // Use original non-fullscreen dimensions
                        canvas.width = originalDisplayWidth;
                        canvas.height = originalDisplayHeight;
                        displayWidth = originalDisplayWidth;
                        displayHeight = originalDisplayHeight;

                        // Apply non-fullscreen styling
                        canvas.style.width = originalDisplayWidth + 'px';
                        canvas.style.height = originalDisplayHeight + 'px';
                        canvas.style.objectFit = 'none';
                    }

                    // Update glasses position to maintain relative position
                    if (oldDisplayWidth > 0 && oldDisplayHeight > 0) {
                        // Update position based on relative position
                        glassesState.x = displayWidth * glassesState.relX;
                        glassesState.y = displayHeight * glassesState.relY;
                    } else {
                        // Initial setup
                        glassesState.x = displayWidth / 2;
                        glassesState.y = displayHeight / 2;
                        glassesState.relX = 0.5;
                        glassesState.relY = 0.5;
                    }

                    // Redraw with new dimensions
                    if (userImg) {
                        draw();
                    }
                }

                // Update relative position whenever glasses are moved
                function updateRelativePosition() {
                    glassesState.relX = glassesState.x / displayWidth;
                    glassesState.relY = glassesState.y / displayHeight;
                }

                setupCanvasDimensions();

                canvas.style.display = 'block';
                canvas.style.cursor = 'crosshair';

                // Listen for color change events
                canvas.addEventListener('colorChanged', async (e) => {
                    console.log('Color changed event received, loading new glasses image...');
                    const newGlassesUrl = e.detail.imageUrl;

                    // Load new glasses image
                    const newGlassesImg = new Image();
                    await new Promise((resolve, reject) => {
                        newGlassesImg.onload = resolve;
                        newGlassesImg.onerror = reject;
                        newGlassesImg.src = newGlassesUrl;
                    });

                    // Update the glasses image reference
                    glassesImg = newGlassesImg;

                    // Redraw with new image
                    draw();
                    console.log('Canvas updated with new color');
                });

                // Mouse/Touch events for dragging
                function getEventPos(e) {
                    const rect = canvas.getBoundingClientRect();
                    let x, y;

                    if (e.touches && e.touches.length > 0) {
                        x = e.touches[0].clientX - rect.left;
                        y = e.touches[0].clientY - rect.top;
                    } else {
                        x = e.clientX - rect.left;
                        y = e.clientY - rect.top;
                    }

                    // Convert to canvas coordinates accounting for the centered image
                    const scaleX = displayWidth / rect.width;
                    const scaleY = displayHeight / rect.height;

                    // Calculate the offset of the image within the canvas
                    const imageOffsetX = (rect.width - displayWidth / scaleX) / 2;
                    const imageOffsetY = (rect.height - displayHeight / scaleY) / 2;

                    // Adjust coordinates to be relative to the image, not the entire canvas
                    const adjustedX = (x - imageOffsetX) * scaleX;
                    const adjustedY = (y - imageOffsetY) * scaleY;

                    return {
                        x: Math.max(0, Math.min(displayWidth, adjustedX)),
                        y: Math.max(0, Math.min(displayHeight, adjustedY))
                    };
                }

                function onPointerDown(e) {
                    e.preventDefault();
                    const pos = getEventPos(e);
                    glassesState.isDragging = true;
                    glassesState.dragStartX = pos.x - glassesState.x;
                    glassesState.dragStartY = pos.y - glassesState.y;
                    canvas.style.cursor = 'grabbing';
                }

                function onPointerMove(e) {
                    if (!glassesState.isDragging) return;
                    e.preventDefault();
                    const pos = getEventPos(e);
                    glassesState.x = pos.x - glassesState.dragStartX;
                    glassesState.y = pos.y - glassesState.dragStartY;
                    updateRelativePosition();
                    draw();
                }

                function onPointerUp(e) {
                    e.preventDefault();
                    glassesState.isDragging = false;
                    canvas.style.cursor = 'crosshair';
                    updateRelativePosition();
                }

                // Attach events
                canvas.addEventListener('mousedown', onPointerDown);
                canvas.addEventListener('mousemove', onPointerMove);
                canvas.addEventListener('mouseup', onPointerUp);
                canvas.addEventListener('touchstart', onPointerDown);
                canvas.addEventListener('touchmove', onPointerMove);
                canvas.addEventListener('touchend', onPointerUp);

                // Wheel for scaling
                canvas.addEventListener('wheel', (e) => {
                    e.preventDefault();
                    const delta = e.deltaY > 0 ? -0.02 : 0.02;
                    glassesState.scale = Math.max(0.1, Math.min(1, glassesState.scale + delta));
                    draw();
                });

                // Handle fullscreen changes
                document.addEventListener('fullscreenchange', setupCanvasDimensions);

                // Initial draw
                draw();
                container.appendChild(canvas);

                // Controls container
                const controlsDiv = document.createElement('div');
                controlsDiv.style.position = 'absolute';
                controlsDiv.style.bottom = '20px';
                controlsDiv.style.left = '50%';
                controlsDiv.style.transform = 'translateX(-50%)';
                controlsDiv.style.zIndex = '20';
                controlsDiv.style.display = 'flex';
                controlsDiv.style.gap = '10px';
                controlsDiv.style.flexWrap = 'wrap';
                controlsDiv.style.justifyContent = 'center';
                controlsDiv.style.maxWidth = '90%';

                // Helper to create a button with type="button"
                function createButton(inner, onClick, style = {}) {
                    const btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'main-btn';
                    btn.innerHTML = inner;
                    Object.assign(btn.style, style);
                    btn.onclick = onClick;
                    return btn;
                }

                // Scale buttons
                const scaleUpBtn = createButton(
                    '<i class="ri-zoom-in-line"></i>',
                    () => { glassesState.scale = Math.min(1, glassesState.scale + 0.05); draw(); },
                    { width: '48px', height: '48px', padding: '0', fontSize: '20px' }
                );

                const scaleDownBtn = createButton(
                    '<i class="ri-zoom-out-line"></i>',
                    () => { glassesState.scale = Math.max(0.1, glassesState.scale - 0.05); draw(); },
                    { width: '48px', height: '48px', padding: '0', fontSize: '20px' }
                );

                // Rotate buttons
                const rotateLeftBtn = createButton(
                    '<i class="ri-anticlockwise-line"></i>',
                    () => { glassesState.rotation -= 5; draw(); },
                    { width: '48px', height: '48px', padding: '0', fontSize: '20px' }
                );

                const rotateRightBtn = createButton(
                    '<i class="ri-clockwise-line"></i>',
                    () => { glassesState.rotation += 5; draw(); },
                    { width: '48px', height: '48px', padding: '0', fontSize: '20px' }
                );

                // Download button
                const downloadBtn = createButton(
                    '<i class="ri-download-line"></i>',
                    () => {
                        // Create a new canvas with original image dimensions
                        const downloadCanvas = document.createElement('canvas');
                        downloadCanvas.width = userImg.width;
                        downloadCanvas.height = userImg.height;
                        const downloadCtx = downloadCanvas.getContext('2d');

                        // Draw user image at original size
                        downloadCtx.drawImage(userImg, 0, 0);

                        // Calculate glasses position and size for original dimensions
                        const scaleX = userImg.width / displayWidth;
                        const scaleY = userImg.height / displayHeight;

                        // Calculate the offset for the centered image
                        const offsetX = (canvas.width - displayWidth) / 2;
                        const offsetY = (canvas.height - displayHeight) / 2;

                        downloadCtx.save();
                        downloadCtx.translate((glassesState.x + offsetX) * scaleX, (glassesState.y + offsetY) * scaleY);
                        downloadCtx.rotate(glassesState.rotation * Math.PI / 180);
                        downloadCtx.scale(-1, 1); // Mirror

                        const originalGlassesWidth = userImg.width * glassesState.scale;
                        const originalGlassesHeight = originalGlassesWidth * (glassesImg.height / glassesImg.width);

                        downloadCtx.drawImage(
                            glassesImg,
                            -originalGlassesWidth / 2,
                            -originalGlassesHeight / 2,
                            originalGlassesWidth,
                            originalGlassesHeight
                        );
                        downloadCtx.restore();

                        // Download
                        downloadCanvas.toBlob((blob) => {
                            const url = URL.createObjectURL(blob);
                            const a = document.createElement('a');
                            a.href = url;
                            a.download = `glasses-tryout-${Date.now()}.png`;
                            a.click();
                            URL.revokeObjectURL(url);
                        }, 'image/png');
                    },
                    { width: '48px', height: '48px', padding: '0', fontSize: '20px' }
                );

                // Go back button
                const goBackBtn = createButton(
                    'Back',
                    () => {
                        document.removeEventListener('fullscreenchange', setupCanvasDimensions);
                        stopMindAR();
                        const container = document.getElementById('ar-container');
                        if (container) {
                            container.style.backgroundColor = 'white';
                        }
                    },
                    { height: '48px', padding: '0 20px' }
                );

                // Add buttons
                controlsDiv.appendChild(scaleDownBtn);
                controlsDiv.appendChild(scaleUpBtn);
                controlsDiv.appendChild(rotateLeftBtn);
                controlsDiv.appendChild(rotateRightBtn);
                controlsDiv.appendChild(downloadBtn);
                controlsDiv.appendChild(goBackBtn);
                container.appendChild(controlsDiv);

                // Instructions
                const instructionsDiv = document.createElement('div');
                instructionsDiv.style.position = 'absolute';
                instructionsDiv.style.top = '20px';
                instructionsDiv.style.left = '50%';
                instructionsDiv.style.transform = 'translateX(-50%)';
                instructionsDiv.style.background = 'rgba(255, 255, 255, 0.9)';
                instructionsDiv.style.padding = '10px 20px';
                instructionsDiv.style.borderRadius = '8px';
                instructionsDiv.style.fontSize = '14px';
                instructionsDiv.style.fontWeight = 'bold';
                instructionsDiv.style.zIndex = '20';
                instructionsDiv.textContent = 'Drag to move • Scroll to resize • Use buttons to adjust';
                container.appendChild(instructionsDiv);

                // Hide instructions after 3 seconds
                setTimeout(() => {
                    instructionsDiv.style.transition = 'opacity 0.5s';
                    instructionsDiv.style.opacity = '0';
                    setTimeout(() => instructionsDiv.remove(), 500);
                }, 3000);

                isARActive = true;
                console.log('✓✓Interactive try-on ready!');

            } catch (error) {
                console.error('Image processing error:', error);
                alert('Failed to process image: ' + error.message);
                stopMindAR();
            }
        }

        async function initializeARScene(canvas) {
            try {
                console.log('Initializing AR Scene...');
                console.log('Canvas element:', canvas);
                console.log('Canvas dimensions:', canvas.width, 'x', canvas.height);

                // Verify canvas is valid
                if (!canvas || !canvas.getContext) {
                    throw new Error('Invalid canvas element');
                }

                // Test 2D context first
                const test2d = canvas.getContext('2d');
                if (!test2d) {
                    throw new Error('Cannot get 2D context from canvas');
                }
                console.log('2D context available');

                // Create Babylon.js engine - simplified approach
                console.log('Creating Babylon.js engine...');
                arEngine = new BABYLON.Engine(canvas, true, {
                    preserveDrawingBuffer: true,
                    stencil: true,
                    alpha: true,
                    premultipliedAlpha: false,
                    depth: true
                });

                console.log('Babylon.js engine created successfully');

                // Create scene
                arScene = new BABYLON.Scene(arEngine);
                arScene.clearColor = new BABYLON.Color4(0, 0, 0, 0);
                console.log('Scene created');

                // Create orthographic camera for AR overlay
                const camera = new BABYLON.FreeCamera("camera", new BABYLON.Vector3(0, 0, -5), arScene);
                camera.mode = BABYLON.Camera.ORTHOGRAPHIC_CAMERA;

                const aspect = canvas.width / canvas.height;
                camera.orthoTop = 1;
                camera.orthoBottom = -1;
                camera.orthoLeft = -aspect;
                camera.orthoRight = aspect;
                console.log('Camera created');

                // Add lights
                const light1 = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), arScene);
                light1.intensity = 1.2;

                const light2 = new BABYLON.DirectionalLight("light2", new BABYLON.Vector3(-1, -2, 1), arScene);
                light2.intensity = 0.8;
                console.log('Lights added');

                // Load glasses model
                const productId = productData.productId || productData.id;
                const modelFiles = productData.model ? productData.model.split(', ') : [];
                const glbFiles = modelFiles.filter(f => f.toLowerCase().endsWith('.glb'));

                if (glbFiles.length === 0) {
                    throw new Error('No GLB model files found');
                }

                const currentColor = selectedColor || productData.availableColors[0] || 'black';
                let modelFile = glbFiles[0];

                for (const file of glbFiles) {
                    if (file.toLowerCase().includes(currentColor.toLowerCase())) {
                        modelFile = file;
                        break;
                    }
                }

                const path = `Products/${productId}/${modelFile}`;
                const modelUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(path)}?alt=media`;

                console.log('Loading GLB model from:', modelUrl);

                // Load model with promise
                await new Promise((resolve, reject) => {
                    BABYLON.SceneLoader.ImportMesh(
                        "",
                        "",
                        modelUrl,
                        arScene,
                        function (meshes) {
                            console.log('Model loaded, meshes count:', meshes.length);

                            if (meshes.length === 0) {
                                reject('No meshes in model');
                                return;
                            }

                            // Create parent node
                            const parent = new BABYLON.TransformNode("glassesParent", arScene);

                            meshes.forEach((mesh, index) => {
                                if (mesh) {
                                    mesh.parent = parent;
                                    console.log(`Mesh ${index}:`, mesh.name);
                                }
                            });

                            parent.scaling = new BABYLON.Vector3(0.2, 0.2, 0.2);
                            parent.rotation = new BABYLON.Vector3(0, Math.PI, 0);
                            parent.position = new BABYLON.Vector3(0, 0, 0);
                            parent.setEnabled(false); // Start hidden

                            glassesModel = parent;

                            // Apply colors
                            applyColorToModel(meshes, currentColor);

                            console.log('Model setup complete, glassesModel:', glassesModel);
                            resolve();
                        },
                        null,
                        function (scene, message, exception) {
                            console.error('Model loading error:', message, exception);
                            reject(new Error(message || 'Failed to load model'));
                        }
                    );
                });

                // Start render loop
                arEngine.runRenderLoop(() => {
                    if (arScene) {
                        arScene.render();
                    }
                });

                console.log('AR Scene fully initialized');
                return true;

            } catch (error) {
                console.error('AR Scene initialization failed:', error);
                throw error;
            }
        }

        function applyColorToModel(meshes, colorName) {
            const rgba = colorMap[colorName.toLowerCase()] || [0, 0, 0, 1];

            meshes.forEach(mesh => {
                if (mesh.material) {
                    const material = mesh.material;

                    if (material.albedoColor) {
                        // PBR Material
                        const alpha = material.alpha || 1;

                        if (alpha < 1) {
                            // Transparent lens
                            material.albedoColor = new BABYLON.Color3(1, 1, 1);
                            material.alpha = 0.25;
                        } else {
                            // Frame color
                            material.albedoColor = new BABYLON.Color3(rgba[0], rgba[1], rgba[2]);
                        }
                    }
                }
            });
        }

        async function initializeFaceDetection() {
            try {
                // Check WebGL support
                const canvas = document.createElement('canvas');
                const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');

                if (!gl) {
                    throw new Error('WebGL not supported by your browser');
                }

                // Try to set backend to webgl, fallback to cpu if needed
                try {
                    await tf.setBackend('webgl');
                } catch (e) {
                    console.warn('WebGL backend failed, trying CPU backend:', e);
                    await tf.setBackend('cpu');
                }

                await tf.ready();

                const model = await faceLandmarksDetection.createDetector(
                    faceLandmarksDetection.SupportedModels.MediaPipeFaceMesh,
                    {
                        runtime: 'tfjs',
                        refineLandmarks: true,
                        maxFaces: 1
                    }
                );

                faceDetector = model;
                console.log("Face detection model loaded with backend:", tf.getBackend());
            } catch (error) {
                console.error('Failed to initialize face detection:', error);
                throw new Error('Face detection initialization failed: ' + error.message);
            }
        }

        function detectFaceShape(keypoints) {
            // Simple face shape detection based on facial proportions
            // Get key points: jaw, cheekbones, forehead

            const jawWidth = Math.abs(keypoints[234].x - keypoints[454].x); // Left to right jaw
            const cheekWidth = Math.abs(keypoints[93].x - keypoints[323].x); // Cheekbone width
            const faceLength = Math.abs(keypoints[10].y - keypoints[152].y); // Top to chin
            const foreheadWidth = Math.abs(keypoints[21].x - keypoints[251].x);

            const ratio = faceLength / jawWidth;
            const cheekToJawRatio = cheekWidth / jawWidth;

            let shape = 'Oval';

            if (ratio > 1.5) {
                if (foreheadWidth > jawWidth) {
                    shape = 'Heart';
                } else {
                    shape = 'Oblong';
                }
            } else if (ratio < 1.2) {
                shape = 'Round';
            } else if (cheekToJawRatio > 1.1) {
                shape = 'Diamond';
            } else if (foreheadWidth > cheekWidth && cheekWidth > jawWidth) {
                shape = 'Triangle';
            } else if (Math.abs(foreheadWidth - jawWidth) < 20) {
                shape = 'Square';
            }

            return shape;
        }

        async function startARLoop(video, canvas) {
            // Get a fresh 2D context for video drawing
            const ctx = canvas.getContext('2d', { willReadFrequently: true });

            if (!ctx) {
                console.error('FATAL: Cannot get 2D context from canvas');
                return;
            }

            console.log('2D context obtained successfully');

            const faceShapeLabel = document.getElementById('faceShapeLabel');
            let frameCount = 0;
            let lastLogTime = Date.now();

            async function detectAndRender() {
                if (!video || video.paused || video.ended || !videoStream) {
                    console.log('Video stopped, ending AR loop');
                    return;
                }

                frameCount++;

                try {
                    // Draw video frame - mirrored
                    ctx.save();
                    ctx.scale(-1, 1);
                    ctx.drawImage(video, -canvas.width, 0, canvas.width, canvas.height);
                    ctx.restore();
                } catch (drawError) {
                    console.error('Error drawing video frame:', drawError);
                }

                const now = Date.now();
                const shouldLog = (now - lastLogTime) > 2000;

                if (shouldLog) {
                    console.log(`Frame ${frameCount}, checking for faces...`);
                    lastLogTime = now;
                }

                try {
                    const faces = await faceDetector.estimateFaces(video, {
                        flipHorizontal: false
                    });

                    if (shouldLog) {
                        console.log(`Detected ${faces.length} face(s)`);
                    }

                    if (faces.length > 0) {
                        const face = faces[0];
                        const keypoints = face.keypoints;

                        // Update face shape periodically
                        if (frameCount % 30 === 0) {
                            const faceShape = detectFaceShape(keypoints);
                            if (faceShape !== currentFaceShape) {
                                currentFaceShape = faceShape;
                                if (faceShapeLabel) {
                                    faceShapeLabel.textContent = `Face Shape: ${faceShape}`;
                                }
                                console.log('Face shape:', faceShape);
                            }
                        }

                        // Position glasses
                        if (glassesModel) {
                            const leftEyeInner = keypoints[133];
                            const leftEyeOuter = keypoints[33];
                            const rightEyeInner = keypoints[362];
                            const rightEyeOuter = keypoints[263];
                            const noseTip = keypoints[1];
                            const noseBridge = keypoints[6];

                            const leftEyeCenter = {
                                x: (leftEyeInner.x + leftEyeOuter.x) / 2,
                                y: (leftEyeInner.y + leftEyeOuter.y) / 2
                            };
                            const rightEyeCenter = {
                                x: (rightEyeInner.x + rightEyeOuter.x) / 2,
                                y: (rightEyeInner.y + rightEyeOuter.y) / 2
                            };

                            const eyeDistance = Math.sqrt(
                                Math.pow(rightEyeCenter.x - leftEyeCenter.x, 2) +
                                Math.pow(rightEyeCenter.y - leftEyeCenter.y, 2)
                            );

                            const centerX = (leftEyeCenter.x + rightEyeCenter.x) / 2;
                            const centerY = (leftEyeCenter.y + rightEyeCenter.y) / 2;

                            const angle = Math.atan2(
                                rightEyeCenter.y - leftEyeCenter.y,
                                rightEyeCenter.x - leftEyeCenter.x
                            );

                            // Normalize coordinates
                            const normX = ((centerX / video.videoWidth) * 2 - 1);
                            const normY = -((centerY / video.videoHeight) * 2 - 1);

                            // Position
                            glassesModel.position.x = -normX * 0.8;
                            glassesModel.position.y = normY * 0.8 + 0.12;
                            glassesModel.position.z = 0;

                            // Scale
                            const scale = (eyeDistance / 150) * 0.2;
                            glassesModel.scaling.set(scale, scale, scale);

                            // Rotations
                            glassesModel.rotation.z = angle;

                            const faceCenter = (leftEyeCenter.x + rightEyeCenter.x) / 2;
                            const noseOffset = (noseTip.x - faceCenter) / video.videoWidth;
                            glassesModel.rotation.y = Math.PI - (noseOffset * 1.5);

                            const verticalOffset = (noseBridge.y - centerY) / video.videoHeight;
                            glassesModel.rotation.x = verticalOffset * 0.4;

                            // Enable if hidden
                            if (!glassesModel.isEnabled()) {
                                glassesModel.setEnabled(true);
                                console.log('Glasses now visible on face!');
                            }

                            if (shouldLog) {
                                console.log('Glasses positioned:', {
                                    x: glassesModel.position.x.toFixed(2),
                                    y: glassesModel.position.y.toFixed(2),
                                    scale: scale.toFixed(3),
                                    eyeDist: eyeDistance.toFixed(1)
                                });
                            }
                        } else {
                            console.error('glassesModel is NULL!');
                        }
                    } else {
                        // No face
                        if (glassesModel && glassesModel.isEnabled()) {
                            glassesModel.setEnabled(false);
                        }
                        if (faceShapeLabel && frameCount % 30 === 0) {
                            faceShapeLabel.textContent = 'Face Shape: No face detected';
                        }
                    }
                } catch (error) {
                    console.error('Detection error:', error);
                }

                animationFrameId = requestAnimationFrame(detectAndRender);
            }

            console.log('>>> Starting detection loop <<<');
            detectAndRender();
        }



        async function loadReviews() {
            console.log("Loading reviews...")
            const productId = productData.productId || productData.id;

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'getReviews',
                        productId: productId
                    })
                });

                const data = await response.json();
                console.log('Reviews response:', data); // Add this to debug

                if (data.success && data.reviews && data.reviews.length > 0) {
                    displayReviews(data.reviews); // Call display function
                    return data.reviews;
                } else {
                    displayReviews([]); // Show "no reviews" message
                    return [];
                }

            } catch (error) {
                console.error('Error loading reviews:', error);
                displayReviews([]); // Show "no reviews" message on error
                return [];
            }
        }

        function displayReviews(reviews) {
            const tabContent = document.getElementById('tabContent');

            if (!reviews || reviews.length === 0) {
                tabContent.innerHTML = '<p>No reviews yet. Be the first to review this product!</p>';
                return;
            }

            let html = '<div style="display: flex; flex-direction: column; gap: 20px;">';

            reviews.forEach(review => {
                const rating = review.rating || 0;
                const stars = '★'.repeat(rating) + '☆'.repeat(5 - rating);
                const date = review.dateTime ? new Date(review.dateTime).toLocaleDateString() : 'Unknown date';
                const reviewText = review.review || 'No review text provided.';
                const userName = review.userName || review.email || 'Anonymous User';

                // Add size and color information if available
                const sizeInfo = review.size ? `<div style="font-size: 12px; color: #666; margin-bottom: 5px;">
            <strong>Size:</strong> ${review.size}
        </div>` : '';

                const colorInfo = review.color ? `<div style="font-size: 12px; color: #666; margin-bottom: 5px;">
            <strong>Color:</strong> ${review.color.charAt(0).toUpperCase() + review.color.slice(1)}
        </div>` : '';

                // Handle multiple review media/images
                let mediaHtml = '';
                if (review.media && review.media.trim() !== '') {
                    // Split media string by comma if multiple images exist
                    const mediaFiles = review.media.split(',').map(file => file.trim()).filter(file => file !== '');
                    const productId = review.productId || productData.productId || productData.id;

                    console.log('Processing media files:', mediaFiles, 'for product:', productId);

                    if (mediaFiles.length > 0) {
                        mediaHtml = `
                    <div style="margin-top: 15px;">
                        <div style="font-size: 12px; color: #666; margin-bottom: 8px;">
                            <strong>Attached Images (${mediaFiles.length}):</strong>
                        </div>
                        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                `;

                        mediaFiles.forEach(mediaFile => {
                            // Use the SAME URL format as model images - this should work!
                            const path = `Reviews/${productId}/${mediaFile}`;
                            const imageUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(path)}?alt=media`;

                            console.log('Generated review image URL:', imageUrl);
                            mediaHtml += `
                                <div style="position: relative;">
                                    <img src="${imageUrl}" 
                                         alt="Review image" 
                                         style="width: 120px; height: 120px; border-radius: 6px; cursor: pointer; object-fit: cover; border: 2px solid #e0e0e0;"
                                         class="review-image"
                                         onclick="openFullscreenReviewImage('${imageUrl}', ${JSON.stringify(mediaFiles)}, '${productId}')"
                                         onerror="handleImageError(this)"
                                         onload="handleImageLoad(this)">
                                    <div class="image-loading" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: #f0f0f0; display: flex; align-items: center; justify-content: center; border-radius: 6px;">
                                        <span style="font-size: 12px; color: #999;">Loading...</span>
                                    </div>
                                </div>
                            `;
                        });

                        mediaHtml += `
                        </div>
                    </div>
                `;
                    }
                }

                html += `
            <div style="border: 1px solid #ddd; padding: 20px; border-radius: 8px; background: #f9f9f9;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 10px;">
                    <div style="flex: 1;">
                        <strong style="font-size: 16px; display: block; margin-bottom: 5px;">${userName}</strong>
                        ${sizeInfo}
                        ${colorInfo}
                    </div>
                    <span style="color: #FFD700; font-size: 18px; white-space: nowrap;">${stars}</span>
                </div>
                <p style="color: #666; font-size: 14px; margin-bottom: 12px;">${date}</p>
                <p style="margin: 0 0 15px 0; line-height: 1.5;">${reviewText}</p>
                ${mediaHtml}
            </div>
        `;
            });

            html += '</div>';
            tabContent.innerHTML = html;

            console.log('Reviews displayed with images');
        }

        function openFullscreenReviewImage(imageUrl, allImages = null, productId = null) {
            console.log('Opening fullscreen review image:', imageUrl);

            // Create fullscreen overlay if it doesn't exist
            let fullscreenOverlay = document.getElementById('reviewFullscreenOverlay');
            if (!fullscreenOverlay) {
                fullscreenOverlay = document.createElement('div');
                fullscreenOverlay.id = 'reviewFullscreenOverlay';
                fullscreenOverlay.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.95);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 10000;
            cursor: pointer;
        `;

                fullscreenOverlay.innerHTML = `
            <div style="position: relative; max-width: 95%; max-height: 95%; display: flex; align-items: center; justify-content: center;">
                <!-- Navigation buttons for multiple images -->
                <button type="button" class="nav-btn nav-prev" style="position: absolute; left: 20px; background: rgba(255,255,255,0.2); color: white; border: none; border-radius: 50%; width: 60px; height: 60px; font-size: 24px; cursor: pointer; z-index: 10001; display: none;">
                    <i class="ri-arrow-left-line"></i>
                </button>
                
                <!-- Main image container -->
                <div style="position: relative; display: flex; align-items: center; justify-content: center;">
                    <img src="" alt="Fullscreen review image" 
                         style="max-width: 100%; max-height: 95vh; border-radius: 8px; object-fit: contain;"
                         onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZjBmMGYwIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCwgc2Fucy1zZXJpZiIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPkltYWdlIG5vdCBmb3VuZDwvdGV4dD48L3N2Zz4='">
                    
                    <!-- Image counter -->
                    <div class="image-counter" style="position: absolute; top: 20px; left: 50%; transform: translateX(-50%); background: rgba(0,0,0,0.7); color: white; padding: 8px 20px; border-radius: 20px; font-size: 16px; font-weight: bold; display: none;"></div>
                </div>
                
                <button type="button" class="nav-btn nav-next" style="position: absolute; right: 20px; background: rgba(255,255,255,0.2); color: white; border: none; border-radius: 50%; width: 60px; height: 60px; font-size: 24px; cursor: pointer; z-index: 10001; display: none;">
                    <i class="ri-arrow-right-line"></i>
                </button>
                
                <!-- Close button -->
                <button type="button" class="close-btn" style="position: absolute; top: 20px; right: 20px; background: rgba(255,255,255,0.9); color: #000; border: none; border-radius: 50%; width: 50px; height: 50px; font-size: 24px; cursor: pointer; z-index: 10001;">
                    <i class="ri-close-line"></i>
                </button>
            </div>
        `;

                document.body.appendChild(fullscreenOverlay);

                // Close when clicking outside the image
                fullscreenOverlay.addEventListener('click', function (e) {
                    if (e.target === fullscreenOverlay) {
                        closeFullscreenReviewImage();
                    }
                });

                // Close with Escape key
                document.addEventListener('keydown', function (e) {
                    if (e.key === 'Escape' && fullscreenOverlay.style.display === 'flex') {
                        closeFullscreenReviewImage();
                    }
                });
            }

            const fullscreenImg = fullscreenOverlay.querySelector('img');
            const prevBtn = fullscreenOverlay.querySelector('.nav-prev');
            const nextBtn = fullscreenOverlay.querySelector('.nav-next');
            const closeBtn = fullscreenOverlay.querySelector('.close-btn');
            const imageCounter = fullscreenOverlay.querySelector('.image-counter');

            // Set current image
            fullscreenImg.src = imageUrl;

            // Handle multiple images
            if (allImages && allImages.length > 1 && productId) {
                const currentIndex = allImages.findIndex(img => {
                    const path = `Reviews/${productId}/${img}`;
                    const imgUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(path)}?alt=media`;
                    return imgUrl === imageUrl;
                });

                if (currentIndex !== -1) {
                    // Show navigation
                    prevBtn.style.display = 'flex';
                    nextBtn.style.display = 'flex';
                    imageCounter.style.display = 'block';
                    imageCounter.textContent = `${currentIndex + 1} / ${allImages.length}`;

                    // Navigation functions
                    const navigateImage = (direction) => {
                        let newIndex = currentIndex + direction;
                        if (newIndex < 0) newIndex = allImages.length - 1;
                        if (newIndex >= allImages.length) newIndex = 0;

                        const newImage = allImages[newIndex];
                        const path = `Reviews/${productId}/${newImage}`;
                        const newImageUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(path)}?alt=media`;

                        fullscreenImg.src = newImageUrl;
                        imageCounter.textContent = `${newIndex + 1} / ${allImages.length}`;

                        // Update current image data
                        fullscreenImg.setAttribute('data-current-url', newImageUrl);
                        fullscreenImg.setAttribute('data-all-images', JSON.stringify(allImages));
                        fullscreenImg.setAttribute('data-product-id', productId);

                        // Update navigation for the new image
                        openFullscreenReviewImage(newImageUrl, allImages, productId);
                    };

                    // Navigation event listeners
                    prevBtn.onclick = (e) => {
                        e.stopPropagation();
                        navigateImage(-1);
                    };

                    nextBtn.onclick = (e) => {
                        e.stopPropagation();
                        navigateImage(1);
                    };

                    // Keyboard navigation
                    const handleKeyNavigation = (e) => {
                        if (e.key === 'ArrowLeft') {
                            navigateImage(-1);
                        } else if (e.key === 'ArrowRight') {
                            navigateImage(1);
                        }
                    };

                    document.addEventListener('keydown', handleKeyNavigation);

                    // Store the handler to remove it later
                    fullscreenOverlay._keyHandler = handleKeyNavigation;
                }
            } else {
                // Single image - hide navigation
                prevBtn.style.display = 'none';
                nextBtn.style.display = 'none';
                imageCounter.style.display = 'none';
            }

            // Close button
            closeBtn.onclick = (e) => {
                e.stopPropagation();
                closeFullscreenReviewImage();
            };

            // Store current image data
            fullscreenImg.setAttribute('data-current-url', imageUrl);
            fullscreenImg.setAttribute('data-all-images', JSON.stringify(allImages || []));
            fullscreenImg.setAttribute('data-product-id', productId || '');

            // Show the fullscreen overlay
            fullscreenOverlay.style.display = 'flex';

            // Prevent body scroll
            document.body.style.overflow = 'hidden';
        }

        function closeFullscreenReviewImage() {
            const fullscreenOverlay = document.getElementById('reviewFullscreenOverlay');
            if (fullscreenOverlay) {
                fullscreenOverlay.style.display = 'none';

                // Remove keyboard navigation listener
                if (fullscreenOverlay._keyHandler) {
                    document.removeEventListener('keydown', fullscreenOverlay._keyHandler);
                    delete fullscreenOverlay._keyHandler;
                }
            }

            // Restore body scroll
            document.body.style.overflow = '';
        }

        // Helper functions for image loading states (keep these the same)
        function handleImageError(imgElement) {
            console.error('Failed to load image:', imgElement.src);
            const loadingDiv = imgElement.parentElement.querySelector('.image-loading');
            if (loadingDiv) {
                loadingDiv.innerHTML = '<span style="font-size: 12px; color: #ff4444;">Failed to load</span>';
            }
            imgElement.style.display = 'none';
        }

        function handleImageLoad(imgElement) {
            const loadingDiv = imgElement.parentElement.querySelector('.image-loading');
            if (loadingDiv) {
                loadingDiv.style.display = 'none';
            }
            console.log('Image loaded successfully:', imgElement.src);
        }

        async function loadRecommendations() {
            const productId = productData.productId || productData.id;
            const currentShape = productData.shape;
            const currentCategory = productData.category;
            const currentColors = productData.availableColors || [];

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'getProductsList'
                    })
                });

                const data = await response.json();

                if (!data.success || !data.products) {
                    console.error('Failed to load products for recommendations');
                    return;
                }

                let allProducts = data.products.filter(p => {
                    const id = p.productId || p.id;
                    return id !== productId; // Exclude current product
                });

                // Scoring system
                let scoredProducts = allProducts.map(product => {
                    let score = 0;

                    // Same shape = +10 points
                    if (product.shape === currentShape) {
                        score += 10;
                    }

                    // Same category = +5 points
                    if (product.category === currentCategory) {
                        score += 5;
                    }

                    // Shared colors = +3 points per color
                    const productColors = [];
                    if (product.inventory && typeof product.inventory === 'object') {
                        Object.keys(product.inventory).forEach(key => {
                            if (typeof product.inventory[key] === 'number') {
                                productColors.push(key.toLowerCase());
                            }
                        });
                    }

                    currentColors.forEach(color => {
                        if (productColors.includes(color.toLowerCase())) {
                            score += 3;
                        }
                    });

                    // Accessories category = +2 points (always relevant)
                    if (product.category && product.category.toLowerCase() === 'accessories') {
                        score += 2;
                    }

                    return { product, score };
                });

                // Sort by score (descending)
                scoredProducts.sort((a, b) => b.score - a.score);

                // Take top 5
                const topRecommendations = scoredProducts.slice(0, 5);

                console.log('Recommendations loaded:', topRecommendations.length);
                displayRecommendations(topRecommendations.map(item => item.product));

            } catch (error) {
                console.error('Error loading recommendations:', error);
            }
        }

        function displayRecommendations(products) {
            const container = document.getElementById('recommendations');

            if (!products || products.length === 0) {
                container.innerHTML = '<p>No recommendations available.</p>';
                return;
            }

            container.innerHTML = '';

            products.forEach(product => {
                const productId = product.productId || product.id;
                const productName = product.name || 'Unknown Product';
                const productPrice = product.price || 0;

                // Extract first available color using the same logic as main product
                const stockInfo = extractColorsAndStock(product);
                const firstColor = stockInfo.colors[0] || 'black';

                console.log('Recommendation:', productName, 'First color:', firstColor, 'Product ID:', productId);

                // Get model files
                const modelFiles = product.model ? product.model.split(', ') : [];
                const glbFile = modelFiles.find(f => f.toLowerCase().endsWith('.glb'));
                const imageFile = modelFiles.find(f => {
                    const ext = f.toLowerCase();
                    return ext.endsWith('.jpg') || ext.endsWith('.jpeg') ||
                        ext.endsWith('.png') || ext.endsWith('.webp');
                });

                const productCard = document.createElement('div');
                productCard.style.cssText = `
            width: 200px;
            height: 320px;
            background: white;
            border-radius: 12px;
            padding: 15px;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.2s ease;
            text-align: center;
            display: flex;
            flex-direction: column;
        `;

                let displayContent = '';

                if (glbFile) {
                    // Use model-viewer for 3D models
                    const modelPath = `Products/${productId}/${glbFile}`;
                    const modelUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(modelPath)}?alt=media`;
                    const viewerId = `rec-model-${productId}`;

                    displayContent = `
                <div style="width: 100%; height: 180px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px;">
                    <model-viewer 
                        id="${viewerId}"
                        src="${modelUrl}"
                        camera-orbit="0deg 75deg auto"
                        disable-pan
                        disable-zoom
                        interaction-prompt="none"
                        style="width: 100%; height: 100%;"
                        data-first-color="${firstColor}">
                    </model-viewer>
                </div>
            `;
                } else if (imageFile) {
                    // Use image
                    const imagePath = `Products/${productId}/${imageFile}`;
                    const imageUrl = `https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/${encodeURIComponent(imagePath)}?alt=media`;

                    displayContent = `
                <div style="width: 100%; height: 180px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px;">
                    <img src="${imageUrl}" alt="${productName}" style="max-width: 100%; max-height: 100%; object-fit: contain;">
                </div>
            `;
                } else {
                    displayContent = `
                <div style="width: 100%; height: 180px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px; background: #f0f0f0; border-radius: 8px;">
                    <span style="color: #999;">No image</span>
                </div>
            `;
                }

                productCard.innerHTML = `
            ${displayContent}
            <div style="flex: 1; display: flex; flex-direction: column; justify-content: space-between;">
                <p style="font-weight: bold; margin-bottom: 5px; font-size: 14px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${productName}</p>
                <p style="color: var(--color-accent); font-weight: bold; font-size: 16px;">RM${productPrice.toFixed(2)}</p>
            </div>
        `;

                // Initialize model color after adding to DOM
                if (glbFile) {
                    setTimeout(() => {
                        const viewer = document.getElementById(viewerId);
                        if (viewer) {
                            // Use the same initialization logic as the main product
                            viewer.addEventListener('load', async () => {
                                await viewer.updateComplete;
                                const materials = viewer.model?.materials || [];
                                const frameColor = colorMap[firstColor.toLowerCase()] || [0, 0, 0, 1];

                                console.log(`Initializing recommendation: ${productName} with color: ${firstColor}`, frameColor);
                                console.log('Materials found:', materials.length);

                                materials.forEach((mat, index) => {
                                    if (!mat.pbrMetallicRoughness) {
                                        console.log(`Material ${index}: No PBR metallic roughness`);
                                        return;
                                    }

                                    const currentColor = mat.pbrMetallicRoughness.baseColorFactor;
                                    const alpha = currentColor ? currentColor[3] : 1;

                                    console.log(`Material ${index}: Alpha = ${alpha}`);

                                    if (alpha < 1) {
                                        // Transparent lens - make white/transparent
                                        console.log(`Setting material ${index} as transparent lens`);
                                        mat.pbrMetallicRoughness.setBaseColorFactor([1, 1, 1, 0.25]);
                                        mat.pbrMetallicRoughness.setRoughnessFactor(0.1);
                                        mat.pbrMetallicRoughness.setMetallicFactor(0);
                                    } else {
                                        // Frame color - apply the selected color
                                        console.log(`Setting material ${index} as frame with color:`, firstColor, frameColor);
                                        mat.pbrMetallicRoughness.setBaseColorFactor(frameColor);
                                    }
                                });

                                console.log('Recommendation model initialized:', productName, 'with color:', firstColor);
                            });

                            // Also handle errors
                            viewer.addEventListener('error', (event) => {
                                console.error('Error loading recommendation model:', productName, event.detail);
                            });
                        } else {
                            console.error('Could not find viewer element:', viewerId);
                        }
                    }, 100);
                }

                productCard.addEventListener('click', () => {
                    window.location.href = `product.aspx?id=${productId}`;
                });

                productCard.addEventListener('mouseenter', function () {
                    this.style.transform = 'scale(1.05)';
                    this.style.boxShadow = '0 4px 16px rgba(0,0,0,0.15)';
                });

                productCard.addEventListener('mouseleave', function () {
                    this.style.transform = 'scale(1)';
                    this.style.boxShadow = '0 2px 8px rgba(0,0,0,0.1)';
                });

                container.appendChild(productCard);
            });
        }

        // Choose Lenses button
        document.getElementById('chooseLensesBtn').addEventListener('click', function () {
            const productId = productData.productId || productData.id;

            if (!selectedColor) {
                alert('Please select a color first');
                return;
            }

            // Redirect to lenses.aspx with product ID and selected color
            window.location.href = `/Pages/Customer/lenses.aspx?id=${productId}&color=${selectedColor}`;
        });

        // Tab switching
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', function () {
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                this.classList.add('active');

                const tabName = this.getAttribute('data-tab');
                if (tabName === 'details') {
                    // Always show product description in details tab
                    document.getElementById('tabContent').innerHTML =
                        `<p>${productData.description || 'No description available'}</p>`;
                } else if (tabName === 'reviews') {
                    // Show loading message while fetching reviews
                    document.getElementById('tabContent').innerHTML = '<p>Loading reviews...</p>';

                    // Load and display reviews
                    loadReviews().then(reviews => {
                        console.log('Reviews loaded and displayed');
                    });
                }
            });
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', fetchProduct);
        // Add event listeners for like and cart buttons
        document.getElementById('likeBtn').addEventListener('click', likeProduct);
        document.getElementById('addToCartBtn').addEventListener('click', addToCart);

        // Initialize UI state
        checkIfLiked();
        updateCartUI();
    </script>
</asp:Content>
