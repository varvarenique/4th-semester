#include "stdafx.h"


#define FILES_SIZE 36
#define NUM_OF_SYMBOLS 20
#define MAX_FILE_SIZE 65535

char readWriteBuffer[MAX_FILE_SIZE];													//буфер для чтения и записи в файл

HANDLE writeEvent;
HANDLE readEvent;
HANDLE endEvent;


extern "C" __declspec(dllexport) void read() {											//объявление для экспорта

	writeEvent = CreateEvent(NULL, false, false, NULL);									// аттрибут защиты, тип сброса, начальное состояние и имя
	readEvent = CreateEvent(NULL, false, true, NULL);
	endEvent = CreateEvent(NULL, false, false, NULL);

	char files_for_read[4][FILES_SIZE] = {
		{ "file1.txt" },
		{ "file2.txt" },
		{ "file3.txt" },
		{ "file4.txt" }
	};

	char buffer[NUM_OF_SYMBOLS + 1];													//буфер для чтения из файла
	DWORD readBytes;																	//число прочитанных байт
	OVERLAPPED overlapped;																//структура для асинхронного ввода и выввода

	overlapped.hEvent = CreateEvent(NULL, false, false, NULL);							//создание события с помощью поля структуры

	for (int i = 0; i < 4; i++) {

		WaitForSingleObject(readEvent, INFINITE);

		overlapped.Offset = 0;															//младшее слово смещения в файле
		overlapped.OffsetHigh = 0;														//старшее

		strcpy_s(readWriteBuffer, sizeof(readWriteBuffer), "");							//очистка строки после каждого файла

		HANDLE readFile = CreateFile(											
			files_for_read[i],															//имя файла
			GENERIC_READ,																//режим доступа
			0,																			//совместный доступ
			NULL,																		//дескриптор защиты
			OPEN_EXISTING,																//открывает существующий файл
			0,																			//атрибуты файла
			NULL																		//дескриптор шаблона файла
		);

		do {
			memset(buffer, '\0', sizeof(buffer));										//блок памяти заполняется нуль-символами (обнуляем)

			if (ReadFile(
				readFile,																//дескриптор файла
				buffer,																	//буфер данных
				NUM_OF_SYMBOLS,															//число байт для чтения
				&readBytes,																//число прочитанных байт
				&overlapped																//указатель на структуру
			) == false) {
				break;
			}

			WaitForSingleObject(overlapped.hEvent, INFINITE);							//ждём завершения чтения (сигнальное состояние)

			strcat_s(readWriteBuffer, sizeof(readWriteBuffer), buffer);					//добавляем буфер в конец

			overlapped.Offset += readBytes;												//новое смещение,если размер файла больше

		} while (readBytes == NUM_OF_SYMBOLS);											
		SetEvent(writeEvent);																			
		CloseHandle(readFile);																		
	}
	SetEvent(endEvent);																					
	CloseHandle(overlapped.hEvent);														

}

extern "C" __declspec(dllexport) void write() {

	TCHAR file_for_write[FILES_SIZE] = "result.txt";
	HANDLE writeFile = CreateFile(file_for_write, GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);	

	DWORD writeBytes;																				
	OVERLAPPED overlapped;

	overlapped.hEvent = CreateEvent(NULL, false, false, NULL);												
	overlapped.Offset = 0;
	overlapped.OffsetHigh = 0;

	while (true) {

		if (WaitForSingleObject(writeEvent, 0) == WAIT_OBJECT_0) {						//проверяем на сигнальное состояние

			WriteFile(
				writeFile,																//дескриптор файла
				&readWriteBuffer,														//передаваемая строка
				strlen(readWriteBuffer),												//число байт для записи
				&writeBytes,															//число записанных байт
				&overlapped																//указатель на структуру
			);

			WaitForSingleObject(overlapped.hEvent, INFINITE);						

			overlapped.Offset += writeBytes;											//записываем смещение

			SetEvent(readEvent);														
		}
		if (WaitForSingleObject(endEvent, 0) == WAIT_OBJECT_0) {						//конец записи
			break;
		}
	}

	CloseHandle(writeFile);															
	CloseHandle(readEvent);															
	CloseHandle(writeEvent);
	CloseHandle(endEvent);
}
