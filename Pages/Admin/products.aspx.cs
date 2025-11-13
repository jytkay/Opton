using System;
using System.Collections.Generic;
using System.Web.Services;
using Google.Cloud.Firestore;
using Opton.Pages;

namespace Opton.Pages.Admin
{
    public partial class products : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is staff/admin
            if (Session["isAdmin"] == null || !(bool)Session["isAdmin"])
            {
                Response.Redirect("~/Pages/Customer/catalogue.aspx");
                return;
            }
        }

        [WebMethod]
        public static string GetProducts()
        {
            FirestoreDb db = SiteMaster.FirestoreDbInstance;
            var productsCol = db.Collection("Products").GetSnapshotAsync().Result;

            var products = new List<Product>();
            foreach (var doc in productsCol.Documents)
            {
                products.Add(doc.ConvertTo<Product>());
            }

            return Newtonsoft.Json.JsonConvert.SerializeObject(products);
        }

        [WebMethod]
        public static string AddOrUpdateProduct(Product product)
        {
            FirestoreDb db = SiteMaster.FirestoreDbInstance;
            var docRef = db.Collection("Products").Document(product.productId);
            docRef.SetAsync(product).Wait();
            return "Success";
        }

        [WebMethod]
        public static string DeleteProduct(string productId)
        {
            FirestoreDb db = SiteMaster.FirestoreDbInstance;
            db.Collection("Products").Document(productId).DeleteAsync().Wait();
            return "Deleted";
        }

        [WebMethod]
        public static string GetNextProductId()
        {
            FirestoreDb db = SiteMaster.FirestoreDbInstance;
            var snapshot = db.Collection("Products").GetSnapshotAsync().Result;
            int maxId = 0;

            foreach (var doc in snapshot.Documents)
            {
                string id = doc.Id.Replace("P-", "");
                if (int.TryParse(id, out int num))
                {
                    if (num > maxId) maxId = num;
                }
            }

            return $"P-{maxId + 1}";
        }
    }
}