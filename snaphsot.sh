#!/bin/bash

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT


keep_snapshots=4
var=$(sudo btrfs subvolume list /mnt/main | grep nextcloud | wc -l)
snapshot_name=$( date '+%F_%H:%M:%S' )
data_dir="/mnt/main/data"

echo
echo  Starting snapshoting...

for i in "$@"
do
    echo  Processing $i...
    x=$i
    z=$i
    execute="sudo btrfs subvolume snapshot $data_dir/$i $data_dir/.snapshots/$x$snapshot_name"
    snapshot_list=$(sudo btrfs subvolume list /mnt/main | grep ".snapshots/$z")
    snapshot_number=$(sudo btrfs subvolume list /mnt/main | grep ".snapshots/$z" | wc -l)
    snapshot_files={}

    if (( $snapshot_number >= $keep_snapshots));
    then
        echo "Number of kept snapshots has been reached:" $keep_snapshots
        oldest_snapshot=$(ls -ltr /mnt/main/data/.snapshots/ | grep $x | tail -1 | awk '{print $9}')
        echo Deleting oldest snapshot: $oldest_snapshot
        sudo btrfs subvolume delete $data_dir/.snapshots/$oldest_snapshot
    fi
    echo
    echo Creating snapshot...
    sudo btrfs subvolume snapshot $data_dir/$i $data_dir/.snapshots/$x$snapshot_name
    echo
done

echo
echo Backuping process finished
