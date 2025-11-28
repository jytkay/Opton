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

                // Add visual indicator for new products
                if (!prod.productId || prod._isNew) {
                    tr.style.backgroundColor = '#f0f8ff'; // Light blue background for new products
                    tr.title = "New product - not saved yet";
                }

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

                    if (col !== 'productId') {
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
                    if (!confirm("Are you sure you want to delete this product? This will also delete ALL associated files from storage.")) return;

                    // Check if this is a new product (temporary ID)
                    if (prod._isTemp || !prod.productId || prod.productId.startsWith('temp_')) {
                        // Remove product from table and local arrays (no server call needed)
                        products = products.filter(p => p !== prod);
                        gridviewData = gridviewData.filter(p => p !== prod);
                        renderTable(products);
                        toggleSaveButton();
                        showToast("New product removed");
                        return;
                    }

                    try {
                        // First, delete ALL files for this product from storage
                        const storageResponse = await fetch('/Handlers/storage_handler.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({
                                action: "deleteProductFolder",
                                productId: prod.productId
                            })
                        });

                        const storageResult = await storageResponse.json();

                        if (!storageResult.success) {
                            console.warn("Failed to delete product folder:", storageResult.message);
                            // Continue with database deletion even if folder deletion fails
                        }

                        // Then delete the product from the database
                        const dbResponse = await fetch('/Handlers/db_handler.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({
                                action: "deleteProduct",
                                productId: prod.productId
                            })
                        });

                        const dbResult = await dbResponse.json();

                        if (dbResult.success) {
                            // Remove product from table and local arrays
                            products = products.filter(p => p.productId !== prod.productId);
                            gridviewData = gridviewData.filter(p => p.productId !== prod.productId);
                            renderTable(products);

                            if (storageResult.success) {
                                showToast("Product and all associated files deleted successfully");
                            } else {
                                showToast("Product deleted from database, but some files may remain in storage");
                            }
                        } else {
                            alert("Failed to delete product: " + dbResult.message);
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
            const isTimeAdded = field === "timeAdded";
            const isPrice = field === "price";

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
                    } else if (isTimeAdded) {
                        const dateInput = td.querySelector('input[type=date]');
                        if (dateInput) finishEditCell(td, dateInput.value, productId, field);
                    } else if (isPrice) {
                        const numberInput = td.querySelector('input[type=number]');
                        if (numberInput) finishEditCell(td, numberInput.value, productId, field);
                    } else if (field === "model") {
                        // Model field handled by buttons, not Enter key
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

            if (isTimeAdded) {
                const dateInput = document.createElement('input');
                dateInput.type = 'date';
                dateInput.style.width = '100%';
                dateInput.style.padding = '4px';
                dateInput.style.position = 'relative';
                dateInput.style.zIndex = 1000;

                // Parse existing date value (format: 2025-06-25T07:00:00Z or YYYY-MM-DD)
                if (oldValue) {
                    try {
                        const date = new Date(oldValue);
                        const year = date.getFullYear();
                        const month = String(date.getMonth() + 1).padStart(2, '0');
                        const day = String(date.getDate()).padStart(2, '0');
                        dateInput.value = `${year}-${month}-${day}`;
                    } catch (e) {
                        dateInput.value = oldValue.split('T')[0]; // fallback
                    }
                }

                td.appendChild(dateInput);
                dateInput.focus();

                dateInput.onblur = () => finishEditCell(td, dateInput.value, productId, field);

            } else if (isPrice) {
                const numberInput = document.createElement('input');
                numberInput.type = 'number';
                numberInput.step = '0.01';
                numberInput.min = '0';
                numberInput.value = oldValue;
                numberInput.style.width = '100%';
                numberInput.style.padding = '4px';
                numberInput.style.position = 'relative';
                numberInput.style.zIndex = 1000;

                td.appendChild(numberInput);
                numberInput.focus();
                numberInput.select();

                numberInput.onblur = () => finishEditCell(td, numberInput.value, productId, field);

            } else if (dropdownFields.includes(field)) {
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
                const container = document.createElement('div');
                container.style.position = 'relative';
                container.style.zIndex = 1000;
                container.style.padding = '8px';
                container.style.backgroundColor = '#fff';
                container.style.border = '1px solid #ccc';
                container.style.borderRadius = '4px';
                container.style.minWidth = '300px';

                // Parse existing models
                const existingModels = oldValue ? oldValue.split(',').map(m => m.trim()).filter(m => m) : [];

                // Display current models with delete buttons
                const currentModelsDiv = document.createElement('div');
                currentModelsDiv.style.marginBottom = '12px';

                if (existingModels.length > 0) {
                    const title = document.createElement('div');
                    title.textContent = 'Current Models:';
                    title.style.fontWeight = 'bold';
                    title.style.marginBottom = '8px';
                    title.style.fontSize = '14px';
                    currentModelsDiv.appendChild(title);

                    existingModels.forEach(model => {
                        const modelItem = document.createElement('div');
                        modelItem.style.display = 'flex';
                        modelItem.style.justifyContent = 'space-between';
                        modelItem.style.alignItems = 'center';
                        modelItem.style.padding = '4px 8px';
                        modelItem.style.marginBottom = '4px';
                        modelItem.style.backgroundColor = '#f5f5f5';
                        modelItem.style.borderRadius = '4px';

                        const modelName = document.createElement('span');
                        modelName.textContent = model;
                        modelName.style.fontSize = '12px';

                        const deleteBtn = document.createElement('button');
                        deleteBtn.innerHTML = '×';
                        deleteBtn.style.background = 'none';
                        deleteBtn.style.border = 'none';
                        deleteBtn.style.color = '#ff4444';
                        deleteBtn.style.cursor = 'pointer';
                        deleteBtn.style.fontSize = '16px';
                        deleteBtn.style.fontWeight = 'bold';
                        deleteBtn.style.padding = '0 4px';

                        deleteBtn.onclick = async (e) => {
                            e.stopPropagation();

                            if (!confirm(`Are you sure you want to delete the model file "${model}"? This will remove it from storage.`)) return;

                            // Remove from existing models
                            const index = existingModels.indexOf(model);
                            if (index > -1) {
                                existingModels.splice(index, 1);
                                // Update the display
                                modelItem.remove();

                                // Update edited data
                                if (!editedData[productId]) editedData[productId] = {};
                                editedData[productId][field] = existingModels.join(', ');
                                editedData[productId]._deletedModels = editedData[productId]._deletedModels || [];
                                editedData[productId]._deletedModels.push(model);

                                toggleSaveButton();

                                // If no models left, hide the title
                                if (existingModels.length === 0) {
                                    title.style.display = 'none';
                                }

                                // Show immediate feedback that deletion is pending
                                showToast(`"${model}" will be deleted from storage when you click Save`);
                            }
                        };

                        modelItem.appendChild(modelName);
                        modelItem.appendChild(deleteBtn);
                        currentModelsDiv.appendChild(modelItem);
                    });
                } else {
                    const noModels = document.createElement('div');
                    noModels.textContent = 'No models uploaded';
                    noModels.style.fontSize = '12px';
                    noModels.style.color = '#666';
                    noModels.style.fontStyle = 'italic';
                    currentModelsDiv.appendChild(noModels);
                }

                // Add new file section
                const addNewSection = document.createElement('div');
                addNewSection.style.borderTop = '1px solid #eee';
                addNewSection.style.paddingTop = '12px';
                addNewSection.style.marginTop = '12px';

                const addTitle = document.createElement('div');
                addTitle.textContent = 'Add New Model:';
                addTitle.style.fontWeight = 'bold';
                addTitle.style.marginBottom = '8px';
                addTitle.style.fontSize = '14px';
                addNewSection.appendChild(addTitle);

                const fileInput = document.createElement('input');
                fileInput.type = 'file';
                fileInput.accept = ".png,.jpg,.jpeg,.glb";
                fileInput.style.width = '100%';
                fileInput.style.marginBottom = '8px';
                fileInput.style.display = 'none';

                const fileInfo = document.createElement('div');
                fileInfo.style.fontSize = '11px';
                fileInfo.style.color = '#666';
                fileInfo.style.marginBottom = '8px';
                fileInfo.textContent = 'File will be uploaded when you click Save';

                const selectBtn = document.createElement('button');
                selectBtn.textContent = 'Select File';
                selectBtn.type = 'button';
                selectBtn.style.padding = '6px 12px';
                selectBtn.style.backgroundColor = '#2196F3';
                selectBtn.style.color = 'white';
                selectBtn.style.border = 'none';
                selectBtn.style.borderRadius = '4px';
                selectBtn.style.cursor = 'pointer';
                selectBtn.style.marginRight = '8px';

                const cancelBtn = document.createElement('button');
                cancelBtn.textContent = 'Done';
                cancelBtn.type = 'button';
                cancelBtn.style.padding = '6px 12px';
                cancelBtn.style.backgroundColor = '#4CAF50';
                cancelBtn.style.color = 'white';
                cancelBtn.style.border = 'none';
                cancelBtn.style.borderRadius = '4px';
                cancelBtn.style.cursor = 'pointer';

                addNewSection.appendChild(fileInfo);
                addNewSection.appendChild(fileInput);
                addNewSection.appendChild(selectBtn);
                addNewSection.appendChild(cancelBtn);

                container.appendChild(currentModelsDiv);
                container.appendChild(addNewSection);
                td.appendChild(container);

                // File selection handler
                selectBtn.onclick = (e) => {
                    e.stopPropagation();
                    fileInput.click();
                };

                fileInput.onchange = () => {
                    if (fileInput.files.length > 0) {
                        const file = fileInput.files[0];
                        fileInfo.textContent = `Selected: ${file.name} (${(file.size / 1024).toFixed(2)} KB) - Will upload on Save`;

                        // Store file reference - DON'T add to model list yet
                        if (!editedData[productId]) editedData[productId] = {};
                        editedData[productId]._newModelFile = file;

                        toggleSaveButton();
                    }
                };

                // Prevent blur when clicking inside the container
                container.addEventListener('mousedown', (e) => {
                    e.stopPropagation();
                });

                cancelBtn.onclick = (e) => {
                    e.stopPropagation();

                    // Check if we have a new file to show in the display
                    let displayValue = existingModels.join(', ');
                    if (editedData[productId] && editedData[productId]._newModelFile) {
                        const newFile = editedData[productId]._newModelFile;
                        // Show pending file in the display (but don't add to the actual model list yet)
                        if (displayValue) {
                            displayValue += `, [Pending: ${newFile.name}]`;
                        } else {
                            displayValue = `[Pending: ${newFile.name}]`;
                        }
                    }

                    // Finish editing with current state
                    finishEditCell(td, displayValue, productId, field);
                };

                container.tabIndex = 0;
                container.focus();
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

            // Check if this is a model field with pending upload
            if (field === "model" && editedData[productId] && editedData[productId]._newModelFile) {
                const pendingFile = editedData[productId]._newModelFile;
                div.innerHTML = `${trimmedValue} <span style="color: #2196F3; font-style: italic;">(New file pending: ${pendingFile.name})</span>`;
            } else {
                div.textContent = trimmedValue;
            }

            td.appendChild(div);
            td.classList.remove('editing');
            currentlyEditing = null;

            if (!editedData[productId]) editedData[productId] = {};

            // Only update the actual model field if it doesn't contain the pending marker
            if (field === "model" && value.includes('[Pending:') || value.includes('(New file pending:')) {
                // Don't update the actual model field - keep the original value
                // The pending file is stored in _newModelFile and will be processed on save
            } else {
                editedData[productId][field] = trimmedValue;
            }

            toggleSaveButton();
        }

        function toggleSaveButton() {
            let hasChanges = false;

            // Check for new products (empty productId)
            const hasNewProducts = products.some(p => !p.productId || p._isNew);
            if (hasNewProducts) {
                hasChanges = true;
            }

            // Check for edited data
            for (const prodId in editedData) {
                // For new products (empty productId), check if they have any actual data
                if (!prodId) {
                    const newProduct = products.find(p => !p.productId);
                    if (newProduct) {
                        // Check if the new product has any non-empty fields (excluding productId and timeAdded)
                        const hasData = Object.keys(newProduct).some(key =>
                            key !== 'productId' &&
                            key !== 'timeAdded' &&
                            key !== '_isNew' &&
                            newProduct[key] &&
                            newProduct[key].toString().trim() !== ''
                        );
                        if (hasData) {
                            hasChanges = true;
                            break;
                        }
                    }
                } else {
                    // For existing products, check for actual changes
                    const orig = gridviewData.find(p => p.productId === prodId);
                    const changes = editedData[prodId];

                    for (const key in changes) {
                        // Skip internal file references for comparison but count them as changes
                        if (key === '_newModelFile' || key === '_deletedModels') {
                            hasChanges = true;
                            break;
                        }

                        const origVal = (orig[key] ?? "").toString().trim();
                        const editedVal = (changes[key] ?? "").toString().trim();
                        if (origVal !== editedVal) {
                            hasChanges = true;
                            break;
                        }
                    }
                    if (hasChanges) break;
                }
            }

            saveBtn.disabled = !hasChanges;
        }

        saveBtn.onclick = async () => {
            if (!confirm("Are you sure you want to save changes?")) return;

            try {
                console.log('Starting save process with editedData:', editedData);

                // Handle model file operations
                for (const prodId in editedData) {
                    console.log('Processing product:', prodId);

                    // Delete removed models from storage
                    if (editedData[prodId]._deletedModels && editedData[prodId]._deletedModels.length > 0) {
                        console.log('Deleting models:', editedData[prodId]._deletedModels);

                        // Create a copy of the array to avoid modification during iteration
                        const modelsToDelete = [...editedData[prodId]._deletedModels];

                        for (const modelName of modelsToDelete) {
                            try {
                                console.log('Attempting to delete model:', modelName, 'for product:', prodId);

                                const deleteData = {
                                    action: 'deleteModel',
                                    productId: prodId,
                                    fileName: modelName
                                };

                                console.log('Sending delete request:', deleteData);

                                const deleteRes = await fetch('/Handlers/storage_handler.ashx', {
                                    method: 'POST',
                                    headers: {
                                        'Content-Type': 'application/json',
                                        'Accept': 'application/json'
                                    },
                                    body: JSON.stringify(deleteData)
                                });

                                console.log('Delete response status:', deleteRes.status);

                                const responseText = await deleteRes.text();
                                console.log('Delete response text:', responseText);

                                let deleteResult;
                                try {
                                    deleteResult = JSON.parse(responseText);
                                } catch (parseError) {
                                    console.error('Failed to parse delete response:', parseError);
                                    throw new Error('Invalid response from server: ' + responseText);
                                }

                                if (deleteResult.success) {
                                    console.log(`Successfully deleted model: ${modelName}`);
                                    // Remove from the deleted models array after successful deletion
                                    const index = editedData[prodId]._deletedModels.indexOf(modelName);
                                    if (index > -1) {
                                        editedData[prodId]._deletedModels.splice(index, 1);
                                    }
                                } else {
                                    console.warn(`Failed to delete model ${modelName}: ${deleteResult.message}`);
                                    // Don't throw error here - continue with other operations
                                    showToast(`Warning: Failed to delete ${modelName} from storage: ${deleteResult.message}`);
                                }
                            } catch (deleteError) {
                                console.warn(`Error deleting model ${modelName}:`, deleteError);
                                showToast(`Warning: Error deleting ${modelName} from storage: ${deleteError.message}`);
                            }
                        }

                        // Clean up empty deleted models array
                        if (editedData[prodId]._deletedModels && editedData[prodId]._deletedModels.length === 0) {
                            delete editedData[prodId]._deletedModels;
                        }
                    }

                    // Upload new model files (existing code remains the same)
                    if (editedData[prodId]._newModelFile) {
                        const file = editedData[prodId]._newModelFile;
                        console.log('Uploading new file:', file.name, 'for product:', prodId);

                        try {
                            const formData = new FormData();
                            formData.append('file', file);
                            formData.append('productId', prodId);
                            formData.append('action', 'uploadModel');

                            console.log('Sending upload request to storage handler');
                            const uploadRes = await fetch('/Handlers/storage_handler.ashx', {
                                method: 'POST',
                                body: formData
                            });

                            console.log('Upload response status:', uploadRes.status);

                            const responseText = await uploadRes.text();
                            console.log('Upload response text:', responseText);

                            let uploadResult;
                            try {
                                uploadResult = JSON.parse(responseText);
                            } catch (parseError) {
                                console.error('Failed to parse upload response:', parseError);
                                throw new Error('Invalid response from server');
                            }

                            if (uploadResult.success) {
                                console.log(`Successfully uploaded model: ${uploadResult.fileName}`);

                                // Get current models (excluding any pending markers)
                                const originalModels = gridviewData.find(p => p.productId === prodId)?.model || '';
                                const currentModels = originalModels ?
                                    originalModels.split(',').map(m => m.trim()).filter(m => m) : [];

                                // Add the new filename to the list
                                if (!currentModels.includes(uploadResult.fileName)) {
                                    currentModels.push(uploadResult.fileName);
                                    editedData[prodId].model = currentModels.join(', ');
                                    console.log('Updated model field to:', editedData[prodId].model);
                                }
                            } else {
                                throw new Error(`Failed to upload model for ${prodId}: ${uploadResult.message}`);
                            }
                        } catch (uploadError) {
                            console.error('Upload error details:', uploadError);
                            throw new Error(`Model upload failed for ${prodId}: ${uploadError.message}`);
                        }

                        // Remove the file reference after successful upload
                        delete editedData[prodId]._newModelFile;
                    }
                }

                // Process database updates
                for (const prodId in editedData) {
                    if (!prodId) {
                        // New product
                        const product = products.find(p => p.productId === "");
                        if (product) {
                            const productData = {
                                action: "addProduct",
                                ...editedData[prodId]
                            };

                            // Remove temporary file references
                            delete productData._newModelFile;
                            delete productData._deletedModels;

                            if (!productData.name || !productData.category) {
                                alert('Product name and category are required');
                                return;
                            }

                            console.log('Adding new product:', productData);
                            const res = await fetch('/Handlers/db_handler.ashx', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify(productData)
                            });
                            const result = await res.json();
                            if (!result.success) {
                                throw new Error(`Failed to add product: ${result.message}`);
                            }

                            product.productId = result.productId;
                            const gridProduct = gridviewData.find(p => p.productId === "");
                            if (gridProduct) {
                                gridProduct.productId = result.productId;
                            }
                        }
                    } else {
                        // Update existing product
                        const original = gridviewData.find(p => p.productId === prodId);
                        const productData = {
                            action: "updateProduct",
                            productId: prodId,
                            ...original,
                            ...editedData[prodId]
                        };

                        // Remove temporary file references
                        delete productData._newModelFile;
                        delete productData._deletedModels;

                        console.log('Updating product:', productData);
                        const res = await fetch('/Handlers/db_handler.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify(productData)
                        });
                        const result = await res.json();
                        if (!result.success) {
                            throw new Error(`Failed to update product ${prodId}: ${result.message}`);
                        }

                        const product = products.find(p => p.productId === prodId);
                        if (product) {
                            Object.assign(product, editedData[prodId]);
                        }
                        if (original) {
                            Object.assign(original, editedData[prodId]);
                        }
                    }
                }

                // Clear editedData and disable save button
                editedData = {};
                saveBtn.disabled = true;

                // Re-render table
                renderTable(products);
                showToast("Products saved successfully!");
            } catch (err) {
                alert("Error saving changes: " + err.message);
            }
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
            // Check for unsaved changes including new products
            let hasChanges = false;

            for (const prodId in editedData) {
                // New products (empty productId) count as changes
                if (!prodId) {
                    hasChanges = true;
                    break;
                }

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
                if (col === 'timeAdded') newProduct[col] = new Date().toISOString().split('T')[0];
                else newProduct[col] = '';
            });

            // Generate a temporary unique ID for the new product
            const tempId = 'temp_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
            newProduct.productId = tempId;
            newProduct._isNew = true;
            newProduct._isTemp = true;

            // Add to top of products and gridviewData
            products.unshift(newProduct);
            gridviewData.unshift(JSON.parse(JSON.stringify(newProduct)));

            renderTable(products);

            // Enable save button since we have a new product
            toggleSaveButton();

            // Focus first editable cell of new row
            setTimeout(() => {
                const firstRow = document.querySelector('#productGrid tbody tr');
                if (firstRow) {
                    const firstEditableTd = Array.from(firstRow.children).find((td, i) => {
                        const col = columns[i - 1]; // first column is #, so index -1
                        return col && col !== 'productId' && col !== 'timeAdded';
                    });
                    if (firstEditableTd) makeEditable(firstEditableTd, tempId, columns[1]); // use tempId for editing
                }
            }, 50);
        };

        document.getElementById('searchBar').addEventListener('input', () => renderTable(products));
        loadProducts();
    </script>

</asp:Content>
