/**
 * GustoPOS Universal Thermal Printer Module
 * Supports: WebUSB, Web Bluetooth, Network (Direct IP), and Window Spooler.
 * Generates ESC/POS commands and handles auto-formatting for 80mm/58mm.
 */

const Printer = {
    devices: {}, // Registry of connected devices by role
    type: 'spooler', // Default type
    paperWidth: 80,

    // ESC/POS Commands
    ESC: '\x1B',
    GS: '\x1D',
    CMD: {
        INIT: '\x1B\x40',
        CUT: '\x1D\x56\x01',
        ALIGN_LEFT: '\x1B\x61\x00',
        ALIGN_CENTER: '\x1B\x61\x01',
        ALIGN_RIGHT: '\x1B\x61\x02',
        BOLD_ON: '\x1B\x45\x01',
        BOLD_OFF: '\x1B\x45\x00',
        SIZE_NORMAL: '\x1D\x21\x00',
        SIZE_LARGE: '\x1D\x21\x11',
    },

    async init(type = 'spooler', role = 'counter', width = 80) {
        this.type = type;
        this.paperWidth = width;
        console.log(`[Printer] Initializing ${role} as ${type} (${width}mm)`);

        if (type === 'usb') {
            try {
                // For USB, we might need distinct vendor IDs or selection logic if using multiple USB printers
                // For now, assuming single USB or primary/secondary logic handled by OS selection
                const device = await navigator.usb.requestDevice({ filters: [{ vendorId: 0x0483 }] });
                await device.open();
                await device.selectConfiguration(1);
                await device.claimInterface(0);
                this.devices[role] = device;
                showToast(`Printer (${role}) Connected`, 'success');
            } catch (e) {
                console.error(`USB Init failed for ${role}:`, e);
                showToast(`Failed to connect ${role} printer`, 'error');
                return false;
            }
        } else if (type === 'bluetooth') {
            try {
                console.log(`[Printer] Requesting Bluetooth device for ${role}...`);
                const device = await navigator.bluetooth.requestDevice({
                    filters: [{ services: ['000018f0-0000-1000-8000-00805f9b34fb'] }],
                    optionalServices: ['000018f0-0000-1000-8000-00805f9b34fb']
                });

                if (device) {
                    const server = await device.gatt.connect();
                    this.devices[role] = device;
                    console.log(`[Printer] ${role} connected:`, device.name);
                    showToast(`Printer (${role}) Connected`, 'success');

                    device.addEventListener('gattserverdisconnected', () => {
                        console.log(`[Printer] ${role} disconnected`);
                        delete this.devices[role];
                        showToast(`Printer (${role}) Disconnected`, 'warning');
                    });
                }
            } catch (e) {
                console.error(`Bluetooth Init failed for ${role}:`, e);
                showToast(`Failed to connect ${role} printer`, 'error');
                return false;
            }
        }
        return true;
    },

    async print(content, role = 'counter', isRaw = false) {
        if (this.type === 'spooler') {
            return this.printToSpooler(content, role);
        }

        const data = isRaw ? content : this.formatReceipt(content, role);

        if (this.type === 'usb') {
            const device = this.devices[role];
            if (!device) {
                console.error(`Printer for ${role} not connected!`);
                showToast(`Printer (${role}) not connected`, 'error');
                return;
            }
            try {
                const encoder = new TextEncoder();
                const bytes = encoder.encode(data);
                await device.transferOut(1, bytes);
            } catch (e) {
                console.error(`Print failed for ${role}:`, e);
                showToast(`Print failed for ${role}`, 'error');
            }
        } else if (this.type === 'bluetooth') {
            const device = this.devices[role];
            if (!device) {
                console.error(`Printer for ${role} not connected!`);
                showToast(`Printer (${role}) not connected`, 'error');
                return;
            }
            try {
                let server = device.gatt;
                if (!server.connected) {
                    console.log(`[Printer] Reconnecting ${role}...`);
                    server = await device.gatt.connect();
                }
                const service = await server.getPrimaryService('000018f0-0000-1000-8000-00805f9b34fb');
                const characteristic = await service.getCharacteristic('00002af1-0000-1000-8000-00805f9b34fb');

                // Chunking for Bluetooth (often limited to ~20 bytes, but modern ones handle ~512)
                // Writing all at once might fail on some devices, but standard implementation is:
                const encoder = new TextEncoder();
                const bytes = encoder.encode(data);

                // Simple write
                await characteristic.writeValue(bytes);
            } catch (e) {
                console.error(`Print failed for ${role}:`, e);
                showToast(`Print failed for ${role}: ` + e.message, 'error');
            }
        } else if (this.type === 'network') {
            const res = await api('network_print', { data: btoa(data), role: role });
            return res.success;
        }
    },

    formatReceipt(data, role = 'counter') {
        let receipt = "";
        const isKitchen = (role === 'kitchen');
        const order = data.order;
        const items = order.items || [];
        const token = order.token_number || 'N/A';

        // ===============================================
        // 1. HEADER & TOKEN (The "Square Box" Logic)
        // ===============================================
        receipt += '\x1B\x40'; // Initialize Printer
        receipt += '\x1B\x61\x01'; // Center Align

        if (isKitchen) {
            receipt += "*** KITCHEN ORDER ***\n\n";

            // --- THE SQUARE BOX TOKEN ---
            // GS B 1 (Reverse On) + GS ! 17 (Double W/H)
            receipt += '\x1D\x42\x01\x1D\x21\x11';
            receipt += `  TOKEN: ${token}  `; // Spaces for padding the box
            receipt += '\x1D\x21\x00\x1D\x42\x00'; // Reset Size & Reverse Off
            // -----------------------------
            receipt += "\n\n";
        } else {
            // Normal Counter Header
            const settings = data.settings || {};
            receipt += (settings.restaurant_name || "GUSTO POS") + "\n";
            if (settings.restaurant_address) receipt += settings.restaurant_address + "\n";
            if (settings.restaurant_phone) receipt += "Tel: " + settings.restaurant_phone + "\n";
        }
        receipt += '\x1B\x61\x00'; // Left Align

        // ===============================================
        // 2. ORDER DETAILS (No Duplicate Token Here)
        // ===============================================
        receipt += `Order: ${order.order_number}\n`;
        receipt += `Date:  ${order.created_at || new Date().toLocaleString()}\n`;
        // Table Name logic
        let tableName = order.table_name || (order.table_id ? `Table ${order.table_id}` : 'Walk-in');
        receipt += `Table: ${tableName}\n`;

        // Waiter Name (Optional)
        if (order.waiter_name) receipt += `Server: ${order.waiter_name}\n`;

        receipt += "--------------------------------\n";

        // ===============================================
        // 3. ITEMS LIST (Conditional Columns)
        // ===============================================
        if (isKitchen) {
            // KITCHEN: QTY | ITEM NAME (No Price)
            receipt += "QTY   ITEM\n";
            receipt += "--------------------------------\n";

            items.forEach(item => {
                // Format: "2 x  Burger"
                let qtyStr = `${item.quantity} x`.padEnd(5);
                receipt += `\x1B\x45\x01${qtyStr}\x1B\x45\x00 ${item.product_name}\n`;

                // Modifiers / Notes
                if (item.notes) receipt += `      (Note: ${item.notes})\n`;
                if (item.modifiers) receipt += `      + ${item.modifiers}\n`;
            });
        } else {
            // COUNTER: ITEM | QTY | PRICE
            receipt += "ITEM                 QTY     TOTAL\n";
            receipt += "--------------------------------\n";

            items.forEach(item => {
                let name = (item.product_name || item.name || '').substring(0, 20).padEnd(20);
                let qty = String(item.quantity).padStart(3);
                let price = parseFloat(item.price || 0);
                let total = String((price * item.quantity).toFixed(2)).padStart(8);
                receipt += `${name} ${qty} ${total}\n`;
            });
        }
        receipt += "--------------------------------\n";

        // ===============================================
        // 4. FOOTER (Remove Totals for Kitchen)
        // ===============================================
        if (!isKitchen) {
            // COUNTER: Show Totals
            receipt += `Subtotal: ${parseFloat(order.subtotal).toFixed(2).padStart(20)}\n`;
            if (parseFloat(order.tax) > 0) receipt += `Tax:      ${parseFloat(order.tax).toFixed(2).padStart(20)}\n`;

            receipt += '\x1B\x45\x01'; // Bold
            receipt += `TOTAL:    ${parseFloat(order.total).toFixed(2).padStart(20)}\n`;
            receipt += '\x1B\x45\x00'; // Reset Bold

            receipt += "\nTHANK YOU!\n";
            receipt += "Software by GustoPOS\n";

            // Payment Mode
            receipt += '\x1B\x61\x01'; // Center
            receipt += "PAYMENT MODE: CASH\n";
        } else {
            // KITCHEN: Simple Cut Line
            receipt += "\n\n\n"; // Space for cutting
        }

        // Cut Command
        receipt += "\n\n\n\n" + this.CMD.CUT;
        return receipt;
    },

    printToSpooler(data, role = 'counter') {
        const { order, settings } = data;
        const isKitchen = (role === 'kitchen');
        const isWalkIn = (order.order_type === 'walk_in') || (order.table_name === 'Walk-in') || (!order.table_name);
        const isDineIn = !isWalkIn;
        const token = order.token_number || 'N/A';
        const tableName = order.table_name || (order.table_id ? `Table ${order.table_id}` : 'Walk-in');

        // Logic for Header Title
        let headerTitle = settings.restaurant_name || "GUSTO POS";
        if (isKitchen) headerTitle = "KITCHEN ORDER";

        // Logic for Token Visibility
        // Walk-in OR Kitchen: Show Token
        // Dine-in Counter: Hide Token
        const showToken = isKitchen || isWalkIn;

        let style = `
            body { background: #fff; font-family: 'Courier New', monospace; padding: 0; margin: 0; width: 80mm; }
            .receipt { width: 100%; box-sizing: border-box; padding: 2mm; }
            
            /* Header */
            .brand { text-align: center; margin-bottom: 5mm; }
            .brand h2 { margin: 0; font-size: 16px; font-weight: bold; text-transform: uppercase; }
            .brand p { margin: 2px 0; font-size: 12px; }

            /* Lines */
            .line { border-top: 1px dashed #000; margin: 3mm 0; }
            .line-thick { border-top: 2px solid #000; margin: 3mm 0; }

            /* Info */
            .info { font-size: 12px; }
            .info div { display: flex; justify-content: space-between; margin: 3px 0; }

            /* Professional Token */
            .token { text-align: center; margin: 5mm 0; font-size: 22px; font-weight: bold; letter-spacing: 2px; border: 2px solid #000; padding: 2mm; width: fit-content; margin-left: auto; margin-right: auto; }

            /* Table */
            table { width: 100%; border-collapse: collapse; font-size: 12px; margin: 5mm 0; table-layout: fixed; }
            th { border-bottom: 1px solid #000; text-align: left; padding: 4px 0; }
            td { padding: 5px 0; vertical-align: top; }
            
            /* Columns */
            .qty { width: 15%; text-align: center; }
            .price { width: 25%; text-align: right; }
            
            /* Item Column: Allow Wrapping (User Request: Fully Displayed) */
            .item { 
                width: 60%; 
                white-space: normal; 
                word-wrap: break-word;
                overflow: visible;
                display: inline-block; 
                max-width: 100%;
                font-size: 11px;
            }
            
            /* Kitchen Specifics */
            .kitchen-item { 
                width: 85%; 
                white-space: normal; 
                word-wrap: break-word;
                overflow: visible;
                display: inline-block;
                max-width: 100%;
                font-size: 14px;
                font-weight: bold;
            }

            /* Totals */
            .total { font-size: 12px; margin-top: 5mm; }
            .total div { display: flex; justify-content: space-between; margin: 4px 0; }
            .grand { font-size: 16px; font-weight: bold; border-top: 1px solid #000; border-bottom: 1px solid #000; padding: 6px 0; }

            /* Footer */
            .footer { text-align: center; font-size: 12px; margin-top: 8mm; }
            
            @media print {
                body { background: none; }
                .no-print { display: none; }
            }
        `;

        let html = `<html><head><title>Receipt</title><style>${style}</style></head><body>`;
        html += `<div class="receipt">`;

        // --- BRAND HEADER ---
        html += `<div class="brand">`;
        if (settings.restaurant_logo) {
            html += `<img src="${settings.restaurant_logo}" style="max-width: 60%; height: auto; margin-bottom: 5px; display: block; margin-left: auto; margin-right: auto;">`;
        }
        html += `<h2>${headerTitle}</h2>`;
        if (!isKitchen) {
            if (settings.restaurant_address) html += `<p>${settings.restaurant_address}</p>`;
            if (settings.restaurant_phone) html += `<p>Tel: ${settings.restaurant_phone}</p>`;
        }
        html += `</div>`;

        // --- TOKEN (Conditional) ---
        if (showToken) {
            html += `<div class="token">TOKEN #${token}</div>`;
        }

        // --- SEPARATOR ---
        html += isKitchen ? `<div class="line-thick"></div>` : `<div class="line"></div>`;

        // --- ORDER INFO ---
        html += `<div class="info">`;
        html += `<div><span>Order:</span><span>#${order.order_number || order.id}</span></div>`;
        html += `<div><span>Date:</span><span>${new Date().toLocaleDateString()} ${new Date().toLocaleTimeString()}</span></div>`;
        html += `<div><span>Type:</span><span>${order.order_type === 'walk_in' ? 'Walk-In' : 'Dine-In'}</span></div>`;
        if (order.table_name || order.table_id) {
            html += `<div><span>Table:</span><span>${tableName}</span></div>`;
        }
        if (order.waiter_name) {
            html += `<div><span>Server:</span><span>${order.waiter_name}</span></div>`;
        }
        html += `</div>`;

        html += `<div class="line"></div>`;

        // --- ITEMS TABLE ---
        html += `<table>`;
        if (isKitchen) {
            // Kitchen: ITEM | QTY (No Price)
            html += `<tr><th class="kitchen-item">ITEM</th><th class="qty">QTY</th></tr>`;
            (order.items || []).forEach(item => {
                html += `<tr>`;
                html += `<td class="kitchen-item">${item.product_name || item.name}`;
                if (item.notes) html += `<br><i style="font-size:0.9em">(${item.notes})</i>`;
                if (item.modifiers) html += `<br><i style="font-size:0.9em">+ ${item.modifiers}</i>`;
                html += `</td>`;
                html += `<td class="qty">${item.quantity}</td>`;
                html += `</tr>`;
            });
        } else {
            // Counter: ITEM | QTY | TOTAL
            html += `<tr><th class="item">ITEM</th><th class="qty">QTY</th><th class="price">TOTAL</th></tr>`;
            (order.items || []).forEach(item => {
                const price = parseFloat(item.price || 0);
                const total = (price * item.quantity).toFixed(2);
                html += `<tr>`;
                html += `<td class="item">${item.product_name || item.name}`;
                if (item.notes) html += `<br><i style="font-size:0.9em">(${item.notes})</i>`;
                html += `</td>`;
                html += `<td class="qty">${item.quantity}</td>`;
                html += `<td class="price">${total}</td>`;
                html += `</tr>`;
            });
        }
        html += `</table>`;

        html += isKitchen ? `<div class="line-thick"></div>` : `<div class="line"></div>`;

        // --- TOTALS (Counter Only) ---
        if (!isKitchen) {
            html += `<div class="total">`;
            html += `<div><span>Subtotal:</span><span>${parseFloat(order.subtotal).toFixed(2)}</span></div>`;
            if (parseFloat(order.tax) > 0) html += `<div><span>Tax:</span><span>${parseFloat(order.tax).toFixed(2)}</span></div>`;
            if (parseFloat(order.service_charge) > 0) html += `<div><span>Srv Chg:</span><span>${parseFloat(order.service_charge).toFixed(2)}</span></div>`;
            if (parseFloat(order.discount) > 0) html += `<div><span>Discount:</span><span>-${parseFloat(order.discount).toFixed(2)}</span></div>`;

            html += `<div class="grand"><span>TOTAL:</span><span>${parseFloat(order.total).toFixed(2)}</span></div>`;
            html += `</div>`;
        }

        // --- FOOTER ---
        html += `<div class="footer">`;
        if (isKitchen) {
            html += `Kitchen Copy<br>Software by GustoPOS`;
        } else {
            html += `THANK YOU!<br>Software by GustoPOS`;
            if (settings.custom_footer_note) {
                html += `<br>${settings.custom_footer_note}`;
            }
        }
        html += `</div>`;

        // --- PRINT CONTROLS (Hidden in Print) ---
        html += `<div class="no-print" style="margin-top: 5mm; text-align: center;">`;
        html += `<button onclick="window.print()" style="padding:10px 20px; font-size:16px;">PRINT RECEIPT</button> `;
        html += `<button onclick="window.close()" style="padding:10px 20px; font-size:16px;">CLOSE</button>`;
        html += `</div>`;

        // Auto Print Script
        html += `<script>window.onload = function() { setTimeout(function() { window.print(); }, 500); };</script>`;

        html += `</div></body></html>`;

        const win = window.open('', 'Receipt', 'width=400,height=600');
        if (win) {
            win.document.open();
            win.document.write(html);
            win.document.close();
        }
        return true;
    }
};
