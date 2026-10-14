#ifndef SERIAL_PORT_H
#define SERIAL_PORT_H

#include <stddef.h>
#include <stdint.h>

typedef struct serial_port serial_port;

int serial_port_open(serial_port *port, const char *name, unsigned int baud_rate);
void serial_port_close(serial_port *port);
int serial_port_write(serial_port *port, const uint8_t *data, size_t length);
int serial_port_read_byte(serial_port *port, uint8_t *data);
void serial_port_sleep(unsigned int seconds);

struct serial_port {
#ifdef _WIN32
  void *handle;
#else
  int fd;
#endif
};

#endif
