using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;

namespace Opton.Handlers
{
    public class get_keys : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            var keys = new Dictionary<string, string>();

            try
            {
                string path = context.Server.MapPath("~/App_Data/apikeys.txt");

                if (File.Exists(path))
                {
                    foreach (var line in File.ReadAllLines(path))
                    {
                        var parts = line.Split(new[] { '=' }, 2);
                        if (parts.Length == 2)
                        {
                            keys[parts[0].Trim()] = parts[1].Trim();
                        }
                    }

                    var serializer = new JavaScriptSerializer();
                    context.Response.Write(serializer.Serialize(new
                    {
                        success = true,
                        apiKeys = keys
                    }));
                }
                else
                {
                    context.Response.Write("{\"success\":false,\"message\":\"apikeys.txt not found.\"}");
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"success\":false,\"message\":\"" + ex.Message + "\"}");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}