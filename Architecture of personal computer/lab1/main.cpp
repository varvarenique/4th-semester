#include <math.h>
#include <iostream>
#include <chrono>

using namespace std;

int main() {
	double a, b, x, d, resultOfFunction, resultOfFunctionAsm;
	char answer;
	do
	{
		resultOfFunction = 0;
		resultOfFunctionAsm = 0;
		cout << "Enter the ranges of the interval: ";
		while (!(cin>>a) || !(cin >> b) || a<0 || b<0) {
			cout << "Mistake! Don't worry. Just try again. ";
			cin.clear();
			rewind(stdin);
		}		
		cout << "Enter step: ";
		cin >> d;
		auto begin = std::chrono::steady_clock::now();
		for (x = a; x<b; x += d)
			resultOfFunction += (pow(x,2))-(sin(sqrt(x)));
		auto end = std::chrono::steady_clock::now();
		auto elapsed_ms = std::chrono::duration_cast<std::chrono::nanoseconds>(end - begin);
		cout << "Result of c-function: " << resultOfFunction << endl;
		cout << "The time is " << elapsed_ms.count() << " nanoseconds" << endl << endl;
		resultOfFunction = 0;
		auto beginAsm = std::chrono::steady_clock::now();
		_asm finit
		for (x = a; x<b; x += d)
		{
			_asm {
				fld x
				fmul x
				fld x
				fsqrt
				fsin
				fsub
				fstp resultOfFunction
			}
			_asm fwait
			resultOfFunctionAsm += resultOfFunction;
		}
		auto endAsm = std::chrono::steady_clock::now();
		auto elapsed_msAsm = std::chrono::duration_cast<std::chrono::nanoseconds>(endAsm - beginAsm);
		cout << "Result of assembler-function: " << resultOfFunctionAsm << endl;
		cout << "The time is " << elapsed_msAsm.count() << " nanoseconds" << endl;
		cout << "Do you want to continue? y/n";
		cin >> answer;
	} while (answer != 'n');

	return 0;

}
