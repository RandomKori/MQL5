//+------------------------------------------------------------------+
//|                                                         Book.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    MarketBookAdd("EURUSD");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      MarketBookRelease("EURUSD");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
    MqlBookInfo bk[];
    bool res=MarketBookGet(symbol,bk);
    if(res)
    {
      int sz=ArraySize(bk);
      for(int i=0;i<sz;i++)
         Print("Цена ",bk[i].price," Объем ",bk[i].volume," Тип заявки ",bk[i].type);
    }
  }
//+------------------------------------------------------------------+
