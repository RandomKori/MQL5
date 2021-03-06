//+------------------------------------------------------------------+
//|                                            3in1_ST_RSI_CCI_L.mq5 |
//|                                                           Рэндом |
//|                                    https://investforum.ru/forum/ |
//+------------------------------------------------------------------+
#property copyright "Рэндом"
#property link      "https://investforum.ru/forum/"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
//--- plot B1
#property indicator_label1  "B1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_level1 40.0
#property indicator_level2 0.0
#property indicator_level3 -40.0
#property  indicator_levelcolor clrGray

#property indicator_label2  "B2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "B3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBrown
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

input double weight_cci=0.1; // from 0 to 1 CCI
input double weight_rsi=0.1; // from 0 to 1 RSI
input int PCCI = 21; // period CCI
input int PRSI = 21; // period RSI
input int St_K=24; // Stochastic %K
input int St_S=10; // Stochastic Signal
input int FastMA=3;
input int SlowMA=7;

//--- indicator buffers
double         B1Buffer[];
double         B2Buffer[];
double         B3Buffer[];
double         B4Buffer[];
double         B5Buffer[];
double         B6Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int ccii,rsii,sti;
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,B1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,B2Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,B3Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,B4Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,B5Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,B6Buffer,INDICATOR_CALCULATIONS);
   
   ccii=iCCI(Symbol(),Period(),PCCI,PRICE_TYPICAL);
   rsii=iRSI(Symbol(),Period(),PRSI,PRICE_TYPICAL);
   sti=iStochastic(Symbol(),Period(),St_K,3,St_S,MODE_EMA,STO_CLOSECLOSE);
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
   int calculated=BarsCalculated(rsii);
   if(calculated<rates_total)
      return(0);
   calculated=BarsCalculated(ccii);
   if(calculated<rates_total)
      return(0);
   calculated=BarsCalculated(sti);
   if(calculated<rates_total)
      return(0);

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0)
         to_copy++;
     }

   if(IsStopped())
      return(0);

   if(CopyBuffer(ccii,0,0,to_copy,B4Buffer)<=0)
      return(0);
   if(CopyBuffer(rsii,0,0,to_copy,B5Buffer)<=0)
      return(0);
   if(CopyBuffer(sti,0,0,to_copy,B6Buffer)<=0)
      return(0);

   int start;
   if(prev_calculated==0)
      start=0;
   else
      start=prev_calculated-1;
  
  for(int i=start; i<rates_total && !IsStopped(); i++)
  {
   if(B4Buffer[i]==EMPTY_VALUE || B5Buffer[i]==EMPTY_VALUE || B6Buffer[i]==EMPTY_VALUE)
   {
      B1Buffer[i]=0.0;
      continue;
   }
   double rsi = B5Buffer[i]-50;
   double cci = B4Buffer[i];
   double St = B6Buffer[i]-50; 
   B1Buffer[i]=St*(1-weight_cci-weight_rsi) + rsi * weight_rsi + cci * weight_cci;
  }
  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,FastMA,B1Buffer,B2Buffer);
  LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,SlowMA,B1Buffer,B3Buffer);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
int LinearWeightedMAOnBuffer(const int rates_total,const int prev_calculated,const int begin,const int period,const double& price[],double& buffer[])
  {
//--- check period
   if(period<=1 || period>(rates_total-begin))
      return(0);
//--- save as_series flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_buffer=ArrayGetAsSeries(buffer);

   ArraySetAsSeries(price,false);
   ArraySetAsSeries(buffer,false);
//--- calculate start position
   int i,start_position;

   if(prev_calculated<=period+begin+2)  // first calculation or number of bars was changed
     {
      //--- set empty value for first bars
      start_position=period+begin;

      for(i=0; i<start_position; i++)
         buffer[i]=0.0;
     }
   else
      start_position=prev_calculated-2;
//--- calculate first visible value
   double sum=0.0,lsum=0.0;
   int    l,weight=0;

   for(i=start_position-period,l=1; i<start_position; i++,l++)
     {
      sum   +=price[i]*l;
      lsum  +=price[i];
      weight+=l;
     }
   buffer[start_position-1]=sum/weight;
//--- main loop
   for(i=start_position; i<rates_total; i++)
     {
      sum      =sum-lsum+price[i]*period;
      lsum     =lsum-price[i-period]+price[i];
      buffer[i]=sum/weight;
     }
//--- restore as_series flags
   ArraySetAsSeries(price,as_series_price);
   ArraySetAsSeries(buffer,as_series_buffer);
//---
   return(rates_total);
  }
  