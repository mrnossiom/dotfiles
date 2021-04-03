function fish_greeting
	set platform (uname)
	echo 'Hello '(set_color brblue)(whoami)(set_color normal)' you are on '(set_color brred)$platform(set_color normal)
end
