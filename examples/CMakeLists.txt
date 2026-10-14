add_library(serial_port common/serial_port.c)
target_include_directories(serial_port PUBLIC common)
target_compile_features(serial_port PUBLIC c_std_99)

function(add_serial_example target source)
  add_executable(${target} ${source})
  target_link_libraries(${target} PRIVATE serial_port)
  target_compile_features(${target} PRIVATE c_std_99)

  if(UNIX AND NOT APPLE)
    target_link_libraries(${target} PRIVATE m)
  endif()

  add_test(NAME ${target}_help COMMAND ${target} --help)
endfunction()

add_serial_example(
  uart_to_axi_serial
  13-uart-to-axi/SM5607_uart2axil_ok/SM5607_uart2axil_ok/seial.c)

add_serial_example(
  ms5607_serial
  14-ms5607-barometer/SM5607_OK/seial.c)
