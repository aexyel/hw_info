# RUN:
# dmesg | awk -f hw_info.awk
# cat /var/run/dmesg.boot | awk -f hw_info.awk

/^OpenBSD 7/ {delete par;delete leaf;};

/ at / {
    if($2=="at"){
        par[$1]=gensub(":","","",$3);
    };
};

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

/^root on sd0/ {
    leaf["sd0"] = leaf["sd0"] "!!! " $0;
};

END{
    offset=1;
    tree("root");
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
