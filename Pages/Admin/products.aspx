<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="products.aspx.cs" Inherits="Opton.Pages.Admin.products" MasterPageFile="~/Site.Master" %>

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
            justify-content: space-between; /* left vs right alignment */
            align-items: center;
        }

        #buttonsLeft {
            display: flex;
            gap: 8px; /* space between left buttons (only one for now) */
        }

        #buttonsRight {
            display: flex;
            gap: 8px; /* space between right buttons */
        }

        #addProductBtn {
            padding: 8px 16px;
            border-radius: 12px;
            border: 1px solid var(--color-dark);
            background-color: var(--color-dark);
            color: #fff;
            cursor: pointer;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: all 0.2s ease;
        }

        #refreshFilterBtn {
            padding: 0; /* remove extra space */
            border: none; /* remove border */
            background: none; /* remove background */
            color: var(--color-dark); /* icon color */
            cursor: pointer;
            font-size: 18px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

            #refreshFilterBtn:hover {
                filter: brightness(0.9);
            }

            #refreshFilterBtn i {
                font-size: 18px;
                vertical-align: middle;
            }

        #addProductBtn:hover {
            filter: brightness(0.85);
        }

        #saveChangesBtn {
            margin-left: 8px;
            background-color: var(--color-accent);
            color: #fff;
            border-radius: 12px;
            padding: 8px 16px;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
        }

            #saveChangesBtn:disabled {
                background-color: #ccc; /* lighter grey when disabled */
                cursor: not-allowed;
                opacity: 0.6;
            }

            #saveChangesBtn:not(:disabled):hover {
                filter: brightness(0.85); /* hover effect only when enabled */
            }

        #productGrid {
            width: 90%;
            margin: 0 auto 30px auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        th, td {
            padding: 8px;
            border: 1px solid #ccc;
            text-align: left;
            word-wrap: break-word;
        }

        /* Add space and style for sort arrows */
        th {
            cursor: pointer;
            background-color: #f2f2f2;
            position: relative; /* for the arrow pseudo-element */
            padding-right: 20px; /* space for the arrow */
        }

            th.sort-asc::after,
            th.sort-desc::after {
                content: '';
                position: absolute;
                right: 8px;
                font-size: 12px;
                pointer-events: none;
            }

            th.sort-asc::after {
                content: '▲';
                color: #555;
            }

            th.sort-desc::after {
                content: '▼';
                color: #555;
            }

        td.editing {
            background-color: #ffffcc;
        }

        td div.truncate {
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            word-wrap: break-word;
        }

        td.non-editable {
            background-color: #f0f0f0;
            color: #666;
            cursor: default;
        }

        td.delete-cell {
            text-align: center;
        }

            td.delete-cell i {
                color: red;
                cursor: pointer;
                font-size: 18px;
                transition: transform 0.2s;
            }

                td.delete-cell i:hover {
                    transform: scale(1.2);
                }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div id="searchContainer">
        <div id="searchWrapper">
            <input type="text" id="searchBar" placeholder="Search products..." />
            <i id="searchIcon" class="ri-search-line"></i>
        </div>
    </div>
    <div id="buttonsContainer">
        <div id="buttonsLeft">
            <button type="button" id="refreshFilterBtn" title="Refresh Filter">
                <i class="ri-refresh-line"></i>
            </button>
        </div>
        <div id="buttonsRight">
            <button type="button" id="addProductBtn">Add Product</button>
            <button type="button" id="saveChangesBtn" disabled>Save</button>
        </div>
    </div>
    <div id="productGrid">
        <p>Loading products...</p>
    </div>

    <script>
        let gridviewData = [];       // Original loaded data
        let editedData = {};         // Track changes per productId
        const saveBtn = document.getElementById('saveChangesBtn');

        let products = [];
        let sortColumn = null;
        let sortAsc = true;
        let columns = [];
        let currentlyEditing = null; // Track currently editing cell

        async function loadProducts() {
            const contentDiv = document.getElementById('productGrid');
            contentDiv.innerHTML = '<p>Loading products...</p>';

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: "getProductsList" })
                });

                const data = await response.json();
                if (!data.success || !data.products?.length) {
                    contentDiv.innerHTML = '<p>No products found.</p>';
                    return;
                }

                products = data.products.map(p => {
                    ["inventory", "R1", "R2", "R3"].forEach(key => {
                        if (p[key] && typeof p[key] === "object") {
                            p[key] = JSON.stringify(p[key]);
                        }
                    });
                    return p;
                });

                gridviewData = JSON.parse(JSON.stringify(products));
                columns = Object.keys(products[0]).filter(c => !c.endsWith("Normalized"));
                renderTable(products);
            } catch (err) {
                contentDiv.innerHTML = `<p>Error loading products: ${err.message}</p>`;
            }
        }

        function getUniqueValues(column) {
            const values = new Set();
            products.forEach(p => {
                if (!p[column]) return;
                if (column === "material") {
                    p[column].split(",").map(v => v.trim()).forEach(v => v && values.add(v));
                } else {
                    values.add(p[column].trim());
                }
            });
            return Array.from(values).sort();
        }

        function renderTable(data) {
            const contentDiv = document.getElementById('productGrid');
            const searchTerm = (document.getElementById('searchBar').value || "").toLowerCase();

            const filtered = data.filter(p =>
                columns.some(col => (p[col] || "").toString().toLowerCase().includes(searchTerm))
            );

            if (!filtered.length) {
                contentDiv.innerHTML = '<p>No products match the search.</p>';
                return;
            }

            const table = document.createElement('table');
            const thead = document.createElement('thead');
            const headerRow = document.createElement('tr');

            const numTh = document.createElement('th');
            numTh.textContent = '#';
            numTh.classList.add('non-editable');
            headerRow.appendChild(numTh);

            columns.forEach(col => {
                const th = document.createElement('th');
                th.textContent = col;

                // Remove previous sort classes
                th.classList.remove('sort-asc', 'sort-desc');

                // Add class for current sorted column
                if (sortColumn === col) {
                    th.classList.add(sortAsc ? 'sort-asc' : 'sort-desc');
                }

                th.onclick = () => sortByColumn(col);
                headerRow.appendChild(th);
            });

            const delTh = document.createElement('th');
            delTh.textContent = 'Delete';
            delTh.classList.add('non-editable');
            headerRow.appendChild(delTh);

            thead.appendChild(headerRow);
            table.appendChild(thead);

            const tbody = document.createElement('tbody');
            filtered.forEach((prod, index) => {
                const tr = document.createElement('tr');

                const numTd = document.createElement('td');
                numTd.textContent = index + 1;
                numTd.classList.add('non-editable');
                tr.appendChild(numTd);

                columns.forEach(col => {
                    const td = document.createElement('td');
                    const div = document.createElement('div');
                    div.classList.add('truncate');
                    div.textContent = prod[col] ?? "";
                    td.appendChild(div);

                    if (col !== 'productId' && col !== 'dateAdded') {
                        td.ondblclick = () => makeEditable(td, prod.productId, col);
                    } else {
                        td.classList.add('non-editable');
                    }

                    tr.appendChild(td);
                });

                const deleteTd = document.createElement('td');
                deleteTd.classList.add('delete-cell');
                const deleteIcon = document.createElement('i');
                deleteIcon.className = 'ri-delete-bin-line';
                deleteTd.appendChild(deleteIcon);
                tr.appendChild(deleteTd);

                deleteIcon.onclick = async () => {
                    if (!confirm("Are you sure you want to delete this product?")) return;

                    // Example: call your delete handler here
                    try {
                        const response = await fetch('/Handlers/fire_handler.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ action: "deleteProduct", productId: prod.productId })
                        });
                        const result = await response.json();
                        if (result.success) {
                            // Remove product from table and local arrays
                            products = products.filter(p => p.productId !== prod.productId);
                            gridviewData = gridviewData.filter(p => p.productId !== prod.productId);
                            renderTable(products);
                            showToast("Product deleted");
                        } else {
                            alert("Failed to delete product");
                        }
                    } catch (err) {
                        alert("Error deleting product: " + err.message);
                    }
                };

                tbody.appendChild(tr);
            });

            table.appendChild(tbody);
            contentDiv.innerHTML = "";
            contentDiv.appendChild(table);
        }

        function sortByColumn(col) {
            if (sortColumn === col) sortAsc = !sortAsc;
            else {
                sortColumn = col;
                sortAsc = true;
            }

            products.sort((a, b) => {
                let valA = a[col] ?? "";
                let valB = b[col] ?? "";
                if (typeof valA === "string") valA = valA.toLowerCase();
                if (typeof valB === "string") valB = valB.toLowerCase();
                return valA < valB ? (sortAsc ? -1 : 1) : valA > valB ? (sortAsc ? 1 : -1) : 0;
            });

            renderTable(products);
        }

        function sortByColumn(col) {
            if (sortColumn === col) sortAsc = !sortAsc;
            else {
                sortColumn = col;
                sortAsc = true;
            }

            products.sort((a, b) => {
                let valA = a[col] ?? "";
                let valB = b[col] ?? "";
                if (typeof valA === "string") valA = valA.toLowerCase();
                if (typeof valB === "string") valB = valB.toLowerCase();
                return valA < valB ? (sortAsc ? -1 : 1) : valA > valB ? (sortAsc ? 1 : -1) : 0;
            });

            renderTable(products);
        }

        function makeEditable(td, productId, field) {
            if (currentlyEditing && currentlyEditing !== td) {
                const oldVal = currentlyEditing.dataset.oldValue;
                finishEditCell(currentlyEditing, oldVal, currentlyEditing.dataset.productId, currentlyEditing.dataset.field);
            }

            currentlyEditing = td;
            td.classList.add("editing");
            const oldValue = td.textContent;
            td.dataset.oldValue = oldValue;
            td.dataset.productId = productId;
            td.dataset.field = field;
            td.innerHTML = '';

            const dropdownFields = ["category", "shape", "subCategory"];
            const isMaterial = field === "material";

            td.tabIndex = 0; // make td focusable
            td.focus();

            // GLOBAL keydown listener for Enter/Escape
            const handleKeydown = (e) => {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    if (dropdownFields.includes(field)) {
                        const select = td.querySelector('select');
                        const otherInput = td.querySelector('input[type=text]');
                        const val = select.value === 'Other' ? otherInput.value.trim() : select.value;
                        finishEditCell(td, val, productId, field);
                    } else if (isMaterial) {
                        const container = td.querySelector('div');
                        const selected = [];
                        container.querySelectorAll('input[type="checkbox"]').forEach(chk => {
                            if (chk.checked && chk !== container.querySelector('input[type=checkbox]:last-child')) selected.push(chk.value);
                        });
                        const otherInput = container.querySelector('input[type=text]');
                        if (otherInput && otherInput.value.trim()) selected.push(otherInput.value.trim());
                        finishEditCell(td, selected.join(','), productId, field);
                    } else if (field === "model") {
                        const fileInput = td.querySelector('input[type=file]');
                        if (fileInput && fileInput.files.length > 0) {
                            finishEditCell(td, fileInput.files[0].name, productId, field);
                        } else {
                            finishEditCell(td, oldValue, productId, field);
                        }
                    } else {
                        const textarea = td.querySelector('textarea');
                        if (textarea) finishEditCell(td, textarea.value, productId, field);
                    }
                }

                if (e.key === 'Escape') {
                    e.preventDefault();
                    finishEditCell(td, oldValue, productId, field);
                }
            };

            td.addEventListener('keydown', handleKeydown);

            if (dropdownFields.includes(field)) {
                const uniqueValues = getUniqueValues(field);
                const select = document.createElement('select');
                const otherOption = "Other";

                uniqueValues.forEach(val => {
                    const opt = document.createElement('option');
                    opt.value = val;
                    opt.textContent = val;
                    if (val === oldValue) opt.selected = true;
                    select.appendChild(opt);
                });

                const optOther = document.createElement('option');
                optOther.value = otherOption;
                optOther.textContent = otherOption;
                if (!uniqueValues.includes(oldValue)) optOther.selected = true;
                select.appendChild(optOther);

                const otherInput = document.createElement('input');
                otherInput.type = 'text';
                otherInput.style.width = '100%';
                otherInput.style.marginTop = '4px';
                otherInput.style.display = select.value === otherOption ? 'block' : 'none';
                otherInput.value = !uniqueValues.includes(oldValue) ? oldValue : "";

                select.style.position = 'relative';
                select.style.zIndex = 1000;
                otherInput.style.position = 'relative';
                otherInput.style.zIndex = 1000;

                td.appendChild(select);
                td.appendChild(otherInput);
                select.focus();

                select.onchange = () => {
                    if (select.value === otherOption) {
                        otherInput.style.display = 'block';
                        otherInput.focus();
                    } else {
                        otherInput.style.display = 'none';
                        const val = select.value;
                        finishEditCell(td, val, productId, field);
                    }
                };

                otherInput.onblur = () => {
                    if (select.value === otherOption && otherInput.value.trim()) finishEditCell(td, otherInput.value.trim(), productId, field);
                    else if (select.value === otherOption) finishEditCell(td, oldValue, productId, field);
                };

            } else if (isMaterial) {
                const uniqueValues = getUniqueValues("material");
                const container = document.createElement('div');
                container.style.display = 'flex';
                container.style.flexWrap = 'wrap';
                container.style.gap = '8px';
                container.style.position = 'relative';
                container.style.zIndex = 1000;

                td.appendChild(container);

                const selectedSet = new Set(oldValue.split(',').map(v => v.trim()).filter(v => v));

                uniqueValues.forEach(val => {
                    const label = document.createElement('label');
                    label.style.display = 'flex';
                    label.style.alignItems = 'center';
                    const checkbox = document.createElement('input');
                    checkbox.type = 'checkbox';
                    checkbox.value = val;
                    checkbox.checked = selectedSet.has(val);
                    label.appendChild(checkbox);
                    label.appendChild(document.createTextNode(' ' + val));
                    container.appendChild(label);
                });

                const otherLabel = document.createElement('label');
                otherLabel.style.display = 'flex';
                otherLabel.style.alignItems = 'center';
                const otherCheckbox = document.createElement('input');
                otherCheckbox.type = 'checkbox';
                const otherInput = document.createElement('input');
                otherInput.type = 'text';
                otherInput.style.display = 'none';
                otherInput.value = '';
                otherInput.style.marginLeft = '4px';
                otherInput.style.position = 'relative';
                otherInput.style.zIndex = 1001;

                otherCheckbox.addEventListener('change', () => {
                    otherInput.style.display = otherCheckbox.checked ? 'inline-block' : 'none';
                    if (otherCheckbox.checked) otherInput.focus();
                });

                otherLabel.appendChild(otherCheckbox);
                otherLabel.appendChild(document.createTextNode(' Other: '));
                otherLabel.appendChild(otherInput);
                container.appendChild(otherLabel);

                container.addEventListener('focusout', (e) => {
                    if (!container.contains(e.relatedTarget)) {
                        const selected = [];
                        container.querySelectorAll('input[type="checkbox"]').forEach(chk => {
                            if (chk.checked && chk !== otherCheckbox) selected.push(chk.value);
                        });
                        if (otherCheckbox.checked && otherInput.value.trim()) selected.push(otherInput.value.trim());
                        finishEditCell(td, selected.join(','), productId, field);
                    }
                });

                container.tabIndex = 0;
                container.focus();

            } else if (field === "model") {
                const fileInput = document.createElement('input');
                fileInput.type = 'file';
                fileInput.accept = ".png,.jpg,.jpeg,.glb";
                fileInput.style.width = '100%';
                fileInput.style.position = 'relative';
                fileInput.style.zIndex = 1000;

                td.appendChild(fileInput);
                fileInput.focus();

                fileInput.onchange = () => {
                    if (fileInput.files.length > 0) {
                        finishEditCell(td, fileInput.files[0].name, productId, field);
                    } else {
                        finishEditCell(td, oldValue, productId, field);
                    }
                };

                fileInput.onblur = () => {
                    if (!fileInput.files.length) finishEditCell(td, oldValue, productId, field);
                };

            } else {
                const textarea = document.createElement('textarea');
                textarea.value = oldValue;
                textarea.style.width = '100%';
                textarea.style.boxSizing = 'border-box';
                textarea.style.resize = 'both';
                textarea.style.position = 'absolute';
                textarea.style.zIndex = 8;
                textarea.style.backgroundColor = '#fff';
                textarea.style.top = '0';
                textarea.style.left = '0';
                textarea.style.minWidth = '150px';
                textarea.style.minHeight = '50px';

                td.style.position = 'relative';
                td.appendChild(textarea);

                const resize = () => {
                    textarea.style.height = 'auto';
                    textarea.style.height = textarea.scrollHeight + 'px';
                };
                textarea.addEventListener('input', resize);
                resize();
                textarea.focus();

                textarea.onblur = () => finishEditCell(td, textarea.value, productId, field);
            }
        }

        function finishEditCell(td, value, productId, field) {
            const trimmedValue = value.toString().trim(); // trim whitespace

            // Validate JSON fields
            const jsonFields = ["inventory", "R1", "R2", "R3"];
            if (jsonFields.includes(field) && !validateJSONField(field, trimmedValue)) {
                alert(`Invalid format for ${field}. Make sure it's a valid JSON object with numeric values.`);
                td.classList.add('editing');
                return; // stop saving
            }

            td.innerHTML = '';
            const div = document.createElement('div');
            div.classList.add('truncate');
            div.textContent = trimmedValue;
            td.appendChild(div);
            td.classList.remove('editing');
            currentlyEditing = null;

            if (!editedData[productId]) editedData[productId] = {};
            editedData[productId][field] = trimmedValue;

            toggleSaveButton();
        }

        function toggleSaveButton() {
            let hasChanges = false;
            for (const prodId in editedData) {
                const orig = gridviewData.find(p => p.productId === prodId);
                const changes = editedData[prodId];
                for (const key in changes) {
                    const origVal = (orig[key] ?? "").toString().trim();
                    const editedVal = (changes[key] ?? "").toString().trim();
                    if (origVal !== editedVal) {
                        hasChanges = true;
                        break;
                    }
                }
                if (hasChanges) break;
            }
            saveBtn.disabled = !hasChanges;
        }

        saveBtn.onclick = async () => {
            if (!confirm("Are you sure you want to save changes?")) return;

            // Apply changes to the data structures
            for (const prodId in editedData) {
                if (!prodId) {
                    // This is a new product (productId is "")
                    const newProduct = products.find(p => p.productId === "");
                    if (newProduct) {
                        // Generate a temporary ID
                        const maxId = products
                            .filter(p => p.productId && p.productId.startsWith('P-'))
                            .map(p => parseInt(p.productId.split('-')[1]) || 0)
                            .reduce((max, num) => Math.max(max, num), 0);
                        const newId = `P-${maxId + 1}`;

                        // Update the product with new ID and edited data
                        Object.assign(newProduct, editedData[prodId]);
                        newProduct.productId = newId;

                        // Update gridviewData
                        const gridProduct = gridviewData.find(p => p.productId === "");
                        if (gridProduct) {
                            Object.assign(gridProduct, editedData[prodId]);
                            gridProduct.productId = newId;
                        }
                    }
                } else {
                    // Existing product - apply changes
                    const product = products.find(p => p.productId === prodId);
                    if (product) {
                        Object.assign(product, editedData[prodId]);
                    }

                    const gridProduct = gridviewData.find(p => p.productId === prodId);
                    if (gridProduct) {
                        Object.assign(gridProduct, editedData[prodId]);
                    }
                }
            }

            // Clear editedData and disable save button
            editedData = {};
            saveBtn.disabled = true;

            // Re-render table
            renderTable(products);

            showToast("Saved!");
        };

        function validateJSONField(fieldName, value) {
            if (!value) return true; // allow empty

            let parsed;
            try {
                parsed = JSON.parse(value);
            } catch (e) {
                return false; // invalid JSON
            }

            if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) return false;

            // Optional: check nested values are numbers
            const checkNestedNumbers = (obj) => {
                for (const key in obj) {
                    if (typeof obj[key] === 'object' && obj[key] !== null) {
                        if (!checkNestedNumbers(obj[key])) return false;
                    } else if (typeof obj[key] !== 'number') return false;
                }
                return true;
            };

            return checkNestedNumbers(parsed);
        }
        document.getElementById('refreshFilterBtn').onclick = async () => {
            // Check for unsaved changes using the same logic as toggleSaveButton
            let hasChanges = false;

            for (const prodId in editedData) {
                const orig = gridviewData.find(p => p.productId === prodId);
                const changes = editedData[prodId];

                for (const key in changes) {
                    const origVal = (orig?.[key] ?? "").toString().trim();
                    const editedVal = (changes[key] ?? "").toString().trim();

                    // Only count as change if it's different from original
                    if (origVal !== editedVal) {
                        hasChanges = true;
                        break;
                    }
                }

                if (hasChanges) break;
            }

            if (hasChanges) {
                const confirmRefresh = confirm("You have unsaved changes. Refreshing will discard them. Continue?");
                if (!confirmRefresh) return;
            }

            // Reset search and sort
            document.getElementById('searchBar').value = '';
            editedData = {}; // discard changes
            toggleSaveButton(); // disable save button

            sortColumn = null; // reset sort
            sortAsc = true;    // default ascending

            await loadProducts(); // reload from server
            showToast("Products refreshed");
        };

        document.getElementById('addProductBtn').onclick = () => {
            const newProduct = {};

            // Initialize all columns with empty strings
            columns.forEach(col => {
                if (col === 'dateAdded') newProduct[col] = new Date().toISOString().split('T')[0];
                else newProduct[col] = '';
            });

            // Add to top of products and gridviewData
            products.unshift(newProduct);
            gridviewData.unshift(JSON.parse(JSON.stringify(newProduct)));

            renderTable(products);

            // Focus first editable cell of new row
            setTimeout(() => {
                const firstRow = document.querySelector('#productGrid tbody tr');
                if (firstRow) {
                    const firstEditableTd = Array.from(firstRow.children).find((td, i) => {
                        const col = columns[i - 1]; // first column is #, so index -1
                        return col && col !== 'productId' && col !== 'dateAdded';
                    });
                    if (firstEditableTd) makeEditable(firstEditableTd, "", columns[1]); // start editing first editable field
                }
            }, 50);
        };

        document.getElementById('searchBar').addEventListener('input', () => renderTable(products));
        loadProducts();
    </script>

</asp:Content>
