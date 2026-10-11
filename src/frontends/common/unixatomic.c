#include <winsock2.h>
#include <uade/unixatomic.h>

#include <errno.h>
#include <stdint.h>
#include <assert.h>

#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#include <io.h>

int uade_atomic_close(int fd)
{
	/*
	 * Note: uade_atomic_close() is actually useless. There are marginal
	 * platforms only where repeating on close() on EINTR is relevant.
	 */
	_close(fd);
	return 0;
}


int uade_atomic_dup2(int oldfd, int newfd)
{
  while (1) {
    if (_dup2(oldfd, newfd) < 0) {
      if (errno == EINTR)
	continue;
      return -1;
    }
    break;
  }
  return newfd;
}

ssize_t uade_atomic_read(int fd, const void *buf, size_t count)
{
  char *b = (char *) buf;
  ssize_t bytes_read = 0;
  ssize_t ret;
  while (bytes_read < count) {
    ret = _read(fd, &b[bytes_read], count - bytes_read);
    if (ret < 0) {
      if (errno == EINTR) continue;
      return -1;
    } else if (ret == 0) {
      return 0;
    }
    bytes_read += ret;
  }
  return bytes_read;
}

ssize_t uade_atomic_write(int fd, const void *buf, size_t count)
{
  char *b = (char *) buf;
  ssize_t bytes_written = 0;
  ssize_t ret;
  while (bytes_written < count) {
    ret = _write(fd, &b[bytes_written], count - bytes_written);
    if (ret < 0) {
      if (errno == EINTR) continue;
      return -1;
    }
    bytes_written += ret;
  }
  return bytes_written;
}
