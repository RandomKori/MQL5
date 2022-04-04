//+------------------------------------------------------------------+
//|                                                    LogVolume.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; //Volumes
//--- indicator buffers
double         LOGBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LOGBuffer,INDICATOR_DATA);
   
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
   for(int i=0;i<rates_total && !IsStopped();i++)
     {
      if(InpVolumeType==VOLUME_REAL)
      {
         LOGBuffer[i]=MathLog10((double)volume[i]+1.0);
      }
      else
      {
         LOGBuffer[i]=MathLog10((double)tick_volume[i]+1.0);
      }
     
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
