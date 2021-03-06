//+------------------------------------------------------------------+
//|                                                  Corealation.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property script_show_inputs
//--- input parameters
input string   Sym1="EURUSD.m";
input string   Sym2="GBPUSD.m";
input int      Count=10000;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#include <Math\Stat\Math.mqh>
void OnStart()
  {
//---
      MqlRates s1[],s2[];
      double   a1[],a2[];
      int limit=Count;
      CopyRates(Sym1,Period(),0,limit,s1);
      CopyRates(Sym2,Period(),0,limit,s2);
      ArrayResize(a1,limit);
      ArrayResize(a2,limit);
      for(int i=0;i<limit;i++)
      {
         a1[i]=(s1[i].high+s1[i].low)/2.0;
         a2[i]=(s2[i].high+s2[i].low)/2.0;
      }
      double r=0.0;
      MathCorrelationPearson(a1,a2,r);
      Comment("Кореляция = ",r);
  }
//+------------------------------------------------------------------+
