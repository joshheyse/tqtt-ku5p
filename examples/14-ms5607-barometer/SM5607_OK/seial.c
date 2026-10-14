#include "serial_port.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MS5607_MAN_BASE 0x44a40000U

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

static int read_fifo(serial_port *port, unsigned int *value)
{
  unsigned int status;
  do {
    if (read_register(port, MS5607_MAN_BASE + 8, &status) != 0) return -1;
  } while ((status & (1U << 31)) != 0);
  return read_register(port, MS5607_MAN_BASE + 4, value);
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

static int read_sensor_loop(serial_port *port)
{
  unsigned short coefficients[6];
  unsigned int value;
  int index;
  if (write_register(port, MS5607_MAN_BASE + 20, 0xaaaa5555U) != 0 ||
      write_register(port, MS5607_MAN_BASE + 12, 0x48) != 0 ||
      write_register(port, MS5607_MAN_BASE + 16, 0x58) != 0) return -1;
  serial_port_sleep(1);
  for (index = 0; index < 6; ++index) {
    if (read_fifo(port, &value) != 0) return -1;
    coefficients[index] = (unsigned short)value;
  }
  for (;;) {
    unsigned int d1;
    unsigned int d2;
    long long delta;
    long long temperature;
    long long offset;
    long long sensitivity;
    long long temperature2 = 0;
    long long offset2 = 0;
    long long sensitivity2 = 0;
    long pressure;
    if (read_fifo(port, &d1) != 0 || read_fifo(port, &d2) != 0) return -1;
    delta = (long long)(d2 & 0x00ffffffU) - ((long long)coefficients[4] << 8);
    temperature = 2000 + (delta * coefficients[5] >> 23);
    offset = ((long long)coefficients[1] << 16) + ((long long)coefficients[3] * delta >> 7);
    sensitivity = ((long long)coefficients[0] << 15) + ((long long)coefficients[2] * delta >> 8);
    if (temperature < 2000) {
      temperature2 = delta * delta >> 31;
      offset2 = 5 * (temperature - 2000) * (temperature - 2000) >> 1;
      sensitivity2 = 5 * (temperature - 2000) * (temperature - 2000) >> 2;
    }
    if (temperature < -1500) {
      offset2 += 7 * (temperature + 1500) * (temperature + 1500);
      sensitivity2 += 11 * (temperature + 1500) * (temperature + 1500) >> 1;
    }
    temperature -= temperature2;
    offset -= offset2;
    sensitivity -= sensitivity2;
    pressure = (long)((((long long)(d1 & 0x00ffffffU) * sensitivity >> 21) - offset) >> 15);
    printf("temperature=%.2f C pressure=%ld Pa altitude=%.2f m\n", (double)temperature / 100.0,
           pressure, 44330.0 * (1.0 - pow((double)pressure / 101325.0, 0.1902949)));
    serial_port_sleep(1);
  }
}

static void usage(const char *program)
{
  printf("Usage: %s [--port DEVICE] [--baud RATE] [--count COUNT] [--sensor]\n", program);
}

int main(int argc, char **argv)
{
#ifdef _WIN32
  const char *port_name = "\\\\.\\COM28";
#else
  const char *port_name = "/dev/ttyUSB0";
#endif
  unsigned int baud_rate = 115200;
  unsigned int count = 200;
  int sensor_mode = 0;
  serial_port port = {0};
  int index;
  int result;

#ifndef _WIN32
  port.fd = -1;
#endif
  for (index = 1; index < argc; ++index) {
    if (strcmp(argv[index], "--help") == 0) { usage(argv[0]); return 0; }
    if (strcmp(argv[index], "--sensor") == 0) { sensor_mode = 1; continue; }
    if (index + 1 >= argc) { usage(argv[0]); return 2; }
    if (strcmp(argv[index], "--port") == 0) port_name = argv[++index];
    else if (strcmp(argv[index], "--baud") == 0) baud_rate = (unsigned int)strtoul(argv[++index], NULL, 10);
    else if (strcmp(argv[index], "--count") == 0) count = (unsigned int)strtoul(argv[++index], NULL, 10);
    else { usage(argv[0]); return 2; }
  }
  if (serial_port_open(&port, port_name, baud_rate) != 0) { perror(port_name); return 1; }
  result = sensor_mode ? read_sensor_loop(&port) : test_register_loop(&port, count);
  serial_port_close(&port);
  if (result != 0) { fprintf(stderr, "MS5607 serial test failed.\n"); return 1; }
  return 0;
}
