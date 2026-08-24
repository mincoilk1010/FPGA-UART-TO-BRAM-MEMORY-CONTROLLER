# FPGA UART to BRAM Memory Controller

## Overview
This project implements a robust hardware memory controller on an FPGA that allows a PC to read and write data to an internal Block RAM (BRAM) using the UART protocol. The design features a custom Finite State Machine (FSM) to parse incoming serial packets, handle BRAM read/write latencies seamlessly, and transmit responses back to the host computer.

## Hardware & Software Environment
* **FPGA Board:** Sipeed Tang Nano 9K (Gowin GW1NR-9)
* **EDA Tool:** Gowin FPGA Designer
* **Host OS:** Ubuntu Linux
* **Languages:** Verilog (RTL Design), Python (Testing)

## System Architecture
The system consists of the following key Verilog modules:
1. `baud_rate_gen.v`: Generates precise `Rclk_en` (16x oversampling) and `Tclk_en` pulses for a target baud rate of 9600 bps from a 27MHz system clock, minimizing baud rate accumulation error.
2. `uart_rx.v`: Asynchronous receiver that safely samples incoming bits and outputs an 8-bit parallel data wire along with a `rx_ready` flag.
3. `uart_tx.v`: Asynchronous transmitter that serializes 8-bit data into a standard UART frame (1 Start, 8 Data, 1 Even Parity, 1 Stop).
4. `uart_bram_ctrl.v`: The core FSM that bridges UART and BRAM. It parses 4-byte packets, controls the BRAM `wr_en` signals, and manages the 1-cycle read latency of synchronous memory.
5. `uart_bram_top.v`: Top-level module integrating all sub-modules and the Gowin BRAM IP Core.

## Communication Protocol
The system uses a custom 4-byte packet structure for communication over Serial (`/dev/ttyUSB1`, 9600-8-E-1).

### Write Command
Writes a single byte of data to a specific 10-bit BRAM address.
* **Byte 1:** `0x57` (ASCII 'W')
* **Byte 2:** Address Low (Bits `[7:0]`)
* **Byte 3:** Address High (Bits `[9:8]`)
* **Byte 4:** Data to write (`0x00` - `0xFF`)

### Read Command
Reads a single byte of data from a specific 10-bit BRAM address. The FPGA will respond with 1 byte of data.
* **Byte 1:** `0x52` (ASCII 'R')
* **Byte 2:** Address Low (Bits `[7:0]`)
* **Byte 3:** Address High (Bits `[9:8]`)
* **Byte 4:** Dummy Data (`0x00`)

## How to Run

### 1. FPGA Setup
1. Open the project in Gowin EDA.
2. Run Synthesis and Place & Route (`Rerun All`).
3. Connect the Tang Nano 9K board and upload the `.fs` bitstream using Gowin Programmer.
4. Press the physical Reset button on the board (Pin 3) to initialize the FSM.

### 2. Python Test Script
Ensure you have the `pyserial` library installed:
```bash
pip install pyserial

Run the automated mass read/write verification script:

Bash
python3 fpga_test.py
Note: Make sure to close Gowin Programmer before running the script to release the /dev/ttyUSB1 COM port.

Key Learnings & Timing Optimizations
Baud Rate Error Mitigation: Transitioned from 115200 bps to 9600 bps to eliminate fractional division errors from the 27MHz clock, ensuring perfect sampling at the center of each bit.

BRAM Read Latency: Optimized the FSM to pipeline the address assignment during the Dummy byte reception state, perfectly masking the 1-clock-cycle delay required by the synchronous BRAM without adding extra wait states.
