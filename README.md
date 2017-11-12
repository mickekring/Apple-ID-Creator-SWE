Apple-ID-Creator-Sweden
==========================

### UPDATE: Nov 12, 2017 - No support on this project
I haven't used this since 2015 which means I haven't updated it either. I'll let it live here for a while longer though...


This is a fork of garrya100's great script adapted and changed for use with the Swedish version of iTunes.<br />
Please show your appreciation of the amount of work that has gone into this by making a donation to a charity of your choice.

You use this script at your own risk. There are no warranties, direct or implied.

### TRIED AND TESTED SETUP
OSX version: Yosemite 10.10.2<br />
iTunes version: 12.1.0.50

### REQUIREMENTS
- <strong>IMPORTANT:</strong> Apple uses a velocity check to prevent too many Apple IDs from a single IP address. You must contact your Apple business representative to request that your IP address is whitelisted for a short time.
- Being AppleScript, this runs only on Macs.
- iTunes 12.1.0.50 is currently tried and tested on Yosemite 10.10.2. Future versions may break the script.
- UI Scripting allows us to script otherwise non-scriptbale interfaces. Read the popup window and follow instructions, when running the script.
- Apple has strong password requirements. Account creation will fail if the passwords are too weak.
- Since this involves international characters, be sure that your csv file handles å,ä and ö correctly.

### HOW TO
- Download the zip file and extract to a location of your choice.
- Edit the UserID-template.xlsx file in Excel and add your desired account information. Leave the empty columns empty.</br>
Save/export the file as a .csv file (comma separated). On OSX with swedish regional settings this will generate a semi colon separated text file.
- Run the AppleScript and point to your .csv file when asked for. If the file is correct, sit back and enjoy.

### KNOWN BUGS
Sometimes the script aborts. Just close iTunes and the script and start again. If some of the accounts have already been created, edit those out of your .csv file.
