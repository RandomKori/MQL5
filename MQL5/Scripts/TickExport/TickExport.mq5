//+------------------------------------------------------------------+
//|                                                   TickExport.mq5 |
//|                                                           Рэндом |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property script_show_inputs
//--- input parameters
input datetime Start=D'2018.08.01 10:00:00';
input datetime End=D'2018.08.10 00:00:00';
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
      MqlTick tk[];
      int counttick=CopyTicksRange(Symbol(),tk,COPY_TICKS_TRADE,Start*1000,End*1000);
      if(counttick==-1 || counttick==0)
      {
         Print("TickExport неудалось загрузить тики");
         return;
      }
      int file=FileOpen(Symbol()+"_Ticks.csv",FILE_WRITE|FILE_UNICODE,",");
      if(file==INVALID_HANDLE)
      {
         Print("TickExport неудалось открыть файл");
         return;
      }
      string s="DateTime,Ask,Bid,Last,Volume,Type";
      FileWrite(file,s);
      for(int i=0;i<counttick;i++)
      {
         s=TimeToString(tk[i].time)+","+DoubleToString(tk[i].ask,Digits())+","+DoubleToString(tk[i].bid,Digits())+","+DoubleToString(tk[i].last,Digits())+","+IntegerToString((long)tk[i].volume);
         int tp=0;
         if((tk[i].flags & TICK_FLAG_BUY) == TICK_FLAG_BUY) tp=1;
         if((tk[i].flags & TICK_FLAG_SELL) == TICK_FLAG_SELL) tp=-1;
         s=s+","+IntegerToString(tp);
         FileWrite(file,s);
      }
      FileClose(file);
  }
//+------------------------------------------------------------------+
