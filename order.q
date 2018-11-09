/
 @author Jiahao
 @date 2018.11.08
\


\l log.q
\l fee.q
\c 5000 5000
op:()!();
appendKey:{$[not x in key op;@[`op;x;:;enlist y];@[`op;x;,;y]];` _ op;}

//Async Send Order to Match Engine(No use)
sendAsync:{[h;tm] 
    -1 "Send";
    oid:`long$.z.P;
    tm,:oid;
    (neg h)(`sendReturn;
    tm;{appendKey[(`$string x[0]);x]});
    oid}

//Sync Send Order to Match Engine server (default)
sendSync:{[h;tm] 
    startTime:.z.P;
    .log.inf "Sending Order to Match:","|" sv string tm;
    oid:`long$.z.P;
    tm,:oid;
    r:h (`sendReturnSync;tm);
    {appendKey[(`$string x[0]);x]}each r;
    .log.inf["Around Match Spend ",string(.z.P-startTime)];
    oid}

//  Send Order Function(This function Will close 
//  opposite position First and Open)
send:{[h;tm]
    oc:last tm;d: first -4#tm;
    p:raze exec l,s from position where symbol=tm[3];
    if[(oc=`open);
        if[(d=`buy) &(p[1]>0); sendSync[h;(-1_tm),`close]];
        if[(d=`sell) &(p[0]>0); sendSync[h;(-1_tm),`close]];
    ];
    sendSync[h;tm];
    }
 
//Cancel Order: param: orderID;
cancel:{[oid]
    .log.inf["Begin Cancel Order ",string oid];
    startTime:.z.P;
    {if[min oid=last each op[x];op::x _ op;.log.info "Canceled;",string oid;];}each key op;
    .log.inf["Canceling Spend ",string(.z.P-startTime)];
    }

/
   [ .e.g ]
   h:hopen `::5000;
   tm: (2018.06.12;0;90005000i;`AP807;`buy;10060;1;`open);
   oid:sendSync[h;tm];
   cancel[oid]
   oid:send[h;tm];
   cancel[oid]
\





orderStatus:([]
    orderID:`long$();
    OrderStatus:`$();
    time:());

//PlayingBack Trading Record 
record:([]
    date:();
    symbol:`$();
    time:();
    oc:`$();
    d:`$();
    price:`float$();
    size:`int$();
    OrderID:`long$());

//  PlayingBack Sending Record (Used to compare with 
//  Trading Record(tbl record))
sendRecord:([]
    date:();
    symbol:`$();
    time:();
    oc:`$();
    d:`$();
    price:`float$();
    size:`int$();
    OrderID:`long$());

position:([symbol:`$()];
    l:`int$();
    s:`int$();
    openPrice:`float$());

/ [ doc ]When Order Returns and Trader Returns will callback this function
/       The Logic  in it is to update the position, record, sendRecord,orderStatus;

onOrder:{[OrderX]
    .log.inf["Comming Into OnOrder"];
    {
      if[0=last x;
          //(90001000i;`success;`date`ap1`as1`time`symbol`oc`d!(2018.06.12;10055f;1;90001000i;`AP807;`open;`buy);"[Trader Return]|593746482636693000";0)
          .log.inf["[TraderReturn]:","|"sv string value x[2]];

          orderid:"J"$last "|" vs  x[3];
          symbol:x[2][`symbol];
          delete from `orderStatus where orderID=orderid;
          `record insert (x[2][`date];x[2][`symbol];x[2][`time];x[2][`oc];x[2][`d];x[2][`price];x[2][`size];orderid);
         $[x[2][`oc]=`open;
                $[x[2][`d]=`buy;
                    update l:l+x[2][`size],openPrice:x[2][`price] from `position where symbol=symbol;
                    update s:s+x[2][`size],openPrice:x[2][`price]from `position where symbol=symbol
                ];
                $[x[2][`d]=`sell;
                    update  l:l-x[2][`size],openPrice:0Nf from `position where symbol=symbol;
                    update  s:s-x[2][`size],openPrice:0Nf from `position where symbol=symbol
                ]
            ];
      ];
      if[0<last x;
          //(90000000i;`pendding;"2018.06.12|0|90000000|AP807|buy|10060|1|open|593745846579727000";"[Order Return]";593745846579727000)
          .log.inf["[OrdeReturn]:",x[2]]
          xx:"|" vs  x[2];
          `sendRecord insert ("D"$xx[0];`$xx[3];x[0];`$xx[7];`$xx[4];"F"$xx[5];"I"$first xx[6];x[4]);
          `orderStatus insert (x[4];x[1];x[0]);
      ];
    } each OrderX;
    }


