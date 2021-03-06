//+------------------------------------------------------------------+
//|                                                  OpenInteres.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
      double buy,sell;
      buy=SymbolInfoDouble(Symbol(),SYMBOL_SESSION_BUY_ORDERS_VOLUME);
      sell=SymbolInfoDouble(Symbol(),SYMBOL_SESSION_SELL_ORDERS_VOLUME);
      Comment("Покупки: ",buy,"\nПродажи: ",sell);
  }
//+------------------------------------------------------------------+
