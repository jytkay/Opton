<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="stock.aspx.cs" Inherits="Opton.Pages.Worker.stock" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <style>
        .container {
            width: 90%;
            max-width: 1200px;
            margin: 20px auto;
        }

        .collapsible {
            background-color: #f1f1f1;
            color: #444;
            cursor: pointer;
            padding: 10px 20px;
            width: 100%;
            border: 1px solid #ccc;
            border-radius: 4px;
            text-align: left;
            outline: none;
            font-size: 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

            .active, .collapsible:hover {
                background-color: #ccc;
            }

            .collapsible:after {
                content: '\25BC';
                font-size: 12px;
                transition: transform 0.2s;
            }

        .active:after {
            transform: rotate(180deg);
        }

        .content {
            padding: 10px 20px;
            display: none;
            overflow: hidden;
            background-color: #f9f9f9;
            margin-bottom: 20px;
            border: 1px solid #ddd;
        }

        table {
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 10px;
            z-index: 8;
            position: relative;
        }

        table, th, td {
            border: 1px solid #ccc;
        }

        th, td {
            padding: 8px;
            text-align: center;
        }

        th {
            background-color: #e2e2e2;
            cursor: pointer;
        }

            th.sorted-asc::after {
                content: " ▲";
            }

            th.sorted-desc::after {
                content: " ▼";
            }

        .stock-section {
            display: flex;
            gap: 20px;
        }

        .stock-table-wrapper {
            flex: 2;
        }

        .restock-input-wrapper {
            flex: 1;
            border: 1px solid #ddd;
            padding: 10px;
            background-color: #fafafa;
        }

            .restock-input-wrapper label {
                display: block;
                margin-top: 10px;
            }

            .restock-input-wrapper input, .restock-input-wrapper select {
                width: 100%;
                padding: 5px;
                margin-top: 5px;
            }

        .btn-submit {
            margin-top: 15px;
            width: 100%;
            padding: 8px;
            background-color: #007bff;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 5px;
        }

            .btn-submit:hover {
                background-color: #0056b3;
            }

        #buttonsRight {
            display: flex;
            justify-content: flex-end;
            margin-bottom: 20px;
            gap: 10px;
        }

            #buttonsRight button {
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

        .restock-controls {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .sort-controls {
            display: flex;
            align-items: center;
            gap: 10px;
        }

            .sort-controls label {
                font-weight: bold;
                margin-right: 5px;
            }

            .sort-controls select {
                padding: 5px 10px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }

        select.inline-editor {
            width: 100%;
            padding: 2px;
        }

        input.inline-editor {
            width: 100%;
            padding: 2px;
        }

        /* Grey out non-editable columns */
        #restockTable td:not(.editable-cell) {
            background-color: #f8f9fa;
            color: #6c757d;
        }

        #restockTable th:not(:nth-child(9)):not(:nth-child(10)):not(:nth-child(11)) {
            background-color: #e9ecef;
            color: #6c757d;
        }

        /* Collapsed icon */
        #collapsedIconContainer {
            text-align: center;
            margin: 20px 0;
            display: none;
        }

            #collapsedIconContainer i {
                font-size: 40px;
                color: #ccc;
            }

        .loading {
            text-align: center;
            padding: 20px;
            color: #666;
        }

        .error {
            color: #dc3545;
            text-align: center;
            padding: 20px;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <!-- Stock List -->
        <button type="button" class="collapsible">Stock List</button>
        <div class="content">
            <div class="stock-section">
                <div class="stock-table-wrapper">
                    <table id="stockTable">
                        <thead>
                            <tr>
                                <th data-sort="productId">Product ID</th>
                                <th data-sort="name">Name</th>
                                <th data-sort="inventory">Inventory</th>
                                <th data-sort="R1">R1</th>
                                <th data-sort="R2">R2</th>
                                <th data-sort="R3">R3</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td colspan="6" class="loading">Loading stock data...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="restock-input-wrapper">
                    <h4>Request to Restock</h4>
                    <label for="ddlProduct">Product</label>
                    <select id="ddlProduct">
                        <option value="">Loading products...</option>
                    </select>

                    <label for="ddlStore">Retailer</label>
                    <select id="ddlStore">
                        <option value="R1">R1</option>
                        <option value="R2">R2</option>
                        <option value="R3">R3</option>
                    </select>

                    <label for="txtQuantity">Quantity</label>
                    <input type="number" id="txtQuantity" value="1" min="1" />

                    <label for="txtRemarks">Remarks (optional)</label>
                    <input type="text" id="txtRemarks" />

                    <button type="button" class="btn-submit" id="btnSubmitRestock">Submit</button>
                </div>
            </div>
        </div>

        <!-- Restock Requests -->
        <button type="button" class="collapsible">Restock Requests</button>
        <div class="content">
            <div class="restock-controls">
                <div class="sort-controls">
                    <select id="statusFilter">
                        <option value="all">All Statuses</option>
                        <option value="Pending">Pending</option>
                        <option value="Ordered">Ordered</option>
                        <option value="Restocked">Restocked</option>
                        <option value="Rejected">Rejected</option>
                    </select>
                    <select id="sortRestocks">
                        <option value="latest">Latest First</option>
                        <option value="oldest">Oldest First</option>
                    </select>
                </div>
                <div id="buttonsRight">
                    <button type="button" id="btnSaveRestock" disabled>Save</button>
                </div>
            </div>
            <table id="restockTable">
                <thead>
                    <tr>
                        <th>Restock ID</th>
                        <th>Product ID</th>
                        <th>Colour</th>
                        <th>Size</th>
                        <th>Quantity</th>
                        <th>Store</th>
                        <th>Request Time</th>
                        <th>Requested By</th>
                        <th>Status</th>
                        <th>Reviewed By</th>
                        <th>Remarks</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="11" class="loading">Loading restock requests...</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- Collapsed icon -->
        <div id="collapsedIconContainer">
        </div>
    </div>

    <script>
        // Collapsible
        const collapsibles = document.querySelectorAll(".collapsible");
        const contents = document.querySelectorAll(".content");
        const collapsedIcon = document.getElementById("collapsedIconContainer");

        function updateCollapsedIcon() {
            const allCollapsed = Array.from(contents).every(c => c.style.display === "none");
            collapsedIcon.style.display = allCollapsed ? "block" : "none";
        }

        collapsibles.forEach(btn => {
            btn.addEventListener("click", () => {
                btn.classList.toggle("active");
                const content = btn.nextElementSibling;
                content.style.display = (content.style.display === "block") ? "none" : "block";
                updateCollapsedIcon();
            });
        });
        updateCollapsedIcon();

        const retailers = ["inventory", "R1", "R2", "R3"];

        function formatStockObject(obj) {
            if (!obj || typeof obj !== "object" || Object.keys(obj).length === 0) return "";
            let result = "";
            for (const sizeOrColour in obj) {
                if (typeof obj[sizeOrColour] === "object") {
                    for (const colour in obj[sizeOrColour]) {
                        result += `${sizeOrColour} ${colour}: ${obj[sizeOrColour][colour]} `;
                    }
                } else {
                    result += `${sizeOrColour}: ${obj[sizeOrColour]} `;
                }
            }
            return result.trim();
        }

        function naturalCompare(a, b) {
            const aNum = parseInt(a.replace(/[^\d]/g, ""), 10);
            const bNum = parseInt(b.replace(/[^\d]/g, ""), 10);
            return aNum - bNum;
        }

        function sortTable(table, colIndex, numeric = false, asc = true) {
            const tbody = table.tBodies[0];
            const rows = Array.from(tbody.querySelectorAll("tr"));
            rows.sort((rA, rB) => {
                let a = rA.cells[colIndex].textContent.trim();
                let b = rB.cells[colIndex].textContent.trim();
                if (numeric) return asc ? naturalCompare(a, b) : naturalCompare(b, a);
                return asc ? a.localeCompare(b) : b.localeCompare(a);
            });
            rows.forEach(r => tbody.appendChild(r));
        }

        document.querySelectorAll("#stockTable th").forEach((th, index) => {
            let asc = true;
            th.addEventListener("click", () => {
                document.querySelectorAll("#stockTable th").forEach(h => h.classList.remove("sorted-asc", "sorted-desc"));
                th.classList.add(asc ? "sorted-asc" : "sorted-desc");
                const numeric = th.dataset.sort === "productId";
                sortTable(th.closest("table"), index, numeric, asc);
                asc = !asc;
            });
        });

        // Load stock data
        async function loadStock() {
            try {
                const res = await fetch("/Handlers/fire_handler.ashx", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ action: "getStockList" })
                });
                const data = await res.json();
                const tbody = document.querySelector("#stockTable tbody");
                const ddlProduct = document.querySelector("#ddlProduct");

                if (!data.success || !data.stockList) {
                    tbody.innerHTML = '<tr><td colspan="6" class="error">Failed to load stock data</td></tr>';
                    ddlProduct.innerHTML = '<option value="">No products available</option>';
                    return;
                }

                tbody.innerHTML = "";
                ddlProduct.innerHTML = '<option value="">Select a product</option>';

                const validStock = data.stockList.filter(s => s.productId && s.name && retailers.some(r => s[r] && Object.keys(s[r]).length > 0));
                validStock.sort((a, b) => naturalCompare(a.productId, b.productId));

                validStock.forEach(stock => {
                    const row = document.createElement("tr");
                    const pidCell = document.createElement("td");
                    pidCell.textContent = stock.productId;
                    row.appendChild(pidCell);

                    const nameCell = document.createElement("td");
                    nameCell.textContent = stock.name;
                    row.appendChild(nameCell);

                    retailers.forEach(r => {
                        const cell = document.createElement("td");
                        cell.textContent = formatStockObject(stock[r]);
                        row.appendChild(cell);
                    });
                    tbody.appendChild(row);

                    const option = document.createElement("option");
                    option.value = stock.productId;
                    option.textContent = `${stock.productId} - ${stock.name}`;
                    ddlProduct.appendChild(option);
                });

            } catch (err) {
                console.error("Error loading stock:", err);
                document.querySelector("#stockTable tbody").innerHTML = '<tr><td colspan="6" class="error">Error loading stock data</td></tr>';
            }
        }

        // Sort restock requests
        function sortRestockRequests(sortOrder) {
            const tbody = document.querySelector("#restockTable tbody");
            const rows = Array.from(tbody.querySelectorAll("tr"));

            if (rows.length === 0 || (rows.length === 1 && rows[0].querySelector('.loading'))) {
                return;
            }

            rows.sort((a, b) => {
                const aTime = a.cells[6].textContent; // Request Time column
                const bTime = b.cells[6].textContent;

                if (sortOrder === 'latest') {
                    return bTime.localeCompare(aTime); // Descending for latest first
                } else {
                    return aTime.localeCompare(bTime); // Ascending for oldest first
                }
            });

            // Clear and re-append sorted rows
            tbody.innerHTML = '';
            rows.forEach(row => tbody.appendChild(row));
        }

        // Load restock requests
        async function loadRestockRequests() {
            try {
                const tbody = document.querySelector("#restockTable tbody");
                tbody.innerHTML = '<tr><td colspan="11" class="loading">Loading restock requests...</td></tr>';

                const res = await fetch("/Handlers/fire_handler.ashx", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ action: "getRestockList" })
                });

                if (!res.ok) {
                    throw new Error(`HTTP error! status: ${res.status}`);
                }

                const data = await res.json();

                console.log("Restock data received:", data);

                if (!data.success) {
                    tbody.innerHTML = `<tr><td colspan="11" class="error">${data.message || "Failed to load restock requests"}</td></tr>`;
                    return;
                }

                tbody.innerHTML = "";

                if (!data.restocks || data.restocks.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="11" class="loading">No restock requests found</td></tr>';
                    document.getElementById("btnSaveRestock").disabled = true;
                    return;
                }

                data.restocks.forEach(restock => {
                    const row = document.createElement("tr");

                    // Store original values for change tracking
                    row.dataset.originalStatus = restock.status || "Pending";
                    row.dataset.originalReviewedBy = restock.reviewedBy || "";
                    row.dataset.originalRemarks = restock.remarks || "";

                    const cells = [
                        restock.restockId || "N/A",
                        restock.productId || "N/A",
                        restock.colour || "N/A",
                        restock.size || "N/A",
                        restock.quantity || 0,
                        restock.storeId || "N/A",
                        restock.requestTime || "N/A",
                        restock.requestedBy || "N/A",
                        restock.status || "Pending",
                        restock.reviewedBy || "",
                        restock.remarks || ""
                    ];

                    cells.forEach((cellText, index) => {
                        const cell = document.createElement("td");

                        // Make only status, reviewedBy, and remarks editable
                        if (index === 8 || index === 9 || index === 10) {
                            cell.className = "editable-cell";
                        } else {
                            // Grey out non-editable cells
                            cell.style.backgroundColor = "#f8f9fa";
                            cell.style.color = "#6c757d";
                        }
                        cell.textContent = cellText;

                        row.appendChild(cell);
                    });

                    tbody.appendChild(row);
                });

                // Apply initial sort
                const sortSelect = document.getElementById("sortRestocks");
                sortRestockRequests(sortSelect.value);

                // Setup inline editing for the newly loaded rows
                setupInlineEditing();

            } catch (err) {
                console.error("Error loading restock requests:", err);
                document.querySelector("#restockTable tbody").innerHTML =
                    '<tr><td colspan="11" class="error">Error loading restock requests: ' + err.message + '</td></tr>';
            }
        }

        // Setup inline editing for restock requests
        function setupInlineEditing() {
            const editableCols = {
                8: ["Pending", "Ordered", "Restocked", "Rejected"], // Status
                9: "text", // Reviewed By
                10: "text" // Remarks
            };

            document.querySelectorAll("#restockTable tbody tr").forEach(row => {
                Object.keys(editableCols).forEach(colIndex => {
                    const cell = row.cells[colIndex];
                    cell.addEventListener("dblclick", () => {
                        if (cell.querySelector("input") || cell.querySelector("select")) return;

                        let editor;
                        if (Array.isArray(editableCols[colIndex])) {
                            editor = document.createElement("select");
                            editableCols[colIndex].forEach(opt => {
                                const option = document.createElement("option");
                                option.value = opt;
                                option.textContent = opt;
                                if (cell.textContent.trim() === opt) option.selected = true;
                                editor.appendChild(option);
                            });
                        } else {
                            editor = document.createElement("input");
                            editor.type = "text";
                            editor.value = cell.textContent.trim();
                            editor.className = "inline-editor";
                        }
                        editor.className = "inline-editor";
                        cell.innerHTML = "";
                        cell.appendChild(editor);
                        editor.focus();

                        editor.addEventListener("blur", () => {
                            cell.textContent = editor.value;
                            checkRestockChanges();
                        });
                        editor.addEventListener("keydown", e => {
                            if (e.key === "Enter") {
                                cell.textContent = editor.value;
                                checkRestockChanges();
                            }
                        });
                    });
                });
            });
        }

        function showToast(message) {
            const toast = document.createElement("div");
            toast.textContent = message;
            toast.style.position = "fixed";
            toast.style.bottom = "20px";
            toast.style.right = "20px";
            toast.style.backgroundColor = "#333";
            toast.style.color = "#fff";
            toast.style.padding = "10px 20px";
            toast.style.borderRadius = "5px";
            toast.style.opacity = "0";
            toast.style.transition = "opacity 0.3s";
            document.body.appendChild(toast);
            setTimeout(() => toast.style.opacity = "1", 50);
            setTimeout(() => { toast.style.opacity = "0"; setTimeout(() => toast.remove(), 500); }, 2000);
        }

        // Submit restock request (using staff ID only)
        document.getElementById("btnSubmitRestock").addEventListener("click", async () => {
            const productId = document.getElementById("ddlProduct").value;
            const retailer = document.getElementById("ddlStore").value;
            const quantity = parseInt(document.getElementById("txtQuantity").value, 10);
            const remarks = document.getElementById("txtRemarks").value.trim();

            if (!productId || !retailer || isNaN(quantity) || quantity <= 0) {
                showToast("Please fill in all required fields correctly!");
                return;
            }

            if (!confirm("Confirm Submission of Restock Request?")) return;

            try {
                const submitBtn = document.getElementById("btnSubmitRestock");
                submitBtn.disabled = true;
                submitBtn.textContent = 'Submitting...';

                // Get staff ID from ASP.NET Session
                const staffId = typeof currentStaffId !== 'undefined' ? currentStaffId : 'S-1';

                const payload = {
                    action: "addRestock",
                    productId: productId,
                    storeId: retailer,
                    quantity: quantity,
                    remarks: remarks,
                    colour: "black",
                    size: "Adults",
                    status: "Pending",
                    reviewedBy: "",
                    requestedBy: staffId // Use staff ID
                };

                console.log("Submitting restock request with staff ID:", staffId);

                const response = await fetch("/Handlers/db_handler.ashx", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload)
                });

                const result = await response.json();

                submitBtn.disabled = false;
                submitBtn.textContent = 'Submit';

                if (result.success) {
                    showToast("Restock request submitted successfully!");
                    document.getElementById("txtQuantity").value = "1";
                    document.getElementById("txtRemarks").value = "";
                    loadRestockRequests();
                } else {
                    showToast("Failed to submit restock request: " + (result.message || "Unknown error"));
                }

            } catch (error) {
                console.error("Error submitting restock request:", error);
                showToast("Error submitting restock request: " + error.message);
                document.getElementById("btnSubmitRestock").disabled = false;
                document.getElementById("btnSubmitRestock").textContent = 'Submit';
            }
        });

        // Get current user from Firebase Auth
        function getCurrentFirebaseUser() {
            return new Promise((resolve) => {
                if (typeof firebase !== 'undefined' && firebase.auth) {
                    const currentUser = firebase.auth().currentUser;
                    if (currentUser) {
                        resolve({
                            uid: currentUser.uid,
                            email: currentUser.email,
                            displayName: currentUser.displayName
                        });
                    } else {
                        // Listen for auth state change in case user is still loading
                        const unsubscribe = firebase.auth().onAuthStateChanged((user) => {
                            unsubscribe();
                            if (user) {
                                resolve({
                                    uid: user.uid,
                                    email: user.email,
                                    displayName: user.displayName
                                });
                            } else {
                                resolve(null);
                            }
                        });
                    }
                } else {
                    resolve(null);
                }
            });
        }

        // Check for changes in restock table
        const checkRestockChanges = () => {
            const rows = document.querySelectorAll("#restockTable tbody tr");
            let hasChanges = false;

            rows.forEach(row => {
                if (!row.dataset.originalStatus) return;

                const status = row.cells[8].textContent.trim();
                const reviewedBy = row.cells[9].textContent.trim();
                const remarks = row.cells[10].textContent.trim();

                if (status !== row.dataset.originalStatus ||
                    reviewedBy !== row.dataset.originalReviewedBy ||
                    remarks !== row.dataset.originalRemarks) {
                    hasChanges = true;
                }
            });

            document.getElementById("btnSaveRestock").disabled = !hasChanges;
        };

        // Save restock changes
        document.getElementById("btnSaveRestock").addEventListener("click", async () => {
            if (!confirm("Are you sure you want to save changes?")) return;

            const rows = document.querySelectorAll("#restockTable tbody tr");
            const changes = [];
            let valid = true;

            // Collect all changes
            rows.forEach(row => {
                const restockId = row.cells[0].textContent.trim();
                const status = row.cells[8].textContent.trim();
                const reviewedBy = row.cells[9].textContent.trim();
                const remarks = row.cells[10].textContent.trim();

                // Validate required fields
                if (!status || !reviewedBy) {
                    valid = false;
                    row.cells[8].style.backgroundColor = "#fdd";
                    row.cells[9].style.backgroundColor = "#fdd";
                } else {
                    row.cells[8].style.backgroundColor = "";
                    row.cells[9].style.backgroundColor = "";
                }

                // Check if values changed
                if (status !== row.dataset.originalStatus ||
                    reviewedBy !== row.dataset.originalReviewedBy ||
                    remarks !== row.dataset.originalRemarks) {
                    changes.push({
                        restockId,
                        status,
                        reviewedBy,
                        remarks
                    });
                }
            });

            if (!valid) {
                showToast("Please fill in all required fields!");
                return;
            }

            if (changes.length === 0) {
                showToast("No changes to save!");
                return;
            }

            try {
                const saveBtn = document.getElementById("btnSaveRestock");
                saveBtn.disabled = true;
                saveBtn.textContent = 'Saving...';

                let savedCount = 0;
                let failedCount = 0;
                const errors = [];

                // Process each change
                for (const change of changes) {
                    try {
                        const payload = {
                            action: "updateRestock",
                            restockId: change.restockId,
                            status: change.status,
                            reviewedBy: change.reviewedBy,
                            remarks: change.remarks
                        };

                        console.log("Saving restock change:", payload);

                        const response = await fetch("/Handlers/db_handler.ashx", {
                            method: "POST",
                            headers: { "Content-Type": "application/json" },
                            body: JSON.stringify(payload)
                        });

                        const result = await response.json();

                        if (result.success) {
                            savedCount++;

                            // Update original data in the row
                            const row = Array.from(rows).find(r => r.cells[0].textContent.trim() === change.restockId);
                            if (row) {
                                row.dataset.originalStatus = change.status;
                                row.dataset.originalReviewedBy = change.reviewedBy;
                                row.dataset.originalRemarks = change.remarks;
                            }
                        } else {
                            failedCount++;
                            errors.push(`${change.restockId}: ${result.message || "Unknown error"}`);
                            console.error("Failed to update restock:", change.restockId, result);
                        }
                    } catch (err) {
                        failedCount++;
                        errors.push(`${change.restockId}: ${err.message}`);
                        console.error("Error updating restock:", change.restockId, err);
                    }
                }

                // Reset button state
                saveBtn.disabled = false;
                saveBtn.textContent = 'Save';

                // Show result message
                let message = `Successfully saved ${savedCount} restock request(s).`;
                if (failedCount > 0) {
                    message += `\n\nFailed to save ${failedCount} restock request(s):\n${errors.join('\n')}`;
                }

                if (failedCount === 0) {
                    showToast(message);
                } else {
                    alert(message);
                }

                // Re-check changes after save
                checkRestockChanges();

            } catch (error) {
                console.error("Error saving changes:", error);
                showToast("Error saving changes: " + error.message);

                // Reset button state
                document.getElementById("btnSaveRestock").disabled = false;
                document.getElementById("btnSaveRestock").textContent = 'Save';
            }
        });

        // Save restock changes
        document.getElementById("btnSaveRestock").addEventListener("click", async () => {
            if (!confirm("Are you sure you want to save changes?")) return;

            const rows = document.querySelectorAll("#restockTable tbody tr");
            const changes = [];
            let valid = true;

            rows.forEach(row => {
                const restockId = row.cells[0].textContent.trim();
                const status = row.cells[8].textContent.trim();
                const reviewedBy = row.cells[9].textContent.trim();
                const remarks = row.cells[10].textContent.trim();

                // Validate required fields
                if (!status || !reviewedBy) {
                    valid = false;
                    row.cells[8].style.backgroundColor = "#fdd";
                    row.cells[9].style.backgroundColor = "#fdd";
                } else {
                    row.cells[8].style.backgroundColor = "";
                    row.cells[9].style.backgroundColor = "";
                }

                // Check if values changed
                if (status !== row.dataset.originalStatus ||
                    reviewedBy !== row.dataset.originalReviewedBy ||
                    remarks !== row.dataset.originalRemarks) {
                    changes.push({
                        restockId,
                        status,
                        reviewedBy,
                        remarks
                    });
                }
            });

            if (!valid) {
                showToast("Please fill in all required fields!");
                return;
            }

            if (changes.length === 0) {
                showToast("No changes to save!");
                return;
            }

            try {
                // Here you would send the changes to your backend
                // For now, we'll update the local data and show success
                changes.forEach(change => {
                    const row = Array.from(rows).find(r => r.cells[0].textContent.trim() === change.restockId);
                    if (row) {
                        row.dataset.originalStatus = change.status;
                        row.dataset.originalReviewedBy = change.reviewedBy;
                        row.dataset.originalRemarks = change.remarks;
                    }
                });

                document.getElementById("btnSaveRestock").disabled = true;
                showToast("Changes saved successfully!");

            } catch (error) {
                console.error("Error saving changes:", error);
                showToast("Error saving changes!");
            }
        });

        // Sort restock requests when dropdown changes
        document.getElementById("sortRestocks").addEventListener("change", (e) => {
            sortRestockRequests(e.target.value);
        });

        // Initialize page
        document.addEventListener("DOMContentLoaded", () => {
            loadStock();
            loadRestockRequests();
        });
    </script>
</asp:Content>
