# adcredchecker
AD Credential List Checker

# description
We get 3rd party lists of username/credentials that we have to determine if accurate in our setup periodically and to automate the process I built this out.

# How To
The lists are normally in the format of:

user1@someemaildomain.local:Bearteeth1!

user2@someemaildomain.local:,Zidqene11

user3@someemaildomain.local:ABlogon5704

user4@someemaildomain.local:BearsRule!:

user4@someemaildomain.local:BearsRule2

user5@someemaildomain.local:BearsRule2

user6@someemaildomain.local:Bearteeth1!


You can past these in A2 on Sheet 2 in the spreadsheet and copy the formulas from B2 through D2 down to the end and it will nicely split it out.  Add whatever Description you may want, IE where the password list came from

Copy and Paste those values from column B, C, D and E into Sheet1 at the bottom.  Make sure you paste Values!

Then exapand the formula in E and F through these new ones as well.

Note:  Complex Password is based on my own logic for my organization, you'll need to install the macro to make it work.  The macro file has a ton of other features in it, but it does things you may not want it to be able to do, so up to you if you use it or not.

Before info in E and F will be useful, sort on pw (column C) and then sort on name (column A).

Filter for True on E and delete any of them as it is a dupe you already have.  
Filter for True on F and delete any of them too as if they don't meet your password policy no point in keeping them.

Once done now copy the fomulas on E and F across all of them again as you will get #REF errors on E at least after deleting stuff

Now you have a nice list of usernames and passwords that you need to test.  Run the powershell script, check the output file and decide how your going to handle its results.

# Excel Macro
Needs dumped in the proper directory to work:
[drive]:\Users\[useraccount]\AppData\Roaming\Microsoft\AddIns

Then you also have to go into excel and enable it.

This is NOT needed for this to work, not to mention some of the functions in the different modules may be something you really don't want excel to do, such as making calls to cmd.exe, but you don't need to use those modules for this anyway.

Your password complexity may be different than ours.  Historically we had min 8 and complexity, then we went to min of 15 (no complexity), so it checks for either of those.  Modify as needed.
