#include "serial_port.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned char byte_at(unsigned int value, int index)
{
  return (unsigned char)(value >> ((3 - index) * 8));
}

static int write_register(serial_port *port, unsigned int address, unsigned int value)
{
  unsigned char request[12] = {0x55, 0xaa, 0x05};
  unsigned char response;
  unsigned int checksum = 0;
  int index;

  for (index = 0; index < 4; ++index) {
    request[3 + index] = byte_at(address, index);
    request[7 + index] = byte_at(value, index);
  }
  for (index = 3; index <= 10; ++index) checksum += request[index];
  request[11] = (unsigned char)checksum;
  if (serial_port_write(port, request, sizeof(request)) != 0) return -1;
  do index = serial_port_read_byte(port, &response); while (index > 0);
  return index;
}

static int read_register(serial_port *port, unsigned int address, unsigned int *value)
{
  unsigned char request[8] = {0x55, 0xaa, 0x03};
  unsigned char response[6];
  unsigned int checksum = 0;
  int index;

  for (index = 0; index < 4; ++index) {
    request[3 + index] = byte_at(address, index);
    checksum += request[3 + index];
  }
  request[7] = (unsigned char)checksum;
  if (serial_port_write(port, request, sizeof(request)) != 0) return -1;
  for (index = 0; index < 6; ++index) {
    int result;
    do result = serial_port_read_byte(port, &response[index]); while (result > 0);
    if (result != 0) return -1;
    if (index < 5) checksum += response[index];
  }
  if (response[5] != (unsigned char)checksum || response[4] != 0) return -1;
  *value = ((unsigned int)response[0] << 24) | ((unsigned int)response[1] << 16) |
           ((unsigned int)response[2] << 8) | response[3];
  return 0;
}

static int test_register_loop(serial_port *port, unsigned int count)
{
  unsigned int expected = 0xabcdef01;
  while (count-- > 0) {
    unsigned int received;
    ++expected;
    if (write_register(port, 0x44a00000, expected) != 0 ||
        read_register(port, 0x44a00000, &received) != 0 || received != expected) return -1;
    printf("0x%08X\n", received);
  }
  return 0;
}

static void usage(const char *program)
{
  printf("Usage: %s [--port DEVICE] [--baud RATE] [--count COUNT]\n", program);
}

int main(int argc, char **argv)
{
#ifdef _WIN32
  const char *port_name = "\\\\.\\COM27";
#else
  const char *port_name = "/dev/ttyUSB0";
#endif
  unsigned int baud_rate = 115200;
  unsigned int count = 200;
  serial_port port = {0};
  int index;

#ifndef _WIN32
  port.fd = -1;
#endif
  for (index = 1; index < argc; ++index) {
    if (strcmp(argv[index], "--help") == 0) { usage(argv[0]); return 0; }
    if (index + 1 >= argc) { usage(argv[0]); return 2; }
    if (strcmp(argv[index], "--port") == 0) port_name = argv[++index];
    else if (strcmp(argv[index], "--baud") == 0) baud_rate = (unsigned int)strtoul(argv[++index], NULL, 10);
    else if (strcmp(argv[index], "--count") == 0) count = (unsigned int)strtoul(argv[++index], NULL, 10);
    else { usage(argv[0]); return 2; }
  }
  if (serial_port_open(&port, port_name, baud_rate) != 0) { perror(port_name); return 1; }
  if (test_register_loop(&port, count) != 0) {
    fprintf(stderr, "UART-to-AXI register test failed.\n");
    serial_port_close(&port);
    return 1;
  }
  serial_port_close(&port);
  return 0;
}
