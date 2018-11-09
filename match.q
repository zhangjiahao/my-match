/
   @author: Jiahao
   @date:2018.11.08
\




\l log.q
\l config.q
LoadDB CTPDBPATH;
\c 5000 5000
\p 5000

epsilon:0;

/ [ doc ] simplest Version: Hitting the price and Volumn very small;
/ [ param ]
/    dt: date;
/    ct:category;(night:1,day:0)
/    tm:time;
/    s:symbol;
/    d:`buy or `sell
/    p:price
/    v:volumn;
/    oc:`open or `close;

simpleMatch:{[dt;ct;tm;s;d;p;v;oc]
    .log.inf["Comming into simpleMatch"];
    res:select bp1:BidPrice1,
            ap1:AskPrice1,
            bs1:BidVol1,
            as1:AskVol1,
            time:Time,symbol:Symbol,date from CtpDepth where date = dt,Category=ct,Symbol=s,Time>=tm+epsilon;
    if[d=`buy;:first select date,price:ap1,size:as1:v,time,symbol,oc:oc,d:d from res where p>=ap1,v<=as1];
    if[d=`sell;:first select date,price:bp1,size:bs1:v,time,symbol,oc:oc,d:d  from res where p<=bp1,v<=bs1];
    };

// This code for async [ Not used now ]. ======================================================
orderHandle:{[tm;cf](neg .z.w)(cf;(tm[2];`pendding;("|" sv string tm);"[Order Return]";last tm))};
traderHandle:{[tm;cf]res:(simpleMatch . -1 _ tm);(neg .z.w)(cf;(res[`time];`success;res;"[Trader Return]";0))};
sendReturn:{[tm;cf]orderHandle[tm;cf];traderHandle[tm;cf];};
//=============================================================================================


/ [ doc ] When Match Engine Server get an Order;
/         Firstly, invoke in orderHanleSync,which will return some info.
/         Secondly, invoke in tradeHanleSync, which will return some trade info.

orderHandleSync:{[tm]
        .log.inf["Comming into OrderHandleSync"];
        (tm[2];`pendding;("|" sv string tm);"[Order Return]";last tm)};

/ [ param ] tm:(dt;ct;tm;s;d;p;v;oc)
/           f: match function

traderHandleSync:{[tm;f]
        .log.inf["Comming into TradeHandleSync"];
        startTime:.z.P;
        res:(f . -1 _ tm);
        .log.inf["Around simpleMatch spend ",string(.z.P-startTime)];
        (res[`time];`success;res;"[Trader Return]|",string first -1#tm;0)};

sendReturnSync:{[tm](orderHandleSync[tm];traderHandleSync[tm;simpleMatch])};
