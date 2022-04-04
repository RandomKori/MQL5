//+------------------------------------------------------------------+
//|                                             HistoryWinExport.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property script_show_inputs
//--- input parameters
enum HL
{
   High,
   Low
};
input int      WinSize=10;
input HL       Prs=High;
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
   int len=ArraySize(rt)-WinSize+1;
   int f=FileOpen(Symbol()+IntegerToString(Period())+".csv",FILE_CSV|FILE_WRITE|FILE_REWRITE);
   for(int i=0;i<len;i++)
   {
      string s="";
      double pr=0.0;
      for(int j=0;j<WinSize;j++)
      {
         if(Prs==High)
            pr=rt[i+j].high;
         else
            pr=rt[i+j].low;
         
         s=s+DoubleToString(pr,Digits())+";";
      }
      if(Prs==High)
            pr=rt[i+WinSize].high;
         else
            pr=rt[i+WinSize].low;
      s=s+DoubleToString(pr,Digits())+"\n";
      FileWriteString(f,s);
   }
   FileClose(f);
  }
//+------------------------------------------------------------------+
