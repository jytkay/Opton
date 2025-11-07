<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Opton._Default" %>

<asp:Content ID="HeaderContent" ContentPlaceHolderID="HeaderContent" runat="server">
    <style>
        :root {
            --color-dark: #2C3639;
            --color-gray: #3F4E4F;
            --color-accent: #A27B5C;
            --color-light: #DCD7C9;
            --color-background: #f5f5f5;
        }

        /* Start Section */
        .start-section {
            position: relative;
            height: 600px;
            background: linear-gradient(135deg, var(--color-gray) 0%, var(--color-dark) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            overflow: hidden;
            margin-bottom: 60px;
        }

        .start-background {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.3;
        }

        .start-content {
            position: relative;
            z-index: 2;
            text-align: center;
            max-width: 800px;
            padding: 40px;
        }

        .start-title {
            font-size: 4em;
            font-weight: bold;
            margin-bottom: 20px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }

        .start-subtitle {
            font-size: 1.5em;
            margin-bottom: 30px;
            color: var(--color-light);
        }

        .start-cta {
            display: inline-block;
            padding: 15px 40px;
            background-color: var(--color-accent);
            color: white;
            text-decoration: none;
            border-radius: 30px;
            font-size: 1.2em;
            font-weight: bold;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(162, 123, 92, 0.4);
        }

            .start-cta:hover {
                background-color: var(--color-light);
                color: var(--color-dark);
                transform: translateY(-3px);
                box-shadow: 0 6px 20px rgba(162, 123, 92, 0.6);
                text-decoration: none;
            }

        /* Features Section */
        .features-section {
            padding: 60px 0;
            background-color: white;
        }

        .section-title {
            text-align: center;
            font-size: 2.5em;
            color: var(--color-dark);
            margin-bottom: 50px;
            font-weight: bold;
        }

        .features-grid {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 40px;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .feature-card {
            background: var(--color-background);
            border-radius: 15px;
            padding: 40px 30px;
            text-align: center;
            transition: all 0.3s ease;
            border-top: 4px solid var(--color-accent);
            flex: 0 1 280px;
        }

            .feature-card:hover {
                transform: translateY(-10px);
                box-shadow: 0 10px 30px rgba(44, 54, 57, 0.15);
            }

        .feature-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            background-color: var(--color-accent);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .feature-icon i {
                font-size: 2.5em;
                color: white;
            }

        .feature-title {
            font-size: 1.5em;
            color: var(--color-gray);
            margin-bottom: 15px;
            font-weight: bold;
        }

        .feature-description {
            color: var(--color-dark);
            line-height: 1.6;
        }

       /* History Banner Section */
        .history-section {
            padding: 80px 20px;
            position: relative;
            overflow: hidden;
            min-height: 500px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .history-background {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            filter: brightness(0.4);
        }

        .history-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(44, 54, 57, 0.85) 0%, rgba(63, 78, 79, 0.85) 100%);
        }

        .history-content {
            max-width: 900px;
            margin: 0 auto;
            text-align: center;
            position: relative;
            z-index: 2;
            color: white;
        }

        .history-year {
            font-size: 5em;
            font-weight: bold;
            color: var(--color-accent);
            margin-bottom: 20px;
            line-height: 1;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }

        .history-title {
            font-size: 2.5em;
            color: white;
            margin-bottom: 30px;
            font-weight: bold;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }

        .history-text {
            font-size: 1.2em;
            color: var(--color-light);
            line-height: 1.8;
            margin-bottom: 20px;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.5);
        }

        .history-divider {
            width: 100px;
            height: 4px;
            background-color: var(--color-accent);
            margin: 30px auto;
            border-radius: 2px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }

        /* Why Choose Us Section */
        .why-us-section {
            padding: 60px 0;
            background-color: var(--color-gray);
            color: white;
        }

        .why-us-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 40px;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .why-us-item {
            text-align: center;
        }

        .why-us-icon {
            font-size: 3em;
            color: var(--color-accent);
            margin-bottom: 20px;
        }

        .why-us-title {
            font-size: 1.3em;
            margin-bottom: 10px;
            font-weight: bold;
        }

        .why-us-description {
            color: var(--color-light);
            line-height: 1.6;
        }

        /* CTA Section */
        .cta-section {
            padding: 80px 20px;
            background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-gray) 100%);
            text-align: center;
            color: white;
        }

        .cta-title {
            font-size: 2.5em;
            margin-bottom: 20px;
            font-weight: bold;
        }

        .cta-subtitle {
            font-size: 1.2em;
            margin-bottom: 30px;
            color: var(--color-light);
        }

        .cta-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .cta-button {
            padding: 15px 35px;
            border-radius: 30px;
            text-decoration: none;
            font-size: 1.1em;
            font-weight: bold;
            transition: all 0.3s ease;
        }

        .cta-button-primary {
            background-color: white;
            color: var(--color-dark);
        }

            .cta-button-primary:hover {
                background-color: var(--color-light);
                transform: translateY(-3px);
                box-shadow: 0 6px 20px rgba(0,0,0,0.2);
                text-decoration: none;
            }

        .cta-button-secondary {
            background-color: transparent;
            color: white;
            border: 2px solid white;
        }

            .cta-button-secondary:hover {
                background-color: white;
                color: var(--color-dark);
                text-decoration: none;
            }

        /* Responsive Design */
        @media (max-width: 768px) {
            .start-title {
                font-size: 2.5em;
            }

            .start-subtitle {
                font-size: 1.2em;
            }

            .section-title {
                font-size: 2em;
            }

            .collection-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Start Section -->
    <section class="start-section">
        <img src="/Assets/landing-bg.jpg" alt="Opton Eyewear" class="start-background" />
        <div class="start-content">
            <h1 class="start-title">See Clearly, Look Great</h1>
            <p class="start-subtitle">Discover premium eyewear that combines style, comfort, and precision</p>
            <a href="/Pages/Customer/catalogue.aspx" class="start-cta">Shop Our Collection</a>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features-section">
        <h2 class="section-title">Why Opton?</h2>
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="ri-eye-line"></i>
                </div>
                <h3 class="feature-title">Premium Quality</h3>
                <p class="feature-description">Carefully curated eyewear made from the finest materials for lasting durability and comfort.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="ri-palette-line"></i>
                </div>
                <h3 class="feature-title">Stylish Designs</h3>
                <p class="feature-description">From classic to contemporary, find frames that perfectly match your personality and style.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="ri-shield-check-line"></i>
                </div>
                <h3 class="feature-title">Expert Service</h3>
                <p class="feature-description">Professional eye care and personalized fitting services to ensure your perfect pair.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="ri-price-tag-3-line"></i>
                </div>
                <h3 class="feature-title">Great Value</h3>
                <p class="feature-description">Competitive pricing without compromising on quality. Premium eyewear that fits your budget.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="ri-camera-line"></i>
                </div>
                <h3 class="feature-title">Virtual Try-On</h3>
                <p class="feature-description">Preview how frames look before you buy with Opton’s built-in try-on feature for a confident choice every time.</p>
            </div>
        </div>
    </section>

    <!-- History Banner -->
    <section class="history-section">
        <img src="/Assets/history-bg.jpg" alt="Opton History" class="history-background" />
        <div class="history-overlay"></div>
        <div class="history-content">
            <div class="history-year">EST. 2025</div>
            <h2 class="history-title">Our Story</h2>
            <div class="history-divider"></div>
            <p class="history-text">
                Since 2025, Opton has been dedicated to providing exceptional eyewear solutions that blend cutting-edge technology with timeless style. What started as a vision to revolutionize the eyewear industry has grown into a trusted name for quality, innovation, and customer satisfaction.
            </p>
            <p class="history-text">
                We believe that everyone deserves access to premium eyewear that not only enhances vision but also reflects personal style. Our commitment to excellence drives us to continuously curate the finest collections and provide unparalleled service to our valued customers.
            </p>
        </div>
    </section>

    <!-- Why Choose Us -->
    <section class="why-us-section">
        <h2 class="section-title">The Opton Difference</h2>
        <div class="why-us-grid">
            <div class="why-us-item">
                <i class="ri-user-smile-line why-us-icon"></i>
                <h3 class="why-us-title">Personalized Fitting</h3>
                <p class="why-us-description">Discover frames that reflect your individuality and elevate your everyday style.</p>
            </div>
            <div class="why-us-item">
                <i class="ri-truck-line why-us-icon"></i>
                <h3 class="why-us-title">Fast Delivery</h3>
                <p class="why-us-description">Quick processing and delivery straight to your door with secure packaging.</p>
            </div>
            <div class="why-us-item">
                <i class="ri-refresh-line why-us-icon"></i>
                <h3 class="why-us-title">Easy Returns</h3>
                <p class="why-us-description">Not satisfied? Hassle-free returns within 30 days for your peace of mind.</p>
            </div>
            <div class="why-us-item">
                <i class="ri-calendar-check-line why-us-icon"></i>
                <h3 class="why-us-title">Book Appointments</h3>
                <p class="why-us-description">Schedule eye tests and fittings at our retail locations at your convenience.</p>
            </div>
        </div>
    </section>

    <!-- Call to Action -->
    <section class="cta-section">
        <h2 class="cta-title">Ready to Find Your Perfect Pair?</h2>
        <p class="cta-subtitle">Browse our collection or visit one of our retail locations</p>
        <div class="cta-buttons">
            <a href="/Pages/Customer/catalogue.aspx" class="cta-button cta-button-primary">Shop Now</a>
            <a href="/Pages/Customer/find_retailers.aspx" class="cta-button cta-button-secondary">Find a Store</a>
        </div>
    </section>
</asp:Content>
