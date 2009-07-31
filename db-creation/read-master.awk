#!/usr/bin/awk -f

BEGIN {
    printf "CREATE TABLE by_category(intname VARCHAR(30), category VARCHAR(30), visname VARCHAR(30), attrib VARCHAR(100));\n"
    printf "BEGIN TRANSACTION;\n"
}

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
    printf "INSERT INTO by_category VALUES("
    printf "'%s','%s','%s',", intname, classname, visname;
    if (NF < 3) {
	printf "NULL";
    } else {
	printf "'%s", $3;
	for (i = 4; i <= NF; i++)
	    printf " %s", $i;
	printf "'";
    }
    printf ");\n";
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

END {
    printf "COMMIT;\n"
}
