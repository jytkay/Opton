<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="appointment.aspx.cs" Inherits="Opton.Pages.Customer.appointment" MasterPageFile="~/Site.Master" Async="true" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <style>
        /* General Page Layout */
        .appointments-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }

        hr.thick-dark {
            border: 0;
            border-top: 5px solid #2C3639;
            width: 100%;
            margin: 20px 0;
        }

        /* Div 1 - Product Hold Section */
        .product-hold {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.2rem;
            cursor: pointer;
            color: #2C3639;
        }

            .product-hold i {
                font-size: 2rem;
            }

        /* Div 2 - Map + User Info */
        .user-info-map {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            justify-content: center;
        }

        .map-preview {
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid #ccc;
            height: 250px;
            width: 250px;
        }

        .user-form {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

            .user-form input,
            .user-form textarea {
                padding: 8px 10px;
                border-radius: 6px;
                border: 1px solid #ccc;
                font-size: 1rem;
                width: 100%;
                box-sizing: border-box;
            }

            .user-form input.error {
                border-color: #dc3545;
            }

            .user-form .error-message {
                color: #dc3545;
                font-size: 0.875rem;
                margin-top: -5px;
            }

            .user-form textarea {
                height: 80px;
            }

        /* Prescription */
        .collapsible-prescription {
            border: 1px solid #ccc;
            border-radius: 6px;
            padding: 8px;
            margin: 10px 0;
        }

        .collapsible-header {
            display: flex;
            justify-content: space-between;
            cursor: pointer;
            font-size: 1rem;
            color: #2C3639;
        }

        .toggle-indicator {
            font-weight: bold;
        }

        /* Prescription switch */
        .prescription-mode {
            display: flex;
            gap: 20px;
            margin: 10px 0;
        }

            .prescription-mode label {
                cursor: pointer;
                padding: 6px 0;
                border: none;
                background: none;
                font-weight: 500;
                text-decoration: none;
                color: #2C3639;
                transition: all 0.2s ease;
                border-bottom: 2px solid transparent;
            }

            .prescription-mode input[type="radio"]:checked + label {
                border-bottom: 2px solid var(--color-accent);
                font-weight: 600;
            }

            .prescription-mode label:hover {
                border-bottom: 2px solid var(--color-accent);
                opacity: 0.8;
            }

            .prescription-mode input[type="radio"] {
                display: none;
            }

        /* Manual prescription fields */
        .manual-prescription-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

            .manual-prescription-table th,
            .manual-prescription-table td {
                padding: 6px;
                border: none;
                text-align: center;
            }

            .manual-prescription-table input {
                width: 90%;
                padding: 4px 6px;
                border-radius: 6px;
                border: 1px solid #ccc;
            }

        /* Div 3 - Retailer Info */
        .retailer-info {
            margin-top: 20px;
            text-align: center;
        }

            .retailer-info .retailer-name {
                font-weight: bold;
                font-size: 1.1rem;
            }

            .retailer-info .retailer-phone i {
                margin-right: 5px;
            }

        hr.short {
            border: 0;
            border-top: 2px solid #2C3639;
            width: 90%;
            margin: 15px auto;
        }

        /* Div 4 - Appointment Section */
        .appointment-section {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
            margin-top: 20px;
        }

        .calendar-container {
            display: flex;
            justify-content: center;
        }

        .appointment-details {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
        }

        .appointment-times {
            display: grid;
            grid-template-columns: repeat(10, auto);
            gap: 10px;
            justify-content: center;
        }

            .appointment-times label {
                padding: 6px 10px;
                border: 1px solid #2C3639;
                border-radius: 6px;
                cursor: pointer;
                display: inline-flex;
                justify-content: center;
                align-items: center;
                min-width: 50px;
                transition: all 0.2s ease;
                background-color: white;
                color: #2C3639;
            }

            .appointment-times input[type="radio"] {
                display: none;
            }

        /* Book button */
        .book-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            background-color: #A27B5C;
            color: white;
            cursor: pointer;
            font-size: 1rem;
            margin: 20px auto 0 auto;
            display: block;
            width: fit-content;
        }

            .book-btn:disabled {
                background-color: #ccc;
                cursor: not-allowed;
            }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="appointments-container">

        <!-- Div 1: Product Hold -->
        <div class="product-hold" onclick="showUserProductList()">
            <i class="ri-add-circle-line"></i>
            Found something you like? Let us hold onto it for you!
        </div>
        <hr class="thick-dark" />

        <!-- Div 2: Map + User Info -->
        <div class="user-info-map">
            <!-- Map -->
            <div class="map-preview" id="mapPreview"></div>

            <!-- User Form -->
            <div class="user-form">
                <input type="text" id="userName" placeholder="Full Name" required />
                <div>
                    <input type="email" id="userEmail" placeholder="Email Address" required />
                    <div id="emailError" class="error-message" style="display: none;"></div>
                </div>
                <input type="tel" id="userPhone" placeholder="Phone Number" required />

                <!-- Collapsible Prescription Section -->
                <div class="collapsible-prescription">
                    <div class="collapsible-header" onclick="togglePrescription(this)">
                        <strong>Prescription (Optional)</strong>
                        <span class="toggle-indicator">▼</span>
                    </div>

                    <div class="collapsible-body" style="display: none; margin-top: 10px;">
                        <!-- Prescription mode toggle -->
                        <div class="prescription-mode">
                            <input type="radio" id="uploadMode" name="prescriptionMode" checked>
                            <label for="uploadMode">Upload Prescription</label>
                            <input type="radio" id="manualMode" name="prescriptionMode">
                            <label for="manualMode">Manual Input</label>
                        </div>

                        <!-- Prescription Type Dropdown -->
                        <div id="prescriptionTypeContainer" style="display: block;">
                            <label for="prescriptionType" style="font-weight: 500;">Prescription Type</label>
                            <select id="prescriptionType" style="padding: 6px 8px; border-radius: 6px; border: 1px solid #ccc; width: 100%;">
                                <option value="">-- Select Type --</option>
                                <option value="nearsightedness">Nearsightedness (Myopia)</option>
                                <option value="farsightedness">Farsightedness (Hyperopia)</option>
                                <option value="reading">Reading Glasses</option>
                                <option value="multifocal">Multifocal / Progressive</option>
                            </select>
                        </div>

                        <!-- Upload Prescription -->
                        <div id="uploadPrescription">
                            <input type="file" id="prescriptionFile" accept=".png,.jpg,.jpeg,.pdf" />
                            <small>Allowed file types: PNG, JPG, JPEG, PDF</small>
                        </div>

                        <!-- Manual Prescription -->
                        <div id="manualPrescription" style="display: none;">
                            <table class="manual-prescription-table">
                                <thead>
                                    <tr>
                                        <th></th>
                                        <th>Left Eye</th>
                                        <th>Right Eye</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>Sphere</td>
                                        <td><input type="text" id="leftEyeSphere" placeholder="Sphere" /></td>
                                        <td><input type="text" id="rightEyeSphere" placeholder="Sphere" /></td>
                                    </tr>
                                    <tr>
                                        <td>Cylinder</td>
                                        <td><input type="text" id="leftEyeCylinder" placeholder="Cylinder" /></td>
                                        <td><input type="text" id="rightEyeCylinder" placeholder="Cylinder" /></td>
                                    </tr>
                                    <tr>
                                        <td>Axis</td>
                                        <td><input type="text" id="leftEyeAxis" placeholder="Axis" /></td>
                                        <td><input type="text" id="rightEyeAxis" placeholder="Axis" /></td>
                                    </tr>
                                    <tr>
                                        <td>PD</td>
                                        <td colspan="2"><input type="text" id="pd" placeholder="Pupillary Distance" /></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <textarea id="userRemarks" placeholder="Remarks (optional)"></textarea>
            </div>
        </div>

        <!-- Div 3: Retailer Info -->
        <div class="retailer-info">
            <div class="retailer-name">
                <asp:Literal ID="retailerNameLiteral" runat="server" Text="Retailer Name"></asp:Literal>
            </div>
            <div class="retailer-address" id="retailerAddress" runat="server" ClientIDMode="Static"></div>
            <div class="retailer-phone" id="retailerPhone" runat="server" ClientIDMode="Static"><i class="ri-phone-fill"></i></div>
        </div>
        <hr class="short" />

        <!-- Div 4: Appointment Selection -->
        <div class="appointment-section">
            <div class="calendar-container">
                <input type="date" id="appointmentDate" onchange="updateAppointmentTimes()" />
            </div>

            <div class="appointment-details">
                <!-- Appointment type dropdown -->
                <select id="appointmentType">
                    <option value="prescription">Prescription</option>
                    <option value="consultation">Consultation</option>
                    <option value="other">Other</option>
                </select>

                <div id="appointmentPrompt">Pick a Date to Start!</div>
                <div class="appointment-times" id="appointmentTimes"></div>
            </div>
        </div>

        <!-- Book Appointment button -->
        <button type="button" class="book-btn" id="bookAppointmentBtn" disabled onclick="bookAppointment()">Book Appointment</button>
    </div>

    <script type="module">
        let retailerOpeningHours = {};

        async function loadRetailerData() {
            const params = new URLSearchParams(window.location.search);
            const retailerId = params.get('retailerId');
            if (!retailerId) {
                console.error("No retailerId in query string");
                return;
            }

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ getRetailers: true })
                });

                const data = await response.json();
                console.log("Handler response:", data);

                const retailers = data.retailers || data;
                if (!Array.isArray(retailers)) {
                    console.error("Retailer data invalid", data);
                    return;
                }

                const retailer = retailers.find(r => r.id == retailerId);
                if (!retailer) {
                    console.error("Retailer not found:", retailerId);
                    return;
                }

                retailerOpeningHours = retailer.openingHours || {};

                const nameEl = document.querySelector('.retailer-name');
                const addressEl = document.getElementById('retailerAddress');
                const phoneEl = document.getElementById('retailerPhone');

                if (nameEl) nameEl.innerHTML = retailer.name || 'Unknown Retailer';
                if (addressEl) addressEl.textContent = retailer.address || 'No address available';
                if (phoneEl) phoneEl.innerHTML = `<i class="ri-phone-fill"></i> ${retailer.phoneNo || 'N/A'}`;

                return {
                    name: retailer.name,
                    lat: parseFloat(retailer.latitude),
                    lng: parseFloat(retailer.longitude)
                };
            } catch (err) {
                console.error("Error fetching retailer data:", err);
            }
        }

        async function initializeMap(lat, lng, retailerName) {
            const apiKey = await fetch('/Handlers/get_keys.ashx')
                .then(res => res.json())
                .then(data => data.apiKeys.GOOGLE_API_KEY)
                .catch(err => {
                    console.error('Failed to get Google API key:', err);
                    return null;
                });

            if (!apiKey) return;

            await new Promise((resolve, reject) => {
                if (window.google && window.google.maps) return resolve();
                const script = document.createElement('script');
                script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}`;
                script.async = true;
                script.defer = true;
                script.onload = resolve;
                script.onerror = reject;
                document.head.appendChild(script);
            });

            const map = new google.maps.Map(document.getElementById('mapPreview'), {
                center: { lat, lng },
                zoom: 15,
            });

            const marker = new google.maps.Marker({
                position: { lat, lng },
                map,
                title: retailerName,
            });

            const infoWindow = new google.maps.InfoWindow({
                content: `
                <div style="font-family: Arial; text-align: center;">
                    <strong>${retailerName}</strong><br>
                    <button id="directionsBtn"
                        style="
                            margin-top: 8px;
                            padding: 6px 12px;
                            background-color: #A27B5C;
                            color: white;
                            border: none;
                            border-radius: 6px;
                            font-weight: bold;
                            cursor: pointer;
                            transition: background 0.2s;
                        "
                        onmouseover="this.style.backgroundColor='#8f6b4f'"
                        onmouseout="this.style.backgroundColor='#A27B5C'">
                        Go Now
                    </button>
                </div>
            `
            });

            infoWindow.open(map, marker);

            google.maps.event.addListener(infoWindow, 'domready', () => {
                const btn = document.getElementById('directionsBtn');
                if (btn) {
                    btn.onclick = () => {
                        const destination = `${lat},${lng}`;
                        window.open(
                            `https://www.google.com/maps/dir/?api=1&destination=${destination}&travelmode=driving`,
                            '_blank'
                        );
                    };
                }
            });
        }

        window.addEventListener('load', async () => {
            const retailer = await loadRetailerData();
            if (retailer && retailer.lat && retailer.lng) {
                initializeMap(retailer.lat, retailer.lng, retailer.name);
            }
        });
    </script>
    <script>
        // Email validation function
        function validateEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        // Add email validation on input
        document.addEventListener('DOMContentLoaded', () => {
            const emailInput = document.getElementById('userEmail');
            const emailError = document.getElementById('emailError');

            emailInput.addEventListener('blur', () => {
                const email = emailInput.value.trim();
                if (email && !validateEmail(email)) {
                    emailInput.classList.add('error');
                    emailError.textContent = 'Please enter a valid email address';
                    emailError.style.display = 'block';
                } else {
                    emailInput.classList.remove('error');
                    emailError.style.display = 'none';
                }
            });

            emailInput.addEventListener('input', () => {
                if (emailInput.classList.contains('error')) {
                    const email = emailInput.value.trim();
                    if (validateEmail(email)) {
                        emailInput.classList.remove('error');
                        emailError.style.display = 'none';
                    }
                }
            });
        });

        function togglePrescription(headerEl) {
            const body = headerEl.nextElementSibling;
            if (!body) return;

            if (body.style.display === 'none') {
                body.style.display = 'block';
                headerEl.querySelector('.toggle-indicator').textContent = '▲';
            } else {
                body.style.display = 'none';
                headerEl.querySelector('.toggle-indicator').textContent = '▼';
            }
        }

        const uploadRadio = document.getElementById('uploadMode');
        const manualRadio = document.getElementById('manualMode');
        const uploadDiv = document.getElementById('uploadPrescription');
        const manualDiv = document.getElementById('manualPrescription');

        uploadRadio.addEventListener('change', () => {
            uploadDiv.style.display = 'block';
            manualDiv.style.display = 'none';
        });

        manualRadio.addEventListener('change', () => {
            uploadDiv.style.display = 'none';
            manualDiv.style.display = 'block';
        });

        const prescriptionType = document.getElementById('prescriptionType');
        const pdInput = document.getElementById('pd');

        prescriptionType.addEventListener('change', () => {
            const type = prescriptionType.value;
            pdInput.style.display = 'table-cell';
            if (type === 'reading') {
                pdInput.style.display = 'none';
            }
        });

        function showUserProductList() {
            alert("Show user's saved products with checkboxes.");
        }

        function updateAppointmentTimes() {
            const dateInput = document.getElementById('appointmentDate').value;
            const timesContainer = document.getElementById('appointmentTimes');
            const prompt = document.getElementById('appointmentPrompt');
            const bookBtn = document.getElementById('bookAppointmentBtn');

            timesContainer.innerHTML = '';

            if (!dateInput) {
                prompt.innerHTML = "Pick a Date to Start!";
                bookBtn.disabled = true;
                return;
            }

            prompt.innerHTML = `<strong>Select a Time for ${dateInput}</strong>`;

            const dayOfWeek = new Date(dateInput).toLocaleDateString('en-US', { weekday: 'long' });
            const hours = retailerOpeningHours[dayOfWeek];

            if (!hours || hours === "Closed") {
                timesContainer.innerHTML = `<div style="text-align:center; font-weight:bold;">Retailer is closed on this day.</div>`;
                bookBtn.disabled = true;
                return;
            }

            const [startHour, endHour] = hours.split('-').map(Number);

            for (let h = startHour; h < endHour; h++) {
                for (let m = 0; m < 60; m += 30) {
                    const slotHour = h.toString().padStart(2, '0');
                    const slotMin = m.toString().padStart(2, '0');
                    const timeValue = `${slotHour}:${slotMin}`;

                    const label = document.createElement('label');
                    const radio = document.createElement('input');
                    radio.type = "radio";
                    radio.name = "appointmentTime";
                    radio.value = timeValue;

                    const span = document.createElement('span');
                    span.textContent = timeValue;

                    label.appendChild(radio);
                    label.appendChild(span);
                    timesContainer.appendChild(label);

                    radio.addEventListener('change', () => {
                        document.querySelectorAll('.appointment-times label').forEach(l => {
                            l.style.backgroundColor = 'white';
                            l.style.color = '#2C3639';
                        });

                        label.style.backgroundColor = 'var(--color-dark)';
                        label.style.color = 'white';

                        bookBtn.disabled = false;
                    });
                }
            }
        }

        function bookAppointment() {
            const name = document.getElementById('userName').value.trim();
            const email = document.getElementById('userEmail').value.trim();
            const phone = document.getElementById('userPhone').value.trim();
            const date = document.getElementById('appointmentDate').value;
            const time = document.querySelector('input[name="appointmentTime"]:checked')?.value;
            const type = document.getElementById('appointmentType').value;
            const prescriptionTypeValue = document.getElementById('prescriptionType').value;
            let prescriptionData = null;

            // Validate email
            if (!validateEmail(email)) {
                document.getElementById('userEmail').classList.add('error');
                document.getElementById('emailError').textContent = 'Please enter a valid email address';
                document.getElementById('emailError').style.display = 'block';
                alert("Please enter a valid email address.");
                return;
            }

            // Validate required fields
            if (!name || !email || !phone || !date || !time || !type) {
                alert("Please fill all required fields and select a time.");
                return;
            }

            // Optional prescription handling
            if (uploadRadio.checked) {
                const fileInput = document.getElementById('prescriptionFile');
                if (fileInput.files.length > 0) {
                    prescriptionData = {
                        type: prescriptionTypeValue || 'unspecified',
                        file: fileInput.files[0].name
                    };
                }
            } else if (manualRadio.checked) {
                const leftSphere = document.getElementById('leftEyeSphere').value.trim();
                const leftCylinder = document.getElementById('leftEyeCylinder').value.trim();
                const leftAxis = document.getElementById('leftEyeAxis').value.trim();
                const rightSphere = document.getElementById('rightEyeSphere').value.trim();
                const rightCylinder = document.getElementById('rightEyeCylinder').value.trim();
                const rightAxis = document.getElementById('rightEyeAxis').value.trim();
                const pd = document.getElementById('pd').value.trim();

                if (leftSphere || leftCylinder || leftAxis || rightSphere || rightCylinder || rightAxis || pd) {
                    prescriptionData = {
                        type: prescriptionTypeValue || 'unspecified',
                        leftSphere, leftCylinder, leftAxis,
                        rightSphere, rightCylinder, rightAxis,
                        pd
                    };
                }
            }

            const remarks = document.getElementById('userRemarks').value.trim();

            // Disable button to prevent double submission
            const bookBtn = document.getElementById('bookAppointmentBtn');
            bookBtn.disabled = true;
            bookBtn.textContent = 'Sending...';

            (async () => {
                try {
                    console.log('Sending email request...');

                    const response = await fetch('/Handlers/send_email_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            action: 'sendAppointmentEmail',
                            userEmail: email,
                            userName: name,
                            appointmentType: type,
                            appointmentDate: date,
                            appointmentTime: time,
                            retailerName: document.querySelector('.retailer-name').textContent,
                            retailerAddress: document.getElementById('retailerAddress').textContent
                        })
                    });

                    const data = await response.json();
                    console.log('Response:', data);

                    if (data.success) {
                        alert('Appointment confirmed! A calendar invite has been sent to your email.');
                        // Optionally redirect or clear form
                        // window.location.href = '/Pages/Customer/find_retailers.aspx';
                    } else {
                        alert('Appointment booking failed: ' + (data.message || 'Unknown error'));
                        console.error('Error details:', data);
                    }
                } catch (err) {
                    console.error('Error:', err);
                    alert('Error confirming appointment: ' + err.message);
                } finally {
                    bookBtn.disabled = false;
                    bookBtn.textContent = 'Book Appointment';
                }
            })();
        }
    </script>
</asp:Content>