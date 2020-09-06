#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <io.h>


int delayValue;
void getTime();
void setTime();
void setDelay();
void setAlarm();
void resetAlarm();

int main()
{
	
	while (1) {
		printf("\n1 - Get time\n");
		printf("2 - Set time\n");
		printf("3 - Set delay\n");
		printf("4 - Set alarm clock\n");
		printf("5 - Exit\n");

		switch (getch()) {
		case '1':
			getTime();
			break;

		case '2':
			setTime();
			break;

		case '3':
			setDelay();
			break;

		case '4':
			setAlarm();
			break;

		case '5':
			printf("Exiting...");
			return 0;

		default:
			printf("Wrong value/n");
			break;
		}
	}
}
unsigned char toBcd(int val)
{
	return (unsigned char)((val / 10 * 16) + (val % 10));
}
unsigned char fromBcd(int val)
{
	return (unsigned char)((val / 16 * 10) + (val % 16));
}
void getTime()
{
	char data[6];
	unsigned int reg[] = { 0x00, 0x02, 0x04, 0x07, 0x08, 0x09 };
	unsigned char time[6];

	for (int i = 0; i < 6; i++)
	{

		outp(0x70, reg[i]);

		data[i] = inp(0x71);
	}


	for (i = 0; i < 6; i++)
	{
		time[i] = fromBcd(data[i]);
	}

	
	printf("Time: %2d:%2d:%2d\nDate: %2d.%2d.20%2d\n", time[2], time[1], time[0], time[3], time[4], time[5]);
}


void setTime(){
	char data[6];
	unsigned int reg[] = { 0x00, 0x02, 0x04, 0x07, 0x08, 0x09 };
	int temp;
	do {
		fflush(stdin);
		printf("Hours: ");
		scanf("%i", &temp);
	} while ((temp > 23 || temp < 0));
	data[2] = toBcd(temp);

	do {
		fflush(stdin);
		printf("Minutes: ");
		scanf("%i", &temp);
	} while (temp > 59 || temp < 0);
	data[1] = toBcd(temp);

	do {
		fflush(stdin);
		printf("Seconds: ");
		scanf("%i", &temp);
	} while (temp > 59 || temp < 0);
	data[0] = toBcd(temp);

	int res;
	do {
		outp(0x70, 0x0A);		//для обновления времени
		res=inp(0x71) & 0x80;	//10000000 ждем пока 7 бит не станет 0- доступ разрешен
	} while (res);


	outp(0x70, 0xB);
	outp(0x71, inp(0x71) | 0x80);	//запрещаем обновление часов (7 бит)

	for (int i = 0; i < 3; i++)
	{
		outp(0x70, reg[i]);
		outp(0x71, data[i]);
	}


	outp(0x70, 0xB);
	outp(0x71, inp(0x71) & 0x7F);	//все разрешаем (запрещение обновления часов ставим = 0)	01111111

}
void interrupt(*oldHandler)(...);
void interrupt newHandler(...)
{
	delayValue--;
	oldHandler();

	
}
void setDelay(){
	
	fflush(stdin);
	printf("Input delay: ");
	scanf("%d", &delayValue);
	_disable();

	oldHandler = getvect(0x70);		//прерывание от часов реального времни
	setvect(0x70, newHandler);

	_enable();
	
	printf("This is your delay. Go and do important things!");
	outp(0xA1, inp(0xA1) & 0xFE); 		// размаскировать прерывания от RTC 11111110
									
	outp(0x70, 0x0B);
	outp(0x71, inp(0x71) | 0x40);		// разрешение переодических прерываний 01000000
										
	while (delayValue > 0);

	outp(0x70, 0x0B);
	outp(0x71, inp(0x71) | 0xBF);	// запрещение переодических прерываний 10111111
	outp(0xA1, inp(0xA1) & 0x01);

	_disable();
	setvect(0x70, oldHandler);
	_enable();
	
	printf("\nOkey. Come here. You can continue surf the Internet.");
	
	return;
}

void interrupt(*oldAlarmHandler) (...);
void interrupt newAlarmHandler(...) {
	puts("\nWake up!\n");

	outp(0x70, 0xB);//запретить прерывания от будильника
	outp(0x71, inp(0x71) & 0xDF);// (11011111)

	oldAlarmHandler();

	resetAlarm();
}



void setAlarm(){

	char data[6];
	int temp;
	do {
		fflush(stdin);
		printf("Hours: ");
		scanf("%i", &temp);
	} while ((temp > 23 || temp < 0));
	data[2] = toBcd(temp);

	do {
		fflush(stdin);
		printf("Minutes: ");
		scanf("%i", &temp);
	} while (temp > 59 || temp < 0);
	data[1] = toBcd(temp);

	do {
		fflush(stdin);
		printf("Seconds: ");
		scanf("%i", &temp);
	} while (temp > 59 || temp < 0);
	data[0] = toBcd(temp);

	outp(0x70, 0x05);
	outp(0x71, data[2]);
	outp(0x70, 0x03);
	outp(0x71, data[1]);
	outp(0x70, 0x01);
	outp(0x71, data[0]);



	_disable();
	oldAlarmHandler = getvect(0x4A);
	setvect(0x4A, newAlarmHandler);
	_enable();

	outp(0x70, 0x0B);
	outp(0x71, (inp(0x71) | 0x20)); // разрешить прерывание для будильника(00100000)

	outp(0xA1, (inp(0xA0) & 0xFE));//размаскировать прерывания от RTC(11111110)
	

	printf("%2d:%2d:%2d\n", fromBcd(data[2]), fromBcd(data[1]), fromBcd(data[0]));

	
}

void resetAlarm() {
	if (oldAlarmHandler == NULL)//не установлен
	{
		return;
	}

	_disable();
	setvect(0x4A, oldAlarmHandler);
	_enable();

	outp(0x70, 0x05);
	outp(0x71, 0);
	outp(0x70, 0x03);
	outp(0x71, 0);
	outp(0x70, 0x01);
	outp(0x71, 0);

}

