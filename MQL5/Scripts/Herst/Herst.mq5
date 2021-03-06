//+------------------------------------------------------------------+
//|                                                        Herst.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Piskarev D.M."
#property link      "piskarev.dmitry25@gmail.com"
#property version   "1.00"
#property script_show_inputs
#property strict


double   LogReturns[],N[],
         R,S1,DevAccum[],StdDevMas[];
int      num1,num2,num3,num4,num5,num6,num7,num8,num9,num10,num11;
double   pi=3.14159265358979323846264338;
double   MaxValue=0.0,MinValue=1000.0;
double   DevSum,Sum,M,RS,RSsum,Dconv;
double   RS1,RS2,RS3,RS4,RS5,RS6,RS7,RS8,RS9,RS10,RS11,
         LogRS1,LogRS2,LogRS3,LogRS4,LogRS5,LogRS6,LogRS7,LogRS8,LogRS9,
         LogRS10,LogRS11;
double   rs1[],rs2[],rs3[],rs4[],rs5[],rs6[],rs7[],rs8[],rs9[],rs10[],rs11[];
double   E1,E2,E3,E4,E5,E6,E7,E8,E9,E10,E11;
double   H,betaE;

double   D,StandDev;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   double close[];
   string  symbol=Symbol();  // Symbol
   ENUM_TIMEFRAMES timeframe=Period(); // Timeframe
   int      bars=Bars(symbol,timeframe);                                           //Объявляем динамический массив цен закрытия
   int copied=CopyClose(symbol,timeframe,0,bars,close);         //Копируем цены закрытия выбранной пары в
   ArraySetAsSeries(close,true);
   ArrayResize(close,bars+1);
   if(bars<1001)                                                //Создаем условие наличия 1001 бара истории
     {
         Comment("Too few bars are available! Try another timeframe.");
         Sleep(10000);                                          //Задержка надписи в течение 10 секунд
         Comment("");
         return;
     }
//+------------------------------------------------------------------+
//| Подготовка массивов                                              |
//+------------------------------------------------------------------+        
   ArrayResize(LogReturns,bars+1);
   ArrayResize(DevAccum,bars+1);
   ArrayResize(StdDevMas,bars+1);
//+------------------------------------------------------------------+
//| Массив логарифмических доходностей                                |
//+------------------------------------------------------------------+
   for(int i=1;i<+bars;i++)
      LogReturns[i]=MathLog(close[i-1]/close[i]);
//+------------------------------------------------------------------+
//|                                                                  |
//|                          R/S-анализ                              |
//|                                                                  |
//+------------------------------------------------------------------+
//--- Зададим количество элементов в каждой подгруппе
   num1=10;
   num2=20;
   num3=25;
   num4=40;
   num5=50;
   num6=100;
   num7=125;
   num8=200;
   num9=250;
   num10=500;
   num11=1000;
//--- Расчет составных Log(R/S)
   for(int A=1; A<=11; A++)
     {
      switch(A)
        {
         case 1:
           {
            ArrayResize(rs1,101);
            RSsum=0.0;
            for(int j=1; j<=100; j++)
              {
               rs1[j]=RSculc(10*j-9,10*j,10);
               RSsum=RSsum+rs1[j];
              }
            RS1=RSsum/100;
            LogRS1=MathLog(RS1);
           }
         break;
         case 2:
           {
            ArrayResize(rs2,51);
            RSsum=0.0;
            for(int j=1; j<=50; j++)
              {
               rs2[j]=RSculc(20*j-19,20*j,20);
               RSsum=RSsum+rs2[j];
              }
            RS2=RSsum/50;
            LogRS2=MathLog(RS2);
           }
         break;

         case 3:
           {
            ArrayResize(rs3,41);
            RSsum=0.0;
            for(int j=1; j<=40; j++)
              {
               rs3[j]=RSculc(25*j-24,25*j,25);
               RSsum=RSsum+rs3[j];
              }
            RS3=RSsum/40;
            LogRS3=MathLog(RS3);
           }
         break;
         case 4:
           {
            ArrayResize(rs4,26);
            RSsum=0.0;
            for(int j=1; j<=25; j++)
              {
               rs4[j]=RSculc(40*j-39,40*j,40);
               RSsum=RSsum+rs4[j];
              }
            RS4=RSsum/25;
            LogRS4=MathLog(RS4);
           }
         break;
         case 5:
           {
            ArrayResize(rs5,21);
            RSsum=0.0;
            for(int j=1; j<=20; j++)
              {
               rs5[j]=RSculc(50*j-49,50*j,50);
               RSsum=RSsum+rs5[j];
              }
            RS5=RSsum/20;
            LogRS5=MathLog(RS5);
           }
         break;
         case 6:
           {
            ArrayResize(rs6,11);
            RSsum=0.0;
            for(int j=1; j<=10; j++)
              {
               rs6[j]=RSculc(100*j-99,100*j,100);
               RSsum=RSsum+rs6[j];
              }
            RS6=RSsum/10;
            LogRS6=MathLog(RS6);
           }
         break;
         case 7:
           {
            ArrayResize(rs7,9);
            RSsum=0.0;
            for(int j=1; j<=8; j++)
              {
               rs7[j]=RSculc(125*j-124,125*j,125);
               RSsum=RSsum+rs7[j];
              }
            RS7=RSsum/8;
            LogRS7=MathLog(RS7);
           }
         break;

         case 8:
           {
            ArrayResize(rs8,6);
            RSsum=0.0;
            for(int j=1; j<=5; j++)
              {
               rs8[j]=RSculc(200*j-199,200*j,200);
               RSsum=RSsum+rs8[j];
              }
            RS8=RSsum/5;
            LogRS8=MathLog(RS8);
           }
         break;

         case 9:
           {
            ArrayResize(rs9,5);
            RSsum=0.0;
            for(int j=1; j<=4; j++)
              {
               rs9[j]=RSculc(250*j-249,250*j,250);
               RSsum=RSsum+rs9[j];
              }
            RS9=RSsum/4;
            LogRS9=MathLog(RS9);
           }
         break;
         case 10:
           {
            ArrayResize(rs10,3);
            RSsum=0.0;
            for(int j=1; j<=2; j++)
              {
               rs10[j]=RSculc(500*j-499,500*j,500);
               RSsum=RSsum+rs10[j];
              }
            RS10=RSsum/2;
            LogRS10=MathLog(RS10);
           }
         break;
         case 11:
           {
            RS11=RSculc(1,1000,1000);
            LogRS11=MathLog(RS11);
           }
         break;
        }
     }
//+----------------------------------------------------------------------+
//|  Расчет коэффициента Херста                                          |      
//+----------------------------------------------------------------------+
   H=RegCulc1000(LogRS1,LogRS2,LogRS3,LogRS4,LogRS5,LogRS6,LogRS7,LogRS8,
                 LogRS9,LogRS10,LogRS11);
//+----------------------------------------------------------------------+
//|          Расчет ожидаемых значений log(E(R/S))                       |      
//+----------------------------------------------------------------------+
   E1=MathLog(ERSculc(num1));
   E2=MathLog(ERSculc(num2));
   E3=MathLog(ERSculc(num3));
   E4=MathLog(ERSculc(num4));
   E5=MathLog(ERSculc(num5));
   E6=MathLog(ERSculc(num6));
   E7=MathLog(ERSculc(num7));
   E8=MathLog(ERSculc(num8));
   E9=MathLog(ERSculc(num9));
   E10=MathLog(ERSculc(num10));
   E11=MathLog(ERSculc(num11));
//+----------------------------------------------------------------------+
//|  Расчет беты ожидаемых значений E(R/S)                               |      
//+----------------------------------------------------------------------+  
   betaE=RegCulc1000(E1,E2,E3,E4,E5,E6,E7,E8,E9,E10,E11);
   Alert("H= ", DoubleToString(H,3), " , E= ",DoubleToString(betaE,3));
   Comment("H= ", DoubleToString(H,3), " , E= ",DoubleToString(betaE,3));
}
//+----------------------------------------------------------------------+
//|  Функция расчета R/S                                                 |      
//+----------------------------------------------------------------------+
double RSculc(int bottom,int top,int barscount)
  {
   Sum=0.0;                                      //Начальное значение суммы равно нулю
   DevSum=0.0;                                   //Начальное значение суммы накопленных
                                                 //отклонений равно нулю  
//--- Расчет суммы доходностей
   for(int i=bottom; i<=top; i++)
      Sum=Sum+LogReturns[i];                     //Накопление суммы
//--- Расчет среднего
   M=Sum/barscount;
//--- Расчет накопленных отклонений
   for(int i=bottom; i<=top; i++)
     {
      DevAccum[i]=LogReturns[i]-M+DevAccum[i-1];
      StdDevMas[i]=MathPow((LogReturns[i]-M),2);
      DevSum=DevSum+StdDevMas[i];               //Составляющая для расчета отклонения
      if(DevAccum[i]>MaxValue)                  //Если значение в массиве меньше некоторого
         MaxValue=DevAccum[i];                  //максимального, то присваиваем максимальному значению
                                                //значение элемента массива DevAccum
      if(DevAccum[i]<MinValue)                  //Логика идентична
         MinValue=DevAccum[i];
     }
//--- Расчет размаха R и отклонения S
   R=MaxValue-MinValue;                         //Размах равен разности максимального и
   MaxValue=0.0; MinValue=1000;                 //минимального значений
   S1=MathSqrt(DevSum/barscount);               //Расчет стандартного отклонения
//--- Расчет показателя R/S
   if(S1!=0)RS=R/S1;                            //Исключаем ошибку деления на "ноль"
// else Alert("Zero divide!");
   return(RS);                                  //Возвращаем значение RS-статистики
  }
//+----------------------------------------------------------------------+
//|  Калькулятор регрессии                                               |      
//+----------------------------------------------------------------------+  
double RegCulc1000(double Y1,double Y2,double Y3,double Y4,double Y5,double Y6,
                   double Y7,double Y8,double Y9,double Y10,double Y11)
  {
   double SumY=0.0;
   double SumX=0.0;
   double SumYX=0.0;
   double SumXX=0.0;
   double b=0.0;                                                  //массив, в котором будут лежать логарифмы делителей
   double n[]={10,20,25,40,50,100,125,200,250,500,1000};          //массив делителей
//---Расчет коэффициентов N
   ArrayResize(N,11);
   for (int i=0; i<=10; i++)
     {
       N[i]=MathLog(n[i]);
       SumX=SumX+N[i];
       SumXX=SumXX+N[i]*N[i];
     }
   SumY=Y1+Y2+Y3+Y4+Y5+Y6+Y7+Y8+Y9+Y10+Y11;
   SumYX=Y1*N[0]+Y2*N[1]+Y3*N[2]+Y4*N[3]+Y5*N[4]+Y6*N[5]+Y7*N[6]+Y8*N[7]+Y9*N[8]+Y10*N[9]+Y11*N[10];
//---Расчет коэффициента Beta регрессии или искомого показателя Херста
   b=(11*SumYX-SumY*SumX)/(11*SumXX-SumX*SumX);
   return(b);
  }
//+----------------------------------------------------------------------+
//|  Функция расчета ожидаемых значений E(R/S)                           |      
//+----------------------------------------------------------------------+
double ERSculc(double m)                 //m - делители 1000
  {
   double e;
   double nSum=0.0;
   double part=0.0;
   for(int i=1; i<=m-1; i++)
     {
      part=MathPow(((m-i)/i), 0.5);
      nSum=nSum+part;
     }
   e=MathPow((m*pi/2),-0.5)*nSum;
   return(e);
  }