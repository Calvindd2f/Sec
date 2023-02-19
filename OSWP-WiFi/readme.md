Increase TX Power for Wi-Fi adapter ins Kali/Blackarch.
Ideally to 30 mBm but can go to 36.


The article “How to increase TX-Power of Wi-Fi adapters in Kali Linux” discusses the theory and different approaches to increasing the TX Power to 30.00 dBm and removing restrictions on the use of blocked Wi-Fi channels. The article is quite long and some points are already outdated. Nevertheless, it is recommended for review, as it addresses such questions as: 1) why it is needed at all; 2) how to increase power by changing the region; 3) why txpower of some Wi-Fi adapters does not rise above a certain value.

patch (https://github.com/buildroot/buildroot/tree/master/package/crda)


### How to Boost TX Power for Wi-Fi in Kali Linux  
  
Create the wireless-regdb-pentest.sh file:
```sh
gedit wireless-regdb-pentest.sh
```

And copy the following into it:
```sh
#!/bin/bash

which pacman > /dev/null 2>&1
if [[ $? -eq '0' ]]; then
    sudo pacman -Sy iw libgcrypt libnl sh systemd python-attrs python-m2crypto python-pycryptodomex --needed --noconfirm
else
    which apt > /dev/null 2>&1
    if [ $? -eq '0' ]; then
        sudo apt update
        sudo apt -y install python3-m2crypto libssl-dev libnl-3-dev pkg-config libgcrypt20-dev python3-pycryptodome libnl-genl-3-dev
    else
        echo 'Man, I am really lost...'
        exit 1;
    fi
fi
 
wget 'https://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/crda.git/snapshot/crda-4.14.tar.gz'
wget 'https://www.kernel.org/pub/software/network/wireless-regdb/wireless-regdb-2020.04.29.tar.xz'
curl 'https://aur.archlinux.org/cgit/aur.git/plain/0001-Makefile-Don-t-run-ldconfig.patch?h=wireless-regdb-pentest' > 0001-Makefile-Don-t-run-ldconfig.patch
curl 'https://aur.archlinux.org/cgit/aur.git/plain/0001-Makefile-Link-libreg.so-against-the-crypto-library.patch?h=wireless-regdb-pentest' > 0001-Makefile-Link-libreg.so-against-the-crypto-library.patch
curl 'https://aur.archlinux.org/cgit/aur.git/plain/crda.conf.d?h=wireless-regdb-pentest' > crda.conf.d
curl 'https://aur.archlinux.org/cgit/aur.git/plain/db.txt?h=wireless-regdb-pentest' > db.txt
curl 'https://aur.archlinux.org/cgit/aur.git/plain/set-wireless-regdom?h=wireless-regdb-pentest' > set-wireless-regdom
curl https://raw.githubusercontent.com/buildroot/buildroot/master/package/crda/0001-crda-support-python-3-in-utils-key2pub.py.patch > 0001-crda-support-python-3-in-utils-key2pub.py.patch
 
tar xf wireless-regdb-2020.04.29.tar.xz
tar xvzf crda-4.14.tar.gz
 
cd crda-4.14
patch -p1 -i ../0001-Makefile-Link-libreg.so-against-the-crypto-library.patch
patch -p1 -i ../0001-Makefile-Don-t-run-ldconfig.patch
patch -p1 -i ../0001-crda-support-python-3-in-utils-key2pub.py.patch
sed -i 's/#!\/usr\/bin\/env python/#!\/usr\/bin\/env python3/' ./utils/key2pub.py
 
cp ../db.txt ../wireless-regdb-2020.04.29/db.txt
 
export CC=gcc
export CXX=g++
cd ../wireless-regdb-2020.04.29/
make mrproper
export REGDB_AUTHOR=root
sed -i 's/#!\/usr\/bin\/env python/#!\/usr\/bin\/env python3/' *.py
make
cd ../crda-4.14
cp ../wireless-regdb-2020.04.29/root.key.pub.pem pubkeys/
 
sed -i 's/python utils\/key2pub.py/python3 utils\/key2pub.py/' Makefile
make REG_BIN=../wireless-regdb-2020.04.29/regulatory.bin
 
sudo install -d -m755 /usr/lib
sudo mkdir -p /usr/lib/crda/pubkeys
sudo make DESTDIR="" UDEV_RULE_DIR=/usr/lib/udev/rules.d/ SBINDIR=/usr/bin/ install
cd ../wireless-regdb-2020.04.29/
 
sudo install -D -m644 ../wireless-regdb-2020.04.29/root.key.pub.pem /usr/lib/crda/pubkeys/root.key.pub.pem
sudo install -D -m644 ../wireless-regdb-2020.04.29/regulatory.bin /usr/lib/crda/regulatory.bin
 
# let’s skip this bashisms
# (if LD_LIBRARY_PATH=../crda-4.14 ../crda-4.14/regdbdump /usr/lib/crda/regulatory.bin > /dev/null) && (echo "Regulatory database verification was succesful.") || (echo "Regulatory database verification failed.")
 
sudo install -d -m755 /usr/lib/firmware
sudo install -D -m644 ../wireless-regdb-2020.04.29/regulatory.db /usr/lib/firmware/regulatory.db
sudo install -D -m644 ../wireless-regdb-2020.04.29/regulatory.db.p7s /usr/lib/firmware/regulatory.db.p7s
sudo install -D -m644 ../wireless-regdb-2020.04.29/LICENSE /usr/share/licenses/wireless-regdb/LICENSE
sudo install -D -m644 ../wireless-regdb-2020.04.29/regulatory.bin.5 /usr/share/man/man5/regulatory.bin.5
sudo install -D -m644 ../crda.conf.d /etc/conf.d/wireless-regdom
 
# sudo su # if you type the commands, you have to be root now
for dom in $(grep ^country ../wireless-regdb-2020.04.29/db.txt | cut -d' ' -f2 | sed 's|:||g'); do echo "#WIRELESS_REGDOM=\"${dom}\"" >> /etc/conf.d/wireless-regdom.tmp; done
sort -u /etc/conf.d/wireless-regdom.tmp >> /etc/conf.d/wireless-regdom
rm /etc/conf.d/wireless-regdom.tmp
# CTRL+d
 
sudo install -D -m644  ../wireless-regdb-2020.04.29/LICENSE "/usr/share/licenses/wireless-regdb/LICENSE"
 
# Not sure if this is necessary since the crda package is already installed above. 

cd ../crda-4.14
sudo make install
```

execute it like below
```sh
sudo bash wireless-regdb-pentest.sh
```

Reboot PC
