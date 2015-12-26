#! /usr/bin/gawk -f

{
	print
}

/^#> / {
	command = substr($0, 4)
	while ((command | getline line) > 0) {
		if (line !~ /^#!/) {
			print line
		}
	}
	close(command)
}
