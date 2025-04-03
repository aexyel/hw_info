# RUN:
# dmesg | cut -c 17-256 | gawk -f hw_info.awk
# cat /var/run/dmesg.boot | cut -c 17-256 | gawk -f hw_info.awk

/^NetBSD 10/ {delete par;delete leaf;};
/ \(root\)/{if($2=="(root)"){par[$1]="(root)"}}


/ at / {
    if($2=="at"){
        par[$1]=gensub(":","","",$3);
    };
};

/ detached/ {delete leaf[$1];delete par[$1];};

{
    if(index($1,":")!=0) {
        _l=gensub(":","","",$1);
        leaf[_l] = leaf[_l] "!!! " gensub($1 " ","","",$0);
    } else {
        if($2=="at"){
            _s=$1 " " $2 " " $3;
            _l=gensub(_s,"","",$0);
            if(_l !=""){
                leaf[$1] = leaf[$1] "!!!" _l
            };
        };
    };
};

/^wd0\(/ {
    leaf["wd0"] = leaf["wd0"] "!!! " $0;
};

/^cd0\(/ {
    leaf["cd0"] = leaf["cd0"] "!!! " $0;
};

/^root on sd/ {
    _s=substr($3,1,3);
    leaf[_s] = leaf[_s] "!!! " $0;
};
/^root on dk/ {
    _s=substr($3,1,3);
    leaf[_s] = leaf[_s] "!!! " $0;
};

END{
    offset=1;
    tree("(root)");
}

function tree(r) {
    for(p in par){
        if (par[p]==r) {
            _format="%" offset*3 "s";
            _tree=sprintf(_format,"->");
            print sprintf("%s %s %s %s",_tree,p,"at",par[p]);
            _l=leaf[p];
            if(_l!=""){
                _format="\n%" (offset+1)*3 "s";
                _tree=sprintf(_format,"=");
                print gensub("\n","","",gensub("!!!",_tree,"G",_l));
            };
            offset=offset+1;
            tree(p);
            offset=offset-1;
        }; 
    };
};
