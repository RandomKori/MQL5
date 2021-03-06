//+------------------------------------------------------------------+
//|                                                        Setka.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
enum Type
  {
   buy,
   sell,
   stop
  };
input Type     T=buy;//Тип сделок
input bool     IsMM=true;//Использовать ли ММ
input double   DD=1000.0;//Доля депозита на определенный лот
input double   Lot=0.1;//Лот
input int      TimeStart=15;//Час начала торговли
input int      TimeStop=23;//Час конца торговли
input int      TP=200;//Тэйк профит
input int      SL=200;//Стоп лосс
input int      Step=200;//Шаг между ордерами
input int      KolSd=10;//Начальное количество ордеров
input int      Otstup=200;//Отступ от цены
input bool     IsPR=true;//Торговать ли при просадке
input double   PR=10.0;//Просадка при которой ордера не выставляются
input bool     IsKS=true;//Торговать ли при привышении количества сделок
input int      KS=5;//Количество сделок
input int      Magic=777;//Магический номер
input int      Slippage=20;//Проскальзование

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double profitd,profitm,profit3m;
int OnInit()
  {
//---

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
   datetime dt=TimeCurrent();
   
   string s="";
   if(T==stop)
      s="Режим: сушка\n";
   else
      s="Режим: авто\n";
  
   s=s+"Общий профит: "+DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),2)+"\n";
   double h1=ProsP();
   s=s+"Общий профит в процентах: "+DoubleToString(h1)+"\n";
   int counts=PositionsTotal();
   
   s=s+"Количество открытых сделок: "+IntegerToString(counts)+"\n";
   
   
   HProfit();
   s=s+"Профит за день: "+DoubleToString(profitd)+"\n";
   s=s+"Профит за месяц: "+DoubleToString(profitm)+"\n";
   s=s+"Профит за 3 месяца: "+DoubleToString(profit3m)+"\n";
   if(IsKS)
      s=s+"Ограничение по количеству сделок: true\n";
   else
      s=s+"Ограничение по количеству сделок: false\n";
   if(IsPR)
      s=s+"Ограничение по просадке: true\n";
   else
      s=s+"Ограничение по просадке: false\n";
   Comment(s);
   MqlDateTime ds;
   TimeToStruct(dt,ds);
   if(ds.hour>=TimeStart && ds.hour<=TimeStop)
     {
      if(IsPR)
         if(ProsP()<=(0.0-PR))
            return;
      if(IsKS)
         if(OSTotal()>=KS)
           {
            if(OTotal()>0)
              {
               int limit=OrdersTotal()-1;
               for(int i=limit; i>=0; i--)
                 {
                  ulong tk=OrderGetTicket((uint) i);
                  if(OrderSelect(tk))
                    {
                     long type;
                     OrderGetInteger(ORDER_TYPE,type);
                     long mg;
                     OrderGetInteger(ORDER_MAGIC,mg);
                     if((type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_SELL_STOP) && mg==Magic)
                       {
                        MqlTradeRequest request= {0};
                        MqlTradeResult  result= {0};
                        ZeroMemory(request);
                        ZeroMemory(result);
                        request.action=TRADE_ACTION_REMOVE;
                        request.order = tk;
                        bool rez=OrderSend(request,result);
                        if(!rez)
                           PrintFormat("OrderSend error %d",GetLastError());
                       }
                    }
                 }
              }
            return;
           }
      Print("OK");
      if(T==buy)
        {
         if(OTotal()==0)
           {
            double pr=SymbolInfoDouble(Symbol(),SYMBOL_ASK)+Otstup*Point();

            for(int i=0; i<KolSd; i++)
              {
               double sl=0.0;
               if(SL>0)
                  sl=pr-SL*Point();
               MqlTradeRequest request= {0};
               MqlTradeResult  result= {0};
               request.action   =TRADE_ACTION_PENDING;                             // тип торговой операции
               request.symbol   =Symbol();                                         // символ
               request.volume   =Lot();                                              // объем в 0.1 лот
               request.deviation=Slippage;                                                // допустимое отклонение от цены
               request.magic    =Magic;
               request.type =ORDER_TYPE_BUY_STOP;
               request.price=pr;
               request.sl=sl;
               request.tp=pr+TP*Point();
               bool rez=OrderSend(request,result);
               if(!rez)
                  PrintFormat("OrderSend error %d",GetLastError());

               pr=pr+Step*Point();
              }
           }
         else
           {
            if(OTotal()>0)
              {
               int limit=OrdersTotal();
               double price=DBL_MAX;
               for(int i=0; i<limit; i++)
                 {
                  ulong tk=OrderGetTicket((uint) i);
                  if(OrderSelect(tk))
                    {
                     long type;
                     OrderGetInteger(ORDER_TYPE,type);
                     long mg;
                     OrderGetInteger(ORDER_MAGIC,mg);
                     if(type==ORDER_TYPE_BUY_STOP && mg==Magic)
                       {
                        double op;
                        OrderGetDouble(ORDER_PRICE_OPEN,op);
                        if(op<price)
                           price=op;
                       }
                    }
                 }
               if(price-Otstup*Point()-Step*Point()>SymbolInfoDouble(Symbol(),SYMBOL_ASK) && price!=DBL_MAX)
                 {
                  price=price-Step*Point();
                  double sl=0.0;
                  if(SL>0)
                     sl=price-SL*Point();
                  MqlTradeRequest request= {0};
                  MqlTradeResult  result= {0};
                  request.action   =TRADE_ACTION_PENDING;                             // тип торговой операции
                  request.symbol   =Symbol();                                         // символ
                  request.volume   =Lot();                                              // объем в 0.1 лот
                  request.deviation=Slippage;                                                // допустимое отклонение от цены
                  request.magic    =Magic;
                  request.type =ORDER_TYPE_BUY_STOP;
                  request.price=price;
                  request.sl=sl;
                  request.tp=price+TP*Point();
                  bool rez=OrderSend(request,result);
                  if(!rez)
                     PrintFormat("OrderSend error %d",GetLastError());
                 }
              }
           }
        }
      if(T==sell)
        {
         if(OTotal()==0)
           {
            double pr=SymbolInfoDouble(Symbol(),SYMBOL_BID)-Otstup*Point();

            for(int i=0; i<KolSd; i++)
              {
               double sl=0.0;
               if(SL>0)
                  sl=pr+SL*Point();
               MqlTradeRequest request= {0};
               MqlTradeResult  result= {0};
               request.action   =TRADE_ACTION_PENDING;                             // тип торговой операции
               request.symbol   =Symbol();                                         // символ
               request.volume   =Lot();                                              // объем в 0.1 лот
               request.deviation=Slippage;                                                // допустимое отклонение от цены
               request.magic    =Magic;
               request.type =ORDER_TYPE_SELL_STOP;
               request.price=pr;
               request.sl=sl;
               request.tp=pr-TP*Point();
               bool rez=OrderSend(request,result);
               if(!rez)
                  PrintFormat("OrderSend error %d",GetLastError());
               pr=pr-Step*Point();
              }
           }
         else
           {
            if(OTotal()>0)
              {
               int limit=OrdersTotal();
               double price=DBL_MIN;
               for(int i=0; i<limit; i++)
                 {
                  ulong tk=OrderGetTicket((uint) i);
                  if(OrderSelect(tk))
                    {
                     long type;
                     OrderGetInteger(ORDER_TYPE,type);
                     long mg;
                     OrderGetInteger(ORDER_MAGIC,mg);
                     if(type==ORDER_TYPE_BUY_STOP && mg==Magic)
                       {
                        double op;
                        OrderGetDouble(ORDER_PRICE_OPEN,op);
                        if(op>price)
                           price=op;
                       }
                    }
                 }
               if(price+Otstup*Point()+Step*Point()<SymbolInfoDouble(Symbol(),SYMBOL_BID) && price!=DBL_MIN)
                 {
                  price=price+Step*Point();
                  double sl=0.0;
                  if(SL>0)
                     sl=price+SL*Point();
                  MqlTradeRequest request= {0};
                  MqlTradeResult  result= {0};
                  request.action   =TRADE_ACTION_PENDING;                             // тип торговой операции
                  request.symbol   =Symbol();                                         // символ
                  request.volume   =Lot();                                              // объем в 0.1 лот
                  request.deviation=Slippage;                                                // допустимое отклонение от цены
                  request.magic    =Magic;
                  request.type =ORDER_TYPE_SELL_STOP;
                  request.price=price;
                  request.sl=sl;
                  request.tp=price-TP*Point();
                  bool rez=OrderSend(request,result);
                  if(!rez)
                     PrintFormat("OrderSend error %d",GetLastError());
                 }
              }
           }
        }

     }
   else
     {
      int limit=OrdersTotal()-1;
      for(int i=limit; i>=0; i--)
        {
         ulong tk=OrderGetTicket((uint) i);
         if(OrderSelect(tk))
           {
            long type;
            OrderGetInteger(ORDER_TYPE,type);
            long mg;
            OrderGetInteger(ORDER_MAGIC,mg);
            if((type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_SELL_STOP) && mg==Magic)
              {
               MqlTradeRequest request= {0};
               MqlTradeResult  result= {0};
               ZeroMemory(request);
               ZeroMemory(result);
               request.action=TRADE_ACTION_REMOVE;
               request.order = tk;
               bool rez=OrderSend(request,result);
               if(!rez)
                  PrintFormat("OrderSend error %d",GetLastError());
              }
           }
        }
     }
   if(T==stop && OTotal()>0)
     {
      int limit=OrdersTotal()-1;
      for(int i=limit; i>=0; i--)
        {
         ulong tk=OrderGetTicket((uint) i);
         if(OrderSelect(tk))
           {
            long type;
            OrderGetInteger(ORDER_TYPE,type);
            long mg;
            OrderGetInteger(ORDER_MAGIC,mg);
            if((type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_SELL_STOP) && mg==Magic)
              {
               MqlTradeRequest request= {0};
               MqlTradeResult  result= {0};
               ZeroMemory(request);
               ZeroMemory(result);
               request.action=TRADE_ACTION_REMOVE;
               request.order = tk;
               bool rez=OrderSend(request,result);
               if(!rez)
                  PrintFormat("OrderSend error %d",GetLastError());
              }
           }
        }
     }


  }
//+------------------------------------------------------------------+
int OTotal()
  {
   int rez=0;
   int limit=OrdersTotal();
   for(int i=0; i<limit; i++)
     {
      ulong tk=OrderGetTicket((uint) i);
      if(OrderSelect(tk))
        {
         long type;
         OrderGetInteger(ORDER_TYPE,type);
         long mg;
         OrderGetInteger(ORDER_MAGIC,mg);
         if((type==ORDER_TYPE_BUY_STOP || type==ORDER_TYPE_SELL_STOP) && mg==Magic)
            rez++;
        }
     }
   return rez;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OSTotal()
  {
   int rez=PositionsTotal();
   
   return rez;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lot()
  {
   double lot=Lot;
   if(IsMM)
      lot=MathFloor(AccountInfoDouble(ACCOUNT_BALANCE)/DD)*Lot;
   return lot;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HProfit()
  {
   profitd=0.0;
   profitm=0.0;
   profit3m=0.0;
   datetime dt=TimeCurrent();
   MqlDateTime ds;
   TimeToStruct(dt,ds);
   MqlDateTime ds1;
   ds1=ds;
   ds1.year=ds.year-2;
   datetime dt1=StructToTime(ds1);
   HistorySelect(dt1,dt);
   int limit=HistoryDealsTotal();
   for(int i=0; i<limit; i++)
     {
      ulong tk=HistoryDealGetTicket((uint)i);
      bool rez=HistoryDealSelect(tk);
      if(tk)
        {
         long type;
         type=HistoryDealGetInteger(tk,DEAL_TYPE);
         long mg;
         mg=HistoryDealGetInteger(tk,DEAL_MAGIC);
         long et;
         et=HistoryDealGetInteger(tk,DEAL_ENTRY);
         if((int)et==DEAL_ENTRY_OUT || (int)et==DEAL_ENTRY_INOUT)
           {
            if(type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL)
              {
               if(mg==Magic)
                 {
                  datetime dho=(datetime)HistoryDealGetInteger(tk,DEAL_TIME);
                  MqlDateTime dhs;
                  double pr;
                  pr=HistoryDealGetDouble(tk,DEAL_PROFIT);
                  TimeToStruct(dho,dhs);
                  if(ds.day==dhs.day && ds.mon==dhs.mon && ds.year==dhs.year)
                     profitd=profitd+pr;
                  if(ds.mon==dhs.mon && ds.year==dhs.year)
                     profitm=profitm+pr;
                  int mon=ds.mon;
                  if(mon==1)
                     mon=11;
                  else
                     if(mon==2)
                        mon=12;
                     else
                        mon=mon-2;
                  if(mon<=dhs.mon && ds.year==dhs.year)
                     profit3m=profit3m+pr;
                  if((mon==12) && (dhs.mon==2 || dhs.mon==1) && ds.year==dhs.year)
                     profit3m=profit3m+pr;
                  if(mon==11 && dhs.mon==1 && ds.year==dhs.year)
                     profit3m=profit3m+pr;
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProsP()
  {
   double rez=0.0;
   rez=AccountInfoDouble(ACCOUNT_PROFIT)/(AccountInfoDouble(ACCOUNT_BALANCE)/100.0);
   return rez;
  }
//+------------------------------------------------------------------+
