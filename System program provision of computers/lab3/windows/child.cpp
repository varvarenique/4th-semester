#include <conio.h>
#include <windows.h>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <string>
#include <limits>
#include <string>

using namespace std;


int main() {
	HANDLE Work = OpenSemaphore (SEMAPHORE_ALL_ACCESS, FALSE, "Work");
	HANDLE Close = OpenSemaphore (SEMAPHORE_ALL_ACCESS, FALSE, "Close");
	HANDLE WINAPI FileProjection = OpenFileMapping (FILE_MAP_ALL_ACCESS, FALSE, "FileProjection");

	LPVOID pointer;
	pointer = MapViewOfFile(FileProjection,	FILE_MAP_ALL_ACCESS, 0,	0, 0);
	
	while (true)
	{
		WaitForSingleObject(Work, INFINITE);

		cout << "Client got: " << (char*)pointer << endl;
		ReleaseSemaphore(Work, 1, NULL);
	}
	return 0;
}
