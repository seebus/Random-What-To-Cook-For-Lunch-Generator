 ############### SETTINGS ###############
 
 # where to store the database?
$db_path = "C\tmp"

#settings for smtp
$smtp_address = "your smtp mail adress"
$smtp_login = "your smtp login"
$smtp_password = "your smtp password"
$smtp_server = "your smtp server"

# who shall receive the mail
$mail_recipients = "test1@gmail.com","test2@gmail.com"

# main food array, enter food choices here
$food_array =
"food_choice_1",
"food_choice_2",
"food_choice_3",
"food_choice_4",
"food_choice_5",
"food_choice_6"

############### /SETTINGS ###############

# date
$date = Get-Date -Format "dd.MM.yy"

# reset arrays
$food_array_calculate_minimum = @()
$food_array_priority = @()
$food_array_non_priority = @()

# calculate food with the lowest usage till date and therefore highest priority
foreach ($food in $food_array)
    {
    $food_array_calculate_minimum += ((Get-Content C:\tmp\food.log | Select-String -Pattern $food) | Measure-Object).count
    }
    $food_minimum = ($food_array_calculate_minimum | Measure-Object -Minimum).Minimum

# create new array with the highest priority food and make sure the food wasn't suggested the last X weeks

$last_meals = (Get-Content $db_path\food.log | Select-Object -Last 5) -replace ';.*',''

foreach ($food in $food_array)
    {
    $food_count = ((Get-Content $db_path\food.log | Select-String -Pattern $food) | Measure-Object).count
    if ($food_count -eq $food_minimum -and $food -notmatch $last_meals)
        {
        $food_array_priority += $food
        }
    else
        {
        $food_array_non_priority += $food
        }
    }
    
# watch the food array priority count, if only one food is left we need to act
$food_array_priority_watcher = (($food_array_priority | Measure-Object).Count)

# calculate what's to eat for the weekend from high priority food array
$food_sa = $food_array_priority | Get-Random

# if only one food in the priority array is left take another one from the non priorty array to make the do loop work
if ($food_array_priority_watcher -eq 1)
    {
    $food_su = ($food_array_non_priority | Get-Random)
    }
else
    {
    $food_su = $food_array_priority | Get-Random
    }

# make sure we do not have the same meal on Sa and Su
if ($food_su -eq $food_sa)
    {
    do {$food_su = $food_array_priority | Get-Random} while ($food_su -eq $food_sa)
    }

# count the meals and make them available for the statistics
$food_log = Get-Content $db_path\food.log
$food_sa_count = ($($food_log | Select-String -Pattern $food_sa) | Measure-Object).count
$food_su_count = ($($food_log | Select-String -Pattern $food_su) | Measure-Object).count

# write food to database and attach date and count for statistics
"$food_sa;$date;$food_sa_count" | Out-File $db_path\food.log -Append
"$food_su;$date;$food_su_count" | Out-File $db_path\food.log -Append

# set mail credentials
$pw = $smtp_password | ConvertTo-SecureString -asPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential $smtp_login, $pw

#send mail to recipients
Send-MailMessage -to $mail_recipients -subject "Random-What-To-Cook-For-Lunch-Generator" -body "
Hey!<br/>
<br/>
The Random-What-To-Cook-For-Lunch-Generator decided! Saturday we are having <b>$food_sa</b> and on Sunday <b>$food_su</b>!<br/>
<br/>
" -smtpserver $smtp_server -Credential $cred -from $smtp_address -Port 25 -Encoding ([System.Text.Encoding]::UTF8) -BodyAsHtml
