using FirebaseAdmin.Auth;
using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Web;

namespace Opton.Pages.Customer
{
    public partial class product : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string productId = Request.QueryString["id"];

            if (string.IsNullOrEmpty(productId))
            {
                Response.Redirect(ResolveUrl("~/Pages/Customer/catalogue.aspx"), false);
                HttpContext.Current.ApplicationInstance.CompleteRequest();
                return;
            }
        }
    }
}
