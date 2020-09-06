#pragma warning(disable:4996)
#include<time.h>
#include<stdio.h>
#include<stdlib.h>
#include<conio.h>
#include <process.h>


int main()
{
	printf("Child start process\n");
	time_t rawtime;
	struct tm* timeinfo;
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	int pid, ppid;

	pid = _getpid();

	printf("pid of child process = %d\nCurrent local time and date: %s\nEnd of child process", pid, asctime(timeinfo));
	
	_getch();
	return 0;
}


