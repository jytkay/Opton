using FirebaseAdmin.Auth;
using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using Twilio;
using Twilio.Rest.Verify.V2.Service;

namespace Opton.Pages.Customer
{
    public partial class appointment : System.Web.UI.Page
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            string retailerId = Request.QueryString["retailerId"];

            if (string.IsNullOrEmpty(retailerId))
            {
                Response.Redirect(ResolveUrl("~/Pages/Customer/find_retailers.aspx"), false);
                HttpContext.Current.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                string retailerName = Request.QueryString["retailerName"];
                retailerNameLiteral.Text = Server.UrlDecode(retailerName);

                await LoadRetailerDetails(retailerId);
            }
        }

        private async Task LoadRetailerDetails(string retailerId)
        {
            try
            {
                var db = SiteMaster.FirestoreDbInstance;
                var doc = await db.Collection("Retailers").Document(retailerId).GetSnapshotAsync();

                if (doc.Exists)
                {
                    retailerAddress.InnerText = doc.GetValue<string>("address");
                    retailerPhone.InnerText = doc.GetValue<long>("phoneNo").ToString();

                    Dictionary<string, string> openingHours = new Dictionary<string, string>();

                    if (doc.ContainsField("openingHours"))
                    {
                        var rawHours = doc.GetValue<Dictionary<string, object>>("openingHours");
                        if (rawHours != null)
                        {
                            foreach (var kv in rawHours)
                            {
                                openingHours[kv.Key] = kv.Value?.ToString() ?? "";
                            }
                        }
                    }

                    string openingHoursJson = Newtonsoft.Json.JsonConvert.SerializeObject(openingHours);
                    Page.ClientScript.RegisterStartupScript(
                        this.GetType(),
                        "openingHoursData",
                        $"var retailerOpeningHours = {openingHoursJson};",
                        true
                    );
                }
                else
                {
                    retailerAddress.InnerText = "Address not available";
                    retailerPhone.InnerText = "Phone not available";
                    Page.ClientScript.RegisterStartupScript(
                        this.GetType(),
                        "openingHoursData",
                        "var retailerOpeningHours = {};",
                        true
                    );
                }
            }
            catch (Exception ex)
            {
                retailerAddress.InnerText = "Error loading address";
                retailerPhone.InnerText = "Error loading phone";
                System.Diagnostics.Debug.WriteLine("[Retailer] Error: " + ex.Message);
                Page.ClientScript.RegisterStartupScript(
                    this.GetType(),
                    "openingHoursData",
                    "var retailerOpeningHours = {};",
                    true
                );
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

                var serializer = new JavaScriptSerializer();
                dynamic result = serializer.Deserialize<dynamic>(json);

                if (result["success"])
                {
                    var apiKeys = new Dictionary<string, string>();
                    foreach (var key in result["apiKeys"].Keys)
                        apiKeys[key] = result["apiKeys"][key];
                    return apiKeys;
                }

                throw new Exception("Failed to load API keys: " + result["message"]);
            }
        }

        // 🧾 Send OTP (SMS or Email)
        [System.Web.Services.WebMethod]
        public static async Task<string> SendOTP(string contact)
        {
            try
            {
                var keys = await GetApiKeysAsync();

                System.Diagnostics.Debug.WriteLine($"[OTP] TWILIO_SID: {keys["TWILIO_SID"].Substring(0, 6)}...");
                System.Diagnostics.Debug.WriteLine($"[OTP] VERIFY_SID: {keys["VERIFY_SID"].Substring(0, 6)}...");
                System.Diagnostics.Debug.WriteLine($"[OTP] Sending OTP to: {contact}");

                TwilioClient.Init(keys["TWILIO_SID"], keys["TWILIO_AUTH"]);

                var verification = VerificationResource.Create(
                    to: contact,
                    channel: contact.Contains("@") ? "email" : "sms",
                    pathServiceSid: keys["VERIFY_SID"]
                );

                System.Diagnostics.Debug.WriteLine($"[OTP] Sent successfully. SID={verification.Sid}, Status={verification.Status}");

                return new JavaScriptSerializer().Serialize(new
                {
                    success = true,
                    sid = verification.Sid,
                    status = verification.Status
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[OTP ERROR] {ex}");
                return new JavaScriptSerializer().Serialize(new
                {
                    success = false,
                    message = ex.Message
                });
            }
        }

        // 🧾 Verify OTP
        [System.Web.Services.WebMethod]
        public static async Task<string> VerifyOTP(string contact, string code)
        {
            try
            {
                var keys = await GetApiKeysAsync();
                TwilioClient.Init(keys["TWILIO_SID"], keys["TWILIO_AUTH"]);

                var check = VerificationCheckResource.Create(
                    to: contact,
                    code: code,
                    pathServiceSid: keys["VERIFY_SID"]
                );

                System.Diagnostics.Debug.WriteLine($"[OTP VERIFY] Status={check.Status}, To={contact}");

                bool approved = check.Status == "approved";
                return new JavaScriptSerializer().Serialize(new
                {
                    success = approved,
                    status = check.Status
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[OTP VERIFY ERROR] {ex}");
                return new JavaScriptSerializer().Serialize(new
                {
                    success = false,
                    message = ex.Message
                });
            }
        }

        // 📅 Send Appointment Confirmation Email using SendGrid API v3
        [System.Web.Services.WebMethod]
        public static async Task<string> SendCalendarInvite(
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
                var keys = await GetApiKeysAsync();

                System.Diagnostics.Debug.WriteLine($"[EMAIL] SENDGRID_KEY length: {keys["SENDGRID_KEY"].Length}");
                System.Diagnostics.Debug.WriteLine($"[EMAIL] Sending to {userEmail} ({userName})");

                // Parse appointment time
                DateTime startTime = DateTime.Parse($"{appointmentDate} {appointmentTime}");
                DateTime endTime = startTime.AddMinutes(30);

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

                    var json = new JavaScriptSerializer().Serialize(emailPayload);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    System.Diagnostics.Debug.WriteLine($"[EMAIL] Sending request to SendGrid...");

                    var response = await client.PostAsync("https://api.sendgrid.com/v3/mail/send", content);
                    var responseBody = await response.Content.ReadAsStringAsync();

                    System.Diagnostics.Debug.WriteLine($"[EMAIL] Response Status={response.StatusCode}");
                    System.Diagnostics.Debug.WriteLine($"[EMAIL] Response Body={responseBody}");

                    bool success = response.StatusCode == HttpStatusCode.Accepted || response.StatusCode == HttpStatusCode.OK;

                    return new JavaScriptSerializer().Serialize(new
                    {
                        success = success,
                        status = response.StatusCode.ToString(),
                        message = success ? "Email sent successfully" : responseBody
                    });
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EMAIL ERROR] {ex}");
                return new JavaScriptSerializer().Serialize(new
                {
                    success = false,
                    message = ex.Message,
                    stackTrace = ex.StackTrace
                });
            }
        }
    }
}