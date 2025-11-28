using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;

namespace Opton.Handlers
{
    /// <summary>
    /// Summary description for send_email_handler
    /// </summary>
    public class send_email_handler : HttpTaskAsyncHandler
    {

        private static readonly JavaScriptSerializer serializer = new JavaScriptSerializer();

        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                // Read request body
                string requestBody;
                using (var reader = new StreamReader(context.Request.InputStream))
                {
                    requestBody = await reader.ReadToEndAsync();
                }

                var data = serializer.Deserialize<Dictionary<string, object>>(requestBody);

                string action = data.ContainsKey("action") ? data["action"].ToString() : "";

                if (action == "sendAppointmentEmail")
                {
                    var result = await SendAppointmentEmail(
                        data["userEmail"].ToString(),
                        data["userName"].ToString(),
                        data["appointmentType"].ToString(),
                        data["appointmentDate"].ToString(),
                        data["appointmentTime"].ToString(),
                        data["retailerName"].ToString(),
                        data["retailerAddress"].ToString()
                    );
                    context.Response.Write(serializer.Serialize(result));
                }
                else if (action == "sendOrderEmail")
                {
                    var result = await SendOrderEmail(
                        data["userEmail"].ToString(),
                        data["userName"].ToString(),
                        data["orderId"].ToString(),
                        data["orderDate"].ToString(),
                        data["items"].ToString(),
                        data["subtotal"].ToString(),
                        data["shipping"].ToString(),
                        data["total"].ToString()
                    );
                    context.Response.Write(serializer.Serialize(result));
                }
                else if (action == "sendOTP")
                {
                    // Keep your existing OTP logic here if needed
                    context.Response.Write(serializer.Serialize(new { success = false, message = "OTP not implemented yet" }));
                }
                else
                {
                    context.Response.Write(serializer.Serialize(new { success = false, message = "Unknown action" }));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EMAIL HANDLER ERROR] {ex}");
                context.Response.Write(serializer.Serialize(new
                {
                    success = false,
                    message = ex.Message,
                    stackTrace = ex.StackTrace
                }));
            }
        }

        private async Task<Dictionary<string, object>> SendOrderEmail(
            string userEmail,
            string userName,
            string orderId,
            string orderDate,
            string items,
            string subtotal,
            string shipping,
            string total)
        {
            try
            {
                // Get API keys
                var keys = await GetApiKeysAsync();

                System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL] Starting email send process");
                System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL] To: {userEmail}, Name: {userName}");
                System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL] Order ID: {orderId}");

                // Create the email JSON payload for SendGrid API v3
                var emailPayload = new
                {
                    personalizations = new[]
                    {
                        new
                        {
                            to = new[] { new { email = userEmail, name = userName } },
                            subject = $"Order Confirmation - {orderId}"
                        }
                    },
                    from = new { email = "opton5854@gmail.com", name = "Opton Store" },
                    content = new[]
                    {
                        new
                        {
                            type = "text/plain",
                            value = $"Hi {userName},\n\nThank you for your order! Your order has been confirmed.\n\n" +
                                    $"Order ID: {orderId}\n" +
                                    $"Order Date: {orderDate}\n\n" +
                                    $"Items:\n{items}\n" +
                                    $"Subtotal: RM {subtotal}\n" +
                                    $"Shipping: RM {shipping}\n" +
                                    $"Total: RM {total}\n\n" +
                                    $"We'll send you another email when your order ships.\n\n" +
                                    $"Thank you for choosing Opton!"
                        },
                        new
                        {
                            type = "text/html",
                            value = $@"
                                <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                                    <h2 style='color: #2C3639;'>Order Confirmation</h2>
                                    <p>Hi {userName},</p>
                                    <p>Thank you for your order! Your order has been confirmed.</p>
                                    
                                    <div style='background-color: #f5f5f5; padding: 15px; border-radius: 8px; margin: 20px 0;'>
                                        <p style='margin: 5px 0;'><strong>Order ID:</strong> {orderId}</p>
                                        <p style='margin: 5px 0;'><strong>Order Date:</strong> {orderDate}</p>
                                    </div>
                                    
                                    <div style='margin: 20px 0;'>
                                        <h3 style='color: #2C3639;'>Order Items</h3>
                                        <div style='background-color: #f9f9f9; padding: 15px; border-radius: 8px;'>
                                            <pre style='margin: 0; white-space: pre-wrap; font-family: Arial, sans-serif;'>{items}</pre>
                                        </div>
                                    </div>
                                    
                                    <div style='background-color: #f5f5f5; padding: 15px; border-radius: 8px; margin: 20px 0;'>
                                        <table style='width: 100%;'>
                                            <tr>
                                                <td style='padding: 5px;'>Subtotal:</td>
                                                <td style='padding: 5px; text-align: right;'>RM {subtotal}</td>
                                            </tr>
                                            <tr>
                                                <td style='padding: 5px;'>Shipping:</td>
                                                <td style='padding: 5px; text-align: right;'>RM {shipping}</td>
                                            </tr>
                                            <tr style='font-weight: bold; font-size: 18px; border-top: 2px solid #2C3639;'>
                                                <td style='padding: 10px 5px 5px 5px;'>Total:</td>
                                                <td style='padding: 10px 5px 5px 5px; text-align: right; color: #A27B5C;'>RM {total}</td>
                                            </tr>
                                        </table>
                                    </div>
                                    
                                    <p>We'll send you another email when your order ships.</p>
                                    <p style='color: #666; font-size: 14px; margin-top: 30px;'>Thank you for choosing Opton!</p>
                                </div>"
                        }
                    }
                };

                // Send via SendGrid API
                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {keys["SENDGRID_KEY"]}");

                    var json = serializer.Serialize(emailPayload);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL] Sending request to SendGrid...");
                    System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL] Payload size: {json.Length} bytes");

                    var response = await client.PostAsync("https://api.sendgrid.com/v3/mail/send", content);
                    var responseBody = await response.Content.ReadAsStringAsync();

                    System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL] Response Status: {response.StatusCode}");
                    System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL] Response Body: {responseBody}");

                    bool success = response.StatusCode == HttpStatusCode.Accepted || response.StatusCode == HttpStatusCode.OK;

                    return new Dictionary<string, object>
                    {
                        { "success", success },
                        { "status", response.StatusCode.ToString() },
                        { "message", success ? "Order email sent successfully" : responseBody }
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL ERROR] {ex}");
                return new Dictionary<string, object>
                {
                    { "success", false },
                    { "message", ex.Message },
                    { "stackTrace", ex.StackTrace }
                };
            }
        }

        private async Task<Dictionary<string, object>> SendAppointmentEmail(
            string userEmail,
            string userName,
            string appointmentType,
            string appointmentDate,
            string appointmentTime,
            string retailerName,
            string retailerAddress)
        {
            try
            {
                // Get API keys
                var keys = await GetApiKeysAsync();

                System.Diagnostics.Debug.WriteLine($"[EMAIL] Starting email send process");
                System.Diagnostics.Debug.WriteLine($"[EMAIL] To: {userEmail}, Name: {userName}");
                System.Diagnostics.Debug.WriteLine($"[EMAIL] SendGrid Key Length: {keys["SENDGRID_KEY"].Length}");

                // Parse appointment time
                DateTime startTime = DateTime.Parse($"{appointmentDate} {appointmentTime}");
                DateTime endTime = startTime.AddMinutes(30);

                System.Diagnostics.Debug.WriteLine($"[EMAIL] Appointment: {startTime} to {endTime}");

                // Create ICS calendar file
                string icsContent = $@"BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Opton//Appointment Scheduler//EN
CALSCALE:GREGORIAN
METHOD:REQUEST
BEGIN:VEVENT
UID:{Guid.NewGuid()}@opton.com
DTSTAMP:{DateTime.UtcNow:yyyyMMddTHHmmssZ}
DTSTART:{startTime.ToUniversalTime():yyyyMMddTHHmmssZ}
DTEND:{endTime.ToUniversalTime():yyyyMMddTHHmmssZ}
SUMMARY:Opton {appointmentType} Appointment
DESCRIPTION:Your appointment at {retailerName}
LOCATION:{retailerAddress}
STATUS:CONFIRMED
SEQUENCE:0
BEGIN:VALARM
TRIGGER:-PT15M
ACTION:DISPLAY
DESCRIPTION:Reminder
END:VALARM
END:VEVENT
END:VCALENDAR";

                // Create the email JSON payload for SendGrid API v3
                var emailPayload = new
                {
                    personalizations = new[]
                    {
                        new
                        {
                            to = new[] { new { email = userEmail, name = userName } },
                            subject = $"Your {appointmentType} Appointment Confirmation"
                        }
                    },
                    from = new { email = "opton5854@gmail.com", name = "Opton Appointments" },
                    content = new[]
                    {
                        new
                        {
                            type = "text/plain",
                            value = $"Hi {userName},\n\nYour {appointmentType} appointment is confirmed!\n\n" +
                                    $"Date: {appointmentDate}\n" +
                                    $"Time: {appointmentTime}\n\n" +
                                    $"Location:\n{retailerName}\n{retailerAddress}\n\n" +
                                    $"A calendar invitation is attached to this email.\n\n" +
                                    $"Thank you for choosing Opton!"
                        },
                        new
                        {
                            type = "text/html",
                            value = $@"
                                <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                                    <h2 style='color: #2C3639;'>Hi {userName},</h2>
                                    <p>Your <strong>{appointmentType}</strong> appointment is confirmed!</p>
                                    
                                    <div style='background-color: #f5f5f5; padding: 15px; border-radius: 8px; margin: 20px 0;'>
                                        <p style='margin: 5px 0;'><strong>Date:</strong> {appointmentDate}</p>
                                        <p style='margin: 5px 0;'><strong>Time:</strong> {appointmentTime}</p>
                                    </div>
                                    
                                    <div style='margin: 20px 0;'>
                                        <p style='margin: 5px 0;'><strong>Location:</strong></p>
                                        <p style='margin: 5px 0;'>{retailerName}</p>
                                        <p style='margin: 5px 0; color: #666;'>{retailerAddress}</p>
                                    </div>
                                    
                                    <p>A calendar invitation is attached to this email.</p>
                                    <p style='color: #666; font-size: 14px; margin-top: 30px;'>Thank you for choosing Opton!</p>
                                </div>"
                        }
                    },
                    attachments = new[]
                    {
                        new
                        {
                            content = Convert.ToBase64String(Encoding.UTF8.GetBytes(icsContent)),
                            filename = "appointment.ics",
                            type = "text/calendar",
                            disposition = "attachment"
                        }
                    }
                };

                // Send via SendGrid API
                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {keys["SENDGRID_KEY"]}");

                    var json = serializer.Serialize(emailPayload);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    System.Diagnostics.Debug.WriteLine($"[EMAIL] Sending request to SendGrid...");
                    System.Diagnostics.Debug.WriteLine($"[EMAIL] Payload size: {json.Length} bytes");

                    var response = await client.PostAsync("https://api.sendgrid.com/v3/mail/send", content);
                    var responseBody = await response.Content.ReadAsStringAsync();

                    System.Diagnostics.Debug.WriteLine($"[EMAIL] Response Status: {response.StatusCode}");
                    System.Diagnostics.Debug.WriteLine($"[EMAIL] Response Body: {responseBody}");

                    bool success = response.StatusCode == HttpStatusCode.Accepted || response.StatusCode == HttpStatusCode.OK;

                    return new Dictionary<string, object>
                    {
                        { "success", success },
                        { "status", response.StatusCode.ToString() },
                        { "message", success ? "Email sent successfully" : responseBody }
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EMAIL ERROR] {ex}");
                return new Dictionary<string, object>
                {
                    { "success", false },
                    { "message", ex.Message },
                    { "stackTrace", ex.StackTrace }
                };
            }
        }

        private static async Task<Dictionary<string, string>> GetApiKeysAsync()
        {
            using (var client = new HttpClient())
            {
                string baseUrl = HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority);
                string url = $"{baseUrl}/Handlers/get_keys.ashx";

                var response = await client.GetAsync(url);
                string json = await response.Content.ReadAsStringAsync();

                var result = serializer.Deserialize<Dictionary<string, object>>(json);

                if ((bool)result["success"])
                {
                    var apiKeys = new Dictionary<string, string>();
                    var keysDict = (Dictionary<string, object>)result["apiKeys"];
                    foreach (var key in keysDict.Keys)
                        apiKeys[key] = keysDict[key].ToString();
                    return apiKeys;
                }

                throw new Exception("Failed to load API keys: " + result["message"]);
            }
        }

        public override bool IsReusable
        {
            get { return false; }
        }
    }
}