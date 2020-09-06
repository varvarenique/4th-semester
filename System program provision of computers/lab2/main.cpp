#include<windows.h>
#include<process.h>
#include<stdio.h>
#include <conio.h>
#include<time.h>
#include <vector>
#include <string>
#include <iomanip>
#include <iostream>
using namespace std;

int main() {
	vector<HANDLE> processes;
	
	printf("Parent process start to work: \n");
	printf("Press + - or q\n");
	char answer='+';
	while (answer != 'q') {
		answer = _getch();
		switch (answer) {
		case '+': {
			PROCESS_INFORMATION procInfo;
			STARTUPINFO startupInfo;
			ZeroMemory(&startupInfo, sizeof(startupInfo));
			ZeroMemory(&procInfo, sizeof(procInfo));
			int procNumber = processes.size();
			if (!CreateProcess("C:\\Users\\User\\Documents\\Visual Studio 2015\\Projects\\sem4_lab2SPOVM\\Debug\\sem2_lab4SPOVM_child.exe",
				(LPSTR)("program " + to_string(procNumber)).c_str(),
				NULL,														// process protection attributes
				NULL,														// thread protection attributes
				FALSE,														// inheritance of descriptor
				0,															// flag, type of process
				NULL,														// pointer to a memory area containing enviroment variables
				NULL,														// current directory of new process
				&startupInfo,
				&procInfo
			))
			{
				printf("Error of creating process\n");
				rewind(stdin);
				getchar();
				return -1;
			}

			HANDLE signalFromChild = CreateEvent(NULL, FALSE, FALSE, "endChild");
			processes.push_back(procInfo.hProcess);
			for (int i = 0; i < processes.size(); i++) {
				HANDLE eventToStart = CreateEvent(NULL, FALSE, FALSE, to_string(i).c_str());
				SetEvent(eventToStart);
				WaitForSingleObject(signalFromChild, INFINITE);
				if (i == processes.size() - 1) cout << "--------------------" << endl;
			}
		}
			break;
		case '-': {
			if (processes.size() > 0) {
				HANDLE lastProc = processes[processes.size() - 1];
				HANDLE signalFromChild = CreateEvent(NULL, FALSE, FALSE, "endChild");
				processes.pop_back();
				TerminateProcess(lastProc, 0);
				CloseHandle(lastProc);
				cout << "Child element was removed. You child processes now: " << endl;
				for (int i = 0; i < processes.size(); i++) {
					HANDLE eventToStart = CreateEvent(NULL, FALSE, FALSE, to_string(i).c_str());
					SetEvent(eventToStart);
					WaitForSingleObject(signalFromChild, INFINITE);
					
					if (i == processes.size() - 1) cout << "--------------------" << endl;
				}
			}
			else {
				cout << "No child processes" << endl;
			}
		}
		break;
		case 'q': {
			for (int i = processes.size() - 1; i >= 0; i--) {
				TerminateProcess(processes[i], 0);
				CloseHandle(processes[i]);
			}
		}
   	  break;
		default:
			printf("You input wrong symbol. Try again: ");
			break;
		}
	}
	return 0;
}
