//+------------------------------------------------------------------+
//|                                                        Delta.mq5 |
//|                                                           Рэндом |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input int      Count=100;
//--- indicator buffers
double         DeltaBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,DeltaBuffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   
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
      int ct=Count;
      if(Count>Bars(Symbol(),Period())) ct=Bars(Symbol(),Period());
      int limit;
      if(prev_calculated==0)
            limit=0;
      else limit=prev_calculated-1;
      for(int i=limit;i<rates_total && !IsStopped();i++)
      {
         if(i<Bars(Symbol(),Period())-ct) {DeltaBuffer[i]=0.0; continue;}
         MqlTick tk[];
         int tc=CopyTicksRange(Symbol(),tk,COPY_TICKS_TRADE,time[i]*1000,(time[i]+Period()*60)*1000-1);
         if(tc==-1 || tc==0) {DeltaBuffer[i]=0.0; continue;}
         double dt=0.0;
         for(int j=0;j<tc;j++)
         {
            if((tk[j].flags & TICK_FLAG_BUY)==TICK_FLAG_BUY) dt=dt+(double)(tk[j].volume);
            if((tk[j].flags & TICK_FLAG_SELL)==TICK_FLAG_SELL) dt=dt-(double)(tk[j].volume);
         }
         DeltaBuffer[i]=dt;
      }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
