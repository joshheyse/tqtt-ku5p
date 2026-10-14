# Light Your LEDs

------ Based on the Kintex UltraScale+ KU5P development board

<img src="media/image1.png" style="width:5.76736in;height:5.29861in" />

# Function Overview

This basic tutorial uses a counter to make LED0 through LED7 flash in sequence. It introduces the Vivado development flow and project creation. All board tutorials use Vivado 2024.1. Download and install it from the Xilinx website.

Hardware Resources

This tutorial uses eight LEDs, as shown in Figure 1-1.

|  |
|:--:|
| <img src="media/image2.png" style="width:1.47222in;height:5.01389in" /> |
| Figure 1-1. LEDs on the board |

The schematic shows that the board LEDs illuminate when driven high, as shown in Figure 1-2.

|  |
|----|
| <img src="media/image3.png" style="width:5.76806in;height:4.43264in" /> |
| Figure 1-2. LED schematic |

**Create the Project**

Open Vivado, as shown in Figure 1-3.

|  |
|----|
| <img src="media/image4.png" style="width:0.875in;height:1.05556in" /> |
| Figure 1-3 |

Create a new project. Select Create Project, as shown in Figure 1-4.

|  |
|----|
| <img src="media/image5.png" style="width:5.125in;height:3in" /> |
| Figure 1-4 |

Select Next, as shown in Figure 1-5.

|  |
|----|
| <img src="media/image6.png" style="width:5.31944in;height:3.39375in" /> |
| Figure 1-5 |

Set the project name to `led_shift`.

Select the project location. The path must not contain Chinese characters. See Figure 1-6.

|  |
|:--:|
| <img src="media/image7.png" style="width:5.76181in;height:3.67639in" /> |
| Figure 1-6 |

Keep the default options on this page and select Next, as shown in Figure 1-7.

|  |
|----|
| <img src="media/image8.png" style="width:5.76181in;height:3.67639in" /> |
| Figure 1-7 |

This page adds files or directories, or creates files. Select Next to first learn the project design flow. See Figure 1-8.

|  |
|----|
| <img src="media/image9.png" style="width:5.76181in;height:3.67639in" /> |
| Figure 1-8 |

This page adds or creates a constraint file. Skip it and select Next, as shown in Figure 1-9.

|  |
|----|
| <img src="media/image10.png" style="width:5.76181in;height:3.67639in" /> |
| Figure 1-9 |

Select the device. The development board uses `xcku5p-ffvb676-2-i`. Select this device and then select Next. See Figure 1-10.

|  |
|----|
| <img src="media/image11.png" style="width:5.76181in;height:3.67639in" /> |
| Figure 1-10 |

Select Finish to create the project, as shown in Figure 1-11.

|  |
|----|
| <img src="media/image12.png" style="width:5.76181in;height:3.67639in" /> |
| Figure 1-11 |

**Add a Design File**

Select Add Sources or `+` to add a design file, as shown in Figure 1-12.

|  |
|----|
| <img src="media/image13.png" style="width:3.72917in;height:2.56528in" /> |
| Figure 1-12 |

The options add a constraint file, design file, or simulation file. Select the design file, as shown in Figure 1-13.

|  |
|----|
| <img src="media/image14.png" style="width:5.76181in;height:3.90694in" /> |
| Figure 1-13 |

Select Create File, enter `led_shift`, select OK, and then select Finish. See Figure 1-14.

|  |
|----|
| <img src="media/image15.png" style="width:5.76181in;height:3.90694in" /> |
| Figure 1-14 |

Enter the module name `led_shift` and select OK to create the design file.

This page sets the module name and I/O ports. Normally, set I/O ports in code. See Figure 1-15.

|  |
|----|
| <img src="media/image16.png" style="width:5.7625in;height:4.12708in" /> |
| Figure 1-15 |

View the created design file. Open the Hierarchy window, double-click Design Sources, and open the `led_shift` design file. See Figure 1-16.

|  |
|----|
| <img src="media/image17.png" style="width:5.76806in;height:4.425in" /> |
| Figure 1-16 |

Add the code in Table 1-1 to `led_shift`.

|  |
|----|
| module led_shift#(parameter CNT_MAX = 49_999_999)( |
| input clk , |
| output reg \[7:0\] led |
| ); |
| reg \[31:0\] cntr ; wire cntr_end = cntr == CNT_MAX ; |
| always@(posedge clk ) cntr \<= ( cntr_end ) ?0:(cntr+1) ; |
| reg \[2:0\]sec_cntr ;always@(posedge clk ) if (cntr_end)sec_cntr\<= sec_cntr+1; |
| always@(posedge clk ) led \<= 1 \<\<sec_cntr; |
| endmodule |
| Table 1-1. Code to add to the file |
|  |

Create the Pin Constraint File

Select `+`, as shown in Figure 1-17.

|  |
|----|
| <img src="media/image18.png" style="width:5.08333in;height:2.09722in" /> |
| Figure 1-17 |

Select the pin constraint file and then select Next, as shown in Figure 1-18.

|  |
|----|
| <img src="media/image19.png" style="width:5.76181in;height:3.90694in" /> |
| Figure 1-18 |

Select Create File, enter the file name, select OK, and then select Finish. This creates the pin constraint file. See Figure 1-19.

|  |
|----|
| <img src="media/image20.png" style="width:4.86806in;height:3.30069in" /> |
| Figure 1-19 |

View the pin constraint file.

Select Hierarchy, double-click Constraints, double-click `constrs`, and double-click `pin.xdc`. This opens the pin constraint file. See Figure 1-20.

|  |
|----|
| <img src="media/image21.png" style="width:4.36875in;height:4.08889in" /> |
| Figure 1-20 |

Assign pins from the schematic, as shown in Figure 1-21.

|  |
|----|
| <img src="media/image22.png" style="width:5.05139in;height:3.11875in" /> |
| Figure 1-21. Partial schematic |

The schematic shows that `+ADJ` is 1.8 V, as shown in Figure 1-22.

|  |
|----|
| <img src="media/image23.png" style="width:1.85417in;height:1.45139in" /> |
| Figure 1-22 |

Open `pin.xdc` and add the Table 1-2 code to assign the device pins.

|  |
|----|
| set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS18} \[get_ports clk \] ; |
| set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS18} \[get_ports led\[0\] \] ; |
| set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS18} \[get_ports led\[1\] \] ; |
| set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS18} \[get_ports led\[2\] \] ; |
| set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS18} \[get_ports led\[3\] \] ; |
| set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS18} \[get_ports led\[4\] \] ; |
| set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS18} \[get_ports led\[5\] \] ; |
| set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS18} \[get_ports led\[6\] \] ; |
| set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS18} \[get_ports led\[7\] \] ; |
| Table 1-2. Pin constraint code |

Generate the Bitstream

Select Generate Bitstream and then select OK, as shown in Figure 1-23.

|  |
|----|
| <img src="media/image24.png" style="width:4.90417in;height:2.18194in" /> |
| Figure 1-23 |

When this dialog appears, the code has no errors and the bitstream was generated. Select Cancel to close the dialog. See Figure 1-24.

|  |
|----|
| <img src="media/image25.png" style="width:3.54861in;height:3.23611in" /> |
| Figure 1-24 |

Program the Bitstream

Connect the board power and serial port, and turn on the power switch. See Figure 1-25.

|  |
|----|
| <img src="media/image26.png" style="width:5.22847in;height:3.825in" /> |
| Figure 1-25 |

Double-click Open Hardware Manager, select Open Target, and select Auto Connect. See Figure 1-26.

|  |
|----|
| <img src="media/image27.png" style="width:3.90417in;height:4.29931in" /> |
| Figure 1-26 |

When Vivado identifies the device, select Program Device and then select Program. See Figure 1-27.

|  |
|----|
| <img src="media/image28.png" style="width:5.76319in;height:3.06528in" /> |
| Figure 1-27 |

After programming, LED0 through LED7 flash in sequence.
