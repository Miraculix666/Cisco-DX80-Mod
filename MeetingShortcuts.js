const xapi = require('xapi');

/**
 * Cisco DX80 Meeting Shortcuts Macro
 * Author: Antigravity AI
 * Version: 1.0
 * 
 * Description:
 * This macro listens for clicks on UI Extension widgets (Action Buttons)
 * with the IDs 'teams' and 'zoom' and opens the respective web versions
 * using the DX80 Web Engine.
 */

xapi.event.on('UserInterface Extensions Widget Action', (event) => {
    if (event.Type === 'clicked') {
        if (event.WidgetId === 'teams') {
            console.log('Opening Teams...');
            xapi.command('UserInterface WebView Display', { 
                Url: 'https://teams.microsoft.com',
                Target: 'Full'
            });
        } else if (event.WidgetId === 'zoom') {
            console.log('Opening Zoom...');
            xapi.command('UserInterface WebView Display', { 
                Url: 'https://zoom.us/join',
                Target: 'Full'
            });
        }
    }
});
