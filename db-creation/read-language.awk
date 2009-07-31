#!/usr/bin/awk -f

BEGIN {
    printf "CREATE TABLE by_language(intname VARCHAR(30), language VARCHAR(30), detail VARCHAR(100));\n"
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
    printf "INSERT INTO by_language VALUES("
    printf "'%s','%s',", intname, langname;
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
    langname = $1;
    next;
}

{
    printf "line %d: syntax error\n", NR >"/dev/stderr";
    exit(1);
}

END {
    printf "COMMIT;\n"
}
