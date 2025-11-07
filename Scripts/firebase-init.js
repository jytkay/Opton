// Scripts/firebase-init.js - IMPROVED VERSION
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-app.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-auth.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.14.0/firebase-firestore.js";

// Central state management
const FirebaseManager = {
    app: null,
    auth: null,
    db: null,
    isInitialized: false,
    isInitializing: false,
    initPromise: null,
    readyCallbacks: [],

    // Initialize Firebase (idempotent - safe to call multiple times)
    async initialize() {
        // If already initialized, return immediately
        if (this.isInitialized) {
            console.log('[FirebaseManager] Already initialized');
            return { app: this.app, auth: this.auth, db: this.db };
        }

        // If currently initializing, wait for that to complete
        if (this.isInitializing && this.initPromise) {
            console.log('[FirebaseManager] Waiting for existing initialization...');
            return this.initPromise;
        }

        // Start initialization
        this.isInitializing = true;
        console.log('[FirebaseManager] Starting initialization...');

        this.initPromise = this._doInitialize();
        return this.initPromise;
    },

    async _doInitialize() {
        try {
            // Fetch API key
            console.log('[FirebaseManager] Fetching API key...');
            const res = await fetch('/Handlers/get_keys.ashx');
            const data = await res.json();

            if (!data.success || !data.apiKeys.FIREBASE_API_KEY) {
                throw new Error("Failed to load Firebase API key");
            }

            const apiKey = data.apiKeys.FIREBASE_API_KEY.replace(/"/g, '');
            console.log('[FirebaseManager] API key retrieved');

            // Firebase config
            const firebaseConfig = {
                apiKey: apiKey,
                authDomain: "opton-e4a46.firebaseapp.com",
                projectId: "opton-e4a46"
            };

            // Initialize Firebase
            console.log('[FirebaseManager] Initializing Firebase app...');
            this.app = initializeApp(firebaseConfig);
            this.auth = getAuth(this.app);
            this.db = getFirestore(this.app);

            // Set global variables for backward compatibility
            window._firebaseApp = this.app;
            window._firebaseAuth = this.auth;
            window._firebaseDb = this.db;
            window._firebaseReady = true;

            this.isInitialized = true;
            this.isInitializing = false;

            console.log('[FirebaseManager] Initialization complete');
            console.log('[FirebaseManager] Auth object:', !!this.auth);
            console.log('[FirebaseManager] Current user:', this.auth.currentUser?.email || 'None');

            // Notify all waiting callbacks
            this.readyCallbacks.forEach(callback => {
                try {
                    callback({ app: this.app, auth: this.auth, db: this.db });
                } catch (err) {
                    console.error('[FirebaseManager] Error in ready callback:', err);
                }
            });
            this.readyCallbacks = [];

            return { app: this.app, auth: this.auth, db: this.db };

        } catch (err) {
            this.isInitializing = false;
            this.initPromise = null;
            console.error('[FirebaseManager] Initialization failed:', err);
            throw err;
        }
    },

    // Register a callback to run when Firebase is ready
    onReady(callback) {
        if (this.isInitialized) {
            // Already ready, call immediately
            callback({ app: this.app, auth: this.auth, db: this.db });
        } else {
            // Queue for later
            this.readyCallbacks.push(callback);
        }
    },

    // Get auth instance (wait if necessary)
    async getAuth() {
        if (!this.isInitialized) {
            await this.initialize();
        }
        return this.auth;
    },

    // Get current user with proper waiting
    async getCurrentUser() {
        const auth = await this.getAuth();

        // If user is already loaded, return immediately
        if (auth.currentUser !== undefined) {
            return auth.currentUser;
        }

        // Otherwise, wait for auth state to be determined
        return new Promise((resolve) => {
            const unsubscribe = auth.onAuthStateChanged((user) => {
                unsubscribe();
                resolve(user);
            });
        });
    },

    // Get ID token (handles all the complexity)
    async getIdToken() {
        try {
            const user = await this.getCurrentUser();
            if (!user) {
                console.log('[FirebaseManager] No authenticated user');
                return null;
            }

            const token = await user.getIdToken();
            console.log('[FirebaseManager] Token retrieved for user:', user.email);
            return token;
        } catch (err) {
            console.error('[FirebaseManager] Error getting token:', err);
            return null;
        }
    }
};

// Auto-initialize on module load
console.log('[firebase-init.js] Module loaded, auto-initializing...');
FirebaseManager.initialize().catch(err => {
    console.error('[firebase-init.js] Auto-initialization failed:', err);
});

// Export both the manager and a legacy function for backward compatibility
export { FirebaseManager };
export async function initFirebase() {
    return FirebaseManager.initialize();
}