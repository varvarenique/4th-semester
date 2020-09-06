#include <dos.h>
int attribute = 0x00;

struct VIDEO
{
	unsigned char symb;
	unsigned char attr;
};

void get_reg();         			//get data from registres
void print(int offset, int);		//fill in the screen

									//IRQ0-7
void interrupt(*int8) (...);		//old handlers
void interrupt(*int9) (...);
void interrupt(*intA) (...);
void interrupt(*intB) (...);
void interrupt(*intC) (...);
void interrupt(*intD) (...);
void interrupt(*intE) (...);
void interrupt(*intF) (...);
									//IRQ8-15
void interrupt(*int70) (...);
void interrupt(*int71) (...);
void interrupt(*int72) (...);
void interrupt(*int73) (...);
void interrupt(*int74) (...);
void interrupt(*int75) (...);
void interrupt(*int76) (...);
void interrupt(*int77) (...);

// new interrupt handlers
void interrupt  int60(...) { get_reg(); int8(); }
void interrupt  int61(...) { attribute++; get_reg(); int9(); }	//keyboard
void interrupt  int62(...) { get_reg(); intA(); }
void interrupt  int63(...) { get_reg(); intB(); }
void interrupt  int64(...) { get_reg(); intC(); }
void interrupt  int65(...) { get_reg(); intD(); }
void interrupt  int66(...) { get_reg(); intE(); }
void interrupt  int67(...) { get_reg(); intF(); }

void interrupt  int68(...) { get_reg(); int70(); }
void interrupt  int69(...) { get_reg(); int71(); }
void interrupt  int6A(...) { get_reg(); int72(); }
void interrupt  int6B(...) { get_reg(); int73(); }
void interrupt  int6C(...) { get_reg(); int74(); }
void interrupt  int6D(...) { get_reg(); int75(); }
void interrupt  int6E(...) { get_reg(); int76(); }
void interrupt  int6F(...) { get_reg(); int77(); }

// fill videomemory pointert
void print(int offset, int val)
{
	char temp;
	int i;
	VIDEO far* screen = (VIDEO far *)MK_FP(0xB800, 0);
	screen += offset;
	for (i = 7; i >= 0; i--)        //find bits
	{
		temp = val % 2;
		val /= 2;         //fill the screen
		screen->symb = temp + '0';
		screen->attr = attribute;
		screen++;
	}
}

// get data from registers
void get_reg()
{
	int reg;
	//leading controller
	reg = inp(0x21);  //masks
	print(0, reg);

	outp(0x20, 0x0B);//is served
	reg = inp(0x20);
	print(9, reg);

	outp(0x20, 0x0A);//requests
	reg = inp(0x20);
	print(18, reg);

	reg = inp(0xA1);  //masks
	print(80, reg);

	outp(0xA0, 0x0B);//is served
	reg = inp(0xA0);
	print(80 + 9, reg);

	outp(0xA0, 0x0A);//requests
	reg = inp(0xA0);
	print(80 + 18, reg);
}

void init()
{
	//IRQ0-7
	int8 = getvect(0x08); // timer
	int9 = getvect(0x09); // keyboard
	intA = getvect(0x0A); // vga
	intB = getvect(0x0B); // unused
	intC = getvect(0x0C); // RS-232 (COM2,4)
	intD = getvect(0x0D); // unused
	intE = getvect(0x0E); // floppy
	intF = getvect(0x0F); // printer (LPT)

						  //IRQ8-15
	int70 = getvect(0x70); // RTC
	int71 = getvect(0x71); // ?
	int72 = getvect(0x72); // ?
	int73 = getvect(0x73); // ?
	int74 = getvect(0x74); // PS/2 mouse controller
	int75 = getvect(0x75); // math coprocessor
	int76 = getvect(0x76); // hdd controller 1
	int77 = getvect(0x77); // hdd controller 2

	setvect(0x08, int68);// A8-AF
	setvect(0x09, int69);
	setvect(0x0A, int6A);
	setvect(0x0B, int6B);
	setvect(0x0C, int6C);
	setvect(0x0D, int6D);
	setvect(0x0E, int6E);
	setvect(0x0F, int6F);


	setvect(0xA8, int60);//08-0F
	setvect(0xA9, int61);
	setvect(0xAA, int62);
	setvect(0xAB, int63);
	setvect(0xAC, int64);
	setvect(0xAD, int65);
	setvect(0xAE, int66);
	setvect(0xAF, int67);


	_disable(); // disable interrupts handling (cli)

	/* MASTER */										// ports for IRQ0-7 for first
	outp(0x20, 0x11);	//ICW1							начальная команда инициализации контроллера
	outp(0x21, 0xA8);   //ICW2							установить адреса вектора прерываний для IRQ0 или IRQ8
	outp(0x21, 0x04);	//ICW3							
	outp(0x21, 0x01);	//ICW4							дополнительные режимы работы

	/* SLAVE */											//ports for IRQ8-15
	outp(0xA0, 0x11);	//ICW1							
	outp(0xA1, 0x08);   //ICW2
	outp(0xA1, 0x02);	//ICW3							определяют номер выхода ведущего контроллера, к которому подключен ведомый
	outp(0xA1, 0x01);	//ICW4

	_enable(); // enable interrupt handling (sti)
}

int main()
{
	unsigned far *fp;
	init();
	// removing psp
	FP_SEG(fp) = _psp; // segment
	FP_OFF(fp) = 0x2c; // offset
	_dos_freemem(*fp);

	_dos_keep(0, (_DS - _CS) + (_SP / 16) + 1);//TSR
	return 0;
}
