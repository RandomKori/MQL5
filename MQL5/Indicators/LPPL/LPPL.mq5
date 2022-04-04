//+------------------------------------------------------------------+
//|                                                         LPPL.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input double   TC=0.0;
input double   A=0.0;
input double   B=0.0;
input double   Beta=0.0;
input double   C=0.0;
input double   Weta=0.0;
input double   Fita=0.0;
//--- indicator buffers
double         LPPLBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LPPLBuffer,INDICATOR_DATA);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
      int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;

   for(int i=limit;i<rates_total && !IsStopped();i++)
      LPPLBuffer[i]=A+B*MathPow(TC-i,Beta)*(1+C*MathCos(Weta*MathLog10(TC-i)+Fita));
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
