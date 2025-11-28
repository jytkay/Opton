<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="profile.aspx.cs" Inherits="Opton.Pages.Customer.profile" MasterPageFile="~/Site.Master" %>
<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <style>
        .profile-container {
            max-width: 600px;
            margin: 50px auto;
            padding: 40px;
            background-color: white;
            border-radius: 15px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            position: relative;
        }

        .edit-mode-btn {
            position: absolute;
            top: 20px;
            right: 20px;
            background: none;
            border: none;
            color: var(--color-gray);
            font-size: 24px;
            cursor: pointer;
            transition: color 0.3s;
            padding: 8px;
            border-radius: 8px;
        }

        .edit-mode-btn:hover {
            color: var(--color-accent);
            background-color: var(--color-background);
        }

        .edit-mode-btn.active {
            color: var(--color-accent);
            background-color: var(--color-light);
        }

        .profile-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .profile-pic-wrapper {
            position: relative;
            display: inline-block;
            margin-bottom: 20px;
        }

        .profile-pic {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid var(--color-gray);
        }

        .user-id {
            font-size: 14px;
            color: var(--color-gray);
            margin-bottom: 10px;
        }

        .user-email {
            font-size: 18px;
            color: var(--color-dark);
            font-weight: 500;
        }

        .profile-form {
            margin-top: 30px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: var(--color-dark);
            margin-bottom: 8px;
        }

        .form-value {
            padding: 12px 15px;
            border: 2px solid transparent;
            border-radius: 10px;
            font-size: 16px;
            color: var(--color-dark);
            background-color: var(--color-background);
            min-height: 44px;
        }

        .form-input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid var(--color-light);
            border-radius: 10px;
            font-size: 16px;
            color: var(--color-dark);
            background-color: white;
            transition: all 0.3s;
            box-sizing: border-box;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--color-accent);
        }

        .phone-wrapper {
            display: flex;
            gap: 10px;
        }

        .country-select {
            width: 120px;
            padding: 12px;
            border: 2px solid var(--color-light);
            border-radius: 10px;
            font-size: 16px;
            color: var(--color-dark);
            background-color: white;
            cursor: pointer;
        }

        .country-select:focus {
            outline: none;
            border-color: var(--color-accent);
        }

        .phone-input {
            flex: 1;
        }

        textarea.form-input {
            resize: vertical;
            min-height: 80px;
            font-family: 'Saira Condensed', sans-serif;
        }

        /* Prescription section styles matching fav_cart.aspx */
        .prescription-section {
            margin-top: 10px;
            padding: 20px;
            background-color: var(--color-background);
            border-radius: 10px;
        }

        .prescription-mode {
            display: flex;
            gap: 20px;
            margin-bottom: 15px;
        }

        .prescription-mode input[type="radio"] {
            display: none;
        }

        .prescription-mode label {
            cursor: pointer;
            padding: 8px 0;
            font-weight: 500;
            color: #666;
            border-bottom: 2px solid transparent;
            transition: all 0.2s;
        }

        .prescription-mode input[type="radio"]:checked + label {
            border-bottom: 2px solid var(--color-accent);
            color: var(--color-dark);
            font-weight: 600;
        }

        .prescription-type-select {
            margin-bottom: 15px;
        }

        .prescription-type-select select {
            width: 100%;
            padding: 10px;
            border: 2px solid var(--color-light);
            border-radius: 8px;
            font-size: 14px;
            color: var(--color-dark);
            background-color: white;
        }

        .prescription-type-select select:focus {
            outline: none;
            border-color: var(--color-accent);
        }

        #uploadPrescription input[type="file"] {
            width: 100%;
            padding: 10px;
            border: 2px dashed var(--color-light);
            border-radius: 8px;
            font-size: 14px;
            background-color: white;
            cursor: pointer;
        }

        #uploadPrescription small {
            color: #666;
            font-size: 12px;
        }

        .manual-prescription-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        .manual-prescription-table th,
        .manual-prescription-table td {
            padding: 8px;
            text-align: center;
            border: 1px solid #e9ecef;
        }

        .manual-prescription-table th {
            background: #f8f9fa;
            font-weight: 600;
            color: var(--color-dark);
        }

        .manual-prescription-table input {
            width: 100%;
            padding: 6px 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-align: center;
        }

        #manualPrescription {
            display: none;
        }

        .save-btn {
            width: 100%;
            padding: 15px;
            background-color: var(--color-accent);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-top: 20px;
            display: none;
        }

        .save-btn:hover {
            background-color: #8a6a4d;
        }

        .save-btn.show {
            display: block;
        }

        .change-password-btn {
            width: 100%;
            padding: 15px;
            background-color: var(--color-dark);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-top: 15px;
        }

        .change-password-btn:hover {
            background-color: var(--color-gray);
        }
    </style>
</asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="profile-container">
        <button type="button" class="edit-mode-btn" id="editModeBtn" onclick="toggleEditMode()">
            <i class="ri-pencil-line"></i>
        </button>

        <div class="profile-header">
            <div class="profile-pic-wrapper">
                <img id="profilePic" class="profile-pic" src="" alt="Profile Picture">
            </div>
            <div class="user-id" id="userId">User ID: Loading...</div>
            <div class="user-email" id="userEmail">Loading...</div>
        </div>

        <div class="profile-form">
            <div class="form-group">
                <label class="form-label">Name</label>
                <div id="nameDisplay" class="form-value"></div>
                <input type="text" id="nameInput" class="form-input" placeholder="Enter your name" style="display: none;">
            </div>

            <div class="form-group">
                <label class="form-label">Phone Number</label>
                <div id="phoneDisplay" class="form-value"></div>
                <div class="phone-wrapper" style="display: none;">
                    <select id="countryCode" class="country-select">
                        <option value="+60">🇲🇾 +60</option>
                        <option value="+1">🇺🇸 +1</option>
                        <option value="+44">🇬🇧 +44</option>
                        <option value="+65">🇸🇬 +65</option>
                        <option value="+86">🇨🇳 +86</option>
                        <option value="+91">🇮🇳 +91</option>
                        <option value="+81">🇯🇵 +81</option>
                        <option value="+82">🇰🇷 +82</option>
                    </select>
                    <input type="tel" id="phoneInput" class="form-input phone-input" placeholder="Enter phone number">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Shipping Address</label>
                <div id="addressDisplay" class="form-value"></div>
                <textarea id="addressInput" class="form-input" placeholder="Enter your shipping address" style="display: none;"></textarea>
            </div>

            <div class="form-group">
                <label class="form-label">Eyewear Prescription</label>
                <div id="prescriptionDisplay" class="form-value"></div>
                <div class="prescription-section" style="display: none;">
                    <div class="prescription-mode">
                        <input type="radio" id="uploadMode" name="prescriptionMode" checked>
                        <label for="uploadMode">Upload Prescription</label>
                        <input type="radio" id="manualMode" name="prescriptionMode">
                        <label for="manualMode">Manual Input</label>
                    </div>

                    <div class="prescription-type-select">
                        <select id="prescriptionType">
                            <option value="">-- Select Type --</option>
                            <option value="nearsightedness">Nearsightedness (Myopia)</option>
                            <option value="farsightedness">Farsightedness (Hyperopia)</option>
                            <option value="reading">Reading Glasses</option>
                            <option value="multifocal">Multifocal / Progressive</option>
                        </select>
                    </div>

                    <div id="uploadPrescription">
                        <input type="file" id="prescriptionFile" accept=".png,.jpg,.jpeg,.pdf">
                        <small>Allowed: PNG, JPG, JPEG, PDF</small>
                    </div>

                    <div id="manualPrescription">
                        <table class="manual-prescription-table">
                            <thead>
                                <tr>
                                    <th></th>
                                    <th>Right Eye (OD)</th>
                                    <th>Left Eye (OS)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><strong>Sphere (SPH)</strong></td>
                                    <td><input type="text" id="rightEyeSphere" placeholder="e.g., -2.00"></td>
                                    <td><input type="text" id="leftEyeSphere" placeholder="e.g., -2.00"></td>
                                </tr>
                                <tr>
                                    <td><strong>Cylinder (CYL)</strong></td>
                                    <td><input type="text" id="rightEyeCylinder" placeholder="e.g., -0.50"></td>
                                    <td><input type="text" id="leftEyeCylinder" placeholder="e.g., -0.50"></td>
                                </tr>
                                <tr>
                                    <td><strong>Axis</strong></td>
                                    <td><input type="text" id="rightEyeAxis" placeholder="e.g., 180"></td>
                                    <td><input type="text" id="leftEyeAxis" placeholder="e.g., 180"></td>
                                </tr>
                                <tr>
                                    <td><strong>PD</strong></td>
                                    <td colspan="2"><input type="text" id="pd" placeholder="e.g., 63"></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <button type="button" class="save-btn" id="saveBtn" onclick="saveProfile()">
                <i class="ri-save-line"></i> Save Changes
            </button>

            <button type="button" class="change-password-btn" id="changePasswordBtn" style="display: none;" onclick="changePassword()">
                <i class="ri-lock-password-line"></i> Change Password
            </button>
        </div>
    </div>

    <script type="module">
        import { onAuthStateChanged, updatePassword, reauthenticateWithCredential, EmailAuthProvider } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-auth.js";
        import { initFirebase } from "/Scripts/firebase-init.js";

        const { app, auth } = await initFirebase();
        let currentUser = null;
        let isEditMode = false;
        let uploadedFile = null;
        let prescriptionData = null;

        onAuthStateChanged(auth, async (user) => {
            if (user && user.emailVerified) {
                currentUser = user;
                await loadUserProfile(user);
            } else {
                window.location.href = '/Pages/Customer/catalogue.aspx';
            }
        });

        async function loadUserProfile(user) {
            const userEmail = user.email.trim().toLowerCase();
            const gravatar = 'https://www.gravatar.com/avatar/' + md5(userEmail) + '?d=identicon&s=200';
            document.getElementById('profilePic').src = user.photoURL || gravatar;
            document.getElementById('userId').textContent = 'User ID: ' + user.uid;
            document.getElementById('userEmail').textContent = user.email;

            const isEmailUser = user.providerData.some(p => p.providerId === 'password');
            if (isEmailUser) {
                document.getElementById('changePasswordBtn').style.display = 'block';
            }

            try {
                const response = await fetch('/Handlers/fire_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'getUserProfile',
                        idToken: await user.getIdToken()
                    })
                });
                const data = await response.json();

                console.log('User profile data:', data);

                if (data.success) {
                    document.getElementById('nameDisplay').textContent = data.name || 'Not set';
                    document.getElementById('nameInput').value = data.name || '';

                    if (data.phoneNo) {
                        document.getElementById('phoneDisplay').textContent = data.phoneNo;
                        const phoneMatch = data.phoneNo.match(/^(\+\d+)\s*(.+)$/);
                        if (phoneMatch) {
                            document.getElementById('countryCode').value = phoneMatch[1];
                            document.getElementById('phoneInput').value = phoneMatch[2].trim();
                        } else {
                            document.getElementById('phoneInput').value = data.phoneNo;
                        }
                    } else {
                        document.getElementById('phoneDisplay').textContent = 'Not set';
                    }

                    document.getElementById('addressDisplay').textContent = data.address || 'Not set';
                    document.getElementById('addressInput').value = data.address || '';

                    // Handle prescription data
                    if (data.prescription) {
                        prescriptionData = parsePrescriptionData(data.prescription);
                        document.getElementById('prescriptionDisplay').textContent = formatPrescriptionDisplay(prescriptionData);
                        loadPrescriptionIntoForm(prescriptionData);
                    } else {
                        document.getElementById('prescriptionDisplay').textContent = 'Not set';
                    }
                }
            } catch (error) {
                console.error('Error loading user data:', error);
            }
        }

        function parsePrescriptionData(prescription) {
            try {
                const parsed = JSON.parse(prescription);
                return parsed;
            } catch {
                // Old format - just text
                return { mode: 'text', text: prescription };
            }
        }

        function formatPrescriptionDisplay(data) {
            if (!data) return 'Not set';

            if (data.mode === 'upload' && data.fileName) {
                return `File: ${data.fileName}`;
            } else if (data.mode === 'manual') {
                let display = `${getPrescriptionTypeName(data.type)} - `;
                display += `R: SPH ${data.rightEye?.sphere || 'N/A'}, `;
                display += `L: SPH ${data.leftEye?.sphere || 'N/A'}`;
                return display;
            } else if (data.text) {
                return data.text;
            }
            return 'Not set';
        }

        function getPrescriptionTypeName(type) {
            const names = {
                'nearsightedness': 'Myopia',
                'farsightedness': 'Hyperopia',
                'reading': 'Reading',
                'multifocal': 'Multifocal'
            };
            return names[type] || type;
        }

        function loadPrescriptionIntoForm(data) {
            if (!data) return;

            if (data.type) {
                document.getElementById('prescriptionType').value = data.type;
            }

            if (data.mode === 'manual') {
                document.getElementById('manualMode').checked = true;
                document.getElementById('uploadPrescription').style.display = 'none';
                document.getElementById('manualPrescription').style.display = 'block';

                if (data.rightEye) {
                    document.getElementById('rightEyeSphere').value = data.rightEye.sphere || '';
                    document.getElementById('rightEyeCylinder').value = data.rightEye.cylinder || '';
                    document.getElementById('rightEyeAxis').value = data.rightEye.axis || '';
                }
                if (data.leftEye) {
                    document.getElementById('leftEyeSphere').value = data.leftEye.sphere || '';
                    document.getElementById('leftEyeCylinder').value = data.leftEye.cylinder || '';
                    document.getElementById('leftEyeAxis').value = data.leftEye.axis || '';
                }
                if (data.pd) {
                    document.getElementById('pd').value = data.pd;
                }
            }
        }

        // Prescription mode toggle
        document.getElementById('uploadMode').addEventListener('change', function () {
            if (this.checked) {
                document.getElementById('uploadPrescription').style.display = 'block';
                document.getElementById('manualPrescription').style.display = 'none';
            }
        });

        document.getElementById('manualMode').addEventListener('change', function () {
            if (this.checked) {
                document.getElementById('uploadPrescription').style.display = 'none';
                document.getElementById('manualPrescription').style.display = 'block';
            }
        });

        window.toggleEditMode = function () {
            isEditMode = !isEditMode;
            const editBtn = document.getElementById('editModeBtn');
            const saveBtn = document.getElementById('saveBtn');

            if (isEditMode) {
                editBtn.classList.add('active');
                editBtn.querySelector('i').className = 'ri-close-line';
                saveBtn.classList.add('show');
                document.getElementById('nameDisplay').style.display = 'none';
                document.getElementById('nameInput').style.display = 'block';
                document.getElementById('phoneDisplay').style.display = 'none';
                document.querySelector('.phone-wrapper').style.display = 'flex';
                document.getElementById('addressDisplay').style.display = 'none';
                document.getElementById('addressInput').style.display = 'block';
                document.getElementById('prescriptionDisplay').style.display = 'none';
                document.querySelector('.prescription-section').style.display = 'block';
            } else {
                editBtn.classList.remove('active');
                editBtn.querySelector('i').className = 'ri-pencil-line';
                saveBtn.classList.remove('show');
                document.getElementById('nameDisplay').style.display = 'block';
                document.getElementById('nameInput').style.display = 'none';
                document.getElementById('phoneDisplay').style.display = 'block';
                document.querySelector('.phone-wrapper').style.display = 'none';
                document.getElementById('addressDisplay').style.display = 'block';
                document.getElementById('addressInput').style.display = 'none';
                document.getElementById('prescriptionDisplay').style.display = 'block';
                document.querySelector('.prescription-section').style.display = 'none';
            }
        };

        window.saveProfile = async function () {
            if (!currentUser) return;

            const saveBtn = document.getElementById('saveBtn');
            saveBtn.disabled = true;
            saveBtn.textContent = 'Saving...';

            try {
                const name = document.getElementById('nameInput').value.trim();
                const countryCode = document.getElementById('countryCode').value;
                const phoneNumber = document.getElementById('phoneInput').value.trim();
                const address = document.getElementById('addressInput').value.trim();
                const fullPhone = phoneNumber ? countryCode + ' ' + phoneNumber : '';

                // Collect prescription data
                let newPrescriptionData = null;
                const prescriptionType = document.getElementById('prescriptionType').value;

                if (prescriptionType) {
                    const uploadMode = document.getElementById('uploadMode').checked;

                    if (uploadMode) {
                        const fileInput = document.getElementById('prescriptionFile');
                        if (fileInput.files.length > 0) {
                            const file = fileInput.files[0];
                            try {
                                const base64 = await fileToBase64(file);
                                newPrescriptionData = {
                                    type: prescriptionType,
                                    mode: 'upload',
                                    fileName: file.name,
                                    fileType: file.type,
                                    data: base64
                                };
                            } catch (error) {
                                alert('Error processing file: ' + error.message);
                                saveBtn.disabled = false;
                                saveBtn.innerHTML = '<i class="ri-save-line"></i> Save Changes';
                                return;
                            }
                        } else {
                            // Keep existing prescription if no new file
                            newPrescriptionData = prescriptionData;
                        }
                    } else {
                        // Manual mode
                        const rightSphere = document.getElementById('rightEyeSphere').value.trim();
                        const leftSphere = document.getElementById('leftEyeSphere').value.trim();

                        if (rightSphere || leftSphere) {
                            newPrescriptionData = {
                                type: prescriptionType,
                                mode: 'manual',
                                rightEye: {
                                    sphere: rightSphere,
                                    cylinder: document.getElementById('rightEyeCylinder').value.trim(),
                                    axis: document.getElementById('rightEyeAxis').value.trim()
                                },
                                leftEye: {
                                    sphere: leftSphere,
                                    cylinder: document.getElementById('leftEyeCylinder').value.trim(),
                                    axis: document.getElementById('leftEyeAxis').value.trim()
                                },
                                pd: document.getElementById('pd').value.trim()
                            };
                        }
                    }
                }

                console.log('Saving profile with data:', {
                    name,
                    phoneNo: fullPhone,
                    address,
                    prescription: newPrescriptionData
                });

                const response = await fetch('/Handlers/db_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'updateUserProfile',
                        idToken: await currentUser.getIdToken(),
                        name: name,
                        phoneNo: fullPhone,
                        address: address,
                        prescription: newPrescriptionData ? JSON.stringify(newPrescriptionData) : ''
                    })
                });

                const data = await response.json();
                console.log('Save response:', data);

                if (data.success) {
                    alert('Profile updated successfully!');
                    prescriptionData = newPrescriptionData;

                    // Update display values
                    document.getElementById('nameDisplay').textContent = name || 'Not set';
                    document.getElementById('phoneDisplay').textContent = fullPhone || 'Not set';
                    document.getElementById('addressDisplay').textContent = address || 'Not set';
                    document.getElementById('prescriptionDisplay').textContent = formatPrescriptionDisplay(newPrescriptionData);

                    toggleEditMode();
                } else {
                    alert('Error updating profile: ' + data.message);
                }
            } catch (error) {
                console.error('Error saving profile:', error);
                alert('Error saving profile: ' + error.message);
            } finally {
                saveBtn.disabled = false;
                saveBtn.innerHTML = '<i class="ri-save-line"></i> Save Changes';
            }
        };

        function fileToBase64(file) {
            return new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.onload = () => resolve(reader.result);
                reader.onerror = reject;
                reader.readAsDataURL(file);
            });
        }

        window.changePassword = async function () {
            if (!currentUser) return;

            const currentPassword = prompt('Enter your current password:');
            if (!currentPassword) return;

            const newPassword = prompt('Enter your new password (minimum 6 characters):');
            if (!newPassword) return;

            if (newPassword.length < 6) {
                alert('Password must be at least 6 characters long.');
                return;
            }

            const confirmPassword = prompt('Confirm your new password:');
            if (newPassword !== confirmPassword) {
                alert('Passwords do not match.');
                return;
            }

            try {
                const credential = EmailAuthProvider.credential(currentUser.email, currentPassword);
                await reauthenticateWithCredential(currentUser, credential);
                await updatePassword(currentUser, newPassword);
                alert('Password changed successfully!');
            } catch (error) {
                if (error.code === 'auth/wrong-password') {
                    alert('Current password is incorrect.');
                } else {
                    alert('Error changing password: ' + error.message);
                }
            }
        };

        function md5(string) {
            return string.split('').reduce((a, b) => {
                a = ((a << 5) - a) + b.charCodeAt(0);
                return a & a;
            }, 0).toString(16);
        }
    </script>
</asp:Content>