#!/bin/bash
#
# test for phc undervolting

_installaur mprime phc-intel

cat > /root/phc_mprime_test.sh << EOF
#!/bin/bash

# Find lowest vids for PHC so that mprime doesn’t find errors.
# Shouldn’t crash the computer, but might.

#####################################
# Parameters.

# short_test_length should be between 15 and 60 s.
# Use a longer length to avoid crashing during the test.
short_test_length=20

# long_test_length should be between 60 and 7200 s or more.
# Bigger values are safer, but increase the test’s length.
long_test_length=320

# safety_vid_delta should be between 1 and 4. Bigger values are safer.
# Suggestions:
# - use 4 if long_test_length < 60
# - use 3 if long_test_length >= 60 and < 240
# - use 2 if long_test_length >= 240
# - use 1 only if long_test_length >= 3600
safety_vid_delta=2

debug=0

#####################################

# Check that settings are sane
if (( short_test_length < 15 )); then
	echo "Forcing short_test_length to 15 seconds."
	short_test_length=15
fi
if (( long_test_length < 30 )); then
	echo "Forcing long_test_length to 30 seconds."
	long_test_length=30
fi
if (( safety_vid_delta < 1 )); then
	echo "Forcing safety vid delta to 1."
	safety_vid_delta=1
fi

# Need root privileges to change the vids
if [[ `whoami` != root ]]; then
	echo "Run me as root."
	exit 1
fi

# Check that mprime is available
which mprime &>/dev/null
if (( $? != 0 )); then
	echo "mprime is not in the path."
	if [[ ! -e ./mprime ]]; then
		echo "No mprime in the current directory either… Aborting."
		exit 1
	fi
	echo "Using mprime from the current directory."
	mp="./mprime -t"
else
	mp="mprime -t"
fi

# Check that PHC is active
cpuf=/sys/devices/system/cpu/cpu0/cpufreq
if [[ ! -e $cpuf/phc_default_vids ]]; then
	echo "The PHC module doesn’t seem to be loaded."
	exit 1
fi

# Warn user about end of the world
echo ""
echo "Warning: this might crash your computer or applications."
echo "Please save all your work and don't do anything while the test is running."
echo "You can stop the test at any time with CTRL-C."
echo "Press RETURN to go on or CTRL-C to cancel."
read

# Store stuff to be able to cleanup later
backup_governor=$(cat $cpuf/scaling_governor)
backup_phc_vids=$(cat $cpuf/phc_vids)

# Log file for mprime
mp_log=/tmp/$(basename $0).mp

# Check that current governor is ondemand
if [[ $backup_governor != ondemand ]]; then
	echo "Switching to the ondemand governor. $backup_governor will be restored later."
	modprobe cpufreq_ondemand
	echo ondemand >$cpuf/scaling_governor
fi
backup_scaling_max_freq=$(cat $cpuf/scaling_max_freq)

function set_sys_val
{
	#echo Writing $2 to $1
	for i in /sys/devices/system/cpu/cpu*/cpufreq/$1; do
		echo "$2" > $i
	done
}

function cleanup
{
	echo ""
	echo "Restoring state…"

	# Kill mprime?
	# bash will kill it because the process hasn’t been disowned.
	# The only problem is it might write to the log after it has been deleted.

	# Restore vids
	set_sys_val phc_vids "$backup_phc_vids"

	# Restore max frequency
	set_sys_val scaling_max_freq "$backup_scaling_max_freq"

	# Restore governor
	set_sys_val scaling_governor "$backup_governor"

	# Delete log
	[[ -e $mp_log ]] && rm $mp_log
}

# Restore original state whenever the script exits
trap "cleanup" EXIT

# List all vids and frequencies
freqs=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies)
vids=$(cat /sys/devices/system/cpu/cpu0/cpufreq/phc_default_vids)

nb_freqs=0
for f in $freqs; do
	#echo $nb_freqs - $f
	freq[nb_freqs]=$f
	((nb_freqs++))
done

nb_vids=0
for v in $vids; do
	#echo $nb_vids - $v
	vid[nb_vids]=$v
	((nb_vids++))
done

if [[ $nb_freqs != $nb_vids ]]; then
	echo "Error: number of vids and number of frequencies differ!"
	exit 1
fi

# Check that writing to scaling_max_freq works (I had this problem)
#set_sys_val scaling_max_freq ${freq[1]}
#if [[ $backup_scaling_max_freq == $(cat $cpuf/scaling_max_freq) ]]; then
#	echo "Error: cannot write to scaling_max_freq!"
#	echo "Try updating your kernel, rebooting and/or reinstalling PHC."
#	exit 1
#fi

# Estimate length of test
estimate_min=$((short_test_length * (${vid[0]} - 2) + long_test_length))
estimate_max=$((short_test_length * (${vid[0]} - 2) + nb_freqs * long_test_length * 3 / 2))

function print_time
{
	# input: $1 = number of seconds
	# output: xx h yy min
	local seconds=$1
	local days=$((seconds/3600/24))
	local seconds=$((seconds-days*3600*24))
	local hours=$((seconds/3600))
	seconds=$((seconds-hours*3600))
	local minutes=$((seconds/60))
	local r
	((days>0)) && r="$days d "
	((hours>0 || days>0)) && r="$r$hours h "
	((days==0)) && r="$r$minutes min"
	echo -n $r
}

echo -n "Estimated time to completion: between "
print_time estimate_min
echo -n " and "
print_time estimate_max
echo ""

# For each available frequency, try to lower the vid as much as possible

# 1st pass: Lower the vid, test mprime for a small amount of time at each step.
#           If an error is detected, increment cur_vid and continue with pass 2.
#           If vid 0 is reached, continue with pass 2.
# 2nd pass: Test cur_vid for a long time.
#           If there is an error, increment cur_vid and loop.
#           Stop when there is no error or cur_vid >= max_vid-delta.
# Final step: best_vid=cur_vid+delta


# set_vid index vid
function set_vid
{
	# Generate phc_vids string
	local v=""
	local i
	for (( i=0; i$mp_log &
	mp_pid=$!
}

function kill_mprime
{
	kill $mp_pid
	wait $mp_pid &>/dev/null # needed to suppress the "killed" message by bash
}

cur_vid=${vid[0]}

for (( f=0; f ${vid[f]} )); then
		cur_vid=${vid[f]}
	fi

	((cur_vid--))

	for (( ; cur_vid > 0; cur_vid-- )); do
		#count=$(( short_test_length + 10 * ( ${vid[f]} + 1 - cur_vid ) / ( ${vid[f]}+1 ) ))
		count=$short_test_length

		echo "Trying vid $cur_vid for $count seconds"

		set_vid $f $cur_vid

		launch_mprime

		if ((debug)); then
			echo -n "Current vids: "
			cat $cpuf/phc_vids
			echo -n "Current freq: "
			cat $cpuf/cpuinfo_cur_freq
		fi

		for (( ; count>0; count-- )); do
			sleep 1
			echo -n "."
			grep FATAL $mp_log &>/dev/null
			if (( $? == 0 )); then
				echo ""
				echo "Hardware failure detected."
				((cur_vid++))
				kill_mprime
				break 2
			fi
			if (( $(cat $cpuf/cpuinfo_cur_freq) != ${freq[f]} )); then
				echo ""
				echo "ERROR: Wrong frequency! Is scaling_max_freq ignored?"
				exit 1
			fi
		done

		echo ""

		kill_mprime
	done

	# Pass 2: stress testing for a longer time and going up in case of an error.

	for (( ; cur_vid >= 0 && cur_vid < ${vid[f]}-safety_vid_delta; cur_vid++ )); do
		count=$long_test_length
		echo "Trying vid $cur_vid for $count seconds"

		set_vid $f $cur_vid

		launch_mprime

		if ((debug)); then
			echo -n "Current vids: "
			cat $cpuf/phc_vids
			echo -n "Current freq: "
			cat $cpuf/cpuinfo_cur_freq
		fi

		for (( ; count>0; count-- )); do
			sleep 1
			echo -n "."
			grep FATAL $mp_log &>/dev/null
			if (( $? == 0 )); then
				echo ""
				echo "Hardware failure detected."
				break
			fi
		done

		kill_mprime

		if (( count == 0 )); then
			break
		fi
	done

	echo ""
	echo "Found correct vid. Adding $safety_vid_delta for safety."
	(( cur_vid < 0 )) && cur_vid=0
	if (( cur_vid + safety_vid_delta > ${vid[f]} )); then
		cur_vid=$((${vid[f]}-safety_vid_delta))
	fi
	final_vids=$final_vids$((cur_vid+safety_vid_delta))
	(( f < nb_freqs-1 )) && final_vids="$final_vids "
	echo "Current results: $final_vids"

done

echo ""
echo "All done."
echo "Default vids: $(cat $cpuf/phc_default_vids)"
echo "Final vids:   $final_vids"
echo ""
if [[ -e /etc/conf.d/phc-intel ]]; then
	echo "Edit /etc/conf.d/phc-intel to add your final vids,"
	echo "then type: sudo rc.d start phc-intel"
else
	echo "Add the following 3 lines to /etc/rc.local, before the final \"exit 0\":"
	echo ""
	echo "for i in /sys/devices/system/cpu/cpu*/cpufreq/phc_vids; do"
	echo "  echo \"$final_vids\" > \$i"
	echo "done"
fi 
EOF

