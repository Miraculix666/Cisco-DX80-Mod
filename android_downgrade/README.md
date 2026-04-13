# Downgrade Cisco DX80 to Android

If you want to convert a Cisco DX80 from CE (Collaboration Endpoint) software back to the latest available Android-based software, you must follow a two-step downgrade process.

**Note on Firmware Files:**
The required firmware files (`s52040ce8_2_1.pkg` and `dx80.ce8.2.0-syn213.rel.pkg`) are proprietary Cisco software. You must download them from the Cisco Software Download Center using a Cisco account with a valid service contract. The files in this repository are placeholders.

## Prerequisites

1. Download the downgrade firmware `s52040ce8_2_1.pkg` from Cisco.
2. Download the conversion firmware `dx80.ce8.2.0-syn213.rel.pkg` from Cisco.
3. Replace the placeholder files in this directory with the actual downloaded files.

## Procedure

### Step 1: Downgrade to CE 8.2.x

If your device is running CE 8.3 or higher (e.g., CE 9.15), you must first downgrade it to CE 8.2.x.
1. Log in to the web interface of your Cisco DX80.
2. Navigate to **Maintenance** > **Software Upgrade**.
3. Upload the `s52040ce8_2_1.pkg` file and install it.
4. Wait for the device to upgrade (downgrade) and reboot.

### Step 2: Convert to Android

Once the device is running CE 8.2.1:
1. Log in to the web interface again.
2. Navigate to **Maintenance** > **Software Upgrade**.
3. Upload the `dx80.ce8.2.0-syn213.rel.pkg` conversion package.
4. Install the package. This will completely convert the DX80 software to the Android 10.2.5 base software.

Once complete, your device will boot into the Android environment, which you can then further upgrade to the latest Android 10.2(5.x) release using CUCM or a TFTP server if required.
