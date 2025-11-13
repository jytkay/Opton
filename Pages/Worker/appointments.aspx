<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="appointments.aspx.cs" Inherits="Opton.Pages.Worker.appointments" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <style>
        :root {
            --color-dark: #333;
            --color-accent: #007bff;
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
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border: 1px solid #ccc;
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 16px;
            background: #fff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            position: relative;
            transition: background 0.2s ease;
        }

            .appointment-card.past-appointment {
                background: #f0f0f0;
            }

        .appointment-id {
            font-size: 1.2em;
            font-weight: bold;
        }

        .appointment-status {
            padding: 6px 12px;
            border-radius: 12px;
            font-weight: bold;
            min-width: 130px;
            text-align: center;
            height: fit-content;
        }

        .status-Booked {
            background-color: #AED6F1;
            color: #03396C;
        }

        .status-Completed {
            background-color: #d4f0d4;
            color: #080;
        }

        .status-Cancelled {
            background-color: #f5cccc;
            color: #900;
        }

        .editable-field {
            border-bottom: 1px dotted #888;
            cursor: text;
        }

            .editable-field:focus {
                outline: none;
                background: #ffffcc;
            }

            .editable-field.empty:before {
                content: "Click to edit";
                color: #888;
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
            <button type="button" id="saveChangesBtn" disabled>Save</button>
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

        async function loadAppointments() {
            const container = document.getElementById('appointmentsGrid');
            container.innerHTML = '<p>Loading appointments...</p>';
            try {
                const res = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: "getAppointmentsList" })
                });
                const data = await res.json();
                if (!data.success || !data.appointments?.length) {
                    container.innerHTML = '<p>No appointments found.</p>';
                    return;
                }
                appointments = data.appointments;
                originalData = {};
                appointments.forEach(a => originalData[a.appointmentId] = JSON.parse(JSON.stringify(a)));
                renderAppointmentCards(appointments);
            } catch (err) {
                container.innerHTML = `<p>Error loading appointments: ${err.message}</p>`;
            }
        }

        function hasChanges(appointmentId, field, newValue) {
            const original = originalData[appointmentId]?.[field] || '';
            return original.toString().trim() !== newValue.toString().trim();
        }

        function renderAppointmentCards(data) {
            const container = document.getElementById('appointmentsGrid');
            container.innerHTML = '';
            const searchTerm = searchBar.value.trim().toLowerCase();
            const filterValStr = String(statusFilter.value || '').toLowerCase();
            const sortVal = sortOrder.value;

            let filteredData = data.filter(app => {
                const statusStr = String(app.status || '').toLowerCase();

                if (filterValStr && statusStr !== filterValStr) return false;
                if (!searchTerm) return true;

                // Format date like the card
                const formattedDate = new Intl.DateTimeFormat('en-US', {
                    weekday: 'long', year: 'numeric', month: 'short', day: 'numeric',
                    hour: '2-digit', minute: '2-digit', hour12: false
                }).format(new Date(app.dateTime)).toLowerCase();

                return (
                    String(app.email || '').toLowerCase().includes(searchTerm) ||
                    String(app.name || '').toLowerCase().includes(searchTerm) ||
                    String(app.phoneNo || '').toLowerCase().includes(searchTerm) ||
                    formattedDate.includes(searchTerm)   // <-- search by displayed date
                );
            });

            filteredData.sort((a, b) => {
                const dateA = new Date(a.dateTime);
                const dateB = new Date(b.dateTime);
                return sortVal === 'latest' ? dateB - dateA : dateA - dateB;
            });

            if (!filteredData.length) {
                container.innerHTML = '<p>No appointments found.</p>';
                return;
            }

            function isNonEmptyObject(obj) {
                return obj && typeof obj === 'object' && Object.keys(obj).length > 0;
            }

            const now = new Date();
            filteredData.forEach(app => {
                const card = document.createElement('div');
                card.className = 'appointment-card';
                const appDate = new Date(app.dateTime);
                if (appDate < now) card.classList.add('past-appointment');

                const makeEditable = (field, value) => {
                    if (!['status', 'staffId', 'cancelReason'].includes(field)) return `<span>${value || ''}</span>`;

                    if (field === 'status') {
                        return `<select class="editable-field" data-field="status">${['Booked', 'Completed', 'Cancelled'].map(opt => `<option value="${opt}" ${opt === value ? 'selected' : ''}>${opt}</option>`).join('')}</select>`;
                    }

                    if (field === 'staffId') {
                        return `<select class="editable-field" data-field="staffId">${['S-1', 'S-2', 'S-3', 'S-4'].map(opt => `<option value="${opt}" ${opt === value ? 'selected' : ''}>${opt}</option>`).join('')}</select>`;
                    }

                    if (field === 'cancelReason') {
                        const empty = !value || value.trim() === '';
                        return `<span class="editable-field${empty ? ' empty' : ''}" data-field="cancelReason" contenteditable="true">${empty ? 'Click to edit' : value}</span>`;
                    }
                };

                const formattedDate = new Intl.DateTimeFormat('en-US', { weekday: 'long', year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false }).format(new Date(app.dateTime));

                card.innerHTML = `
                    <div class="appointment-info">
                        <p class="appointment-id"><strong>${app.name || ''}</strong> | ${app.email || ''} | ${app.phoneNo || ''} | ${formattedDate}</p>
                        <p>Prescription: ${app.prescription ? JSON.stringify(app.prescription) : ''}</p>
                        ${isNonEmptyObject(app.holdItem) ? `<p>Hold Item: ${JSON.stringify(app.holdItem)}</p>` : ''}
                        <p>Type: ${app.type || ''} | Remarks: ${app.remarks || ''}</p>
                        <p>Status: ${makeEditable('status', app.status)} | Staff: ${makeEditable('staffId', app.staffId)} | Cancel Reason: ${makeEditable('cancelReason', app.cancelReason)}</p>
                    </div>
                `;

                card.querySelectorAll('.editable-field').forEach(el => {
                    // Handle click on empty fields
                    if (el.classList.contains('empty') && el.getAttribute('contenteditable')) {
                        el.addEventListener('focus', () => {
                            if (el.textContent === 'Click to edit') {
                                el.textContent = '';
                                el.classList.remove('empty');
                            }
                        });
                    }

                    const updateValue = () => {
                        const field = el.getAttribute('data-field');
                        let newValue = el.tagName === 'SELECT' ? el.value : el.innerText.trim();

                        // Don't save "Click to edit" as value
                        if (newValue === 'Click to edit') {
                            newValue = '';
                        }

                        if (hasChanges(app.appointmentId, field, newValue)) {
                            editedData[app.appointmentId] = editedData[app.appointmentId] || {};
                            editedData[app.appointmentId][field] = newValue;
                        } else {
                            if (editedData[app.appointmentId]) delete editedData[app.appointmentId][field];
                            if (Object.keys(editedData[app.appointmentId] || {}).length === 0) delete editedData[app.appointmentId];
                        }
                        saveBtn.disabled = Object.keys(editedData).length === 0;
                    };
                    el.addEventListener('blur', updateValue);
                    el.addEventListener('change', updateValue);
                });

                container.appendChild(card);
            });
        }

        statusFilter.addEventListener('change', () => renderAppointmentCards(appointments));
        searchBar.addEventListener('input', () => renderAppointmentCards(appointments));
        sortOrder.addEventListener('change', () => renderAppointmentCards(appointments));

        saveBtn.onclick = async () => {
            if (!confirm("Are you sure you want to save changes?")) return;

            // Apply changes to original data
            for (const appointmentId in editedData) {
                if (originalData[appointmentId]) {
                    Object.assign(originalData[appointmentId], editedData[appointmentId]);
                }
                // Also update the appointments array
                const appointment = appointments.find(a => a.appointmentId === appointmentId);
                if (appointment) {
                    Object.assign(appointment, editedData[appointmentId]);
                }
            }

            // Clear edited data and disable save button
            editedData = {};
            saveBtn.disabled = true;

            // Re-render to show updated data
            renderAppointmentCards(appointments);

            if (typeof showToast === "function") {
                showToast("Appointments saved successfully!");
            } else {
                alert("Appointments saved successfully!");
            }
        };

        loadAppointments();
    </script>
</asp:Content>
