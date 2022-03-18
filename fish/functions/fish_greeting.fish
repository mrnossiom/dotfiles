function fish_greeting
	set platform (uname)
	
	if test (pwd) = '/mnt/c/Users/milom'; cd ~; end
	
	echo 'Hello '(set_color brblue)(whoami)(set_color normal)' you are on '(set_color brred)$platform(set_color normal)'.'
	echo 'Your current directory is '(set_color brgreen)(pwd)(set_color normal)
end
