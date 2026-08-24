import serial
import time

SERIAL_PORT = '/dev/ttyUSB1' 
BAUD_RATE = 9600

def init_serial():
    try:
        ser = serial.Serial(
            port=SERIAL_PORT, 
            baudrate=BAUD_RATE,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_EVEN,    
            stopbits=serial.STOPBITS_ONE,
            timeout=1
        )
        print(f"[*] Connected {SERIAL_PORT}, baud rate: {BAUD_RATE} bps (Parity: EVEN)")
        time.sleep(2) 
        return ser
    except Exception as e:
        print(f"[!] Connection error: {e}")
        return None

def write_bram(ser, addr, data):
    """Write cmd"""
    cmd = 0x57  # 'W'
    addr_l = addr & 0xFF
    addr_h = (addr >> 8) & 0x03
    
    #Cmd -> Addr Low -> Addr High -> Data
    packet = bytes([cmd, addr_l, addr_h, data])
    
    ser.write(packet)
    print(f"[WRITE] send data: {hex(data)} to addr: {addr} ({hex(addr)})")
    time.sleep(0.05) 

def read_bram(ser, addr):
    """Read cmd"""
    cmd = 0x52  # 'R'
    addr_l = addr & 0xFF
    addr_h = (addr >> 8) & 0x03
    dummy_data = 0x00
    
    packet = bytes([cmd, addr_l, addr_h, dummy_data])
    

    ser.reset_input_buffer() 
    
    ser.write(packet)
    
    response = ser.read(1) 
    
    if len(response) == 1:
        val = response[0]
        print(f"[READ] addr {addr} ({hex(addr)}) data is: {hex(val)}")
        return val
    else:
        print(f"[READ]  ERROR!")
        return None

if __name__ == "__main__":
    fpga_serial = init_serial()
    
    if fpga_serial:
        print("-" * 50)
        print("COMMUNICATION START")
        print("-" * 50)
        
        # Test Case 1: write cmd
        write_bram(fpga_serial, addr=10, data=0x99)
        write_bram(fpga_serial, addr=20, data=0xAA)
        write_bram(fpga_serial, addr=128, data=0x55)
        write_bram(fpga_serial, addr=512, data=0x66)
        write_bram(fpga_serial, addr=1023, data=0x77)
        
        print("-" * 50)
        
        # Test Case 2: read cmd
        read_bram(fpga_serial, addr=10)
        read_bram(fpga_serial, addr=20)
        read_bram(fpga_serial, addr=128)
        read_bram(fpga_serial, addr=512)
        read_bram(fpga_serial, addr=1023)
        read_bram(fpga_serial, addr=50) 
        
        print("-" * 50)
        fpga_serial.close()
        print("DONE!.")