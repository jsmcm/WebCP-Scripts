#!/bin/bash

mailDirectory=$1
emailAddress=$2

date=$(date +"%a, %d %b %Y %H:%M:%S +0200")
hostName=`hostname`

if [ "$mailDirectory" = "" ]
then
	echo "its blank"
	exit
fi

mailName="1111111111.2222222222.$hostName"

if [ -d $mailDirectory ] 
then
	echo "Return-path: <$emailAddress>" >> $mailDirectory/$mailName
	echo "Envelope-to: $emailAddress" >> $mailDirectory/$mailName
	echo "Delivery-date: $date" >> $mailDirectory/$mailName
	echo "To: John <$emailAddress>" >> $mailDirectory/$mailName
	echo "From: Mail System <$emailAddress>" >> $mailDirectory/$mailName
	echo "Date: $emailAddress" >> $mailDirectory/$mailName
	echo "MIME-Version: 1.0" >> $mailDirectory/$mailName
	echo "Content-Type: text/plain; charset=utf-8; format=flowed" >> $mailDirectory/$mailName
	echo "Content-Transfer-Encoding: 7bit" >> $mailDirectory/$mailName
	echo "Content-Language: en-US" >> $mailDirectory/$mailName
	echo "Subject: Important information about your new mail account" >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "Hi, your new mail account is set up and if you're reading this, working!" >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "We wanted to highlight some important information regarding spam!" >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "If you've set your mailbox up as an IMAP account then you should see a Spam folder (if not, close your mail program and reopen it)." >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "When you get spam please don't delete it, rather move it to this spam folder. This will allow our system to learn what you consider to be spam over time and hopefully this will lead to a reduction in the number of spam mails you receive." >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "How long does it take to work?" >> $mailDirectory/$mailName
	echo "===================" >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "The spam learning system requires at least 200 emails before it will do anything so this might take a while. What we recommend you do is log into your control panel and set your spam threshold to a high level, like 100. That way you'll receive loads more spam than usual. While that might be annoying it will help you train your spam filters quicker. Once you have 200 mails in the spam folder you can turn that back to something reasonable (like 50??)." >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "My spam mails disappear" >> $mailDirectory/$mailName
	echo "===============" >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "Mail you put into spam is deleted once our systems have learned about it, so only put mail into spam if its really spam and you don't mind it being deleted. On average we scan once a day." >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "That's all," >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "Regards," >> $mailDirectory/$mailName
	echo "" >> $mailDirectory/$mailName
	echo "Your mail server!" >> $mailDirectory/$mailName

fi



