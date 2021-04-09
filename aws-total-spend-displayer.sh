#!/usr/bin/bash

# Simple script to fetch AWS Month-to-Date spend and print it out in AUD 

# Capture Month-to-Date Spend Total using AWS CLI

max=1

echo "AWS Max Spend is $max dollars"

aws_billing_ammount_monthy=$(aws ce get-cost-and-usage \
			--time-period Start=$(date -u -d "$TODAY" '+%Y-%m-01'),End=$(date -u +"%Y-%m-%d" --date="+1 day") \
			--granularity MONTHLY \
			--metrics UnblendedCost \
			--output text | sort -r -k 3 | head -n 1 | cut -f 2)

# Use free.currconv.com API to retrieve conversion from USD to AUD - FREE API key required, and added some transformation to obtain rate value
conversion_value_usd_to_aud=$(curl -s -X GET 'https://free.currconv.com/api/v7/convert?q=USD_AUD&compact=ultra&apiKey=<API_TOKEN>' 2>&1 | sed -E 's/.*"USD_AUD":"?([^,"]*)"?.*/\1/' | sed 's/}//' )

# Multiply Monthly Spend total AUD into US Dollar 
total=$(expr $aws_billing_ammount_monthy*$conversion_value_usd_to_aud | bc)

# print the total in AUD
echo -e "AWS Monthly Total Spend is (AUD): " $total

date=$(date +"%d-%m-%Y-%H:%M")
#echo "Todays Date:" $date "AWS Total Cost:" $total >> aws-total-spend.csv
convert=$(echo "Date" $date "Cost" $total)
# echo "Date" "Time"  | sed -E 's/ +/,/g' > aws-total-spend.csv -- work in progress for headers later
echo $convert | sed -E 's/ +/,/g' >> aws-total-spend.csv

totaltoint=${total%%.*}
RED='\033[0;31m'

if  [[ "$totaltoint" -gt "$max" ]];
	then 
		echo -e "${RED}AWS total spend is above max"
	else 
		echo -e "AWS spend is below max"
fi





