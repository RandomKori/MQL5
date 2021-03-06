//+------------------------------------------------------------------+
//|                                            RandomMartyCool_1.mq5 |
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
input int      Slipage=2;//Проскальзование
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING tf;

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
     MathSrand(16383);   

   lt.GVarName="MG_1";
   lt.Shape=DML;
   lt.DoublingCount=Ud;
   lt.MaxLot=MaxLot;
   lt.GVarGet();

   if(GlobalVariableCheck("MBRM"+Symbol())) maxbalance=GlobalVariableGet("MBRM"+Symbol());
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
   if(Risk()) return;
   if(!PositionSelect(Symbol()))Open();
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
  }
//+------------------------------------------------------------------+

void Open()
  {
   int rnd=MathRand();

   MqlTradeResult result;
   MqlTradeRequest request;

   ZeroMemory(result);
   ZeroMemory(request);

   request.symbol=_Symbol;
   request.magic=777;
   request.deviation=50;
   request.action=TRADE_ACTION_DEAL;
   request.type_filling=tf;
   if(rnd>=16383)
     {
      request.volume=lt.Lot();

      request.type=ORDER_TYPE_BUY;
      request.sl=0;
      request.tp=0;
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      OrderSend(request,result);

     }
   if(rnd<16383)
     {
      request.volume=lt.Lot();

      request.type=ORDER_TYPE_SELL;
      request.sl=0;
      request.tp=0;
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      OrderSend(request,result);

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
