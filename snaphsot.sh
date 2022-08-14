#!/bin/bash

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT


keep_snapshots=4
snapshot_name=$( date '+%F_%H:%M:%S' )
data_dir="/mnt/main/data"

echo 
echo =========================================
echo
echo  Starting snapshoting
echo

for i in "$@"
do
    x=$i
    z=$i
    g=$i
    d=$i
    t=$i

    echo -----------------------------------------
    echo Processing $i...
    echo 
    echo Stoping containers:
    echo 
    
    processes=$(docker ps | grep $g | awk  '{print $1}')
    #echo $processes
    processes=($processes)
    for (( i=0; i<${#processes[@]}; i++ ))
    do
        docker container stop "${processes[$i]}"
        echo Container "${processes[$i]}" has been stoped
    done
    echo 
    
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
    sudo btrfs subvolume snapshot $data_dir/$d $data_dir/.snapshots/$d$snapshot_name
    echo Snapshot $x$snapshot_name has been created
    
    for (( i=0; i<${#processes[@]}; i++ ))
    do
        docker start "${processes[$i]}"
        echo Container "${processes[$i]}" has been restarted
    done

    echo -----------------------------------------
done

echo
echo Backuping process finished
echo =========================================
echo
