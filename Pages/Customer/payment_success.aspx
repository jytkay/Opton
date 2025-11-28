<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="payment_success.aspx.cs" Inherits="Opton.Pages.Customer.payment_success" MasterPageFile="~/Site.Master" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div style="max-width: 800px; margin: 100px auto; padding: 40px; text-align: center;">
        <div id="loadingDiv">
            <i class="ri-loader-4-line" style="font-size: 64px; color: var(--color-accent); animation: spin 1s linear infinite;"></i>
            <h2>Verifying Payment...</h2>
            <p>Please wait while we confirm your payment.</p>
        </div>

        <div id="successDiv" style="display: none;">
            <i class="ri-check-circle-line" style="font-size: 96px; color: #28a745;"></i>
            <h1>Payment Successful!</h1>
            <p>Your order has been confirmed.</p>
            <p id="orderIdDisplay" style="font-size: 20px; font-weight: bold; color: var(--color-accent); margin: 20px 0;"></p>
            <button type="button" onclick="window.location.href='<%= ResolveUrl("~/Pages/Customer/catalogue.aspx") %>'" style="padding: 15px 30px; background: var(--color-accent); color: white; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; margin-top: 20px;">
                Continue Shopping
            </button>
        </div>

        <div id="errorDiv" style="display: none;">
            <i class="ri-close-circle-line" style="font-size: 96px; color: #dc3545;"></i>
            <h1>Payment Failed</h1>
            <p id="errorMessage">There was an issue processing your payment.</p>
            <button onclick="window.location.href='/Pages/Customer/checkout.aspx'" style="padding: 15px 30px; background: var(--color-accent); color: white; border: none; border-radius: 8px; font-size: 16px; cursor: pointer; margin-top: 20px;">
                Try Again
            </button>
        </div>
    </div>

    <style>
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
    </style>

    <script>
        async function verifyPayment() {
            const urlParams = new URLSearchParams(window.location.search);
            const paymentIntent = urlParams.get('payment_intent');

            if (!paymentIntent) {
                showError('No payment information found');
                return;
            }

            try {
                // Verify payment with backend
                const response = await fetch('/Handlers/payment_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'verifyPayment',
                        paymentIntentId: paymentIntent
                    })
                });

                const result = await response.json();

                if (result.success && result.status === 'succeeded') {
                    // Get pending order data
                    const pendingOrderData = sessionStorage.getItem('pendingOrderData');

                    if (pendingOrderData) {
                        const orderData = JSON.parse(pendingOrderData);

                        console.log('Order Data Keys:', Object.keys(orderData));
                        console.log('Full Order Data:', orderData);

                        orderData.payment.transactionId = paymentIntent;
                        orderData.payment.status = 'paid';
                        await createOrderAfterPayment(orderData);
                    } else {
                        showError('Order data not found. Please contact support with payment ID: ' + paymentIntent);
                    }
                } else {
                    showError('Payment verification failed: ' + (result.status || 'Unknown error'));
                }
            } catch (error) {
                console.error('Verification error:', error);
                showError(error.message);
            }
        }

        async function createOrderAfterPayment(orderData) {
            try {
                // Transform ALL items into the structure backend expects
                const transformedData = {
                    customer: orderData.customer,
                    items: orderData.items.map(item => ({
                        product: item.product || {},
                        package: item.package || {},
                        addons: item.addons || [],
                        prescription: item.prescription || null
                    })),
                    payment: orderData.payment,
                    prices: orderData.prices
                };

                const response = await fetch('/Handlers/payment_handler.ashx', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        action: 'createOrder',
                        orderData: transformedData
                    })
                });

                const result = await response.json();

                if (result.success) {
                    sessionStorage.removeItem('checkoutData');
                    sessionStorage.removeItem('pendingOrderData');
                    showSuccess(result.orderId);
                } else {
                    showError('Order creation failed: ' + result.message);
                }
            } catch (error) {
                showError('Order creation error: ' + error.message);
            }
        }

        function showSuccess(orderId) {
            document.getElementById('loadingDiv').style.display = 'none';
            document.getElementById('successDiv').style.display = 'block';
            document.getElementById('orderIdDisplay').textContent = 'Order ID: ' + orderId;
        }

        function showError(message) {
            document.getElementById('loadingDiv').style.display = 'none';
            document.getElementById('errorDiv').style.display = 'block';
            document.getElementById('errorMessage').textContent = message;
        }

        // Start verification on page load
        window.addEventListener('load', verifyPayment);
    </script>
</asp:Content>