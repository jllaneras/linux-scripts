#!/bin/sh

# Backup script based on: http://www.interlinked.org/tutorials/rsync_time_machine.html

backups_dir=$1
backups_dir=${backups_dir%/} # remove trailing slash if any to avoid double slashes

if [ $# -lt 1 ]; then 
    echo "No destination defined. Usage: $0 destination" >&2
    exit 1
elif [ $# -gt 1 ]; then
    echo "Too many arguments. Usage: $0 destination" >&2
    exit 1
elif [ ! -d "$backups_dir" ]; then
   echo "The destination path does not exist: $backups_dir" >&2
   exit 1
elif [ ! -w "$backups_dir" ]; then
   echo "Directory not writable: $backups_dir" >&2
   exit 1
fi

# run this process with real low priority
ionice -c 3 -p $$
renice +12  -p $$

source_dir=/*
backup_name=backup-`date "+%Y%m%dT%H%M%S"`
backup_path=$backups_dir/$backup_name
start=$(date +%s)

rsync \
	--human-readable \
	--archive \
	--partial \
	--progress \
	--one-file-system \
	--xattrs \
	--inplace \
	--delete \
	--delete-excluded \
	--exclude-from=$backups_dir/exclude.conf \
	--link-dest=../current \
	$source_dir $backup_path.incomplete 2> $backup_path.log

mv $backup_path.incomplete $backup_path

# Update link to the last backup
rm -f $backups_dir/current
ln -s $backup_name $backups_dir/current

finish=$(date +%s)
echo "Total time: $(( ($finish - $start) / 60 )) minutes, $(( ($finish - $start) % 60 )) seconds" | tee -a $backup_path.log
