#!/bin/bash
clear
sleep 1
if [ -e getalmexinfo.json ]
then
	echo " "
	echo "Script running already?"
	echo " "

else
echo "blah" > getalmexinfo.json

THISHOST=$(hostname -f)

sudo apt-get install jq pwgen bc -y

#killall almexd
#rm -rf almex*
#rm -rf .almex*

mkdir ~/almex
cd ~/almex
wget https://github.com/AlmexCoin/almex/releases/download/1.0.0.1/Linux_bin.tar.gz
tar -zxvf Linux_bin.tar.gz
rm Linux_bin.tar.gz
cd ~

mkdir ~/.almex
RPCU=$(pwgen -1 4 -n)
PASS=$(pwgen -1 14 -n)
EXIP=$(curl ipinfo.io/ip)

printf "rpcuser=rpc$RPCU\nrpcpassword=$PASS\nrpcport=10002\nrpcthreads=8\nrpcallowip=127.0.0.1\nbind=$EXIP:10001\nmaxconnections=32\ngen=0\nexternalip=$EXIP\ndaemon=1\n\n" > ~/.almex/almex.conf

~/almex/almexd -daemon
sleep 20
MKEY=$(~/almex/almex-cli masternode genkey)

~/almex/almex-cli stop
printf "masternode=1\nmasternodeprivkey=$MKEY\n\n" >> ~/.almex/almex.conf
sleep 60
~/almex/almexd -daemon
sleep 10
~/almex/almex-cli stop
sleep 30

mkdir ~/backup
cp ~/.almex/almex.conf ~/backup/almex.conf
cp ~/.almex/wallet.dat ~/backup/wallet.dat

crontab -l > mycron
echo "@reboot ~/almex/almexd -daemon >/dev/null 2>&1" >> mycron
crontab mycron
rm mycron

echo "Reindexing blockchain..."

sleep 5
rm ~/.almex/mncache.dat
rm ~/.almex/mnpayments.dat
sleep 35
~/almex/almexd -daemon -reindex
sleep 2

################################################################################

sleep 10

BLKS=$(curl http://explorer.almex.team/api/getblockcount)

while true; do
WALLETBLOCKS=$(~/almex/almex-cli getblockcount)
if (( $(echo "$WALLETBLOCKS < $BLKS" | bc -l) )); then
	clear
	echo " "
	echo " "
	echo "  Keep waiting..."
	echo " "
	echo "    Blocks so far: $WALLETBLOCKS"
	echo " "
	echo " "
	echo " "
	sleep 5
else
	echo " "
	echo " "
	echo "    Complete!"
	echo " "
	echo " "
	sleep 5
	break
fi
	echo " "
	echo " "
	echo " "
done


echo "Now wait for AssetID: 999..."
sleep 1

while true; do

MNSYNC=$(~/almex/almex-cli mnsync status)
echo "$MNSYNC" > mnalmexsync.json
ASSETID=$(jq '.RequestedMasternodeAssets' mnalmexsync.json)

if (( $(echo "$ASSETID < 900" | bc -l) )); then
	clear
	echo " "
	echo " "
	echo "  Keep waiting..."
	echo " "
	echo "  Looking for: 999"
	echo "      AssetID: $ASSETID"
	echo " "
	echo " "
	echo " "
	sleep 5
else
	echo " "
	echo " "
	echo "    Complete!"
	echo " "
	echo " "
	sleep 5
	break
fi
	echo " "
	echo " "
	echo " "
done

###########################

rm mnalmexsync.json

echo " "
echo " "
echo " "

sleep 2
echo "=================================="
echo " "
echo "Your masternode.conf should look like:"
echo " "
echo "MNxx $EXIP:10001 $MKEY TXID VOUT"
echo " "
echo "=================================="
echo " "
sleep 3
echo " "
echo "  - You can now Start Alias in the windows wallet!"
echo " "
echo "       Thanks for using MadStu's Install Script"
echo " "

rm getalmexinfo.json
cp ~/.almex/masternode.conf ~/backup/masternode.conf

fi
