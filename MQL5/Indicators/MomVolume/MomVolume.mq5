//+------------------------------------------------------------------+
//|                                                    MomVolume.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input int      MomPeriod=10;
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; //Volumes
//--- indicator buffers
double         MomBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MomBuffer,INDICATOR_DATA);
   
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
    if(rates_total<MomPeriod)
      return(0);
//--- preliminary calculations
   int pos=prev_calculated-1; // set calc position
   if(pos<MomPeriod)
      pos=MomPeriod;
//--- the main loop of calculations
   for(int i=pos;i<rates_total && !IsStopped();i++)
     {
      if(InpVolumeType==VOLUME_REAL)
      {
         MomBuffer[i]=(volume[i]-volume[i-MomPeriod]);
      }
      else
      {
         MomBuffer[i]=(tick_volume[i]-tick_volume[i-MomPeriod]);
      }
      
     }
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
