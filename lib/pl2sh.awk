#!/usr/bin/gawk -f

BEGINFILE {
	print "#!/usr/bin/env bash"
	print ""
	filename = FILENAME
	gsub(/^.*\//, "", filename)
	gsub(/.pl$/, "", filename)
	print "function", filename, "{"
	print "perl -e \"$(cat <<'EOC'"
}

{ print $0 }

ENDFILE {
	print "EOC"
	print ")\" -- $@"
	print "}"
}
