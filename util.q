/
 Some Basic Method
 @author Jiahao
 @date 2018.11.09
\

//[ doc ] calculate the return Money
moneyCal:{
    res:select {-[;] . x} each (0N 2)#price,(0N 2)#oc,(0N 2)#d,pprice:(0N 2)#price from record;
    res:delete from res where (count each d) <2;
    res:update price: neg price from res where (last each d) = `buy;
    res:update symbol:(first record`symbol),size:(first record`size) from res;
    res:update PriceSums:sums price,Product:sym2product each symbol from res;
    res: res lj `Product xkey fee;
    res:update feeopen1:?[FeeMode=`ByVol;size*feeopen;size*(first flip pprice)*TradeUnit*feeopen] from res;
    res:update feeclose1:?[FeeMode=`ByVol;size*feeclose;size*(last flip pprice)*TradeUnit*feeclose] from res;
    res:update fee:feeopen1+feeclose1 from res;
    res:update MoneyWithoutFee:PriceSums*TradeUnit from res;
    res:update MoneySums:sums (price*TradeUnit)-fee,feeSums:sums fee from res; 
    res:delete feeclose1,feeopen1,FeeMode,TradeUnit,feeopen,feeclose from res
    }

// [ doc ] Compare the Send Price and Trade Price difference
compare:{
   `date`symbol`sendTime`time`sendPrice`price`sendSize`size`oc`d xcols delete OrderID from 
    record lj `symbol`OrderID xkey select sendTime:time,sendPrice:price ,sendSize:size,OrderID,symbol from sendRecord
    }

// Get max drop down for a list;
getMaxDropDown:{min x-maxs x};

// Get Max drop down Ratio for a list;
getMaxDropDownRatio:{s:min x-maxs x;b:max x til first (&)s=mins x-maxs x;s%b};

// get Main Contract x:date;y:product ...The simplest Get Main Contract Method.(Maybe fault sometimes)
getMain:{ p:raze (string y),"*";.qtools.denum exec first Symbol  from `c xdesc select c:count i by Symbol from CtpDepth where date = x,Category=0,Symbol like p};

// if rb888 Means rb maintract.
symfunc:{$[(xx:string x) like "*888";getMain[y;`$ssr[xx;"888";""]];x]}

// map contract Name to product Name
sym2product:{x:string x;`$lower rtrim @[x;(x ss "[0-9]");:;" "]} 

// qtools Function Used to cast enumate to symbol;
.qtools.cols:{[tbl;typ]schema:meta tbl;$[11h=(abs type typ);exec c from schema where a in typ;exec c from schema where t in typ]};
.qtools.enumrange:20 76h;
.qtools.denum:{$[(abs type x) within .qtools.enumrange;value x;0h=type x;.qtools.denum each x;x]};
.qtools.denumtbl:{[tbl] scol:.qtools.cols[tbl;"s "];a:scol!{(.qtools.denum;x)}each scol;![tbl;();0b;a]};


// Common utils
// @author Shen
// @date 2016.05.20
\d .util

// get time from Research Dept integer format, e.g. 100000000 -> 10:00:00.000
int2time:{"T"$-9#"00000000",string x}
// convert time to Research Dept integer format, e.g. 10:00:00.000 -> 100000000
time2int:{x:`time$x;`int$(1e7*`hh$x)+(1e5*`mm$x)+(1e3*`ss$x)+(`int$x mod 1e3)}
// integer to date, e.g. 20160519 -> 2016.05.19
int2date:{"D"$string x}
// date to integer, e.g. 2016.05.19 -> 20160519
date2int:{x:`date$x;`int$(1e4*`year$x)+(1e2*`mm$x)+`dd$x}

// Check if this is a hdb process
isHdb:{$[@[value;`.Q.pf;`rdb]~`date;1b;0b]}
// Check if a variable is a keyed or non-keyed table
isTable:{if[98h=type x;:1b];if[99h=type x;:98h=type key x];0b}
// Convert symbol or symbol vector to string such that it can be put in sql
// e.g., h "select from tbl where sym in ",sym2str[`if1`if2`a1`a2]
sym2str:{"(`$\"",$[1<count x;"\";`$\"" sv string x;string first x],"\")"}
/ transform date & time to unix micro secs
/ @param d  date
/ @param time  time
dt2unixus:{[d;t]`long$((d + t) - 1970.01.01D8) div 1000}
/ unix timestamp to time
TimeStamp2Time:{`time$(08:00+`datetime$-10957+x%86400000000)}
/ get handle of gateway
gw:{$[0<count s:.servers.getservers[`proctype;`gateway;()!();1b;1b]`w;rand s;s]}
/ get IP address
ip:{
   // ip_str:system "echo $(/sbin/ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' ORS=' ' | awk '{print substr($0,1,length()-1);}')";
    //AARON update for Centos
    ip_str:system "echo $(/sbin/ifconfig | grep 'inet '| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2}' ORS=' ' | awk '{print substr($0,1,length()-1);}')";
    res:`$" " vs raze ip_str
 }
/ convert iTime and tday into Unix timestamp
/ @param iTime int
/ @param tday date
dateTime2TimeStamp:{[iTime;tday] "j"$(1000*("j"$(.util.int2time[iTime]-`time$ 08:00:00.000))) + ("j"$(0.001*((`timestamp$tday)-(`timestamp$ 1970.01.01))))}

\d .
