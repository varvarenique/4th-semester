#include <iostream>
#include <windows.h>
#include <windowsx.h>
#include <stdlib.h>

using namespace std;

void* myRealloc(void* memory, int newSize);
void* myMalloc(int size);
void  myFree(void* memory);

int main() {
	int* memory;
	int sizeAlloc;
	int sizeRealloc;
	
	//malloc
	cout << "Enter size of int array: ";
	
	while (!(cin >> sizeAlloc) || cin.peek() != '\n') {
		cout << "Error. Input integer value" << endl;
		cin.clear();
		rewind(stdin);
	}
	memory = (int*)myMalloc(sizeAlloc);

	cout << "Input elements of array:  " << endl;
	for (int i = 0; i < sizeAlloc; i++) {
		while (!(cin >> memory[i]) || cin.peek() != '\n') {
			cout << "Error. Input integer value" << endl;
			cin.clear();
			rewind(stdin);
		}
	}
	cout << "Your array: " << endl;
	for (int i = 0; i < sizeAlloc; i++) {
		cout << memory[i] << ' ';
	}
	//realloc
	cout << endl << "Input size for realloc: ";
	while (!(cin >> sizeRealloc) || cin.peek() != '\n') {
		cout << "Error. Input integer value" << endl;
		cin.clear();
		rewind(stdin);
	}
	memory = (int*)myRealloc(memory, sizeRealloc);
	cout << "Input elements of new array:  " << endl;
	for (int i = 0; i < sizeRealloc; i++) {
		while (!(cin >> memory[i]) || cin.peek() != '\n') {
			cout << "Error. Input integer value" << endl;
			cin.clear();
			rewind(stdin);
		}
	}
	cout << "Your array: " << endl;
	for (int i = 0; i < sizeRealloc; i++) {
		cout << memory[i] << ' ';
	}
	//free
	myFree(memory);
	system("pause");
	return 0;
}


void*  myMalloc(int size) {

	void* newMemoryPointer;
	
	HLOCAL memoryId = LocalAlloc(GHND, size + sizeof(HLOCAL));						//Выделяем из локальной кучи перемещаемую память(для избежания фрагментации, неизменный только дескриптор), заполненную нулями. + размер 
																					
	if (memoryId != NULL) {																					
		newMemoryPointer = LocalLock(memoryId);										//Блокируем блок памяти (т к он перемещаемый), возвращает указатель на первый байт блока памяти.
		if (newMemoryPointer != NULL){
																	
			newMemoryPointer = memoryId;											// Записываем дескриптор в начало
			newMemoryPointer = (int*)newMemoryPointer + sizeof(HLOCAL);				// указатель на следующий байт
		}
		else {
			cout << "Error. Can't block memory" << endl;
			cout << GetLastError() << endl;
			newMemoryPointer = nullptr;
		}
	}
	else {
		cout << "Allocation error" << endl;
		cout << GetLastError() << endl;
		newMemoryPointer = nullptr;
	}
	return newMemoryPointer;
}

void myFree(void* memory) {

	HLOCAL hMemory = (int*)memory - sizeof(HLOCAL);										// получаем дескриптор
	LocalUnlock(hMemory);

	if (LocalFree(hMemory) != NULL) {
		cout << "Free error" << endl;
		cout << GetLastError() << endl;
	}
	else {
		cout << "Correct!" << endl;
		memory = nullptr;
	}
}


void* myRealloc(void* memory, int newSize) {

	void* newMemory;
	HLOCAL hMemory = (int*)memory - sizeof(HLOCAL);									// получаем дескриптор

	hMemory = LocalReAlloc(hMemory, newSize, NULL);									//изменяем размер без изменения флагов

	if (hMemory != NULL) {
		newMemory = (int*)memory - sizeof(HLOCAL);
		newMemory = LocalLock(hMemory);
		if (newMemory != NULL) {
			newMemory = hMemory;
			newMemory = (int*)newMemory + sizeof(HLOCAL);
		}
		else {
			cout << "Error" << endl;
			cout << GetLastError() << endl;
			newMemory = nullptr;
		}
	}
	else {
		cout << "Error in realloc" << endl;
		cout << GetLastError() << endl;
		newMemory = nullptr;
	}
	return newMemory;
}
