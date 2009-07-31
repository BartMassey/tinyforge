#!/usr/bin/awk -f

NF==0 {
    next;
}

$1=="*"&&$2~/\[\[.*]]/ {
    name = substr($2, 3, length($2) - 4);
    nfields = split(name, namefields, "|");
    visname = namefields[1];
    if (nfields == 1)
	intname = visname;
    else if (nfields == 2)
        intname = namefields[2];
    intname = tolower(intname);
    printf "%s,%s,\"%s\",", intname, classname, visname;
    if (NF >= 3) {
	printf "\"%s", $3;
	for (i = 4; i <= NF; i++)
	    printf " %s", $i;
	printf "\"";
    }
    printf "\n";
    next;
}

$1!="*"&&NF>1 {
    classname = $1;
    next;
}

{
    printf "line %d: syntax error\n", NR >"/dev/stderr";
    exit(1);
}
