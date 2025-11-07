using Google.Cloud.Firestore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;

namespace Opton.Handlers
{
    /// <summary>
    /// Summary description for payment_handler
    /// </summary>
    public class payment_handler : HttpTaskAsyncHandler
    {

        private static readonly JavaScriptSerializer serializer = new JavaScriptSerializer();

        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                string requestBody;
                using (var reader = new StreamReader(context.Request.InputStream))
                {
                    requestBody = await reader.ReadToEndAsync();
                }

                var data = serializer.Deserialize<Dictionary<string, object>>(requestBody);
                string action = data.ContainsKey("action") ? data["action"].ToString() : "";

                System.Diagnostics.Debug.WriteLine($"[PAYMENT] Action: {action}");

                switch (action)
                {
                    case "createPaymentIntent":
                        var intentResult = await CreatePaymentIntent(data);
                        context.Response.Write(serializer.Serialize(intentResult));
                        break;

                    case "createOrder":
                        var orderResult = await CreateOrder(data);
                        context.Response.Write(serializer.Serialize(orderResult));
                        break;

                    case "verifyPayment":
                        var verifyResult = await VerifyPayment(data);
                        context.Response.Write(serializer.Serialize(verifyResult));
                        break;

                    default:
                        context.Response.Write(serializer.Serialize(new { success = false, message = "Unknown action" }));
                        break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PAYMENT ERROR] {ex}");
                context.Response.Write(serializer.Serialize(new
                {
                    success = false,
                    message = ex.Message,
                    stackTrace = ex.StackTrace
                }));
            }
        }

        private async Task<Dictionary<string, object>> CreatePaymentIntent(Dictionary<string, object> data)
        {
            try
            {
                var keys = await GetApiKeysAsync();
                string paymentMethod = data["paymentMethod"].ToString();
                decimal amount = Convert.ToDecimal(data["amount"]);
                string currency = data.ContainsKey("currency") ? data["currency"].ToString() : "myr";

                System.Diagnostics.Debug.WriteLine($"[PAYMENT] Creating intent for {paymentMethod}, Amount: {amount} {currency}");

                // Convert to cents/smallest currency unit
                int amountInCents = (int)(amount * 100);

                if (paymentMethod == "card")
                {
                    // Stripe Payment Intent for card payments
                    return await CreateStripePaymentIntent(keys["STRIPE_SECRET_KEY"], amountInCents, currency);
                }
                else if (paymentMethod == "ewallet" || paymentMethod == "online")
                {
                    // For Malaysian e-wallets and online banking, use Stripe with FPX
                    return await CreateStripeFPXPaymentIntent(keys["STRIPE_SECRET_KEY"], amountInCents, currency, paymentMethod);
                }
                else
                {
                    return new Dictionary<string, object>
                {
                    { "success", false },
                    { "message", "Unsupported payment method" }
                };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PAYMENT INTENT ERROR] {ex}");
                return new Dictionary<string, object>
            {
                { "success", false },
                { "message", ex.Message }
            };
            }
        }

        private async Task<Dictionary<string, object>> CreateStripePaymentIntent(string apiKey, int amount, string currency)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");

                    var formData = new Dictionary<string, string>
                {
                    { "amount", amount.ToString() },
                    { "currency", currency },
                    { "payment_method_types[]", "card" },
                    { "metadata[integration]", "opton_checkout" }
                };

                    var content = new FormUrlEncodedContent(formData);
                    var response = await client.PostAsync("https://api.stripe.com/v1/payment_intents", content);
                    var responseBody = await response.Content.ReadAsStringAsync();

                    System.Diagnostics.Debug.WriteLine($"[STRIPE] Response: {responseBody}");

                    if (response.IsSuccessStatusCode)
                    {
                        var result = serializer.Deserialize<Dictionary<string, object>>(responseBody);
                        return new Dictionary<string, object>
                    {
                        { "success", true },
                        { "clientSecret", result["client_secret"] },
                        { "paymentIntentId", result["id"] }
                    };
                    }
                    else
                    {
                        return new Dictionary<string, object>
                    {
                        { "success", false },
                        { "message", responseBody }
                    };
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[STRIPE ERROR] {ex}");
                throw;
            }
        }

        private async Task<Dictionary<string, object>> CreateStripeFPXPaymentIntent(string apiKey, int amount, string currency, string method)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");

                    // FPX for Malaysian online banking and e-wallets
                    var formData = new Dictionary<string, string>
                {
                    { "amount", amount.ToString() },
                    { "currency", currency },
                    { "payment_method_types[]", "fpx" },
                    { "metadata[integration]", "opton_checkout" },
                    { "metadata[type]", method }
                };

                    var content = new FormUrlEncodedContent(formData);
                    var response = await client.PostAsync("https://api.stripe.com/v1/payment_intents", content);
                    var responseBody = await response.Content.ReadAsStringAsync();

                    System.Diagnostics.Debug.WriteLine($"[STRIPE FPX] Response: {responseBody}");

                    if (response.IsSuccessStatusCode)
                    {
                        var result = serializer.Deserialize<Dictionary<string, object>>(responseBody);
                        return new Dictionary<string, object>
                    {
                        { "success", true },
                        { "clientSecret", result["client_secret"] },
                        { "paymentIntentId", result["id"] }
                    };
                    }
                    else
                    {
                        return new Dictionary<string, object>
                    {
                        { "success", false },
                        { "message", responseBody }
                    };
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[STRIPE FPX ERROR] {ex}");
                throw;
            }
        }

        private async Task<Dictionary<string, object>> VerifyPayment(Dictionary<string, object> data)
        {
            try
            {
                var keys = await GetApiKeysAsync();
                string paymentIntentId = data["paymentIntentId"].ToString();

                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {keys["STRIPE_SECRET_KEY"]}");

                    var response = await client.GetAsync($"https://api.stripe.com/v1/payment_intents/{paymentIntentId}");
                    var responseBody = await response.Content.ReadAsStringAsync();

                    if (response.IsSuccessStatusCode)
                    {
                        var result = serializer.Deserialize<Dictionary<string, object>>(responseBody);
                        string status = result["status"].ToString();

                        return new Dictionary<string, object>
                    {
                        { "success", status == "succeeded" },
                        { "status", status },
                        { "paymentIntent", result }
                    };
                    }
                    else
                    {
                        return new Dictionary<string, object>
                    {
                        { "success", false },
                        { "message", responseBody }
                    };
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[VERIFY PAYMENT ERROR] {ex}");
                return new Dictionary<string, object>
            {
                { "success", false },
                { "message", ex.Message }
            };
            }
        }

        private async Task<Dictionary<string, object>> CreateOrder(Dictionary<string, object> data)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("[ORDER] Creating order in Firestore...");

                var db = Opton.SiteMaster.FirestoreDbInstance;
                var orderData = (Dictionary<string, object>)data["orderData"];

                // Generate order ID
                string orderId = "ORD" + DateTime.Now.ToString("yyyyMMddHHmmss") + new Random().Next(1000, 9999);

                // Prepare order document
                var orderDoc = new Dictionary<string, object>
            {
                { "orderId", orderId },
                { "customer", orderData["customer"] },
                { "product", orderData["product"] },
                { "package", orderData["package"] },
                { "addons", orderData["addons"] },
                { "prescription", orderData.ContainsKey("prescription") ? orderData["prescription"] : null },
                { "payment", orderData["payment"] },
                { "prices", orderData["prices"] },
                { "status", "pending" },
                { "createdAt", FieldValue.ServerTimestamp },
                { "updatedAt", FieldValue.ServerTimestamp }
            };

                // Save to Firestore
                var docRef = await db.Collection("Orders").AddAsync(orderDoc);

                System.Diagnostics.Debug.WriteLine($"[ORDER] Created successfully: {orderId}");

                // Send confirmation email
                await SendOrderConfirmationEmail(orderData, orderId);

                return new Dictionary<string, object>
            {
                { "success", true },
                { "orderId", orderId },
                { "firestoreId", docRef.Id }
            };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ORDER ERROR] {ex}");
                return new Dictionary<string, object>
            {
                { "success", false },
                { "message", ex.Message },
                { "stackTrace", ex.StackTrace }
            };
            }
        }

        private async Task SendOrderConfirmationEmail(Dictionary<string, object> orderData, string orderId)
        {
            try
            {
                var keys = await GetApiKeysAsync();
                var customer = (Dictionary<string, object>)orderData["customer"];
                var product = (Dictionary<string, object>)orderData["product"];
                var prices = (Dictionary<string, object>)orderData["prices"];

                string customerEmail = customer["email"].ToString();
                string customerName = customer["fullName"].ToString();

                // Create email content
                var emailPayload = new
                {
                    personalizations = new[]
                    {
                    new
                    {
                        to = new[] { new { email = customerEmail, name = customerName } },
                        subject = $"Order Confirmation - {orderId}"
                    }
                },
                    from = new { email = "opton5854@gmail.com", name = "Opton Store" },
                    content = new[]
                    {
                    new
                    {
                        type = "text/html",
                        value = $@"
                            <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                                <h2 style='color: #2C3639;'>Order Confirmation</h2>
                                <p>Hi {customerName},</p>
                                <p>Thank you for your order! Your order has been confirmed.</p>
                                
                                <div style='background-color: #f5f5f5; padding: 15px; border-radius: 8px; margin: 20px 0;'>
                                    <p style='margin: 5px 0;'><strong>Order ID:</strong> {orderId}</p>
                                    <p style='margin: 5px 0;'><strong>Product:</strong> {product["name"]}</p>
                                    <p style='margin: 5px 0;'><strong>Total:</strong> RM {Convert.ToDecimal(prices["total"]):F2}</p>
                                </div>
                                
                                <p>We'll send you another email when your order ships.</p>
                                <p style='color: #666; font-size: 14px; margin-top: 30px;'>Thank you for choosing Opton!</p>
                            </div>"
                    }
                }
                };

                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Add("Authorization", $"Bearer {keys["SENDGRID_KEY"]}");

                    var json = serializer.Serialize(emailPayload);
                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    var response = await client.PostAsync("https://api.sendgrid.com/v3/mail/send", content);
                    System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL] Status: {response.StatusCode}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[ORDER EMAIL ERROR] {ex}");
                // Don't throw - email failure shouldn't block order creation
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

                throw new Exception("Failed to load API keys");
            }
        }

        public override bool IsReusable
        {
            get { return false; }
        }
    }
}