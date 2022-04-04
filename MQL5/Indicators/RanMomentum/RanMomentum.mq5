//+------------------------------------------------------------------+
//|                                                  RanMomentum.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input int      MomPeriod=14;
//--- indicator buffers
double         MomBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MomBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
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
      int limit;
      if(prev_calculated==0)
         limit=MomPeriod;
      else limit=prev_calculated-1;

      for(int i=limit;i<rates_total && !IsStopped();i++)
         MomBuffer[i]=price[i]-price[i-MomPeriod];
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
