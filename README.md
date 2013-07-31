Rally-Add-TestCases-TestSet

- Configuring and Using the Add Test Cases to Test Set Script

- Create directory for script and associated files:

- C:\Users\username\Documents\Rally  Add Test Cases to Test Set\ 

- Download the script repository from Github using the “Download ZIP” button to the above directory and extract
 

- Create your Test Case to Test Set mapping file. It must be a plain text CSV file with the following fields/format:
<pre>
Test Case FormattedID,Test Case Name, Target Test Set FormattedID, Target Test Set Name
TC327,TC07-012-006,TS11,Performance Load Tests
</pre>
- The script will assign the Test Case with the Formatted ID matching that in the first comma-separated column, to the Test Set with Formatted ID matching that in the third comma-separated column. If the script lookup against Rally for either the Test Case or Target Test Folder fails to find the object of interest in Rally, it will skip that row and move on.

- Using a text editor, customize the code parameters in the my_vars.rb file for your environment.
 <pre>
	my_vars.rb:
	
	$my_base_url       = "https://rally1.rallydev.com/slm"
	$my_username       = "user@company.com"
	$my_password       = "topsecret"
	$my_workspace      = "My Workspace"
	$my_project        = "My Project"
	$wsapi_version     = "1.43"
	$filename          = 'add_test_cases_to_testset.csv'
</pre>


- Run the script.
<pre>
C:\> ruby add_test_cases_to_testset.rb
Adding Test Set TS8 to Test Set cache.
Caching Test Case TC349 for addition to Test Set TS8
Caching Test Case TC350 for addition to Test Set TS8
Caching Test Case TC351 for addition to Test Set TS8
Caching Test Case TC352 for addition to Test Set TS8
Caching Test Case TC353 for addition to Test Set TS8
Caching Test Case TC354 for addition to Test Set TS8
Caching Test Case TC355 for addition to Test Set TS8
Caching Test Case TC356 for addition to Test Set TS8
Caching Test Case TC357 for addition to Test Set TS8
Caching Test Case TC358 for addition to Test Set TS8
Caching Test Case TC359 for addition to Test Set TS8
Caching Test Case TC360 for addition to Test Set TS8
Caching Test Case TC361 for addition to Test Set TS8
Caching Test Case TC362 for addition to Test Set TS8
Caching Test Case TC363 for addition to Test Set TS8
Caching Test Case TC364 for addition to Test Set TS8
Adding Test Set TS9 to Test Set cache.
Caching Test Case TC365 for addition to Test Set TS9
Caching Test Case TC366 for addition to Test Set TS9
Caching Test Case TC367 for addition to Test Set TS9
Caching Test Case TC368 for addition to Test Set TS9
Caching Test Case TC369 for addition to Test Set TS9
Caching Test Case TC370 for addition to Test Set TS9
Caching Test Case TC371 for addition to Test Set TS9
Caching Test Case TC372 for addition to Test Set TS9
Caching Test Case TC373 for addition to Test Set TS9
Caching Test Case TC374 for addition to Test Set TS9
Caching Test Case TC375 for addition to Test Set TS9
Caching Test Case TC376 for addition to Test Set TS9
Caching Test Case TC377 for addition to Test Set TS9
Caching Test Case TC378 for addition to Test Set TS9
Caching Test Case TC389 for addition to Test Set TS9
Caching Test Case TC395 for addition to Test Set TS9
Test Set TS8 successfully added 16 Test Cases.
Test Set TS9 successfully added 16 Test Cases.
Finished!
</pre>

This will update the Test Folder for ALL TEST CASES listed in the move_test_cases.csv file.

Please Note: The way Rally’s Webservices API works to assign Test Case to Test Sets involves adding a (potentially large) array of Test Cases as an attribute to the Test Set. This can sometimes cause concurrency problems, especially if a Test Case that’s included in an update operation like this gets changed or edited elsewhere during the update process. For this reason, it’s recommended that you keep your batch sizes relatively small when running this script, and to run it during times when concurrent editing/updating is less likely to occur, if possible.