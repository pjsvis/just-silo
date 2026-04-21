# google cloud setup
<details>
<summary>Step-by-step Google Cloud Console instructions</summary>

> For **remote deployment**, create an OAuth client of type **Web application** (not Desktop app). Use Desktop app only for local stdio usage.

1. **Go to Google Cloud Console:** Open [console.cloud.google.com](https://console.cloud.google.com/)
2. **Create or Select a Project:** Click the project dropdown > "NEW PROJECT". Name it (e.g., "MCP Docs Server") and click "CREATE".
3. **Enable APIs:**
   - Navigate to "APIs & Services" > "Library"
   - Search for and enable: **Google Docs API**, **Google Sheets API**, **Google Drive API**, **Gmail API**, **Google Calendar API**
4. **Configure OAuth Consent Screen:**
   - Go to "APIs & Services" > "OAuth consent screen"
   - Choose "External" and click "CREATE"
   - Fill in: App name, User support email, Developer contact email
   - Click "SAVE AND CONTINUE"
   - Add scopes: `documents`, `spreadsheets`, `drive`, `gmail.modify`, `calendar.events`
   - Click "SAVE AND CONTINUE"
   - Add your Google email as a Test User
   - Click "SAVE AND CONTINUE"
5. **Create Credentials:**
   - Go to "APIs & Services" > "Credentials"
   - Click "+ CREATE CREDENTIALS" > "OAuth client ID"
   - Application type: "Desktop app"
   - Click "CREATE"
   - Copy the **Client ID** and **Client Secret**

</details>