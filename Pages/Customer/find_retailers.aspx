<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="find_retailers.aspx.cs" Inherits="Opton.Pages.Customer.find_retailers" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeaderOverride" ContentPlaceHolderID="HeaderContent" runat="server">
    <style>
        .retailer-page {
            display: flex;
            gap: 16px;
            padding: 20px;
        }

        /* Left sidebar */
        .retailer-options {
            width: 250px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        /* Collapsible panels */
        .collapsible {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 10px;
        }

        .collapsible-header {
            display: flex;
            justify-content: space-between;
            cursor: pointer;
            font-weight: 600;
        }

        .collapsible-content {
            margin-top: 8px;
            display: none;
            flex-direction: column;
            gap: 8px;
        }

        .collapsible.active .collapsible-content {
            display: flex;
        }

        /* Search input with icon inside */
        .search-row {
            position: relative;
        }

        .search-row input {
            width: 100%;
            padding: 8px 30px 8px 10px;
            border-radius: 8px;
            border: 1px solid rgba(0,0,0,0.1);
        }

        .search-row .search-icon {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 16px;
            color: #888;
        }

        /* Locations */
        .location-item {
            cursor: pointer;
            padding: 8px;
            border-radius: 6px;
            transition: background-color 0.2s;
        }

        .location-item:hover {
            background-color: rgba(0,0,0,0.05);
        }

        .location-item.selected {
            background-color: rgba(0,0,0,0.1);
        }

        /* Buttons */
        .map-action-btn {
            display: inline-block;
            margin: 4px;
            padding: 10px 16px;
            border: none;
            border-radius: 8px;
            background-color: #0078ff;
            color: white;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .map-action-btn:hover {
            background-color: #005fcc;
        }

        .book-appointment-btn {
            background-color: var(--color-dark, #333);
        }

        .book-appointment-btn:hover {
            background-color: #222;
        }

        /* Map section */
        .map-section {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .map-default {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            position: relative;
            height: 600px;
        }

        .fullscreen-btn {
            position: absolute;
            bottom: 10px;
            right: 10px;
            border: none;
            border-radius: 50%;
            padding: 8px;
            cursor: pointer;
            font-size: 18px;
            background: none;
            color: inherit;
        }

        /* Appointment section */
        .appointment-booking {
            font-size: 16px;
            font-weight: 600;
            text-align: right;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="retailer-page">

        <!-- Left sidebar -->
        <div class="retailer-options">
            <!-- Locations collapsible -->
            <div class="locations-list collapsible active">
                <div class="collapsible-header" onclick="this.parentElement.classList.toggle('active')">
                    Locations <i class="ri-arrow-down-s-line"></i>
                </div>
                <div class="collapsible-content">
                    <div class="search-row">
                        <input type="text" placeholder="Search locations..." />
                        <i class="ri-search-line search-icon"></i>
                    </div>
                    <hr />
                    <div id="retailerList"></div>
                </div>
            </div>
        </div>

        <!-- Right section -->
        <div class="map-section">
            <div class="map-default" id="map"></div>
            <div class="appointment-booking">
                <button id="goNowBtn" type="button" class="map-action-btn" style="display:none;">
                    Go Now
                </button>
                <button id="bookAppointmentBtn" type="button" class="map-action-btn book-appointment-btn" style="display:none;">
                    Book Appointment
                </button>
                <span id="defaultLabel">(Select a Location to <strong>Book an Appointment</strong>)</span>
            </div>
        </div>

        <script type="module">
            import { FirebaseManager } from "/Scripts/firebase-init.js";

            window.getIdToken = async () => await FirebaseManager.getIdToken();
            window.getCurrentUser = async () => await FirebaseManager.getCurrentUser();

            FirebaseManager.onReady(async () => {
                await loadRetailers();

                // --- Search filter ---
                const searchInput = document.querySelector('.search-row input');
                searchInput.addEventListener('input', () => {
                    const query = searchInput.value.toLowerCase();
                    document.querySelectorAll('.location-item').forEach(item => {
                        const text = item.textContent.toLowerCase();
                        item.style.display = text.includes(query) ? '' : 'none';
                    });
                });
            });

            let map;
            let markers = [];

            async function loadRetailers() {
                const contentDiv = document.getElementById('retailerList');
                contentDiv.innerHTML = '<p>Loading retailers...</p>';

                try {
                    const response = await fetch('/Handlers/fire_handler.ashx', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ getRetailers: true })
                    });

                    const data = await response.json();
                    if (!data.success || !data.retailers?.length) {
                        contentDiv.innerHTML = '<p>No retailers found.</p>';
                        return;
                    }

                    contentDiv.innerHTML = '';
                    const goNowBtn = document.getElementById('goNowBtn');
                    const bookBtn = document.getElementById('bookAppointmentBtn');
                    const defaultLabel = document.getElementById('defaultLabel');
                    let currentInfoWindow = null;

                    data.retailers.forEach((r, index) => {
                        const retailerDiv = document.createElement('div');
                        retailerDiv.classList.add('location-item');
                        retailerDiv.innerHTML = `
                            <strong>${r.name}</strong>
                            <div class="retailer-address">${r.address}</div>
                            <hr />
                        `;
                        contentDiv.appendChild(retailerDiv);

                        retailerDiv.addEventListener('click', () => {
                            document.querySelectorAll('.location-item').forEach(el => el.classList.remove('selected'));
                            retailerDiv.classList.add('selected');

                            const lat = parseFloat(r.latitude);
                            const lng = parseFloat(r.longitude);
                            const markerObj = markers[index];

                            if (!isNaN(lat) && !isNaN(lng)) {
                                map.panTo({ lat, lng });
                                map.setZoom(15);
                            }

                            if (currentInfoWindow) currentInfoWindow.close();
                            if (markerObj?.infoWindow) {
                                markerObj.infoWindow.open(map, markerObj.marker);
                                currentInfoWindow = markerObj.infoWindow;
                            }

                            goNowBtn.style.display = 'inline-block';
                            bookBtn.style.display = 'inline-block';
                            defaultLabel.style.display = 'none';

                            goNowBtn.onclick = () => {
                                window.open(`https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}&travelmode=driving`, '_blank');
                            };

                            bookBtn.textContent = `Book Appointment at ${r.name}`;
                            bookBtn.onclick = () => {
                                window.location.href = `appointment.aspx?retailerId=${encodeURIComponent(r.id)}&retailerName=${encodeURIComponent(r.name)}`;
                            };
                        });
                    });

                    await initializeMap(data.retailers);

                } catch (err) {
                    console.error('Error loading retailers:', err);
                }
            }

            async function initializeMap(retailers) {
                const mapDiv = document.getElementById('map');
                const apiKey = (await (await fetch('/Handlers/get_keys.ashx')).json()).apiKeys.GOOGLE_API_KEY;

                const script = document.createElement('script');
                script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}`;
                document.head.appendChild(script);

                script.onload = () => {
                    map = new google.maps.Map(mapDiv, {
                        center: { lat: parseFloat(retailers[0].latitude), lng: parseFloat(retailers[0].longitude) },
                        zoom: 12
                    });

                    retailers.forEach((r, index) => {
                        const lat = parseFloat(r.latitude);
                        const lng = parseFloat(r.longitude);
                        if (isNaN(lat) || isNaN(lng)) return;

                        const marker = new google.maps.Marker({ position: { lat, lng }, map, title: r.name });
                        const infoWindow = new google.maps.InfoWindow({ content: `<strong>${r.name}</strong><br>${r.address}` });
                        marker.addListener('click', () => infoWindow.open(map, marker));

                        markers.push({ marker, infoWindow });
                    });
                };
            }
        </script>
    </div>
</asp:Content>
