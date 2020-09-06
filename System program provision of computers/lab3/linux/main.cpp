#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/shm.h>
#include <sys/wait.h>
#include <unistd.h>
#include <cstring>
#include <string.h>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <limits>


using namespace std;

int main() {

    int clientStatus;

    key_t semaphoreKey, shMemoryKey;

    struct sembuf semaphoreSet;
    struct shmid_ds shMemoryStruct;

    semaphoreKey = ftok("/dev/null", 28);//generation of key for semaphore
    shMemoryKey = ftok("/dev/null", 29);// generation of key for sh mem
    int semaphoreId = semget(semaphoreKey, 4, IPC_CREAT| SHM_R | SHM_W);//create semaphore
    int shMemoryId = shmget(shMemoryKey, 10, IPC_CREAT | SHM_R | SHM_W);  //create of shared memory segment
    void *shMemoryAddress = shmat(shMemoryId, NULL, 0);//get adress of segment

    pid_t  pid = fork();
    switch(pid) {
    case -1: {
        cout << "Error of creating process" << endl;
        exit(-1);
    }
    case 0: {
        while(true) {
            // Wait server

            semaphoreSet.sem_num = 0;
            semaphoreSet.sem_op  = -1;
            semaphoreSet.sem_flg = SEM_UNDO;
            semop(semaphoreId, &semaphoreSet, 1);


            if(semctl(semaphoreId, 2, GETVAL) == 1){
               shmdt(shMemoryAddress);
                break;
            }

            shMemoryAddress = shmat(shMemoryId, NULL, 0);// get adress of segment
            cout << "Client got: " << (char*)shMemoryAddress << endl;

            // Say, that client has read the memory
            semaphoreSet.sem_num = 1;
            semaphoreSet.sem_op  = 1;
            semaphoreSet.sem_flg = SEM_UNDO;
            semop(semaphoreId, &semaphoreSet, 1);
        }
        exit(0);
    }
    default: {
        string inputString;
        char answer = 'a';
        while(answer != 'n') {
            memset(shMemoryAddress, '\0', 1);
            cout << "Server: Please, enter the string" << endl;
            getline(cin, inputString);
            strcpy((char*)shMemoryAddress, const_cast<char*>(inputString.c_str()));
            inputString.clear();
            // Server ready
            semaphoreSet.sem_num = 0;// number of semaphore
            semaphoreSet.sem_op  = 1;// add counter
            semaphoreSet.sem_flg = SEM_UNDO;
            semop(semaphoreId, &semaphoreSet, 1);
            // Wait for client
            semaphoreSet.sem_num = 1;
            semaphoreSet.sem_op  = -1;// sub
            semaphoreSet.sem_flg = SEM_UNDO;
            semop(semaphoreId, &semaphoreSet, 1);

            if(semctl(semaphoreId, 3, GETVAL) > 0){
                break;
            }
            cout << "Continue?\ny - continue\nn - exit" << endl;
            cin >> answer;
            while(cin.peek()!='\n' || (answer != 'y' && answer != 'n')){
                cout << "Wrong value. Try again: ";
                cin.clear();
                cin.ignore(numeric_limits<streamsize>::max(), '\n');
                cin >> answer;
            }
            if(answer == 'n') {

                semaphoreSet.sem_num = 2;
                semaphoreSet.sem_op  = 1;
                semaphoreSet.sem_flg = SEM_UNDO;
                semop(semaphoreId, &semaphoreSet, 1);

                semaphoreSet.sem_num = 0;
                semaphoreSet.sem_op  = 1;
                semaphoreSet.sem_flg = SEM_UNDO;
                semop(semaphoreId, &semaphoreSet, 1);

                waitpid(pid, &clientStatus, 0);
                
            }

            rewind(stdin);
            cin.clear();
            cin.ignore();
            }
        }
    }

    semctl(semaphoreId, 0, IPC_RMID, NULL);//delete semaphore
    shmdt(shMemoryAddress);
    shmctl(shMemoryId, IPC_RMID, &shMemoryStruct);// delete shared memory segment

    return 0;
}
