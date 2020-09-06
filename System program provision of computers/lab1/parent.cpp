#pragma warning(disable:4996)
#include<windows.h>
#include<process.h>
#include<stdio.h>
#include <conio.h>
#include<time.h>

int main() {
	PROCESS_INFORMATION procInfo;
	STARTUPINFO startupInfo;
	ZeroMemory(&startupInfo, sizeof(startupInfo));
	ZeroMemory(&procInfo, sizeof(procInfo));
	printf("Parent process start to work: \n");
	if (!CreateProcess("C:\\Users\\User\\Documents\\Visual Studio 2015\\Projects\\sem4_lab1_child\\Debug\\sem4_lab1_child.exe",
		NULL,
		NULL,
		NULL,
		FALSE,
		0,
		NULL,
		NULL,
		&startupInfo,
		&procInfo
	))
	{
		printf("Error creating process\n");
		return -1;
	}
	WaitForSingleObject(procInfo.hProcess, INFINITE);
	CloseHandle(procInfo.hProcess);
	CloseHandle(procInfo.hThread);
	time_t rawtime;
	struct tm* timeinfo;
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	int ppid;
	ppid = _getpid();
	
	printf("\npid of parent process= %d\nCurrent local time and date: %s\nEnd of parent process", ppid, asctime(timeinfo));

	_getch();
	return 0;
}
