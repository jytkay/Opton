<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="track_order.aspx.cs" Inherits="Opton.Pages.Customer.track_order" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <style>
        /* Container */
        .track-page {
            display: flex;
            flex-direction: column;
            gap: 24px;
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Header */
        .track-header {
            text-align: center;
        }

            .track-header .title {
                display: inline-flex;
                align-items: center;
                gap: 10px;
                font-size: 28px;
                font-weight: 700;
                color: var(--color-dark);
            }

            .track-header hr {
                height: 15px;
                border: none;
                background-color: var(--color-light);
                margin-top: 10px;
                margin-bottom: 0;
                border-radius: 8px;
            }

        /* Order Input */
        .order-input {
            display: flex;
            flex-direction: column;
            gap: 12px;
            align-items: stretch;
        }

            .order-input input {
                width: 320px;
                padding: 12px 14px;
                border: 1px solid rgba(0,0,0,0.08);
                border-radius: 12px;
                font-size: 15px;
                text-align: center;
                box-shadow: 0 1px 2px rgba(0,0,0,0.03);
                margin: 0 auto;
            }

        .proceed-row {
            display: flex;
            justify-content: center;
        }

        .proceed-btn {
            background: transparent;
            border: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

            .proceed-btn i {
                font-size: 40px;
                color: var(--color-accent);
                line-height: 1;
            }

        /* Contact */
        .contact {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            font-size: 15px;
            color: var(--color-dark);
            text-align: center;
            transition: all 180ms ease;
        }

            .contact.compact {
                flex-direction: row;
                white-space: nowrap;
                font-size: 13px;
                gap: 12px;
                justify-content: center;
                align-items: center;
            }

            .contact .title {
                font-size: 16px;
                display: block;
            }

            .contact.compact .title {
                font-size: 13px;
                display: inline-block;
                margin-right: 6px;
            }

            .contact .phone-row {
                display: inline-flex;
                gap: 8px;
                align-items: center;
                font-weight: 500;
            }

                .contact .phone-row i {
                    font-size: 18px;
                    color: var(--color-accent);
                }

        /* Track Icons */
        .track-icons {
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .track-steps {
            display: flex;
            justify-content: space-between;
            width: 80%;
            position: relative;
            z-index: 1;
        }

        .track-line {
            position: absolute;
            top: 40%;
            left: 16%;
            right: 16%;
            height: 4px;
            background: var(--color-light);
            border-radius: 2px;
            transform: translateY(-50%);
            z-index: 0;
        }

        .track-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
            width: 20%;
        }

            .track-step .step-icon {
                width: 56px;
                height: 56px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                background: white;
                color: var(--color-accent);
                font-size: 24px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.08);
                transition: all 0.2s ease;
            }

            .track-step.current .step-icon {
                background: var(--color-accent);
                color: white;
            }

            .track-step span {
                margin-top: 8px;
                font-size: 14px;
                color: var(--color-dark);
                text-align: center;
                width: 100%;
            }

        /* Tracked Details */
        .tracked-details {
            display: none;
            background: #fafafa;
            padding: 16px;
            border-radius: 8px;
            border: 1px solid rgba(0,0,0,0.03);
        }

            .tracked-details.active {
                display: block;
            }

            .tracked-details h3 {
                margin-top: 0;
                margin-bottom: 12px;
                font-size: 20px;
                color: var(--color-dark);
            }

            .tracked-details ul {
                padding-left: 16px;
                margin: 0 0 12px 0;
            }

                .tracked-details ul li {
                    margin-bottom: 6px;
                    line-height: 1.4;
                }

            .tracked-details ol {
                padding-left: 20px;
                margin: 0;
            }

                .tracked-details ol li {
                    margin-bottom: 4px;
                }

        /* Responsive */
        @media (max-width: 700px) {
            .track-icons {
                padding: 0 6%;
            }

            .track-step .step-icon {
                width: 48px;
                height: 48px;
                font-size: 20px;
            }

            .track-header .title {
                font-size: 20px;
                gap: 8px;
            }

            .proceed-btn i {
                font-size: 34px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="track-page">

        <!-- Header -->
        <div class="track-header">
            <div class="title">Track Order</div>
            <hr />
        </div>

        <!-- Order Input -->
        <div class="order-input">
            <input id="txtTrackNo" type="text" placeholder="Tracking Number" />
            <div class="proceed-row">
                <button type="button" class="proceed-btn" id="btnTrack">
                    <i class="ri-arrow-down-circle-fill"></i>
                </button>
            </div>
        </div>

        <!-- Contact -->
        <div class="contact" id="contactBlock">
            <strong class="title">Placed an order?</strong>
            <span>Check your email for your order number, or contact us at:</span>
            <div class="phone-row">
                <i class="ri-phone-fill"></i>
                <strong>+60 12-345 6789</strong>
            </div>
        </div>

        <!-- Track Icons -->
        <div class="track-icons">
            <div class="track-line"></div>
            <div class="track-steps">
                <div class="track-step" data-status="ORDERED">
                    <i class="ri-shopping-bag-fill step-icon"></i>
                    <span>Ordered</span>
                </div>
                <div class="track-step" data-status="PACKED">
                    <i class="ri-archive-fill step-icon"></i>
                    <span>Packed</span>
                </div>
                <div class="track-step" data-status="IN_TRANSIT">
                    <i class="ri-truck-fill step-icon"></i>
                    <span>In Transit</span>
                </div>
                <div class="track-step" data-status="OUT_FOR_DELIVERY">
                    <i class="ri-map-pin-fill step-icon"></i>
                    <span>Out for Delivery</span>
                </div>
                <div class="track-step" data-status="DELIVERED">
                    <i class="ri-home-4-fill step-icon"></i>
                    <span>Delivered</span>
                </div>
            </div>
        </div>

        <!-- Tracked Details -->
        <div id="trackedDetails" class="tracked-details">
            <h3>Order #<span id="trackedTrackNo">—</span></h3>
            <div id="trackedInfo">Order details will appear here after tracking...</div>
        </div>

    </div>

    <script>
        (async function () {
            const btn = document.getElementById('btnTrack');
            const tracked = document.getElementById('trackedDetails');
            const contact = document.getElementById('contactBlock');
            const trackNoEl = document.getElementById('trackedTrackNo');
            const trackedInfo = document.getElementById('trackedInfo');

            let TRACK123_API_KEY;
            try {
                const res = await fetch('/Handlers/get_keys.ashx');
                const data = await res.json();
                if (data.success && data.apiKeys.TRACK123_API_KEY) {
                    TRACK123_API_KEY = data.apiKeys.TRACK123_API_KEY;
                }
            } catch (err) {
                console.error(err);
            }

            const TRACK123_QUERY_URL = 'https://api.track123.com/gateway/open-api/tk/v2/track/query';

            async function fetchTrackingInfo(trackingNumber) {
                const body = {
                    trackNos: [trackingNumber],
                    createTimeStart: "2021-01-01 00:00:00",
                    createTimeEnd: "2030-01-01 23:59:59",
                    cursor: "",
                    queryPageSize: 100
                };
                try {
                    const response = await fetch(TRACK123_QUERY_URL, {
                        method: 'POST',
                        headers: {
                            'Track123-Api-Secret': TRACK123_API_KEY,
                            'accept': 'application/json',
                            'content-type': 'application/json'
                        },
                        body: JSON.stringify(body)
                    });
                    if (!response.ok) throw new Error(`HTTP ${response.status}`);
                    return await response.json();
                } catch (err) {
                    console.error(err);
                    return { error: err.message };
                }
            }

            function resetStepClasses() {
                document.querySelectorAll('.track-step').forEach(step => step.classList.remove('current'));
            }

            function highlightCurrentStep(status) {
                const steps = document.querySelectorAll('.track-step');
                steps.forEach(step => {
                    if (step.dataset.status === status.toUpperCase()) {
                        step.classList.add('current');
                    }
                });
            }

            btn.addEventListener('click', async function () {
                const orderInput = document.getElementById('txtTrackNo').value.trim();
                if (!orderInput) return alert("Please enter a tracking number.");

                tracked.classList.add('active');
                contact.classList.add('compact');
                trackNoEl.textContent = orderInput;
                trackedInfo.innerHTML = 'Fetching tracking information...';

                resetStepClasses();

                const data = await fetchTrackingInfo(orderInput);
                if (data.error) {
                    trackedInfo.textContent = `Error: ${data.error}`;
                    return;
                }

                if (data.data?.accepted?.content.length > 0) {
                    const tracking = data.data.accepted.content[0];
                    highlightCurrentStep(tracking.transitStatus || '');

                    let html = `<ul>`;

                    if (tracking.trackNo) html += `<li><strong>Tracking Number:</strong> ${tracking.trackNo}</li>`;
                    if (tracking.localLogisticsInfo?.courierNameEN) html += `<li><strong>Carrier:</strong> ${tracking.localLogisticsInfo.courierNameEN}</li>`;
                    if (tracking.transitStatus) html += `<li><strong>Current Status:</strong> ${tracking.transitStatus}</li>`;
                    if (tracking.shipTime) html += `<li><strong>Pickup Date:</strong> ${tracking.shipTime}</li>`;
                    if (tracking.expectedDelivery) html += `<li><strong>Estimated Delivery:</strong> ${tracking.expectedDelivery}</li>`;
                    if (tracking.shipFrom) html += `<li><strong>Origin:</strong> ${tracking.shipFrom}</li>`;
                    if (tracking.shipTo) html += `<li><strong>Destination:</strong> ${tracking.shipTo}</li>`;

                    html += `</ul>`;

                    // Tracking history
                    const history = tracking.localLogisticsInfo?.trackingDetails || [];
                    if (history.length > 0) {
                        html += `<h4>Tracking History:</h4><ol>`;
                        history.forEach(e => {
                            const parts = [];
                            if (e.eventTime) parts.push(e.eventTime);
                            if (e.eventDetail) parts.push(e.eventDetail);
                            if (e.address) parts.push(e.address);
                            if (parts.length) html += `<li>${parts.join(' — ')}</li>`;
                        });
                        html += `</ol>`;
                    }

                    trackedInfo.innerHTML = html;
                } else {
                    trackedInfo.textContent = 'No tracking information available.';
                }
            });

            document.getElementById('txtTrackNo').addEventListener('keydown', function (e) {
                if (e.key === 'Enter') { e.preventDefault(); btn.click(); }
            });

        })();
</script>
</asp:Content>
