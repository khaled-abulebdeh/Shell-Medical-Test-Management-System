#!/bin/sh



Average_test_value() {
	Hgb_sum="0"
	Hgb_counter="0"
	LDL_sum="0"
	LDL_counter="0"
	BGT_sum="0"
	BGT_counter="0"
	systole_sum="0"
	systole_counter="0"
	diastole_sum="0"
	diastole_counter="0"




	while read line; do




    	# Test names (as Hgb) are followed by ",", and we don't know its exact length, we have to find it
    	testLength=$(echo "$line" | cut -d' ' -f2 | wc -c)
    	#subtract one to ignore ",", and one to ignore new line char
    	testLength=$(($testLength - 2))




    	resultLength=$(echo "$line" | cut -d' ' -f4 | wc -c)
    	resultLength=$(($resultLength - 2))




    	testName="$(echo "$line" | cut -d' ' -f2 | cut -c1-$testLength)"
    	result="$(echo "$line" | cut -d' ' -f4 | cut -c1-$resultLength)"




    	#now, to find up_normal tests, there are many cases according to different test names
    	case "$testName" in
    	"Hgb")
        	Hgb_sum=$(echo "$Hgb_sum + $result" | bc)
        	Hgb_counter=$(($Hgb_counter + 1))
        	;;




    	"BGT")
        	BGT_sum=$(echo "$BGT_sum + $result" | bc)
        	BGT_counter=$(($BGT_counter + 1))
        	;;




    	"LDL")
        	LDL_sum=$(echo "$LDL_sum + $result" | bc)
        	LDL_counter=$(($LDL_counter + 1))
        	;;
    	"systole")
        	systole_sum=$(echo "$systole_sum + $result" | bc)
        	systole_counter=$(($systole_counter + 1))
        	;;




    	"diastole")
        	diastole_sum=$(echo "$diastole_sum + $result" | bc)
        	diastole_counter=$(($diastole_counter + 1))
        	;;
    	*) ;;
    	esac




	done <"MedicalRecord.txt"




	if [ "$Hgb_counter" -eq "0" ]; then
    	echo "There are no Hgb tests"
	else
    	printf "Hgb Average Result = %0.2f\n" "$(echo "$Hgb_sum/$Hgb_counter" | bc -l)"
	fi




	if [ "$BGT_counter" -eq "0" ]; then
    	echo "There are no BGT tests"
	else
    	printf "BGT Average Result = %0.2f\n" "$(echo "$BGT_sum/$BGT_counter" | bc -l)"
	fi




	if [ "$LDL_counter" -eq "0" ]; then
    	echo "There are no LDL tests"
	else
    	printf "LDL Average Result = %0.2f\n" "$(echo "$LDL_sum/$LDL_counter" | bc -l)"
	fi




	if [ "$systole_counter" -eq "0" ]; then
    	echo "There are no systole tests"
	else
    	printf "systole Average Result = %0.2f\n" "$(echo "$systole_sum/$systole_counter" | bc -l)"
	fi




	if [ "$diastole_counter" -eq "0" ]; then
    	echo "There are no diastole tests"
	else
    	printf "diastole Average Result = %0.2f\n" "$(echo "$diastole_sum/$diastole_counter" | bc -l)"
	fi




}




retrieve_patient_tests_using_status() {
	# "$1" is the first parameter passed through a function call, not the passed to run a script (not ./file.sh "arg")
	# we have checked that patient is existed (in search_test_by_id)




	#checking validity of input
	while true; do
    	echo "Enter test status (Pending, Completed, Reviewed)"
    	read status
    	if [ "$(echo " Pending  Completed  Reviewed " | grep "\<$status\>")" ]; then # one choice is accepted
        	break                                                                   	#  accepted input
    	else
        	echo "Sorry, Unaccepted status"
    	fi
	done




	# || means if command_1 was not execute, execute command_2
	cat "MedicalRecord.txt" | grep "$1" | grep "$status" || printf "patient has no $status tests\n"
}




retrieve_all_patient_tests() {
	# "$1" is the first parameter passed through a function call, not the passed to run a script (not ./file.sh "arg")
	# we have checked that patient is existed (in search_test_by_id)
	echo ""
	cat MedicalRecord.txt | grep "$1"
	echo ""
}




retrieve_up_normal_patient_tests() {
	# "$1" is the first parameter passed through a function call, not the passed to run a script (not ./file.sh "arg")
	# we have checked that patient is existed (in search_test_by_id)




	cat MedicalRecord.txt | grep "$1" >temp.txt # store all patient result in a temp file




	checker="0"
	while read line; do




    	# Test names (as Hgb) are followed by ",", and we don't know its exact length, we have to find it
    	testLength=$(echo "$line" | cut -d' ' -f2 | wc -c)
    	#subtract one to ignore ",", and one to ignore new line char
    	testLength=$(($testLength - 2))




    	resultLength=$(echo "$line" | cut -d' ' -f4 | wc -c)
    	resultLength=$(($resultLength - 2))




    	testName="$(echo "$line" | cut -d' ' -f2 | cut -c1-$testLength)"
    	result="$(echo "$line" | cut -d' ' -f4 | cut -c1-$resultLength)"




    	#now, to find up_normal tests, there are many cases according to different test names
    	case "$testName" in
    	"Hgb")
        	if [ $(echo "$result >  17.2" | bc) -eq "1" ]; then
            	echo "$line"
            	checker="1" #to mark that there is upnormal tests
        	fi
        	;;




    	"BGT")
        	if [ $(echo "$result >  99" | bc) -eq "1" ]; then
            	echo "$line"
            	checker="1" #to mark that there is upnormal tests
        	fi
        	;;




    	"LDL")
        	if [ $(echo "$result >  100" | bc) -eq "1" ]; then
            	echo "$line"
            	checker="1" #to mark that there is upnormal tests
        	fi
        	;;




    	"systole")
        	if [ $(echo "$result >  120" | bc) -eq "1" ]; then
            	echo "$line"
            	checker="1" #to mark that there is upnormal tests
        	fi
        	;;




    	"diastole")
        	if [ $(echo "$result >  80" | bc) -eq "1" ]; then
            	echo "$line"
            	checker="1" #to mark that there is upnormal tests
        	fi
        	;;




    	*) ;;
    	esac




	done <"temp.txt"




	if [ "$checker" -eq "0" ]; then
    	printf "Patient has no upnormal tests\n\n"
	fi




}




retrieve_patient_tests_in_period() {
	current_year="$(date | tr -s ' ' ' ' | cut -d' ' -f7)"




	current_month="$(date | tr -s ' ' ' ' | cut -d' ' -f2)"
	#to convert month from (Jan, Apr,...) to nummers (1,2,...)
	case "$current_month" in
	"Jan") current_month=1 ;;
	"Feb") current_month=2 ;;
	"Mar") current_month=3 ;;
	"Apr") current_month=4 ;;
	"May") current_month=5 ;;
	"Jun") current_month=6 ;;
	"Jul") current_month=7 ;;
	"Aug") current_month=8 ;;
	"Sep") current_month=9 ;;
	"Oct") current_month=10 ;;
	"Nov") current_month=11 ;;
	"Dec") current_month=12 ;;
	esac




	#enter starting date then check YYYY_MM format
	while true; do
    	echo ""
    	echo "enter starting date in YYYY-MM format"
    	read starting_date
    	if [ $(echo "$starting_date" | grep "\<[0-9]\{4\}\-[0-9]\{2\}\>") ]; then
        	starting_year="$(echo "$starting_date" | cut -c1-4)"
        	starting_month="$(echo "$starting_date" | cut -c6-7)"




        	#check if currentDate < testDate (means not existed !)
        	if [ "$current_year" -lt "$starting_year" ]; then
            	echo "Sorry, year must be before than or equal  $current_year"
            	continue
        	elif [ "$current_year" -eq "$starting_year" ]; then
            	if [ "$current_month" -lt "$starting_month" ]; then
                	echo "in current year, starting month must be before current month"
                	continue
            	else
                	break #accepted
            	fi
        	else
            	if [ "$starting_month" -gt "12" -o "$starting_month" -le "0" ]; then
                	echo "entre a month 1-12"
                	continue
            	else
                	break
            	fi
        	fi
    	else
        	echo ""
        	echo "Sorry, use YYYY-MM format"
    	fi
	done




	#enter ending date then check YYYY_MM format
	while true; do
    	echo ""
    	echo "enter ending date in YYYY-MM format"
    	read ending_date
    	if [ $(echo "$ending_date" | grep "\<[0-9]\{4\}\-[0-9]\{2\}\>") ]; then
        	ending_year="$(echo "$ending_date" | cut -c1-4)"
        	ending_month="$(echo "$ending_date" | cut -c6-7)"




        	#check if currentDate < testDate (means not existed !)
        	if [ "$current_year" -lt "$ending_year" ]; then
            	echo "Sorry, year must be before than or equal $current_year"
            	continue
        	elif [ "$starting_year" -gt "$ending_year" ]; then
            	echo "Starting date must be before ending date"
            	continue
        	elif [ "$current_year" -eq "$ending_year" ]; then
            	if [ "$current_month" -le "$ending_month" ]; then
                	echo "in current year, ending month must be before or equal the current month"
                	continue
            	else
                	break #accepted
            	fi
        	else
            	if [ "$ending_month" -gt "12" -o "$ending_month" -le "0" ]; then
                	echo "entre a month 1-12"
                	continue
            	else
                	break
            	fi
        	fi
    	else
        	echo ""
        	echo "Sorry, use YYYY-MM format"
    	fi
	done




	# to check each test if it is in the entered period
	checker="0" # to find out if there are results
	echo ""
	while read line; do
    	#to check id for this test, first.
    	test_id="$(echo "$line" | cut -c1-7)"
    	if [ "$test_id" != "$1" ]; then
        	continue #skip this line
    	fi




    	test_date="$(echo "$line" | cut -d' ' -f3)"
    	test_year="$(echo "$test_date" | cut -c1-4)"
    	test_month="$(echo "$test_date" | cut -c6-7)"




    	#case 0: if (test_year < starting_year)  or (test_year > ending_year) : not accepted year
    	if [ \( "$test_year" -lt "$starting_year" \) -o \( "$test_year" -gt "$ending_year" \) ]; then
        	continue # exit to check next line




    	#case 1: if (test_year>starting_year) & (test_year<ending_year) : no need to compare months
    	elif [ \( "$test_year" -gt "$starting_year" \) -a \( "$test_year" -lt "$ending_year" \) ]; then
        	checker="1"
        	echo "$line" #accepted




    	#case 2: if (test_year=starting_year) & (test_year=ending_year): need to compare month ranges
    	elif [ \( "$test_year" -eq "$starting_year" \) -a \( "$test_year" -eq "$ending_year" \) ]; then
        	if [ \( "$test_month" -ge "$starting_month" \) -a \( "$test_month" -le "$ending_month" \) ]; then
            	checker="1"
            	echo "$line"
        	fi




    	#case 3: if (test_year=starting_year) : need to compare ending
    	#no need to check ending, ro reach case 3 means the absolutly (test_date<ending_date) and (starting_date<ending_date)
    	elif [ "$test_year" -eq "$starting_year" ]; then
        	if [ "$test_month" -ge "$starting_month" ]; then
            	checker="1"
            	echo "$line"
        	fi




    	#case 4: if (test_year=ending_year) : need to compare starting
    	#no need to check starting, ro reach case 4 means the absolutly (test_date>starting_date) and  (ending_date>starting_date)
    	elif [ "$test_year" -eq "$ending_year" ]; then
        	if [ "$test_month" -le "$ending_month" ]; then
            	checker="1"
            	echo "$line"
        	fi
    	else
        	:
    	#do nothinh, not accepted test field




    	fi
	done <"MedicalRecord.txt"




	if [ "$checker" -eq "0" ]; then
    	printf "patient has no tests in the period given\n\n"
	fi
}




search_for_all_upnormal_tests() {




	while read line; do




    	# Test names (as Hgb) are followed by ",", and we don't know its exact length, we have to find it
    	testLength=$(echo "$line" | cut -d' ' -f2 | wc -c)
    	#subtract one to ignore ",", and one to ignore new line char
    	testLength=$(($testLength - 2))




    	resultLength=$(echo "$line" | cut -d' ' -f4 | wc -c)
    	resultLength=$(($resultLength - 2))




    	testName="$(echo "$line" | cut -d' ' -f2 | cut -c1-$testLength)"
    	result="$(echo "$line" | cut -d' ' -f4 | cut -c1-$resultLength)"
    	#now, to find up_normal tests, there are many cases according to different test names
    	case "$testName" in
    	"Hgb")
        	if [ $(echo "$result >  17.2" | bc) -eq "1" ]; then
            	echo "$line"
        	fi
        	;;




    	"BGT")
        	if [ $(echo "$result >  99" | bc) -eq "1" ]; then
            	echo "$line"
        	fi
        	;;




    	"LDL")
        	if [ $(echo "$result >  100" | bc) -eq "1" ]; then
            	echo "$line"
        	fi
        	;;
    	"systole")
        	if [ $(echo "$result >  120" | bc) -eq "1" ]; then
            	echo "$line"
        	fi
        	;;




    	"diastole")
        	if [ $(echo "$result >  80" | bc) -eq "1" ]; then
            	echo "$line"
        	fi
        	;;




    	*) ;;
    	esac




	done <"MedicalRecord.txt"
	printf "\n"
}




# Search for a test by patient ID
search_test_by_id() {




	while true; do
    	echo -n "enter patient id "
    	read patient_id
    	#Error Handling: check if it is exactly 7 numbers
    	if [ $(echo "$patient_id" | grep "\<[0-9]\{7\}\>") ]; then
        	break
    	else
        	echo "Sorry, patient id must be exactly 7 numbers"
    	fi
	done




	#to check if the patient having an accepted id format is existed
	# If patient is found
	if [ "$(grep "^$patient_id" MedicalRecord.txt)" ]; then
    	:
	else
    	printf "Sorry, patient has no existing tests\n\n"
    	return # to exit the function
	fi




	repetition=1 #an accepted value to enter the loop for the first time
	#repetition variable is used to display the menu more times if the input is not accepted
	while [ "$repetition" -ne "0" ]; do
    	repetition=0 # to reset the loop, suppose this is the last trun (unless entering the default case of the switch)
    	printf "\nenter your choice\n"
    	echo "1) Retrieve all patient tests"
    	echo "2) Retrieve all up normal patient tests"
    	echo "3) Retrieve all patient tests in a given specific period"
    	echo "4) Retrieve all patient tests based on test status"
    	read choice
    	case "$choice" in
    	1)
        	retrieve_all_patient_tests "$patient_id"
        	;; #we passed it as a parameter (acutally, it is called an argument)
    	2) retrieve_up_normal_patient_tests "$patient_id" ;;
    	3) retrieve_patient_tests_in_period "$patient_id" ;;
    	4) retrieve_patient_tests_using_status "$patient_id" ;;
    	#notice the syntax when 2 commands at the same case
    	*)
        	echo "Wrong input, try again" #no ;; here
        	repetition=1
        	;; #to iterate again
    	esac
	done




}




update_test_result() {
	# ask for ID and validate it exists in the recordsfile.txt
	while true; do
    	echo -n "Enter Patient ID (7 Digits Only): "
    	read patient_id




    	if [ "$(echo "$patient_id" | grep '^[0-9]\{7\}$')" ]; then
        	if grep "^$patient_id: " MedicalRecord.txt >/dev/null; then
            	break # which means that it does exist ..
        	else
            	echo "ERROR!! The patient ID Does NOT found in MedicalRecords. Please try again with existed ID."
        	fi
    	else
        	echo "ERROR!! Please try again using (7 digits) ONLY!"
    	fi
	done




	# now asks for test Name and validate it exists for that given patient ID
	while true; do
    	echo -n "Enter Test Name: "
    	read test_Record_name




    	if grep "^$patient_id: $test_Record_name," MedicalRecord.txt >/dev/null; then
        	break # which means it found it then continue
    	else
        	echo "ERROR!! Test Name not found for this Patient ID in MedicalRecord. Please try again using maybe Hgb, BGT, LDL, systole, diastole .."
    	fi
	done




	# now asks for the test date in YYYY-MM format and validate it
	while true; do
    	echo -n "Enter the Date (YYYY-MM): "
    	read test_Record_Date




    	if grep "^$patient_id: $test_Record_name, $test_Record_Date," MedicalRecord.txt >/dev/null; then
        	break # which also means that it found this date with this format
    	else
        	echo "ERROR!! The test Date Does NOT found for this Test Name and Patient ID in MedicalRecord. Please try again with included date!"
    	fi
	done




	# now asks the user what to update: result, date, status, or exit
	echo "NOW Enter the option you would like to update.."
	echo "(1) Result"
	echo "(2) Date"
	echo "(3) Status"
	echo "(4) Exit"




	read choice




	case $choice in
	1)
    	while true; do
        	echo -n "Enter new Result: "
        	read new_result




        	if echo "$new_result" | grep -qE '^[0-9]*(\.[0-9]*)?$'; then #




            	sed "s/\(^$patient_id: $test_Record_name, $test_Record_Date, \)[0-9]*\(\.[0-9]*\)\?/\1$new_result/" MedicalRecord.txt >MedicalRecord.tmp && mv MedicalRecord.tmp MedicalRecord.txt
            	echo "Result updated successfully :)"
            	break




        	else
            	echo "ERROR!! Please enter a valid number."
        	fi
    	done
    	;;
	2)
    	while true; do
        	echo -n "Enter new Date (YYYY-MM): "
        	read new_date




        	if echo "$new_date" | grep -qE '^[0-9]{4}-[0-9]{2}$'; then
            	# extract year and month from new_date
            	new_year=$(echo "$new_date" | cut -d'-' -f1)
            	new_month=$(echo "$new_date" | cut -d'-' -f2)




            	# ensure the month is properly formatted (must be between 01 and 12)
            	if [ "$new_month" -lt 1 ]; then
                	echo "ERROR!! Month must be between 01 and 12."
                	continue
            	else
                	if [ "$new_month" -gt 12 ]; then
                    	echo "ERROR!! Month must be between 01 and 12."
                    	continue
                	fi
            	fi




            	# the current year and month
            	current_year="$(date | tr -s ' ' ' ' | cut -d' ' -f7)"
            	current_month="$(date | tr -s ' ' ' ' | cut -d' ' -f2)"




            	# convert month name to number (e.g. Jan -> 1)
            	case "$current_month" in
            	"Jan") current_month=1 ;;
            	"Feb") current_month=2 ;;
            	"Mar") current_month=3 ;;
            	"Apr") current_month=4 ;;
            	"May") current_month=5 ;;
            	"Jun") current_month=6 ;;
            	"Jul") current_month=7 ;;
            	"Aug") current_month=8 ;;
            	"Sep") current_month=9 ;;
            	"Oct") current_month=10 ;;
            	"Nov") current_month=11 ;;
            	"Dec") current_month=12 ;;
            	esac




            	# new date should not exceed the current date
            	# Ensure that the new date does not exceed the current date
            	if [ "$new_year" -gt "$current_year" ]; then
                	echo "ERROR!! Year must not exceed the current year ($current_year)."
                	continue
            	else
                	if [ "$new_year" -eq "$current_year" ]; then
                    	if [ "$new_month" -gt "$current_month" ]; then
                        	echo "ERROR!! In the current year, the month must not exceed the current month ($current_month)."
                        	continue
                    	fi
                	fi
            	fi




            	formatted_new_date="$new_year-$new_month"
            	# update the date in the record file
            	echo "$new_year-$new_month"
            	sed "s/\(^$patient_id: $test_Record_name, \)$test_Record_Date/\1$formatted_new_date/" MedicalRecord.txt >MedicalRecord.tmp && mv MedicalRecord.tmp MedicalRecord.txt
            	echo "Date updated successfully :)"
            	break
        	else
            	echo "ERROR!! Please use the YYYY-MM format."
        	fi
    	done
    	;;




	3)
    	# Update status
    	while true; do
        	echo -n "Enter new Status (Pending/Completed/Reviewed): "
        	read new_status




        	if echo "$new_status" | grep -qE '^(Pending|Completed|Reviewed)$'; then
            	# Find the line with the specific Patient ID, Test Name, and Date (case-insensitive)
            	line=$(grep -i "^$patient_id: $test_Record_name, $test_Record_Date," MedicalRecord.txt)




            	if [ -n "$line" ]; then # -n for tests if the string inside the quotes is non-empty




                	new_line=$(echo "$line" | sed -E "s/(, [^,]*$)/, $new_status/i")
                	# since it used to make case unsensetive ..
                	# -E: enables extended regular expressions in sed
                	# , : matches a comma followed by a space
                	# [^,]*: matches any sequence of characters that are not a comma
                	# i : this flag makes the substitution case-insensitive
                	# Use sed to replace the line in the file and save to a temporary file
                	sed "s|$line|$new_line|I" MedicalRecord.txt >MedicalRecord.tmp && mv MedicalRecord.tmp MedicalRecord.txt




                	echo "status updated successfully :)"
                	break
            	else
                	echo "ERROR!! The specific record could not be found."
                	break
            	fi
        	else
            	echo "ERROR!! Please enter one of the following ONLY: Pending, Completed, Reviewed."
        	fi
    	done
    	;;
	4)
    	# exit
    	echo "Good Bye my friend"
    	echo "Exiting..."
    	break
    	;;
	*)
    	echo "ERROR!! Invalid choice, please select ONLY 1, 2, 3, or 4."
    	;;
	esac




}




Add_Test_Record() {
	# 7-digit Patient ID
	while true; do
    	echo -n "Enter Patient ID (7 Digits Only): "
    	read patient_id




    	if [ "$(echo "$patient_id" | grep '^[0-9]\{7\}$')" ]; then
        	break
    	else
        	echo "Please Try again with using 7 digits ONLY!"
    	fi
	done




	# Test Name (non-empty and must exist in MedicalTest.txt)
	while true; do
    	echo -n "Enter Test Name: "
    	read test_Record_name




    	# Check if the test name or its shortcut exists in MedicalTest.txt
    	if grep "^$test_Record_name " MedicalTest.txt >/dev/null || grep "($test_Record_name)" MedicalTest.txt >/dev/null; then
        	# Extract the unit for the test name from MedicalTest.txt
        	unit=$(grep "^$test_Record_name " MedicalTest.txt | cut -d';' -f3 | cut -d':' -f2 | tr -d ' ')
        	if [ -z "$unit" ]; then
            	unit=$(grep "($test_Record_name)" MedicalTest.txt | cut -d';' -f3 | cut -d':' -f2 | tr -d ' ')
        	fi
        	echo "Unit for $test_Record_name is set to: $unit"
        	break




    	else
        	echo "Test Name is invalid or not found in MedicalTest.txt. Please try again."
    	fi
	done




	# Continue with date and result entry as before...
	current_year="$(date | tr -s ' ' ' ' | cut -d' ' -f7)"
	current_month="$(date | tr -s ' ' ' ' | cut -d' ' -f2)"
	# convert month from (Jan, Apr,...) to numbers (1,2,...)
	case "$current_month" in
	"Jan") current_month=1 ;;
	"Feb") current_month=2 ;;
	"Mar") current_month=3 ;;
	"Apr") current_month=4 ;;
	"May") current_month=5 ;;
	"Jun") current_month=6 ;;
	"Jul") current_month=7 ;;
	"Aug") current_month=8 ;;
	"Sep") current_month=9 ;;
	"Oct") current_month=10 ;;
	"Nov") current_month=11 ;;
	"Dec") current_month=12 ;;
	esac




	# Enter starting date then check YYYY_MM format
	while true; do
    	echo ""
    	echo "Enter starting date in YYYY-MM format"
    	read starting_date
    	if [ $(echo "$starting_date" | grep "\<[0-9]\{4\}\-[0-9]\{2\}\>") ]; then
        	starting_year="$(echo "$starting_date" | cut -c1-4)"
        	starting_month="$(echo "$starting_date" | cut -c6-7)"




        	# Check if currentDate < testDate (means not existed!)
        	if [ "$current_year" -lt "$starting_year" ]; then
            	echo "Sorry, year must be before than or equal to $current_year"
            	continue
        	elif [ "$current_year" -eq "$starting_year" ]; then
            	if [ "$current_month" -lt "$starting_month" ]; then
                	echo "In current year, starting month must be before current month"
                	continue
            	else
                	break # Accepted
            	fi
        	else
            	if [ "$starting_month" -gt "12" -o "$starting_month" -le "0" ]; then
                	echo "Enter a month 1-12"
                	continue
            	else
                	break
            	fi
        	fi
    	else
        	echo ""
        	echo "Sorry, use YYYY-MM format"
    	fi
	done




	# Result (can be floating point or integer)
	while true; do
    	echo -n "Enter Result: "
    	read result




    	if echo "$result" | grep -qE '^[0-9]*(\.[0-9]*)?$'; then
        	# To check for the entered result from the test record valid Results
        	break
    	else
        	echo "ERROR!! Please enter a valid number ONLY."
    	fi
	done




	# Status (Pending/Completed/Reviewed)
	while true; do
    	echo -n "Enter Status (Pending/Completed/Reviewed): "
    	read status




    	if [ "$(echo "$status" | grep '^\(Pending\|Completed\|Reviewed\)$')" ]; then
        	break
    	else
        	echo "ERROR!! Please enter one of the following ONLY: Pending, Completed, Reviewed."
    	fi
	done




	# The final output should be in the form "YYYY-MM"
	formatted_date="$starting_year-$starting_month"




	# Now, when you print $formatted_date, it will be in the correct format "YYYY-MM"
	echo "$patient_id: $test_Record_name, $formatted_date, $result, $unit, $status" >>MedicalRecord.txt
	echo "Record added successfully :)"
}




delete_test() {
	# ask for ID and validate it exists in the recordsfile.txt
	while true; do
    	echo -n "Enter Patient ID (7 Digits Only): "
    	read patient_id




    	if [ "$(echo "$patient_id" | grep '^[0-9]\{7\}$')" ]; then
        	if grep "^$patient_id: " MedicalRecord.txt >/dev/null; then
            	break # which means that it does exist ..
        	else
            	echo "ERROR!! The patient ID Does NOT found in MedicalRecords. Please try again with existed ID."
        	fi
    	else
        	echo "ERROR!! Please try again using (7 digits) ONLY!"
    	fi
	done




	# now asks for test Name and validate it exists for that given patient ID
	while true; do
    	echo -n "Enter Test Name: "
    	read test_Record_name




    	if grep "^$patient_id: $test_Record_name," MedicalRecord.txt >/dev/null; then
        	break # which means it found it then continue
    	else
        	echo "ERROR!! Test Name not found for this Patient ID in MedicalRecord. Please try again using maybe Hgb, BGT, LDL, systole, diastole .."
    	fi
	done




	# now asks for the test date in YYYY-MM format and validate it
	while true; do
    	echo -n "Enter the Date (YYYY-MM): "
    	read test_Record_Date




    	if grep "^$patient_id: $test_Record_name, $test_Record_Date," MedicalRecord.txt >/dev/null; then
        	break # which also means that it found this date with this format
    	else
        	echo "ERROR!! The test Date Does NOT found for this Test Name and Patient ID in MedicalRecord. Please try again with included date!"
    	fi
	done




	# confirm deletion
	while true; do
    	echo -n "Are you sure you want to delete this record? (yes/no): "
    	read confirmation
    	if [ "$confirmation" = "yes" ]; then
        	# delete the specific line from MedicalRecord.txt
        	grep -v "^$patient_id: $test_Record_name, $test_Record_Date," MedicalRecord.txt >MedicalRecord.tmp && mv MedicalRecord.tmp MedicalRecord.txt
        	echo "Record deleted successfully :)"
        	break
    	elif [ "$confirmation" = "no" ]; then
        	echo "Deletion canceled."
        	break
    	else
        	echo "Invalid input, please type 'yes' or 'no'."
    	fi
	done
}



# Display main menu
while true; do
	printf "\nMedical Test Management System\n"
	echo "1. Add a new medical test record"
	echo "2. Search for a test by patient ID"
	echo "3. Search for abnormal tests"
	echo "4. Calculate average test value"
	echo "5. Update an existing test result"
	echo "6. Delete a test"
	echo "7. Exit"
	echo -n "Please enter your choice: "
	read choice
	case $choice in
	1)
    	Add_Test_Record #check
    	;;
	2)
    	search_test_by_id
    	;;
	3)
    	search_for_all_upnormal_tests
    	;;
	4)
    	Average_test_value
    	;;
	5)
    	update_test_result #check
    	;;
	6)
    	delete_test # check
    	;;
	7)
    	break
    	;;
	*)
    	echo "Invalid choice, please try again."
    	;;
	esac
done












