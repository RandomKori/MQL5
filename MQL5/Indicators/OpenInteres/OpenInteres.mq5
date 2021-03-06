//+------------------------------------------------------------------+
//|                                                  OpenInteres.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
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
      double buy,sell,oi;
      buy=SymbolInfoDouble(Symbol(),SYMBOL_SESSION_BUY_ORDERS_VOLUME);
      sell=SymbolInfoDouble(Symbol(),SYMBOL_SESSION_SELL_ORDERS_VOLUME);
      oi=SymbolInfoDouble(Symbol(),SYMBOL_SESSION_INTEREST);
      Comment("Покупки: ",buy,"\nПродажи: ",sell,"\nИнтерес: ",oi);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
