#include "serial_port.h"

#include <errno.h>

#ifdef _WIN32
#include <windows.h>

int serial_port_open(serial_port *port, const char *name, unsigned int baud_rate)
{
  DCB dcb;
  COMMTIMEOUTS timeouts;
  HANDLE handle = CreateFileA(name, GENERIC_READ | GENERIC_WRITE, 0, NULL,
                              OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

  if (handle == INVALID_HANDLE_VALUE || !SetupComm(handle, 4096, 4096) ||
      !GetCommState(handle, &dcb)) {
    if (handle != INVALID_HANDLE_VALUE) {
      CloseHandle(handle);
    }
    return -1;
  }
  dcb.BaudRate = (DWORD)baud_rate;
  dcb.ByteSize = 8;
  dcb.Parity = NOPARITY;
  dcb.StopBits = TWOSTOPBITS;
  dcb.fBinary = TRUE;
  dcb.fParity = FALSE;
  dcb.fOutxCtsFlow = FALSE;
  dcb.fOutxDsrFlow = FALSE;
  dcb.fDtrControl = DTR_CONTROL_ENABLE;
  dcb.fRtsControl = RTS_CONTROL_ENABLE;
  timeouts.ReadIntervalTimeout = MAXDWORD;
  timeouts.ReadTotalTimeoutMultiplier = 0;
  timeouts.ReadTotalTimeoutConstant = 100;
  timeouts.WriteTotalTimeoutMultiplier = 0;
  timeouts.WriteTotalTimeoutConstant = 1000;
  if (!SetCommState(handle, &dcb) || !SetCommTimeouts(handle, &timeouts)) {
    CloseHandle(handle);
    return -1;
  }
  port->handle = handle;
  return 0;
}

void serial_port_close(serial_port *port)
{
  if (port->handle != NULL && port->handle != INVALID_HANDLE_VALUE) {
    CloseHandle((HANDLE)port->handle);
    port->handle = NULL;
  }
}

int serial_port_write(serial_port *port, const uint8_t *data, size_t length)
{
  DWORD written;
  if (!WriteFile((HANDLE)port->handle, data, (DWORD)length, &written, NULL)) {
    return -1;
  }
  return written == length ? 0 : -1;
}

int serial_port_read_byte(serial_port *port, uint8_t *data)
{
  DWORD count;
  if (!ReadFile((HANDLE)port->handle, data, 1, &count, NULL)) {
    return -1;
  }
  return count == 1 ? 0 : 1;
}

void serial_port_sleep(unsigned int seconds)
{
  Sleep(seconds * 1000U);
}

#else
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>

static speed_t baud_to_posix(unsigned int baud_rate)
{
  switch (baud_rate) {
  case 9600: return B9600;
  case 19200: return B19200;
  case 38400: return B38400;
  case 57600: return B57600;
  case 115200: return B115200;
  default: return 0;
  }
}

int serial_port_open(serial_port *port, const char *name, unsigned int baud_rate)
{
  struct termios options;
  speed_t speed = baud_to_posix(baud_rate);
  int fd;

  if (speed == 0) {
    errno = EINVAL;
    return -1;
  }
  fd = open(name, O_RDWR | O_NOCTTY | O_SYNC);
  if (fd < 0 || tcgetattr(fd, &options) != 0) {
    if (fd >= 0) {
      close(fd);
    }
    return -1;
  }
  cfsetispeed(&options, speed);
  cfsetospeed(&options, speed);
  options.c_cflag = (options.c_cflag & ~(CSIZE | PARENB | PARODD)) | CS8 | CLOCAL | CREAD | CSTOPB;
  options.c_iflag = 0;
  options.c_oflag = 0;
  options.c_lflag = 0;
  options.c_cc[VMIN] = 0;
  options.c_cc[VTIME] = 1;
  if (tcsetattr(fd, TCSANOW, &options) != 0) {
    close(fd);
    return -1;
  }
  port->fd = fd;
  return 0;
}

void serial_port_close(serial_port *port)
{
  if (port->fd >= 0) {
    close(port->fd);
    port->fd = -1;
  }
}

int serial_port_write(serial_port *port, const uint8_t *data, size_t length)
{
  size_t written = 0;
  while (written < length) {
    ssize_t count = write(port->fd, data + written, length - written);
    if (count < 0) {
      if (errno == EINTR) continue;
      return -1;
    }
    written += (size_t)count;
  }
  return 0;
}

int serial_port_read_byte(serial_port *port, uint8_t *data)
{
  ssize_t count = read(port->fd, data, 1);
  if (count < 0) return errno == EINTR ? 1 : -1;
  return count == 1 ? 0 : 1;
}

void serial_port_sleep(unsigned int seconds)
{
  sleep(seconds);
}
#endif
