using System;
using System.Web;

namespace Opton.Handlers
{
    public class set_work_view : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.Clear();
            context.Response.ContentType = "application/json";
            context.Response.TrySkipIisCustomErrors = true;

            try
            {
                string method = context.Request.HttpMethod;

                if (method == "GET")
                {
                    string view = context.Session["view"] as string ?? "customer";
                    context.Response.Write("{\"view\":\"" + view + "\"}");
                }
                else if (method == "POST")
                {
                    string currentView = context.Session["view"] as string;
                    string redirectUrl;

                    if (currentView == "work")
                    {
                        context.Session["view"] = "customer";
                        redirectUrl = "/Pages/Customer/catalogue.aspx";
                    }
                    else
                    {
                        context.Session["view"] = "work";

                        bool isAdmin = context.Session["isAdmin"] as bool? ?? false;
                        bool isStaff = context.Session["isStaff"] as bool? ?? false;

                        if (isAdmin)
                            redirectUrl = "/Pages/Admin/dashboard.aspx";
                        else if (isStaff)
                            redirectUrl = "/Pages/Worker/orders.aspx";
                        else
                            redirectUrl = "/Pages/Customer/catalogue.aspx";
                    }

                    context.Response.Write("{\"success\":true,\"redirectUrl\":\"" + redirectUrl + "\"}");
                }
                else
                {
                    // prevent silent crash on OPTIONS, HEAD, etc.
                    context.Response.Write("{\"error\":\"Unsupported method\"}");
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":\"" + ex.Message + "\"}");
            }
        }

        public bool IsReusable => false;
    }
}