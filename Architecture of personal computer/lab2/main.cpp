#include <windows.h>
#include <stdio.h>
#include <time.h>

void showArray(short array[], int);

int main() {
	int count = 1000000, length = 16;
	clock_t start, stop;
	short a_array[16], b_array[16], max_array[16];
	for (int i = 0; i < length; i++) {
		a_array[i] = i + 1;//-999 + rand() % 999;
		b_array[i] = length - i;//-999 + rand() % 999;
	}
	showArray(a_array, length);
	showArray(b_array, length);
	start = clock();
	for (int j = 0; j < count; j++) {
		for (int i = 0; i < length; i++) {
			if (a_array[i] > b_array[i]) {
				max_array[i] = a_array[i];
			}
			else max_array[i] = b_array[i];
		}
	}

	stop = clock();
	printf("C:\n");
	showArray(max_array, length);
	float  res = stop - start;
	printf("\nTime:%.40f\n", res/CLOCKS_PER_SEC);
	clock_t startAsm, stopAsm;
	startAsm = clock();
	for (int i = 0; i < count; i++) {
		_asm {
			pusha
			xor esi, esi
			mov ecx, 16
			findMaxArray:
				mov ax, a_array[esi]
				mov bx, b_array[esi]
				cmp ax, bx
				jge great
				jmp less
			great :
				mov max_array[esi], ax
				jmp end
			less :
				mov max_array[esi], bx
			end :
				add esi, 2
			loop findMaxArray
			popa
		}
	}
	stopAsm = clock();
	printf("Assembler:\n");
	showArray(max_array, length);
		res = stopAsm - startAsm;
	printf("\nTime:%.40f\n", res / CLOCKS_PER_SEC);
	clock_t startMMX, stopMMX;
	startMMX = clock();
	for (int i = 0; i < count; i++) {
		_asm {
			pusha
			mov ecx, 4
			xor esi, esi
			findMaxArrayMMX :
				movq MM0, a_array[esi]
				movq MM1, b_array[esi]
				pmaxub MM0, MM1
				movd max_array[esi], MM0
				add esi, 8
			loop findMaxArrayMMX
				emms
				popa
		}
	}
	stopMMX = clock();
	printf("Assembler with MMX:\n");
	showArray(max_array, length);
	res = stopMMX - startMMX;
	printf("\nTime:%.40f\n", res / CLOCKS_PER_SEC);
	system("pause");
	return 0;
}

void showArray(short array[], int length) {
	for (int i = 0; i < length; i++) {
		printf("%d ", array[i]);
	}
	printf("\n");
}
