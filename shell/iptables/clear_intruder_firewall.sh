#!/bin/bash

chain_name=INTRUDER-INPUT

sendemail()
{
	NTIME=$(date +'%Y/%m/%d %H:%M:%S')
	body="$NTIME iptable top 10 rules today:\n
	$*"
	mail_sender=$(whoami)@$(hostname)
	recipient="liuhongguang@kankan.com"
	cc="guoshenglong@kankan.com,yuanzhe@kankan.com"
	subject="#WARN_INTRUDER#suspect intruder from websession nginx"
	/usr/local/monitor-base/bin/sendEmail -s mail.kankan.com  -f $mail_sender -xu liuhongguang@kankan.com -xp "g2441314\$" -t "$recipient" -cc "$cc" -u "$subject" -o message-charset=utf8 -m "$body"
}

rules=$(iptables -L $chain_name | head -n 12 2>/dev/null)
if [ $? -eq 0 ]; then
	sendemail $rules
else
	iptables -N $chain_name
fi

# flush (delete) all rules in chain $chain_name
iptables -F $chain_name
