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
input int      StopTake=200;//Тэйк и стоп
input int      Slipage=50;//Проскальзование
input int      MAPeriod=50;//Период МА
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING tf;
int m1=0;
int m2=0;
bool pos=false;
double maxbalance=0.0;
int u=0;
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
   m1=iMA(Symbol(),Period(),MAPeriod,0,MODE_SMA,PRICE_MEDIAN);
   lt.GVarName="MG_11";
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
      {
         HistorySelect(0,TimeCurrent());
         if(HistoryDealsTotal()==0)
         {
            pos=false;
            u=0;
            return;
         }
         int index=0;
         int tpy1=0;
         do
            {
              index++;
              if(index>HistoryDealsTotal())
              {
                  pos=false;
                  u=0;
                  return;
              }
              tpy1=HistoryDealGetInteger(HistoryDealGetTicket(HistoryDealsTotal()-index),DEAL_TYPE); 
            }
         while(tpy1!=DEAL_TYPE_BUY && tpy1!=DEAL_TYPE_SELL);
         double profit=HistoryDealGetDouble(HistoryDealGetTicket(HistoryDealsTotal()-index),DEAL_PROFIT);
         if(profit>0.0)
         {
            pos=false;
            u=0;
            return;
         }
         if(u<Ud)
         {
            MqlTradeResult result;
            MqlTradeRequest request;

            ZeroMemory(result);
            ZeroMemory(request);
            
            
            
            
            int tpy=HistoryDealGetInteger(HistoryDealGetTicket(HistoryDealsTotal()-index),DEAL_TYPE);
            request.symbol=_Symbol;
            request.magic=777;
            request.deviation=50;
            request.action=TRADE_ACTION_DEAL;
            request.type_filling=tf;
            if(tpy==DEAL_TYPE_SELL)
            {
               request.volume=lt.Lot();

               request.type=ORDER_TYPE_BUY;
               request.sl=0;
               request.tp=0;
               request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
               OrderSend(request,result);
               u++;
               pos=true;
            }
            if(tpy==DEAL_TYPE_BUY)
            {
               request.volume=lt.Lot();

               request.type=ORDER_TYPE_SELL;
               request.sl=0;
               request.tp=0;
               request.price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
               OrderSend(request,result);
               u++;
               pos=true;
            }
           }
           else
           {
               pos=false;
               u=0;
           }
      }
      
  }
//+------------------------------------------------------------------+

void Open()
  {
   double t[1];
   MqlRates rt[1];

   if(CopyBuffer(m1,0,1,1,t)<0) return;
   if(CopyRates(Symbol(),Period(),1,1,rt)<0) return;

   MqlTradeResult result;
   MqlTradeRequest request;

   ZeroMemory(result);
   ZeroMemory(request);

   request.symbol=_Symbol;
   request.magic=777;
   request.deviation=50;
   request.action=TRADE_ACTION_DEAL;
   request.type_filling=tf;
   if(t[0]<rt[0].close)
     {
      request.volume=lt.Lot();

      request.type=ORDER_TYPE_BUY;
      request.sl=0;
      request.tp=0;
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      OrderSend(request,result);
      pos=true;
     }
   if(t[0]>rt[0].close)
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
