#!/usr/bin/awk -f

BEGIN {
    printf "CREATE TABLE categories(num INT, name VARCHAR(30), desc VARCHAR(100));\n"
    printf "BEGIN TRANSACTION;"
}

NF==0 {
    next;
}

$1=="*"&&$2~/\[\[.*]]/ {
    next;
}

$1!="*"&&NF>1 {
    printf "INSERT INTO categories VALUES("
    printf "%d,'%s','", ++num, $1;
    $1="";
    printf "%s');\n", substr($0,2);
    next;
}

{
    printf "line %d: syntax error\n", NR >"/dev/stderr";
    exit(1);
}

END {
    printf "COMMIT;\n"
}
