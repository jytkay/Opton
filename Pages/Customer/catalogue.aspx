<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="catalogue.aspx.cs" Inherits="Opton.Pages.Customer.catalogue" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Catalogue</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />

    <style>
        /* Header bar */
        .header-bar {
            height: 55px;
            background-color: #2C3639;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 20px;
        }

        .header-bar .logo img {
            height: 40px;
        }

        .header-bar .nav-icons {
            display: flex;
            gap: 20px;
        }

        .header-bar .nav-icons a {
            color: #ffffff;
            font-size: 20px;
            text-decoration: none;
            position: relative;
        }

        .header-bar .nav-icons a::after {
            content: attr(data-tooltip);
            position: absolute;
            bottom: -25px;
            left: 50%;
            transform: translateX(-50%);
            background: #000000cc;
            color: #fff;
            font-size: 12px;
            padding: 3px 6px;
            border-radius: 4px;
            opacity: 0;
            white-space: nowrap;
            pointer-events: none;
            transition: opacity 0.2s;
        }

        .header-bar .nav-icons a:hover::after {
            opacity: 1;
        }

       /* Banner section */
        .banner {
            width: 100%;
            background-color: #3F4E4F;
            overflow: hidden;
        }

        .banner img {
            width: 100%;
            height: auto;
            display: block;
        }

    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Header -->
        <div class="header-bar">
            <div class="logo">
                <img src="<%= ResolveUrl("~/Assets/logo.png") %>" alt="Logo" />
            </div>
            <div class="nav-icons">
                <a href="OrderTracking.aspx" data-tooltip="Order Tracking">
                    <i class="fa-solid fa-truck-fast"></i>
                </a>
                <a href="Favourites.aspx" data-tooltip="Favourites / Cart" style="position:relative;">
                    <i class="fa-solid fa-cart-shopping"></i>
                    <i class="fa-solid fa-heart" style="font-size:12px;position:absolute;top:-5px;right:-10px;color:red;"></i>
                </a>
                <a href="Retailers.aspx" data-tooltip="Retailers">
                    <i class="fa-solid fa-location-dot"></i>
                </a>
                <a href="Login.aspx" data-tooltip="Login">
                    <i class="fa-solid fa-user"></i>
                </a>
            </div>
        </div>

        <!-- Banner -->
        <div class="banner">
            <img src="<%= ResolveUrl("~/Assets/banner.png") %>"/>
        </div>
    </form>
</body>
</html>
