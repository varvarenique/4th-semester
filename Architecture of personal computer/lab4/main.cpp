#include <dos.h>
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#define  nTimes 65536

int melody[] = {
	349, 392, 440, 349, 440, 440, 392, 349, 392, 0
};
int clock[] = {
	600, 300, 600, 300, 300, 300, 300, 300, 300, 0
};

void getAndPrintNumber(long max) {
	unsigned int  number, numberLow, numberHigh;
	outp(0x43, 128);//block 
	numberLow = inp(0x42);
	numberHigh = inp(0x42);
	number = numberHigh * 256 + numberLow;
	printf("\nRandom number: %u\n", number);
	outp(0x61, inp(0x61) & 0xFD);
}
void getRandom(long max) {
	
	outp(0x43, 0xB4);
	outp(0x42, max % 256);
	max /= 256;
	outp(0x42, max);
	outp(0x61, inp(0x61) | 1);// without dynamic
	printf("Enter any key to show number... \n");
	char symbol;
	rewind(stdin);
	scanf("%c", &symbol);
	getAndPrintNumber(max);
}


void printKd() {
	int port[] = { 0x40, 0x41, 0x42 };
	unsigned long j;
	unsigned kdLow, kdHigh, kd, max;
	int blockCommand[] = { 0, 64, 128 };//00000000, 01000000,10000000 
	printf("Coefficient:\n");
	for (int iChan = 0; iChan < 3; iChan++) {
		max = 0;
		kd = 0;
		if (iChan == 2)
		{
			outp(0x61, inp(0x61) | 3);
		}
		for (j = 0; j < nTimes; j++) {
			outp(0x43, blockCommand[iChan]);
			kdLow = inp(port[iChan]);
			kdHigh = inp(port[iChan]);
			kd = kdHigh * 256 + kdLow;

		}
		if (kd > max) {
			max = kd;
		}
		if (iChan == 2)
		{
			outp(0x61, inp(0x61) & 0xFC);
		}
		printf("Max = %X, chanel - %d\n", max, iChan);
	}
}

void printWords() {

	int port[] = { 0x40, 0x41, 0x42 };
	
	unsigned char state;
	char stateWord[8];
	int i;
	outp(0x43, 0xE2); 	//11100010  0x40
	state = inp(0x40);
	for (i = 7; i >= 0; i--)
	{
		stateWord[i] = state % 2 + '0';
		state /= 2;

	}
	for (i = 0; i < 8; i++)
	{
		printf("%c", stateWord[i]);
	}
	printf("\n");
	outp(0x43, 0xE4); 	//11100100  0x41
	state = inp(0x41);
	for (i = 7; i >= 0; i--)
	{
		stateWord[i] = state % 2 + '0';
		state /= 2;

	}
	for (i = 0; i < 8; i++)
	{
		printf("%c", stateWord[i]);
	}
	printf("\n");
	outp(0x43, 0xE8); 	//11101000  0x42
	state = inp(0x42);
	for (i = 7; i >= 0; i--)
	{
		stateWord[i] = state % 2 + '0';
		state /= 2;

	}
	for (i = 0; i < 8; i++)
	{
		printf("%c", stateWord[i]);
	}
	printf("\n");
}

void setFrequency(unsigned int freq) {
	
	long base = 1193180, kd;
	outp(0x43, 0xB6);
	kd = base / freq;
	outp(0x42, kd % 256);
	kd /= 256;
	outp(0x42, kd);
}

void play() {
	

	for (int i = 0; melody[i] != 0 || clock[i] != 0; i++) {

		setFrequency(melody[i]);	
		outp(0x61, inp(0x61) | 3);
		delay(clock[i]);
		outp(0x61, inp(0x61) & 0xfc);

	}
}

int main() {

	int i;
	long range;
	char selection;

	while (1) {
		printf("1: Play sound \n");
		printf("2: Print KD\n");
		printf("3: Print condition words\n");
		printf("4: Generate random numbers\n");
		printf("5: Exit(e)\n\n");
		selection = getch();

		switch (selection) {
		case '1':
			system("cls");
			play();
			break;
		case '2':
			system("cls");
			printKd();
			getch();
			break;
		case '3':
			system("cls");
			printWords();
			getch();
			break;
		case '4':
			system("cls");
			printf("Enter the above range of random( 0<range<65536): ");
			while (!scanf("%ld", &range) || range < 1) {
				printf("Error. Try again: ");
				rewind(stdin);
			}
			getRandom(range);
			break;
		case '5':
			printf("Exiting...");
			return 0;
		default:
			printf("Error key! Please try again\n");
			break;
		}
	}
}

