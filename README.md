# Synopsis

This is a very basic PowerShell Script that we use to choose from a list of dishes what to cook on the weekend. All you need to run this is fill out the variables needed and configure a scheduled job on one of your Windows machines.

# Variables needed (as shown in the script):
 
- where to store the database?
  - $db_path = "C\tmp"

- settings for smtp
  - $smtp_address = "your smtp mail adress"
  - $smtp_login = "your smtp login"
  - $smtp_password = "your smtp password"
  - $smtp_server = "your smtp server"

- who shall receive the mail
  - $mail_recipients = "test1@gmail.com","test2@gmail.com"

- main food array, enter food choices here (12+ choices recommended)
  - $food_array =
  - "food_choice_1",
  - "food_choice_2",
  - "food_choice_3",
  - "food_choice_4",
  - "food_choice_5",
  - "food_choice_6",
  - "food_choice_7",
  - "food_choice_8",
  - "food_choice_9",
  - "food_choice_10",
  - "food_choice_11",
  - "food_choice_12"
  
# Function

The script itself will prioritize the dishes by frequency and use the dishes with the lowest frequency first. It will also not use the last X dishes and make sure there will not be the same dish on Saturday and Sunday. Me and my wife both get a mail every Thursday morning (before we do our grocery shopping for the weekend) with what to cook.
