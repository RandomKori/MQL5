//+------------------------------------------------------------------+
//|                                                          SWT.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
input int   MA1=10;
input int   MA2=30;
input int   MA3=50;
input int   MA4=100;
input int   MA5=200;
//--- indicator buffers
double         F1Buffer[];
double         F2Buffer[];
double         F3Buffer[];
double         F4Buffer[];

double         MA1Buffer[];
double         MA2Buffer[];
double         MA3Buffer[];
double         MA4Buffer[];
double         MA5Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int ma1,ma2,ma3,ma4,ma5;
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,F1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,F2Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,F3Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,F4Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,MA1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,MA2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,MA3Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,MA4Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,MA5Buffer,INDICATOR_CALCULATIONS);
   
   ma1=iMA(Symbol(),Period(),MA1,0,MODE_EMA,PRICE_MEDIAN);
   ma2=iMA(Symbol(),Period(),MA2,0,MODE_EMA,PRICE_MEDIAN);
   ma3=iMA(Symbol(),Period(),MA3,0,MODE_EMA,PRICE_MEDIAN);
   ma4=iMA(Symbol(),Period(),MA4,0,MODE_EMA,PRICE_MEDIAN);
   ma5=iMA(Symbol(),Period(),MA5,0,MODE_EMA,PRICE_MEDIAN);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   if(rates_total<MA5)
      return(0);
   int calculated=BarsCalculated(ma1);
   if(calculated<rates_total)
   {
     Print("Not all data of MA1 is calculated (",calculated,"bars ). Error",GetLastError());
     return(0);
   }
   calculated=BarsCalculated(ma2);
   if(calculated<rates_total)
   {
     Print("Not all data of MA2 is calculated (",calculated,"bars ). Error",GetLastError());
     return(0);
   }
   calculated=BarsCalculated(ma3);
   if(calculated<rates_total)
   {
     Print("Not all data of MA3 is calculated (",calculated,"bars ). Error",GetLastError());
     return(0);
   }
   calculated=BarsCalculated(ma4);
   if(calculated<rates_total)
   {
     Print("Not all data of MA4 is calculated (",calculated,"bars ). Error",GetLastError());
     return(0);
   }
   calculated=BarsCalculated(ma5);
   if(calculated<rates_total)
   {
     Print("Not all data of MA4 is calculated (",calculated,"bars ). Error",GetLastError());
     return(0);
   }
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
   {
     to_copy=rates_total-prev_calculated;
     if(prev_calculated>0) to_copy++;
   }
   if(IsStopped()) return(0);
   if(CopyBuffer(ma1,0,0,to_copy,MA1Buffer)<=0)
   {
     Print("Getting MA1 is failed! Error",GetLastError());
     return(0);
   }
   if(CopyBuffer(ma2,0,0,to_copy,MA2Buffer)<=0)
   {
     Print("Getting MA2 is failed! Error",GetLastError());
     return(0);
   }
   if(CopyBuffer(ma3,0,0,to_copy,MA3Buffer)<=0)
   {
     Print("Getting MA3 is failed! Error",GetLastError());
     return(0);
   }
   if(CopyBuffer(ma4,0,0,to_copy,MA4Buffer)<=0)
   {
     Print("Getting MA4 is failed! Error",GetLastError());
     return(0);
   }
   if(CopyBuffer(ma5,0,0,to_copy,MA5Buffer)<=0)
   {
     Print("Getting MA5 is failed! Error",GetLastError());
     return(0);
   }
   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;
   for(int i=limit;i<rates_total && !IsStopped();i++)
   {
      F1Buffer[i]=MA1Buffer[i]-MA2Buffer[i];
      F2Buffer[i]=MA2Buffer[i]-MA3Buffer[i];
      F3Buffer[i]=MA3Buffer[i]-MA4Buffer[i];
      F4Buffer[i]=MA4Buffer[i]-MA5Buffer[i];
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
