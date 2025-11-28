using Google.Cloud.Storage.V1;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using System.Web;

namespace Opton.Handlers
{
    public class storage_handler : HttpTaskAsyncHandler
    {
        private const string BucketName = "opton-e4a46.firebasestorage.app";

        public override async Task ProcessRequestAsync(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                // Debug info
                System.Diagnostics.Debug.WriteLine($"[STORAGE] Request method: {context.Request.HttpMethod}");
                System.Diagnostics.Debug.WriteLine($"[STORAGE] Content-Type: {context.Request.ContentType}");
                System.Diagnostics.Debug.WriteLine($"[STORAGE] Form keys: {string.Join(", ", context.Request.Form.AllKeys)}");
                System.Diagnostics.Debug.WriteLine($"[STORAGE] Has files: {context.Request.Files.Count}");

                // Try to get action from multiple sources
                string action = context.Request.Form["action"] ??
                               context.Request.QueryString["action"];

                // If we still don't have an action and this looks like a JSON request, parse the body
                if (string.IsNullOrEmpty(action) &&
                    context.Request.ContentType?.ToLower().Contains("application/json") == true)
                {
                    string requestBody;
                    using (var reader = new StreamReader(context.Request.InputStream))
                    {
                        requestBody = await reader.ReadToEndAsync();
                    }

                    System.Diagnostics.Debug.WriteLine($"[STORAGE] JSON body: {requestBody}");

                    if (!string.IsNullOrEmpty(requestBody))
                    {
                        var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(requestBody);
                        action = data.ContainsKey("action") ? data["action"].ToString() : null;

                        if (action == "deleteModel")
                        {
                            await HandleModelDelete(context, data);
                            return;
                        }
                        else if (action == "deleteProductFolder")
                        {
                            await HandleProductFolderDelete(context, data);
                            return;
                        }
                    }
                }

                // Handle form-based actions
                if (action == "uploadModel")
                {
                    await HandleModelUpload(context);
                }
                else if (action == "deleteModel")
                {
                    // For form-based delete (if any)
                    var formData = new Dictionary<string, object>
                    {
                        { "productId", context.Request.Form["productId"] },
                        { "fileName", context.Request.Form["fileName"] }
                    };
                    await HandleModelDelete(context, formData);
                }
                else if (action == "deleteProductFolder")
                {
                    // For form-based product folder delete (if any)
                    var formData = new Dictionary<string, object>
                    {
                        { "productId", context.Request.Form["productId"] }
                    };
                    await HandleProductFolderDelete(context, formData);
                }
                else if (action == "uploadReviewImage")
                {
                    await HandleReviewImageUpload(context);
                    return;
                }
                else
                {
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Invalid action: " + (action ?? "null")
                    }));
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[STORAGE ERROR] {ex}");
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message
                }));
            }
        }
        private async Task HandleModelUpload(HttpContext context)
        {
            if (context.Request.Files.Count == 0)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "No file uploaded"
                }));
                return;
            }

            var file = context.Request.Files[0];
            string productId = context.Request.Form["productId"];

            if (string.IsNullOrEmpty(productId))
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = "Product ID is required"
                }));
                return;
            }

            string fileName = Path.GetFileName(file.FileName);
            string storagePath = $"Products/{productId}/{fileName}";

            try
            {
                var storage = StorageClient.Create();

                using (var stream = file.InputStream)
                {
                    await storage.UploadObjectAsync(
                        BucketName,
                        storagePath,
                        file.ContentType,
                        stream
                    );
                }

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    filePath = $"gs://{BucketName}/{storagePath}",
                    fileName = fileName
                }));
            }
            catch (Exception ex)
            {
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = $"Upload failed: {ex.Message}"
                }));
            }
        }

        private async Task HandleModelDelete(HttpContext context, Dictionary<string, object> data)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE] Delete request received");

                string productId = data["productId"].ToString();
                string fileName = data["fileName"].ToString();

                System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE] Deleting: Products/{productId}/{fileName}");

                string filePath = $"Products/{productId}/{fileName}";

                var storage = StorageClient.Create();
                await storage.DeleteObjectAsync(BucketName, filePath);

                System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE] Successfully deleted: {filePath}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    message = "File deleted successfully"
                }));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE ERROR] {ex}");
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = $"Delete failed: {ex.Message}"
                }));
            }
        }

        private async Task HandleProductFolderDelete(HttpContext context, Dictionary<string, object> data)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE PRODUCT FOLDER] Request received");

                string productId = data["productId"].ToString();
                string folderPrefix = $"Products/{productId}/";

                System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE PRODUCT FOLDER] Deleting all files with prefix: {folderPrefix}");

                var storage = StorageClient.Create();

                // List all objects with the product folder prefix
                var objects = storage.ListObjects(BucketName, folderPrefix);

                int deletedCount = 0;
                var deleteTasks = new List<Task>();

                // Delete all files in parallel for better performance
                foreach (var obj in objects)
                {
                    try
                    {
                        var deleteTask = storage.DeleteObjectAsync(BucketName, obj.Name);
                        deleteTasks.Add(deleteTask);
                        System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE PRODUCT FOLDER] Queued delete for: {obj.Name}");
                        deletedCount++;
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE PRODUCT FOLDER ERROR] Failed to queue delete for {obj.Name}: {ex.Message}");
                    }
                }

                // Wait for all delete operations to complete
                if (deleteTasks.Count > 0)
                {
                    await Task.WhenAll(deleteTasks);
                }

                System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE PRODUCT FOLDER] Successfully deleted {deletedCount} files from folder: {folderPrefix}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    message = $"Deleted {deletedCount} files from product folder {productId}",
                    deletedCount = deletedCount
                }));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[STORAGE DELETE PRODUCT FOLDER ERROR] {ex}");
                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = $"Failed to delete product folder: {ex.Message}"
                }));
            }
        }

        private async Task HandleReviewImageUpload(HttpContext context)
        {
            try
            {
                Debug.WriteLine("=== HandleReviewImageUpload START ===");
                Debug.WriteLine($"Files count: {context.Request.Files.Count}");
                Debug.WriteLine($"Form keys: {string.Join(", ", context.Request.Form.AllKeys)}");

                if (context.Request.Files.Count == 0)
                {
                    Debug.WriteLine("No files in request");
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "No image uploaded"
                    }));
                    return;
                }

                var file = context.Request.Files[0];
                string productId = context.Request.Form["productId"];
                string fileName = context.Request.Form["fileName"];

                Debug.WriteLine($"File name from form: {fileName}");
                Debug.WriteLine($"File name from file object: {file.FileName}");
                Debug.WriteLine($"Product ID: {productId}");
                Debug.WriteLine($"File size: {file.ContentLength} bytes");
                Debug.WriteLine($"Content type: {file.ContentType}");

                if (string.IsNullOrEmpty(productId))
                {
                    Debug.WriteLine("Product ID is missing");
                    context.Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Product ID is required"
                    }));
                    return;
                }

                // Use provided fileName or generate from original
                if (string.IsNullOrEmpty(fileName))
                {
                    fileName = Path.GetFileName(file.FileName);
                    Debug.WriteLine($"Using original filename: {fileName}");
                }

                string storagePath = $"Reviews/{productId}/{fileName}";
                Debug.WriteLine($"Storage path: {storagePath}");
                Debug.WriteLine($"Bucket name: {BucketName}");

                var storage = StorageClient.Create();

                using (var stream = file.InputStream)
                {
                    Debug.WriteLine($"Stream length: {stream.Length} bytes");
                    Debug.WriteLine($"Starting upload...");

                    // Detect content type from file extension if not provided
                    string contentType = file.ContentType;
                    if (string.IsNullOrEmpty(contentType))
                    {
                        string extension = Path.GetExtension(fileName).ToLower();

                        if (extension == ".jpg" || extension == ".jpeg")
                        {
                            contentType = "image/jpeg";
                        }
                        else if (extension == ".png")
                        {
                            contentType = "image/png";
                        }
                        else if (extension == ".gif")
                        {
                            contentType = "image/gif";
                        }
                        else if (extension == ".webp")
                        {
                            contentType = "image/webp";
                        }
                        else if (extension == ".bmp")
                        {
                            contentType = "image/bmp";
                        }
                        else if (extension == ".svg")
                        {
                            contentType = "image/svg+xml";
                        }
                        else
                        {
                            contentType = "image/jpeg"; // fallback
                        }

                        Debug.WriteLine($"Detected content type from extension: {contentType}");
                    }

                    var uploadedObject = await storage.UploadObjectAsync(
                        BucketName,
                        storagePath,
                        contentType,
                        stream
                    );

                    Debug.WriteLine($"Upload complete! Object name: {uploadedObject.Name}");
                    Debug.WriteLine($"Object size: {uploadedObject.Size}");
                }

                Debug.WriteLine($"Review image uploaded successfully: {fileName}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    fileName = fileName,
                    storagePath = storagePath,
                    message = "Image uploaded successfully"
                }));

                Debug.WriteLine("=== HandleReviewImageUpload END (SUCCESS) ===");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"!!! ERROR in HandleReviewImageUpload !!!");
                Debug.WriteLine($"Message: {ex.Message}");
                Debug.WriteLine($"Stack: {ex.StackTrace}");
                Debug.WriteLine($"Inner exception: {ex.InnerException?.Message}");

                context.Response.Write(JsonConvert.SerializeObject(new
                {
                    success = false,
                    message = ex.Message,
                    details = ex.StackTrace
                }));
            }
        }

        public override bool IsReusable => false;
    }
}