//+------------------------------------------------------------------+
//|                                                    TickChart.mq5 |
//|                                                           Рэндом |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
input datetime StartDateTime=D'2018.08.01 10:00';

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <CustomSymbols\CustomSymbols.mqh>


datetime curt;
bool ok=true;
long tms=0;
long chart;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   MqlRates ticks[];
   CustomSymbolCreate("Tick-"+Symbol(),"Tick");
   curt=TimeCurrent();
   CustomRatesDelete("Tick-"+Symbol(),0,curt);

   CopyProperty("Tick-"+Symbol(),Symbol());
   MqlTick tk[];
   int ct=CopyTicksRange(Symbol(),tk,COPY_TICKS_ALL,StartDateTime*1000,(curt+10)*1000);
   if(ct==-1 || ct==0) {ok=false; Print("Ticks copy failed"); return(INIT_FAILED);}
   ArrayResize(ticks,ct);
   datetime dd=tk[0].time;
   for(int i=0;i<ct;i++)
     {
      ticks[i].time=dd;
      ticks[i].spread=(int)NormalizeDouble((tk[i].ask-tk[i].bid)/Point(),0);
      ticks[i].tick_volume=1;
      ticks[i].real_volume=0;
      ticks[i].open=tk[i].bid;
      ticks[i].high=tk[i].bid;
      ticks[i].low=tk[i].bid;
      ticks[i].close=tk[i].bid;
      dd=dd+60;

     }
   CustomRatesReplace("Tick-"+Symbol(),ticks[0].time,ticks[ArraySize(ticks)-1].time,ticks);
   SymbolSelect("Tick-"+Symbol(),true);
   chart=ChartOpen("Tick-"+Symbol(),PERIOD_M1);
   MqlTick tr[1];
   tr[0]=tk[ct-1];
   tr[0].time_msc=0;
   tr[0].time=ticks[ArraySize(ticks)-1].time;
   CustomTicksAdd("Tick-"+Symbol(),tr);
   ChartRedraw(chart);
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
   MqlTick tk[];
   MqlRates ticks[];
   int ct=CopyTicksRange(Symbol(),tk,COPY_TICKS_ALL,tms,(curt+10)*1000);
   if(ct==-1 || ct==0) {ok=false; Print("Ticks copy failed"); return;}
   ArrayResize(ticks,ct);
   int index=ArraySize(ticks)-1;
   datetime dd=ticks[index-1].time+60;
   for(int i=0;i<ct;i++)
     {
      ticks[i].time=dd;
      ticks[i].spread=(int)NormalizeDouble((tk[i].ask-tk[i].bid)/Point(),0);
      ticks[i].tick_volume=1;
      ticks[i].real_volume=0;
      ticks[i].open=tk[i].bid;
      ticks[i].high=tk[i].bid;
      ticks[i].low=tk[i].bid;
      ticks[i].close=tk[i].bid;
      dd=dd+60;

     }
   CustomRatesUpdate("Tick-"+Symbol(),ticks);
   MqlTick tr[1];
   tr[0]=tk[ct-1];
   tr[0].time_msc=0;
   tr[0].time=ticks[ArraySize(ticks)-1].time;
   CustomTicksAdd("Tick-"+Symbol(),tr);
   ChartRedraw(chart);
  }
//+------------------------------------------------------------------+
