<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="appointments.aspx.cs" Inherits="Opton.Pages.Worker.appointments" MasterPageFile="~/Site.Master" %>

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
            justify-content: space-between;
            align-items: center;
        }

        #buttonsLeft select {
            padding: 6px 12px;
            font-size: 14px;
            border-radius: 8px;
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

        #appointmentsGrid {
            width: 90%;
            margin: 0 auto 30px auto;
        }

        .appointment-card {
            border: 1px solid #ccc;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 16px;
            background: #fff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            position: relative;
        }

        .appointment-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
            padding-bottom: 12px;
            border-bottom: 1px solid #eee;
        }

        .appointment-id {
            font-size: 1.2em;
            font-weight: bold;
            color: var(--color-dark);
        }

        .appointment-status {
            padding: 6px 12px;
            border-radius: 16px;
            font-weight: bold;
            min-width: 100px;
            text-align: center;
            font-size: 13px;
        }

        .status-Booked {
            background-color: #AED6F1;
            color: #03396C;
        }

        .status-Completed {
            background-color: #b3e6b3;
            color: #2e8b57;
        }

        .status-Cancelled {
            background-color: #f5cccc;
            color: #c0392b;
        }

        .appointment-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 12px;
        }

        .appointment-section {
            margin-bottom: 12px;
        }

        .section-title {
            font-weight: bold;
            color: var(--color-dark);
            margin-bottom: 6px;
            font-size: 14px;
        }

        .customer-info {
            background: #f8f9fa;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 12px;
            font-size: 13px;
        }

        .info-card {
            background: white;
            padding: 10px;
            margin-bottom: 8px;
            border-radius: 6px;
            border-left: 3px solid var(--color-accent);
            font-size: 13px;
        }

        .info-header {
            display: flex;
            justify-content: space-between;
            font-weight: bold;
            margin-bottom: 6px;
        }

        .info-details {
            font-size: 13px;
            color: #666;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 4px;
            padding: 1px 0;
        }

        .editable-field {
            border-bottom: 1px dotted #888;
            cursor: text;
            padding: 2px 4px;
            min-width: 60px;
            display: inline-block;
            font-size: 13px;
        }

        .editable-field:focus {
            outline: none;
            background: #ffffcc;
            border-bottom: 1px solid #007bff;
        }

        .empty-field {
            color: #999;
            font-style: italic;
        }

        .cancel-reason-section {
            background: #fff0f0;
            padding: 10px;
            border-radius: 6px;
            margin-top: 10px;
            border-left: 3px solid #dc3545;
        }

        .cancel-reason-input {
            width: 100%;
            padding: 6px 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 13px;
            margin-top: 5px;
            display: none;
        }

        .cancel-reason-input.show {
            display: block;
        }

        .compact-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 4px;
        }

        .compact-label {
            font-weight: 600;
            color: #666;
            min-width: 80px;
        }

        .compact-value {
            flex: 1;
            text-align: right;
        }

        @media (max-width: 768px) {
            .appointment-details {
                grid-template-columns: 1fr;
            }
            
            .appointment-header {
                flex-direction: column;
                gap: 8px;
            }
            
            .appointment-status {
                align-self: flex-start;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div id="searchContainer">
        <div id="searchWrapper">
            <input type="text" id="searchBar" placeholder="Search appointments..." />
            <i id="searchIcon" class="ri-search-line"></i>
        </div>
    </div>

    <div id="buttonsContainer">
        <div id="buttonsLeft" style="display: flex; gap: 10px;">
            <select id="statusFilter">
                <option value="">All Statuses</option>
                <option value="Booked">Booked</option>
                <option value="Completed">Completed</option>
                <option value="Cancelled">Cancelled</option>
            </select>
            <select id="sortOrder">
                <option value="latest">Sort: Latest First</option>
                <option value="oldest">Sort: Oldest First</option>
            </select>
        </div>
        <div id="buttonsRight">
            <button type="button" id="saveChangesBtn" disabled>Save Changes</button>
        </div>
    </div>

    <div id="appointmentsGrid">
        <p>Loading appointments...</p>
    </div>

    <script>
        let appointments = [];
        let originalData = {};
        let editedData = {};
        const saveBtn = document.getElementById('saveChangesBtn');
        const statusFilter = document.getElementById('statusFilter');
        const searchBar = document.getElementById('searchBar');
        const sortOrder = document.getElementById('sortOrder');

        // Helper function to format date
        function formatDate(dateValue) {
            if (!dateValue) return 'Not set';

            try {
                let date;
                if (dateValue.seconds) {
                    // Firestore timestamp
                    date = new Date(dateValue.seconds * 1000);
                } else if (typeof dateValue === 'string') {
                    date = new Date(dateValue);
                } else {
                    date = new Date(dateValue);
                }

                if (isNaN(date.getTime())) return 'Invalid date';

                return date.toLocaleString('en-MY', {
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: true
                });
            } catch (e) {
                return 'Invalid date';
            }
        }

        // Parse prescription data for compact display - UPDATED FOR NEW STRUCTURE
        function parsePrescription(prescription) {
            if (!prescription || typeof prescription !== 'object') return '';

            console.log('Prescription data:', prescription);

            const parts = [];

            // Handle new structure: {"Prescription":{"Far":{"left":"-0.5","right":"-0.5"}}}
            if (prescription.Prescription && typeof prescription.Prescription === 'object') {
                const presData = prescription.Prescription;

                if (presData.Far && typeof presData.Far === 'object') {
                    const left = presData.Far.left || '';
                    const right = presData.Far.right || '';
                    if (left || right) parts.push(`Far: L${left} R${right}`);
                }

                if (presData.Near && typeof presData.Near === 'object') {
                    const left = presData.Near.left || '';
                    const right = presData.Near.right || '';
                    if (left || right) parts.push(`Near: L${left} R${right}`);
                }

                if (presData.Reading && typeof presData.Reading === 'object') {
                    const left = presData.Reading.left || '';
                    const right = presData.Reading.right || '';
                    if (left || right) parts.push(`Reading: L${left} R${right}`);
                }
            }

            // Handle old structure as fallback
            if (parts.length === 0) {
                if (prescription.Near && typeof prescription.Near === 'object') {
                    const left = prescription.Near.left || prescription.Near.Left || '';
                    const right = prescription.Near.right || prescription.Near.Right || '';
                    if (left || right) parts.push(`Near: L${left} R${right}`);
                }

                if (prescription.Reading && typeof prescription.Reading === 'object') {
                    const left = prescription.Reading.left || prescription.Reading.Left || '';
                    const right = prescription.Reading.right || prescription.Reading.Right || '';
                    if (left || right) parts.push(`Reading: L${left} R${right}`);
                }

                if (prescription.Far && typeof prescription.Far === 'object') {
                    const left = prescription.Far.left || prescription.Far.Left || '';
                    const right = prescription.Far.right || prescription.Far.Right || '';
                    if (left || right) parts.push(`Far: L${left} R${right}`);
                }
            }

            return parts.length > 0 ? parts.join(' | ') : '';
        }

        // Parse hold item data for compact display - UPDATED FOR NEW STRUCTURE
        function parseHoldItem(holdItem) {
            if (!holdItem || typeof holdItem !== 'object') return '';

            console.log('Hold item data:', holdItem);

            const parts = [];

            // Handle new structure: {"P-7":{"Adults":"black"},"P-3":{"Adults":"black"}}
            if (Object.keys(holdItem).some(key => key.startsWith('P-'))) {
                // It's the new structure with product IDs as keys
                Object.entries(holdItem).forEach(([productId, itemData]) => {
                    if (typeof itemData === 'object') {
                        let itemDesc = productId;
                        // Extract size and color
                        for (const [size, color] of Object.entries(itemData)) {
                            if (size !== 'package' && size !== 'addOn' && size !== 'prescription') {
                                itemDesc += ` (${size}: ${color})`;
                            }
                        }
                        parts.push(itemDesc);
                    }
                });
            }
            // Handle old structure as fallback
            else if (holdItem.productId) {
                parts.push(holdItem.productId);
                if (holdItem.color) parts.push(holdItem.color);
                if (holdItem.size) parts.push(holdItem.size);
            }

            return parts.length > 0 ? parts.join(' • ') : '';
        }

        // Load appointments from server
        async function loadAppointments() {
            const contentDiv = document.getElementById('appointmentsGrid');
            contentDiv.innerHTML = '<p>Loading appointments...</p>';

            try {
                const res = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: "getAppointmentsList" })
                });

                const data = await res.json();

                if (!data.success || !data.appointments?.length) {
                    contentDiv.innerHTML = '<p>No appointments found.</p>';
                    return;
                }

                appointments = data.appointments;
                originalData = {};
                appointments.forEach(a => {
                    originalData[a.appointmentId] = JSON.parse(JSON.stringify(a));
                });

                renderAppointmentCards(appointments);
            } catch (err) {
                console.error('Error loading appointments:', err);
                contentDiv.innerHTML = `<p>Error loading appointments: ${err.message}</p>`;
            }
        }

        // Check if field has changes
        function hasChanges(appointmentId, field, newValue) {
            const original = originalData[appointmentId]?.[field] || '';
            return original.toString().trim() !== newValue.trim();
        }

        // Render appointment cards
        function renderAppointmentCards(data) {
            const container = document.getElementById('appointmentsGrid');
            container.innerHTML = '';

            const searchTerm = searchBar.value.trim().toLowerCase();
            const filterVal = statusFilter.value;

            let filteredData = data.filter(appointment => {
                // Status filter
                if (filterVal && appointment.status !== filterVal) return false;

                // Search filter
                if (!searchTerm) return true;

                const searchFields = [
                    appointment.appointmentId,
                    appointment.email,
                    appointment.name,
                    appointment.phoneNo,
                    appointment.type,
                    appointment.remarks,
                    appointment.staffId
                ];

                return searchFields.some(field =>
                    field && field.toString().toLowerCase().includes(searchTerm)
                );
            });

            // Sort data
            const sortVal = sortOrder.value;
            filteredData.sort((a, b) => {
                const dateA = new Date(a.dateTime);
                const dateB = new Date(b.dateTime);
                return sortVal === 'latest' ? dateB - dateA : dateA - dateB;
            });

            if (!filteredData.length) {
                container.innerHTML = '<p>No appointments found.</p>';
                return;
            }

            filteredData.forEach(appointment => {
                const card = document.createElement('div');
                card.className = 'appointment-card';
                card.dataset.appointmentId = appointment.appointmentId;

                // Debug logging
                console.log('Appointment data:', appointment);
                console.log('Prescription raw:', appointment.prescription);
                console.log('Hold item raw:', appointment.holdItem);

                // Determine status class
                let statusClass = '';
                const status = appointment.status || '';
                switch (status.toLowerCase()) {
                    case 'booked': statusClass = 'status-Booked'; break;
                    case 'completed': statusClass = 'status-Completed'; break;
                    case 'cancelled': statusClass = 'status-Cancelled'; break;
                    default: statusClass = 'status-Booked';
                }

                // Create editable field
                const makeEditable = (field, value, type = 'text') => {
                    const isEmpty = !value || value.toString().trim() === '';

                    if (type === 'select') {
                        const options = {
                            status: ['Booked', 'Completed', 'Cancelled'],
                            staffId: ['S-1', 'S-2', 'S-3', 'S-4', 'S-5']
                        }[field] || [];

                        let optsHtml = options.map(opt =>
                            `<option value="${opt}" ${opt === value ? 'selected' : ''}>${opt}</option>`
                        ).join('');
                        return `<select class="editable-field" data-field="${field}">${optsHtml}</select>`;
                    } else {
                        const displayValue = isEmpty ? 'Click to edit' : value;
                        return `<span class="editable-field ${isEmpty ? 'empty-field' : ''}" data-field="${field}" contenteditable="true">${displayValue}</span>`;
                    }
                };

                // Build prescription and hold item display
                const prescriptionText = parsePrescription(appointment.prescription);
                const holdItemText = parseHoldItem(appointment.holdItem);

                console.log('Parsed prescription:', prescriptionText);
                console.log('Parsed hold item:', holdItemText);

                card.innerHTML = `
                    <div class="appointment-header">
                        <div>
                            <div class="appointment-id">${appointment.appointmentId || 'No ID'}</div>
                            <div style="color: #666; font-size: 12px; margin-top: 2px;">
                                ${formatDate(appointment.dateTime)} • ${appointment.type || ''}
                            </div>
                        </div>
                        <div class="appointment-status ${statusClass}">
                            ${makeEditable('status', appointment.status, 'select')}
                        </div>
                    </div>

                    <div class="customer-info">
                        <div class="compact-row">
                            <span class="compact-label">Customer:</span>
                            <span class="compact-value">${appointment.name || 'N/A'} • ${appointment.phoneNo || 'N/A'}</span>
                        </div>
                        <div class="compact-row">
                            <span class="compact-label">Email:</span>
                            <span class="compact-value">${appointment.email || 'N/A'}</span>
                        </div>
                    </div>

                    <div class="appointment-details">
                        <div class="appointment-section">
                            <div class="info-card">
                                <div class="compact-row">
                                    <span class="compact-label">Store:</span>
                                    <span class="compact-value">${appointment.storeId || 'N/A'}</span>
                                </div>
                                ${appointment.details ? `
                                <div class="compact-row">
                                    <span class="compact-label">Details:</span>
                                    <span class="compact-value" style="text-align: left; font-size: 12px;">${appointment.details}</span>
                                </div>
                                ` : ''}
                                ${prescriptionText ? `
                                <div class="compact-row">
                                    <span class="compact-label">Prescription:</span>
                                    <span class="compact-value" style="text-align: left; font-size: 12px;">${prescriptionText}</span>
                                </div>
                                ` : ''}
                                ${holdItemText ? `
                                <div class="compact-row">
                                    <span class="compact-label">Hold Item:</span>
                                    <span class="compact-value" style="text-align: left; font-size: 12px;">${holdItemText}</span>
                                </div>
                                ` : ''}
                            </div>
                        </div>

                        <div class="appointment-section">
                            <div class="info-card">
                                <div class="compact-row">
                                    <span class="compact-label">Staff:</span>
                                    <span class="compact-value">${makeEditable('staffId', appointment.staffId, 'select')}</span>
                                </div>
                                ${appointment.remarks ? `
                                <div class="compact-row">
                                    <span class="compact-label">Remarks:</span>
                                    <span class="compact-value" style="text-align: left; font-size: 12px;">${appointment.remarks}</span>
                                </div>
                                ` : ''}
                            </div>
                        </div>
                    </div>

                    <div class="cancel-reason-section" id="cancel-reason-${appointment.appointmentId}" style="display: ${appointment.status === 'Cancelled' ? 'block' : 'none'}">
                        <div class="section-title">Cancel Reason</div>
                        <div>
                            <span class="editable-field ${!appointment.cancelReason ? 'empty-field' : ''}" 
                                  data-field="cancelReason" 
                                  contenteditable="true"
                                  style="display: ${appointment.cancelReason ? 'inline-block' : 'none'}">
                                ${appointment.cancelReason || 'Click to edit'}
                            </span>
                            <input type="text" 
                                   class="cancel-reason-input" 
                                   placeholder="Enter cancel reason..."
                                   value="${appointment.cancelReason || ''}"
                                   style="display: ${!appointment.cancelReason ? 'block' : 'none'}">
                        </div>
                    </div>
                `;

                // Add event listeners for editable fields
                const statusSelect = card.querySelector('select[data-field="status"]');
                const cancelReasonSection = card.querySelector(`#cancel-reason-${appointment.appointmentId}`);
                const cancelReasonSpan = card.querySelector('span[data-field="cancelReason"]');
                const cancelReasonInput = card.querySelector('.cancel-reason-input');

                // Status change handler
                statusSelect.addEventListener('change', function () {
                    const isCancelled = this.value === 'Cancelled';
                    cancelReasonSection.style.display = isCancelled ? 'block' : 'none';

                    if (isCancelled && !appointment.cancelReason) {
                        cancelReasonSpan.style.display = 'none';
                        cancelReasonInput.style.display = 'block';
                        cancelReasonInput.focus();
                    }

                    updateEditedData(appointment.appointmentId, 'status', this.value);
                });

                // Cancel reason input handlers
                if (cancelReasonInput) {
                    cancelReasonInput.addEventListener('input', function () {
                        updateEditedData(appointment.appointmentId, 'cancelReason', this.value);
                    });

                    cancelReasonInput.addEventListener('blur', function () {
                        if (this.value.trim()) {
                            cancelReasonSpan.textContent = this.value.trim();
                            cancelReasonSpan.style.display = 'inline-block';
                            this.style.display = 'none';
                            cancelReasonSpan.classList.remove('empty-field');
                        }
                    });
                }

                if (cancelReasonSpan) {
                    cancelReasonSpan.addEventListener('focus', function () {
                        if (this.textContent === 'Click to edit') {
                            this.textContent = '';
                            this.classList.remove('empty-field');
                        }
                    });

                    cancelReasonSpan.addEventListener('blur', function () {
                        updateEditedData(appointment.appointmentId, 'cancelReason', this.textContent.trim());
                        if (!this.textContent.trim()) {
                            this.textContent = 'Click to edit';
                            this.classList.add('empty-field');
                        }
                    });
                }

                // Staff selection handler
                const staffSelect = card.querySelector('select[data-field="staffId"]');
                if (staffSelect) {
                    staffSelect.addEventListener('change', function () {
                        updateEditedData(appointment.appointmentId, 'staffId', this.value);
                    });
                }

                container.appendChild(card);
            });
        }

        // Update edited data
        function updateEditedData(appointmentId, field, newValue) {
            // Don't save "Click to edit" as value
            if (newValue === 'Click to edit') {
                newValue = '';
            }

            if (hasChanges(appointmentId, field, newValue)) {
                editedData[appointmentId] = editedData[appointmentId] || {};
                editedData[appointmentId][field] = newValue;
            } else {
                if (editedData[appointmentId]) {
                    delete editedData[appointmentId][field];
                    if (Object.keys(editedData[appointmentId]).length === 0) {
                        delete editedData[appointmentId];
                    }
                }
            }

            saveBtn.disabled = Object.keys(editedData).length === 0;
        }

        // Save changes
        saveBtn.onclick = async () => {
            if (!confirm("Are you sure you want to save all changes?")) return;

            saveBtn.disabled = true;
            saveBtn.textContent = 'Saving...';

            try {
                let savedCount = 0;
                let failedCount = 0;
                const errors = [];

                // Process each edited appointment
                for (const appointmentId in editedData) {
                    try {
                        const changes = editedData[appointmentId];
                        const originalAppointment = originalData[appointmentId];

                        // Prepare payload for db_handler
                        const payload = {
                            action: 'updateAppointment',
                            appointmentId: appointmentId
                        };

                        // Add all fields from original appointment (to maintain structure)
                        // Then override with edited fields
                        const fieldsToSend = [
                            'storeId', 'userId', 'email', 'name', 'phoneNo',
                            'details', 'type', 'remarks', 'status',
                            'staffId', 'cancelReason'
                        ];

                        fieldsToSend.forEach(field => {
                            if (changes.hasOwnProperty(field)) {
                                payload[field] = changes[field];
                            } else if (originalAppointment.hasOwnProperty(field)) {
                                payload[field] = originalAppointment[field];
                            }
                        });

                        // Handle dateTime specially
                        if (originalAppointment.dateTime) {
                            // Convert to ISO UTC string
                            let dateTime;
                            if (originalAppointment.dateTime.seconds) {
                                dateTime = new Date(originalAppointment.dateTime.seconds * 1000);
                            } else {
                                dateTime = new Date(originalAppointment.dateTime);
                            }
                            payload.dateTime = dateTime.toISOString();
                        }

                        // Include prescription and holdItem (preserve structure)
                        if (originalAppointment.prescription) {
                            payload.prescription = JSON.stringify(originalAppointment.prescription);
                        }
                        if (originalAppointment.holdItem) {
                            payload.holdItem = JSON.stringify(originalAppointment.holdItem);
                        }

                        console.log('Updating appointment:', appointmentId, payload);

                        // Send to db_handler
                        const response = await fetch('/Handlers/db_handler.ashx', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify(payload)
                        });

                        const result = await response.json();

                        if (result.success) {
                            savedCount++;

                            // Update local data
                            if (originalData[appointmentId]) {
                                Object.assign(originalData[appointmentId], changes);
                            }
                            const appointment = appointments.find(a => a.appointmentId === appointmentId);
                            if (appointment) {
                                Object.assign(appointment, changes);
                            }
                        } else {
                            failedCount++;
                            errors.push(`${appointmentId}: ${result.message || 'Unknown error'}`);
                            console.error('Failed to update appointment:', appointmentId, result);
                        }
                    } catch (err) {
                        failedCount++;
                        errors.push(`${appointmentId}: ${err.message}`);
                        console.error('Error updating appointment:', appointmentId, err);
                    }
                }

                // Clear edited data
                editedData = {};
                saveBtn.disabled = true;
                saveBtn.textContent = 'Save Changes';

                // Re-render to show updated data
                renderAppointmentCards(appointments);

                // Show result message
                let message = `Successfully saved ${savedCount} appointment(s).`;
                if (failedCount > 0) {
                    message += `\n\nFailed to save ${failedCount} appointment(s):\n${errors.join('\n')}`;
                }
                alert(message);

            } catch (error) {
                console.error('Error saving changes:', error);
                alert("Error saving changes: " + error.message);
                saveBtn.disabled = Object.keys(editedData).length === 0;
                saveBtn.textContent = 'Save Changes';
            }
        };

        // Event listeners for filtering and sorting
        statusFilter.addEventListener('change', () => renderAppointmentCards(appointments));
        searchBar.addEventListener('input', () => renderAppointmentCards(appointments));
        sortOrder.addEventListener('change', () => renderAppointmentCards(appointments));

        // Load appointments on page load
        loadAppointments();
    </script>
</asp:Content>