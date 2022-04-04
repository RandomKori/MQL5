//+------------------------------------------------------------------+
//|                                                       ROCLog.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input int      ROCPeriod=10;//Period
input double   Level=30000.0;//Level
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; //Volumes
//--- indicator buffers
double         ROCBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ROCBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ROCPeriod);
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
    if(rates_total<ROCPeriod)
      return(0);
//--- preliminary calculations
   int pos=prev_calculated-1; // set calc position
   if(pos<ROCPeriod)
      pos=ROCPeriod;
//--- the main loop of calculations
   for(int i=pos;i<rates_total && !IsStopped();i++)
     {
      if(InpVolumeType==VOLUME_REAL)
      {
         if(volume[i]==0.0)
            ROCBuffer[i]=0.0;
         else
         {
            double v1=MathLog10((double)volume[i]+1.0);
            double v2=MathLog10((double)volume[i-ROCPeriod]+1.0);
            if(v1==0.0)
            {
               ROCBuffer[i]=0.0;
               return(rates_total);
            }
            ROCBuffer[i]=(v1-v2)/v1*100.0;
         }
      }
      else
      {
         if(tick_volume[i]==0.0)
            ROCBuffer[i]=0.0;
         else
            {
            double v1=MathLog10((double)tick_volume[i]+1.0);
            double v2=MathLog10((double)tick_volume[i-ROCPeriod]+1.0);
            if(v1==0.0)
            {
               ROCBuffer[i]=0.0;
               return(rates_total);
            }
            ROCBuffer[i]=(v1-v2)/v1*100.0;
         }
      }
      if(ROCBuffer[i]>=Level) PlaySound("alert.wav");
     }
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
