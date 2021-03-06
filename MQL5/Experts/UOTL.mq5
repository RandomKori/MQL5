//+------------------------------------------------------------------+
//|                                                         UOTL.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- input parameters
input string   Com1="Время установки отложек";
input int      StartH=10;// Час выставления ордеров
input int      StartM=0;//Минута выставления ордеров
input string   Com2="Время удаления не сработавших отложек";
input int      StopH=22;//Час удаления несработавших ордеров
input int      StopM=0;//Минута удаления несработавших ордеров
input string   Com3="----------------------------------------";
input int      StopSpd=100;//Спред для проверки
input int      Otstup=200;//Отступ для ордеров
input double   Lot=0.1;//Лот
input int      TP=500;//Тэйк профит
input int      SL=500;//Стоп лосс
input int      Slippage=30;//Проскальзование
input ulong    Magic=777;//Магический номер
input ENUM_ORDER_TYPE_FILLING Filing=ORDER_FILLING_FOK;//Тип исполнения ордеров
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int otl=0;
int OnInit()
  {
//---
      string nm="otl"+IntegerToString(Magic);
      if(GlobalVariableCheck(nm))
         otl=(int)GlobalVariableGet(nm);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
     string nm="otl"+IntegerToString(Magic);
     GlobalVariableSet(nm,otl); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   datetime tc=TimeCurrent();
   
   MqlDateTime ts;
   TimeToStruct(tc,ts);
   if(ts.hour==StartH && ts.min==StartM)
      if(otl==0)
        {
         int spd=(int)((SymbolInfoDouble(Symbol(),SYMBOL_ASK)-SymbolInfoDouble(Symbol(),SYMBOL_BID))/Point());
         if(spd<=StopSpd)
           {
            MqlTradeRequest rc= {0};
            MqlTradeResult rz= {0};

            rc.action=TRADE_ACTION_PENDING;
            rc.magic=Magic;
            rc.symbol=Symbol();
            rc.volume=Lot;
            rc.deviation=Slippage;
            rc.type_filling=Filing;
            rc.type_time=ORDER_TIME_GTC;

            rc.type=ORDER_TYPE_BUY_STOP;
            double pr=SymbolInfoDouble(Symbol(),SYMBOL_ASK)+Otstup*Point();
            rc.price=pr;
            rc.sl=pr-SL*Point();
            rc.tp=pr+TP*Point();
            if(OrderSend(rc,rz))
               Print("Error: ",rz.retcode);

            rc.type=ORDER_TYPE_SELL_STOP;
            pr=SymbolInfoDouble(Symbol(),SYMBOL_BID)-Otstup*Point();
            rc.price=pr;
            rc.sl=pr+SL*Point();
            rc.tp=pr-TP*Point();
            if(OrderSend(rc,rz))
               Print("Error: ",rz.retcode);

            otl=1;
           }
        }
   if(otl==1)
     {
      if(ts.hour>=StopH && ts.min>=StopM)
        {
         int limit=OrdersTotal()-1;
         for(int i=limit; i>=0; i--)
           {
            ulong ticket=OrderGetTicket(i);
            if(OrderSelect(ticket))
              {
               long tp=OrderGetInteger(ORDER_TYPE);
               long mg=OrderGetInteger(ORDER_MAGIC);
               if(mg==Magic)
                  if(tp==ORDER_TYPE_BUY_STOP || tp==ORDER_TYPE_SELL_STOP)
                    {
                     MqlTradeRequest rc= {0};
                     MqlTradeResult rz= {0};

                     rc.action=TRADE_ACTION_REMOVE;
                     rc.order=ticket;
                     if(OrderSend(rc,rz))
                        if(OrderSend(rc,rz))
                           Print("Error: ",rz.retcode);
                    }
              }
           }
         otl=0;
        }
     }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   if(OTotal()==1 && otl==1)
     {
      int limit=OrdersTotal()-1;
      for(int i=limit; i>=0; i--)
        {
         ulong ticket=OrderGetTicket(i);
         if(OrderSelect(ticket))
           {
            long tp=OrderGetInteger(ORDER_TYPE);
            long mg=OrderGetInteger(ORDER_MAGIC);
            if(mg==Magic)
               if(tp==ORDER_TYPE_BUY_STOP || tp==ORDER_TYPE_SELL_STOP)
                 {
                  MqlTradeRequest rc= {0};
                  MqlTradeResult rz= {0};

                  rc.action=TRADE_ACTION_REMOVE;
                  rc.order=ticket;
                  if(OrderSend(rc,rz))
                     if(OrderSend(rc,rz))
                        Print("Error: ",rz.retcode);
                 }
           }
        }
      otl=0;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OTotal()
  {
   int r=0;
   int limit=OrdersTotal();
   for(int i=0; i<limit; i++)
     {
      ulong ticket=OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         long tp=OrderGetInteger(ORDER_TYPE);
         long mg=OrderGetInteger(ORDER_MAGIC);
         if(mg==Magic)
            if(tp==ORDER_TYPE_BUY_STOP || tp==ORDER_TYPE_SELL_STOP)
               r++;
        }
     }
   return r;
  }
//+------------------------------------------------------------------+
