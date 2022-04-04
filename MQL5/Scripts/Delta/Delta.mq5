//+------------------------------------------------------------------+
//|                                                        Delta.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property script_show_inputs
//--- input parameters

input datetime dt=D'2004.01.01 00:00';
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   MqlRates rt[];
   datetime ct=TimeCurrent();
   CopyRates(Symbol(),Period(),dt,ct,rt);
   int len=ArraySize(rt)-1;
   int f=FileOpen(Symbol()+IntegerToString(Period())+".csv",FILE_CSV|FILE_WRITE|FILE_REWRITE);
   for(int i=0;i<len;i++)
   {
      string s="";
      double prh=0.0;
      double prl=0.0;
      prh=rt[i+1].high-rt[i].high;
      prl=rt[i+1].low-rt[i].low;
      s=DoubleToString(prh,8)+";"+DoubleToString(prl,8)+"\n";
      FileWriteString(f,s);
   }
   FileClose(f);
  }
//+------------------------------------------------------------------+
