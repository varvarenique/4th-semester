#include <iostream>
#include <pthread.h>
#include <vector>
#include <csignal>
#include <unistd.h>
#include <stdlib.h>

using namespace std;


pthread_mutex_t mutexPointer;

void term_handler(int i){
    pthread_mutex_lock(&mutexPointer);
    cout << "Terminate thread: " << pthread_self() << endl;
    pthread_mutex_unlock(&mutexPointer);
    pthread_exit(NULL);
}

void* startRoutine(void* arg){
    while (true)
    {
        pthread_mutex_lock(&mutexPointer);
        cout << "Thread: " << pthread_self() << endl;
        cout << "--------------------" << endl;
        pthread_mutex_unlock(&mutexPointer);
        sleep(1);
    }

}

int main(){

    struct sigaction sigAction;
    sigAction.sa_handler = term_handler;
    sigaction(SIGUSR1, &sigAction, 0);
    vector <pthread_t> threadsId;
    pthread_t id;
    char answer;
    if(pthread_mutex_init(&mutexPointer, NULL)!=0){           //create mutex
        cout << "Mutex create error" << endl;
    }
    cout << "Input symbol" << endl;
    while(true) {
        pthread_mutex_lock(&mutexPointer);
        rewind(stdin);
        cin >> answer;
        switch(answer) {
            case '+': {

                if(pthread_create(&id, NULL, startRoutine, NULL)!=0){        // create thread
                    cout << "Error of creating thread" << endl;
                    break;
                }
                threadsId.push_back(id);
                sleep(1);

            }
            break;

            case '-': {
                if (!threadsId.empty()) {
                    pthread_kill(threadsId.back(), SIGUSR1);
                    sleep(1);
                    threadsId.pop_back();
                } else {
                    cout <<  "List is empty." << endl;
                }
            }
            break;
            case 'q':{
                if(!threadsId.empty()){
                    for(pthread_t &i: threadsId) {
                        pthread_kill(i, SIGUSR1);
                    }
                    threadsId.clear();
                }
                exit(0);
            }
            default:{
                cout << "Wrong value" << endl;
            }
            break;
        }
        pthread_mutex_unlock(&mutexPointer);
        sleep(1);
    }

    return 0;
}
