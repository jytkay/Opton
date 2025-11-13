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
            border: 1px solid #ccc; /* grey border */
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

        #buttonsRight button {
            margin-left: 8px;
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

        select.inline-editor {
            width: 100%;
            padding: 2px;
        }

        input.inline-editor {
            width: 100%;
            padding: 2px;
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
                        <tbody></tbody>
                    </table>
                </div>

                <div class="restock-input-wrapper">
                    <h4>Request to Restock</h4>
                    <label for="ddlProduct">Product</label>
                    <select id="ddlProduct"></select>

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
            <div id="buttonsRight">
                <button type="button" id="btnSaveRestock" disabled>Save</button>
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
                    <!-- Hardcoded rows (same as before) -->
                    <tr>
                        <td>RE-1</td>
                        <td>P-5</td>
                        <td>black</td>
                        <td>Adults</td>
                        <td>7</td>
                        <td>S-1</td>
                        <td>2025-10-01, 9:15</td>
                        <td>S-1</td>
                        <td>Ordered</td>
                        <td>S-2</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-2</td>
                        <td>P-4</td>
                        <td>black</td>
                        <td>Adults</td>
                        <td>9</td>
                        <td>S-2</td>
                        <td>2025-10-01, 10:20</td>
                        <td>S-2</td>
                        <td>Ordered</td>
                        <td>S-3</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-3</td>
                        <td>P-3</td>
                        <td>brown</td>
                        <td>Adults</td>
                        <td>9</td>
                        <td>S-3</td>
                        <td>2025-10-01, 11:05</td>
                        <td>S-3</td>
                        <td>Ordered</td>
                        <td>S-1</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-4</td>
                        <td>P-7</td>
                        <td>black</td>
                        <td>Adults</td>
                        <td>6</td>
                        <td>S-1</td>
                        <td>2025-10-02, 9:50</td>
                        <td>S-4</td>
                        <td>Ordered</td>
                        <td>S-5</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-5</td>
                        <td>P-10</td>
                        <td>black</td>
                        <td>Adults</td>
                        <td>6</td>
                        <td>S-3</td>
                        <td>2025-10-02, 10:40</td>
                        <td>S-5</td>
                        <td>Ordered</td>
                        <td>S-2</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-6</td>
                        <td>P-6</td>
                        <td>white</td>
                        <td>Kids</td>
                        <td>8</td>
                        <td>S-2</td>
                        <td>2025-10-02, 11:25</td>
                        <td>S-1</td>
                        <td>Ordered</td>
                        <td>S-3</td>
                        <td>Stock damaged during transport</td>
                    </tr>
                    <tr>
                        <td>RE-7</td>
                        <td>P-12</td>
                        <td>pink</td>
                        <td>Kids</td>
                        <td>8</td>
                        <td>S-1</td>
                        <td>2025-10-03, 9:30</td>
                        <td>S-2</td>
                        <td>Ordered</td>
                        <td>S-4</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-8</td>
                        <td>P-1</td>
                        <td>silver</td>
                        <td>Adults</td>
                        <td>18</td>
                        <td>S-2</td>
                        <td>2025-10-03, 10:15</td>
                        <td>S-3</td>
                        <td>Ordered</td>
                        <td>S-5</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-9</td>
                        <td>P-2</td>
                        <td>white</td>
                        <td>Adults</td>
                        <td>10</td>
                        <td>S-2</td>
                        <td>2025-10-03, 11:00</td>
                        <td>S-1</td>
                        <td>Ordered</td>
                        <td>S-2</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-10</td>
                        <td>P-13</td>
                        <td>black</td>
                        <td>Adults</td>
                        <td>6</td>
                        <td>S-3</td>
                        <td>2025-10-04, 9:45</td>
                        <td>S-4</td>
                        <td>Ordered</td>
                        <td>S-1</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-11</td>
                        <td>P-16</td>
                        <td>black</td>
                        <td>Adults</td>
                        <td>8</td>
                        <td>S-2</td>
                        <td>2025-10-04, 10:30</td>
                        <td>S-5</td>
                        <td>Ordered</td>
                        <td>S-3</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-12</td>
                        <td>P-20</td>
                        <td>black</td>
                        <td>Adults</td>
                        <td>7</td>
                        <td>S-1</td>
                        <td>2025-10-04, 11:15</td>
                        <td>S-2</td>
                        <td>Ordered</td>
                        <td>S-4</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-13</td>
                        <td>P-22</td>
                        <td>black</td>
                        <td>Kids</td>
                        <td>8</td>
                        <td>S-3</td>
                        <td>2025-10-05, 9:20</td>
                        <td>S-3</td>
                        <td>Ordered</td>
                        <td>S-1</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-14</td>
                        <td>P-23</td>
                        <td>black</td>
                        <td>Adults</td>
                        <td>8</td>
                        <td>S-1</td>
                        <td>2025-10-05, 10:05</td>
                        <td>S-1</td>
                        <td>Ordered</td>
                        <td>S-5</td>
                        <td></td>
                    </tr>
                    <tr>
                        <td>RE-15</td>
                        <td>P-25</td>
                        <td>black</td>
                        <td>Adults</td>
                        <td>11</td>
                        <td>S-2</td>
                        <td>2025-10-05, 11:00</td>
                        <td>S-4</td>
                        <td>Ordered</td>
                        <td>S-2</td>
                        <td></td>
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
                tbody.innerHTML = "";
                ddlProduct.innerHTML = "";

                if (!data.stockList) return;

                const validStock = data.stockList.filter(s => s.productId && s.name && retailers.some(r => s[r] && Object.keys(s[r]).length > 0));
                validStock.sort((a, b) => naturalCompare(a.productId, b.productId));

                validStock.forEach(stock => {
                    const row = document.createElement("tr");
                    const pidCell = document.createElement("td"); pidCell.textContent = stock.productId; row.appendChild(pidCell);
                    const nameCell = document.createElement("td"); nameCell.textContent = stock.name; row.appendChild(nameCell);
                    retailers.forEach(r => {
                        const cell = document.createElement("td");
                        cell.textContent = formatStockObject(stock[r]);
                        row.appendChild(cell);
                    });
                    tbody.appendChild(row);

                    const option = document.createElement("option");
                    option.value = stock.productId;
                    option.textContent = stock.productId;
                    ddlProduct.appendChild(option);
                });

            } catch (err) { console.error("Error loading stock:", err); }
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

        document.getElementById("btnSubmitRestock").addEventListener("click", () => {
            if (!confirm("Confirm Submission of Restock Request?")) return;

            const productId = document.getElementById("ddlProduct").value;
            const retailer = document.getElementById("ddlStore").value;
            const quantity = parseInt(document.getElementById("txtQuantity").value, 10);
            const remarks = document.getElementById("txtRemarks").value.trim();

            if (!productId || !retailer || isNaN(quantity) || quantity <= 0) {
                showToast("Please fill in all required fields correctly!");
                return;
            }

            showToast("Request Submitted!");
            document.getElementById("txtQuantity").value = "1";
            document.getElementById("txtRemarks").value = "";
        });

        // Inline editing for Restock Requests
        const editableCols = { 8: ["Ordered", "Restocked", "Rejected"], 9: "text", 10: "text" }; // Status, Reviewed By, Remarks
        document.querySelectorAll("#restockTable tbody tr").forEach(row => {
            // Store original values
            row.dataset.originalStatus = row.cells[8].textContent.trim();
            row.dataset.originalReviewedBy = row.cells[9].textContent.trim();
            row.dataset.originalRemarks = row.cells[10].textContent.trim();

            Object.keys(editableCols).forEach(colIndex => {
                const cell = row.cells[colIndex];
                cell.addEventListener("dblclick", () => {
                    if (cell.querySelector("input") || cell.querySelector("select")) return;
                    let editor;
                    if (Array.isArray(editableCols[colIndex])) {
                        editor = document.createElement("select");
                        editableCols[colIndex].forEach(opt => {
                            const option = document.createElement("option");
                            option.value = opt; option.textContent = opt;
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

        // Save Restock Changes
        document.getElementById("btnSaveRestock").addEventListener("click", () => {
            if (!confirm("Are you sure you want to save changes?")) return;

            const rows = document.querySelectorAll("#restockTable tbody tr");
            const changes = [];
            let valid = true;
            let hasChanges = false;

            rows.forEach(row => {
                const restockId = row.cells[0].textContent.trim();
                const status = row.cells[8].textContent.trim();
                const reviewedBy = row.cells[9].textContent.trim();
                const remarks = row.cells[10].textContent.trim();

                // Store original values if not already stored
                if (!row.dataset.originalStatus) {
                    row.dataset.originalStatus = status;
                    row.dataset.originalReviewedBy = reviewedBy;
                    row.dataset.originalRemarks = remarks;
                }

                // Check if values changed
                if (status !== row.dataset.originalStatus ||
                    reviewedBy !== row.dataset.originalReviewedBy ||
                    remarks !== row.dataset.originalRemarks) {
                    hasChanges = true;
                }

                if (!status || !reviewedBy) {
                    valid = false;
                    row.cells[8].style.backgroundColor = "#fdd";
                    row.cells[9].style.backgroundColor = "#fdd";
                } else {
                    row.cells[8].style.backgroundColor = "";
                    row.cells[9].style.backgroundColor = "";
                }

                changes.push({
                    restockId,
                    status,
                    reviewedBy,
                    remarks
                });
            });

            if (!valid) {
                showToast("Please fill in all required fields!");
                return;
            }

            if (!hasChanges) {
                showToast("No changes to save!");
                return;
            }

            // Update the stored original values
            rows.forEach(row => {
                row.dataset.originalStatus = row.cells[8].textContent.trim();
                row.dataset.originalReviewedBy = row.cells[9].textContent.trim();
                row.dataset.originalRemarks = row.cells[10].textContent.trim();
            });

            // Disable save button since there are no unsaved changes
            document.getElementById("btnSaveRestock").disabled = true;

            console.log("Saved changes:", changes);
            showToast("Changes saved successfully!");
        });

        // Add this new code to enable the save button when changes are made
        const restockTable = document.getElementById("restockTable");
        const btnSaveRestock = document.getElementById("btnSaveRestock");

        // Track changes in restock table
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

            btnSaveRestock.disabled = !hasChanges;
        };

        loadStock();
    </script>
</asp:Content>
