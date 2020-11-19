#!/bin/bash

prefix=$(dirname $(realpath $0))
WATCHDOG=$prefix/watchdog.sh

if ! [ -f $prefix/config.sh ]; then
    
    while ! [ -f $bbb_path/capture-full-replay.sh ] ; do
	echo "Please enter the path to capture-full-replay.sh:"
	read -e -p "BBB path: " bbb_path
    done
    bbb_path=$(realpath $bbb_path)

    
cat 2>/dev/null > $prefix/config.sh <<EOF
#!/bin/bash

BBB_DOWNLOADER_ROOT=$bbb_path
INPUT_DIR=$prefix/to_be_downloaded
OUTPUT_DIR=$prefix/downloads
MAX_CONCURRENT_TASKS=8
EOF

fi

cat 2>/dev/null > /lib/systemd/system/bbb_downloader.service  <<EOF
[Unit]
Description=BBB downloader
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=$SUDO_USER
ExecStart=/bin/bash $WATCHDOG

[Install]
WantedBy=multi-user.target

EOF

if [ $? -ne 0 ]; then
    echo Please run the script as sudo:
    echo sudo $0 $@
    exit 1
fi

systemctl restart bbb_downloader
