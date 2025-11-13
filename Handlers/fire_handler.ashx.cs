using FirebaseAdmin.Auth;
using Google.Cloud.Firestore;
using Google.Cloud.Firestore.V1;
using Newtonsoft.Json;
using Opton.Pages;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace Opton.Handlers
{
    public class fire_handler : IHttpAsyncHandler, System.Web.SessionState.IRequiresSessionState
    {
        public bool IsReusable => false;

        public IAsyncResult BeginProcessRequest(HttpContext context, AsyncCallback cb, object extraData)
        {
            var task = ProcessRequestAsync(context);
            task.ContinueWith(t => cb(t));
            return task;
        }

        public void EndProcessRequest(IAsyncResult result) { }

        private async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            dynamic data = null;
            string message = "";
            bool success = false;
            int length = 0;
            bool isStaff = false;
            bool isAdmin = false;

            try
            {
                using (var reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
                {
                    string body = await reader.ReadToEndAsync();
                    length = body.Length;
                    data = JsonConvert.DeserializeObject(body);
                    success = true;
                    Debug.WriteLine($"========================================");
                    Debug.WriteLine($"Received request body: {body}");
                    Debug.WriteLine($"Parsed data.action: {data?.action}");
                    Debug.WriteLine($"Parsed data.idToken exists: {(data?.idToken != null)}");
                    Debug.WriteLine($"Parsed data.productId: {data?.productId}");
                    Debug.WriteLine($"========================================");
                }

                var db = SiteMaster.FirestoreDbInstance;
                Debug.WriteLine($"Firestore DB Instance: {(db != null ? "Connected" : "NULL")}");

                // CHECK ACTION-BASED REQUESTS FIRST (before idToken-only requests)

                // Check if email exists
                if (data?.checkEmail != null)
                {
                    await HandleCheckEmail(context, data);
                    return;
                }

                // Like/Unlike Product (Saved items)
                string actionValue = data?.action?.ToString();
                Debug.WriteLine($"Checking action value: '{actionValue}'");

                if (!string.IsNullOrEmpty(actionValue) && (actionValue == "like" || actionValue == "unlike"))
                {
                    await HandleLikeUnlike(context, data, db);
                    return;
                }

                if (data?.action == "getProduct")
                {
                    await HandleGetProduct(context, data, db);
                    return;
                }

                if (data?.action == "getProductsList")
                {
                    await HandleGetProductsList(context, db);
                    return;
                }

                if (data?.action == "getReviews")
                {
                    await HandleGetReviews(context, data, db);
                    return;
                }

                if (data?.action == "getUsersList")
                {
                    await HandleGetUsersList(context, db);
                    return;
                }

                if (data?.action == "getOrdersList")
                {
                    await HandleGetOrdersList(context, db);
                    return;
                }

                if (data?.action == "getAppointmentsList")
                {
                    await HandleGetAppointmentsList(context, db);
                    return;
                }

                // Check if product is liked
                if (data?.checkLiked != null)
                {
                    await HandleCheckLiked(context, data, db);
                    return;
                }

                // Add to Cart
                if (!string.IsNullOrEmpty(actionValue) && actionValue == "addToCart")
                {
                    Debug.WriteLine($">>> Routing to HandleAddToCart");
                    await HandleAddToCart(context, data, db);
                    return;
                }

                // Remove from Cart
                if (data?.action == "removeFromCart")
                {
                    await HandleRemoveFromCart(context, data, db);
                    return;
                }

                // Get Cart Count
                if (data?.getCartCount != null)
                {
                    await HandleGetCartCount(context, data, db);
                    return;
                }

                // Get Saved items
                if (data?.action == "getSaved")
                {
                    await HandleGetSaved(context, data, db);
                    return;
                }

                // Get Cart items
                if (data?.action == "getCart")
                {
                    await HandleGetCart(context, data, db);
                    return;
                }

                // Update Cart Quantity
                if (data?.action == "updateCartQuantity")
                {
                    await HandleUpdateCartQuantity(context, data, db);
                    return;
                }

                // Check for Retailers
                if (data?.getRetailers != null && data.getRetailers == true)
                {
                    await HandleGetRetailers(context, db);
                    return;
                }

                if (data?.action == "getProductsByRetailer")
                {
                    await HandleGetProductsByRetailer(context, data, db);
                    return;
                }

                // Get retailers that have products
                if (data?.getRetailersWithProducts != null && data.getRetailersWithProducts == true)
                {
                    await HandleGetRetailersWithProducts(context, db);
                    return;
                }

                if (actionValue == "getStockList")
                {
                    await HandleGetStockList(context, db);
                    return;
                }

                if (actionValue == "getRestockList")
                {
                    await HandleGetRestockList(context, db);
                    return;
                }

                if (data?.action == "getStaffList")
                {
                    await HandleGetStaffList(context, db);
                    return;
                }

                if (data?.action == "saveAppointment")
                {
                    await HandleSaveAppointment(context, data, db);
                    return;
                }

                if (data?.action == "saveStaff")
                {
                    await HandleSaveStaff(context, data, db);
                    return;
                }

                // ONLY AFTER checking for specific actions, check for idToken operations
                // Handle idToken operations (login/register/token verification/delete)
                if (data?.idToken != null)
                {
                    await HandleIdTokenOperations(context, data, db);
                    return;
                }

                Debug.WriteLine("No matching handler found for request");
            }
            catch (Exception ex)
            {
                success = false;
                message = ex.Message;
                Debug.WriteLine($"!!! FATAL ERROR in ProcessRequestAsync !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");
            }

            context.Response.Write(JsonConvert.SerializeObject(new
            {
                success,
                length,
                received = data,
                message,
                isStaff,
                isAdmin
            }));
        }

        private async Task HandleIdTokenOperations(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("[HandleIdTokenOperations] is running.");
            string message = "";
            bool isStaff = false;
            bool isAdmin = false;

            var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
            string uid = decodedToken.Uid;

            var firebaseUser = await FirebaseAuth.DefaultInstance.GetUserAsync(uid);
            string email = firebaseUser.Email ?? "";

            // Always check staff status
            var staffSnapshot = await db.Collection("Staff")
                .WhereEqualTo("userId", uid)
                .WhereEqualTo("email", email)
                .Limit(1)
                .GetSnapshotAsync();

            isStaff = staffSnapshot.Count > 0;

            if (isStaff)
            {
                var staffDoc = staffSnapshot.Documents[0];
                string role = "";
                if (staffDoc.TryGetValue("role", out string roleValue))
                {
                    role = roleValue;
                }
                isAdmin = role.Equals("Admin", StringComparison.OrdinalIgnoreCase);
            }

            context.Session["isStaff"] = isStaff;
            context.Session["isAdmin"] = isAdmin;
            if (context.Session["view"] == null)
            {
                context.Session["view"] = "customer";
            }

            if (data.deleteAccount == true)
            {
                await db.Collection("Users").Document(uid).DeleteAsync();
                await FirebaseAuth.DefaultInstance.DeleteUserAsync(uid);
                message = "Account deleted";
            }
            else if (data.register == true)
            {
                var user = new User
                {
                    email = email,
                    isVerified = decodedToken.Claims.ContainsKey("email_verified") ? (bool)decodedToken.Claims["email_verified"] : false,
                    name = "",
                    phoneNo = "",
                    address = "",
                    prescription = "",
                    joinDate = DateTime.Now
                };
                await db.Collection("Users").Document(uid).SetAsync(user);
                message = "User registered and stored in Firestore";
            }
            else
            {
                message = "Token verified";
            }

            context.Response.Write(JsonConvert.SerializeObject(new
            {
                success = true,
                length = 0,
                received = data,
                message,
                isStaff,
                isAdmin
            }));
        }

        private async Task HandleCheckEmail(HttpContext context, dynamic data)
        {
            bool success = true;
            string message = "";
            bool exists = false;

            try
            {
                var user = await FirebaseAuth.DefaultInstance.GetUserByEmailAsync((string)data.checkEmail);
                exists = true;
            }
            catch (FirebaseAuthException ex)
            {
                if (ex.AuthErrorCode == AuthErrorCode.UserNotFound)
                    exists = false;
                else
                {
                    success = false;
                    message = ex.Message;
                }
            }

            context.Response.Write(JsonConvert.SerializeObject(new
            {
                success,
                length = 0,
                received = data,
                exists,
                message = exists ? "Email exists" : "Email not found"
            }));
        }

        private async Task HandleGetProduct(HttpContext context, dynamic data, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";
            Debug.WriteLine("=== HandleGetProduct START ===");

            string productId = data?.productId?.ToString() ?? "";
            Debug.WriteLine($"Product ID: {productId}");

            if (string.IsNullOrEmpty(productId))
            {
                Debug.WriteLine("Product ID is empty");
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Product ID required",
                    product = (Product)null
                }));
                return;
            }

            try
            {
                var docRef = db.Collection("Products").Document(productId);
                Debug.WriteLine($"Fetching document from Firestore...");
                var snapshot = await docRef.GetSnapshotAsync();
                Debug.WriteLine($"Document exists: {snapshot.Exists}");

                if (!snapshot.Exists)
                {
                    Debug.WriteLine("Product not found in Firestore");
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Product not found",
                        product = (Product)null
                    }));
                    return;
                }

                // Convert snapshot to Product object
                Product product = snapshot.ConvertTo<Product>();
                Debug.WriteLine($"Product converted successfully: {product.name}");

                var response = new
                {
                    success = true,
                    product = product,
                    message = "Product fetched successfully"
                };

                string json = JsonConvert.SerializeObject(response);
                Debug.WriteLine($"Sending response: {json}");
                context.Response.Write(json);
                Debug.WriteLine("=== HandleGetProduct END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleGetProduct !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");
                Debug.WriteLine($"Inner: {ex.InnerException?.Message}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message,
                    product = (Product)null,
                    error = ex.ToString()
                }));
                Debug.WriteLine("=== HandleGetProduct END (ERROR) ===");
            }
        }

        private async Task HandleGetProductsList(HttpContext context, FirestoreDb db)
        {
            Debug.WriteLine("Getting products list...");
            try
            {
                Debug.WriteLine("Attempting to retrieve products list...");
                var snapshot = await db.Collection("Products").GetSnapshotAsync();
                var products = snapshot.Documents.Select(doc => doc.ConvertTo<Product>()).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    products
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetReviews(HttpContext context, dynamic data, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";
            Debug.WriteLine("=== HandleGetReviews START ===");

            try
            {
                string productId = data?.productId?.ToString() ?? "";
                Debug.WriteLine($"Product ID: {productId}");

                if (string.IsNullOrEmpty(productId))
                {
                    Debug.WriteLine("Product ID is empty");
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Product ID required",
                        reviews = new List<Review>()
                    }));
                    return;
                }

                // Get reviews for this product
                var reviewsSnapshot = await db.Collection("Reviews")
                    .WhereEqualTo("productId", productId)
                    .GetSnapshotAsync();

                Debug.WriteLine($"Found {reviewsSnapshot.Count} reviews for product {productId}");

                var reviews = new List<Review>();

                foreach (var doc in reviewsSnapshot.Documents)
                {
                    try
                    {
                        var review = doc.ConvertTo<Review>();
                        review.reviewId = doc.Id; // Set the document ID as reviewId

                        reviews.Add(review);
                        Debug.WriteLine($"Added review {doc.Id} with rating {review.rating}");
                    }
                    catch (Exception ex)
                    {
                        Debug.WriteLine($"Error processing review document {doc.Id}: {ex.Message}");
                        // Continue with other reviews even if one fails
                    }
                }

                // Calculate average rating
                double averageRating = 0;
                if (reviews.Count > 0)
                {
                    averageRating = reviews.Where(r => r.rating > 0).Average(r => r.rating);
                }

                // Sort reviews by date (newest first)
                var sortedReviews = reviews.OrderByDescending(r => r.dateTime).ToList();

                var response = new
                {
                    success = true,
                    reviews = sortedReviews,
                    averageRating = Math.Round(averageRating, 1),
                    totalReviews = reviews.Count,
                    message = $"Found {reviews.Count} reviews"
                };

                Debug.WriteLine($"Sending response: {reviews.Count} reviews, average rating: {averageRating}");
                context.Response.Write(JsonConvert.SerializeObject(response));
                Debug.WriteLine("=== HandleGetReviews END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleGetReviews !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message,
                    reviews = new List<Review>(),
                    averageRating = 0,
                    totalReviews = 0
                }));
            }
        }

        private async Task HandleGetUsersList(HttpContext context, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";
            Debug.WriteLine("=== HandleGetUsersList START ===");

            try
            {
                var snapshot = await db.Collection("Users").GetSnapshotAsync();
                Debug.WriteLine($"Fetched {snapshot.Count} user documents");

                var usersList = snapshot.Documents.Select(doc =>
                {
                    var dict = doc.ToDictionary();
                    dict["userId"] = doc.Id;

                    // Handle all fields as strings or appropriate types
                    string[] stringFields = { "email", "name", "address", "prescription" };
                    foreach (var field in stringFields)
                    {
                        if (dict.ContainsKey(field))
                        {
                            if (dict[field] != null)
                                dict[field] = dict[field].ToString();
                            else
                                dict[field] = "";
                        }
                    }

                    // Handle phoneNo - can be string or long
                    if (dict.ContainsKey("phoneNo"))
                    {
                        if (dict["phoneNo"] != null)
                            dict["phoneNo"] = dict["phoneNo"].ToString();
                        else
                            dict["phoneNo"] = "";
                    }

                    // Handle isVerified as boolean
                    if (dict.ContainsKey("isVerified"))
                    {
                        if (dict["isVerified"] is bool)
                            dict["isVerified"] = (bool)dict["isVerified"];
                        else
                            dict["isVerified"] = false;
                    }

                    return dict;
                }).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    users = usersList
                }));

                Debug.WriteLine("=== HandleGetUsersList END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleGetUsersList !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetOrdersList(HttpContext context, FirestoreDb db)
        {
            try
            {
                var snapshot = await db.Collection("Orders").GetSnapshotAsync();

                var orders = snapshot.Documents.Select(doc =>
                {
                    var raw = doc.ToDictionary(); // RAW FIRESTORE DICTIONARY
                    raw["orderId"] = doc.Id;

                    // ✅ FORMAT orderTime + arrivalTime into readable strings
                    if (raw.ContainsKey("orderTime") && raw["orderTime"] is Timestamp ot)
                        raw["orderTime"] = ot.ToDateTime().ToString("yyyy-MM-dd HH:mm:ss");

                    if (raw.ContainsKey("arrivalTime") && raw["arrivalTime"] is Timestamp at)
                        raw["arrivalTime"] = at.ToDateTime().ToString("yyyy-MM-dd HH:mm:ss");

                    // ✅ Ensure items stay structured
                    if (raw.ContainsKey("items") && raw["items"] is Dictionary<string, object> itemsDict)
                    {
                        var structuredItems = new Dictionary<string, object>();

                        foreach (var kv in itemsDict) // kv.Key = productId
                        {
                            string productId = kv.Key;
                            if (kv.Value is Dictionary<string, object> itemDict)
                            {
                                // Keep Adults/Kids, package, addOn, prescription intact
                                var newItem = new Dictionary<string, object>();
                                foreach (var key in itemDict.Keys)
                                {
                                    newItem[key] = itemDict[key];
                                }
                                structuredItems[productId] = newItem;
                            }
                        }

                        raw["items"] = structuredItems;
                    }

                    // ✅ Ensure price stays structured
                    if (raw.ContainsKey("price") && raw["price"] is Dictionary<string, object> priceDict)
                    {
                        var structuredPrices = new Dictionary<string, object>();

                        foreach (var kv in priceDict) // kv.Key = productId
                        {
                            if (kv.Value is Dictionary<string, object> priceObj)
                            {
                                structuredPrices[kv.Key] = priceObj;
                            }
                        }

                        raw["price"] = structuredPrices;
                    }

                    return raw;

                }).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    orders
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetAppointmentsList(HttpContext context, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";
            Debug.WriteLine("=== HandleGetAppointmentsList START ===");

            try
            {
                var snapshot = await db.Collection("Appointments").GetSnapshotAsync();
                Debug.WriteLine($"Fetched {snapshot.Count} documents from Appointments collection.");

                var appointments = snapshot.Documents.Select(doc =>
                {
                    Debug.WriteLine($"Processing document ID: {doc.Id}");

                    var raw = doc.ToDictionary(); // Raw Firestore data
                    raw["appointmentId"] = doc.Id;

                    // string fields
                    string[] stringFields = { "email", "name", "details", "type", "remarks", "status", "staffId", "cancelReason", "storeId", "userId" };
                    foreach (string field in stringFields)
                    {
                        if (raw.ContainsKey(field))
                            raw[field] = raw[field] != null ? raw[field].ToString() : "";
                    }

                    // phoneNo → string
                    if (raw.ContainsKey("phoneNo"))
                        raw["phoneNo"] = raw["phoneNo"] != null ? raw["phoneNo"].ToString() : "";

                    // dateTime → DateTime
                    if (raw.ContainsKey("dateTime"))
                    {
                        object dtObj = raw["dateTime"];
                        if (dtObj is Timestamp)
                        {
                            var ts = (Timestamp)dtObj;
                            raw["dateTime"] = ts.ToDateTime();
                            Debug.WriteLine($"Converted dateTime for doc {doc.Id}: {raw["dateTime"]}");
                        }
                        else
                        {
                            DateTime dt;
                            if (dtObj != null && DateTime.TryParse(dtObj.ToString(), out dt))
                            {
                                raw["dateTime"] = dt;
                                Debug.WriteLine($"Parsed dateTime string for doc {doc.Id}: {raw["dateTime"]}");
                            }
                            else
                            {
                                raw["dateTime"] = null;
                                Debug.WriteLine($"Failed to parse dateTime for doc {doc.Id}");
                            }
                        }
                    }

                    // prescription → ensure dictionary exists
                    if (!raw.ContainsKey("prescription") || raw["prescription"] == null)
                    {
                        raw["prescription"] = new Dictionary<string, object>();
                    }
                    else
                    {
                        var dictObj = raw["prescription"] as Dictionary<string, object>;
                        if (dictObj == null)
                            raw["prescription"] = new Dictionary<string, object>();
                    }

                    // holdItem → ensure dictionary exists and normalize format
                    if (!raw.ContainsKey("holdItem") || raw["holdItem"] == null)
                    {
                        raw["holdItem"] = new Dictionary<string, object>();
                    }
                    else
                    {
                        var holdObj = raw["holdItem"] as Dictionary<string, object>;
                        if (holdObj == null)
                        {
                            // If holdItem exists but is not the expected type, replace with empty dictionary
                            raw["holdItem"] = new Dictionary<string, object>();
                        }
                        else
                        {
                            // Optionally, ensure nested values are dictionaries or normalized
                            var normalized = new Dictionary<string, object>();
                            foreach (var kv in holdObj)
                            {
                                // Expecting structure: "P-20": { "Adults": "silver" } or nested details
                                var innerDict = kv.Value as Dictionary<string, object>;
                                if (innerDict != null)
                                {
                                    normalized[kv.Key] = innerDict;
                                }
                                else
                                {
                                    // If inner value is a primitive (e.g. string), wrap into a dictionary with default key
                                    normalized[kv.Key] = new Dictionary<string, object> { { "variant", kv.Value } };
                                }
                            }
                            raw["holdItem"] = normalized;
                        }
                    }

                    return raw;
                })
                .Where(a => a.ContainsKey("dateTime") && a["dateTime"] != null)
                .OrderBy(a => (DateTime)a["dateTime"])
                .ToList();

                Debug.WriteLine($"Returning {appointments.Count} appointments after filtering null dateTime.");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    appointments
                }));

                Debug.WriteLine("=== HandleGetAppointmentsList END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleGetAppointmentsList !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleLikeUnlike(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("=== HandleLikeUnlike START ===");

            if (data.idToken == null)
            {
                Debug.WriteLine("No idToken provided");
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Authentication required"
                }));
                return;
            }

            try
            {
                Debug.WriteLine($"Verifying token...");
                var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
                string uid = decodedToken.Uid;
                Debug.WriteLine($"Token verified for UID: {uid}");

                string productId = data.productId?.ToString() ?? "";
                Debug.WriteLine($"Product ID: {productId}");

                if (string.IsNullOrEmpty(productId))
                {
                    Debug.WriteLine("Product ID is empty");
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Product ID required"
                    }));
                    return;
                }

                var savedRef = db.Collection("Saved");
                var savedId = $"{uid}_{productId}";
                string message = "";

                Debug.WriteLine($"Action: {data.action}, SavedID: {savedId}");

                if (data.action == "like")
                {
                    var saved = new Saved
                    {
                        userId = uid,
                        productId = productId,
                        addedOn = DateTime.UtcNow
                    };

                    Debug.WriteLine($"Attempting to save to Firestore: {JsonConvert.SerializeObject(saved)}");
                    await savedRef.Document(savedId).SetAsync(saved);
                    Debug.WriteLine($"✓ Successfully saved to Firestore");
                    message = "Added to favorites";
                }
                else
                {
                    Debug.WriteLine($"Attempting to delete from Firestore");
                    await savedRef.Document(savedId).DeleteAsync();
                    Debug.WriteLine($"✓ Successfully deleted from Firestore");
                    message = "Removed from favorites";
                }

                var response = new
                {
                    success = true,
                    message,
                    action = data.action
                };

                Debug.WriteLine($"Sending response: {JsonConvert.SerializeObject(response)}");
                context.Response.Write(JsonConvert.SerializeObject(response));
                Debug.WriteLine("=== HandleLikeUnlike END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleLikeUnlike !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");
                Debug.WriteLine($"Inner: {ex.InnerException?.Message}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
                Debug.WriteLine("=== HandleLikeUnlike END (ERROR) ===");
            }
        }

        private async Task HandleCheckLiked(HttpContext context, dynamic data, FirestoreDb db)
        {
            if (data.idToken == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Authentication required",
                    isLiked = false
                }));
                return;
            }

            var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
            string uid = decodedToken.Uid;
            string productId = data.productId?.ToString() ?? "";

            if (string.IsNullOrEmpty(productId))
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Product ID required",
                    isLiked = false
                }));
                return;
            }

            try
            {
                var savedId = $"{uid}_{productId}";
                var doc = await db.Collection("Saved").Document(savedId).GetSnapshotAsync();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    isLiked = doc.Exists
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message,
                    isLiked = false
                }));
            }
        }

        private async Task HandleAddToCart(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("=== HandleAddToCart START ===");

            if (data.idToken == null)
            {
                Debug.WriteLine("No idToken provided");
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Authentication required"
                }));
                return;
            }

            try
            {
                Debug.WriteLine("Verifying token...");
                var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
                string uid = decodedToken.Uid;
                Debug.WriteLine($"Token verified for UID: {uid}");

                string productId = data.productId?.ToString() ?? "";
                int quantity = data.quantity != null ? (int)data.quantity : 1;
                string colour = data.colour?.ToString() ?? "Default";
                string size = data.size?.ToString() ?? "Default";

                Debug.WriteLine($"Product ID: {productId}, Quantity: {quantity}, Colour: {colour}, Size: {size}");

                if (string.IsNullOrEmpty(productId))
                {
                    Debug.WriteLine("Product ID is empty");
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Product ID required"
                    }));
                    return;
                }

                var cartRef = db.Collection("Cart");
                // Include colour and size in the cartId to differentiate variants
                var cartId = $"{uid}_{productId}_{colour}_{size}";
                string message = "";

                Debug.WriteLine($"CartID: {cartId}");
                Debug.WriteLine("Checking if cart item exists...");
                var existingDoc = await cartRef.Document(cartId).GetSnapshotAsync();
                Debug.WriteLine($"Exists: {existingDoc.Exists}");

                if (existingDoc.Exists)
                {
                    var existingCart = existingDoc.ConvertTo<Cart>();
                    existingCart.quantity += quantity;
                    Debug.WriteLine($"Updating existing cart: new quantity = {existingCart.quantity}");
                    await cartRef.Document(cartId).SetAsync(existingCart);
                    Debug.WriteLine("✓ Successfully updated in Firestore");
                    message = "Cart updated";
                }
                else
                {
                    var cart = new Cart
                    {
                        userId = uid,
                        productId = productId,
                        quantity = quantity,
                        colour = colour,
                        size = size,
                        hasPrescription = data.hasPrescription != null ? (bool)data.hasPrescription : false,
                        prescriptionDetails = data.prescriptionDetails != null ? data.prescriptionDetails.ToString() : "",
                        addedOn = DateTime.UtcNow
                    };

                    Debug.WriteLine("Creating new cart item");
                    await cartRef.Document(cartId).SetAsync(cart);
                    Debug.WriteLine("✓ Successfully saved to Firestore");
                    message = "Added to cart";
                }

                var response = new
                {
                    success = true,
                    message
                };

                Debug.WriteLine($"Sending response: {JsonConvert.SerializeObject(response)}");
                context.Response.Write(JsonConvert.SerializeObject(response));
                Debug.WriteLine("=== HandleAddToCart END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine("!!! ERROR in HandleAddToCart !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");
                Debug.WriteLine($"Inner: {ex.InnerException?.Message}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
                Debug.WriteLine("=== HandleAddToCart END (ERROR) ===");
            }
        }

        private async Task HandleRemoveFromCart(HttpContext context, dynamic data, FirestoreDb db)
        {
            if (data.idToken == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Authentication required"
                }));
                return;
            }

            var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
            string uid = decodedToken.Uid;
            string productId = data.productId?.ToString() ?? "";

            if (string.IsNullOrEmpty(productId))
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Product ID required"
                }));
                return;
            }

            try
            {
                var cartId = $"{uid}_{productId}";
                await db.Collection("Cart").Document(cartId).DeleteAsync();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    message = "Removed from cart"
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetCartCount(HttpContext context, dynamic data, FirestoreDb db)
        {
            if (data.idToken == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Authentication required",
                    count = 0
                }));
                return;
            }

            var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
            string uid = decodedToken.Uid;

            try
            {
                var cartSnapshot = await db.Collection("Cart")
                    .WhereEqualTo("userId", uid)
                    .GetSnapshotAsync();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    count = cartSnapshot.Count
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message,
                    count = 0
                }));
            }
        }

        private async Task HandleGetSaved(HttpContext context, dynamic data, FirestoreDb db)
        {
            if (data.idToken == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Authentication required"
                }));
                return;
            }

            var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
            string uid = decodedToken.Uid;

            try
            {
                var savedSnapshot = await db.Collection("Saved")
                    .WhereEqualTo("userId", uid)
                    .GetSnapshotAsync();

                var items = savedSnapshot.Documents.Select(doc => doc.ConvertTo<Saved>()).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    items
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetCart(HttpContext context, dynamic data, FirestoreDb db)
        {
            if (data.idToken == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Authentication required"
                }));
                return;
            }

            var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
            string uid = decodedToken.Uid;

            try
            {
                var cartSnapshot = await db.Collection("Cart")
                    .WhereEqualTo("userId", uid)
                    .GetSnapshotAsync();

                var items = cartSnapshot.Documents.Select(doc => doc.ConvertTo<Cart>()).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    items
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleUpdateCartQuantity(HttpContext context, dynamic data, FirestoreDb db)
        {
            if (data.idToken == null)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Authentication required"
                }));
                return;
            }

            var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
            string uid = decodedToken.Uid;
            string productId = data.productId?.ToString() ?? "";
            int quantity = data.quantity != null ? (int)data.quantity : 1;

            if (string.IsNullOrEmpty(productId))
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Product ID required"
                }));
                return;
            }

            try
            {
                var cartRef = db.Collection("Cart");
                var cartId = $"{uid}_{productId}";

                var existingDoc = await cartRef.Document(cartId).GetSnapshotAsync();

                if (existingDoc.Exists)
                {
                    var existingCart = existingDoc.ConvertTo<Cart>();
                    existingCart.quantity = quantity;
                    await cartRef.Document(cartId).SetAsync(existingCart);

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Quantity updated"
                    }));
                }
                else
                {
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Cart item not found"
                    }));
                }
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetRetailers(HttpContext context, FirestoreDb db)
        {
            try
            {
                var snapshot = await db.Collection("Retailers").GetSnapshotAsync();
                var retailers = snapshot.Documents.Select(doc =>
                {
                    Dictionary<string, string> normalizedHours = new Dictionary<string, string>();

                    if (doc.ContainsField("openingHours"))
                    {
                        var rawHours = doc.GetValue<Dictionary<string, object>>("openingHours");
                        if (rawHours != null)
                        {
                            foreach (var kv in rawHours)
                            {
                                normalizedHours[kv.Key] = kv.Value?.ToString() ?? "";
                            }
                        }
                    }

                    return new
                    {
                        id = doc.Id,
                        name = doc.GetValue<string>("name"),
                        address = doc.GetValue<string>("address"),
                        latitude = doc.GetValue<double>("latitude"),
                        longitude = doc.GetValue<double>("longitude"),
                        phoneNo = doc.GetValue<long>("phoneNo"),
                        openingHours = normalizedHours // assign renamed variable here
                    };
                }).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    retailers
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetProductsByRetailer(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("Getting products by retailer...");
            try
            {
                string retailerId = data.retailerId;
                if (string.IsNullOrEmpty(retailerId))
                {
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Retailer ID is required"
                    }));
                    return;
                }

                Debug.WriteLine($"Retrieving products for retailer: {retailerId}");

                // Get all products first (same as getProductsList)
                var snapshot = await db.Collection("Products").GetSnapshotAsync();
                var allProducts = snapshot.Documents.Select(doc => doc.ConvertTo<Product>()).ToList();

                Debug.WriteLine($"Total products found: {allProducts.Count}");

                // Filter products that have data for this retailer
                var filteredProducts = allProducts.Where(product =>
                {
                    switch (retailerId.ToUpper())
                    {
                        case "R1":
                            return product.R1 != null;
                        case "R2":
                            return product.R2 != null;
                        case "R3":
                            return product.R3 != null;
                        default:
                            return product.inventory != null;
                    }
                }).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    products = filteredProducts
                }));

                Debug.WriteLine($"Filtered products for retailer {retailerId}: {filteredProducts.Count}");
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetRetailersWithProducts(HttpContext context, FirestoreDb db)
        {
            try
            {
                // Step 1: Fetch all retailers
                var retailersSnapshot = await db.Collection("Retailers").GetSnapshotAsync();
                var retailers = retailersSnapshot.Documents.Select(doc => new
                {
                    id = doc.Id,
                    name = doc.GetValue<string>("name"),
                    address = doc.GetValue<string>("address"),
                    latitude = doc.GetValue<double>("latitude"),
                    longitude = doc.GetValue<double>("longitude"),
                    phoneNo = doc.GetValue<long>("phoneNo"),
                    openingHours = doc.ContainsField("openingHours")
                        ? doc.GetValue<Dictionary<string, object>>("openingHours")
                            .ToDictionary(kv => kv.Key, kv => kv.Value?.ToString() ?? "")
                        : new Dictionary<string, string>()
                }).ToList();

                // Step 2: Fetch all products and group by retailerId
                var productsSnapshot = await db.Collection("Products").GetSnapshotAsync();
                var productsByRetailer = productsSnapshot.Documents
                    .Where(doc => doc.ContainsField("retailerId"))
                    .GroupBy(doc => doc.GetValue<string>("retailerId"))
                    .ToDictionary(g => g.Key, g => g.Count());

                // Step 3: Filter retailers to only those that have products
                var retailersWithProducts = retailers
                    .Where(r => productsByRetailer.ContainsKey(r.id))
                    .Select(r => new
                    {
                        r.id,
                        r.name,
                        r.address,
                        r.latitude,
                        r.longitude,
                        r.phoneNo,
                        r.openingHours,
                        productCount = productsByRetailer[r.id] // Number of products available
                    })
                    .ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    retailers = retailersWithProducts
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetStockList(HttpContext context, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";

            try
            {
                var snapshot = await db.Collection("Products").GetSnapshotAsync();

                var stockList = snapshot.Documents.Select(doc =>
                {
                    var dict = doc.ToDictionary(); // Raw Firestore fields
                    dict["productId"] = doc.Id;   // Add document ID
                    return dict;
                }).ToList();

                // Log full data with [STOCK]
                string jsonLog = JsonConvert.SerializeObject(stockList, Formatting.Indented);
                System.Diagnostics.Debug.WriteLine($"[STOCK] {jsonLog}");
                Console.WriteLine($"[STOCK] {jsonLog}");

                // Write response using classic ASP.NET
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    stockList
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetRestockList(HttpContext context, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";

            try
            {
                var snapshot = await db.Collection("RestockRequests").GetSnapshotAsync();

                var restocks = snapshot.Documents.Select(doc =>
                {
                    var dict = doc.ToDictionary();
                    dict["restockId"] = doc.Id;

                    if (dict.ContainsKey("requestTime") && dict["requestTime"] is Timestamp ts)
                        dict["requestTime"] = ts.ToDateTime().ToString("yyyy-MM-dd HH:mm:ss");

                    return dict;
                }).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    restocks
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleGetStaffList(HttpContext context, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";
            Debug.WriteLine("=== HandleGetStaffList START ===");

            try
            {
                var snapshot = await db.Collection("Staff").GetSnapshotAsync();
                Debug.WriteLine($"Fetched {snapshot.Count} staff documents");

                var staffList = snapshot.Documents.Select(doc =>
                {
                    var dict = doc.ToDictionary();
                    dict["staffId"] = doc.Id;

                    // Ensure string fields
                    string[] stringFields = { "email", "name", "phoneNo", "storeId", "role" };
                    foreach (var field in stringFields)
                    {
                        if (dict.ContainsKey(field))
                            dict[field] = dict[field]?.ToString() ?? "";
                    }

                    // Format addedOn date
                    if (dict.ContainsKey("addedOn") && dict["addedOn"] is Timestamp ts)
                    {
                        dict["addedOn"] = ts.ToDateTime().ToString("MM/dd/yyyy");
                    }
                    else if (dict.ContainsKey("addedOn"))
                    {
                        dict["addedOn"] = dict["addedOn"]?.ToString() ?? "";
                    }

                    return dict;
                }).ToList();

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    staff = staffList
                }));

                Debug.WriteLine("=== HandleGetStaffList END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleGetStaffList !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleSaveStaff(HttpContext context, dynamic data, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";
            Debug.WriteLine("=== HandleSaveStaff START ===");

            try
            {
                var staffRef = db.Collection("Staff");
                var newStaffIds = new List<string>();

                // Handle new staff
                if (data.newStaff != null)
                {
                    var newStaffList = JsonConvert.DeserializeObject<List<Dictionary<string, object>>>(data.newStaff.ToString());

                    foreach (var staffData in newStaffList)
                    {
                        // Validate required fields
                        if (!staffData.ContainsKey("email") || string.IsNullOrEmpty(staffData["email"]?.ToString()))
                        {
                            context.Response.Write(JsonConvert.SerializeObject(new
                            {
                                success = false,
                                message = "Email is required for new staff"
                            }));
                            return;
                        }

                        // Generate new staff ID
                        var newDoc = staffRef.Document();
                        var staffId = newDoc.Id;

                        var staffObj = new Dictionary<string, object>
                        {
                            ["email"] = staffData.ContainsKey("email") ? staffData["email"]?.ToString() ?? "" : "",
                            ["name"] = staffData.ContainsKey("name") ? staffData["name"]?.ToString() ?? "" : "",
                            ["phoneNo"] = staffData.ContainsKey("phoneNo") ? staffData["phoneNo"]?.ToString() ?? "" : "",
                            ["storeId"] = staffData.ContainsKey("storeId") ? staffData["storeId"]?.ToString() ?? "" : "",
                            ["role"] = staffData.ContainsKey("role") ? staffData["role"]?.ToString() ?? "Staff" : "Staff",
                            ["addedOn"] = Timestamp.FromDateTime(DateTime.UtcNow)
                        };

                        await staffRef.Document(staffId).SetAsync(staffObj);
                        newStaffIds.Add(staffId);
                        Debug.WriteLine($"Created new staff: {staffId}");
                    }
                }

                // Handle updated staff
                if (data.updatedStaff != null)
                {
                    var updatedStaffDict = JsonConvert.DeserializeObject<Dictionary<string, Dictionary<string, object>>>(data.updatedStaff.ToString());

                    foreach (var kvp in updatedStaffDict)
                    {
                        var staffId = kvp.Key;
                        var updates = kvp.Value;

                        Debug.WriteLine($"Updating staff: {staffId}");
                        await staffRef.Document(staffId).UpdateAsync(updates);
                    }
                }

                // Handle deleted staff
                if (data.deletedStaff != null)
                {
                    var deletedStaffList = JsonConvert.DeserializeObject<List<string>>(data.deletedStaff.ToString());

                    foreach (var staffId in deletedStaffList)
                    {
                        if (!string.IsNullOrEmpty(staffId))
                        {
                            Debug.WriteLine($"Deleting staff: {staffId}");
                            await staffRef.Document(staffId).DeleteAsync();
                        }
                    }
                }

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    message = "Staff changes saved successfully",
                    newStaffIds
                }));

                Debug.WriteLine("=== HandleSaveStaff END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleSaveStaff !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task HandleSaveAppointment(HttpContext context, dynamic data, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";
            Debug.WriteLine("=== HandleSaveAppointment START ===");

            try
            {
                string storeId = data?.storeId?.ToString() ?? "";
                string userId = data?.userId?.ToString() ?? "";
                string email = data?.email?.ToString() ?? "";
                string name = data?.name?.ToString() ?? "";
                string phoneNoStr = data?.phoneNo?.ToString() ?? "";
                string details = data?.details?.ToString() ?? "";
                string type = data?.type?.ToString() ?? "Consultation";
                string dateTimeStr = data?.dateTime?.ToString() ?? "";
                string remarks = data?.remarks?.ToString() ?? "";
                string status = data?.status?.ToString() ?? "Booked";

                Debug.WriteLine($"Appointment data - Store: {storeId}, Email: {email}, Name: {name}, DateTime: {dateTimeStr}");

                // Validate required fields
                if (string.IsNullOrEmpty(storeId) || string.IsNullOrEmpty(email) ||
                    string.IsNullOrEmpty(name) || string.IsNullOrEmpty(dateTimeStr))
                {
                    Debug.WriteLine("Missing required fields");
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Missing required fields"
                    }));
                    return;
                }

                // Parse phone number to long (remove spaces, dashes, etc.)
                long phoneNo = 0;
                string cleanPhone = new string(phoneNoStr.Where(char.IsDigit).ToArray());
                if (!long.TryParse(cleanPhone, out phoneNo))
                {
                    Debug.WriteLine($"Invalid phone number format: {phoneNoStr}");
                    phoneNo = 0; // Default to 0 if parsing fails
                }

                // Convert dateTime string to Firestore Timestamp
                // Expected format: "2025-11-22T11:30:00" (ISO format)
                Timestamp dateTimeTimestamp;
                try
                {
                    DateTime dt = DateTime.Parse(dateTimeStr);
                    // Convert to UTC if not already
                    if (dt.Kind == DateTimeKind.Unspecified)
                    {
                        // Assume local time (Malaysia is UTC+8)
                        dt = DateTime.SpecifyKind(dt, DateTimeKind.Local);
                    }
                    dateTimeTimestamp = Timestamp.FromDateTime(dt.ToUniversalTime());
                    Debug.WriteLine($"Converted dateTime: {dateTimeStr} -> {dateTimeTimestamp}");
                }
                catch (Exception ex)
                {
                    Debug.WriteLine($"Error parsing dateTime: {ex.Message}");
                    dateTimeTimestamp = Timestamp.FromDateTime(DateTime.UtcNow);
                }

                // Generate appointment ID
                string appointmentId = await GenerateAppointmentId(db);
                Debug.WriteLine($"Generated appointment ID: {appointmentId}");

                // Create appointment data dictionary with correct field names
                var appointmentData = new Dictionary<string, object>
        {
            { "appointmentId", appointmentId },
            { "storeId", storeId },
            { "userId", userId },
            { "email", email },
            { "name", name },
            { "phoneNo", phoneNo }, // Store as number
            { "details", details },
            { "type", type },
            { "dateTime", dateTimeTimestamp }, // Store as Timestamp
            { "remarks", remarks },
            { "status", status },
            { "createdAt", Timestamp.FromDateTime(DateTime.UtcNow) },
            { "cancelReason", "" }, // Add empty cancelReason field
            { "staffId", "" } // Add empty staffId field
        };

                Debug.WriteLine($"Base appointment data created with phoneNo: {phoneNo}");

                // Handle prescription data
                if (data?.prescription != null)
                {
                    try
                    {
                        string prescriptionJson = data.prescription.ToString();
                        Debug.WriteLine($"Raw prescription JSON: {prescriptionJson}");

                        var prescriptionDict = JsonConvert.DeserializeObject<Dictionary<string, object>>(prescriptionJson);

                        // Convert nested objects properly
                        var processedPrescription = ProcessNestedDictionary(prescriptionDict);
                        appointmentData["prescription"] = processedPrescription;

                        Debug.WriteLine("Added prescription data");
                    }
                    catch (Exception ex)
                    {
                        Debug.WriteLine($"Error parsing prescription: {ex.Message}");
                        appointmentData["prescription"] = new Dictionary<string, object>
                {
                    { "Prescription", new Dictionary<string, object>() }
                };
                    }
                }
                else
                {
                    // Add empty prescription if none provided
                    appointmentData["prescription"] = new Dictionary<string, object>
            {
                { "Prescription", new Dictionary<string, object>() }
            };
                }

                // Handle holdItems data - FIXED to match Firebase structure
                if (data?.holdItems != null)
                {
                    try
                    {
                        string holdItemsJson = data.holdItems.ToString();
                        Debug.WriteLine($"Raw holdItems JSON: {holdItemsJson}");

                        var holdItemsDict = JsonConvert.DeserializeObject<Dictionary<string, object>>(holdItemsJson);

                        // Process to ensure correct structure: {"P-3": {"Adults": "black"}}
                        var processedHoldItems = ProcessNestedDictionary(holdItemsDict);
                        appointmentData["holdItems"] = processedHoldItems;

                        Debug.WriteLine($"Added holdItems: {holdItemsDict.Count} items");
                    }
                    catch (Exception ex)
                    {
                        Debug.WriteLine($"Error parsing holdItems: {ex.Message}");
                        appointmentData["holdItems"] = new Dictionary<string, object>();
                    }
                }
                else
                {
                    appointmentData["holdItems"] = new Dictionary<string, object>();
                }

                // Save to Firestore
                await db.Collection("Appointments").Document(appointmentId).SetAsync(appointmentData);
                Debug.WriteLine("✓ Successfully saved appointment to Firestore");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    message = "Appointment saved successfully",
                    appointmentId = appointmentId
                }));

                Debug.WriteLine("=== HandleSaveAppointment END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleSaveAppointment !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Error saving appointment: " + ex.Message
                }));
            }
        }

        // Helper method to process nested dictionaries
        private Dictionary<string, object> ProcessNestedDictionary(Dictionary<string, object> dict)
        {
            var result = new Dictionary<string, object>();

            foreach (var kvp in dict)
            {
                if (kvp.Value is Newtonsoft.Json.Linq.JObject jObj)
                {
                    // Convert JObject to Dictionary recursively
                    result[kvp.Key] = ProcessNestedDictionary(jObj.ToObject<Dictionary<string, object>>());
                }
                else if (kvp.Value is Dictionary<string, object> nestedDict)
                {
                    result[kvp.Key] = ProcessNestedDictionary(nestedDict);
                }
                else
                {
                    result[kvp.Key] = kvp.Value;
                }
            }

            return result;
        }

        private async Task<string> GenerateAppointmentId(FirestoreDb db)
        {
            try
            {
                // Get all appointments to find the highest ID
                var appointmentsRef = db.Collection("Appointments");
                var snapshot = await appointmentsRef.GetSnapshotAsync();

                int maxId = 0;
                foreach (var document in snapshot.Documents)
                {
                    var data = document.ToDictionary();
                    if (data.ContainsKey("appointmentId"))
                    {
                        string appointmentId = data["appointmentId"]?.ToString() ?? "";
                        // Extract number from "A-1", "A-2", etc.
                        if (appointmentId.StartsWith("A-"))
                        {
                            string numPart = appointmentId.Substring(2);
                            if (int.TryParse(numPart, out int num))
                            {
                                if (num > maxId)
                                {
                                    maxId = num;
                                }
                            }
                        }
                    }
                }

                // Generate next ID
                int nextId = maxId + 1;
                Debug.WriteLine($"Generated new appointment ID: A-{nextId} (max was: {maxId})");
                return $"A-{nextId}";
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error generating appointment ID: {ex.Message}");
                // Fallback to timestamp-based ID if there's an error
                string fallbackId = $"A-{DateTime.UtcNow.Ticks}";
                Debug.WriteLine($"Using fallback ID: {fallbackId}");
                return fallbackId;
            }
        }

        public void ProcessRequest(HttpContext context)
        {
            throw new NotImplementedException();
        }
    }
}