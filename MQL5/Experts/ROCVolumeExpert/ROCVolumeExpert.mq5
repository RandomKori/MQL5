//+------------------------------------------------------------------+
//|                                              ROCVolumeExpert.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
enum ISP
  {
   FOK,
   IOC,
   RETURN
  };
//Входные переменные
input ISP      isp=RETURN;//Тип исполнения
input int      WPeriod=9;
input int      ROC=10;//ROC период
input double   ROCLevel=30000.0;//ROC уровень
input int      SL=10;//Стоп лосс
input int      TP=20;//Тейк профит
input double   Lot=1.0;//Лот
input double   MaxRisk=20;//Риск в процентах по депозиту
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING tf;
int roc,ad;
bool pos=false;
double maxbalance=0.0;
int sl,tp;
int OnInit()
  {
//---
      switch(isp)
      {
         case FOK: tf=ORDER_FILLING_FOK; break;
         case IOC: tf=ORDER_FILLING_IOC; break;
         case RETURN: tf=ORDER_FILLING_RETURN; break;
      }
      
      ad=iWPR(Symbol(),Period(),WPeriod);
      roc=iCustom(Symbol(),Period(),"ROC\\ROC.ex5",ROC,VOLUME_REAL);
      
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
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
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
            r.sl=PositionGetDouble(POSITION_PRICE_OPEN)-sl*Point();
            r.tp=PositionGetDouble(POSITION_PRICE_OPEN)+tp*Point();
           }
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            r.sl=PositionGetDouble(POSITION_PRICE_OPEN)+sl*Point();
            r.tp=PositionGetDouble(POSITION_PRICE_OPEN)-tp*Point();
           }
         OrderSend(r,rez);
        }
     }
   else
      pos=false;
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
//+------------------------------------------------------------------+
void Open()
{
   double mc1[1],roc1[1];
   
   if(CopyBuffer(roc,0,1,1,roc1)<0) return;
   if(CopyBuffer(ad,0,1,1,mc1)<0) return;
      
   MqlRates rt[1];
   
   CopyRates(Symbol(),Period(),1,1,rt);
   
   MqlTradeResult result;
   MqlTradeRequest request;

   ZeroMemory(result);
   ZeroMemory(request);
   if(roc1[0]>=ROCLevel)
   {
      sl=SL;
      tp=TP;
      if(roc1[0]>=ROCLevel*3)
      {
         sl=sl*3;
         tp=tp*3;
      }
      else
         if(roc1[0]>=ROCLevel*2)
         {
            sl=sl*2;
            tp=tp*2;
         }
      request.symbol=_Symbol;
      request.magic=777;
      request.deviation=50;
      request.action=TRADE_ACTION_DEAL;
      request.type_filling=tf;
      if(mc1[0]<20.0)
      {
         request.volume=Lot;

         request.type=ORDER_TYPE_SELL;
         request.sl=0;
         request.tp=0;
         OrderSend(request,result);
         pos=true;
      }
      if(mc1[0]>80.0)
      {
         request.volume=Lot;

         request.type=ORDER_TYPE_BUY;
         request.sl=0;
         request.tp=0;
         OrderSend(request,result);
         pos=true;
      }
   }
}