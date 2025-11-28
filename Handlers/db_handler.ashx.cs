using FirebaseAdmin.Auth;
using Google.Cloud.Firestore;
using Google.Cloud.Firestore.V1;
using Newtonsoft.Json;
using Opton.Pages;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace Opton.Handlers
{
    public class db_handler : IHttpAsyncHandler, System.Web.SessionState.IRequiresSessionState
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

            try
            {
                using (var reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
                {
                    string body = await reader.ReadToEndAsync();
                    data = JsonConvert.DeserializeObject(body);
                    Debug.WriteLine($"========================================");
                    Debug.WriteLine($"[db_handler] Received request body: {body}");
                    Debug.WriteLine($"[db_handler] Parsed data.action: {data?.action}");
                    Debug.WriteLine($"========================================");
                }

                var db = SiteMaster.FirestoreDbInstance;
                Debug.WriteLine($"[db_handler] Firestore DB Instance: {(db != null ? "Connected" : "NULL")}");

                string actionValue = data?.action?.ToString();

                // Route to appropriate handlers based on action
                switch (actionValue)
                {
                    case "updateUserProfile":
                        await HandleUserOperations(context, data, db);
                        return;

                    case "addStaff":
                    case "updateStaff":
                    case "deleteStaff":
                        await HandleStaffOperations(context, data, db);
                        return;

                    case "addRetailer":
                    case "updateRetailer":
                    case "deleteRetailer":
                        await HandleRetailerOperations(context, data, db);
                        return;

                    case "addProduct":
                    case "updateProduct":
                    case "deleteProduct":
                        await HandleProductOperations(context, data, db);
                        return;

                    case "addRestock":
                    case "updateRestock":
                    case "deleteRestock":
                        await HandleRestockOperations(context, data, db);
                        return;

                    case "addOrder":
                    case "updateOrder":
                    case "deleteOrder":
                        await HandleOrderOperations(context, data, db);
                        return;

                    case "addReview":
                    case "updateReview":
                    case "deleteReview":
                        await HandleReviewOperations(context, data, db);
                        return;

                    case "addAppointment":
                    case "updateAppointment":
                    case "deleteAppointment":
                        await HandleAppointmentOperations(context, data, db);
                        return;

                    default:
                        message = "Invalid action specified";
                        break;
                }

                Debug.WriteLine("[db_handler] No matching handler found for request");
            }
            catch (Exception ex)
            {
                success = false;
                message = ex.Message;
                Debug.WriteLine($"!!! FATAL ERROR in db_handler ProcessRequestAsync !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");
            }

            context.Response.Write(JsonConvert.SerializeObject(new
            {
                success,
                message
            }));
        }

        #region User Operations
        private async Task HandleUserOperations(HttpContext context, dynamic data, FirestoreDb db)
        {
            context.Response.ContentType = "application/json";
            Debug.WriteLine("=== HandleUpdateUserProfile START ===");

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
                var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync((string)data.idToken);
                string uid = decodedToken.Uid;
                Debug.WriteLine($"Token verified for UID: {uid}");

                // Prepare user data
                var userData = new Dictionary<string, object>
                {
                    ["name"] = data?.name?.ToString() ?? "",
                    ["phoneNo"] = data?.phoneNo?.ToString() ?? "",
                    ["address"] = data?.address?.ToString() ?? "",
                    ["prescription"] = data?.prescription?.ToString() ?? ""
                };

                Debug.WriteLine($"Updating user profile: {JsonConvert.SerializeObject(userData)}");

                // Update user document
                await db.Collection("Users").Document(uid).SetAsync(userData, SetOptions.MergeAll);

                Debug.WriteLine("✓ Successfully updated user profile");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    message = "Profile updated successfully"
                }));

                Debug.WriteLine("=== HandleUpdateUserProfile END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleUpdateUserProfile !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }
        #endregion

        #region Staff Operations
        private async Task HandleStaffOperations(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("=== HandleStaffOperations START ===");
            string action = data?.action?.ToString();

            try
            {
                if (action == "deleteStaff")
                {
                    string staffId = data?.staffId?.ToString() ?? "";

                    if (string.IsNullOrEmpty(staffId))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = false,
                            message = "Staff ID is required"
                        }));
                        return;
                    }

                    await db.Collection("Staff").Document(staffId).DeleteAsync();

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Staff deleted successfully"
                    }));
                    return;
                }

                if (action == "addStaff" || action == "updateStaff")
                {
                    string staffId = data?.staffId?.ToString() ?? "";

                    // For new staff, generate ID
                    if (action == "addStaff" || string.IsNullOrEmpty(staffId))
                    {
                        staffId = db.Collection("Staff").Document().Id;
                    }

                    var staffData = new Dictionary<string, object>
                    {
                        ["userId"] = data?.userId?.ToString() ?? "",
                        ["email"] = data?.email?.ToString() ?? "",
                        ["name"] = data?.name?.ToString() ?? "",
                        ["phoneNo"] = data?.phoneNo?.ToString() ?? "",
                        ["storeId"] = data?.storeId?.ToString() ?? "",
                        ["role"] = data?.role?.ToString() ?? "Staff",
                        ["addedOn"] = Timestamp.FromDateTime(DateTime.UtcNow)
                    };

                    await db.Collection("Staff").Document(staffId).SetAsync(staffData, SetOptions.MergeAll);

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = action == "addStaff" ? "Staff added successfully" : "Staff updated successfully",
                        staffId
                    }));
                }

                Debug.WriteLine("=== HandleStaffOperations END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleStaffOperations !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }
        #endregion

        #region Retailer Operations
        private async Task HandleRetailerOperations(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("=== HandleRetailerOperations START ===");
            string action = data?.action?.ToString();

            try
            {
                if (action == "deleteRetailer")
                {
                    string retailerId = data?.retailerId?.ToString() ?? "";

                    if (string.IsNullOrEmpty(retailerId))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = false,
                            message = "Retailer ID is required"
                        }));
                        return;
                    }

                    await db.Collection("Retailers").Document(retailerId).DeleteAsync();

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Retailer deleted successfully"
                    }));
                    return;
                }

                if (action == "addRetailer" || action == "updateRetailer")
                {
                    string retailerId = data?.retailerId?.ToString() ?? "";

                    // For new retailer, generate ID
                    if (action == "addRetailer" || string.IsNullOrEmpty(retailerId))
                    {
                        retailerId = db.Collection("Retailers").Document().Id;
                    }

                    // Parse opening hours
                    Dictionary<string, object> openingHours = new Dictionary<string, object>();
                    if (data?.openingHours != null)
                    {
                        string openingHoursJson = data.openingHours.ToString();
                        openingHours = JsonConvert.DeserializeObject<Dictionary<string, object>>(openingHoursJson);
                    }

                    var retailerData = new Dictionary<string, object>
                    {
                        ["name"] = data?.name?.ToString() ?? "",
                        ["address"] = data?.address?.ToString() ?? "",
                        ["longitude"] = data?.longitude != null ? Convert.ToDouble(data.longitude) : 0.0,
                        ["latitude"] = data?.latitude != null ? Convert.ToDouble(data.latitude) : 0.0,
                        ["phoneNo"] = data?.phoneNo != null ? Convert.ToInt64(data.phoneNo) : 0L,
                        ["openingHours"] = openingHours
                    };

                    await db.Collection("Retailers").Document(retailerId).SetAsync(retailerData, SetOptions.MergeAll);

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = action == "addRetailer" ? "Retailer added successfully" : "Retailer updated successfully",
                        retailerId
                    }));
                }

                Debug.WriteLine("=== HandleRetailerOperations END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleRetailerOperations !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }
        #endregion

        #region Product Operations
        private async Task HandleProductOperations(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("=== HandleProductOperations START ===");
            string action = data?.action?.ToString();

            try
            {
                if (action == "deleteProduct")
                {
                    string productId = data?.productId?.ToString() ?? "";

                    if (string.IsNullOrEmpty(productId))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = false,
                            message = "Product ID is required"
                        }));
                        return;
                    }

                    await db.Collection("Products").Document(productId).DeleteAsync();

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Product deleted successfully"
                    }));
                    return;
                }

                if (action == "addProduct" || action == "updateProduct")
                {
                    string productId = data?.productId?.ToString() ?? "";

                    // For new product, generate ID
                    if (action == "addProduct" || string.IsNullOrEmpty(productId))
                    {
                        productId = db.Collection("Products").Document().Id;
                    }

                    // Parse JSON fields
                    Dictionary<string, object> inventory = ParseJsonField(data?.inventory);
                    Dictionary<string, object> R1 = ParseJsonField(data?.R1);
                    Dictionary<string, object> R2 = ParseJsonField(data?.R2);
                    Dictionary<string, object> R3 = ParseJsonField(data?.R3);

                    // Parse timeAdded properly
                    DateTime timeAdded = DateTime.UtcNow;
                    if (data?.timeAdded != null)
                    {
                        string timeAddedStr = data.timeAdded.ToString();
                        if (!string.IsNullOrEmpty(timeAddedStr))
                        {
                            DateTime parsedDate = ParseDateTime(timeAddedStr);
                            // Ensure it's UTC
                            if (parsedDate.Kind == DateTimeKind.Unspecified)
                            {
                                timeAdded = DateTime.SpecifyKind(parsedDate, DateTimeKind.Utc);
                            }
                            else if (parsedDate.Kind == DateTimeKind.Local)
                            {
                                timeAdded = parsedDate.ToUniversalTime();
                            }
                            else
                            {
                                timeAdded = parsedDate;
                            }
                        }
                    }

                    var productData = new Dictionary<string, object>
                    {
                        ["name"] = data?.name?.ToString() ?? "",
                        ["description"] = data?.description?.ToString() ?? "",
                        ["category"] = data?.category?.ToString() ?? "",
                        ["subCategory"] = data?.subCategory?.ToString() ?? "",
                        ["material"] = data?.material?.ToString() ?? "",
                        ["shape"] = data?.shape?.ToString() ?? "",
                        ["price"] = data?.price != null ? Convert.ToDouble(data.price) : 0.0,
                        ["tags"] = data?.tags?.ToString() ?? "",
                        ["model"] = data?.model?.ToString() ?? "",
                        ["dimensions"] = data?.dimensions?.ToString() ?? "",
                        ["timeAdded"] = Timestamp.FromDateTime(timeAdded),
                        ["inventory"] = inventory,
                        ["R1"] = R1,
                        ["R2"] = R2,
                        ["R3"] = R3
                    };

                    await db.Collection("Products").Document(productId).SetAsync(productData, SetOptions.MergeAll);

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = action == "addProduct" ? "Product added successfully" : "Product updated successfully",
                        productId
                    }));
                }

                Debug.WriteLine("=== HandleProductOperations END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleProductOperations !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }
        #endregion

        #region Restock Operations
        private async Task HandleRestockOperations(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("=== HandleRestockOperations START ===");
            string action = data?.action?.ToString();

            try
            {
                if (action == "deleteRestock")
                {
                    string restockId = data?.restockId?.ToString() ?? "";

                    if (string.IsNullOrEmpty(restockId))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = false,
                            message = "Restock ID is required"
                        }));
                        return;
                    }

                    await db.Collection("Restock").Document(restockId).DeleteAsync();

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Restock request deleted successfully"
                    }));
                    return;
                }

                if (action == "addRestock" || action == "updateRestock")
                {
                    string restockId = data?.restockId?.ToString() ?? "";

                    // For new restock, generate ID in RE-1, RE-2 format
                    if (action == "addRestock" || string.IsNullOrEmpty(restockId))
                    {
                        restockId = await GenerateRestockId(db);
                    }

                    var restockData = new Dictionary<string, object>
                    {
                        ["productId"] = data?.productId?.ToString() ?? "",
                        ["colour"] = data?.colour?.ToString() ?? "",
                        ["size"] = data?.size?.ToString() ?? "",
                        ["quantity"] = data?.quantity != null ? Convert.ToInt32(data.quantity) : 0,
                        ["storeId"] = data?.storeId?.ToString() ?? "",
                        ["requestTime"] = Timestamp.FromDateTime(DateTime.UtcNow),
                        ["requestedBy"] = data?.requestedBy?.ToString() ?? "",
                        ["status"] = data?.status?.ToString() ?? "Pending",
                        ["reviewedBy"] = data?.reviewedBy?.ToString() ?? "",
                        ["remarks"] = data?.remarks?.ToString() ?? ""
                    };

                    await db.Collection("Restock").Document(restockId).SetAsync(restockData, SetOptions.MergeAll);

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = action == "addRestock" ? "Restock request added successfully" : "Restock request updated successfully",
                        restockId
                    }));
                }

                Debug.WriteLine("=== HandleRestockOperations END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleRestockOperations !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private async Task<string> GenerateRestockId(FirestoreDb db)
        {
            try
            {
                // Get all restocks to find the highest ID
                var restocksRef = db.Collection("Restock");
                var snapshot = await restocksRef.GetSnapshotAsync();

                int maxId = 0;
                foreach (var document in snapshot.Documents)
                {
                    var docId = document.Id;
                    // Extract number from "RE-1", "RE-2", etc.
                    if (docId.StartsWith("RE-"))
                    {
                        string numPart = docId.Substring(3);
                        if (int.TryParse(numPart, out int num))
                        {
                            if (num > maxId)
                            {
                                maxId = num;
                            }
                        }
                    }
                }

                // Generate next ID
                int nextId = maxId + 1;
                return $"RE-{nextId}";
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error generating restock ID: {ex.Message}");
                // Fallback to timestamp-based ID
                return $"RE-{DateTime.UtcNow.Ticks}";
            }
        }
        #endregion

        #region Order Operations
        private async Task HandleOrderOperations(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("=== HandleOrderOperations START ===");
            string action = data?.action?.ToString();

            try
            {
                if (action == "deleteOrder")
                {
                    string orderId = data?.orderId?.ToString() ?? "";

                    if (string.IsNullOrEmpty(orderId))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = false,
                            message = "Order ID is required"
                        }));
                        return;
                    }

                    await db.Collection("Orders").Document(orderId).DeleteAsync();

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Order deleted successfully"
                    }));
                    return;
                }

                if (action == "addOrder" || action == "updateOrder")
                {
                    string orderId = data?.orderId?.ToString() ?? "";

                    // For update, orderId must be provided
                    if (action == "updateOrder" && string.IsNullOrEmpty(orderId))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = false,
                            message = "Order ID is required for update"
                        }));
                        return;
                    }

                    // For new order, generate ID in OR-1, OR-2 format
                    if (action == "addOrder" || string.IsNullOrEmpty(orderId))
                    {
                        orderId = await GenerateOrderId(db);
                    }

                    // For updates, get existing order first to preserve fields not being updated
                    Dictionary<string, object> existingOrder = new Dictionary<string, object>();
                    if (action == "updateOrder")
                    {
                        // Check if order uses new format
                        var existingDoc = await db.Collection("Orders").Document(orderId).GetSnapshotAsync();
                        if (existingDoc.Exists)
                        {
                            var existingData = existingDoc.ToDictionary();

                            if (existingData.ContainsKey("customer"))
                            {
                                // Use new format update
                                var updateData = new Dictionary<string, object>();

                                // Update status in payment section
                                if (data?.status != null && existingData.ContainsKey("payment"))
                                {
                                    var payment = existingData["payment"] as Dictionary<string, object> ?? new Dictionary<string, object>();
                                    payment["status"] = data.status.ToString();
                                    updateData["payment"] = payment;
                                    updateData["status"] = data.status.ToString();
                                }

                                // Update tracking info if provided
                                if (data?.trackingNo != null)
                                {
                                    updateData["trackingNo"] = data.trackingNo.ToString();
                                }

                                // Update timestamp
                                updateData["updatedAt"] = Timestamp.FromDateTime(DateTime.UtcNow);

                                await db.Collection("Orders").Document(orderId).UpdateAsync(updateData);

                                context.Response.Write(JsonConvert.SerializeObject(new
                                {
                                    success = true,
                                    message = "Order updated successfully (new format)",
                                    orderId
                                }));
                                return;
                            }
                        }
                    }

                    // Parse JSON fields - ensure proper structure
                    Dictionary<string, object> items;
                    Dictionary<string, object> price;

                    // For updates, try to get from request first, then fall back to existing
                    if (data?.items != null)
                    {
                        items = ParseOrderItems(data.items);
                    }
                    else if (existingOrder.ContainsKey("items"))
                    {
                        items = existingOrder["items"] as Dictionary<string, object> ?? new Dictionary<string, object>();
                    }
                    else
                    {
                        items = new Dictionary<string, object>();
                    }

                    if (data?.price != null)
                    {
                        price = ParseOrderPrice(data.price);
                    }
                    else if (existingOrder.ContainsKey("price"))
                    {
                        price = existingOrder["price"] as Dictionary<string, object> ?? new Dictionary<string, object>();
                    }
                    else
                    {
                        price = new Dictionary<string, object>();
                    }

                    // Parse timestamps using safe conversion
                    Timestamp orderTime;
                    if (data?.orderTime != null)
                    {
                        orderTime = SafeConvertToTimestamp(data.orderTime.ToString());
                    }
                    else if (existingOrder.ContainsKey("orderTime") && existingOrder["orderTime"] is Timestamp)
                    {
                        orderTime = (Timestamp)existingOrder["orderTime"];
                    }
                    else
                    {
                        orderTime = Timestamp.FromDateTime(DateTime.UtcNow);
                    }

                    Timestamp arrivalTime;
                    if (data?.arrivalTime != null)
                    {
                        arrivalTime = SafeConvertToTimestamp(data.arrivalTime.ToString());
                    }
                    else if (existingOrder.ContainsKey("arrivalTime") && existingOrder["arrivalTime"] is Timestamp)
                    {
                        arrivalTime = (Timestamp)existingOrder["arrivalTime"];
                    }
                    else
                    {
                        arrivalTime = Timestamp.FromDateTime(DateTime.UtcNow.AddDays(7));
                    }

                    // Handle optional returnRefundTime
                    object returnRefundTime = null;
                    if (data?.returnRefundTime != null)
                    {
                        string refundTimeStr = data.returnRefundTime.ToString();
                        if (!string.IsNullOrEmpty(refundTimeStr))
                        {
                            returnRefundTime = SafeConvertToTimestamp(refundTimeStr);
                        }
                    }
                    else if (existingOrder.ContainsKey("returnRefundTime") && existingOrder["returnRefundTime"] is Timestamp)
                    {
                        returnRefundTime = existingOrder["returnRefundTime"];
                    }

                    // Build order data with proper fallbacks
                    var orderData = new Dictionary<string, object>
                    {
                        ["orderId"] = orderId,
                        ["userId"] = data?.userId?.ToString() ?? (existingOrder.ContainsKey("userId") ? existingOrder["userId"]?.ToString() : "") ?? "",
                        ["name"] = data?.userId?.ToString() ?? (existingOrder.ContainsKey("name") ? existingOrder["name"]?.ToString() : "") ?? "",
                        ["email"] = data?.email?.ToString() ?? (existingOrder.ContainsKey("email") ? existingOrder["email"]?.ToString() : "") ?? "",
                        ["phoneNo"] = data?.phoneNo?.ToString() ?? (existingOrder.ContainsKey("phoneNo") ? existingOrder["phoneNo"]?.ToString() : "") ?? "",
                        ["address"] = data?.address?.ToString() ?? (existingOrder.ContainsKey("address") ? existingOrder["address"]?.ToString() : "") ?? "",
                        ["items"] = items,
                        ["price"] = price,
                        ["discount"] = data?.discount != null ? Convert.ToDouble(data.discount) :
                                      (existingOrder.ContainsKey("discount") ? Convert.ToDouble(existingOrder["discount"]) : 0.0),
                        ["paymentType"] = data?.paymentType?.ToString() ?? (existingOrder.ContainsKey("paymentType") ? existingOrder["paymentType"]?.ToString() : "") ?? "",
                        ["orderTime"] = orderTime,
                        ["arrivalTime"] = arrivalTime,
                        ["trackingNo"] = data?.trackingNo?.ToString() ?? (existingOrder.ContainsKey("trackingNo") ? existingOrder["trackingNo"]?.ToString() : "") ?? GenerateTrackingNumber(),
                        ["status"] = data?.status?.ToString() ?? (existingOrder.ContainsKey("status") ? existingOrder["status"]?.ToString() : "") ?? "Pending",
                        ["deliveredFrom"] = data?.deliveredFrom?.ToString() ?? (existingOrder.ContainsKey("deliveredFrom") ? existingOrder["deliveredFrom"]?.ToString() : "") ?? "R1",
                        ["refundReason"] = data?.refundReason?.ToString() ?? (existingOrder.ContainsKey("refundReason") ? existingOrder["refundReason"]?.ToString() : "") ?? "",
                        ["processedBy"] = data?.processedBy?.ToString() ?? (existingOrder.ContainsKey("processedBy") ? existingOrder["processedBy"]?.ToString() : "") ?? ""
                    };

                    // Only add returnRefundTime if it has a value
                    if (returnRefundTime != null)
                    {
                        orderData["returnRefundTime"] = returnRefundTime;
                    }

                    Debug.WriteLine($"Saving order data: {JsonConvert.SerializeObject(orderData)}");

                    await db.Collection("Orders").Document(orderId).SetAsync(orderData, SetOptions.MergeAll);

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = action == "addOrder" ? "Order added successfully" : "Order updated successfully",
                        orderId
                    }));
                }

                Debug.WriteLine("=== HandleOrderOperations END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleOrderOperations !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }

        private Dictionary<string, object> ParseOrderItems(dynamic itemsField)
        {
            if (itemsField == null)
            {
                return new Dictionary<string, object>();
            }

            try
            {
                // If it's already a string, deserialize it
                string jsonStr = itemsField.ToString();
                var itemsDict = JsonConvert.DeserializeObject<Dictionary<string, object>>(jsonStr);

                // Process each item to ensure proper structure
                var result = new Dictionary<string, object>();
                foreach (var kvp in itemsDict)
                {
                    if (kvp.Value is Newtonsoft.Json.Linq.JObject jObj)
                    {
                        result[kvp.Key] = jObj.ToObject<Dictionary<string, object>>();
                    }
                    else
                    {
                        result[kvp.Key] = kvp.Value;
                    }
                }

                return result;
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error parsing order items: {ex.Message}");
                return new Dictionary<string, object>();
            }
        }

        private Dictionary<string, object> ParseOrderPrice(dynamic priceField)
        {
            if (priceField == null)
            {
                return new Dictionary<string, object>();
            }

            try
            {
                string jsonStr = priceField.ToString();
                var priceDict = JsonConvert.DeserializeObject<Dictionary<string, object>>(jsonStr);

                var result = new Dictionary<string, object>();
                foreach (var kvp in priceDict)
                {
                    if (kvp.Value is Newtonsoft.Json.Linq.JObject jObj)
                    {
                        result[kvp.Key] = jObj.ToObject<Dictionary<string, object>>();
                    }
                    else
                    {
                        result[kvp.Key] = kvp.Value;
                    }
                }

                return result;
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error parsing order price: {ex.Message}");
                return new Dictionary<string, object>();
            }
        }

        private async Task<string> GenerateOrderId(FirestoreDb db)
        {
            try
            {
                // Get all orders to find the highest ID
                var ordersRef = db.Collection("Orders");
                var snapshot = await ordersRef.GetSnapshotAsync();

                int maxId = 0;
                foreach (var document in snapshot.Documents)
                {
                    var data = document.ToDictionary();
                    if (data.ContainsKey("orderId"))
                    {
                        string orderId = data["orderId"]?.ToString() ?? "";
                        // Extract number from "OR-1", "OR-2", etc.
                        if (orderId.StartsWith("OR-"))
                        {
                            string numPart = orderId.Substring(3);
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
                return $"OR-{nextId}";
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error generating order ID: {ex.Message}");
                // Fallback to timestamp-based ID
                return $"OR-{DateTime.UtcNow.Ticks}";
            }
        }

        private string GenerateTrackingNumber()
        {
            const string prefix = "TRK";
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            var random = new Random();

            string randomPart = new string(Enumerable.Repeat(chars, 6)
                .Select(s => s[random.Next(s.Length)]).ToArray());

            return $"{prefix}{randomPart}";
        }

        private Timestamp SafeConvertToTimestamp(string dateTimeStr)
        {
            if (string.IsNullOrEmpty(dateTimeStr))
            {
                return Timestamp.FromDateTime(DateTime.UtcNow);
            }

            try
            {
                DateTime dt = DateTime.Parse(dateTimeStr);

                // Ensure UTC
                DateTime utcDt;
                if (dt.Kind == DateTimeKind.Utc)
                {
                    utcDt = dt;
                }
                else if (dt.Kind == DateTimeKind.Local)
                {
                    utcDt = dt.ToUniversalTime();
                }
                else // Unspecified
                {
                    // Try parsing as ISO format first
                    if (dateTimeStr.EndsWith("Z") || dateTimeStr.Contains("+"))
                    {
                        utcDt = DateTime.Parse(dateTimeStr, null, System.Globalization.DateTimeStyles.AdjustToUniversal);
                    }
                    else
                    {
                        // Assume local time and convert
                        utcDt = DateTime.SpecifyKind(dt, DateTimeKind.Local).ToUniversalTime();
                    }
                }

                return Timestamp.FromDateTime(utcDt);
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error converting to Timestamp: {ex.Message} - Input: {dateTimeStr}");
                return Timestamp.FromDateTime(DateTime.UtcNow);
            }
        }
        #endregion

        #region Review Operations
        private async Task HandleReviewOperations(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("=== HandleReviewOperations START ===");
            string action = data?.action?.ToString();

            try
            {
                if (action == "deleteReview")
                {
                    string reviewId = data?.reviewId?.ToString() ?? "";

                    if (string.IsNullOrEmpty(reviewId))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = false,
                            message = "Review ID is required"
                        }));
                        return;
                    }

                    await db.Collection("Reviews").Document(reviewId).DeleteAsync();

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Review deleted successfully"
                    }));
                    return;
                }

                if (action == "addReview" || action == "updateReview")
                {
                    string reviewId = data?.reviewId?.ToString() ?? "";

                    // For new review, generate ID
                    if (action == "addReview" || string.IsNullOrEmpty(reviewId))
                    {
                        reviewId = db.Collection("Reviews").Document().Id;
                    }

                    // Get user info - handle both authenticated and guest users
                    string userId = data?.userId?.ToString() ?? "";
                    string email = data?.email?.ToString() ?? "";

                    // If idToken is provided, verify it (authenticated user)
                    if (data?.idToken != null && !string.IsNullOrEmpty(data.idToken.ToString()))
                    {
                        try
                        {
                            var decodedToken = await FirebaseAdmin.Auth.FirebaseAuth.DefaultInstance
                                .VerifyIdTokenAsync((string)data.idToken);
                            userId = decodedToken.Uid;
                            // Use authenticated user's email if available
                            if (string.IsNullOrEmpty(email))
                            {
                                email = decodedToken.Claims.ContainsKey("email")
                                    ? decodedToken.Claims["email"].ToString()
                                    : email;
                            }
                        }
                        catch (Exception ex)
                        {
                            Debug.WriteLine($"Token verification failed: {ex.Message}");
                            // Continue as guest if token verification fails
                        }
                    }

                    var reviewData = new Dictionary<string, object>
                    {
                        ["userId"] = userId,
                        ["email"] = email,
                        ["productId"] = data?.productId?.ToString() ?? "",
                        ["size"] = data?.size?.ToString() ?? "",
                        ["colour"] = data?.colour?.ToString() ?? "",
                        ["review"] = data?.review?.ToString() ?? "",
                        ["rating"] = data?.rating != null ? Convert.ToDouble(data.rating) : 0.0,
                        ["media"] = data?.media?.ToString() ?? "",
                        ["dateTime"] = Timestamp.FromDateTime(DateTime.UtcNow),
                        ["isGuest"] = data?.idToken == null || string.IsNullOrEmpty(data.idToken.ToString())
                    };

                    await db.Collection("Reviews").Document(reviewId).SetAsync(reviewData, SetOptions.MergeAll);

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = action == "addReview" ? "Review added successfully" : "Review updated successfully",
                        reviewId
                    }));
                }

                Debug.WriteLine("=== HandleReviewOperations END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleReviewOperations !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }
        #endregion

        #region Appointment Operations
        private async Task HandleAppointmentOperations(HttpContext context, dynamic data, FirestoreDb db)
        {
            Debug.WriteLine("=== HandleAppointmentOperations START ===");
            string action = data?.action?.ToString();

            try
            {
                if (action == "deleteAppointment")
                {
                    string appointmentId = data?.appointmentId?.ToString() ?? "";

                    if (string.IsNullOrEmpty(appointmentId))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = false,
                            message = "Appointment ID is required"
                        }));
                        return;
                    }

                    await db.Collection("Appointments").Document(appointmentId).DeleteAsync();

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Appointment deleted successfully"
                    }));
                    return;
                }

                if (action == "addAppointment" || action == "updateAppointment")
                {
                    string appointmentId = data?.appointmentId?.ToString() ?? "";

                    // For update, appointmentId must be provided
                    if (action == "updateAppointment" && string.IsNullOrEmpty(appointmentId))
                    {
                        context.Response.Write(JsonConvert.SerializeObject(new
                        {
                            success = false,
                            message = "Appointment ID is required for update"
                        }));
                        return;
                    }

                    // For new appointment, generate ID
                    if (action == "addAppointment" || string.IsNullOrEmpty(appointmentId))
                    {
                        appointmentId = await GenerateAppointmentId(db);
                    }

                    // For updates, get existing appointment first to preserve fields not being updated
                    Dictionary<string, object> existingAppointment = new Dictionary<string, object>();
                    if (action == "updateAppointment")
                    {
                        try
                        {
                            var existingDoc = await db.Collection("Appointments").Document(appointmentId).GetSnapshotAsync();
                            if (existingDoc.Exists)
                            {
                                existingAppointment = existingDoc.ToDictionary();
                                Debug.WriteLine($"Found existing appointment: {appointmentId}");
                            }
                        }
                        catch (Exception ex)
                        {
                            Debug.WriteLine($"Error fetching existing appointment: {ex.Message}");
                        }
                    }

                    // Parse JSON fields - with fallback to existing data
                    Dictionary<string, object> prescription;
                    Dictionary<string, object> holdItem;

                    if (data?.prescription != null)
                    {
                        prescription = ParseJsonField(data.prescription);
                    }
                    else if (existingAppointment.ContainsKey("prescription"))
                    {
                        prescription = existingAppointment["prescription"] as Dictionary<string, object> ?? new Dictionary<string, object>();
                    }
                    else
                    {
                        prescription = new Dictionary<string, object>();
                    }

                    if (data?.holdItem != null)
                    {
                        holdItem = ParseJsonField(data.holdItem);
                    }
                    else if (existingAppointment.ContainsKey("holdItem") || existingAppointment.ContainsKey("holdItems"))
                    {
                        // Check both holdItem and holdItems for backwards compatibility
                        holdItem = (existingAppointment["holdItem"] ?? existingAppointment["holdItems"]) as Dictionary<string, object> ?? new Dictionary<string, object>();
                    }
                    else
                    {
                        holdItem = new Dictionary<string, object>();
                    }

                    // Parse phone number
                    long phoneNo = 0;
                    string phoneNoStr = data?.phoneNo?.ToString() ?? (existingAppointment.ContainsKey("phoneNo") ? existingAppointment["phoneNo"]?.ToString() : "") ?? "";
                    string cleanPhone = new string(phoneNoStr.Where(char.IsDigit).ToArray());
                    long.TryParse(cleanPhone, out phoneNo);

                    // Parse dateTime with proper UTC handling
                    Timestamp dateTimeTimestamp;
                    if (data?.dateTime != null)
                    {
                        try
                        {
                            string dateTimeStr = data.dateTime.ToString();
                            DateTime dt;

                            // Try parsing as ISO format first
                            if (DateTime.TryParse(dateTimeStr, null, System.Globalization.DateTimeStyles.RoundtripKind, out dt))
                            {
                                // Convert to UTC if not already
                                if (dt.Kind == DateTimeKind.Utc)
                                {
                                    dateTimeTimestamp = Timestamp.FromDateTime(dt);
                                }
                                else if (dt.Kind == DateTimeKind.Local)
                                {
                                    dateTimeTimestamp = Timestamp.FromDateTime(dt.ToUniversalTime());
                                }
                                else
                                {
                                    // Assume UTC
                                    dateTimeTimestamp = Timestamp.FromDateTime(DateTime.SpecifyKind(dt, DateTimeKind.Utc));
                                }
                            }
                            else
                            {
                                throw new Exception("Invalid dateTime format");
                            }
                        }
                        catch (Exception ex)
                        {
                            Debug.WriteLine($"Error parsing dateTime: {ex.Message}");
                            dateTimeTimestamp = Timestamp.FromDateTime(DateTime.UtcNow);
                        }
                    }
                    else if (existingAppointment.ContainsKey("dateTime") && existingAppointment["dateTime"] is Timestamp)
                    {
                        dateTimeTimestamp = (Timestamp)existingAppointment["dateTime"];
                    }
                    else
                    {
                        dateTimeTimestamp = Timestamp.FromDateTime(DateTime.UtcNow);
                    }

                    // Build appointment data with proper fallbacks
                    var appointmentData = new Dictionary<string, object>
                    {
                        ["appointmentId"] = appointmentId,
                        ["storeId"] = data?.storeId?.ToString() ?? (existingAppointment.ContainsKey("storeId") ? existingAppointment["storeId"]?.ToString() : "") ?? "",
                        ["userId"] = data?.userId?.ToString() ?? (existingAppointment.ContainsKey("userId") ? existingAppointment["userId"]?.ToString() : "") ?? "",
                        ["email"] = data?.email?.ToString() ?? (existingAppointment.ContainsKey("email") ? existingAppointment["email"]?.ToString() : "") ?? "",
                        ["name"] = data?.name?.ToString() ?? (existingAppointment.ContainsKey("name") ? existingAppointment["name"]?.ToString() : "") ?? "",
                        ["phoneNo"] = phoneNo,
                        ["details"] = data?.details?.ToString() ?? (existingAppointment.ContainsKey("details") ? existingAppointment["details"]?.ToString() : "") ?? "",
                        ["prescription"] = prescription,
                        ["type"] = data?.type?.ToString() ?? (existingAppointment.ContainsKey("type") ? existingAppointment["type"]?.ToString() : "") ?? "Consultation",
                        ["dateTime"] = dateTimeTimestamp,
                        ["remarks"] = data?.remarks?.ToString() ?? (existingAppointment.ContainsKey("remarks") ? existingAppointment["remarks"]?.ToString() : "") ?? "",
                        ["holdItem"] = holdItem,
                        ["status"] = data?.status?.ToString() ?? (existingAppointment.ContainsKey("status") ? existingAppointment["status"]?.ToString() : "") ?? "Booked",
                        ["staffId"] = data?.staffId?.ToString() ?? (existingAppointment.ContainsKey("staffId") ? existingAppointment["staffId"]?.ToString() : "") ?? "",
                        ["cancelReason"] = data?.cancelReason?.ToString() ?? (existingAppointment.ContainsKey("cancelReason") ? existingAppointment["cancelReason"]?.ToString() : "") ?? ""
                    };

                    Debug.WriteLine($"Saving appointment data: {JsonConvert.SerializeObject(appointmentData)}");

                    await db.Collection("Appointments").Document(appointmentId).SetAsync(appointmentData, SetOptions.MergeAll);

                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = action == "addAppointment" ? "Appointment added successfully" : "Appointment updated successfully",
                        appointmentId
                    }));
                }

                Debug.WriteLine("=== HandleAppointmentOperations END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleAppointmentOperations !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }
        #endregion

        #region Helper Methods
        private Dictionary<string, object> ParseJsonField(dynamic field)
        {
            if (field == null)
            {
                return new Dictionary<string, object>();
            }

            try
            {
                string jsonStr = field.ToString();
                var dict = JsonConvert.DeserializeObject<Dictionary<string, object>>(jsonStr);
                return ProcessNestedDictionary(dict);
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error parsing JSON field: {ex.Message}");
                return new Dictionary<string, object>();
            }
        }

        private Dictionary<string, object> ProcessNestedDictionary(Dictionary<string, object> dict)
        {
            if (dict == null)
                return new Dictionary<string, object>();

            var result = new Dictionary<string, object>();

            foreach (var kvp in dict)
            {
                if (kvp.Value is Newtonsoft.Json.Linq.JObject jObj)
                {
                    result[kvp.Key] = ProcessNestedDictionary(
                        jObj.ToObject<Dictionary<string, object>>()
                    );
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

        private DateTime ParseDateTime(string dateTimeStr)
        {
            if (string.IsNullOrEmpty(dateTimeStr))
            {
                return DateTime.UtcNow;
            }

            try
            {
                DateTime dt = DateTime.Parse(dateTimeStr);

                // Convert to UTC if not already
                if (dt.Kind == DateTimeKind.Utc)
                {
                    return dt;
                }
                else if (dt.Kind == DateTimeKind.Local)
                {
                    return dt.ToUniversalTime();
                }
                else // DateTimeKind.Unspecified
                {
                    // Assume it's already in UTC and just specify the kind
                    return DateTime.SpecifyKind(dt, DateTimeKind.Utc);
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error parsing DateTime: {ex.Message}");
                return DateTime.UtcNow;
            }
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
        #endregion

        public void ProcessRequest(HttpContext context)
        {
            throw new NotImplementedException();
        }
    }
}