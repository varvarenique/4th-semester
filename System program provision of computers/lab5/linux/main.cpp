#include <iostream>
#include <pthread.h>
#include <string.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <unistd.h>

#define NUMBER 4

typedef bool (*foo)(const char*, const char*, unsigned int, unsigned int);

void* handle;
pthread_mutex_t writeMutex;
pthread_mutex_t delMutex;

void* threadWrite(void *ptr) {
    char path[] = "./result.txt";
    int offset = 0;
    int numberOfSymbols = 0;

    foo writeFromFile = (foo)dlsym(handle, "writing");

    while (pthread_mutex_trylock(&delMutex)) {
        pthread_mutex_lock(&writeMutex);
        for (int i = 0; i != BUFSIZ && ((char*)ptr)[i] != '\0'; i++)
            numberOfSymbols++;
        writeFromFile(path, (const char*)ptr, offset, numberOfSymbols);
        offset += numberOfSymbols;
        quantity = 0;
        pthread_mutex_unlock(&writeMutex);
        usleep(70000);
    }
    puts("End of writing");
    pthread_mutex_unlock(&delMutex);
    return 0;
}

int main() {
    char* paths[] = {"./file1.txt", "./file2.txt", "./file3.txt", "./file4.txt"};
    unsigned int count = 1;
    pthread_t thread;
    char buffer[BUFSIZ] = {};

    handle = dlopen("./aiodll.so", RTLD_LAZY);                      // зашружаем библиотеку
    foo readFromFile = (foo)dlsym(handle, "reading");               //получаем адрес функции

    pthread_mutex_init(&writeMutex, NULL);
    pthread_mutex_init(&delMutex, NULL);

    pthread_mutex_lock(&writeMutex);
    pthread_mutex_lock(&delMutex);

    pthread_create(&thread, NULL, threadWrite, buffer);

    for (int i; i < NUMBER; i++){

        readFromFile(paths[i], buffer, 0, BUFSIZ);
        pthread_mutex_unlock(&writeMutex);
        usleep(50000);
        pthread_mutex_lock(&writeMutex);
        if (i + 1 == NUMBER)
            pthread_mutex_unlock(&delMutex);
        for (int j = 0; j != BUFSIZ && buffer[j] != '\0'; j++)
            buffer[j] = {};                                             //чистим
        usleep(100000);
    }

    pthread_mutex_lock(&delMutex);

    pthread_mutex_destroy(&writeMutex);
    pthread_mutex_destroy(&delMutex);

    dlclose(handle);

    puts("Exit from program");
    return 0;
  }
