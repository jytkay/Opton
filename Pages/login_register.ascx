<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="login_register.ascx.cs" Inherits="Opton.Pages.login_register" %>

<!-- Login/Register Dropdown (appears under login icon) -->
<div id="login_registerModal" class="auth-dropdown-container" style="display: none;">
    <div class="auth-dropdown-content">
        <!-- Google / Email options -->
        <button class="google-btn" type="button" id="googleLoginBtn">
            <i class="ri-google-line"></i>Sign in / Sign up with Google
        </button>

        <button class="email-btn" type="button" onclick="showEmailForm()">
            <i class="ri-mail-line"></i>Sign in / Sign up with Email
        </button>

        <!-- Email form -->
        <div id="emailAuthForm" style="display: none; margin-top: 10px;">
            <input type="email" id="txtEmail" placeholder="Email" class="input-field" />
            <div class="password-wrapper">
                <input type="password" id="txtPassword" placeholder="Password" class="input-field" />
                <span class="toggle-password" onclick="togglePassword('txtPassword', this)">
                    <i class="ri-eye-close-line"></i>
                </span>
            </div>

            <!-- Confirm Password field (hidden by default) -->
            <div id="confirmPasswordWrapper" class="password-wrapper" style="display: none;">
                <input type="password" id="txtConfirmPassword" placeholder="Confirm Password" class="input-field" />
                <span class="toggle-password" onclick="togglePassword('txtConfirmPassword', this)">
                    <i class="ri-eye-close-line"></i>
                </span>
            </div>

            <!-- Forgot Password link -->
            <div style="text-align: right; margin: 5px 0;">
                <a href="#" id="forgotPasswordLink" style="font-size: 13px; color: #2C3639;">Forgot Password?</a>
            </div>

            <button class="action-btn" type="button" onclick="submitAuth()">Continue</button>

            <button id="resendVerificationBtn" class="action-btn" style="margin-top: 10px; display: none;">
                Resend Verification Email
            </button>
        </div>
    </div>
</div>

<!-- User Profile Dropdown (appears after login) -->
<div id="userProfileDropdown" class="user-dropdown-container" style="display: none;">
    <div class="user-dropdown-content">
        <div class="user-info">
            <img id="userProfilePic" src="" alt="Profile" class="profile-pic" />
            <div class="user-details">
                <span id="userEmail" class="user-email"></span>
            </div>
        </div>
        <hr />
        <button type="button" class="dropdown-option" onclick="viewProfile()">
            <i class="ri-user-line"></i>View Profile
        </button>
        <button id="switchToWorkBtn" type="button" class="dropdown-option" style="display: none;"
            onclick="switchWorkAccount()">
            <i class="ri-toggle-line"></i>Switch to Work Account
        </button>
        <button type="button" class="dropdown-option" onclick="logout()">
            <i class="ri-logout-box-line"></i>Logout
        </button>
        <button type="button" class="dropdown-option danger" onclick="deleteAccount()">
            <i class="ri-delete-bin-line"></i>Delete Account
        </button>
    </div>
</div>

<style>
    /* Auth Dropdown Container */
    .auth-dropdown-container {
        position: fixed;
        top: 60px;
        right: 20px;
        z-index: 9999;
    }

    .auth-dropdown-content {
        background-color: white;
        padding: 20px;
        border-radius: 15px;
        width: 320px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
        text-align: center;
    }

    .google-btn, .email-btn {
        width: 100%;
        padding: 12px;
        border-radius: 10px;
        margin-bottom: 10px;
        border: 1px solid #ccc;
        background-color: white;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        transition: all 0.2s;
    }

        .google-btn:hover, .email-btn:hover {
            background-color: #f5f5f5;
            border-color: #999;
        }

        .google-btn i, .email-btn i {
            margin-right: 8px;
            font-size: 18px;
        }

    .action-btn {
        width: 100%;
        padding: 12px;
        background: #2C3639;
        color: white;
        border: none;
        border-radius: 10px;
        margin-top: 10px;
        cursor: pointer;
        font-weight: 600;
        transition: background-color 0.2s;
    }

        .action-btn:hover {
            background: #1f2729;
        }

    .input-field {
        width: 100%;
        padding: 12px;
        margin: 5px 0;
        border: 1px solid #ccc;
        border-radius: 10px;
        background-color: #fff;
        box-sizing: border-box;
    }

        .input-field:focus {
            outline: none;
            border-color: #2C3639;
        }

    .password-wrapper {
        position: relative;
    }

    .toggle-password {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        cursor: pointer;
        color: #666;
    }

    /* User Profile Dropdown */
    .user-dropdown-container {
        position: fixed;
        top: 60px;
        right: 20px;
        z-index: 9999;
    }

    .user-dropdown-content {
        background: white;
        border-radius: 12px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
        width: 280px;
        padding: 16px;
    }

    .user-info {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 12px;
    }

    .profile-pic {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        object-fit: cover;
    }

    .user-details {
        flex: 1;
        text-align: left;
    }

    .user-email {
        display: block;
        font-size: 14px;
        color: #2C3639;
        font-weight: 500;
        word-break: break-word;
    }

    .user-dropdown-content hr {
        border: none;
        border-top: 1px solid #e0e0e0;
        margin: 12px 0;
    }

    .dropdown-option {
        width: 100%;
        padding: 12px 16px;
        background: none;
        border: none;
        text-align: left;
        cursor: pointer;
        font-size: 15px;
        display: flex;
        align-items: center;
        gap: 10px;
        border-radius: 6px;
        transition: background-color 0.2s;
        color: #2C3639;
    }

        .dropdown-option:hover {
            background-color: #f5f5f5;
        }

        .dropdown-option.danger {
            color: #d32f2f;
        }

            .dropdown-option.danger:hover {
                background-color: #ffebee;
            }

        .dropdown-option i {
            font-size: 18px;
        }

    /* Header Profile Picture */
    .header-profile-pic {
        width: 30px;
        height: 30px;
        border-radius: 50%;
        object-fit: cover;
        border: 2px solid white;
        transition: transform 0.2s;
    }

        .header-profile-pic:hover {
            transform: scale(1.1);
        }

    #resendVerificationBtn {
        background: #2C3639;
        color: white;
        border: none;
        border-radius: 10px;
        width: 100%;
        padding: 12px;
        cursor: pointer;
        font-weight: 600;
        transition: background-color 0.2s;
    }

        #resendVerificationBtn:disabled {
            background: #999; /* Grey background when disabled */
            cursor: not-allowed;
        }
</style>

<!-- Firebase SDKs -->
<script type="module">
    import {
        GoogleAuthProvider,
        signInWithPopup,
        createUserWithEmailAndPassword,
        signInWithEmailAndPassword,
        sendPasswordResetEmail,
        onAuthStateChanged,
        sendEmailVerification,
    } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-auth.js";

    import { FirebaseManager } from "/Scripts/firebase-init.js";

    // Initialize and wait for Firebase
    console.log('[login_register] Starting initialization...');
    const { app, auth } = await FirebaseManager.initialize();
    console.log('[login_register] Firebase ready, current user:', auth.currentUser?.email || 'None');

    const provider = new GoogleAuthProvider();
    provider.setCustomParameters({ prompt: 'select_account' });

    // Track account check status
    let emailChecked = false;
    let accountExists = false;

    // Check if user is already logged in
    onAuthStateChanged(auth, (user) => {
        console.log('[login_register] Auth state changed:', user ? `Logged in: ${user.email}` : 'No user');
        if (user && user.emailVerified) {
            // Only update UI if email is verified
            updateUIForLoggedInUser(user);
        } else if (user && !user.emailVerified) {
            auth.signOut();
        }
        window.dispatchEvent(new CustomEvent('auth-state-changed', { detail: { user } }));
    });

    // Show/hide dropdowns
    window.showLoginRegisterModal = function () {
        const dropdown = document.getElementById("login_registerModal");
        dropdown.style.display = dropdown.style.display === "none" ? "block" : "none";
        document.getElementById("userProfileDropdown").style.display = "none";
    };
    window.toggleUserDropdown = function () {
        const dropdown = document.getElementById("userProfileDropdown");
        dropdown.style.display = dropdown.style.display === "none" ? "block" : "none";
        document.getElementById("login_registerModal").style.display = "none";
    };
    document.addEventListener("click", (e) => {
        const loginDropdown = document.getElementById("login_registerModal");
        const userDropdown = document.getElementById("userProfileDropdown");
        const loginIcon = document.querySelector('a[onclick*="showLoginRegisterModal"]') || document.querySelector('a[onclick*="toggleUserDropdown"]');
        if (loginIcon && !loginIcon.contains(e.target) && !loginDropdown.contains(e.target) && !userDropdown.contains(e.target)) {
            loginDropdown.style.display = "none";
            userDropdown.style.display = "none";
        }
    });

    // Show email form
    window.showEmailForm = function () {
        document.getElementById("emailAuthForm").style.display = "block";
    };

    // Close login dropdown
    function closeLoginDropdown() {
        document.getElementById("login_registerModal").style.display = "none";
        // Reset form
        document.getElementById("txtEmail").value = "";
        document.getElementById("txtPassword").value = "";
        document.getElementById("txtConfirmPassword").value = "";
        document.getElementById("confirmPasswordWrapper").style.display = "none";
        emailChecked = false;
        accountExists = false;
    }

    // Email field event listener - reset check status when email changes
    document.getElementById("txtEmail").addEventListener("input", function () {
        emailChecked = false;
        accountExists = false;
        document.getElementById("confirmPasswordWrapper").style.display = "none";
    });

    async function postJson(url, data) {
        const resp = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(data)
        });

        const text = await resp.text();

        let json = null;
        try {
            json = JSON.parse(text);
            console.log("[postJson] Parsed JSON:", json);
        } catch (e) {
            console.warn("[postJson] Failed to parse JSON:", e.message);
        }

        return {
            ok: resp.ok,
            status: resp.status,
            data: json,
            text: text
        };
    }

    // Password field event listener - check if account exists when user focuses on password
    document.getElementById("txtEmail").addEventListener("blur", async function () {
        const email = this.value.trim();
        if (!email) return;

        try {
            const res = await fetch("/Handlers/fire_handler.ashx", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ checkEmail: email })
            });
            const data = await res.json();
            accountExists = data.exists;

            console.log("Email exists:", accountExists);
            document.getElementById("confirmPasswordWrapper").style.display = accountExists ? "none" : "block";
            emailChecked = true;
        } catch (err) {
            console.error("Error checking email:", err);
            document.getElementById("confirmPasswordWrapper").style.display = "block";
        }
    });

    // Toggle password visibility
    window.togglePassword = function (textboxId, iconSpan) {
        const txt = document.getElementById(textboxId);
        const icon = iconSpan.querySelector("i");
        txt.type = txt.type === "password" ? "text" : "password";
        icon.className = txt.type === "password" ? "ri-eye-close-line" : "ri-eye-line";
    };

    // Google Login / Signup
    document.getElementById("googleLoginBtn").addEventListener("click", async () => {
        console.log("Beginning signin...")
        try {
            const result = await signInWithPopup(auth, provider);
            const user = result.user;
            await sendTokenToServer(user);

            await postJson("/Handlers/fire_handler.ashx", {
                idToken: await user.getIdToken(true),
                register: true,
                email: user.email
            });

            alert("Logged in successfully with Google!");
            closeLoginDropdown();
        }
        catch (error) {
            if (error.code !== 'auth/popup-closed-by-user' && error.code !== 'auth/cancelled-popup-request') {
                alert("Google login failed: " + error.message);
            }
        }
    });

    let newlyCreatedUser = null;
    const resendBtn = document.getElementById("resendVerificationBtn");
    resendBtn.lastSent = 0;
    resendBtn.baseCooldown = 30_000;
    resendBtn.attempts = 0;

    let lastVerificationSent = 0;

    resendBtn.onclick = async () => {
        const user = auth.currentUser || newlyCreatedUser;
        if (!user) return alert("No user available for verification email.");

        resendBtn.disabled = true;
        resendBtn.textContent = "Sending verification email...";

        try {
            await sendEmailVerification(user, { url: window.location.origin + "/Pages/Customer/catalogue.aspx" });
            alert("Verification email resent. Please check your inbox.");
            lastVerificationSent = Date.now();
        } catch (err) {
            if (err.code === "auth/too-many-requests") {
                const now = Date.now();
                const waitTime = Math.max(60_000 - (now - lastVerificationSent), 0);
                const seconds = Math.ceil(waitTime / 1000);
                alert(`Too many verification requests. Please wait ${seconds} second(s) before trying again.`);
            } else {
                alert("Failed to resend verification email: " + err.message);
            }
        } finally {
            resendBtn.disabled = false;
            resendBtn.textContent = "Resend Verification Email";
        }
    };

    // Main submitAuth function
    window.submitAuth = async function () {
        const email = document.getElementById("txtEmail").value.trim();
        const password = document.getElementById("txtPassword").value;
        const confirmPassword = document.getElementById("txtConfirmPassword").value;

        if (!email || !password) {
            alert("Please enter both email and password.");
            return;
        }

        const confirmWrapper = document.getElementById("confirmPasswordWrapper");
        if (!accountExists && confirmWrapper.style.display !== "none") {
            if (!confirmPassword) return alert("Please confirm your password.");
            if (password !== confirmPassword) return alert("Passwords do not match. Please try again.");
        }

        try {
            if (accountExists) {
                const userCred = await signInWithEmailAndPassword(auth, email, password);
                const user = userCred.user;

                if (!user.emailVerified) {
                    alert("Email not verified. Please verify your email first.\nCheck your spam folder!");
                    resendBtn.style.display = "block";
                    newlyCreatedUser = user;
                    auth.signOut();
                    return;
                }

                await sendTokenToServer(user);
                alert("Logged in successfully with email!");
                closeLoginDropdown();

            } else {
                const userCred = await createUserWithEmailAndPassword(auth, email, password);
                const user = userCred.user;

                newlyCreatedUser = user;
                await sendEmailVerification(user, { url: window.location.origin + "/Pages/Customer/catalogue.aspx" });
                alert("Account created! A verification email has been sent.");

                await postJson("/Handlers/fire_handler.ashx", {
                    idToken: await user.getIdToken(true),
                    register: true,
                    email: user.email
                });

                resendBtn.style.display = "block";
                accountExists = true;
                emailChecked = true;
                confirmWrapper.style.display = "none";

                auth.signOut().then(() => location.reload());
            }
        } catch (error) {
            switch (error.code) {
                case "auth/wrong-password":
                case "auth/invalid-credential":
                    alert("Incorrect password. Please try again.");
                    break;
                case "auth/email-already-in-use":
                    accountExists = true;
                    emailChecked = true;
                    confirmWrapper.style.display = "none";

                    try {
                        const userCred = await signInWithEmailAndPassword(auth, email, password);
                        const user = userCred.user;

                        if (user.emailVerified) {
                            await sendTokenToServer(user);
                            closeLoginDropdown();
                        } else {
                            alert("Email not verified. Please check inbox or resend verification email.");
                            resendBtn.style.display = "block";
                            newlyCreatedUser = user;
                        }
                    } catch (loginErr) {
                        if (loginErr.code === "auth/wrong-password" || loginErr.code === "auth/invalid-credential") {
                            alert("Incorrect password. Please try again.");
                        } else {
                            alert("Automatic login failed: " + loginErr.message);
                        }
                    }
                    break;
                case "auth/weak-password":
                    alert("Password too short. Minimum 6 characters required.");
                    break;
                case "auth/invalid-email":
                    alert("Please enter a valid email address.");
                    break;
                default:
                    alert("Authentication failed: " + error.message);
            }
        }
    };

    // Forgot Password
    document.getElementById("forgotPasswordLink").addEventListener("click", async (e) => {
        e.preventDefault();
        const email = document.getElementById("txtEmail").value.trim();
        if (!email) {
            alert("Please enter your email first.");
            return;
        }

        try {
            await sendPasswordResetEmail(auth, email);
            alert("Password reset email sent. Check your inbox.");
        } catch (error) {
            switch (error.code) {
                case "auth/invalid-email":
                    alert("Please enter a valid email address.");
                    break;
                case "auth/user-not-found":
                    alert("No account found with this email.");
                    break;
                default:
                    alert("Error sending reset email: " + error.message);
            }
        }
    });

    // Send token to server
    async function sendTokenToServer(user) {
        try {
            const token = await user.getIdToken(true);

            const payload = { idToken: token };

            const resp = await postJson("/Handlers/fire_handler.ashx", payload);

            if (!resp.ok) {
                console.error("❌ sendTokenToServer failed - HTTP", resp.status);
                console.error("Response body:", resp.text);
                alert("Failed to save user data to server. Please contact support.");
                return { success: false, isStaff: false, isAdmin: false };
            }

            const data = resp.data;
            console.log("Parsed response data:", data);

            if (data && data.success) {
                return {
                    success: true,
                    isStaff: data.isStaff === true,
                    isAdmin: data.isAdmin === true
                };
            } else {
                console.warn("Server returned success=false or missing:", data);
                if (data && data.message) {
                    console.error("Server message:", data.message);
                    alert("Error saving user: " + data.message);
                }
                return { success: false, isStaff: false, isAdmin: false };
            }
        } catch (err) {
            console.error("Token generation/send exception:", err);
            alert("Error communicating with server: " + err.message);
            return { success: false, isStaff: false, isAdmin: false };
        }
    }

    // Update UI for logged-in user
    async function updateUIForLoggedInUser(user) {
        const loginButton = document.querySelector('a[onclick*="showLoginRegisterModal"]');
        const userEmail = user.email.trim().toLowerCase();
        const gravatar = 'https://www.gravatar.com/avatar/' + md5(userEmail) + '?d=identicon&s=40';
        const cacheKey = 'profilePic_' + userEmail;
        let cachedPic = localStorage.getItem(cacheKey);
        const fallbackPic = gravatar;

        function setProfilePic(url) {
            loginButton.innerHTML = '<img src="' + url + '" alt="Profile" class="header-profile-pic" />';
            loginButton.setAttribute('onclick', 'toggleUserDropdown()');
            loginButton.setAttribute('data-tooltip', 'Account');
            document.getElementById('userProfilePic').src = url;
            document.getElementById('userEmail').textContent = user.email;
        }

        if (cachedPic) setProfilePic(cachedPic);
        if (user.photoURL) {
            const img = new Image();
            img.onload = function () { setProfilePic(user.photoURL); localStorage.setItem(cacheKey, user.photoURL); };
            img.onerror = function () { setProfilePic(fallbackPic); localStorage.setItem(cacheKey, fallbackPic); };
            img.src = user.photoURL;
        } else {
            setProfilePic(fallbackPic);
            localStorage.setItem(cacheKey, fallbackPic);
        }

        const result = await sendTokenToServer(user);

        const switchBtn = document.getElementById("switchToWorkBtn");
        if (switchBtn && result.isStaff) {
            switchBtn.style.display = "flex";
            await updateSwitchButtonText();
        }
    }

    async function updateSwitchButtonText() {
        try {
            const response = await fetch("/Handlers/set_work_view.ashx");
            const data = await response.json();
            const switchBtn = document.getElementById("switchToWorkBtn");

            if (data.view === "work") {
                switchBtn.innerHTML = '<i class="ri-toggle-fill"></i>Switch to Customer Account';
            } else {
                switchBtn.innerHTML = '<i class="ri-toggle-line"></i>Switch to Work Account';
            }
        } catch (err) {
            console.error("Error getting view:", err);
        }
    }

    window.switchWorkAccount = async function () {
        const response = await fetch("/Handlers/set_work_view.ashx", { method: "POST" });
        const data = await response.json();
        if (data.success && data.redirectUrl) {
            window.location.href = data.redirectUrl;
        } else {
            window.location.reload();
        }
    };

    window.viewProfile = function () { window.location.href = '/Pages/Customer/profile.aspx'; };

    window.logout = function () {
        if (confirm('Are you sure you want to log out?')) {
            // Restore guest data before logging out
            if (typeof window.restoreGuestDataOnLogout === 'function') {
                window.restoreGuestDataOnLogout();
                console.log('Guest data restored for next session');
            }

            auth.signOut()
                .then(() => {
                    console.log('User logged out successfully');
                    location.reload();
                })
                .catch(err => {
                    console.error('Logout error:', err);
                    alert('Logout failed: ' + err.message);
                });
        }
    };

    window.deleteAccount = async () => {
        if (!confirm("Are you sure you want to delete your account? This action cannot be undone.")) return;

        const currentUser = auth.currentUser;
        if (!currentUser) {
            alert("No user is logged in.");
            return;
        }

        try {
            const token = await currentUser.getIdToken(true);

            const response = await fetch("/Handlers/fire_handler.ashx", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ idToken: token, deleteAccount: true })
            });

            const result = await response.json();
            console.log("Handler response:", result);

            if (result.success) {
                auth.signOut().then(() => location.reload()).catch(err => alert('Logout of deleted account failed: ' + err.message));
                alert("Account deleted successfully.");
            } else {
                alert("Delete failed: " + result.message);
            }
        } catch (error) {
            console.error("deleteAccount error:", error);
            alert("Error deleting account.");
        }
    };

    function md5(string) { return string.split('').reduce((a, b) => { a = ((a << 5) - a) + b.charCodeAt(0); return a & a; }, 0).toString(16); }

    document.getElementById("txtEmail").addEventListener("keydown", function (e) {
        if (e.key === "Enter") {
            e.preventDefault();
            document.getElementById("txtPassword").focus();
        }
    });

    document.getElementById("txtPassword").addEventListener("keydown", function (e) {
        if (e.key === "Enter") {
            e.preventDefault();
            const confirmWrapper = document.getElementById("confirmPasswordWrapper");

            if (confirmWrapper.style.display === "block") {
                const confirmInput = document.getElementById("txtConfirmPassword");
                confirmInput.focus();
                confirmInput.select();
            } else {
                submitAuth();
            }
        }
    });

    document.getElementById("txtConfirmPassword").addEventListener("keydown", function (e) {
        if (e.key === "Enter") {
            e.preventDefault();
            submitAuth();
        }
    });
</script>
