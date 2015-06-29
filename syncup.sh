#!/bin/sh

# Sync local user data to network home
# 
# Created by Amsys
#
# Use at your own risk.  Amsys will accept
# no responsibility for loss or damage
# caused by this script.

############## Set Variables

logfile="/Library/Amsys/syncData.log"
	# Set the path to your log file

filterFile="/Library/Amsys/syncup_filter_exclude"
	# Set the path to your log file

# Create a function to echo output and to write to a log file
writelog()
{
	echo "${1}"	"${2}" "${3}" "${4}"
	echo $(date) "${1}"	"${2}" "${3}" "${4}" >> $logfile
}

writelog "STARTING: User data sync"

############## Sync Preparation

syncSource="/Users/$USER/"
	# Source folder for the rsync command (should be /Users/$USER)
	
syncDest="/Volumes/$USER"
	# Destination folder for the rsync command (should be /Volumes/$USER)

sleep 2

############## Free space check

writelog "Checking whether sync data will fit in the network drive"

syncsize=`rsync -nhuzrlv --progress --filter="merge $filterFile" $syncSource $syncDest | grep "total size" | awk '{ print $4; }' | sed 's/M//g' | awk '{printf("%d\n",$1 + 0.5)}'`
	# Gets the size of the data to sync.
	# Options used:
		# n - (Dry run) show what would have been transferred
		# u - Skip files that are newer on the receiver
		# z - Compress file data during the transfer
		# r - Recurse into directories
		# l - Copy symlinks as symlinks
		# v - Increase verbosity
networkhomecapacity=`df -hm $syncDest | awk 'NR==2 {print $4}'`
	# Gets the amount of free space in the user's network home 
	# (based on quota or physical storage space)
writelog "There is ${syncsize}MB to sync"
writelog "There is ${networkhomecapacity}MB of free space in the network home for the user $USER"

if [ $syncsize -lt $networkhomecapacity ];
	then
		writelog "There is sufficient space in the network home for $USER for this sync."
		writelog ""
		writelog "##### Starting Sync #####"
		writelog "Syncing from $syncSource to $syncDest"

############## Start Sync Loop

counter=`ls $syncSource | grep -c "[A-z 0-9]"`
	# Outputs the number of folders in the specified location

while [ $counter -ne 0 ]

	do
		source=`ls $syncSource | grep "[A-z 0-9]" | head -$counter | tail -1`
			# Gets the sync folder name by counter number
				
		rsync -uhzrlv --progress --filter="merge $filterFile" $syncSource $syncDest 2>> /tmp/${USER}syncerror
				
		syncerror=`cat /tmp/${USER}syncerror | grep "failed" | sed 's/rsync: send_files failed to open \"//g' | sed 's/"//g' | sed 's/.\{4\}$//'`
		errorcount=`cat /tmp/${USER}syncerror | grep -c "failed"`
		rm /tmp/${USER}syncerror

			# Error checking starts below this line
			if [ $errorcount -ne 0 ] ; then
			    	writelog "#### ERROR #### Unable to sync $syncerror"
	    	   		writelog "$syncerror"
			else 
					writelog "$syncSource/$source synced successfully."
			fi
			# Error checking completed

		counter=$(( $counter - 1 ))
			# Reduces the counter by 1

done

writelog "##### Sync Complete #####"
writelog ""		
		
############## End Sync Loop

else

	writelog "There is insufficient space in ${USER}'s network drive to synchronise the local files."
		
fi	

writelog "Script complete"
############## Script complete

exit 0