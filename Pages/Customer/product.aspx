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

                <p class="stock" id="productStock">Loading stock...</p>

                <div class="action-buttons">
                    <div class="action-row">
                        <button type="button" class="main-btn" id="findRetailerBtn">Find Retailer</button>
                        <button type="button" class="circle-btn" id="likeBtn">
                            <i class="ri-heart-line"></i>
                        </button>
                    </div>
                    <div class="action-row">
                        <button type="button" class="main-btn" id="chooseLensesBtn">Choose Lenses</button>
                        <button type="button" class="circle-btn" id="addToCartBtn">
                            <i class="ri-shopping-cart-2-line"></i>
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

        <div class="recommendations">
            <h3>Recommendations</h3>
            <hr style="width: 900px; margin: 0 auto;">
            <div class="catalogue-line" id="recommendations">
            </div>
        </div>
    </div>

    <div class="loading" id="loadingDiv">
        <p>Loading product...</p>
    </div>

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

            Object.values(sources).forEach(source => {
                if (!source || typeof source !== 'object') return;

                // Check if flat structure (color: quantity)
                const isFlatStructure = Object.values(source).every(v => typeof v === 'number');

                if (isFlatStructure) {
                    // Format: {"black":200,"white":183,"brown":90}
                    Object.entries(source).forEach(([color, quantity]) => {
                        if (typeof quantity === 'number') {
                            colorStockTemp[color] = (colorStockTemp[color] || 0) + quantity;
                            totalStockTemp += quantity;
                        }
                    });
                } else {
                    // Format: {"Adults":{"black":8}} or {"Adults":{"black":{"S":5}}}
                    Object.values(source).forEach(ageGroup => {
                        if (typeof ageGroup === 'object') {
                            Object.entries(ageGroup).forEach(([color, value]) => {
                                if (typeof value === 'number') {
                                    colorStockTemp[color] = (colorStockTemp[color] || 0) + value;
                                    totalStockTemp += value;
                                } else if (typeof value === 'object') {
                                    // Nested structure with sizes
                                    Object.values(value).forEach(qty => {
                                        if (typeof qty === 'number') {
                                            colorStockTemp[color] = (colorStockTemp[color] || 0) + qty;
                                            totalStockTemp += qty;
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
                colors: Object.keys(colorStockTemp)
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

            const firstColor = productData.availableColors[0] || 'black';
            const initialModelUrl = colorModels[firstColor] || defaultModel || glbFiles[0];

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

                // Still initialize color for lens transparency
                modelMain.addEventListener('load', async () => {
                    await initializeModelColor(modelMain, firstColor);
                    await generateImageOnLoad();
                });                modelOption1.addEventListener('load', () => initializeModelColor(modelOption1, firstColor));
                modelOption2.addEventListener('load', () => initializeModelColor(modelOption2, firstColor));
            } else {
                // Single model - use color changing
                const modelUrl = defaultModel || initialModelUrl;
                modelMain.src = modelUrl;
                modelOption1.src = modelUrl;
                modelOption2.src = modelUrl;

                // Initialize color on load
                modelMain.addEventListener('load', async () => {
                    await initializeModelColor(modelMain, firstColor);
                    await generateImageOnLoad();
                });                modelOption1.addEventListener('load', () => initializeModelColor(modelOption1, firstColor));
                modelOption2.addEventListener('load', () => initializeModelColor(modelOption2, firstColor));
            }

            // Force select first color
            const firstCircle = document.querySelector('.circle');
            if (firstCircle) {
                firstCircle.click();
            }

            modelMain.addEventListener('load', async () => {
                await initializeModelColor(modelMain, firstColor);
                await generateImageOnLoad();
            });
        }

        // Initialize model color (from catalogue)
        async function initializeModelColor(modelViewer, color) {
            await modelViewer.updateComplete;
            const materials = modelViewer.model?.materials || [];

            const frameColor = colorMap[color.toLowerCase()] || [0, 0, 0, 1];

            materials.forEach(mat => {
                if (!mat.pbrMetallicRoughness) return;

                const alpha = mat.pbrMetallicRoughness.baseColorFactor?.[3] ?? 1;

                if (alpha < 1) {
                    mat.pbrMetallicRoughness.setBaseColorFactor([1, 1, 1, 0.25]);
                    mat.pbrMetallicRoughness.setRoughnessFactor(0.1);
                    mat.pbrMetallicRoughness.setMetallicFactor(0);
                } else {
                    mat.pbrMetallicRoughness.setBaseColorFactor(frameColor);
                }
            });
        }
        
        // Change model color (from catalogue)
        async function changeModelColor(modelViewer, color) {
            await modelViewer.updateComplete;
            const materials = modelViewer.model?.materials || [];
            const rgba = colorMap[color.toLowerCase()] || [0, 0, 0, 1];

            materials.forEach(mat => {
                if (!mat.pbrMetallicRoughness) return;
                const alpha = mat.pbrMetallicRoughness.baseColorFactor?.[3] ?? 1;

                if (alpha >= 1) {
                    mat.pbrMetallicRoughness.setBaseColorFactor(rgba);
                }
            });

            // Generate AR image for this color if not already cached
            if (!colorGlassesImages[color]) {
                setTimeout(async () => {
                    colorGlassesImages[color] = await generateARImageFromModel();
                    glassesImageUrl = colorGlassesImages[color];
                    console.log('AR image generated for color:', color);

                    // Update AR view if active
                    if (isARActive && arAnchor) {
                        updateARGlasses(glassesImageUrl);
                    }
                }, 800);
            } else {
                glassesImageUrl = colorGlassesImages[color];
                // Update AR view if active
                if (isARActive && arAnchor) {
                    updateARGlasses(glassesImageUrl);
                }
            }
        }

        // Change GLB model
        function changeGlbModel(color) {
            const modelMain = document.getElementById('modelMain');
            const modelOption1 = document.getElementById('modelOption1');
            const modelOption2 = document.getElementById('modelOption2');

            const colorModels = JSON.parse(modelMain.getAttribute('data-color-models') || '{}');

            if (colorModels[color]) {
                modelMain.src = colorModels[color];
                modelOption1.src = colorModels[color];
                modelOption2.src = colorModels[color];

                // Generate AR image for new model after load
                if (!colorGlassesImages[color]) {
                    modelMain.addEventListener('load', async function generateForColor() {
                        await new Promise(r => setTimeout(r, 1000));
                        colorGlassesImages[color] = await generateARImageFromModel();
                        glassesImageUrl = colorGlassesImages[color];
                        console.log('AR image generated for model color:', color);

                        // Update AR view if active
                        if (isARActive && arAnchor) {
                            updateARGlasses(glassesImageUrl);
                        }

                        modelMain.removeEventListener('load', generateForColor);
                    });
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

            document.getElementById('loadingDiv').style.display = 'none';
            document.getElementById('productPage').style.display = 'flex';
        }

        function selectColor(element, color) {
            document.querySelectorAll('.circle').forEach(c => c.classList.remove('selected'));
            element.classList.add('selected');
            selectedColor = color;

            console.log('Color selected:', color);

            // Update stock display
            const stockForColor = colorStockMap[color] || 0;
            document.getElementById('productStock').textContent = `${stockForColor} in stock (${color})`;

            // Check if we need to change model file or just color
            const modelMain = document.getElementById('modelMain');
            const modelOption1 = document.getElementById('modelOption1');
            const modelOption2 = document.getElementById('modelOption2');

            if (!modelMain) return;

            const colorModelsAttr = modelMain.getAttribute('data-color-models');

            if (colorModelsAttr) {
                // Multiple GLB files - switch model
                changeGlbModel(color);
            } else {
                // Single model - change color
                changeModelColor(modelMain, color);
                if (modelOption1) changeModelColor(modelOption1, color);
                if (modelOption2) changeModelColor(modelOption2, color);
            }

            // Update dimensions display if active
            if (showingDimensions) {
                displayDimensions();
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

                if (view === 'static') {
                    mainDisplay.innerHTML = '<model-viewer id="modelMain" camera-orbit="0deg 75deg auto" disable-pan disable-zoom interaction-prompt="none"></model-viewer>';
                    actionBtn.style.display = 'none';
                    dimensionBtn.style.display = 'flex';
                    setTimeout(() => {
                        loadModels().then(() => {
                            // Reapply selected color
                            if (selectedColor) {
                                const modelMain = document.getElementById('modelMain');
                                const colorModelsAttr = modelMain ? modelMain.getAttribute('data-color-models') : null;
                                if (colorModelsAttr) {
                                    changeGlbModel(selectedColor);
                                } else if (modelMain) {
                                    changeModelColor(modelMain, selectedColor);
                                }
                            }
                            if (showingDimensions) {
                                setTimeout(() => displayDimensions(), 500);
                            }
                        });
                    }, 100);
                } else if (view === 'angle') {
                    mainDisplay.innerHTML = '<model-viewer id="modelMain" camera-orbit="-45deg 75deg auto" disable-pan disable-zoom interaction-prompt="none"></model-viewer>';
                    actionBtn.style.display = 'none';
                    dimensionBtn.style.display = 'flex';
                    setTimeout(() => {
                        loadModels().then(() => {
                            // Reapply selected color
                            if (selectedColor) {
                                const modelMain = document.getElementById('modelMain');
                                const colorModelsAttr = modelMain ? modelMain.getAttribute('data-color-models') : null;
                                if (colorModelsAttr) {
                                    changeGlbModel(selectedColor);
                                } else if (modelMain) {
                                    changeModelColor(modelMain, selectedColor);
                                }
                            }
                            if (showingDimensions) {
                                setTimeout(() => displayDimensions(), 500);
                            }
                        });
                    }, 100);
                } else if (view === 'interactive') {
                    // Interactive 360° view - allow rotation, pan, and zoom
                    mainDisplay.innerHTML = '<model-viewer id="modelMain" camera-orbit="0deg 75deg auto" camera-controls interaction-prompt="none"></model-viewer>';
                    actionBtn.style.display = 'flex';
                    actionBtn.innerHTML = '<i class="ri-refresh-line"></i>';
                    dimensionBtn.style.display = 'none';
                    showingDimensions = false;
                    clearDimensions();
                    setTimeout(() => {
                        loadModels().then(() => {
                            // Reapply selected color
                            if (selectedColor) {
                                const modelMain = document.getElementById('modelMain');
                                const colorModelsAttr = modelMain ? modelMain.getAttribute('data-color-models') : null;
                                if (colorModelsAttr) {
                                    changeGlbModel(selectedColor);
                                } else if (modelMain) {
                                    changeModelColor(modelMain, selectedColor);
                                }
                            }
                        });
                    }, 100);
                }

                currentView = view;
            });
        });

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
                display.requestFullscreen();
            }
        });

        // Generate PNG snapshot from model-viewer
        async function generateARImageFromModel() {
            console.log('=== Generating AR Image from Model ===');
            const modelMain = document.getElementById('modelMain');

            if (!modelMain) {
                console.error('Model viewer not found');
                return null;
            }

            try {
                await modelMain.updateComplete;
                await new Promise(r => setTimeout(r, 2000)); // Wait for full render

                console.log('Taking snapshot...');
                const blob = await modelMain.toBlob({
                    idealAspect: true,
                    mimeType: 'image/png'
                });

                if (!blob) {
                    console.error('Failed to create blob');
                    return null;
                }

                const url = URL.createObjectURL(blob);
                console.log('AR Image Generated:', url.substring(0, 50) + '...');
                return url;

            } catch (error) {
                console.error('Error generating AR image:', error);
                return null;
            }
        }

        // MindAR Camera functionality - IMAGE-BASED (WORKING METHOD FROM TRYON.ASPX)
        async function startMindAR() {
            // Prevent camera start if image upload is active
            if (isARActive) {
                console.log('AR already active from image upload');
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

                startBtn.style.display = 'none';
                uploadBtn.style.display = 'none';
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
                stopBtn.style.display = 'block';

                // Mirror video
                const videoEl = container.querySelector('video');
                if (videoEl) {
                    videoEl.style.zIndex = "1";
                    videoEl.style.transform = "scaleX(-1)";
                }
                renderer.domElement.style.transform = "scaleX(-1)";
                renderer.domElement.style.zIndex = "2";

                // Render loop
                renderer.setAnimationLoop(() => {
                    renderer.render(scene, camera);
                });

                console.log('✓✓AR Try-On Active! ✓✓✓');

            } catch (error) {
                console.error('MindAR error:', error);
                alert('Failed to start AR: ' + error.message);
                stopMindAR();
            }
        }

        function updateARGlasses(imageUrl) {
            if (!arAnchor || !mindarThree) return;

            console.log('Updating AR glasses with new color...');
            const textureLoader = new THREE.TextureLoader();
            textureLoader.load(imageUrl, (texture) => {
                const imageMesh = new THREE.Mesh(
                    new THREE.PlaneGeometry(1.2, 1.2),
                    new THREE.MeshBasicMaterial({
                        map: texture,
                        transparent: true,
                        alphaTest: 0.1  // Makes lenses completely transparent
                    })
                );
                imageMesh.scale.x = -1;
                imageMesh.position.set(0, 0.04, 0);
                arAnchor.group.clear();
                arAnchor.group.add(imageMesh);
                console.log('AR glasses updated');
            });
        }

        // Remove loadGLBModelToFace - WE DON'T NEED IT!
        // The image is generated from model-viewer instead

        function stopMindAR() {
            console.log('=== Stopping MindAR ===');

            if (mindarThree) {
                mindarThree.stop();
                mindarThree = null;
                arAnchor = null;
                console.log('MindAR stopped');
            }

            isARActive = false; // Reset flag

            const container = document.getElementById('ar-container');
            if (container) {
                container.innerHTML = `
            <div class="loading" style="position: absolute; z-index: 5; display: none;">
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
            }

            console.log('UI reset');
        }

        async function handleImageUploadMindAR(event) {
            const file = event.target.files[0];
            if (!file) return;

            console.log('=== Processing uploaded image ===');
            const container = document.getElementById('ar-container');
            const startBtn = document.getElementById('startCameraBtn');
            const uploadBtn = document.getElementById('uploadImageBtn');

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
                const glassesImg = new Image();
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

                // Calculate display size
                const containerWidth = container.clientWidth;
                const containerHeight = container.clientHeight;
                const imgAspect = userImg.width / userImg.height;
                const containerAspect = containerWidth / containerHeight;

                let displayWidth, displayHeight;
                if (imgAspect > containerAspect) {
                    displayWidth = containerWidth;
                    displayHeight = containerWidth / imgAspect;
                } else {
                    displayHeight = containerHeight;
                    displayWidth = containerHeight * imgAspect;
                }

                // Create canvas
                const canvas = document.createElement('canvas');
                canvas.width = displayWidth;
                canvas.height = displayHeight;
                canvas.style.display = 'block';
                canvas.style.cursor = 'crosshair';

                const ctx = canvas.getContext('2d');

                // Glasses state
                let glassesState = {
                    x: displayWidth / 2,
                    y: displayHeight / 2,
                    scale: 0.25,
                    rotation: 0,
                    isDragging: false,
                    dragStartX: 0,
                    dragStartY: 0
                };

                // Draw function
                function draw() {
                    // Clear and draw user image
                    ctx.clearRect(0, 0, displayWidth, displayHeight);
                    ctx.drawImage(userImg, 0, 0, displayWidth, displayHeight);

                    // Draw glasses
                    ctx.save();
                    ctx.translate(glassesState.x, glassesState.y);
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

                // Mouse/Touch events for dragging
                function getEventPos(e) {
                    const rect = canvas.getBoundingClientRect();
                    if (e.touches && e.touches.length > 0) {
                        return {
                            x: e.touches[0].clientX - rect.left,
                            y: e.touches[0].clientY - rect.top
                        };
                    }
                    return {
                        x: e.clientX - rect.left,
                        y: e.clientY - rect.top
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
                    draw();
                }

                function onPointerUp(e) {
                    e.preventDefault();
                    glassesState.isDragging = false;
                    canvas.style.cursor = 'crosshair';
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
                        canvas.toBlob((blob) => {
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
                    () => stopMindAR(),
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

        // Like functionality
        async function checkIfLiked() {
            const idToken = localStorage.getItem('idToken');
            if (!idToken) return;

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        checkLiked: true,
                        idToken: idToken,
                        productId: productData.productId || productData.id
                    })
                });

                const data = await response.json();
                if (data.success && data.isLiked) {
                    isLiked = true;
                    document.querySelector('#likeBtn i').className = 'ri-heart-fill';
                    document.getElementById('likeBtn').classList.add('liked');
                }
            } catch (error) {
                console.error('Error checking like status:', error);
            }
        }

        document.getElementById('likeBtn').addEventListener('click', async function () {
            const idToken = localStorage.getItem('idToken');
            if (!idToken) {
                alert('Please login to save items');
                return;
            }

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: isLiked ? 'unlike' : 'like',
                        idToken: idToken,
                        productId: productData.productId || productData.id
                    })
                });

                const data = await response.json();
                if (data.success) {
                    isLiked = !isLiked;
                    const icon = this.querySelector('i');
                    if (isLiked) {
                        icon.className = 'ri-heart-fill';
                        this.classList.add('liked');
                    } else {
                        icon.className = 'ri-heart-line';
                        this.classList.remove('liked');
                    }
                }
            } catch (error) {
                console.error('Error toggling like:', error);
            }
        });

        // Add to cart functionality
        document.getElementById('addToCartBtn').addEventListener('click', async function () {
            const idToken = localStorage.getItem('idToken');
            if (!idToken) {
                alert('Please login to add items to cart');
                return;
            }

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'addToCart',
                        idToken: idToken,
                        productId: productData.productId || productData.id,
                        quantity: 1
                    })
                });

                const data = await response.json();
                if (data.success) {
                    alert('Added to cart!');
                }
            } catch (error) {
                console.error('Error adding to cart:', error);
            }
        });

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
                    document.getElementById('tabContent').innerHTML =
                        `<p>${productData.description || 'No description available'}</p>`;
                } else {
                    document.getElementById('tabContent').innerHTML =
                        '<p>No reviews yet.</p>';
                }
            });
        });

        // Initialize
        document.addEventListener('DOMContentLoaded', fetchProduct);
    </script>
</asp:Content>