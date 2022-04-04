//+------------------------------------------------------------------+
//|                                                    LineChart.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
input ENUM_APPLIED_PRICE Type=PRICE_MEDIAN;
//--- indicator buffers
double         LineBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int ma;
double MaBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MaBuffer,INDICATOR_CALCULATIONS);

   ma=iMA(Symbol(),Period(),1,0,MODE_SMA,Type);
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
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }

   if(CopyBuffer(ma,0,0,to_copy,MaBuffer)<=0)
     {
      Print("Getting MA is failed! Error",GetLastError());
      return(0);
     }

   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;

   for(int i=limit;i<rates_total && !IsStopped();i++)
      LineBuffer[i]=MaBuffer[i];
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
