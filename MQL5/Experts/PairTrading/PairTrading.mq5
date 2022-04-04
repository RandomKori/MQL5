//+------------------------------------------------------------------+
//|                                                  PairTrading.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input string   Sym1="GBPUSD.m";
input string   Sym2="EURUSD.m";
input double   Lot=0.1;
input double   LotK=4.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    ObjectCreate(0,"BUYPT",OBJ_BUTTON,0,0,0);
    ObjectCreate(0,"SELLPT",OBJ_BUTTON,0,0,0);
    ObjectSetInteger(0,"BUYPT",OBJPROP_XDISTANCE,10);
    ObjectSetInteger(0,"BUYPT",OBJPROP_YDISTANCE,20);
    ObjectSetInteger(0,"SELLPT",OBJPROP_XDISTANCE,70);
    ObjectSetInteger(0,"SELLPT",OBJPROP_YDISTANCE,20);
    ObjectSetString(0,"BUYPT",OBJPROP_TEXT,"BUY");
    ObjectSetString(0,"SELLPT",OBJPROP_TEXT,"SELL");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    MqlTick s1,s2;
    SymbolInfoTick(Sym1,s1);
    SymbolInfoTick(Sym2,s2);
    Comment("K= ",s1.last/s2.last);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
      double ls1=Lot;
      double ls2=Lot*LotK;
      if(id==CHARTEVENT_OBJECT_CLICK)
      {
         ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
         if(sparam=="BUYPT")
         {
           OpenPos(Sym1,1,ls1);
           
           OpenPos(Sym2,-1,ls2);
         }
         if(sparam=="SELLPT")
         {
           OpenPos(Sym1,-1,ls1);
           
           OpenPos(Sym2,1,ls2);
         }
      }
   
  }
//+------------------------------------------------------------------+

void OpenPos(string sym,int sg,double lt)
{
   MqlTick last_tick;
   SymbolInfoTick(sym,last_tick);
   MqlTradeResult result;
   MqlTradeRequest request;
   
   
   ZeroMemory(result);
   ZeroMemory(request);

   request.symbol=sym;
   request.magic=777;
   request.deviation=2;
   request.action=TRADE_ACTION_DEAL;
   request.type_filling=ORDER_FILLING_RETURN;
   if(sg==1)
   {
      request.volume=lt;
      request.price=last_tick.ask;
      request.type=ORDER_TYPE_BUY;
      request.sl=0;
      request.tp=0;
      bool r=OrderSend(request,result);

   }
   if(sg==-1)
   {
      request.volume=lt;
      request.price=last_tick.bid;
      request.type=ORDER_TYPE_SELL;
      request.sl=0;
      request.tp=0;
      bool r=OrderSend(request,result);

   }
}