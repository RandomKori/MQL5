//+------------------------------------------------------------------+
//|                                                HistoryExport.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property script_show_inputs
//--- input parameters
input datetime Start=D'2000.01.01 00:00:00';
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
      datetime ct=TimeCurrent();
      MqlRates rt[];
      CopyRates(Symbol(),Period(),Start,ct,rt);
      int len=ArraySize(rt);
      int f=FileOpen(Symbol()+IntegerToString(Period())+".csv",FILE_CSV|FILE_WRITE|FILE_REWRITE);
      string s1="Time;Open;High;Low;Close;Real volume;Tick volume\n";
      FileWrite(f,s1);
      for(int i=0;i<len;i++)
      {
         string s=TimeToString(rt[i].time)+";"+DoubleToString(rt[i].open,Digits())+";"+DoubleToString(rt[i].high,Digits())+";"+DoubleToString(rt[i].low,Digits())+";"+DoubleToString(rt[i].close,Digits())+";"+IntegerToString(rt[i].real_volume)+";"+IntegerToString(rt[i].tick_volume)+"\n";
         FileWrite(f,s);
         
      }
      FileClose(f);
  }
//+------------------------------------------------------------------+
