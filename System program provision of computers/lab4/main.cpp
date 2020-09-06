#include <iostream>
#include <vector>
#include <windows.h>
#include <stdlib.h>
using namespace std;
HANDLE mutex;


void* Thread(void* pParams) {

	while (true)
	{
		WaitForSingleObject(mutex, INFINITE);                      
		cout << "Thread:  " << GetCurrentThreadId() << endl;
		ReleaseMutex(mutex);                                         
		Sleep(100);
	}
}

int main(int argc, char *argv[])
{
	vector<HANDLE> threadsHandels;
	char symbol;
	HANDLE hThread;
	mutex = CreateMutex(NULL, FALSE, NULL);
	while (true) {
		WaitForSingleObject(mutex, INFINITE);

		cout << "Print +/- or q" << endl;
		rewind(stdin);
		cin.get(symbol);

		switch (symbol) {
		case '+': {
			if ((hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)Thread, NULL, CREATE_SUSPENDED, NULL)) == 0) {
				cout << "Thread create error" << endl;
				break;
			}
			threadsHandels.push_back(hThread);
			Sleep(1000);
		}
		break;

		case '-': {
			if (!threadsHandels.empty()) {
				TerminateThread(threadsHandels.back(), NO_ERROR);
				CloseHandle(threadsHandels.back());
				Sleep(1000);
				threadsHandels.pop_back();
			}
			else {
				cout << "No elements" << endl;
			}
		}
		break;

		case 'q':
			if (!threadsHandels.empty())
			{
				for (HANDLE &eachHandle : threadsHandels) {
					CloseHandle(eachHandle);
				}
				threadsHandels.clear();
			}
		exit(0);
		default:
			continue;
		}
		for (HANDLE &childID : threadsHandels) {
			ResumeThread(childID);
			ReleaseMutex(mutex);
			Sleep(100);
			WaitForSingleObject(mutex, INFINITE);
			SuspendThread(childID);
		}
		ReleaseMutex(mutex);
	}

	return 0;
}
