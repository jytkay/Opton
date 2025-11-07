using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Google.Cloud.Firestore;

namespace Opton.Pages
{
    [FirestoreData]
    public class User
    {
        [FirestoreProperty]
        public string userId { get; set; }

        [FirestoreProperty]
        public string email { get; set; }

        [FirestoreProperty]
        public bool isVerified { get; set; }

        [FirestoreProperty]
        public string name { get; set; }

        [FirestoreProperty]
        public string phoneNo { get; set; }

        [FirestoreProperty]
        public string address { get; set; }

        [FirestoreProperty]
        public string prescription { get; set; }
        [FirestoreProperty]
        public DateTime joinDate { get; set; }
    }

    [FirestoreData]
    public class Staff
    {
        [FirestoreProperty]
        public string userId { get; set; }

        [FirestoreProperty]
        public string email { get; set; }

        [FirestoreProperty]
        public string name { get; set; }

        [FirestoreProperty]
        public string phoneNo { get; set; }

        [FirestoreProperty]
        public string storeId { get; set; }

        [FirestoreProperty]
        public string role { get; set; }

        [FirestoreProperty]
        public Timestamp addedOn { get; set; }
    }

    [FirestoreData]
    public class Product
    {
        [FirestoreDocumentId]
        public string productId { get; set; }

        [FirestoreProperty] public string name { get; set; }
        [FirestoreProperty] public string description { get; set; } = "";
        [FirestoreProperty] public string category { get; set; }
        [FirestoreProperty] public string subCategory { get; set; } = "";
        [FirestoreProperty] public string material { get; set; } = "";
        [FirestoreProperty] public string shape { get; set; } = "";
        [FirestoreProperty] public double price { get; set; } = 0;
        [FirestoreProperty] public string tags { get; set; } = "";
        [FirestoreProperty] public string model { get; set; } = "";
        [FirestoreProperty] public string dimensions { get; set; } = "";
        [FirestoreProperty] public DateTime timeAdded { get; set; }
        [FirestoreProperty] public object inventory { get; set; }
        [FirestoreProperty] public object R1 { get; set; }
        [FirestoreProperty] public object R2 { get; set; }
        [FirestoreProperty] public object R3 { get; set; }

        public Dictionary<string, Dictionary<string, object>> InventoryNormalized => NormalizeNestedDictionary(inventory);
        public Dictionary<string, Dictionary<string, object>> R1Normalized => NormalizeNestedDictionary(R1);
        public Dictionary<string, Dictionary<string, object>> R2Normalized => NormalizeNestedDictionary(R2);
        public Dictionary<string, Dictionary<string, object>> R3Normalized => NormalizeNestedDictionary(R3);

        private static readonly HashSet<string> AllowedColors = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "black","brown","white","red","orange","green","blue","purple","pink","gold","silver"
        };

        private static Dictionary<string, Dictionary<string, object>> NormalizeNestedDictionary(object raw)
        {
            var result = new Dictionary<string, Dictionary<string, object>>();
            if (raw == null) return result;

            if (raw is IDictionary outerDict)
            {
                bool isSingleLevel = outerDict.Values.Cast<object>().All(v => !(v is IDictionary));

                if (isSingleLevel)
                {
                    var colorDict = new Dictionary<string, object>();
                    foreach (DictionaryEntry kv in outerDict)
                    {
                        string color = kv.Key.ToString();
                        if (AllowedColors.Contains(color))
                            colorDict[color] = Convert.ToInt64(kv.Value);
                    }

                    result["default"] = colorDict;
                    return result;
                }

                foreach (DictionaryEntry kv in outerDict)
                {
                    string outerKey = kv.Key.ToString();
                    var colorDict = new Dictionary<string, object>();

                    if (kv.Value is IDictionary colorMap)
                    {
                        bool isColorLevel = colorMap.Values.Cast<object>().All(v => !(v is IDictionary));

                        if (isColorLevel)
                        {
                            foreach (DictionaryEntry colorKv in colorMap)
                            {
                                string color = colorKv.Key.ToString();
                                if (AllowedColors.Contains(color))
                                    colorDict[color] = Convert.ToInt64(colorKv.Value);
                            }
                        }
                        else
                        {
                            foreach (DictionaryEntry colorKv in colorMap)
                            {
                                string color = colorKv.Key.ToString();
                                if (AllowedColors.Contains(color) && colorKv.Value is IDictionary sizeMap)
                                {
                                    long sum = 0;
                                    foreach (DictionaryEntry sizeKv in sizeMap)
                                        sum += Convert.ToInt64(sizeKv.Value);
                                    colorDict[color] = sum;
                                }
                            }
                        }
                    }
                    result[outerKey] = colorDict;
                }
            }
            return result;
        }
    }

    [FirestoreData]
    public class Restock
    {
        [FirestoreDocumentId]
        public string restockId { get; set; }

        [FirestoreProperty] public string productId { get; set; }
        [FirestoreProperty] public int quantity { get; set; }

        [FirestoreProperty] public string storeId { get; set; } = "";
        [FirestoreProperty] public DateTime? requestTime { get; set; }
        [FirestoreProperty] public string requestedBy { get; set; } = "";
        [FirestoreProperty] public string status { get; set; } = "";
        [FirestoreProperty] public string reviewedBy { get; set; } = "";
        [FirestoreProperty] public string remarks { get; set; } = "";
    }

    [FirestoreData]
    public class Review
    {
        [FirestoreDocumentId]
        public string reviewId { get; set; }

        [FirestoreProperty] public string userId { get; set; }
        [FirestoreProperty] public string productId { get; set; }
        [FirestoreProperty] public string review { get; set; }
        [FirestoreProperty] public int rating { get; set; }
        [FirestoreProperty] public string media { get; set; }
        [FirestoreProperty] public DateTime dateTime { get; set; }
    }

    [FirestoreData]
    public class Order
    {
        [FirestoreDocumentId]
        public string orderId { get; set; }

        [FirestoreProperty] public string userId { get; set; } = "";
        [FirestoreProperty] public string email { get; set; } = "";
        [FirestoreProperty] public string phoneNo { get; set; } = "";
        [FirestoreProperty] public string address { get; set; } = "";

        [FirestoreProperty]
        public Dictionary<string, Dictionary<string, object>> items { get; set; } = new Dictionary<string, Dictionary<string, object>>();

        [FirestoreProperty]
        public Dictionary<string, Dictionary<string, object>> price { get; set; } = new Dictionary<string, Dictionary<string, object>>();
        [FirestoreProperty] public string paymentType { get; set; } = "";
        [FirestoreProperty] public double? discount { get; set; } = 0;
        [FirestoreProperty] public DateTime? orderTime { get; set; }
        [FirestoreProperty] public DateTime? arrivalTime { get; set; }
        [FirestoreProperty] public string trackingNo { get; set; } = "";
        [FirestoreProperty] public string status { get; set; } = "";
        [FirestoreProperty] public string deliveredFrom { get; set; } = "";
        [FirestoreProperty] public string refundReason { get; set; } = "";
        [FirestoreProperty] public string returnRefundTime { get; set; } = "";
        [FirestoreProperty] public string processedBy { get; set; } = "";
    }

    [FirestoreData]
    public class Saved
    {
        [FirestoreProperty] public string userId { get; set; }
        [FirestoreProperty] public string productId { get; set; }
        [FirestoreProperty] public DateTime addedOn { get; set; }
    }

    [FirestoreData]
    public class Cart
    {
        [FirestoreProperty] public string userId { get; set; }
        [FirestoreProperty] public string productId { get; set; }
        [FirestoreProperty] public int quantity { get; set; }
        [FirestoreProperty] public bool hasPrescription { get; set; }
        [FirestoreProperty] public string prescriptionDetails { get; set; }
        [FirestoreProperty] public DateTime addedOn { get; set; }
    }

    [FirestoreData]
    public class Retailer
    {
        [FirestoreDocumentId]
        public string storeId { get; set; }

        [FirestoreProperty] public string name { get; set; }
        [FirestoreProperty] public string address { get; set; }
        [FirestoreProperty] public double longitude { get; set; }
        [FirestoreProperty] public double latitude { get; set; }
        [FirestoreProperty] public string phoneNo { get; set; }
        [FirestoreProperty] public object openingHours { get; set; }

        public Dictionary<string, string> OpeningHoursNormalized => NormalizeOpeningHours(openingHours);

        private static Dictionary<string, string> NormalizeOpeningHours(object raw)
        {
            var result = new Dictionary<string, string>();
            if (raw == null) return result;

            if (raw is IDictionary dict)
            {
                foreach (DictionaryEntry kv in dict)
                {
                    result[kv.Key.ToString()] = kv.Value?.ToString() ?? "";
                }
            }

            return result;
        }
    }

    [FirestoreData]
    public class Appointment
    {
        [FirestoreDocumentId]
        public string appointmentId { get; set; }

        [FirestoreProperty] public string storeId { get; set; } = "";
        [FirestoreProperty] public string userId { get; set; } = "";
        [FirestoreProperty] public string email { get; set; } = "";
        [FirestoreProperty] public string name { get; set; } = "";
        [FirestoreProperty] public string phoneNo { get; set; } = "";
        [FirestoreProperty] public string details { get; set; } = "";
        [FirestoreProperty] public Dictionary<string, object> prescription { get; set; } = new Dictionary<string, object>();
        [FirestoreProperty] public string type { get; set; } = "";
        [FirestoreProperty] public DateTime? dateTime { get; set; }
        [FirestoreProperty] public string remarks { get; set; } = "";
        [FirestoreProperty] public Dictionary<string, object> holdItem { get; set; } = new Dictionary<string, object>();
        [FirestoreProperty] public string status { get; set; } = "";
        [FirestoreProperty] public string staffId { get; set; } = "";
        [FirestoreProperty] public string cancelReason { get; set; } = "";
    }
}
