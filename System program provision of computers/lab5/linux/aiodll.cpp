#include <aio.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

extern "C" bool reading(const char* path, const char* buffer, unsigned int from, unsigned int howMany)
{
    aiocb structure;
    structure.aio_fildes = open(path, O_RDONLY);
    structure.aio_offset = from;
    structure.aio_buf = (void*)buffer;
    structure.aio_nbytes = BUFSIZ;
    aio_read(&structure);
    while (aio_error(&structure))
    {
        puts("Wait for reading from file...");
        usleep(50);
    }
    close(structure.aio_fildes);
    return true;
}

extern "C" bool writing(const char* path, const char* buffer, unsigned int from, unsigned int howMany)
{
    aiocb structure;
    structure.aio_fildes = open(path, O_WRONLY);
    structure.aio_offset = from;
    structure.aio_buf = (void*)buffer;
    structure.aio_nbytes = howMany;
    aio_write(&structure);
    while (aio_error(&structure))
    {
        puts("writing..");
        usleep(50);
    }
    close(structure.aio_fildes);
    return true;
}
