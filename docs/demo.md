# Demo

#### 1. Show and explain your Platform Designer System
   - Address of RGB LED controller: `0x0004_a820`
  - Address of ADC controller: `0x0000_0000`
  - Custom component address(es): `N/A`

   
   __STEPS__: 
   
To view the custom component addresses: 

    Open Quartus project > tools tab Select > Platform Designer

   

#### 2. Show and explain VHDL code for each component

3. Show and explain device driver source code

4. Show and explain device driver source code
      • RGB LED controller
      – register offsets
      – compatible string
      – sysfs attributes
      • Custom component 1
      • Custom component 2


#### 5. Kernel module info (check compatible string)
   • RGB LED controller
   • Custom component 1
   • Custom component 2


#### 6. sysfs. Show sysfs attribute files for each device. Read/write some files to demonstrate control of
   the hardware.
   • RGB LED controller
   • ADC controller
   • Custom component 1
   • Custom component 2

__STEPS:__

Open Putty > Login
    
    de10nano login: soc
    password: fpga

Get sudo permissions:

    sudo -i

Load device driver:

    insmod /home/soc/rgb_led.ko 
Or

    insmod /home/soc/denano10_adc.ko


#### 7. Userspace software demonstration
   - RGB LED busy loop
   - fixed-point data type conversions
   - Proposal software 1
   - Proposal software 2

__STEPS:__ 

Load both device drivers:


EXTRA:
For C code permissions run:

    chmod a+r+x /home/soc/./<executable_name>
To cross compile c code 

   `arm-linux-gnueabihf-gcc -o <executable_name> <program_name>.c`

Move it to:
    
    /srv/



