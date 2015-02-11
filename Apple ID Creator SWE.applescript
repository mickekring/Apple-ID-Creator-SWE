property iTunesCountryCode : "SWE" --set for error trap set for those don't know they need to set the localisation, comment this one out when the locale is set

--declare localisation variables here
global ibooksLinkLocation
global curCheckBox
global curExpectedElementString
global curExpectedElementLocation
global curTermsExpectedElementString
global curTermsExpectedElementLocation
global noOfResponses
global curCheckBoxNum
global curMonthPos
global curDayPos
global enableTitle
global curTitlePos
global curUserNameGroupPos
global curAddressGroupPos
global curCityFieldName
global curCityFieldPos
global curCityGroupPos
global enableCounty
global curCountyPos
global enableProvince
global curProvincePos
global curProvinceGroup
global enableState
global curStateGroup
global curStatePos
global enablePostcode
global curPostalCodeFieldName
global curPostalCodeFieldPos
global curPostalCodeFieldGroup
global curPhoneGroup
global curAreaCode
global curPhonePos

--Used for storing a list of encountered errors. Written to by various handlers, read by checkForErrors()
global errorList
set errorList to {}

--Used for controlling the running or abortion of the script. Handler will run as long as scriptAction is "Continue". Can also be set to "Abort" to end script, or "Skip User" to skip an individual user.
global scriptAction
set scriptAction to "Continue"

--Store the current user number (based off line number in CSV file)
global currentUser
set currentUserNumber to 0

--Used for completing every step in the process, except actually creating the Apple ID. Also Pauses the script at various locations so the user can verify everything is working properly.
property dryRun : true


--Master delay timer for slowing the script down at specified sections. Usefull for tweaking the entire script's speed
property masterDelay : 1

--Maximum time (in seconds) the script will wait for a page to load before giving up and throwing an error
property netDelay : 30

--Used at locations in script that will be vulnerable to slow processing. Multiplied by master delay. Tweak for slow machines. May be added to Net Delay.
property processDelay : 1

--How often should the script check that something has loaded/is ready
property checkFrequency : 0.5

--Used to store supported iTunes versions
property supportedItunesVersions : {"12.1.0"}
property supportedOSVersions : {"10.10.2"}

--Used for checking if iTunes is loading a page
property itunesAccessingString : "Accessing iTunes Store…"

--Used for error checking Page 1 if email address or password is rejected. Simply counts the elements and it the warning box pops up UI elements increase by one
global elementCountDefault
set elementCountDefault to 0
global elementPasswordCountDefault
set elementPasswordCountDefault to 0
global elementEmailCountDefault
set elementEmailCountDefault to 0


--Start localistaion settings

if iTunesCountryCode is "SWE" then
	set ibooksLinkLocation to "itms://itunes.apple.com/se/app/ibooks/id364709193?mt=8"
	set curExpectedElementString to "Välkommen till iTunes Store"
	set curExpectedElementLocation to "Välkommen till iTunes Store"
	set curTermsExpectedElementString to "Villkor och Apples integritetspolicy"
	set curTermsExpectedElementLocation to "Villkor och Apples integritetspolicy"
	set curCheckBox to 1
	set curCheckBoxNum to 6
	set noOfResponses to 5
	set curMonthPos to 2
	set curDayPos to 1
	set enableTitle to false
	set curTitlePos to 7
	set curUserNameGroupPos to 8
	set curAddressGroupPos to 9
	set curCityFieldName to "Town"
	set curCityFieldPos to 2
	set curCityGroupPos to 10
	set enableProvince to false
	set enableCounty to false
	set enableState to false
	set curStateGroup to 11
	set curStatePos to 2
	set enablePostcode to true
	set curPostalCodeFieldName to "Postcode"
	set curPostalCodeFieldPos to 1
	set curPostalCodeFieldGroup to 10
	set curPhoneGroup to 11
	set curAreaCode to true
	set curPhonePos to 2
end if

-- only functions below this point, and data for iTunes "Get" button

(*
	Email
	Password
	Secret Question 1
	Secret Answer 1
	Secret Question 2
	Secret Answer 2
	Secret Question 3
	Secret Answer 3
	Month Of Birth
	Day Of Birth
	Year Of Birth
	First Name
	Last Name
	Address Street
	Address City
	Address State
	Address Zip
	Phone Area Code
	Phone Number
	Account Status
*)

--Properties for storing possible headers to check the source CSV file for. Source file will be checked for each of the items to locate the correct columns

property emailHeaders : {"Email", "Email Address"}
property passwordHeaders : {"Password", "Pass"}
property secretQuestion1Headers : {"Secret Question 1"}
property secretAnswer1Headers : {"Secret Answer 1"}
property secretQuestion2Headers : {"Secret Question 2"}
property secretAnswer2Headers : {"Secret Answer 2"}
property secretQuestion3Headers : {"Secret Question 3"}
property secretAnswer3Headers : {"Secret Answer 3"}
property monthOfBirthHeaders : {"Month", "Birth Month", "Month of Birth"}
property dayOfBirthHeaders : {"Day", "Birth Day", "Day Of Birth"}
property yearOfBirthHeaders : {"Year", "Birth Year", "Year Of Birth"}
property firstNameHeaders : {"First Name", "First", "fname"}
property lastNameHeaders : {"Last Name", "Last", "lname"}
property addressStreetHeaders : {"Street", "Street Address", "Address Street"}
property addressCityHeaders : {"City", "Address City"}
property addressStateHeaders : {"State", "Address State"}
property addressZipHeaders : {"Zip Code", "Zip", "Address Zip"}
property phoneAreaCodeHeaders : {"Area Code", "Phone Area Code"}
property phoneNumberHeaders : {"Phone Number", "Phone"}
property rescueEmailHeaders : {"Rescue Email (Optional)", "Rescue Email"}
property accountStatusHeaders : {"Account Status"} --Used to keep track of what acounts have been created


--Supported descriptions of iTunes free button

property supportedFreeButtonDescriptions : {"Hämta, iBooks", "Hämta", "Get, iBooks", "Get, iBooks", "0,00 kr Get, iBooks", "0,00 kr Hämta, iBooks", "0,00 kr Hämta"}

set userDroppedFile to false

--Check to see if a file was dropped on this script
on open droppedFile
	set userDroppedFile to true
	MainMagic(userDroppedFile, droppedFile)
end open

--Launch the script in interactive mode if no file was dropped (if file was dropped on script, this will never be run, because of the "on open" above)
set droppedFile to ""
MainMagic(userDroppedFile, droppedFile)

--Main Function

on MainMagic(userDroppedFile, droppedFile)
	
	--Donation Nag, maybe I can encourage a little good in the world!
	
	set scriptAction to button returned of (display dialog "This script is donation ware. If you use this script, consider the many hours of work contributed by many people. " & return & return & "Show your appreciation by making a donation to a charity of your choice" buttons {"Continue"} default button "Continue") as text
	
	--Check OS Version
	
	set OSVersion to system version of (system info)
	set OSVersionIsSupported to false
	
	repeat with versionOSCheckLoopCounter from 1 to (count of items in supportedOSVersions)
		if item versionOSCheckLoopCounter of supportedOSVersions is equal to OSVersion then
			set OSVersionIsSupported to true
			exit repeat
		end if
	end repeat
	
	if OSVersionIsSupported is false then
		
		set scriptAction to button returned of (display dialog "OSX is at version " & OSVersion & return & return & "It is unknown if this version of OSX will work with this script." & return & return & "You may abort now, or try running the script anyway." buttons {"Abort", "Continue"} default button "Abort") as text
		
	end if
	
	
	--Check iTunes Version
	
	
	set itunesVersion to version of application "iTunes"
	set itunesVersionIsSupported to false
	
	repeat with versionCheckLoopCounter from 1 to (count of items in supportedItunesVersions)
		if item versionCheckLoopCounter of supportedItunesVersions is equal to itunesVersion then
			set itunesVersionIsSupported to true
			exit repeat
		end if
	end repeat
	
	if itunesVersionIsSupported is false then
		set scriptAction to button returned of (display dialog "iTunes is at version " & itunesVersion & return & return & "It is unknown if this version of iTunes will work with this script." & return & return & "You may abort now, or try running the script anyway." buttons {"Abort", "Continue"} default button "Abort") as text
	end if
	
	if scriptAction is "Continue" then
		
		--Load user file
		
		set usersFile to loadUsersFile(userDroppedFile, droppedFile) --Load the users file. Returns a list of columns from the source file
		
		if scriptAction is "Continue" then
			--Split out header information from each of the columns
			set headers to {}
			
			repeat with headerRemoverLoopCounter from 1 to (count of items in usersFile)
				
				set headers to headers & "" --Add an empty item to headers
				
				set item headerRemoverLoopCounter of headers to item 1 of item headerRemoverLoopCounter of usersFile --Save the header from the column
				
				set item headerRemoverLoopCounter of usersFile to (items 2 thru (count of items in item headerRemoverLoopCounter of usersFile) of item headerRemoverLoopCounter of usersFile) --Remove the header from the column
				
			end repeat
			
			set userCount to (count of items in item 1 of usersFile) --Counts the number of users
			
			--seperated column contents (not really necessarry, but it makes everything else a whole lot more readable)
			set appleIdEmailColumnContents to item 1 of usersFile
			set appleIdPasswordColumnContents to item 2 of usersFile
			
			set appleIdSecretQuestion1ColumnContents to item 3 of usersFile
			set appleIdSecretAnswer1ColumnContents to item 4 of usersFile
			set appleIdSecretQuestion2ColumnContents to item 5 of usersFile
			set appleIdSecretAnswer2ColumnContents to item 6 of usersFile
			set appleIdSecretQuestion3ColumnContents to item 7 of usersFile
			set appleIdSecretAnswer3ColumnContents to item 8 of usersFile
			set monthOfBirthColumnContents to item 9 of usersFile
			set dayOfBirthColumnContents to item 10 of usersFile
			set yearOfBirthColumnContents to item 11 of usersFile
			
			set userFirstNameColumnContents to item 12 of usersFile
			set userLastNameColumnContents to item 13 of usersFile
			set addressStreetColumnContents to item 14 of usersFile
			set addressCityColumnContents to item 15 of usersFile
			set addressStateColumnContents to item 16 of usersFile
			set addressZipColumnContents to item 17 of usersFile
			set phoneAreaCodeColumnContents to item 18 of usersFile
			set phoneNumberColumnContents to item 19 of usersFile
			set appleIdRescueColumnContents to item 20 of usersFile
			set accountStatusColumnContents to item 21 of usersFile
			
			
			
			
			--Ask user if they want to perform a dry run, and give them a chance to cancel
			
			
			set scriptRunMode to button returned of (display dialog "Would you like to preform a ''dry run'' of the script?" & return & return & "A ''dry run'' will run through every step, EXCEPT actually creating the Apple IDs." buttons {"Actually Create Apple IDs", "Dry Run", "Cancel"}) as text
			if scriptRunMode is "Actually Create Apple IDs" then set dryRun to false
			if scriptRunMode is "Dry Run" then set dryRun to true
			if scriptRunMode is "Cancel" then set scriptAction to "Abort"
			
			--Create ID's
			
			if scriptAction is not "Abort" then
				set accountStatusSetByCurrentRun to {}
				set currentUserNumber to 0
				repeat with loopCounter from 1 to userCount
					
					--Increment our current user, just so other handlers can know what user we are on
					set currentUserNumber to currentUserNumber + 1
					
					--Get a single user's information from the column contents
					set appleIdEmail to item loopCounter of appleIdEmailColumnContents
					set appleIdPassword to item loopCounter of appleIdPasswordColumnContents
					
					set appleIdSecretQuestion1 to item loopCounter of appleIdSecretQuestion1ColumnContents
					set appleIdSecretAnswer1 to item loopCounter of appleIdSecretAnswer1ColumnContents
					set appleIdSecretQuestion2 to item loopCounter of appleIdSecretQuestion2ColumnContents
					set appleIdSecretAnswer2 to item loopCounter of appleIdSecretAnswer2ColumnContents
					set appleIdSecretQuestion3 to item loopCounter of appleIdSecretQuestion3ColumnContents
					set appleIdSecretAnswer3 to item loopCounter of appleIdSecretAnswer3ColumnContents
					set rescueEmail to item loopCounter of appleIdRescueColumnContents
					set monthOfBirth to item loopCounter of monthOfBirthColumnContents
					set dayOfBirth to item loopCounter of dayOfBirthColumnContents
					set yearOfBirth to item loopCounter of yearOfBirthColumnContents
					
					set userFirstName to item loopCounter of userFirstNameColumnContents
					set userLastName to item loopCounter of userLastNameColumnContents
					set addressStreet to item loopCounter of addressStreetColumnContents
					set addressCity to item loopCounter of addressCityColumnContents
					set addressState to item loopCounter of addressStateColumnContents
					set addressZip to item loopCounter of addressZipColumnContents
					set phoneAreaCode to item loopCounter of phoneAreaCodeColumnContents
					set phoneNumber to item loopCounter of phoneNumberColumnContents
					set accountStatus to item loopCounter of accountStatusColumnContents
					
					delay masterDelay
					
					--Signout Apple ID that is currently signed in (if any)
					
					
					SignOutItunesAccount()
					
					--Go to the iBooks App page location to kick off Apple ID creation with no payment information
					installIbooks()
					
					
					delay 1 --Fix so iTunes is properly tested for, instead of just manually delaying
					
					repeat
						set lcdStatus to GetItunesStatusUntillLcd("Does Not Match", itunesAccessingString, 4, "times. Check for:", 120, "intervals of", 0.25, "seconds") ------------------------Wait for iTunes to open (if closed) and the iBooks page to load
						if lcdStatus is "Matched" then exit repeat
						delay masterDelay
					end repeat
					
					--Checks for errors that may have been thrown by previous handler					
					
					CheckForErrors()
					
					--If an error was detected and the user chose to abort, then end the script					
					if scriptAction is "Abort" then exit repeat
					
					--Click "create Apple ID" button on pop-up window
					
					
					ClickCreateAppleIDButton()
					
					--Click "Continue" on the page with the title "Welcome to the iTunes Store"
					
					ClickContinueOnPageOne()
					
					---Checks for errors that may have been thrown by previous handler					  
					CheckForErrors()
					
					--If an error was detected and the user chose to abort, then end the script
					
					if scriptAction is "Abort" then exit repeat
					
					--Check the "I have read and agreed" box and then the "Agree" button					
					AgreeToTerms()
					
					--Checks for errors that may have been thrown by previous handler
					
					
					CheckForErrors()
					
					--If an error was detected and the user chose to abort, then end the script
					
					if scriptAction is "Abort" then exit repeat
					
					
					--Fills the first page of apple ID details. Birth Month is full text, like "January". Birth Day and Birth Year are numeric. Birth Year is 4 digit
					
					log {"Creating ", appleIdEmail}
					
					ProvideAppleIdDetails(appleIdEmail, appleIdPassword, appleIdSecretQuestion1, appleIdSecretAnswer1, appleIdSecretQuestion2, appleIdSecretAnswer2, appleIdSecretQuestion3, appleIdSecretAnswer3, rescueEmail, monthOfBirth, dayOfBirth, yearOfBirth)
					
					--Set Errors for Page One faults
					
					if elementCountDefault < elementPasswordCountDefault then set errorList to errorList & ("Password set has failed")
					
					if elementCountDefault < elementEmailCountDefault then set errorList to errorList & ("Email set has failed")
					
					
					
					
					--Checks for errors that may have been thrown by previous handler
					
					CheckForErrors()
					
					--If an error was detected and the user chose to abort, then end the script
					
					if scriptAction is "Abort" then exit repeat
					
					--Fill payment details, without credit card info
					
					
					ProvidePaymentDetails(userFirstName, userLastName, addressStreet, addressCity, addressState, addressZip, phoneAreaCode, phoneNumber)
					
					--Checks for errors that may have been thrown by previous handler
					
					CheckForErrors()
					
					--If an error was detected and the user chose to abort, then end the script
					
					
					if scriptAction is "Abort" then exit repeat
					
					
					if scriptAction is "Continue" then
						
						--If user was successfully created mark user as created
						
						set accountStatusSetByCurrentRun to accountStatusSetByCurrentRun & ""
						set item loopCounter of accountStatusSetByCurrentRun to "Created"
					end if
					
					--If a user was skipped...
					--Mark user as "Skipped"
					
					if scriptAction is "Skip User" then
						set accountStatusSetByCurrentRun to accountStatusSetByCurrentRun & ""
						set item loopCounter of accountStatusSetByCurrentRun to "Skipped"
						
						--Set the Script back to "Continue" mode
						
						set scriptAction to "Continue"
					end if
					
					if scriptAction is "Stop" then exit repeat
					
				end repeat
				
				--Display dialog boxes that confirm the exit status of the script
				
				activate
				if scriptAction is "Abort" then display dialog "Script was aborted" buttons {"OK"}
				if scriptAction is "Stop" then display dialog "Dry run completed" buttons {"OK"}
				if scriptAction is "Continue" then display dialog "Script Completed Successfully" buttons {"OK"}
				
				
				--Fix for multiple positive outcomes
				if itunesVersionIsSupported is false then --If the script was run against an unsupported version of iTunes...
					if scriptAction is "Continue" then --And it wasn't aborted...
						if button returned of (display dialog "Would you like to add iTunes Version " & itunesVersion & " to the list of supported iTunes versions?" buttons {"Yes", "No"} default button "No") is "Yes" then --...then ask the user if they want to add the current version of iTunes to the supported versions list
							set supportedItunesVersions to supportedItunesVersions & itunesVersion
							display dialog "iTunes version " & itunesVersion & " succesfully added to list of supported versions."
						end if
					end if
				end if
				
				if OSVersionIsSupported is false then --If the script was run against an unsupported version of iTunes...
					if scriptAction is "Continue" then --And it wasn't aborted...
						if button returned of (display dialog "Would you like to add iTunes Version " & OSVersion & " to the list of supported iTunes versions?" buttons {"Yes", "No"} default button "No") is "Yes" then --...then ask the user if they want to add the current version of iTunes to the supported versions list
							set supportedOSVersions to supportedOSVersions & OSVersion
							display dialog "iTunes version " & OSVersion & " succesfully added to list of supported versions."
						end if
					end if
				end if
			end if
		end if
	end if
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------End main function
	
end MainMagic

(*_________________________________________________________________________________________________________________________________________*)

--Functions

on loadUsersFile(userDroppedFile, chosenFile)
	if userDroppedFile is false then set chosenFile to "Choose"
	set readFile to ReadCsvFile(chosenFile) --Open the CSV file and read its raw contents
	set readFile to ParseCsvFile(readFile) --Parse the values into a list of lists
	
	set listOfColumnsToFind to {"Email", "Password", "Secret Question 1", "Secret Answer 1", "Secret Question 2", "Secret Answer 2", "Secret Question 3", "Secret Answer 3", "Month Of Birth", "Day Of Birth", "Year Of Birth", "First Name", "Last Name", "Address Street", "Address City", "Address State", "Address Zip", "Phone Area Code", "Phone Number", "Rescue Email (Optional)", "Account Status"}
	
	--Locate the columns in the file
	set findResults to {}
	repeat with columnFindLoopCounter from 1 to (count of items in listOfColumnsToFind)
		set findResults to findResults & ""
		set item columnFindLoopCounter of findResults to findColumn((item columnFindLoopCounter of listOfColumnsToFind), readFile) --FindColumn Returns a list of two items. The first item is either "Found" or "Not Found". The second item (if the item was "found") will be a numerical reference to the column that was found, based on its position in the source file
	end repeat
	
	--Verify that the columns were found, and resolve any missing columns
	repeat with columnVerifyLoopCounter from 1 to (count of items in findResults)
		if scriptAction is "Continue" then
			if item 1 of item columnVerifyLoopCounter of findResults is "Found" then --Check if the current item to be located was found
				set item columnVerifyLoopCounter of findResults to item 2 of item columnVerifyLoopCounter of findResults --Remove the verification information and set the item to just the column number
			else --If a column is missing
				--Ask the user what they would like to do
				set missingColumnResolution to button returned of (display dialog "The script was unable to locate the " & item columnVerifyLoopCounter of listOfColumnsToFind & " column. The script cannot continue without this information." & return & return & "What would you like to do?" buttons {"Abort Script", "Manually Locate Column"}) as text
				
				--If the user chose to abort
				if missingColumnResolution is "Abort Script" then set scriptAction to "Abort"
				
				--If the user chose to manually locate the column
				if missingColumnResolution is "Manually Locate Column" then
					--Create a list of the columns to choose from, complete with a number at the beginning of each item in the list
					set columnList to {}
					repeat with createColumnListLoopCounter from 1 to (count of items in readFile) --Each loop will create an entry in the list of choices corresponding to the first row of a column in the original source file
						set columnList to columnList & ((createColumnListLoopCounter as text) & " " & item 1 of item createColumnListLoopCounter of readFile) --Dynamically add an incremented number and space to the beginning of each item in the list of choices, and then add the contents of the first row of the column chosen for this loop
					end repeat
					
					--Present the list of column choices to the user
					set listChoice to choose from list columnList with prompt "Which of the items below is an example of ''" & item columnVerifyLoopCounter of listOfColumnsToFind & "''" --Ask user which of the choices matches what we are looking for
					if listChoice is false then --If the user clicked cancel in the list selection dialog box
						set scriptAction to "Abort"
					else
						set item columnVerifyLoopCounter of findResults to (the first word of listChoice as number) --Set the currently evaluating entry of findResults to the column NUMBER (determined by getting the first word of list choice, which corresponds to column numbers) the user selected
					end if
				end if
				
			end if
		else --If an abort has been thrown
			exit repeat
		end if
	end repeat
	
	--Retrieve the contents of the found columns
	if scriptAction is "Continue" then
		set fileContents to {}
		repeat with contentRetrievalLoopCounter from 1 to (count of items in findResults)
			set fileContents to fileContents & ""
			set item contentRetrievalLoopCounter of fileContents to getColumnContents((item contentRetrievalLoopCounter of findResults), readFile)
		end repeat
	end if
	
	if scriptAction is "Continue" then
		return fileContents
	end if
	
end loadUsersFile

on findColumn(columnToFind, fileContents)
	
	--BEGIN FIND EMAIL																							
	if columnToFind is "Email" then
		return findInList(emailHeaders, fileContents)
	end if
	
	--BEGIN FIND PASSWORD																						
	if columnToFind is "Password" then
		return findInList(passwordHeaders, fileContents)
	end if
	
	--BEGIN FIND SECRET QUESTION																				
	if columnToFind is "Secret Question 1" then
		return findInList(secretQuestion1Headers, fileContents)
	end if
	
	--BEGIN FIND SECRET ANSWER																					
	if columnToFind is "Secret Answer 1" then
		return findInList(secretAnswer1Headers, fileContents)
	end if
	
	--BEGIN FIND SECRET QUESTION 2																				
	if columnToFind is "Secret Question 2" then
		return findInList(secretQuestion2Headers, fileContents)
	end if
	
	--BEGIN FIND SECRET ANSWER 2																					
	if columnToFind is "Secret Answer 2" then
		return findInList(secretAnswer2Headers, fileContents)
	end if
	
	--BEGIN FIND SECRET QUESTION  3																				
	if columnToFind is "Secret Question 3" then
		return findInList(secretQuestion3Headers, fileContents)
	end if
	
	--BEGIN FIND SECRET ANSWER 3																					
	if columnToFind is "Secret Answer 3" then
		return findInList(secretAnswer3Headers, fileContents)
	end if
	
	--BEGIN FIND BIRTH MONTH 																					
	if columnToFind is "Month Of Birth" then
		return findInList(monthOfBirthHeaders, fileContents)
	end if
	
	--BEGIN FIND BIRTH DAY 																						
	if columnToFind is "Day Of Birth" then
		return findInList(dayOfBirthHeaders, fileContents)
	end if
	
	--BEGIN FIND BIRTH YEAR 																						
	if columnToFind is "Year Of Birth" then
		return findInList(yearOfBirthHeaders, fileContents)
	end if
	
	--BEGIN FIND LAST NAME																						
	if columnToFind is "First Name" then
		return findInList(firstNameHeaders, fileContents)
	end if
	
	--BEGIN FIND LAST NAME																						
	if columnToFind is "Last Name" then
		return findInList(lastNameHeaders, fileContents)
	end if
	
	--BEGIN FIND ADDRESS STREET																				
	if columnToFind is "Address Street" then
		return findInList(addressStreetHeaders, fileContents)
	end if
	
	--BEGIN FIND ADDRESS CITY																					
	if columnToFind is "Address City" then
		return findInList(addressCityHeaders, fileContents)
	end if
	
	--BEGIN FIND ADDRESS STATE																					
	if columnToFind is "Address State" then
		return findInList(addressStateHeaders, fileContents)
	end if
	
	--BEGIN FIND ADDRESS ZIP																					
	if columnToFind is "Address Zip" then
		return findInList(addressZipHeaders, fileContents)
	end if
	
	--BEGIN FIND PHONE AREA CODE																				
	if columnToFind is "Phone Area Code" then
		return findInList(phoneAreaCodeHeaders, fileContents)
	end if
	
	--BEGIN FIND PHONE NUMBER																					
	if columnToFind is "Phone Number" then
		return findInList(phoneNumberHeaders, fileContents)
	end if
	
	--BEGIN FIND RESCUE EMAIL																					
	if columnToFind is "Rescue Email (Optional)" then
		return findInList(rescueEmailHeaders, fileContents)
	end if
	
	--BEGIN FIND ACCOUNT STATUS																				
	if columnToFind is "Account Status" then
		return findInList(accountStatusHeaders, fileContents)
	end if
	
end findColumn

-----------------------------------------

on findInList(matchList, listContents)
	try
		set findState to "Not Found"
		set findLocation to 0
		repeat with columnItemLoopCounter from 1 to (count of items of (item 1 of listContents))
			repeat with testForMatchLoopCounter from 1 to (count of matchList)
				if item columnItemLoopCounter of (item 1 of listContents) is item testForMatchLoopCounter of matchList then
					set findState to "Found"
					set findLocation to columnItemLoopCounter
					exit repeat
				end if
			end repeat
			if findState is "Found" then exit repeat
		end repeat
		return {findState, findLocation} as list
	on error
		display dialog "Hmm Well, I was looking for something in the file, and something went wrong." buttons "Bummer"
		return 0
	end try
end findInList

-----------------------------------------

--BEGIN GET COLUMN CONTENTS																								
on getColumnContents(columnToGet, fileContents)
	set columnContents to {}
	repeat with loopCounter from 1 to (count of items of fileContents)
		set columnContents to columnContents & 1
		try
			set item loopCounter of columnContents to item columnToGet of item loopCounter of fileContents
		on error theError
			display alert "Data row parsing error. Remove empty or invalid row at line: " & loopCounter buttons ("Stop script and edit csv manually") default button 1
			error number -128
		end try
	end repeat
	return columnContents
end getColumnContents

-----------------------------------------

on ReadCsvFile(chosenFile)
	--Check to see if we are being passed a method instead of a file to open
	set method to ""
	try
		if chosenFile is "Choose" then
			set method to "Choose"
		end if
	end try
	
	try
		if method is "Choose" then
			set chosenFile to choose file
		end if
		
		set fileOpened to (characters 1 thru -((count every item of (name extension of (info for chosenFile))) + 2) of (name of (info for chosenFile))) as string
		set testResult to TestCsvFile(chosenFile)
		
		if testResult is yes then
			set openFile to open for access chosenFile
			set fileContents to read chosenFile
			close access openFile
			return fileContents
		end if
		
	on error
		
		--Clean up properly and abort
		
		set scriptAction to button returned of (display dialog "Data file load was cancelled" buttons {"Abort"} default button "Abort") as text
	end try
end ReadCsvFile

-----------------------------------------

on TestCsvFile(chosenFile)
	set chosenFileKind to type identifier of (info for chosenFile)
	if chosenFileKind is "CSV Document" then
		return yes
	else
		if chosenFileKind is "public.comma-separated-values-text" then
			return yes
		else
			display dialog "Silly " & (word 1 of the long user name of (system info)) & ", that file is not a .CSV!" buttons "Oops, my bad"
			return no
		end if
	end if
end TestCsvFile

-----------------------------------------

on ParseCsvFile(fileContents)
	try
		set parsedFileContents to {} --Instantiate our list to hold parsed file contents
		set delimitersOnCall to AppleScript's text item delimiters --Copy the delimiters that are in place when this handler was called
		set AppleScript's text item delimiters to "," --Set delimiter to commas
		
		--Parse each line (paragraph) from the unparsed file contents
		set lineCount to (count of paragraphs in fileContents)
		repeat with loopCounter from 1 to lineCount --Loop through each line in the file, one at a time
			set parsedFileContents to parsedFileContents & 1 --Add a new item to store the parsed paragraph
			set item loopCounter of parsedFileContents to (every text item of paragraph loopCounter of fileContents) --Parse a line from the file into individual items and store them in the item created above
		end repeat
		
		set AppleScript's text item delimiters to delimitersOnCall --Set Applescript's delimiters back to whatever they were when this handler was called
		return parsedFileContents --Return our fancy parsed contents
	on error
		display dialog "Woah! Um, that's not supposed to happen." & return & return & "Something goofed up bad when I tried to read the file!" buttons "Ok, I'll take a look at the file"
		return fileContents
	end try
end ParseCsvFile

-----------------------------------------

on verifyPage(expectedElementString, expectedElementLocation, expectedElementCount, verificationTimeout, requiresGroup)
	tell application "System Events"
		--
		
		my GetItunesStatusUntillLcd("Does Not Match", itunesAccessingString, 4, "times. Check for:", (verificationTimeout * (1 / checkFrequency)), "intervals of", checkFrequency, "seconds")
		(*repeat
			set lcdStatus to my GetItunesStatusUntillLcd("Does Not Match", itunesAccessingString, 4, "times. Check for:", (verificationTimeout * (1 / checkFrequency)), "intervals of", checkFrequency, "seconds")
			if lcdStatus is "Matched" then exit repeat
			delay masterDelay
		end repeat*)
		
		set elementCount to count every UI element of UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
		
		repeat with timeoutLoopCounter from 1 to verificationTimeout --Loop will be ended before reaching verificationTimeout if the expectedElementString is successfully located
			
			if timeoutLoopCounter is equal to verificationTimeout then return "unverified"
			
			if expectedElementCount is 0 then set expectedElementCount to elementCount --Use 0 to disable element count verification
			
			if expectedElementCount is not elementCount then set expectedElementCount to elementCount --Check all countable elements
			
			if elementCount is equal to expectedElementCount then
				set everyTitle to {}
				
				if requiresGroup then
					set elementToTest to UI element expectedElementLocation of group 2 of UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
				else
					set elementToTest to UI element expectedElementLocation of UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
				end if
				
				set elementProperties to properties of elementToTest
				
				try
					set elementString to title of elementProperties
					--set elementString to (text items 1 through (count of text items in expectedElementString) of elementString) as string
				end try
				
				if elementString is equal to expectedElementString then
					return "verified"
				end if
			end if
			delay 1
		end repeat
	end tell
end verifyPage

-----------------------------------------

on CheckForErrors()
	if scriptAction is "Continue" then --This is to make sure a previous abort hasn't already been thrown.
		if errorList is not {} then --If there are errors in the list
			tell application "Script Editor" to activate
			
			set errorAction to button returned of (display dialog "Errors were detected. What would you like to do?" buttons {"Abort", "Review"} default button "Review") as string
			
			if errorAction is "Abort" then
				set scriptAction to "Abort" --This sets the global abort action
				return "Abort" --This breaks out of the remainder of the error checker
			end if
			
			if errorAction is "Review" then
				repeat with loopCounter from 1 to (count of items in errorList) --Cycle through all the errors in the list
					if errorAction is "Abort" then
						set scriptAction to "Abort" --This sets the global abort action
						return "Abort" --This breaks out of the remainder of the error checker
					else
						set errorAction to button returned of (display dialog "Showing error " & loopCounter & " of " & (count of items in errorList) & ":" & return & return & item loopCounter of errorList & return & return & "What would you like to do?" buttons {"Abort", "Manually Correct"} default button "Manually Correct") as string
						if errorAction is "Manually Correct" then set errorAction to button returned of (display dialog "Click continue when the error has been corrected." & return & "If you cannot correct the error, then you may skip this user or abort the entire script" buttons {"Abort", "Skip User", "Continue"} default button "Continue") as string
					end if
				end repeat
				set errorList to {} --Clear errors if we've made it all the way through the loops
				set scriptAction to errorAction
			end if
			
		end if --for error check
	end if --for abort check
end CheckForErrors

-----------------------------------------

on SignOutItunesAccount()
	if scriptAction is "Continue" then --This is to make sure an abort hasn't been thrown
		tell application "System Events"
			--Tell iTunes to open iBooks. Still submits information to Apple but moves the script along much faster
			tell application "iTunes" to open location ibooksLinkLocation
			delay masterDelay
			
			
			
			set storeMenu to menu "Affär" of menu bar item "Affär" of menu bar 1 of application process "iTunes"
			set storeMenuItems to title of every menu item of storeMenu
		end tell
		
		repeat with loopCounter from 1 to (count of items in storeMenuItems)
			if item loopCounter of storeMenuItems is "Logga ut" then
				tell application "System Events"
					click menu item "Logga ut" of storeMenu
				end tell
			end if
		end repeat
	end if
end SignOutItunesAccount

-----------------------------------------

on GetItunesStatusUntillLcd(matchType, stringToMatch, matchDuration, "times. Check for:", checkDuration, "intervals of", checkFrequency, "seconds")
	set loopCounter to 0
	set matchedFor to 0
	set itunesLcdText to {}
	
	repeat
		set loopCounter to loopCounter + 1
		
		if loopCounter is greater than or equal to (checkDuration * checkFrequency) then
			return "Unmatched"
		end if
		
		set itunesLcdText to itunesLcdText & ""
		tell application "System Events"
			try
				--set item loopCounter of itunesLcdText to value of static text 1 of scroll area 1 of window 1 of application process "iTunes"
				set item loopCounter of itunesLcdText to value of static text 1 of scroll area 1 of window 1 of application process "iTunes"
			end try
		end tell
		
		if matchType is "Matches" then
			if item loopCounter of itunesLcdText is stringToMatch then
				set matchedFor to matchedFor + 1
			else
				set matchedFor to 0
			end if
		end if
		
		if matchType is "Does Not Match" then
			if item loopCounter of itunesLcdText is not stringToMatch then
				set matchedFor to matchedFor + 1
			else
				set matchedFor to 0
			end if
		end if
		
		if matchedFor is greater than or equal to matchDuration then
			return "Matched"
		end if
		delay checkFrequency
	end repeat
	
end GetItunesStatusUntillLcd

-----------------------------------------

on installIbooks()
	delay (masterDelay * processDelay)
	if scriptAction is "Continue" then --This is to make sure an abort hasn't been thrown
		
		tell application "iTunes" to open location ibooksLinkLocation
		delay (masterDelay * processDelay)
		set pageVerification to verifyPage("iBooks", "iBooks", 42, netDelay, true) --Looking for "iBooks", in the second element, on a page with a count of 39 elements, with a timeout of 5, and it requires the use of "group 1" for checking
		
		if pageVerification is "verified" then --Actually click the button to obtain iBooks
			delay (masterDelay * processDelay)
			tell application "System Events"
				try
					set freeButton to button 1 of group 3 of UI element 1 of scroll area 1 of splitter group 1 of window "iTunes" of application process "iTunes"
					
					-- check if free button is supported
					set freeButtonDescription to description of freeButton
					set freeButtonDescriptionIsSupported to false
					repeat with freeButtonCheckLoopCounter from 1 to (count of items in supportedFreeButtonDescriptions)
						if item freeButtonCheckLoopCounter of supportedFreeButtonDescriptions is equal to freeButtonDescription then
							set freeButtonDescriptionIsSupported to true
							exit repeat
						end if
					end repeat
					
					if freeButtonDescriptionIsSupported is true then
						click freeButton
					else
						set errorList to errorList & "Unable to locate supported free button by its description."
					end if
					
				on error
					set errorList to errorList & "Unable to locate install app button by its description."
				end try
			end tell
			set pageVerification to ""
		else --Throw error if page didn't verify
			set errorList to errorList & "Unable to verify that iTunes is open at the iBooks App Store Page."
		end if
		
	end if
end installIbooks

-----------------------------------------

on ClickCreateAppleIDButton()
	delay (masterDelay * processDelay)
	if scriptAction is "Continue" then --This is to make sure an abort hasn't been thrown
		--Verification text for window:
		--get value of static text 1 of window 1 of application process "iTunes" --should be equal to "Sign In to the iTunes Store"
		tell application "System Events"
			try
				click button "Skapa Apple-ID" of window 1 of application process "iTunes"
			on error
				set errorList to errorList & "Unable to locate and click button ''Create Apple ID'' on ID sign-in window"
			end try
		end tell
	end if
end ClickCreateAppleIDButton

-----------------------------------------

on ClickContinueOnPageOne()
	delay (masterDelay * processDelay)
	
	
	set pageVerification to verifyPage(curExpectedElementString, curExpectedElementLocation, 7, netDelay, false) ----------Verify we are at page 1 of the Apple ID creation page
	
	if pageVerification is "verified" then
		
		try
			tell application "System Events"
				set contButton to button "Fortsätt" of UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
				if title of contButton is "Fortsätt" then
					click contButton
				else
					set errorList to errorList & "Unable to locate and click the Continue button on page ''Welcome to iTunes Store''."
				end if
			end tell
		on error
			set errorList to errorList & "Unable to locate and click the Continue button on page ''Welcome to iTunes Store''."
		end try
		
		set pageVerification to ""
	else
		set errorList to errorList & "Unable to verify that iTunes is open at the first page of the Apple ID creation process."
	end if
end ClickContinueOnPageOne

-----------------------------------------

on AgreeToTerms()
	delay (masterDelay * processDelay)
	
	
	set pageVerification to verifyPage(curTermsExpectedElementString, curTermsExpectedElementLocation, 11, netDelay, false) ----------Verify we are at page 1 of the Apple ID creation page
	
	if pageVerification is "verified" then
		tell application "System Events"
			
			
			try
				set agreeCheckbox to checkbox curCheckBox of group curCheckBoxNum of UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
				set buttonVerification to title of agreeCheckbox
				
				click agreeCheckbox
			on error
				set errorList to errorList & "Unable to locate and check box #2 ''I have read and agree to these terms and conditions.''"
			end try
			
			--delay (masterDelay * processDelay) --We need to pause a second for System Events to realize we have checked the box
			delay 1
			my CheckForErrors()
			
			
			if scriptAction is "Continue" then
				try
					set agreeButton to button "Godkänn" of UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
					set buttonVerification to title of agreeButton
					if buttonVerification is "Godkänn" then
						click agreeButton
					else
						set errorList to errorList & "Unable to locate and click button ''Agree''."
					end if
				on error
					set errorList to errorList & "Unable to locate and click button ''Agree''."
				end try
			else
				set errorList to errorList & "Unable to locate and click button ''Agree''."
			end if
			
		end tell
	end if
	
end AgreeToTerms

-----------------------------------------
on theForm()
	tell application "System Events"
		set theForm to UI element 1 of scroll area 3 of window 1 of application process "iTunes"
		return theForm
	end tell
end theForm

-----------------------------------------

on FillInField(fieldName, theField, theValue)
	tell application "System Events"
		try
			set focused of theField to true
			set value of theField to theValue
			if value of theField is not theValue then
				set errorList to errorList & ("Unable to fill " & fieldName & ".")
			end if
		on error
			set errorList to errorList & ("Unable to fill " & fieldName & ". ")
		end try
	end tell
end FillInField

on FillInKeystroke(fieldName, theField, theValue)
	tell application "System Events"
		set frontmost of application process "iTunes" to true --Verify that iTunes is the front window before performing keystroke event
		try
			set focused of theField to true
			keystroke theValue
		on error
			set errorList to errorList & ("Unable to fill " & fieldName & ". ")
		end try
	end tell
end FillInKeystroke

on FillInPopup(fieldName, theField, theValue, maximum)
	tell application "System Events"
		set frontmost of application process "iTunes" to true --Verify that iTunes is the front window before performing keystroke event
		try
			-- iTunes doesn't allow direct access to popup menus. So we step through instead.
			repeat with loopCounter from 1 to maximum
				if value of theField is theValue then exit repeat
				
				set focused of theField to true
				delay 0.1
				keystroke " " -- Space to open the menu
				keystroke (key code 125) -- down arrow
				keystroke " " -- Space to close the menu
			end repeat
			
			if value of theField is not theValue then set errorList to errorList & ("Unable to fill " & fieldName & ". ")
		on error
			set errorList to errorList & ("Unable to fill " & fieldName & ". ")
		end try
	end tell
end FillInPopup

on ClickThis(fieldName, theField)
	tell application "System Events"
		try
			click theField
		on error
			set errorList to errorList & ("Unable to click " & fieldName & ". ")
		end try
	end tell
end ClickThis

-----------------------------------------

on ProvideAppleIdDetails(appleIdEmail, appleIdPassword, appleIdSecretQuestion1, appleIdSecretAnswer1, appleIdSecretQuestion2, appleIdSecretAnswer2, appleIdSecretQuestion3, appleIdSecretAnswer3, rescueEmail, userBirthMonth, userBirthDay, userBirthYear)
	if scriptAction is "Continue" then --This is to make sure an abort hasn't been thrown
		set pageVerification to verifyPage("Ange information om Apple-ID", "Ange information om Apple-ID", 0, (netDelay * processDelay), false)
		if pageVerification is "Verified" then
			tell application "System Events"
				
				set theForm to UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
				
				--Count the number of UI elements on the page to get a baseline
				
				set elementCountDefault to 0
				set elementCountDefault to count every UI element of UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
				
				-----------
				tell me to FillInField("Email", text field 1 of group 3 of theForm, appleIdEmail)
				-----------
				tell me to FillInKeystroke("Password", text field 1 of group 2 of group 4 of theForm, appleIdPassword)
				
				--Count number of UI elements after attemping to set password, if number has increased, error box is showing
				
				set elementPasswordCountDefault to 0
				set elementPasswordDefault to count every UI element of UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
				
				
				-----------
				tell me to FillInKeystroke("Retype your password", text field 1 of group 4 of group 4 of theForm, appleIdPassword)
				-----------
				tell me to FillInPopup("First Security Question", pop up button 1 of group 1 of group 7 of theForm, appleIdSecretQuestion1, noOfResponses)
				tell me to FillInField("First Answer", text field 1 of group 2 of group 7 of theForm, appleIdSecretAnswer1)
				-----------
				tell me to FillInPopup("Second Security Question", pop up button 1 of group 1 of group 8 of theForm, appleIdSecretQuestion2, noOfResponses)
				tell me to FillInField("Second Answer", text field 1 of group 2 of group 8 of theForm, appleIdSecretAnswer2)
				-----------
				tell me to FillInPopup("Third Security Question", pop up button 1 of group 1 of group 9 of theForm, appleIdSecretQuestion3, noOfResponses)
				tell me to FillInField("Third Answer", text field 1 of group 2 of group 9 of theForm, appleIdSecretAnswer3)
				-----------
				tell me to FillInField("Optional Rescue Email", text field 1 of group 12 of theForm, rescueEmail)
				
				tell me to FillInPopup("Month", pop up button 1 of group curMonthPos of group 14 of theForm, userBirthMonth, 12)
				tell me to FillInPopup("Day", pop up button 1 of group curDayPos of group 14 of theForm, userBirthDay, 31)
				tell me to FillInField("Year", text field 1 of group 3 of group 14 of theForm, userBirthYear)
				-----------
				set releaseCheckbox to checkbox 1 of group 16 of theForm
				set newsCheckbox to checkbox 1 of group 17 of theForm
				if value of releaseCheckbox is 1 then
					tell me to ClickThis("New releases and additions to the iTunes Store.", releaseCheckbox)
				end if
				if value of newsCheckbox is 1 then
					tell me to ClickThis("News, special offers, and information about related products and services from Apple.", newsCheckbox)
				end if
				
				-----------
				
				--If element count has increased before continue is clicked, password set has failed, set error flag
				
				if elementCountDefault < elementPasswordCountDefault then set errorList to errorList & ("Password set has failed")
				
				my CheckForErrors() --Check for errors before continuing to the next page
				
				if dryRun is true then
					set dryRunSucess to button returned of (display dialog "Did everything fill in properly?" buttons {"Yes", "No"}) as text
					if dryRunSucess is "No" then
						set scriptAction to button returned of (display dialog "What would you like to do?" buttons {"Abort", "Continue"}) as text
					end if
				end if
				
				if scriptAction is "Continue" then
					tell me to click button "Fortsätt" of theForm
					
					
					delay 3 --Wait for page to respond to email address fail, this may need to be adjusted for slow connections
					
					--Count UI elements again, if they have increased over baseline, error box is showing, set error flag
					
					
					set elementEmailCount to 0
					set elementEmailCount to count every UI element of UI element 1 of scroll area 1 of splitter group 1 of window 1 of application process "iTunes"
					
					if elementEmailCount > elementCountDefault then set errorList to errorList & ("Email set has failed")
					
					set buttonReClick to false
					if elementEmailCount > elementCountDefault then set buttonReClick to true
					
					
					my CheckForErrors()
					
					--If error was trapped and then fixed, try to click continue again
					
					delay 1
					
					if buttonReClick is true then
						tell me to click button "Continue" of theForm
					end if
				end if
			end tell
		else --(If page didn't verify)
			set errorList to errorList & "Unable to verify that the ''Provide Apple ID Details'' page is open and fill its contents."
		end if
	end if
end ProvideAppleIdDetails

--------

on ProvidePaymentDetails(userFirstName, userLastName, addressStreet, addressCity, addressState, addressZip, phoneAreaCode, phoneNumber)
	if scriptAction is "Continue" then --This is to make sure an abort hasn't been thrown
		set pageVerification to verifyPage("Ange ett betalningssätt", "Ange ett betalningssätt", 0, (netDelay * processDelay), false)
		
		
		--Wait for the page to change after selecting payment type
		set checkFrequency to 0.25 --How often (in seconds) the iTunes LCD will be checked to see if iTunes is busy loading the page
		
		repeat
			set lcdStatus to GetItunesStatusUntillLcd("Does Not Match", itunesAccessingString, 4, "times. Check for:", (netDelay * (1 / checkFrequency)), "intervals of", checkFrequency, "seconds")
			if lcdStatus is "Matched" then exit repeat
			delay masterDelay
		end repeat
		
		tell application "System Events"
			
			
			if enableTitle is true then
				try
					set frontmost of application process "iTunes" to true --Verify that iTunes is the front window before performing keystroke event
					set focused of pop up button 1 of group 1 of group curTitlePos of theForm to true
					keystroke "Mr"
				on error
					set errorList to errorList & "Unable to set ''Title' to 'Mr.'"
				end try
				
			end if
			-----------
			
			try
				set value of text field 1 of group 1 of group curUserNameGroupPos of theForm to userFirstName
			on error
				set errorList to errorList & "Unable to set ''First Name'' field to " & userFirstName
			end try
			-----------
			try
				set value of text field 1 of group 2 of group curUserNameGroupPos of theForm to userLastName
			on error
				set errorList to errorList & "Unable to set ''Last Name'' field to " & userLastName
			end try
			-----------
			try
				set value of text field 1 of group 1 of group curAddressGroupPos of theForm to addressStreet
			on error
				set errorList to errorList & "Unable to set ''Street Address'' field to " & addressStreet
			end try
			-----------
			
			
			try
				set value of text field 1 of group curCityFieldPos of group curCityGroupPos of theForm to addressCity
			on error
				set errorList to errorList & "Unable to set ''City or Town'' field to " & addressCity
			end try
			
			
			
			
			if enableCounty is true then
				
				try
					UI elements
					set value of text field 1 of group 1 of group curCountyPos of theForm to addressState
				on error
					set errorList to errorList & "Unable to set ''County'' field to " & addressState
				end try
			end if
			
			----------
			
			if enableState is true then
				try
					set frontmost of application process "iTunes" to true --Verify that iTunes is the front window before performking keystroke event
					set focused of pop up button 1 of group curStatePos of group curStateGroup of theForm to true
					keystroke addressState
				on error
					set errorList to errorList & "Unable to set ''State'' drop-down to " & addressState
				end try
			end if
			
			
			---------			
			
			if enableProvince is true then
				try
					set frontmost of application process "iTunes" to true --Verify that iTunes is the front window before performking keystroke event
					set focused of pop up button 1 of group curProvincePos of group curProvinceGroup of theForm to true
					keystroke addressState
				on error
					set errorList to errorList & "Unable to set ''Province'' drop-down to " & addressState
				end try
			end if
			
			-----------			
			
			if enablePostcode is true then
				try
					--set value of text field 1 of group 3 of group 11 of theForm to addressZip
					set value of text field 1 of group curPostalCodeFieldPos of group curPostalCodeFieldGroup of theForm to addressZip
				on error
					set errorList to errorList & "Unable to set ''Postal Code'' field to " & addressZip
				end try
			end if
			
			---------
			
			if curAreaCode is true then
				
				try
					set value of text field 1 of group 1 of group curPhoneGroup of theForm to phoneAreaCode
				on error
					set errorList to errorList & "Unable to set ''Area Code'' field to " & phoneAreaCode
				end try
				
			end if
			-----------
			try
				set value of text field 1 of group curPhonePos of group curPhoneGroup of theForm to phoneNumber
			on error
				set errorList to errorList & "Unable to set ''Phone Number'' field to " & phoneNumber
			end try
			-----------
			
			my CheckForErrors()
			
			if dryRun is true then --Pause to make sure all the fields filled properly
				set dryRunSucess to button returned of (display dialog "Did everything fill in properly?" buttons {"Yes", "No"}) as text
				if dryRunSucess is "No" then
					set scriptAction to button returned of (display dialog "What would you like to do?" buttons {"Abort", "Continue"}) as text
				end if
			end if
			
			if dryRun is false then --Click the "Create Apple ID" button as long as we aren't in "Dry Run" mode
				if scriptAction is "Continue" then --Continue as long as no errors occurred
					try
						click button "Create Apple ID" of theForm
					on error
						set errorList to errorList & "Unable to click ''Create Apple ID'' button."
					end try
				end if --End "Continue if no errors" statement
			else --If we are doing a dry run then...
				set dryRunChoice to button returned of (display dialog "Completed. Would you like to stop the script now, continue ''dry running'' with the next user in the CSV (if applicable), or run the script ''for real'' starting with the first user?" buttons {"Stop Script", "Continue Dry Run", "Run ''For Real''"}) as text
				if dryRunChoice is "Stop Script" then set scriptAction to "Stop"
				if dryRunChoice is "Run ''For Real''" then
					set currentUserNumber to 0
					set dryRun to false
				end if
			end if --End "dry Run" if statement
			
		end tell --End "System Events" tell
	end if --End main error check IF
end ProvidePaymentDetails

--Version Changes
--1.1.1.1 Original Fork of GBR version for iTunes 11.0 and below

--1.1.1.2 Added AUS localisation

--1.1.1.3 Added NZ localisation

--1.1.1.4 Added Month/Date localisation option

--1.1.2.0 Changed to support iTunes 12.0.1

--1.1.2.1 Added "Get" button descriptions

--1.1.2.2 Added routine for "Province"

--1.1.2.1 Added PNG localisation

--1.1.2.2 Added Postcode location routine

--1.1.3.0 Changes for Yosemite

--1.1.3.1 Added more "Get Button" decsriptions

--1.1.3.2 Consolidate all localisations into one codebase

--1.1.3.3 Added Title localisation, Title can now be set on or off as required

--1.2.0.0 Major code rewrite, added global variables at top of script, move all localisation settings to a single block per localisation at top of code to make them easier to find and modifiy, rewrite and add some new routines to allow localisation

--1.2.0.1 Changed supported iTunes version to 12.0.1 family only, as the element locations are different to the other iTunes families, will now display warning if run on any other versions.

--1.2.0.2 Remove redundant code and general code clean up

--1.2.0.3 Consolidate all known localisations, tested with iTunes stores in English, all OK, local language versions may need tweaking but at least there is a starting point

--1.2.0.4 Remove code where I was trying to support Mavericks and Yosemite (different element locations by one position), errors are not consistent, Mavericks version now forked off

--1.2.0.5 Added OS Check routine, script will now warn if OS Version not supported.

--1.2.0.6 Added error trap routine if location not set, script will now pop up dialogue "abort" box with a warning. Just behaves a little bit nicer for those who don't know they have to set the localisation

--1.2.0.7 Changed localisation settings for NZL to put "State" feild into "Suburb" Box on script

--1.2.0.8 Added routine to pop up dialogue box if csv file upload is cancelled, just nicer behavior then throwing an error for those who are not coders

--1.2.0.9 Clean up code and add comments to make it easier to follow

--1.2.0.10 Added donation nag....

--1.2.0.11 More code clean up. Fix commenting so it is consistant and easier to follow (I hope.....)

--1.2.0.12 Minor bugfix unexpected action after no locale set

--1.2.0.13 Added localisations for India and Spain. They may need tweaking as they were built for the 'English' versions of the Indian and Spanish iTunes stores

--1.2.0.14 Added routine to enable add sucessful OS to supported OS types

--1.2.0.15 Added error traping for when email and/or password is rejected, user can now be skipped or script aborted. Slightly complicated by the fact the the password is not verified by Apple till the continue button is clicked. If the network conection is slow the error will be "junped over" and the script will fail. The delay checking time may need to be increased.

--1.2.0.16 Bug fix in error trapping, wrong variable used (Thanks Johny)