Fee:("ssssssfsiisffffiffffff";enlist ",")0:`:./basetbl/Fee.csv;
fee:select Product,feeopen:ExchIntraOpenFee*(1+MyBrokerOpenFee),feeclose:ExchIntraCloseFee*(1+MyBrokerCloseFee),FeeMode,TradeUnit  from Fee;;

