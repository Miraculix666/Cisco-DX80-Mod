// ============================================================
// Cisco DX80 - Meeting Shortcuts Macro (V2 - Korrigiert)
// ============================================================
// WICHTIG: Das DX80 (CE 9.15) unterstuetzt KEINE WebEngine!
// Der Browser-Befehl (UserInterface WebView Display) ist 
// hardwareseitig nicht verfuegbar (ARM Cortex-A9, zu alt).
//
// Stattdessen: SIP-Dial-Logik fuer Teams/Zoom via Meeting-ID
// ============================================================

const xapi = require('xapi');
const CONFIG = require('./config.js');

function dialMeeting(service, meetingId) {
  let sipAddress = '';
  
  if (service === 'zoom') {
    // Zoom SIP Format: MEETINGID@zoomcrc.com
    sipAddress = meetingId + '@' + CONFIG.zoomSipDomain;
  } else if (service === 'teams') {
    // Teams SIP Format: meetingid@m.lync.com
    sipAddress = meetingId + '@' + CONFIG.teamsSipDomain;
  }
  
  console.log('Dialing: ' + sipAddress);
  xapi.command('Dial', { Number: sipAddress }).catch(e => {
    console.error('Dial error: ' + e.message);
  });
}

// Teams Button Handler
xapi.event.on('UserInterface Extensions Widget Action', (event) => {
  if (event.Type !== 'clicked') return;

  // Teams Meeting-ID Eingabe
  if (event.WidgetId === 'teams') {
    xapi.command('UserInterface Message TextInput Display', {
      FeedbackId: 'teams_meetingid',
      Title: 'Microsoft Teams',
      Text: 'Geben Sie die Meeting-ID oder SIP-Adresse ein:',
      Placeholder: 'z.B. 123456789 oder user@company.com',
      InputType: 'SingleLine',
      SubmitText: 'Verbinden',
    }).catch(e => console.error(e));
  }

  // Zoom Meeting-ID Eingabe
  if (event.WidgetId === 'zoom') {
    xapi.command('UserInterface Message TextInput Display', {
      FeedbackId: 'zoom_meetingid',
      Title: 'Zoom Meeting',
      Text: 'Geben Sie die Zoom Meeting-ID ein:',
      Placeholder: 'z.B. 123 456 789',
      InputType: 'SingleLine',
      SubmitText: 'Verbinden',
    }).catch(e => console.error(e));
  }
});

// Eingabe-Antwort verarbeiten
xapi.event.on('UserInterface Message TextInput Response', (event) => {
  if (!event || !event.Text) return;
  const input = event.Text.replace(/\s/g, ''); // Leerzeichen entfernen
  
  if (event.FeedbackId === 'teams_meetingid') {
    if (input.includes('@')) {
      // Direktwahl einer SIP-Adresse
      xapi.command('Dial', { Number: input }).catch(e => console.error('Dial error: ' + e.message));
    } else {
      dialMeeting('teams', input);
    }
  }
  
  if (event.FeedbackId === 'zoom_meetingid') {
    if (input.includes('@')) {
      // Direktwahl einer SIP-Adresse für Zoom
      xapi.command('Dial', { Number: input }).catch(e => console.error('Dial error: ' + e.message));
    } else {
      dialMeeting('zoom', input);
    }
  }
});

console.log('Meeting Shortcuts Macro V2 geladen.');
