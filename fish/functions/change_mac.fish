function change_mac
	sudo ip link set wlp2s0 down
	macchanger -a wlp2s0
	sudo ip link set wlp2s0 up
end