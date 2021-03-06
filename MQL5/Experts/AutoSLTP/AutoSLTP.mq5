//+------------------------------------------------------------------+
//|                                                     AutoSLTP.mq5 |
//|                                                           Рэндом |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//--- input parameters
input int      SL=5;
input int      TP=6;
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
void OnTrade()
  {
//---
       if(PositionSelect(Symbol()))
      {
         if(PositionGetDouble(POSITION_SL)==0.0)
         {
            MqlTradeRequest r={};
            MqlTradeResult rez={};
            
            r.action=TRADE_ACTION_SLTP;
            r.symbol=Symbol();
            r.position=PositionGetInteger(POSITION_TICKET);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            {
               r.sl=PositionGetDouble(POSITION_PRICE_OPEN)-SL*Point();
               r.tp=PositionGetDouble(POSITION_PRICE_OPEN)+TP*Point();
            }
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            {
               r.sl=PositionGetDouble(POSITION_PRICE_OPEN)+SL*Point();
               r.tp=PositionGetDouble(POSITION_PRICE_OPEN)-TP*Point();
            }
            OrderSend(r,rez);
         }
      }
  }
//+------------------------------------------------------------------+
