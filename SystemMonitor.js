const xapi = require('xapi');

/**
 * Cisco DX80 System Monitor Macro
 * Displays room analytics and device status.
 */

async function updateStatus() {
  let temp = null;
  let airQuality = null;

  try {
    temp = await xapi.status.get('RoomAnalytics AmbientTemperature');
  } catch (e) {
    console.log('Temperature metric not available on this firmware/hardware');
  }

  try {
    airQuality = await xapi.status.get('RoomAnalytics AirQuality Index');
  } catch (e) {
    console.log('Air Quality metric not available on this firmware/hardware');
  }

  if (temp !== null) {
    console.log(`Current Temp: ${temp}°C`);
    // Note: You can also push these values to a UI Extension widget label
    // xapi.command('UserInterface Extensions Widget SetValue', { WidgetId: 'temp_label', Value: temp + '°C' });
  }

  if (airQuality !== null) {
    console.log(`Current Air Quality: ${airQuality}`);
  }
}

// Update every 5 minutes
setInterval(updateStatus, 300000);
updateStatus();
