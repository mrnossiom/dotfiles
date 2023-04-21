function change_mac
	set dev (nmcli --get-values GENERAL.DEVICE,GENERAL.TYPE device show | sed '/^wifi/!{h;d;};x;q')

	sudo ip link set $dev down
	
	if test "$argv[1]" = "reset";
		sudo macchanger --permanent $dev
	else;
		sudo macchanger --another $dev
	end

	sudo ip link set $dev up
end