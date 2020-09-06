#include <stdlib.h>
#include <windows.h>
#include <iostream>
#include <thread>

using namespace std;												//определяем тип для библиотечных функций

HINSTANCE library;															// дескриптор 

void read();
void write();


int main() {

	library = LoadLibrary("sem4_lab5SPOVM_DLL.dll");

	if (library == NULL) {
		cout << "Error of loading library" << endl;
		exit(0);
	}

	cout << "in process..." << endl;

	thread reader(read);								//создание потоки чтения и записи
	thread writer(write);

	reader.join();
	writer.join();

	cout << "Everything is good. Work finished" << endl;

	FreeLibrary(library);									//выгрузка библиотеки

	return 0;
}

void read() {
	FARPROC readFromDLL = GetProcAddress(library, "read");			// возвращает адрес функции дескриптор + имя функции
	readFromDLL();
	ExitThread(0);
}

void write() {
	FARPROC writeFromDLL = GetProcAddress(library, "write");
	writeFromDLL();
	ExitThread(0);
}
