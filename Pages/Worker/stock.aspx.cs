using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Opton.Pages.Worker
{
    public partial class stock : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is staff
            if (Session["isStaff"] == null || !(bool)Session["isStaff"])
            {
                Response.Redirect("~/Pages/Customer/catalogue.aspx");
                return;
            }
        }
    }
}