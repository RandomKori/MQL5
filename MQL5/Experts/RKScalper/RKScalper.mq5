//+------------------------------------------------------------------+
//|                                                    RKScalper.mq5 |
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
input string   Sym="BR-9.18";//Торговый символ
input double   DML=10000;//Доля депозита на 1 минимальный лот
input double   MaxLot=100;//Максимально допустимый лот
input double   MinLot=1;//Минимально допустимый лот
input double   MaxRisk=20;//Риск в процентах по депозиту
input int      SL=5;//Стоп лосс
input int      TP=6;//Тэйк профит
input int      Slipage=1;//Пролскальзование
input int      Magic=777;//Магический номер
input int      MAPeriod=3;//Переод скользящей средней
input int      MACDFast=5;//OsMA бфстрая
input int      MACDSlow=20;//OsMA медленная
input int      MACDSignal=3;//OsMA сигнальная
//Includes

//Глобальные переменные
ENUM_ORDER_TYPE_FILLING tf;
double maxbalance=0.0;
int m1=0;
int m2=0;
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
      if(GlobalVariableCheck("MB"+IntegerToString(Magic))) maxbalance=GlobalVariableGet("MB"+IntegerToString(Magic));
      
      m1=iOsMA(Symbol(),Period(),MACDFast,MACDSlow,MACDSignal,PRICE_MEDIAN);
      m2=iMA(Symbol(),Period(),MAPeriod,0,MODE_EMA,PRICE_MEDIAN);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   GlobalVariableSet("MB"+IntegerToString(Magic),maxbalance);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   
   if(Risk()) return;
   if(!PositionSelect(Sym))Open();
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

   request.symbol=Sym;
   request.magic=Magic;
   request.deviation=Slipage;
   request.action=TRADE_ACTION_DEAL;
   request.type_filling=tf;
   if(sg==1)
   {
      request.volume=Lot(DML);
      request.price=last_tick.ask;
      request.type=ORDER_TYPE_BUY;
      request.sl=last_tick.bid-SL*Point();
      request.tp=last_tick.ask+TP*Point();
      bool r=OrderSend(request,result);

   }
   if(sg==-1)
   {
      request.volume=Lot(DML);
      request.price=last_tick.bid;
      request.type=ORDER_TYPE_SELL;
      request.sl=last_tick.ask+SL*Point();
      request.tp=last_tick.bid-TP*Point();
      bool r=OrderSend(request,result);

   }
}
//Сигнал на открытие. 0 - нет позиции, 1 - покупка, -1 - продажа
int OpenSignal()
{
   int rez=0;
   double t[3];
   double k[2];
   
   if(CopyBuffer(m1,0,1,3,t)<0) return rez;
   if(CopyBuffer(m2,0,1,2,k)<0) return rez;
   
   if(t[0]>t[1] && t[1]<t[2] && k[1]>k[0]) rez=1;
   if(t[0]<t[1] && t[1]>t[2] && k[1]<k[0]) rez=-1;
   return rez;
}

double Lot(double dml)
{
   double lot=MathFloor(AccountInfoDouble(ACCOUNT_BALANCE)/dml)*MinLot;
   if(lot<MinLot) lot=MinLot;
   if(lot>MaxLot) lot=MaxLot;
   return lot;
}

bool Risk()
{
   bool rez=false;
   if(maxbalance<AccountInfoDouble(ACCOUNT_BALANCE)) maxbalance=AccountInfoDouble(ACCOUNT_BALANCE);
   double db=AccountInfoDouble(ACCOUNT_BALANCE)-maxbalance;
   double pros=db/(maxbalance/100.0);
   if(pros<-MaxRisk) rez=true;
   return rez;
}

