#!/bin/sh
#
# PaperCut Hive Uninstall Script
#
agreed=
answered=

if [ "$1" == "-y" ]; then
    agreed=1
    answered=1
fi

while [ -z "${answered}" ]; do
        echo
        echo
        echo "Would you like to uninstall PaperCut Hive?  [yes or no] "
        read reply leftover
        case $reply in
            [yY] | [yY][eE][sS])
                agreed=1
                answered=1
                ;;
            [nN] | [nN][oO])
                answered=1
                read
                ;;
        esac
done
if [ ! -z "${agreed}" ]; then

    if [ "${USER}" != "root" ]; then
        echo "You must be an administrator user to run this program."
        echo "Enter your password if requested..."
    fi

    sudo sh -c "(
        echo 'Uninstalling...'
        #
        # Stop and disable services
        #
        '/Library/PaperCut Hive/pc-edgenode-service' stop
        '/Library/PaperCut Hive/pc-edgenode-service' uninstall

        lpadmin -x PAPERCUT_POCKET_PRINTER
        su - '@user_name@' -c '\"/Users/@user_name@/Library/PaperCut Hive/pc-print-client-service\" stop'
        su - '@user_name@' -c '\"/Users/@user_name@/Library/PaperCut Hive/pc-print-client-service\" uninstall'
        rm -rf '/Users/@user_name@/Library/PaperCut Hive'

        sleep 5

        '/Library/PaperCut Hive/pc-edgenode-service' command uninstall

        rm -rf '/Library/PaperCut Hive'
    )"


    echo "PaperCut Hive is removed from your computer successfully. You can close this window now."
fi
