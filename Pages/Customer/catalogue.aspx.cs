using Google.Cloud.Firestore;
using Opton.Pages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using Newtonsoft.Json;

namespace Opton.Pages.Customer
{
    public partial class catalogue : System.Web.UI.Page
    {
        // ViewState properties for maintaining state
        private string SearchTerm
        {
            get { return ViewState["SearchTerm"] as string ?? ""; }
            set { ViewState["SearchTerm"] = value; }
        }

        private string SortBy
        {
            get { return ViewState["SortBy"] as string ?? ""; }
            set { ViewState["SortBy"] = value; }
        }

        private string SortOrder
        {
            get { return ViewState["SortOrder"] as string ?? "asc"; }
            set { ViewState["SortOrder"] = value; }
        }

        protected async void Page_Load(object sender, EventArgs e)
        {
            Debug.WriteLine("[Catalogue] ========== Page_Load START ==========");
            Debug.WriteLine($"[Catalogue] IsPostBack: {IsPostBack}");

            if (!IsPostBack)
            {
                Debug.WriteLine("[Catalogue] First page load");
                
                // Load filters first
                await LoadAndRenderFiltersAsync();
                
                // Load ALL products for client-side filtering
                await LoadAllProductsForClient();
            }

            Debug.WriteLine("[Catalogue] ========== Page_Load END ==========");
        }

        private async Task LoadAllProductsForClient()
        {
            Debug.WriteLine($"[Catalogue] LoadAllProductsForClient - Loading ALL products");

            var products = await GetAllProductsAsync();

            if (products == null || products.Count == 0)
            {
                productTableBody.InnerHtml = @"
                    <tr>
                        <td colspan='3' style='text-align: center; padding: 40px;'>
                            <h3 style='color: #999;'>No products found</h3>
                        </td>
                    </tr>";
                pagerContainer.Text = "";
            }
            else
            {
                // Apply sorting if specified
                if (!string.IsNullOrEmpty(SortBy))
                {
                    products = ApplySorting(products, SortBy, SortOrder);
                }

                RenderAllProducts(products);
            }

            Debug.WriteLine($"[Catalogue] Loaded {products?.Count ?? 0} total products");
        }

        private List<Product> ApplySorting(List<Product> products, string sortBy, string sortOrder)
        {
            Debug.WriteLine($"[Catalogue] ApplySorting - SortBy: {sortBy}, Order: {sortOrder}");

            switch (sortBy.ToLower())
            {
                case "price":
                    products = sortOrder == "asc" 
                        ? products.OrderBy(p => p.price).ToList()
                        : products.OrderByDescending(p => p.price).ToList();
                    break;

                case "name":
                    products = sortOrder == "asc"
                        ? products.OrderBy(p => p.name ?? "").ToList()
                        : products.OrderByDescending(p => p.name ?? "").ToList();
                    break;

                case "time added":
                    products = sortOrder == "asc"
                        ? products.OrderBy(p => p.timeAdded).ToList()
                        : products.OrderByDescending(p => p.timeAdded).ToList();
                    break;

                case "popularity":
                    // Add popularity logic if you have a field for it
                    products = sortOrder == "asc"
                        ? products.OrderBy(p => p.name ?? "").ToList()
                        : products.OrderByDescending(p => p.name ?? "").ToList();
                    break;
            }

            return products;
        }

        private void RenderAllProducts(List<Product> products)
        {
            productTableBody.Controls.Clear();
            productTableBody.InnerHtml = "";

            // Render all products hidden initially - JavaScript will handle display
            foreach (var product in products)
            {
                string productHtml = RenderProductItem(product);
                if (!string.IsNullOrEmpty(productHtml))
                {
                    productTableBody.InnerHtml += productHtml;
                }
            }

            // JavaScript will handle pagination client-side
            pagerContainer.Text = "<div id='pagerContainer'></div>";
        }

        private async Task<List<Product>> GetAllProductsAsync()
        {
            try
            {
                FirestoreDb db = SiteMaster.FirestoreDbInstance;
                CollectionReference productsRef = db.Collection("Products");

                QuerySnapshot snapshot = await productsRef.GetSnapshotAsync();

                List<Product> products = new List<Product>();
                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    if (doc.Exists)
                    {
                        Product product = doc.ConvertTo<Product>();
                        product.productId = doc.Id;
                        products.Add(product);
                    }
                }

                Debug.WriteLine($"[Catalogue] Retrieved {products.Count} products from Firestore");
                return products;
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[Catalogue] Error fetching all products: {ex}");
                return new List<Product>();
            }
        }

        private async Task LoadAndRenderFiltersAsync()
        {
            try
            {
                FirestoreDb db = SiteMaster.FirestoreDbInstance;
                QuerySnapshot snapshot = await db.Collection("Products").GetSnapshotAsync();

                var categories = new HashSet<string>();
                var shapes = new HashSet<string>();
                var colors = new HashSet<string>();
                var materials = new HashSet<string>();

                foreach (DocumentSnapshot doc in snapshot.Documents)
                {
                    if (doc.Exists)
                    {
                        // Category
                        if (doc.ContainsField("category"))
                        {
                            string category = doc.GetValue<string>("category");
                            if (!string.IsNullOrEmpty(category))
                                categories.Add(category);
                        }

                        // Shape
                        if (doc.ContainsField("shape"))
                        {
                            string shape = doc.GetValue<string>("shape");
                            if (!string.IsNullOrEmpty(shape))
                                shapes.Add(shape);
                        }

                        // Material
                        if (doc.ContainsField("material"))
                        {
                            string material = doc.GetValue<string>("material");
                            if (!string.IsNullOrEmpty(material))
                            {
                                foreach (var mat in material.Split(','))
                                {
                                    var trimmed = mat.Trim();
                                    if (!string.IsNullOrEmpty(trimmed))
                                        materials.Add(trimmed);
                                }
                            }
                        }

                        // Colors from inventory
                        var inventories = new[] { "inventory", "R1", "R2", "R3" };
                        foreach (var invField in inventories)
                        {
                            if (doc.ContainsField(invField))
                            {
                                var invData = doc.GetValue<Dictionary<string, object>>(invField);
                                if (invData != null)
                                {
                                    // Check if it's a flat structure (color: quantity)
                                    bool isFlatStructure = invData.Values.All(v => !(v is Dictionary<string, object>));

                                    if (isFlatStructure)
                                    {
                                        // Format: {"black":200,"white":183,"brown":90}
                                        foreach (var colorKey in invData.Keys)
                                        {
                                            colors.Add(colorKey);
                                        }
                                    }
                                    else
                                    {
                                        // Format: {"Adults":{"black":8}} or {"Adults":{"black":{"S":5}}}
                                        foreach (var ageGroup in invData.Values)
                                        {
                                            if (ageGroup is Dictionary<string, object> colorDict)
                                            {
                                                foreach (var colorKey in colorDict.Keys)
                                                {
                                                    colors.Add(colorKey);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Debug.WriteLine($"[Catalogue] Loaded filters - Categories: {categories.Count}, Shapes: {shapes.Count}, Colors: {colors.Count}, Materials: {materials.Count}");

                // Render filters in the page
                RenderFilterCheckboxes("categoryFilters", categories, "category");
                RenderFilterCheckboxes("shapeFilters", shapes, "shape");
                RenderFilterCheckboxes("colorFilters", colors, "color");
                RenderFilterCheckboxes("materialFilters", materials, "material");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[Catalogue] Error loading filters: {ex.Message}");
            }
        }

        private void RenderFilterCheckboxes(string containerId, HashSet<string> values, string filterType)
        {
            System.Web.UI.HtmlControls.HtmlGenericControl container = null;

            switch (containerId)
            {
                case "categoryFilters":
                    container = categoryFilters;
                    break;
                case "shapeFilters":
                    container = shapeFilters;
                    break;
                case "colorFilters":
                    container = colorFilters;
                    break;
                case "materialFilters":
                    container = materialFilters;
                    break;
            }

            if (container == null)
            {
                Debug.WriteLine($"[Catalogue] Warning: Container '{containerId}' not found");
                return;
            }

            container.InnerHtml = "";

            // Add "All" option first
            container.InnerHtml += $@"
        <label style='display: block; margin-bottom: 5px; cursor: pointer; font-weight: 600;'>
            <input type='checkbox' 
                   id='{filterType}_all' 
                   class='filter-checkbox' 
                   data-filter-type='{filterType}' 
                   data-filter-value='all' 
                   checked />
            All
        </label>
        <hr style='margin: 5px 0;' />";

            if (values == null || values.Count == 0)
            {
                container.InnerHtml += "<span style='color: #ddd; font-style: italic;'>No options available</span>";
                return;
            }

            foreach (var value in values.OrderBy(v => v))
            {
                string checkboxId = $"{filterType}_{value.Replace(" ", "_").Replace(",", "")}";
                string displayValue = System.Globalization.CultureInfo.CurrentCulture.TextInfo.ToTitleCase(value.ToLower());

                container.InnerHtml += $@"
            <label style='display: block; margin-bottom: 5px; cursor: pointer;'>
                <input type='checkbox' 
                       id='{checkboxId}' 
                       class='filter-checkbox' 
                       data-filter-type='{filterType}' 
                       data-filter-value='{value.ToLower()}' 
                       disabled />
                {displayValue}
            </label>";
            }

            Debug.WriteLine($"[Catalogue] Rendered {values.Count} options + 'All' for {containerId}");
        }

        private string RenderProductItem(Product product)
        {
            string productId = product.productId ?? "";
            Dictionary<string, string> colorModelUrls = new Dictionary<string, string>();
            Dictionary<string, string> colorImageUrls = new Dictionary<string, string>();
            bool hasGlb = false;
            bool hasMultipleGlbs = false;
            string availableColors = "";
            string availableAgeGroups = "";
            string firstColor = "black";
            string defaultModelUrl = "";
            string defaultImageUrl = "";

            var sources = new Dictionary<string, Dictionary<string, Dictionary<string, object>>>()
{
    { "inventory", product.InventoryNormalized },
    { "R1", product.R1Normalized },
    { "R2", product.R2Normalized },
    { "R3", product.R3Normalized }
};

            var allColors = new HashSet<string>();
            var allAgeGroups = new HashSet<string>();

            // Extract colors and age groups
            foreach (var sourcePair in sources)
            {
                var sourceDict = sourcePair.Value;
                if (sourceDict != null && sourceDict.Count > 0)
                {
                    foreach (var ageGroupPair in sourceDict)
                    {
                        string ageGroup = ageGroupPair.Key;

                        // Only add to age groups if it's not "default" (which means flat structure)
                        if (ageGroup != "default")
                        {
                            allAgeGroups.Add(ageGroup);
                        }

                        var colorDict = ageGroupPair.Value;
                        if (colorDict != null)
                        {
                            foreach (var colorPair in colorDict)
                            {
                                allColors.Add(colorPair.Key);
                            }
                        }
                    }
                }
            }

            if (allColors.Count > 0)
            {
                firstColor = allColors.First();
                availableColors = string.Join(",", allColors);
            }

            if (allAgeGroups.Count > 0)
            {
                availableAgeGroups = string.Join(",", allAgeGroups);
            }

            // Process model/image files
            if (!string.IsNullOrEmpty(productId) && !string.IsNullOrEmpty(product.model))
            {
                string[] files = product.model.Split(new string[] { ", " }, StringSplitOptions.RemoveEmptyEntries);
                string[] glbFiles = Array.FindAll(files, f => f.EndsWith(".glb", StringComparison.OrdinalIgnoreCase));

                if (glbFiles.Length > 0)
                {
                    hasGlb = true;

                    if (glbFiles.Length > 1)
                    {
                        hasMultipleGlbs = true;

                        foreach (var glbFile in glbFiles)
                        {
                            string fileName = System.IO.Path.GetFileNameWithoutExtension(glbFile).ToLower();
                            string path = $"Products/{productId}/{glbFile}";
                            string glbUrl = $"https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/{Uri.EscapeDataString(path)}?alt=media";

                            bool colorFound = false;
                            foreach (var color in allColors)
                            {
                                if (fileName.Contains(color.ToLower()))
                                {
                                    colorModelUrls[color] = glbUrl;
                                    colorFound = true;
                                    break;
                                }
                            }

                            if (!colorFound && string.IsNullOrEmpty(defaultModelUrl))
                            {
                                defaultModelUrl = glbUrl;
                            }
                        }

                        if (!string.IsNullOrEmpty(defaultModelUrl) && colorModelUrls.Count == 0)
                        {
                            hasMultipleGlbs = false;
                        }
                    }
                    else
                    {
                        string path = $"Products/{productId}/{glbFiles[0]}";
                        defaultModelUrl = $"https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/{Uri.EscapeDataString(path)}?alt=media";
                    }
                }
                else
                {
                    string[] imageFiles = Array.FindAll(files, f =>
                        f.EndsWith(".png", StringComparison.OrdinalIgnoreCase) ||
                        f.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase) ||
                        f.EndsWith(".jpeg", StringComparison.OrdinalIgnoreCase)
                    );

                    if (imageFiles.Length > 0)
                    {
                        foreach (var imageFile in imageFiles)
                        {
                            string fileName = System.IO.Path.GetFileNameWithoutExtension(imageFile).ToLower();
                            string path = $"Products/{productId}/{imageFile}";
                            string imageUrl = $"https://firebasestorage.googleapis.com/v0/b/opton-e4a46.firebasestorage.app/o/{Uri.EscapeDataString(path)}?alt=media";

                            bool colorFound = false;
                            foreach (var color in allColors)
                            {
                                if (fileName.Contains(color.ToLower()))
                                {
                                    colorImageUrls[color] = imageUrl;
                                    colorFound = true;
                                    break;
                                }
                            }

                            if (!colorFound && string.IsNullOrEmpty(defaultImageUrl))
                            {
                                defaultImageUrl = imageUrl;
                            }
                        }

                        if (string.IsNullOrEmpty(defaultImageUrl) && colorImageUrls.Count > 0)
                        {
                            defaultImageUrl = colorImageUrls[firstColor];
                        }
                        else if (!string.IsNullOrEmpty(defaultImageUrl) && colorImageUrls.Count == 0)
                        {
                            foreach (var color in allColors)
                            {
                                colorImageUrls[color] = defaultImageUrl;
                            }
                        }
                    }
                }
            }

            bool shouldHide = string.IsNullOrEmpty(product.name) ||
                              (product.price <= 0 && string.IsNullOrEmpty(defaultModelUrl) &&
                               colorModelUrls.Count == 0 && colorImageUrls.Count == 0 && string.IsNullOrEmpty(defaultImageUrl));

            if (shouldHide)
            {
                return "";
            }

            // Generate Media HTML
            string mediaHtml = "";
            string hoverScript = "";

            if (hasGlb)
            {
                string initialModelUrl = !string.IsNullOrEmpty(defaultModelUrl) ? defaultModelUrl :
                                         (colorModelUrls.ContainsKey(firstColor) ? colorModelUrls[firstColor] : colorModelUrls.Values.First());

                string colorSwatchesHtml = "";
                string colorDataJson = "{}";

                if (!string.IsNullOrEmpty(availableColors))
                {
                    var colors = availableColors.Split(',');
                    bool isFirst = true;
                    var colorDataDict = new List<string>();

                    foreach (var color in colors)
                    {
                        string swatchId = $"color-{productId}-{color}";
                        string activeClass = isFirst ? " active" : "";

                        if (hasMultipleGlbs && colorModelUrls.Count > 0)
                        {
                            colorSwatchesHtml += $"<div id='{swatchId}' class='color-swatch{activeClass}' style='background-color: {color};' data-color='{color}' onclick='changeGlbModel(this, event)'></div>";

                            string modelUrl = colorModelUrls.ContainsKey(color) ? colorModelUrls[color] : defaultModelUrl;
                            colorDataDict.Add($"\"{color}\": \"{modelUrl.Replace("\"", "\\\"")}\"");
                        }
                        else
                        {
                            colorSwatchesHtml += $"<div id='{swatchId}' class='color-swatch{activeClass}' style='background-color: {color};' data-color='{color}' onclick='changeModelColor(this, event)'></div>";
                        }

                        isFirst = false;
                    }

                    if (hasMultipleGlbs && colorModelUrls.Count > 0)
                    {
                        colorDataJson = "{" + string.Join(", ", colorDataDict) + "}";
                    }
                }

                string tagBadgeHtml = !string.IsNullOrEmpty(product.tags)
                    ? $"<div class='product-tag'>{product.tags}</div>"
                    : "";

                string modelViewerId = $"model-{productId}";
                string dataAttribute = hasMultipleGlbs && colorModelUrls.Count > 0 ? $"data-color-models='{colorDataJson}'" : $"data-first-color='{firstColor}' data-colors='{availableColors}'";

                mediaHtml = $@"
            <div class='model-container' {dataAttribute}>
                {tagBadgeHtml}
                <div class='hover-actions'>
                    <i class='ri-heart-line action-icon' onclick='likeProduct(event, ""{productId}"")'></i>
                    <i class='ri-shopping-cart-2-line action-icon cart-icon' onclick='addToCart(event, ""{productId}"")'></i>
                    <span class='cart-badge' style='display:none; position:absolute; top:-5px; right:-5px; background:red; color:white; border-radius:50%; width:20px; height:20px; font-size:12px; text-align:center; line-height:20px;'>0</span>
                </div>
                <model-viewer 
                    id='{modelViewerId}'
                    src='{initialModelUrl}'
                    alt='{(product.name ?? "").Replace("'", "&apos;")}'
                    camera-orbit='0deg 75deg auto'
                    disable-pan
                    disable-zoom
                    interaction-prompt='none'
                    loading='eager'
                    reveal='auto'
                    exposure='1'
                    shadow-intensity='1'
                    style='width: 100%; height: 200px; display: block;'
                    {(hasMultipleGlbs && colorModelUrls.Count > 0 ? "" : $"onload='initializeModel(this, \"{firstColor}\")'")}>
                </model-viewer>
                <div class='color-swatches'>{colorSwatchesHtml}</div>
            </div>";

                hoverScript = $@"onmouseover=""var mv = document.getElementById('{modelViewerId}'); if(mv) mv.cameraOrbit='-45deg 75deg auto'; var tag = this.querySelector('.product-tag'); if(tag) tag.classList.add('hidden'); var actions = this.querySelector('.hover-actions'); if(actions) actions.classList.add('visible');""
            onmouseout=""var mv = document.getElementById('{modelViewerId}'); if(mv) mv.cameraOrbit='0deg 75deg auto'; var tag = this.querySelector('.product-tag'); if(tag) tag.classList.remove('hidden'); var actions = this.querySelector('.hover-actions'); if(actions) actions.classList.remove('visible');""";
            }
            else if (colorImageUrls.Count > 0 || !string.IsNullOrEmpty(defaultImageUrl))
            {
                string initialImageUrl = !string.IsNullOrEmpty(defaultImageUrl) ? defaultImageUrl :
                                         (colorImageUrls.ContainsKey(firstColor) ? colorImageUrls[firstColor] : colorImageUrls.Values.First());

                string colorSwatchesHtml = "";
                string colorDataJson = "{}";

                if (colorImageUrls.Count > 0)
                {
                    var colors = availableColors.Split(',');
                    bool isFirst = true;
                    var colorDataDict = new List<string>();

                    foreach (var color in colors)
                    {
                        string swatchId = $"color-{productId}-{color}";
                        string activeClass = isFirst ? " active" : "";
                        colorSwatchesHtml += $"<div id='{swatchId}' class='color-swatch{activeClass}' style='background-color: {color};' data-color='{color}' onclick='changeImageColor(this, event)'></div>";

                        string imageUrl = colorImageUrls.ContainsKey(color) ? colorImageUrls[color] : defaultImageUrl;
                        colorDataDict.Add($"\"{color}\": \"{imageUrl.Replace("\"", "\\\"")}\"");

                        isFirst = false;
                    }

                    colorDataJson = "{" + string.Join(", ", colorDataDict) + "}";
                }

                string tagBadgeHtml = !string.IsNullOrEmpty(product.tags)
                    ? $"<div class='product-tag'>{product.tags}</div>"
                    : "";

                string imageId = $"img-{productId}";

                mediaHtml = $@"
            <div class='model-container' data-color-images='{colorDataJson}'>
                {tagBadgeHtml}
                <div class='hover-actions'>
                    <i class='ri-heart-line action-icon' onclick='likeProduct(event, ""{productId}"")'></i>
                    <i class='ri-shopping-cart-2-line action-icon cart-icon' onclick='addToCart(event, ""{productId}"")'></i>
                    <span class='cart-badge' style='display:none;'>0</span>
                </div>
                <img id='{imageId}'
                     src='{initialImageUrl}' 
                     alt='{(product.name ?? "").Replace("'", "&apos;")}' 
                     style='width: 80%; height: 80%; object-fit: contain;' />
                <div class='color-swatches'>{colorSwatchesHtml}</div>
            </div>";

                hoverScript = @"onmouseover=""var tag = this.querySelector('.product-tag'); if(tag) tag.classList.add('hidden'); var actions = this.querySelector('.hover-actions'); if(actions) actions.classList.add('visible');""
            onmouseout=""var tag = this.querySelector('.product-tag'); if(tag) tag.classList.remove('hidden'); var actions = this.querySelector('.hover-actions'); if(actions) actions.classList.remove('visible');""";
            }
            else
            {
                mediaHtml = "<div style='width: 100%; height: 200px; display: flex; align-items: center; justify-content: center; color: #999;'>No image available</div>";
            }

            string priceText = product.price > 0 ? $"RM{product.price:0.00}" : "Contact for Price";
            string productName = product.name ?? "Unnamed Product";
            string category = product.category ?? "";
            string shape = product.shape ?? "";
            string material = product.material ?? "";
            DateTime timeAddedDt = product.timeAdded != default(DateTime)
                ? product.timeAdded
                : DateTime.Now;
            string timeAdded = timeAddedDt.ToString("yyyy-MM-dd");

            // Return product HTML as a standalone div (not wrapped in table structure)
            return $@"
    <div class='product-item' 
         data-product-id='{productId}'
         data-product-name='{productName.ToLower()}'
         data-product-price='{product.price}'
         data-product-category='{category.ToLower()}'
         data-product-age='{availableAgeGroups.ToLower()}'
         data-product-shape='{shape.ToLower()}'
         data-product-colors='{availableColors.ToLower()}'
         data-product-material='{material.ToLower()}'
         data-product-date='{timeAdded}'
         style='cursor: pointer; display: none;'
         {hoverScript}
         onclick=""if(!event.target.closest('.color-swatch, .action-icon, .color-swatches, .hover-actions')) location.href='product.aspx?id={productId}';"">
        <div class='product-image'>
            {mediaHtml}
        </div>
        <div class='product-info'>
            <div class='product-price'>{priceText}</div>
            <div class='product-name'>{productName}</div>
        </div>
    </div>";
        }
    }
}