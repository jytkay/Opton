<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="catalogue.aspx.cs" Inherits="Opton.Pages.Customer.catalogue" MasterPageFile="~/Site.Master" Async="true" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <script type="module" src="https://unpkg.com/@google/model-viewer@latest/dist/model-viewer.min.js"></script>

    <style>
        /* Right container */
        .right-container {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        /* Toolbar container - sticky */
        .toolbar {
            position: sticky;
            top: 55px;
            width: 100%;
            height: 110px;
            background-color: rgba(162, 123, 92, 0.85);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 20px;
            z-index: 1000;
            box-sizing: border-box;
        }

            /* Common style for all toolbar elements */
            .toolbar input,
            .toolbar select,
            .toolbar button {
                height: 40px;
                background-color: white;
                color: #2C3639;
                border: none;
                border-radius: 30px;
                font-size: 16px;
                outline: none;
            }

        /* Search bar */
        .search-container {
            position: relative;
            width: 300px;
        }

            .search-container input {
                width: 100%;
                padding-left: 10px;
                padding-right: 40px;
                box-sizing: border-box;
            }

            .search-container i {
                position: absolute;
                right: 12px;
                top: 50%;
                transform: translateY(-50%);
                color: #2C3639;
                pointer-events: none;
            }

        /* Dropdown wrapper */
        .select-container {
            position: relative;
            display: inline-block;
            text-align: center;
            text-align-last: center;
        }

            .select-container select {
                appearance: none;
                -webkit-appearance: none;
                -moz-appearance: none;
                padding: 0 35px 0 15px;
                min-width: 120px;
                text-align: center;
            }

            .select-container::after {
                content: "\ea4e";
                font-family: "remixicon";
                font-weight: normal;
                position: absolute;
                right: 12px;
                top: 50%;
                transform: translateY(-50%);
                pointer-events: none;
                color: #2C3639;
            }

        /* Right controls */
        .right-controls {
            display: flex;
            align-items: center;
            gap: 10px;
        }

            .right-controls button {
                width: 40px;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
            }

        /* Product grid container */
        .catalogue-products {
            padding: 20px;
            background-color: #f5f5f5;
            flex: 1;
        }

        /* Table styling for 3-column layout */
        .product-table {
            width: 100%;
            border: none;
            border-collapse: separate;
            border-spacing: 20px;
            margin: 0 auto;
            max-width: 1200px;
        }

            .product-table tbody tr {
                display: table-row;
            }

            .product-table tbody td {
                width: 33.333%;
                vertical-align: top;
                padding: 0;
            }

            .product-table tfoot tr {
                display: table-row;
            }

            .product-table tfoot td {
                padding: 20px 0;
                text-align: center;
            }

            /* Style pager buttons */
            .product-table .pager a,
            .product-table .pager span {
                display: inline-block;
                padding: 8px 14px;
                background-color: #A27B5C;
                color: white;
                border-radius: 6px;
                margin: 0 4px;
                text-decoration: none;
                font-family: 'Teko', sans-serif;
            }

            .product-table .pager span {
                background-color: #2C3639;
                font-weight: bold;
            }

            .product-table .pager-cell {
                padding: 20px 0;
                text-align: center;
            }

        /* Individual product item */
        .product-item {
            background-color: white;
            text-align: center;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            height: 100%;
            display: flex;
            flex-direction: column;
        }

            .product-item:hover {
                transform: scale(1.02);
                box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            }

        /* Product image container */
        .product-image {
            width: 100%;
            height: 200px;
            background-color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

            .product-image > div {
                width: 100%;
                height: 100%;
            }

            .product-image model-viewer {
                width: 100%;
                height: 100%;
            }

            .product-image img {
                width: 80%;
                height: 80%;
                object-fit: contain;
            }

        /* Product info */
        .product-info {
            padding: 15px;
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        /* Price text with Teko font */
        .product-price {
            font-family: var(--font-price);
            color: #2C3639;
            font-size: 1.2rem;
            font-weight: 500;
            margin-bottom: 5px;
        }

        /* Product name */
        .product-name {
            background-color: #A27B5C;
            color: white;
            padding: 8px 0;
            margin: 0 -15px -15px -15px;
            font-size: 1rem;
            font-weight: 500;
        }

        /* Model container wrapper */
        .model-container {
            position: relative;
            width: 100%;
            height: 200px;
        }

        /* Product tag badge */
        .product-tag {
            position: absolute;
            top: 8px;
            left: 8px;
            background-color: var(--color-accent);
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.85rem;
            font-weight: 500;
            z-index: 10;
            transition: opacity 0.2s ease;
        }

            .product-tag.hidden {
                opacity: 0;
                pointer-events: none;
            }

        /* Hover action icons */
        .hover-actions {
            position: absolute;
            top: 8px;
            right: 8px;
            display: flex;
            gap: 8px;
            opacity: 0;
            transition: opacity 0.2s ease;
            z-index: 10;
            pointer-events: none;
        }

            .hover-actions.visible {
                opacity: 1;
                pointer-events: auto;
            }

        .action-icon {
            background-color: white;
            color: var(--color-accent);
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
            transition: transform 0.2s ease, background-color 0.2s ease;
        }

            .action-icon:hover {
                transform: scale(1.1);
                background-color: var(--color-accent);
                color: white;
            }

        /* Color swatches */
        .color-swatches {
            position: absolute;
            bottom: 8px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 6px;
            z-index: 10;
        }

        .color-swatch {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            border: 2px solid white;
            cursor: pointer;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
            transition: transform 0.2s ease, border-color 0.2s ease;
        }

            .color-swatch:hover {
                transform: scale(1.15);
                border-color: var(--color-background);
            }

            .color-swatch.active {
                border-color: var(--color-background);
                border-width: 3px;
            }

        /* Pagination container */
        .pager {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
            margin: 20px 0;
            flex-wrap: wrap;
        }

            /* Normal page links */
            .pager a {
                display: inline-block;
                padding: 10px 16px;
                background-color: #A27B5C;
                color: white;
                border-radius: 8px;
                text-decoration: none;
                font-weight: 500;
                transition: background-color 0.2s, transform 0.2s;
                min-width: 36px;
                text-align: center;
            }

                .pager a:hover {
                    background-color: #8f6646;
                    transform: translateY(-2px);
                }

            /* Current page */
            .pager span.current {
                display: inline-block;
                padding: 10px 16px;
                background-color: #2C3639;
                color: white;
                font-weight: bold;
                border-radius: 8px;
                min-width: 36px;
                text-align: center;
            }
            /* Dots */
            .pager .dots {
                display: inline-block;
                padding: 10px 6px;
                color: #555;
                font-weight: bold;
            }

            /* Previous / Next arrows style */
            .pager a.pager-nav {
                font-weight: bold;
            }

            /* Optional: hover effect for first/last pages and dots */
            .pager .dots:hover {
                cursor: default;
                color: #555;
            }

            .pager button {
                display: inline-block;
                padding: 10px 16px;
                background-color: #A27B5C;
                color: white;
                border: none;
                border-radius: 8px;
                font-weight: 500;
                transition: background-color 0.2s, transform 0.2s;
                min-width: 36px;
                text-align: center;
                cursor: pointer;
                font-family: 'Teko', sans-serif;
            }

                .pager button:hover:not(:disabled) {
                    background-color: #8f6646;
                    transform: translateY(-2px);
                }

                .pager button:disabled {
                    background-color: #ccc;
                    cursor: not-allowed;
                    transform: none;
                }

                .pager button.pager-nav {
                    font-weight: bold;
                }
    </style>
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
            console.log('[catalogue] Firebase ready, initializing page...');
            await window.initializeCataloguePage();
        });
    </script>
    <script>
        // CRITICAL: Prevent ASP.NET form postbacks for pagination links
        document.addEventListener('DOMContentLoaded', function () {
            // Disable form submission
            const form = document.querySelector('form');
            if (form) {
                form.addEventListener('submit', function (e) {
                    console.log('Form submission blocked');
                    e.preventDefault();
                    return false;
                });
            }

            // Also disable __doPostBack if it exists
            if (typeof __doPostBack !== 'undefined') {
                window.__doPostBack = function (eventTarget, eventArgument) {
                    console.log('PostBack blocked:', eventTarget, eventArgument);
                    return false;
                };
            }
        });

        document.addEventListener('click', function (e) {
            if (e.target.closest('.pager a')) {
                e.preventDefault();
                e.stopImmediatePropagation();
                return false; // fully blocks webform events
            }
        });

        // ==================== GLOBAL STATE ====================
        let allProducts = []; // Store all product elements
        let sortOrder = 'asc'; // Track sort order for toggle button
        let activeFilters = {
            category: [],
            age: [],
            shape: [],
            color: [],
            material: [],
            price: []
        };

        // ==================== STORAGE & AUTH ====================
        const STORAGE_KEYS = {
            guestSaved: 'guestSaved',
            guestCart: 'guestCart'
        };

        async function getCurrentUserId() {
            const user = await window.getCurrentUser();
            return user ? user.uid : null;
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

        // ==================== FILTER & SORT LOGIC ====================
        function applyFiltersAndSort() {
            console.log('=== APPLY FILTERS AND SORT ===');

            const searchInput = document.querySelector('.search-container input');
            const sortSelect = document.querySelector('.select-container select');

            const searchTerm = searchInput ? searchInput.value.toLowerCase().trim() : '';
            const sortValue = sortSelect ? sortSelect.value : 'Sort by';

            console.log('Search:', searchTerm);
            console.log('Sort:', sortValue, 'Order:', sortOrder);
            console.log('Active Filters:', activeFilters);

            // Refresh allProducts array from current DOM state
            if (!window.masterProductList || window.masterProductList.length === 0)
                window.masterProductList = Array.from(document.querySelectorAll('.product-item'));

            const allProducts = [...window.masterProductList];

            console.log('Total products available:', allProducts.length);

            // STEP 1: Filter products
            let visibleProducts = allProducts.filter((product, index) => {
                const productName = (product.getAttribute('data-product-name') || '').toLowerCase();
                const productId = (product.getAttribute('data-product-id') || '').toLowerCase();
                const productCategory = (product.getAttribute('data-product-category') || '').toLowerCase().trim();
                const productAge = (product.getAttribute('data-product-age') || '').toLowerCase().trim();
                const productShape = (product.getAttribute('data-product-shape') || '').toLowerCase().trim();
                const productColors = (product.getAttribute('data-product-colors') || '').toLowerCase().split(',').map(c => c.trim()).filter(c => c);
                const productMaterial = (product.getAttribute('data-product-material') || '').toLowerCase().trim();
                const productPrice = parseFloat(product.getAttribute('data-product-price')) || 0;

                // Search filter - if search term is empty/null, show all
                if (searchTerm.trim() !== '') {
                    let matches = false;

                    // Check name and ID
                    if (productName.includes(searchTerm) || productId.includes(searchTerm)) {
                        matches = true;
                    }

                    // Check price (support "RM100", "100", etc.)
                    const priceSearchMatch = searchTerm.match(/rm\s*(\d+)/i);
                    if (priceSearchMatch) {
                        const searchPrice = parseFloat(priceSearchMatch[1]);
                        // Allow ±10% tolerance for price searches
                        if (Math.abs(productPrice - searchPrice) <= searchPrice * 0.1) {
                            matches = true;
                        }
                    } else if (/^\d+$/.test(searchTerm)) {
                        // Pure number search
                        const searchPrice = parseFloat(searchTerm);
                        if (Math.abs(productPrice - searchPrice) <= searchPrice * 0.1) {
                            matches = true;
                        }
                    }

                    // Check colors
                    if (productColors.some(color => color.includes(searchTerm))) {
                        matches = true;
                    }

                    if (!matches) {
                        return false;
                    }
                }

                // Category filter (skip if "all" is active or no filters selected)
                if (activeFilters.category.length > 0 && !activeFilters.category.includes('all')) {
                    if (!activeFilters.category.includes(productCategory)) {
                        return false;
                    }
                }

                // Age filter (skip if "all" is active, no filters selected, OR product has no age data)
                if (activeFilters.age.length > 0 && !activeFilters.age.includes('all')) {
                    // If product has no age data, allow it through (e.g., accessories)
                    if (productAge === '') {
                        // Product has no age requirement - include it
                    } else {
                        // Product has age data - check if it matches any selected filter
                        if (!activeFilters.age.some(age => productAge.includes(age.toLowerCase()))) {
                            return false;
                        }
                    }
                }

                // Shape filter (skip if "all" is active, no filters selected, OR product has no shape data)
                if (activeFilters.shape.length > 0 && !activeFilters.shape.includes('all')) {
                    // If product has no shape data, allow it through (e.g., accessories)
                    if (productShape === '') {
                        // Product has no shape requirement - include it
                    } else {
                        // Product has shape data - check if it matches filter
                        if (!activeFilters.shape.includes(productShape)) {
                            return false;
                        }
                    }
                }

                // Color filter (skip if "all" is active or no filters selected)
                if (activeFilters.color.length > 0 && !activeFilters.color.includes('all')) {
                    // Colors are more universal - even accessories might have colors
                    if (productColors.length === 0) {
                        // No color data - could still show if we want accessories visible
                        // For now, include products without color data
                    } else {
                        if (!activeFilters.color.some(color => productColors.includes(color.toLowerCase()))) {
                            return false;
                        }
                    }
                }

                // Material filter (skip if "all" is active, no filters selected, OR product has no material data)
                if (activeFilters.material.length > 0 && !activeFilters.material.includes('all')) {
                    // If product has no material data, allow it through
                    if (productMaterial === '') {
                        // Product has no material requirement - include it
                    } else {
                        // Product has material data - check if it matches filter
                        if (!activeFilters.material.some(mat => productMaterial.includes(mat.toLowerCase()))) {
                            return false;
                        }
                    }
                }

                // Price filter (skip if "all" is active or no filters selected)
                if (activeFilters.price.length > 0 && !activeFilters.price.includes('all')) {
                    let priceMatch = false;
                    activeFilters.price.forEach(range => {
                        if (range === 'under100' && productPrice < 100) priceMatch = true;
                        if (range === '100-300' && productPrice >= 100 && productPrice <= 300) priceMatch = true;
                        if (range === '300-500' && productPrice > 300 && productPrice <= 500) priceMatch = true;
                        if (range === '500-1000' && productPrice > 500 && productPrice <= 1000) priceMatch = true;
                        if (range === 'above1000' && productPrice > 1000) priceMatch = true;
                    });
                    if (!priceMatch) return false;
                }

                return true;
            });

            console.log(`✓ Filtered: ${visibleProducts.length}/${allProducts.length} products`);

            // STEP 2: Sort products
            if (sortValue !== 'Sort by' && visibleProducts.length > 0) {
                console.log(`Sorting by ${sortValue} (${sortOrder})...`);

                visibleProducts.sort((a, b) => {
                    const priceA = parseFloat(a.getAttribute('data-product-price')) || 0;
                    const priceB = parseFloat(b.getAttribute('data-product-price')) || 0;
                    const nameA = (a.getAttribute('data-product-name') || '').toLowerCase();
                    const nameB = (b.getAttribute('data-product-name') || '').toLowerCase();
                    const dateA = a.getAttribute('data-product-date') || '';
                    const dateB = b.getAttribute('data-product-date') || '';

                    let comparison = 0;

                    switch (sortValue) {
                        case 'Name':
                            comparison = nameA.localeCompare(nameB);
                            break;
                        case 'Price':
                            comparison = priceA - priceB;
                            break;
                        case 'Latest':
                            const timeA = new Date(dateA).getTime();
                            const timeB = new Date(dateB).getTime();
                            comparison = timeB - timeA;
                            break;
                        case 'Popularity':
                            const countA = productOrderCounts[a.getAttribute('data-product-id')] || 0;
                            const countB = productOrderCounts[b.getAttribute('data-product-id')] || 0;
                            comparison = countB - countA; // Higher count = more popular
                            break;
                        default:
                            return 0;
                    }

                    return sortOrder === 'asc' ? comparison : -comparison;
                });

                console.log(`✓ Sorted ${visibleProducts.length} products`);
            }

            // STEP 3: Reset to first page and render
            currentClientPage = 0;
            renderProducts(visibleProducts);
        }

        let currentClientPage = 0;
        const clientPageSize = 12;

        function renderProducts(products) {
            console.log("=== RENDERING PRODUCTS ===");
            console.log("Products to render:", products.length);

            const productTableBody = document.querySelector('[id$="productTableBody"]');

            if (!productTableBody) {
                console.error('Could not find product table body');
                return;
            }

            // Clear existing content
            productTableBody.innerHTML = '';

            if (products.length === 0) {
                const row = document.createElement('tr');
                const cell = document.createElement('td');
                cell.colSpan = 3;
                cell.style.textAlign = 'center';
                cell.style.padding = '40px';
                cell.innerHTML = '<h3 style="color: #999;">No products found</h3>';
                row.appendChild(cell);
                productTableBody.appendChild(row);
                renderClientPagination(0, products);
                return;
            }

            // Calculate pagination
            const totalPages = Math.ceil(products.length / clientPageSize);
            const startIdx = currentClientPage * clientPageSize;
            const endIdx = Math.min(startIdx + clientPageSize, products.length);
            const pageProducts = products.slice(startIdx, endIdx);

            console.log(`Rendering page ${currentClientPage + 1}/${totalPages} (items ${startIdx}-${endIdx} of ${products.length})`);

            // Create table rows with 3 columns each
            for (let i = 0; i < pageProducts.length; i += 3) {
                const row = document.createElement('tr');

                for (let j = i; j < Math.min(i + 3, pageProducts.length); j++) {
                    const cell = document.createElement('td');

                    // Clone the product element
                    const productClone = pageProducts[j].cloneNode(true);

                    // Make it visible
                    productClone.style.display = '';

                    // Re-attach event listeners
                    attachProductListeners(productClone);

                    cell.appendChild(productClone);
                    row.appendChild(cell);
                }

                // Fill remaining cells if last row is incomplete
                while (row.children.length < 3) {
                    const emptyCell = document.createElement('td');
                    emptyCell.style.visibility = 'hidden';
                    row.appendChild(emptyCell);
                }

                productTableBody.appendChild(row);
            }

            // Render pagination
            renderClientPagination(totalPages, products);

            console.log(`✓ Rendered ${pageProducts.length} products on page ${currentClientPage + 1}`);
        }

        function attachProductListeners(productElement) {
            const productId = productElement.getAttribute('data-product-id');

            // Re-add hover effects for model viewer AND images
            productElement.addEventListener('mouseenter', function () {
                // Handle model viewer rotation - find it within THIS product element
                const mv = this.querySelector('model-viewer');
                if (mv) {
                    mv.cameraOrbit = '-45deg 75deg auto';
                }

                // Handle tag and actions visibility
                const tag = this.querySelector('.product-tag');
                if (tag) tag.classList.add('hidden');

                const actions = this.querySelector('.hover-actions');
                if (actions) actions.classList.add('visible');
            });

            productElement.addEventListener('mouseleave', function () {
                // Reset model viewer rotation
                const mv = this.querySelector('model-viewer');
                if (mv) {
                    mv.cameraOrbit = '0deg 75deg auto';
                }

                // Reset tag and actions visibility
                const tag = this.querySelector('.product-tag');
                if (tag) tag.classList.remove('hidden');

                const actions = this.querySelector('.hover-actions');
                if (actions) actions.classList.remove('visible');
            });

            // Add proper click handler for product navigation
            productElement.addEventListener('click', function (e) {
                // Don't navigate if clicking on interactive elements
                if (e.target.closest('.color-swatch, .action-icon, .color-swatches, .hover-actions')) {
                    return;
                }
                window.location.href = `product.aspx?id=${productId}`;
            });

            // Re-attach like button
            const heartIcon = productElement.querySelector('.ri-heart-line, .ri-heart-fill');
            if (heartIcon) {
                heartIcon.onclick = (e) => {
                    e.stopPropagation();
                    likeProduct(e, productId);
                };
            }

            // Re-attach cart button
            const cartIcon = productElement.querySelector('.cart-icon');
            if (cartIcon) {
                cartIcon.onclick = (e) => {
                    e.stopPropagation();
                    addToCart(e, productId);
                };
            }

            // Re-add hover effects for model viewer AND images
            const modelViewerId = `model-${productId}`;
            const modelViewer = document.getElementById(modelViewerId);
            const imageId = `img-${productId}`;

            productElement.addEventListener('mouseenter', function () {
                // Handle model viewer rotation
                const mv = document.getElementById(modelViewerId);
                if (mv) {
                    mv.cameraOrbit = '-45deg 75deg auto';
                }

                // Handle tag and actions visibility
                const tag = this.querySelector('.product-tag');
                if (tag) tag.classList.add('hidden');

                const actions = this.querySelector('.hover-actions');
                if (actions) actions.classList.add('visible');
            });

            productElement.addEventListener('mouseleave', function () {
                // Reset model viewer rotation
                const mv = document.getElementById(modelViewerId);
                if (mv) {
                    mv.cameraOrbit = '0deg 75deg auto';
                }

                // Reset tag and actions visibility
                const tag = this.querySelector('.product-tag');
                if (tag) tag.classList.remove('hidden');

                const actions = this.querySelector('.hover-actions');
                if (actions) actions.classList.remove('visible');
            });
        }

        function renderClientPagination(totalPages, allFilteredProducts) {
            const pagerContainer = document.getElementById('pagerContainer');

            if (!pagerContainer) {
                console.error('Pager container not found');
                return;
            }

            if (totalPages <= 1) {
                pagerContainer.innerHTML = '';
                return;
            }

            // Clear existing content
            pagerContainer.innerHTML = '';

            const pagerDiv = document.createElement('div');
            pagerDiv.className = 'pager';

            // Previous button
            const prevBtn = document.createElement('button');
            prevBtn.type = 'button';
            prevBtn.className = currentClientPage > 0 ? 'pager-nav' : 'pager-nav';
            prevBtn.textContent = '«';
            prevBtn.disabled = currentClientPage === 0;
            if (currentClientPage > 0) {
                prevBtn.onclick = () => goToClientPage(currentClientPage - 1);
            }
            pagerDiv.appendChild(prevBtn);
            pagerDiv.appendChild(document.createTextNode(' '));

            // Smart page number rendering (show max 7 page numbers)
            const maxPages = 7;
            let startPage = Math.max(0, currentClientPage - Math.floor(maxPages / 2));
            let endPage = Math.min(totalPages - 1, startPage + maxPages - 1);

            if (endPage - startPage < maxPages - 1) {
                startPage = Math.max(0, endPage - maxPages + 1);
            }

            // Show first page + ellipsis if needed
            if (startPage > 0) {
                const firstBtn = document.createElement('button');
                firstBtn.type = 'button';
                firstBtn.textContent = '1';
                firstBtn.onclick = () => goToClientPage(0);
                pagerDiv.appendChild(firstBtn);
                pagerDiv.appendChild(document.createTextNode(' '));

                if (startPage > 1) {
                    const dots = document.createElement('span');
                    dots.className = 'dots';
                    dots.textContent = '...';
                    pagerDiv.appendChild(dots);
                    pagerDiv.appendChild(document.createTextNode(' '));
                }
            }

            // Page numbers
            for (let i = startPage; i <= endPage; i++) {
                if (i === currentClientPage) {
                    const currentSpan = document.createElement('span');
                    currentSpan.className = 'current';
                    currentSpan.textContent = (i + 1).toString();
                    pagerDiv.appendChild(currentSpan);
                } else {
                    const pageBtn = document.createElement('button');
                    pageBtn.type = 'button';
                    pageBtn.textContent = (i + 1).toString();
                    const pageNum = i;
                    pageBtn.onclick = () => goToClientPage(pageNum);
                    pagerDiv.appendChild(pageBtn);
                }
                pagerDiv.appendChild(document.createTextNode(' '));
            }

            // Show ellipsis + last page if needed
            if (endPage < totalPages - 1) {
                if (endPage < totalPages - 2) {
                    const dots = document.createElement('span');
                    dots.className = 'dots';
                    dots.textContent = '...';
                    pagerDiv.appendChild(dots);
                    pagerDiv.appendChild(document.createTextNode(' '));
                }

                const lastBtn = document.createElement('button');
                lastBtn.type = 'button';
                lastBtn.textContent = totalPages.toString();
                lastBtn.onclick = () => goToClientPage(totalPages - 1);
                pagerDiv.appendChild(lastBtn);
                pagerDiv.appendChild(document.createTextNode(' '));
            }

            // Next button
            const nextBtn = document.createElement('button');
            nextBtn.type = 'button';
            nextBtn.className = 'pager-nav';
            nextBtn.textContent = '»';
            nextBtn.disabled = currentClientPage === totalPages - 1;
            if (currentClientPage < totalPages - 1) {
                nextBtn.onclick = () => goToClientPage(currentClientPage + 1);
            }
            pagerDiv.appendChild(nextBtn);

            pagerContainer.appendChild(pagerDiv);
        }

        window.goToClientPage = function (pageNum) {
            console.log(`Going to page ${pageNum + 1}`);
            currentClientPage = pageNum;

            // Get current filtered products
            const searchInput = document.querySelector('.search-container input');
            const sortSelect = document.querySelector('.select-container select');
            const searchTerm = searchInput ? searchInput.value.toLowerCase().trim() : '';
            const sortValue = sortSelect ? sortSelect.value : 'Sort by';

            // Re-filter products
            let visibleProducts = [...window.masterProductList].filter(product => {
                // Apply all the same filters from applyFiltersAndSort
                const productName = (product.getAttribute('data-product-name') || '').toLowerCase();
                const productId = (product.getAttribute('data-product-id') || '').toLowerCase();
                const productCategory = (product.getAttribute('data-product-category') || '').toLowerCase().trim();
                const productAge = (product.getAttribute('data-product-age') || '').toLowerCase().trim();
                const productShape = (product.getAttribute('data-product-shape') || '').toLowerCase().trim();
                const productColors = (product.getAttribute('data-product-colors') || '').toLowerCase().split(',').map(c => c.trim()).filter(c => c);
                const productMaterial = (product.getAttribute('data-product-material') || '').toLowerCase().trim();
                const productPrice = parseFloat(product.getAttribute('data-product-price')) || 0;

                // Search filter
                if (searchTerm.trim() !== '') {
                    if (!productName.includes(searchTerm) && !productId.includes(searchTerm)) {
                        return false;
                    }
                }

                // Apply all active filters (same logic as applyFiltersAndSort)
                if (activeFilters.category.length > 0 && !activeFilters.category.includes('all')) {
                    if (!activeFilters.category.includes(productCategory)) return false;
                }
                if (activeFilters.age.length > 0 && !activeFilters.age.includes('all')) {
                    if (productAge !== '' && !activeFilters.age.some(age => productAge.includes(age.toLowerCase()))) {
                        return false;
                    }
                }
                if (activeFilters.shape.length > 0 && !activeFilters.shape.includes('all')) {
                    if (productShape !== '' && !activeFilters.shape.includes(productShape)) {
                        return false;
                    }
                }
                if (activeFilters.color.length > 0 && !activeFilters.color.includes('all')) {
                    if (productColors.length > 0 && !activeFilters.color.some(color => productColors.includes(color.toLowerCase()))) {
                        return false;
                    }
                }
                if (activeFilters.material.length > 0 && !activeFilters.material.includes('all')) {
                    if (productMaterial !== '' && !activeFilters.material.some(mat => productMaterial.includes(mat.toLowerCase()))) {
                        return false;
                    }
                }
                if (activeFilters.price.length > 0 && !activeFilters.price.includes('all')) {
                    let priceMatch = false;
                    activeFilters.price.forEach(range => {
                        if (range === 'under100' && productPrice < 100) priceMatch = true;
                        if (range === '100-300' && productPrice >= 100 && productPrice <= 300) priceMatch = true;
                        if (range === '300-500' && productPrice > 300 && productPrice <= 500) priceMatch = true;
                        if (range === '500-1000' && productPrice > 500 && productPrice <= 1000) priceMatch = true;
                        if (range === 'above1000' && productPrice > 1000) priceMatch = true;
                    });
                    if (!priceMatch) return false;
                }

                return true;
            });

            // Re-apply sort
            if (sortValue !== 'Sort by' && visibleProducts.length > 0) {
                visibleProducts.sort((a, b) => {
                    const priceA = parseFloat(a.getAttribute('data-product-price')) || 0;
                    const priceB = parseFloat(b.getAttribute('data-product-price')) || 0;
                    const nameA = (a.getAttribute('data-product-name') || '').toLowerCase();
                    const nameB = (b.getAttribute('data-product-name') || '').toLowerCase();
                    const dateA = a.getAttribute('data-product-date') || '';
                    const dateB = b.getAttribute('data-product-date') || '';

                    let comparison = 0;
                    switch (sortValue) {
                        case 'Name':
                            comparison = nameA.localeCompare(nameB);
                            break;
                        case 'Price':
                            comparison = priceA - priceB;
                            break;
                        case 'Latest':
                            const timeA = new Date(dateA).getTime();
                            const timeB = new Date(dateB).getTime();
                            comparison = timeB - timeA;
                            break;
                        default:
                            return 0;
                    }
                    return sortOrder === 'asc' ? comparison : -comparison;
                });
            }

            // Render the specific page
            renderProducts(visibleProducts);

            // Scroll to top
            const toolbar = document.querySelector('.toolbar');
            if (toolbar) {
                toolbar.scrollIntoView({ behavior: 'smooth', block: 'start' });
            } else {
                window.scrollTo({ top: 0, behavior: 'smooth' });
            }
        };

        // ==================== FILTER CHECKBOX HANDLERS ====================

        function setupFilterListeners() {
            // Use event delegation on the filter panel instead of individual checkboxes
            const filterPanel = document.getElementById('filter-panel');

            if (filterPanel) {
                // Remove any existing listener to avoid duplicates
                filterPanel.removeEventListener('change', handleFilterChange);

                // Add single delegated event listener
                filterPanel.addEventListener('change', handleFilterChange);

                console.log('[setupFilterListeners] Event delegation attached to filter panel');
            } else {
                console.error('[setupFilterListeners] Filter panel not found!');
            }
        }

        function handleFilterChange(event) {
            const checkbox = event.target;

            // Only handle checkboxes with filter-checkbox class
            if (!checkbox.classList.contains('filter-checkbox')) {
                return;
            }

            const filterType = checkbox.getAttribute('data-filter-type');
            const filterValue = checkbox.getAttribute('data-filter-value');

            console.log('[handleFilterChange]', {
                type: filterType,
                value: filterValue,
                checked: checkbox.checked
            });

            // Handle "All" checkbox
            if (filterValue === 'all') {
                if (checkbox.checked) {
                    // Check "All" - uncheck and disable all other checkboxes in this filter
                    activeFilters[filterType] = ['all'];

                    const filterContainer = checkbox.closest('div').parentElement;
                    const otherCheckboxes = filterContainer.querySelectorAll(`.filter-checkbox:not([data-filter-value="all"])`);

                    otherCheckboxes.forEach(cb => {
                        cb.checked = false;
                        cb.disabled = true;
                    });
                } else {
                    // Uncheck "All" - enable all other checkboxes
                    activeFilters[filterType] = [];

                    const filterContainer = checkbox.closest('div').parentElement;
                    const otherCheckboxes = filterContainer.querySelectorAll(`.filter-checkbox:not([data-filter-value="all"])`);

                    otherCheckboxes.forEach(cb => {
                        cb.disabled = false;
                    });
                }
            } else {
                // Regular checkbox
                if (checkbox.checked) {
                    if (!activeFilters[filterType].includes(filterValue)) {
                        activeFilters[filterType].push(filterValue);
                    }
                } else {
                    activeFilters[filterType] = activeFilters[filterType].filter(v => v !== filterValue);
                }
            }

            console.log('[handleFilterChange] Active filters:', activeFilters);
            applyFiltersAndSort();
        }

        function debugFilters() {
            console.log('=== FILTER DEBUG ===');
            console.log('All checkboxes:', document.querySelectorAll('.filter-checkbox').length);
            console.log('Category filters:', document.querySelectorAll('#categoryFilters .filter-checkbox').length);
            console.log('Shape filters:', document.querySelectorAll('#shapeFilters .filter-checkbox').length);
            console.log('Color filters:', document.querySelectorAll('#colorFilters .filter-checkbox').length);
            console.log('Material filters:', document.querySelectorAll('#materialFilters .filter-checkbox').length);
            console.log('Size filters:', document.querySelectorAll('#sizeFilters .filter-checkbox').length);
            console.log('Active filters:', activeFilters);
        }

        // ==================== SORT HANDLERS ====================

        function setupSortListeners() {
            const sortSelect = document.querySelector('.select-container select');
            const sortButton = document.querySelector('.right-controls button');

            if (sortSelect) {
                sortSelect.addEventListener('change', function () {
                    console.log('Sort changed:', this.value);
                    applyFiltersAndSort();
                });
            }

            if (sortButton) {
                sortButton.addEventListener('click', function () {
                    sortOrder = sortOrder === 'asc' ? 'desc' : 'asc';

                    // Update button icon
                    const icon = this.querySelector('i');
                    if (icon) {
                        icon.className = sortOrder === 'asc' ? 'ri-sort-asc' : 'ri-sort-desc';
                    }

                    console.log('Sort order toggled:', sortOrder);
                    applyFiltersAndSort();
                });
            }
        }

        // ==================== SEARCH HANDLER ====================

        function setupSearchListener() {
            const searchInput = document.querySelector('.search-container input');

            if (searchInput) {
                // Remove debounce for more responsive search
                searchInput.addEventListener('input', () => {
                    applyFiltersAndSort();
                });

                // Also trigger on Enter key
                searchInput.addEventListener('keypress', function (e) {
                    if (e.key === 'Enter') {
                        applyFiltersAndSort();
                    }
                });

                console.log('[setupSearchListener] Search listener attached');
            }
        }

        function debounce(func, wait) {
            let timeout;
            return function executedFunction(...args) {
                clearTimeout(timeout);
                timeout = setTimeout(() => func(...args), wait);
            };
        }

        // ==================== LIKE/UNLIKE PRODUCT ====================

        async function likeProduct(event, productId) {
            event.stopPropagation();

            const isAuth = await isAuthenticated();
            const icon = event.target;
            const isLiked = icon.classList.contains('ri-heart-fill');
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
                        toggleHeartIcon(icon, isLiked);
                        showNotification(result.message);
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
                toggleHeartIcon(icon, isLiked);
                showNotification(isLiked ? 'Removed from favorites' : 'Added to favorites');
            }
        }

        // ==================== ADD TO CART ====================

        async function addToCart(event, productId) {
            event.stopPropagation();

            const isAuth = await isAuthenticated();

            // Get the product element to extract available colors
            const productElement = document.querySelector(`[data-product-id="${productId}"]`);
            const productColors = productElement ?
                (productElement.getAttribute('data-product-colors') || '').split(',').map(c => c.trim()).filter(c => c) :
                [];

            // For catalogue, use first available color or show selection modal
            let selectedColor = productColors.length > 0 ? productColors[0] : 'Default';
            let selectedSize = 'Default'; // Glasses typically don't have sizes in catalogue view

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

        // ==================== UPDATE CART UI ====================

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

            // Update cart icons
            document.querySelectorAll('[data-product-id]').forEach(element => {
                const productId = element.getAttribute('data-product-id');
                const cartIcon = element.querySelector('.cart-icon');
                const cartBadge = element.querySelector('.cart-badge');

                if (cartIcon && cartBadge) {
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
            });

            // Update global cart count
            const totalCount = Object.values(cartData).reduce((sum, qty) => sum + qty, 0);
            const globalCartBadge = document.querySelector('.cart-count');
            if (globalCartBadge) {
                globalCartBadge.textContent = totalCount;
                globalCartBadge.style.display = totalCount > 0 ? 'inline-block' : 'none';
            }
        }

        // ==================== UPDATE LIKED UI ====================

        async function updateLikedUI() {
            const isAuth = await isAuthenticated();
            const productElements = document.querySelectorAll('[data-product-id]');

            if (isAuth) {
                const idToken = await window.getIdToken();

                for (const element of productElements) {
                    const productId = element.getAttribute('data-product-id');

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
                        const heartIcon = element.querySelector('.ri-heart-line, .ri-heart-fill');

                        if (heartIcon) {
                            if (result.success && result.isLiked) {
                                heartIcon.classList.remove('ri-heart-line');
                                heartIcon.classList.add('ri-heart-fill');
                            } else {
                                heartIcon.classList.remove('ri-heart-fill');
                                heartIcon.classList.add('ri-heart-line');
                            }
                        }
                    } catch (error) {
                        console.error('Error checking liked status:', error);
                    }
                }
            } else {
                const savedItems = getGuestSaved();

                productElements.forEach(element => {
                    const productId = element.getAttribute('data-product-id');
                    const heartIcon = element.querySelector('.ri-heart-line, .ri-heart-fill');

                    if (heartIcon) {
                        if (savedItems.includes(productId)) {
                            heartIcon.classList.remove('ri-heart-line');
                            heartIcon.classList.add('ri-heart-fill');
                        } else {
                            heartIcon.classList.remove('ri-heart-fill');
                            heartIcon.classList.add('ri-heart-line');
                        }
                    }
                });
            }
        }

        // ==================== REFRESH UI ====================

        async function refreshProductUI() {
            console.log('=== REFRESHING PRODUCT UI ===');
            await updateLikedUI();
            await updateCartUI();
        }

        // ==================== UTILITY FUNCTIONS ====================

        function toggleHeartIcon(icon, isCurrentlyLiked) {
            if (isCurrentlyLiked) {
                icon.classList.remove('ri-heart-fill');
                icon.classList.add('ri-heart-line');
            } else {
                icon.classList.remove('ri-heart-line');
                icon.classList.add('ri-heart-fill');
            }
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

        // ==================== COLOR CHANGE FUNCTIONS ====================

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

        async function initializeModel(modelViewer, firstColor) {
            await modelViewer.updateComplete;
            const materials = modelViewer.model?.materials || [];

            const frameColor = firstColor && colorMap[firstColor.toLowerCase()]
                ? colorMap[firstColor.toLowerCase()]
                : [0, 0, 0, 1];

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

        async function changeModelColor(swatchElement, event) {
            event.stopPropagation();

            const container = swatchElement.closest('.model-container');
            const modelViewer = container.querySelector('model-viewer');
            const color = swatchElement.getAttribute('data-color');

            container.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('active'));
            swatchElement.classList.add('active');

            if (modelViewer) {
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
            }
        }

        async function changeImageColor(swatchElement, event) {
            event.stopPropagation();

            const container = swatchElement.closest('.model-container');
            const img = container.querySelector('img');
            const color = swatchElement.getAttribute('data-color');

            container.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('active'));
            swatchElement.classList.add('active');

            const colorImagesJson = container.getAttribute('data-color-images');

            if (colorImagesJson && img) {
                try {
                    const colorImages = JSON.parse(colorImagesJson);

                    if (colorImages[color]) {
                        img.style.opacity = '0.5';
                        setTimeout(() => {
                            img.src = colorImages[color];
                            img.style.opacity = '1';
                        }, 150);
                    }
                } catch (error) {
                    console.error('Error parsing color images:', error);
                }
            }
        }

        async function changeGlbModel(swatchElement, event) {
            event.stopPropagation();

            const container = swatchElement.closest('.model-container');
            const modelViewer = container.querySelector('model-viewer');
            const color = swatchElement.getAttribute('data-color');

            container.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('active'));
            swatchElement.classList.add('active');

            const colorModelsJson = container.getAttribute('data-color-models');

            if (colorModelsJson && modelViewer) {
                try {
                    const colorModels = JSON.parse(colorModelsJson);

                    if (colorModels[color]) {
                        modelViewer.src = colorModels[color];
                    }
                } catch (error) {
                    console.error('Error parsing color models:', error);
                }
            }
        }

        let productOrderCounts = {};

        async function loadProductPopularity() {
            try {
                const res = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: "getOrdersList" })
                });
                const data = await res.json();

                if (data.success && data.orders?.length) {
                    productOrderCounts = {};

                    // Count orders per product
                    data.orders.forEach(order => {
                        if (order.items && typeof order.items === 'object') {
                            for (const productId in order.items) {
                                productOrderCounts[productId] = (productOrderCounts[productId] || 0) + 1;
                            }
                        }
                    });

                    console.log('Product popularity loaded:', productOrderCounts);
                }
            } catch (err) {
                console.error('Error loading product popularity:', err);
            }
        }

        // ==================== INITIALIZATION ====================
        window.initializeCataloguePage = async function () {
            console.log('=== INITIALIZING CATALOGUE PAGE ===');

            await loadProductPopularity();

            // Get all product items from the server-rendered HTML
            const allProductElements = document.querySelectorAll('.product-item');

            // CRITICAL: Attach event listeners to original products BEFORE storing them
            allProductElements.forEach(product => {
                attachProductListeners(product);
            });

            window.masterProductList = Array.from(allProductElements);

            console.log(`Loaded ${window.masterProductList.length} products into master list`);

            // Initialize "All" checkboxes
            initializeAllCheckboxes();

            // Setup event listeners
            setupFilterListeners();
            setupSortListeners();
            setupSearchListener();

            // Initial render with all products
            applyFiltersAndSort();

            // Refresh UI for cart/likes
            await refreshProductUI();

            console.log('=== CATALOGUE INITIALIZATION COMPLETE ===');
        };

        function initializeAllCheckboxes() {
            const filterTypes = ['category', 'age', 'shape', 'color', 'material', 'price'];

            filterTypes.forEach(type => {
                const allCheckbox = document.querySelector(`[data-filter-type="${type}"][data-filter-value="all"]`);

                if (allCheckbox) {
                    // Check the "All" checkbox
                    allCheckbox.checked = true;
                    activeFilters[type] = ['all'];

                    // Disable other checkboxes in this category
                    const filterContainer = allCheckbox.closest('div').parentElement;
                    const otherCheckboxes = filterContainer.querySelectorAll(`.filter-checkbox:not([data-filter-value="all"])`);

                    otherCheckboxes.forEach(cb => {
                        cb.disabled = true;
                    });
                }
            });
        }

        // Auth state change listener
        window.addEventListener('auth-state-changed', async (e) => {
            console.log('[catalogue] Auth state changed');
            await new Promise(resolve => setTimeout(resolve, 500));
            await refreshProductUI();
        });

        window.masterProductList = Array.from(document.querySelectorAll('.product-item'));

        // Expose functions globally
        window.likeProduct = likeProduct;
        window.addToCart = addToCart;
        window.refreshProductUI = refreshProductUI;
        window.initializeModel = initializeModel;
        window.changeModelColor = changeModelColor;
        window.changeImageColor = changeImageColor;
        window.changeGlbModel = changeGlbModel;
    </script>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div id="banner" style="width: 100%; background-color: var(--color-gray); overflow: hidden">
        <img src="<%= ResolveUrl("~/Assets/banner.png") %>" alt="Banner" style="width: 100%; height: auto; display: block" />
    </div>

    <div style="width: 100%; display: flex">
        <div id="filter-panel" style="width: 233px; height: calc(100vh - 55px); position: sticky; top: 55px; overflow-y: auto; background-color: var(--color-accent); color: white; padding: 20px; scrollbar-color: white var(--color-accent);">
            <h2 style="font-weight: bold; margin-bottom: 10px; text-align: center; letter-spacing: 1px">FILTERS</h2>
            <hr />

            <!-- Category Filter (Dynamic) -->
            <details style="margin-top: 10px" open>
                <summary style="font-weight: 600; cursor: pointer">Category</summary>
                <div id="categoryFilters" runat="server" style="margin-top: 5px; padding-left: 10px; font-size: 0.9em">
                    <!-- Will be populated dynamically via C# -->
                </div>
            </details>
            <hr />

            <!-- Age Filter (Hardcoded) -->
            <details style="margin-top: 10px">
                <summary style="font-weight: 600; cursor: pointer">Age</summary>
                <div style="margin-top: 5px; padding-left: 10px; font-size: 0.9em">
                    <label style="display: block; margin-bottom: 5px; cursor: pointer; font-weight: 600;">
                        <input type="checkbox" class="filter-checkbox" data-filter-type="age" data-filter-value="all" checked />
                        All
       
                    </label>
                    <hr style='margin: 5px 0;' />
                    <label style="display: block; margin-bottom: 5px; cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox" data-filter-type="age" data-filter-value="kids" disabled />
                        Kids
       
                    </label>
                    <label style="display: block; margin-bottom: 5px; cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox" data-filter-type="age" data-filter-value="adults" disabled />
                        Adults
       
                    </label>
                </div>
            </details>
            <hr />

            <!-- Shape Filter (Dynamic) -->
            <details style="margin-top: 10px">
                <summary style="font-weight: 600; cursor: pointer">Shape</summary>
                <div id="shapeFilters" runat="server" style="margin-top: 5px; padding-left: 10px; font-size: 0.9em">
                    <!-- Will be populated dynamically via C# -->
                </div>
            </details>
            <hr />

            <!-- Color Filter (Dynamic) -->
            <details style="margin-top: 10px">
                <summary style="font-weight: 600; cursor: pointer">Colour</summary>
                <div id="colorFilters" runat="server" style="margin-top: 5px; padding-left: 10px; font-size: 0.9em">
                    <!-- Will be populated dynamically via C# -->
                </div>
            </details>
            <hr />

            <!-- Material Filter (Dynamic) -->
            <details style="margin-top: 10px">
                <summary style="font-weight: 600; cursor: pointer">Material</summary>
                <div id="materialFilters" runat="server" style="margin-top: 5px; padding-left: 10px; font-size: 0.9em">
                    <!-- Will be populated dynamically via C# -->
                </div>
            </details>
            <hr />

            <!-- Price Filter (Hardcoded with ranges) -->
            <details style="margin-top: 10px">
                <summary style="font-weight: 600; cursor: pointer">Price</summary>
                <div style="margin-top: 5px; padding-left: 10px; font-size: 0.9em">
                    <label style="display: block; margin-bottom: 5px; cursor: pointer; font-weight: 600;">
                        <input type="checkbox" class="filter-checkbox" data-filter-type="price" data-filter-value="all" checked />
                        All
       
                    </label>
                    <hr style='margin: 5px 0;' />
                    <label style="display: block; margin-bottom: 5px; cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox" data-filter-type="price" data-filter-value="under100" disabled />
                        Under RM100
       
                    </label>
                    <label style="display: block; margin-bottom: 5px; cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox" data-filter-type="price" data-filter-value="100-300" disabled />
                        RM100 - RM300
       
                    </label>
                    <label style="display: block; margin-bottom: 5px; cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox" data-filter-type="price" data-filter-value="300-500" disabled />
                        RM300 - RM500
       
                    </label>
                    <label style="display: block; margin-bottom: 5px; cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox" data-filter-type="price" data-filter-value="500-1000" disabled />
                        RM500 - RM1000
       
                    </label>
                    <label style="display: block; margin-bottom: 5px; cursor: pointer;">
                        <input type="checkbox" class="filter-checkbox" data-filter-type="price" data-filter-value="above1000" disabled />
                        Above RM1000
       
                    </label>
                </div>
            </details>
        </div>

        <div class="right-container">
            <div class="toolbar">
                <div class="search-container">
                    <input type="text" placeholder="Search products..." />
                    <i class="ri-search-2-line"></i>
                </div>

                <div class="right-controls">
                    <div class="select-container">
                        <select>
                            <option>Sort by</option>
                            <option>Name</option>
                            <option>Price</option>
                            <option>Latest</option>
                            <option>Popularity</option>
                        </select>
                    </div>
                    <button type="button"><i class="ri-sort-asc"></i></button>
                </div>
            </div>

            <div class="catalogue-products">
                <table class="product-table">
                    <tbody id="productTableBody" runat="server"></tbody>
                </table>
                <asp:Literal ID="pagerContainer" runat="server"></asp:Literal>
            </div>
        </div>
    </div>
</asp:Content>
