using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Opton.Pages.Admin
{
    public partial class dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is staff/admin
            if (Session["isAdmin"] == null || !(bool)Session["isAdmin"])
            {
                Response.Redirect("~/Pages/catalogue.aspx");
                return;
            }
        }
    }
}