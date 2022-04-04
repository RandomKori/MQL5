//+------------------------------------------------------------------+
//|                                                  MedianPrice.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- indicator buffers
double         MedianBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MedianBuffer,INDICATOR_DATA);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;
//--- 
   for(int i=limit;i<rates_total && !IsStopped();i++)
      MedianBuffer[i]=(high[i]+low[i])/2.0;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
