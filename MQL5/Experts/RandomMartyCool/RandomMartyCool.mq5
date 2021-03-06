//+------------------------------------------------------------------+
//|                                              RandomMartyCool.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
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
input double   DML=1000;//Доля депозита на минимальный лот
input int      Ud=1;//Количесство удвоенеий
input double   MaxRisk=20;//Риск в процентах по депозиту
input double   MaxLot=100;//Максимальный лот
input int      StopTake=500;//Тэйк и стоп
input int      Slipage=50;//Проскальзование
input int      MACD1Fast=5;//Быстрая MACD 1
input int      MACD1Slow=20;//Медленая MACD 1
input int      MACD2Fast=10;//Быстрая MACD 2
input int      MACD2Slow=15;//Медленая MACD 2
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING tf;
int m1=0;
int m2=0;
bool pos=false;
double maxbalance=0.0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <MM/Martingail.mqh>
Martingail lt;
//+------------------------------------------------------------------+
//|                                                                  |
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
   m1=iMACD(Symbol(),Period(),MACD1Fast,MACD1Slow,3,PRICE_MEDIAN);
   m2=iMACD(Symbol(),Period(),MACD2Fast,MACD2Slow,3,PRICE_MEDIAN);

   lt.GVarName="MG_1";
   lt.Shape=DML;
   lt.DoublingCount=Ud;
   lt.MaxLot=MaxLot;
   lt.GVarGet();

   if(GlobalVariableCheck("MBRM"+Symbol())) maxbalance=GlobalVariableGet("MBRM"+Symbol());
   if(PositionSelect(Symbol()))
      pos=true;
   else
      pos=false;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   lt.GVarSet();
   GlobalVariableSet("MBRM"+Symbol(),maxbalance);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
    MqlRates r[1];
   CopyRates(Symbol(),Period(),0,1,r);
   if(r[0].tick_volume>1) return;
   if(Risk()) return;
   if(!pos) Open();
  }
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   if(PositionSelect(Symbol()))
     {
      if(PositionGetDouble(POSITION_SL)==0.0)
        {
         MqlTradeRequest r={};
         MqlTradeResult rez={};

         r.action=TRADE_ACTION_SLTP;
         r.symbol=Symbol();
         r.position=PositionGetInteger(POSITION_TICKET);
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            r.sl=PositionGetDouble(POSITION_PRICE_OPEN)-StopTake*Point();
            r.tp=PositionGetDouble(POSITION_PRICE_OPEN)+StopTake*Point();
           }
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            r.sl=PositionGetDouble(POSITION_PRICE_OPEN)+StopTake*Point();
            r.tp=PositionGetDouble(POSITION_PRICE_OPEN)-StopTake*Point();
           }
         OrderSend(r,rez);
        }
     }
   else
      pos=false;
  }
//+------------------------------------------------------------------+

void Open()
  {
   double t[3];
   double k[2];

   if(CopyBuffer(m1,0,1,3,t)<0) return;
   if(CopyBuffer(m2,0,1,2,k)<0) return;

   MqlTradeResult result;
   MqlTradeRequest request;

   ZeroMemory(result);
   ZeroMemory(request);

   request.symbol=_Symbol;
   request.magic=777;
   request.deviation=50;
   request.action=TRADE_ACTION_DEAL;
   request.type_filling=tf;
   if(t[0]>t[1] && t[1]<t[2] && k[1]>k[0])
     {
      request.volume=lt.Lot();

      request.type=ORDER_TYPE_BUY;
      request.sl=0;
      request.tp=0;
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      OrderSend(request,result);
      pos=true;
     }
   if(t[0]<t[1] && t[1]>t[2] && k[1]<k[0])
     {
      request.volume=lt.Lot();

      request.type=ORDER_TYPE_SELL;
      request.sl=0;
      request.tp=0;
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      OrderSend(request,result);
      pos=true;
     }
  }
//+------------------------------------------------------------------+
bool Risk()
  {
   bool rez=false;
   if(maxbalance<AccountInfoDouble(ACCOUNT_BALANCE)) maxbalance=AccountInfoDouble(ACCOUNT_BALANCE);
   double db=AccountInfoDouble(ACCOUNT_BALANCE)-maxbalance;
   double pros=db/(maxbalance/100.0);
   if(pros<-MaxRisk) rez=true;
   return rez;
  }
//+------------------------------------------------------------------+
