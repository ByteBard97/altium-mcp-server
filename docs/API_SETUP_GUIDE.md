# Nexar API Setup Guide

This guide will walk you through creating a Nexar account and obtaining the API credentials needed for the distributor integration feature in Altium MCP Server.

## What is Nexar?

Nexar is a unified API platform that provides access to electronic component data from hundreds of distributors, manufacturers, and suppliers. It aggregates real-time information about:

- Component availability and stock levels
- Pricing and quantity breaks
- Datasheets and specifications
- Alternative and cross-reference parts
- Lifecycle and obsolescence status

## Why Do I Need API Keys?

API keys (Client ID and Client Secret) authenticate your requests to Nexar's servers and ensure:

- **Security:** Only authorized applications can access the API
- **Rate limiting:** Fair usage across all users
- **Analytics:** Track your application's API usage
- **Support:** Nexar can help troubleshoot issues specific to your account

## Step-by-Step Setup

### Step 1: Create a Nexar Account

1. **Visit the Nexar website**

   Navigate to [https://nexar.com](https://nexar.com) in your web browser.

2. **Click "Sign Up" or "Get Started"**

   Look for the registration button, typically in the top-right corner of the page.

3. **Choose an account type**

   - **Individual/Hobbyist:** Free tier with reasonable rate limits
   - **Professional:** Higher rate limits and additional features
   - **Enterprise:** Custom solutions for high-volume usage

   For most Altium MCP users, the free Individual account is sufficient to start.

4. **Fill in your information**

   Provide the required information:
   - Full name
   - Email address (use a professional email if possible)
   - Company name (optional, but recommended)
   - Password (choose a strong password)

5. **Verify your email**

   - Check your inbox for a verification email from Nexar
   - Click the verification link to activate your account
   - If you don't see it, check your spam/junk folder

6. **Complete your profile**

   After verification, you may be asked to:
   - Describe your use case (e.g., "PCB design automation")
   - Select your industry (e.g., "Electronics Manufacturing")
   - Agree to Terms of Service

### Step 2: Access the Developer Dashboard

1. **Log in to your Nexar account**

   Go to [https://nexar.com](https://nexar.com) and sign in with your credentials.

2. **Navigate to the Applications section**

   Look for one of the following:
   - "Developer" menu or tab
   - "Applications" in the user menu
   - "API Access" in settings
   - Direct link: [https://nexar.com/applications](https://nexar.com/applications)

   **Screenshot reference:** This page shows a dashboard with your applications and API usage statistics.

3. **Understand the dashboard**

   The dashboard typically displays:
   - List of your applications (empty if this is your first time)
   - API usage statistics and quotas
   - Documentation links
   - Account tier information

### Step 3: Create an Application

An "application" in Nexar represents your integration project. You can have multiple applications if needed.

1. **Click "Create New Application" or similar button**

   This button is usually prominently displayed on the Applications page.

2. **Fill in the application details**

   You'll be asked to provide:

   **Application Name** (required)
   ```
   Altium MCP Integration
   ```
   or
   ```
   [Your Company] - Altium Tools
   ```

   **Description** (required)
   ```
   Integration between Altium Designer and Claude AI for automated
   BOM validation, component availability checking, and distributor
   data access via the Altium MCP Server.
   ```

   **Application Type** (if asked)
   - Select "Desktop Application" or "Server-Side Application"
   - NOT "Single Page Application" or "Mobile App"

   **Redirect URIs** (if asked)
   - For the Altium MCP server, you typically don't need redirect URIs
   - Leave blank or use: `http://localhost:8080/callback`

   **Permissions/Scopes** (if asked)
   - Select "Read component data"
   - Select "Search capabilities"
   - You typically don't need write permissions

3. **Create the application**

   Click "Create," "Submit," or "Save" to create your application.

   **Screenshot reference:** The form shows fields for name, description, and application settings.

### Step 4: Obtain Your API Credentials

Once your application is created, you'll be shown your API credentials.

1. **Locate your Client ID**

   - The Client ID is a long string like: `a1b2c3d4-e5f6-7890-abcd-1234567890ab`
   - This is public and safe to store in your environment file
   - Copy this value

   **Screenshot reference:** The credentials page shows "Client ID" with a copy button.

2. **Locate your Client Secret**

   - The Client Secret is another long string similar to the Client ID
   - **IMPORTANT:** This is sensitive like a password - keep it secret!
   - It may be hidden by default (shown as `••••••••`)
   - Click "Show" or "Reveal" to display it
   - Copy this value immediately

   **Screenshot reference:** The credentials page shows "Client Secret" with show/hide toggle and copy button.

3. **Save your credentials immediately**

   **Critical:** You may only see the Client Secret once!

   - Copy both values to a secure location temporarily
   - Do NOT close the browser window until you've saved them
   - Consider using a password manager
   - If you lose the Client Secret, you'll need to regenerate credentials

4. **Store credentials in a safe temporary location**

   Open a text editor and create a temporary file:

   ```
   Nexar API Credentials for Altium MCP
   ====================================
   Date: [Current Date]

   Client ID: a1b2c3d4-e5f6-7890-abcd-1234567890ab
   Client Secret: z9y8x7w6-v5u4-3210-zyxw-9876543210fe

   NOTE: Delete this file after adding to .env
   ```

### Step 5: Configure Altium MCP Server

Now you'll add these credentials to your Altium MCP installation.

1. **Locate your Altium MCP installation directory**

   The location depends on how you installed:

   **If installed via Claude Desktop Extension:**
   - Windows: `%APPDATA%\Claude\extensions\altium-mcp\`
   - Or check Claude Desktop settings for extension location

   **If installed manually:**
   - The directory where you cloned/extracted the project

2. **Navigate to the server directory**

   ```
   cd [installation_directory]/server
   ```

3. **Check for an example environment file**

   Look for `.env.example` or `env.example`:

   ```bash
   # On Windows Command Prompt
   dir .env*

   # On PowerShell
   ls .env*
   ```

4. **Create your environment file**

   **If `.env.example` exists:**
   ```bash
   # Windows Command Prompt
   copy .env.example .env

   # PowerShell
   Copy-Item .env.example .env
   ```

   **If no example file exists:**
   Create a new file named `.env` (note the leading dot)

5. **Edit the .env file**

   Open `.env` in your preferred text editor:
   - Notepad
   - VS Code
   - Notepad++
   - Sublime Text

6. **Add your credentials**

   Add or update these lines in the `.env` file:

   ```env
   # Nexar API Configuration
   NEXAR_CLIENT_ID=a1b2c3d4-e5f6-7890-abcd-1234567890ab
   NEXAR_CLIENT_SECRET=z9y8x7w6-v5u4-3210-zyxw-9876543210fe
   ```

   **Important formatting rules:**
   - No spaces around the `=` sign
   - No quotes around the values (unless they're in the actual credential)
   - Each credential on its own line
   - No trailing spaces

7. **Optional: Add additional configuration**

   You can also configure:

   ```env
   # Cache duration in seconds (default: 3600 = 1 hour)
   NEXAR_CACHE_DURATION=3600

   # Preferred currency for pricing (default: USD)
   NEXAR_CURRENCY=USD

   # Enable debug logging (default: false)
   NEXAR_DEBUG=false

   # Preferred distributors (comma-separated)
   NEXAR_PREFERRED_DISTRIBUTORS=DigiKey,Mouser,Newark
   ```

8. **Save the file**

   - Save and close your text editor
   - Ensure the file is named `.env` exactly (not `.env.txt`)

9. **Secure the file**

   **Important security steps:**

   - The `.env` file should be in `.gitignore` (if using Git)
   - Never commit this file to version control
   - Don't share this file with others
   - Don't upload it to cloud storage without encryption

### Step 6: Verify the Configuration

1. **Restart Claude Desktop**

   Completely close and restart Claude Desktop to load the new environment variables.

2. **Test the connection**

   Open a conversation with Claude and ask:

   ```
   "Can you check if the Nexar distributor integration is configured correctly?"
   ```

   or

   ```
   "What's the availability for manufacturer part LM358N?"
   ```

3. **Expected response if successful**

   Claude should respond with actual availability data from distributors.

4. **Expected response if unsuccessful**

   If there's an issue, Claude will report an error such as:
   - "Unable to authenticate with Nexar API"
   - "Nexar credentials not found"
   - "Connection error"

   See the Troubleshooting section below.

## Understanding Your API Limits

### Free Tier Limits

Typical limits for free Nexar accounts:

- **Requests per hour:** 1,000
- **Requests per day:** 10,000
- **Concurrent requests:** 10
- **Data retention:** 24 hours

### Monitoring Usage

1. **Check the Nexar dashboard**

   View real-time usage at [nexar.com/applications](https://nexar.com/applications)

2. **Usage metrics typically shown:**
   - Requests this hour/day/month
   - Percentage of quota used
   - Peak usage times
   - Error rates

3. **Usage tips:**
   - The MCP server caches results to minimize API calls
   - Batch requests when possible
   - Avoid repeatedly checking the same component

### Upgrading Your Account

If you hit rate limits:

1. **Evaluate your usage patterns** in the dashboard
2. **Consider upgrading** to a Professional tier
3. **Contact Nexar sales** for enterprise solutions
4. **Optimize your queries** to reduce API calls

## Regenerating Credentials

If you need to regenerate your credentials (lost secret, security concern, etc.):

1. **Log in to Nexar dashboard**
2. **Go to your application settings**
3. **Look for "Regenerate Credentials" or "Reset Secret"**
4. **Confirm the action** (old credentials will stop working!)
5. **Copy the new credentials** immediately
6. **Update your `.env` file** with the new values
7. **Restart Claude Desktop**

**Warning:** Regenerating credentials immediately invalidates the old ones. Any running instances will stop working until updated.

## Troubleshooting

### Issue: "Cannot find .env file"

**Solution:**
- Ensure you created the file in the correct directory (`server/.env`)
- On Windows, make sure file extensions are visible
- The file should not be `.env.txt` - rename if necessary
- Check that the file isn't hidden

### Issue: "Authentication Failed"

**Possible causes:**
1. **Typo in credentials**
   - Carefully re-copy from Nexar dashboard
   - Check for extra spaces or line breaks
   - Ensure no quotes were added accidentally

2. **Wrong format in .env file**
   - Use `NEXAR_CLIENT_ID=value` (no spaces around =)
   - No quotes needed
   - No trailing whitespace

3. **Credentials expired or regenerated**
   - Check if credentials are still valid in Nexar dashboard
   - Regenerate if necessary

4. **Application suspended**
   - Check application status in Nexar dashboard
   - Contact Nexar support if suspended

### Issue: "Environment variables not loading"

**Solutions:**
1. Restart Claude Desktop completely
2. Check file is named `.env` exactly (not `env` or `.env.txt`)
3. Verify file is in the `server` directory
4. Check file permissions (should be readable)

### Issue: "Rate limit exceeded"

**Solutions:**
1. Wait for the rate limit window to reset (usually 1 hour)
2. Check usage in Nexar dashboard
3. Increase `NEXAR_CACHE_DURATION` to cache results longer
4. Consider upgrading account tier
5. Optimize queries to be more efficient

### Issue: "File extension not showing on Windows"

To show file extensions in Windows:

1. Open File Explorer
2. Click "View" tab
3. Check "File name extensions"
4. Now you can see if the file is `.env` or `.env.txt`

## Security Best Practices

### Protecting Your Credentials

1. **Never commit .env to version control**
   ```bash
   # Add to .gitignore
   .env
   *.env
   !.env.example
   ```

2. **Use environment-specific files**
   - `.env.development` for testing
   - `.env.production` for production
   - Never reuse credentials across environments

3. **Rotate credentials periodically**
   - Every 90 days for production
   - Immediately if compromised

4. **Limit credential access**
   - Only store on devices that need them
   - Use file permissions to restrict access
   - Don't share via email or messaging

### What To Do If Credentials Are Compromised

1. **Immediately regenerate credentials** in Nexar dashboard
2. **Update all instances** with new credentials
3. **Review API usage logs** for suspicious activity
4. **Contact Nexar support** if you see unauthorized usage
5. **Update .env file** on all machines
6. **Delete temporary files** containing old credentials

## Getting Help

### Nexar Support Resources

- **Documentation:** [https://nexar.com/docs](https://nexar.com/docs)
- **API Reference:** [https://nexar.com/api-reference](https://nexar.com/api-reference)
- **Support Portal:** [https://support.nexar.com](https://support.nexar.com)
- **Community Forum:** Check Nexar's community discussions
- **Email Support:** support@nexar.com (response time varies by tier)

### Altium MCP Resources

- **GitHub Issues:** Report bugs specific to the MCP integration
- **Documentation:** See [DISTRIBUTOR_INTEGRATION.md](./DISTRIBUTOR_INTEGRATION.md)
- **Workflow Guide:** See [BOM_VALIDATION_WORKFLOW.md](./BOM_VALIDATION_WORKFLOW.md)

## Screenshots Reference Guide

While this guide describes the process in detail, here's where screenshots would be particularly helpful:

1. **Nexar Homepage**
   - Location of Sign Up button
   - Account type selection screen

2. **Email Verification**
   - Example of verification email
   - Where to click to verify

3. **Applications Dashboard**
   - Overview of dashboard layout
   - Where to find "Create Application" button
   - Example of application list

4. **Create Application Form**
   - All form fields filled out
   - Dropdown selections
   - Submit button location

5. **Credentials Display**
   - Client ID field with copy button
   - Client Secret field (hidden and revealed)
   - Warning message about saving secret

6. **File Location**
   - Example showing .env file in correct directory
   - File explorer view with extensions visible

7. **Successful Configuration**
   - Claude responding with distributor data
   - Example of successful API response

## Quick Reference Card

Keep this handy during setup:

```
NEXAR API SETUP QUICK REFERENCE
================================

1. Create account: https://nexar.com
2. Verify email
3. Go to: Applications → Create New Application
4. Copy: Client ID and Client Secret
5. Create file: server/.env
6. Add lines:
   NEXAR_CLIENT_ID=your_client_id
   NEXAR_CLIENT_SECRET=your_secret
7. Save file
8. Restart Claude Desktop
9. Test: "Check availability for LM358N"

Important:
- Keep Client Secret private
- No spaces around = in .env file
- File must be named .env exactly
- Restart Claude Desktop after changes
```

## Next Steps

Once you've completed this setup:

1. Read [DISTRIBUTOR_INTEGRATION.md](./DISTRIBUTOR_INTEGRATION.md) to learn about all available features
2. Review [BOM_VALIDATION_WORKFLOW.md](./BOM_VALIDATION_WORKFLOW.md) for practical workflows
3. Try checking availability for a component in your current design
4. Explore pricing and alternative part finding features

Happy designing!
