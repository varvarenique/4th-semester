#define _CRT_SECURE_NO_WARNINGS
#include <conio.h>
#include <windows.h>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <string>
#include <limits>

using namespace std;


int main(){
	HANDLE Work = CreateSemaphore (NULL, 0, 1, "Work");
	HANDLE Close = CreateSemaphore(NULL, 0, 1, "Close");
	HANDLE WINAPI FileProjection = CreateFileMapping (INVALID_HANDLE_VALUE,	NULL, PAGE_READWRITE, 0, 100, "FileProjection");
	PROCESS_INFORMATION procInfo;
	STARTUPINFO startupInfo;
	ZeroMemory(&startupInfo, sizeof(startupInfo));
	ZeroMemory(&procInfo, sizeof(procInfo));

	if (!CreateProcess("C:\\Users\\User\\Documents\\Visual Studio 2015\\Projects\\sem4_lab3SPOVM_child\\Debug\\sem4_lab3SPOVM_child.exe", NULL, NULL, NULL, FALSE, FALSE , NULL, NULL, &startupInfo, &procInfo)) {
		printf("Error creating process\n");
		rewind(stdin);
		getchar();
		return -1;
	}

	LPVOID memoryMap = MapViewOfFile(FileProjection, FILE_MAP_ALL_ACCESS, 0, 0, 0);
	char* memoryForString = (char*)memoryMap;
	bool readyForInput = true;
	string inputString;
	char answer = 'a';
	
	while (answer != 'n') {
		cout << "Server: Please, enter the string" << endl;
		getline(cin, inputString);
		readyForInput = false;

		strcpy(memoryForString, const_cast<char*>(inputString.c_str()));
		memoryForString[inputString.length()] = '\0';
		inputString.clear();
		ReleaseSemaphore(Work, 1, NULL);
		WaitForSingleObject(Work, INFINITE);

		cout << "\nContinue? Press:\ny - continue\nn - exit" << endl;
		cin >> answer;
		while (answer != 'n' && answer != 'y' || cin.peek() != '\n') {
			cout << "Wrong value. Try again: " << endl;
			rewind(stdin);
			cin.clear();
			cin >> answer;
		}
		if (answer == 'n') {
			ReleaseSemaphore(Close, 1, NULL);
			ReleaseSemaphore(Work, 1, NULL);
			WaitForSingleObject(procInfo.hProcess, INFINITE);
			UnmapViewOfFile(memoryMap);
			CloseHandle(procInfo.hThread);
			CloseHandle(procInfo.hProcess);
			CloseHandle(Close);
			CloseHandle(Work);
			CloseHandle(FileProjection);
			return 0;
		}

		inputString.clear();
		rewind(stdin);
		cin.clear();
		cout << endl;

	}
	return 0;
}
