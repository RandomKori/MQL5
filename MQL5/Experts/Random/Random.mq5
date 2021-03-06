//+------------------------------------------------------------------+
//|                                                       Random.mq5 |
//|                                                           Рэндом |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
enum ISP
{
   FOK,
   IOC,
   RETURN
};
//Входные переменные
input ISP      isp=RETURN;//Тип исполнения
input double   Lot=1.0;//Лот
input int      SL=5;//Стоп лосс
input int      TP=6;//Тэйк профит
input int      Slipage=1;//Пролскальзование
input int      Magic=777;//Магический номер
//Includes

//Глобальные переменные
ENUM_ORDER_TYPE_FILLING tf;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
      switch(isp)
      {
         case FOK: tf=ORDER_FILLING_FOK; break;
         case IOC: tf=ORDER_FILLING_IOC; break;
         case RETURN: tf=ORDER_FILLING_RETURN; break;
      }
      MathSrand(16383);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!PositionSelect(Symbol()))Open();
}
//Открытие позиции
void Open()
{
   MqlTick last_tick;
   SymbolInfoTick(Symbol(),last_tick);
   MqlTradeResult result;
   MqlTradeRequest request;
   
   int sg=OpenSignal();
   ZeroMemory(result);
   ZeroMemory(request);

   request.symbol=Symbol();
   request.magic=Magic;
   request.deviation=Slipage;
   request.action=TRADE_ACTION_DEAL;
   request.type_filling=tf;
   if(sg==1)
   {
      request.volume=Lot;
      request.price=last_tick.ask;
      request.type=ORDER_TYPE_BUY;
      request.sl=last_tick.ask-SL*Point();
      request.tp=last_tick.ask+TP*Point();
      bool r=OrderSend(request,result);

   }
   if(sg==-1)
   {
      request.volume=Lot;
      request.price=last_tick.bid;
      request.type=ORDER_TYPE_SELL;
      request.sl=last_tick.bid+SL*Point();
      request.tp=last_tick.bid-TP*Point();
      bool r=OrderSend(request,result);

   }
}
//Сигнал на открытие. 0 - нет позиции, 1 - покупка, -1 - продажа
int OpenSignal()
{
   int rez=0;
   if(MathRand()>16383)
      rez=1;
   else
      rez=-1; 
   return rez;
}
