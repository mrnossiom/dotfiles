# File loader
for file in ./.{aliases,functions,exports,extra}; do
	source "$file";
done;
