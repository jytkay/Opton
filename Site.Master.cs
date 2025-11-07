using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Api;
using Google.Apis.Auth.OAuth2;
using Google.Cloud.Firestore;
using System;
using System.Diagnostics;

namespace Opton
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        public static FirestoreDb FirestoreDbInstance { get; private set; }
        private static bool firebaseAuthInitialized = false;

        protected void Page_Init(object sender, EventArgs e)
        {
            InitialiseFirestore();
            InitialiseFirebaseAuth();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SetupNavButtons();
            }
        }

        private void InitialiseFirestore()
        {
            if (FirestoreDbInstance == null)
            {
                string credentialsPath = Server.MapPath("~/App_Data/opton-firebase-adminsdk.json");
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialsPath);

                FirestoreDbInstance = FirestoreDb.Create("opton-e4a46");
            }
        }

        private static readonly object firebaseLock = new object();
        private void InitialiseFirebaseAuth()
        {
            if (!firebaseAuthInitialized)
            {
                lock (firebaseLock)
                {
                    if (!firebaseAuthInitialized) // double-check lock
                    {
                        string credentialsPath = Server.MapPath("~/App_Data/opton-firebase-adminsdk.json");

                        var credential = Google.Apis.Auth.OAuth2.CredentialFactory
                            .FromFile<Google.Apis.Auth.OAuth2.ServiceAccountCredential>(credentialsPath)
                            .ToGoogleCredential();

                        try
                        {
                            if (FirebaseApp.DefaultInstance == null)
                            {
                                FirebaseApp.Create(new AppOptions() { Credential = credential });
                                Debug.WriteLine("[FirebaseAuth] Initialized successfully.");
                            }
                        }
                        catch (ArgumentException)
                        {
                            // Default app already exists, ignore
                            Debug.WriteLine("[FirebaseAuth] Default instance already exists.");
                        }

                        firebaseAuthInitialized = true;
                    }
                }
            }
        }

        protected void SetupNavButtons()
        {
            // Change to lowercase "isStaff" and "isAdmin" to match what fire_handler.ashx sets
            var isStaff = Session["isStaff"] != null && (bool)Session["isStaff"];
            var isAdmin = Session["isAdmin"] != null && (bool)Session["isAdmin"];
            var isWorkAccount = Session["view"] != null && Session["view"].ToString() == "work";

            customerNavButtons.Visible = true;
            workerNavButtons.Visible = false;
            adminNavButtons.Visible = false;

            if (isStaff && isWorkAccount)
            {
                customerNavButtons.Visible = false;
                workerNavButtons.Visible = true;

                if (isAdmin)
                {
                    adminNavButtons.Visible = true;
                }
            }

            // Change header bar colour for work account
            if (isWorkAccount)
            {
                logoImg.Src = ResolveUrl("~/Assets/logo2.png");
                headerBar.Style["background-color"] = "var(--color-light)";
            }
            else
            {
                headerBar.Style["background-color"] = "var(--color-dark)";
                logoImg.Src = ResolveUrl("~/Assets/logo.png");
            }
        }
    }
}
