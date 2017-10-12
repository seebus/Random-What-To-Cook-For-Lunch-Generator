﻿# date
$date = Get-Date -Format "dd.MM.yy"

# main food array
$food_array = "Griechischer Eintopf","Hot Dogs oder Burger","Geschnetzeltes mit Schmorgurke","den Joker","Lasagne","La Vialla","selbstgemachte Pizza","Pizza vom Lieferdienst","Türkische Suppe","Gulasch","Geschnetzeltes","Gefüllte Paprika","Spaghetti a la Mama","Spaghetti a la Papa","Chilli","Reis mit gelber Soße","Köttbullar","Fischstäbchen mit Pommes","Pellkartoffeln mit Hering","Nudelauflauf","Gemüsepfanne mit Reis","Rouladen","Blumenkohl mit Hollandaise","Pellkartoffeln mit Quark","Bandnudeln mit Hähnchenfleisch","Labskaus","Frikadellen","Tomatenreis mit Bifteki","Bulgursalat mit Zucuk"

# reset arrays
$food_array_calculate_minimum = @()
$food_array_priority = @()
$food_array_non_priority = @()

# calculate food with the lowest usage till date and therefor highest priority
foreach ($food in $food_array)
    {
    $food_array_calculate_minimum += ((Get-Content C:\tmp\food.log | Select-String -Pattern $food) | Measure-Object).count
    }
    $food_minimum = ($food_array_calculate_minimum | Measure-Object -Minimum).Minimum

# create new array with the highest priority food
foreach ($food in $food_array)
    {
    $food_count = ((Get-Content C:\tmp\food.log | Select-String -Pattern $food) | Measure-Object).count
    if ($food_count -eq $food_minimum)
        {
        $food_array_priority += $food
        }
    else
        {
        $food_array_non_priority += $food
        }
    }

# watch the food array priority count
$food_array_priority_watcher = (($food_array_priority | Measure-Object).Count)

# calculate what's to eat for the weekend from high priority food array
$food_sa = $food_array_priority | Get-Random

# if only one food in the priority array is take another one from the non priorty array
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

$food_log = Get-Content C:\tmp\food.log
$food_sa_count = ($($food_log | Select-String -Pattern $food_sa) | Measure-Object).count
$food_su_count = ($($food_log | Select-String -Pattern $food_su) | Measure-Object).count

# write food to database and attach date and count for statistics
"$food_sa;$date;$food_sa_count" | Out-File C:\tmp\food.log -Append
"$food_su;$date;$food_su_count" | Out-File C:\tmp\food.log -Append

# who shall receive the mail
$mail_recipients = "test@gmail.com"

$pw = "your-smtp-password" | ConvertTo-SecureString -asPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential "your-smtp-login", $pw

Send-MailMessage -to $mail_recipients -subject "Random-What-To-Cook-For-Lunch-Generator" -body "
Hey!<br/>
<br/>
The Random-What-To-Cook-For-Lunch-Generator decided! Saturday we are having <b>$food_sa</b> and on Sunday <b>$food_su</b>!<br/>
<br/>
" -smtpserver your-smtp-server -Credential $cred -from "your-mail-address" -Port 25 -Encoding ([System.Text.Encoding]::UTF8) -BodyAsHtml