# TQTT-KU5P FPGA Examples

This repository contains examples and English documentation for the TQTT-KU5P board. HamGeek also identifies the board as SKU 101069.

## Board

The board uses an AMD Kintex UltraScale+ `xcku5p-ffvb676-2-i` FPGA. This repository keeps the vendor examples, translated documentation, and board constraints.

## Top-level constraints

The combined [pins.xdc](pins.xdc) file collects board pin data from the schematic and example constraints. It enables `sys_clk`, `reset_n`, and `led[3:0]`.

The other interface constraints stay commented until a top module exposes the matching ports. Copy or add only the constraints that match the top module.

CAUTION: Make sure +ADJ is between 1.71 V and 1.89 V before you use the hardware. Make sure CLK_50M is not more than VCCO + 0.20 V. Excess voltage can damage E18.

## Examples

| Directory | Purpose |
|---|---|
| [01-led](examples/01-led/) | Flash the eight board LEDs in sequence. |
| [02-programming-flash](examples/02-programming-flash/) | Program and store an FPGA image in SPI flash. |
| [03-qsfp-40g-ibert](examples/03-qsfp-40g-ibert/) | Test QSFP 40G links with IBERT. |
| [04-qsfp-100g-ibert](examples/04-qsfp-100g-ibert/) | Test QSFP 100G links with IBERT. |
| [05-pcie-xdma](examples/05-pcie-xdma/) | Test PCIe with the XDMA IP core. |
| [06-ddr4-sdram](examples/06-ddr4-sdram/) | Test DDR4 SDRAM with the MIG IP core. |
| [07-hdmi-display](examples/07-hdmi-display/) | Display an image through HDMI. |
| [08-sd-card](examples/08-sd-card/) | Read and write SD-card sectors through SPI. |
| [09-ad9361](examples/09-ad9361/) | Test an AD9361 RF daughterboard. |
| [10-buzzer](examples/10-buzzer/) | Drive the passive buzzer with PWM. |
| [11-pwm-fan](examples/11-pwm-fan/) | Control a four-wire fan with PWM. |
| [12-ds18b20](examples/12-ds18b20/) | Read temperature from a DS18B20 sensor. |
| [13-uart-to-axi](examples/13-uart-to-axi/) | Convert UART transfers to AXI Lite master transfers. |
| [14-ms5607-barometer](examples/14-ms5607-barometer/) | Read pressure, temperature, and altitude from an MS5607 sensor. |

Example 09 requires the related RF daughterboard. Contact support for the daughterboard tutorial. The tutorial is not available with the base board alone.

## Vivado projects

Each example keeps its canonical Vivado project files. Open the example `.xpr` file in Vivado. The project directory contains the `.srcs` source tree. It can also contain block-design files, IP configuration `.xci` files, constraint files, and HDL source files.

Vivado regenerates build output from these project sources. Git ignores these generated items:

- `*.runs/`, `*.cache/`, `*.gen/`, `*.hw/`, `*.sim/`, `*.tmp/`, `.Xil/`, `ip_user_files/`, and `xsim.dir/`
- Vivado journals, logs, status files, checkpoints, reports, and simulation files
- Generated programming files such as `.bit`, `.bin`, `.mcs`, and `.ltx`

## Linux utilities

The repository builds Linux serial-port utilities for examples 13 and 14. Build them with CMake:

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build
```

The build creates `uart_to_axi_serial` and `ms5607_serial` in `build/examples/`. Use `--help` to see each utility command line.
