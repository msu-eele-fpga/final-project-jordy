# Final Project Report
To be continued 

RGB LED Common cathode


50 ms period

ADC

150 ohm resistors

RED output GPIO_0 (0)
GREEN output GPIO_0 (2)
BLUE output GPIO_0 (4)

open with
in linux-socfpga/arch/arm/boot/dts/intel/socfpga/
`socfpga_cyclone5_de10nano_final_project.dts`

both spans are 20

### Fixed Point
The period is assigned in ms. W is the size of the signal and F is the number of fractional bits.

W.F
W or N = Width or Weight (number of bits in the entire number), F = Fractional Bits
I = Integer Bits

#### PERIOD
W = 18, I = 6, F = 12

It looks like this : 000000.000000000000

#### DUTY CYCLE
W = 11, I = 1, F = 10

This duty cycle allows for a range from 0 to 1.9990

#### MULTIPLICATION

W_i + W_i+1 = total width

#### DIVISION
W_numerator + F_denominator

Matlab fixed point fi() function