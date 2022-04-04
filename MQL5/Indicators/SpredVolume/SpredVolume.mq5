//+------------------------------------------------------------------+
//|                                                  SpredVolume.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- indicator buffers
double         SVBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int sprd;
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,SVBuffer,INDICATOR_DATA);
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
   int pos=prev_calculated-1;
   if(pos<0) pos=0;
   for(int i=pos;i<rates_total && !IsStopped();i++)
   {
      SVBuffer[i]=tick_volume[i]/((high[i]-low[i])/Point());
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
