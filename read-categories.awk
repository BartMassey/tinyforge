#!/usr/bin/awk -f

NF==0 {
    next;
}

$1=="*"&&$2~/\[\[.*]]/ {
    next;
}

$1!="*"&&NF>1 {
    printf "%s,\"", $1;
    $1="";
    printf "%s\"\n", substr($0,2);
    next;
}

{
    printf "line %d: syntax error\n", NR >"/dev/stderr";
    exit(1);
}
