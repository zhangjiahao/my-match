\l config.q
LoadQModule `order.q`util.q`log.q`kline.q;


\c 4000 4000
//.log.lvl:1;


LoadDB CTPDBPATH;
op:()!();
h:hopen `::5000;

onBar:{
    //================================Strategy Logic======================//
     .log.inf["on Bar"];
     .log.inf "Bar Time ",string last (0!kline)`time;
     closeList: -3#exec close from 0!kline;
     x:last 0!kline;
     if [((&/) (1_deltas closeList) >0) & (0=position[x`symbol][`l]);
         .log.inf["long signal"];
         tm: (x[`date];x[`category];.util.time2int last exec time from 0!kline;x[`symbol];`buy;last closeList;1;`open);
         .log.inf["long signal"];
         send[h;tm];
         ];

     if [((&/) (1_deltas closeList) <0) & (0=position[x`symbol][`s]);
         .log.inf["short signal"];
         tm: (x[`date];x[`category];.util.time2int last exec time from 0!kline;x[`symbol];`sell;last closeList;1;`open);
         .log.inf["short signal"];
         send[h;tm];
         ];
    //================================End Strategy Logic======================//
    if[in[t:`$string (.util.time2int last (0!kline)[`time]);key op];onOrder op t;op::t _ op];
    }

onBook:{
    //==============StrategyLogic=======================//
   
    //==============End StrategyLogic=======================//

    playBackData,:x; 
    s2:MinuteF bin x[`Time];
    if[s2>s;`kline set genk[playBackData;T];onBar[]];
    s::s2;
    if[in[t:`$string .util.time2int x[`Time];key op];onOrder op t;op::t _ op];
    }


//PlayBack Just For Day
runDaySymbol:{[d;symb]
   symb:symfunc[symb;d];
   kLineInit[0];
   originData::select from CtpDepth where date = d,Category=0,Symbol=symb,Time>=90000000;
   originData::update Time: .util.int2time each Time from originData;
   playBackData::0#originData;
   s::0;    //kline count 
   .log.inf["excute onBook"];
   onBook each originData;
    }

//PlayBack Just For Ngt
runNightSymbol:{[d;symb]
   symb:symfunc[symb;d];
   kLineInit[0];
   kLineInit[1];
   originData::select from CtpDepth where date = d,Category=1,Symbol=symb;
   originData::update Time:240000000+Time from originData where Time<=40000000;
   originData::select from originData where Time within (210000000;250000000);
   originData::update Time: .util.int2time each Time from originData;
   playBackData::0#originData;
   s::0;    //kline count 
   .log.inf["excute onBook"];
   onBook each originData;
    }

//PlayBack For Both Day And Night
runSymbol:{[d;s]runNightSymbol[d;s];runDaySymbol[d;s];}

/ [Main Function]
theFirstInit:{
    T::5;
    `position insert (`rb1810;0;0;0Nf);
    //`position insert (`AP810;0;0;0Nf);
    }[];

// MainContract
// runSymbol[;`AP810] each (2018.06.11;2018.06.12)

runSymbol[;`rb888] each (2018.06.11;2018.06.12)

.log.inf "Analysis Trade Record and get the performance";
-1 .Q.s moneyCal[];
.log.inf "Comparing Send Record and Trade Record";
-1 .Q.s compare[];
.log.inf "Get MaxDropDown and Max DropDownRatio";
.log.inf "MaxDropDown:",string getMaxDropDown moneyCal[]`MoneySums  ;
.log.inf "MaxDropDownRatio:",string getMaxDropDownRatio moneyCal[]`MoneySums;



/ Some Other Test Case
//runDay:runDaySymbol[;`rb1810];
//runNight:runNightSymbol[;`rb1810];
// runDay each enlist 2018.06.12
// runNight each (2018.06.11;2018.06.12)
