kLineInit:{
    if[x=0;
    MinuteF::09:00:00.000+`minute$T*til `int$1+(15:00:00.000 - 09:00:00.000)%(`time$T*60000i)];
    if[x=1;
    MinuteF::21:00:00.000+`minute$T*til `int$1+(27:00:00.000 - 21:00:00.000)%(`time$T*60000i)];
    }

// x: table;y: T: minute unit
genk:{[x;y]
     0!`time xcol select close:last LastPrice,open:first LastPrice,high: max LastPrice, 
     low:min LastPrice ,date:first date ,category:first Category,symbol:first Symbol  by y xbar Time.minute from x
     }

