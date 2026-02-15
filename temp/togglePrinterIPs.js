// Toggle visibility of printer IP fields based on printer type
function togglePrinterIPs() {
    const printerType = document.getElementById('set-printer-type')?.value;
    const receiptContainer = document.getElementById('receipt-printer-ip-container');
    const kitchenContainer = document.getElementById('kitchen-printer-ip-container');

    if (receiptContainer && kitchenContainer) {
        if (printerType === 'network') {
            receiptContainer.style.display = 'block';
            kitchenContainer.style.display = 'block';
        } else {
            receiptContainer.style.display = 'none';
            kitchenContainer.style.display = 'none';
        }
    }
}
