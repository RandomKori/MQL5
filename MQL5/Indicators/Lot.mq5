//+------------------------------------------------------------------+
//|                                                          Lot.mq5 |
//|                                                           Рэндом |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Рэндом"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
//--- input parameters
input double   Frac=1000.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Comment("Lot=",FLot(Frac));
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
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   Comment("Lot=",FLot(Frac));
  }
//+------------------------------------------------------------------+

double FLot(double Fract)
{
   double minl=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxl=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double lot=MathFloor(AccountInfoDouble(ACCOUNT_BALANCE)/Fract)*minl;
   if(lot>maxl) lot=maxl;
   if(lot<minl) lot=minl;
   return lot;
}
