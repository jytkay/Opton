<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="login.aspx.cs" Inherits="Opton.Pages.login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login</title>
    <style>
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            font-family: Arial, sans-serif;
            background: url('<%= ResolveUrl("~/Assets/login-bg.jpg") %>') no-repeat center center fixed;
            background-size: cover;
        }

        .login-container {
            display: flex;
            height: 100vh;
        }

        /* Left panel with semi-transparent background */
        .login-left {
            width: 644px;
            background-color: rgba(44, 54, 57, 0.9);
            display: flex;
            justify-content: center; /* horizontal centering */
            align-items: center;     /* vertical centering */
        }

        .login-left a {
            display: flex;           /* make the link a flex container */
            justify-content: center;
            align-items: center;
            width: 100%;             /* fill the parent div */
        }

        .login-left img {
            width: 90%;
            height: auto;
            display: block;          /* remove default inline spacing */
            margin: 0 auto;          /* center in case flex not applied */
        }

        /* Right panel transparent, content centered */
        .login-right {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-form {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .login-form input[type="text"],
        .login-form input[type="password"] {
            width: 562px;
            height: 55px;
            border-radius: 30px;
            border: none;
            padding: 0 20px;
            margin-bottom: 30px;
            background-color: #DCD7C9;
            font-size: 16px;
            text-align: center;
        }

        .login-form input::placeholder {
            color: #888888;
            text-align: center;
        }

        .login-form button {
            width: 307px;
            height: 55px;
            border-radius: 30px;
            border: none;
            background-color: #A27B5C;
            color: white;
            font-size: 18px;
            cursor: pointer;
            margin: 50px 0 20px 0;
        }

        .login-form button:hover {
            background-color: #8B6644;
        }

        .login-form a {
            color: #A27B5C;
            font-style: italic;
            text-decoration: none;
        }

        .login-form a:hover {
            text-decoration: underline;
        }

        @media (max-width: 1200px) {
            .login-container {
                flex-direction: column;
            }
            .login-left, .login-right {
                width: 100%;
                height: 50vh;
            }
            .login-form input[type="text"],
            .login-form input[type="password"] {
                width: 80%;
            }
            .login-form button {
                width: 50%;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-container">
            <!-- Left panel with logo -->
            <div class="login-left">
                <a href="<%: ResolveUrl("~/Pages/Customer/catalogue.aspx") %>">
                    <img src="<%: ResolveUrl("~/Assets/logo.png") %>" alt="Logo" />
                </a>
            </div>

            <!-- Right panel with login form -->
            <div class="login-right">
                <div class="login-form">
                    <input type="text" id="txtEmail" name="txtEmail" placeholder="Email" />
                    <input type="password" id="txtPassword" name="txtPassword" placeholder="Password" />
                    <br /><br /><br />
                    <button type="submit">Login</button>
                    <a href="<%: ResolveUrl("~/Pages/Customer/register.aspx") %>">Don't have an account? Register now</a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
