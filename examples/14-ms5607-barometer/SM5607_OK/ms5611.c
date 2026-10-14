

#include "ad9361.h"
#include "ad9361_api.h"
#include "platform.h"
#include "util.h"
#include "config.h"
#include <string.h>
#include "math.h"

#include <xil_io.h>

#define MS5611_MAN_BASE  0x43ce0000

#define MS5611_ADDRESS                (0x77)
#define MS5611_CMD_ADC_READ           (0x00)
#define MS5611_CMD_RESET              (0x1E)
#define MS5611_CMD_CONV_D1            (0x40)
#define MS5611_CMD_CONV_D2            (0x50)
#define MS5611_CMD_READ_PROM          (0xA2)

typedef enum
{
    MS5611_ULTRA_HIGH_RES   = 0x08,
    MS5611_HIGH_RES         = 0x06,
    MS5611_STANDARD         = 0x04,
    MS5611_LOW_POWER        = 0x02,
    MS5611_ULTRA_LOW_POWER  = 0x00
} ms5611_osr_t;

	static unsigned short  fc[6];
    static unsigned char  ct;
	static unsigned char  uosr;
	static int  TEMP2;
	static int64_t OFF2, SENS2;
	static unsigned int D1,D2;


	void wr_reg_ms5611(int i,unsigned int x){
		unsigned int  addr ;
		addr = MS5611_MAN_BASE ;
		addr+=i*4;
		Xil_Out32(addr,x);
		//*addr = x ;
	}

	unsigned int  rd_reg_ms5611(int i){
		unsigned int addr ;
		addr =  MS5611_MAN_BASE ;
		addr += i*4 ;
		return Xil_In32( addr ) ;
	}

static unsigned int ms5611_get_fifo(){
	unsigned int t ;
	//3'h2   : reg_data_out <= { fifo_empty,fifo_full,14'b0, fifo_cntr[15:0] };
	while(1){t = rd_reg_ms5611(2); t &= 1<<31 ; if (t==0) break;} ;
	t = rd_reg_ms5611(1);
//	printf("ms5611_get_fifo get %06x\r\n",t);
	return t;
}


unsigned int rd_fifo_len (){
	unsigned int i = rd_reg_ms5611(2);
	i &=0x3f;
//	printf("rd-fifo_len = %d \r\n",i);
//	printf("%d\r\n",i);
	return i;
}

int ms5611_init(){
	unsigned int i ;
	wr_reg_ms5611(5,0xaaaa5555);
	i = rd_reg_ms5611(5);
 	printf("readback %0x \r\n",i);
 ///	if (i!=0xaaaa5556) {printf("ms5611_init fail for this reg can not access\r\n");return 1;}
	uosr = MS5611_ULTRA_HIGH_RES ;
	wr_reg_ms5611 (  3 , MS5611_CMD_CONV_D1 + uosr  );
	wr_reg_ms5611 (  4 , MS5611_CMD_CONV_D2 + uosr  );

    sleep(1);
	i = rd_reg_ms5611(2);
	i &=0x3f;
	printf("FIFO SIZE is %d\r\n",i );
	for (i=0;i<6;++i) 	{
		fc[i] = ms5611_get_fifo() ;
		printf("fc[%d]=0x%x\r\n",i,fc[i]);
	}
}

void ms5611_up_D1_D2(){
	D1 = ms5611_get_fifo() & 0xffffff ;
	D2 = ms5611_get_fifo() & 0xffffff ;
}

int   ms5611_readPressure(int  compensation)
{
     int  dT = D2 - (unsigned int )fc[4] * 256;
    int64_t SENS = (int64_t)fc[0] * 32768 + (int64_t)fc[2] * dT / 256;
    int64_t MY_OFF = (int64_t)fc[1] * 65536 + (int64_t)fc[3] * dT / 128;
    if (compensation)
    {
	 int  TEMP = 2000 + ((int64_t) dT * fc[5]) / 8388608;
	OFF2 = 0;
	SENS2 = 0;
	if (TEMP < 2000)
	{
	    OFF2 = 5 * ((TEMP - 2000) * (TEMP - 2000)) / 2;
	    SENS2 = 5 * ((TEMP - 2000) * (TEMP - 2000)) / 4;
	}
	if (TEMP < -1500)
	{
	    OFF2 = OFF2 + 7 * ((TEMP + 1500) * (TEMP + 1500));
	    SENS2 = SENS2 + 11 * ((TEMP + 1500) * (TEMP + 1500)) / 2;
	}
	MY_OFF = MY_OFF - OFF2;
	SENS = SENS - SENS2;
    }
    unsigned int  P = (D1 * SENS / 2097152 - MY_OFF) / 32768;
    return P;
}

double  ms5611_readTemperature(int  compensation){
     int  dT = D2 - (unsigned int )fc[4] * 256;
     int  TEMP = 2000 + ((int64_t) dT * fc[5]) / 8388608;
    TEMP2 = 0;
    if (compensation)
    {
	if (TEMP < 2000)
	{
	    TEMP2 = (dT * dT) / pow(2, 31);
	}
    }
    TEMP = TEMP - TEMP2;
    return ((double)TEMP/100);
}

// Calculate altitude from Pressure & Sea level pressure
double   ms5611_getAltitude(double pressure)
{
	double  seaLevelPressure = 101325.0 ;
	//	double getAltitude(double pressure, double seaLevelPressure = 101325);
    return (44330.0f * (1.0f - pow((double)pressure / (double)seaLevelPressure, 0.1902949f)));
}

// Calculate sea level from Pressure given on specific altitude

/*
 *
 * double  ms5611_getSeaLevel(double pressure, double altitude)
{
    return ((double)pressure / pow(1.0f - ((double)altitude / 44330.0f), 5.255f));
}

*/


void test_ms5611_2(void )
{
  // Read raw values
	float absoluteAltitude ;
	  float relativeAltitude ;
	ms5611_init();

  // Read true temperature & Pressure
while(1){
  ms5611_up_D1_D2();
  double realTemperature = ms5611_readTemperature(0);
  long realPressure = ms5611_readPressure(0);

  // Calculate altitude
    absoluteAltitude = ms5611_getAltitude(realPressure);

    relativeAltitude = ms5611_getAltitude(realPressure);

 //   ms5611_readPressure(int  compensation)
//    ms5611_readTemperature(int  compensation)

 printf("--");

 //printf(" rawTemp = ");
 //printf("%d",rawTemp);
 printf(", realTemp = ");
 printf("%f",realTemperature);
 printf(" *C\n");

// printf(" rawPressure = ");
// printf("%d",rawPressure);
 printf(", realPressure = ");
 printf("%d",realPressure);
 printf(" Pa\n\n\n\n");

 printf(" absoluteAltitude = ");
 printf("%f",absoluteAltitude);
 printf(" m, relativeAltitude = ");
 printf("%f",relativeAltitude);
 printf(" m\n");
 sleep(2);

}


}


#define Sea_Level_Pressure 101325.0


int  Temp ;
int P;
float Height = 0;

void Pressure_Caculate()
{
	int64_t MY_OFF = 0,OFF2 = 0,SENS = 0, SENS2 = 0,T2 = 0;
	int64_t dT = 0;
	dT = D2 - (((int64_t)fc[4]) << 8);
	Temp = 2000 + (((int64_t)dT * fc[5])>>23);
	if(Temp < 2000)
	{
		T2 = ( dT*dT )>>31;
		OFF2 = 5 * (Temp - 2000) * (Temp - 2000) >> 1;
		SENS2 = 5 * (Temp - 2000) * (Temp - 2000) >> 2;
	}
	if(Temp < -1500)
	{
		OFF2 = OFF2 + 7 * (Temp + 1500) * (Temp + 1500);
		SENS2 = SENS2 + ( 11 * (Temp +1500) * (Temp +1500) >> 1 );
	}
	MY_OFF = (((int64_t)fc[1]) << 16) + ((fc[3] * dT) >> 7);
	SENS = (((int64_t)fc[0]) << 15) + ((fc[2] * dT) >> 8);
	MY_OFF -= OFF2;
	Temp -= T2;
	SENS -= SENS2;
	P = (((D1 * SENS)>>21) - MY_OFF)>>15;
	Height = 44330 * (1 - pow(P/Sea_Level_Pressure ,1 / 5.225));
}






void test_ms5611_1(void )
{
	  printf("start to test ms5611 \r\n");
	  ms5611_init();
	  while(1){
	  ms5611_up_D1_D2();
	  Pressure_Caculate();
	  printf("Pressure is %d ,temp is %d ,height is %f\r\n",P,Temp,Height);
	 // rd_fifo_len();
	  usleep(1000*1000);
	  rd_fifo_len();
	 // sleep(1);
	  }
}


