# rot_enc_fpga

This project is the beginnings of a lathe electronics leadscrew. Tested with Quartus 21.1 and a Terasic DE0-Nano.

Goal 1: Receive and display the position reported by a rotary encoder.
Goal 2: Closed loop motor control following primary encoder position (simple motion control algorithm)
Goal 2b: ibid. (traditional motion control algorithm)
Goal 3: Useful UI for selecting modes, commands, and display options


Methods: An incremental encoder is used to sense rotary position. An absolute encoder would be more tolerant of noise, but was 3x the price of the incremental encoder. A differential line receiver is used to join the differential lines and generate digital (3.3v, 3v?) signal lines. An FPGA receives the digital signals and decodes them into a position based on resolution of the encoder and number of pulses following detection of the home position. The FPGA also implements an i2c transmitter that sends the position information to an LCD equipped with an i2c receiver. The LCD has a built-in character set, allowing only the characters that need to be drawn to be sent, and removing the need to maintain a frame buffer in the FPGA. There is a good chance the work being done by the FPGA could more easily be done by a small microcontroller, but this project is also to reinforce FPGA skills.

Block diagram: Rotary encoder -> differential receiver -> FPGA -> i2c back -> LCD

Hardware:
Rotary encoder: TRDA-2E2500VD
	ENCODER 2500 PPR 0.25in SOLID LINE- DRIVER 5VDC 2m (6.5ft) CBL LT DUTY
	Automation Direct, $89.00

Differential receiver:
	LV32E, SOIC-16 package
	Mouser

SOIC-16 breakout board
	Adafruit, 3 for $3

SOIC-16 test socket
	Adafruit, $30

FPGA: Terasic DE0-Nano
	Digikey, $86.25

i2c backpack: i2c / SPI character LCD backpack[ID:292]
	Adafruit, $10.00

LCD: Standard LCD 20x4 + extras (white on blue) [ID:198]
	Adafruit, $17.95

Line level converter:
	xxx, SOIC-24 package
	Mouser

SOIC-24 breakout board
	Adafruit, 

SOIC-28 test socket
	Adafruit, 

5-way navigation switch
	Adafruit, $2.95
	http://www.adafruit.com/products/504

Total cost: $2xx

Tasks:
1) Verify that the output of the rotary encoder is compatible with RS-422 signaling, and select an appropriate differential receiver, and prototyping breakout board. (Prior to 2014-5-16, AM26LV32E, SOIC-16 package, not sure about the RS-422 compatibility, appears to allow voltage domain conversions e.g., the encoder in 5V domain and the logic out in 3.3V, socket and breakout boards
from AdaFruit)
2) Interface the rotary encoder with the differential receiver and verify operation. (2014-5-16)
3) Develop the FPGA based quadrilateral decoder. (2014-5-19)
4) Develop the FPGA based LCD display. (2014-5-26)
5) Develop the FPGA based i2c transmitter. (may be a distraction from what's important and adds expense but creates a building block for other projects)
6) Integration (to what? single board? better goal may be a closed loop stepper controller and synchronization with the rotary encoder, as a mock up of a threading machine)
7) Interface with a stepper motor so a rotation of the encoder moves the stepper motor (done)
8) Create a closed loop feedback control of the stepper motor (done)
9) Add a stick to control jogging of motor (done)
10) Implement a traditional motion control algorithm such as PI, PD, or PID
11) Improve the display controller to allow motor modes (position seeking (shortest route, route of last encoder motion, forward only, or reverse only), 
    jog mode, closed loop mode (on or off)), commands (go to home), and display mode (incremental, absolute, degrees or pulse count) b) Tach mode (2014-6-7)


Filenames of useful references:
* AV02-0096EN - quadrature decoder counter interface.pdf
* HD44780 - LCD controller and driver.pdf
* LS7183N_LS7184N - quadrature clock convertor.pdf
* LS7183_LS7184 - quadrature clock converter.pdf
* LiquidCrystal.cpp
* LiquidCrystal.h
* PR LS708xN - new quad clock convertors.pdf
* TB-109 - rotary encoder output types.pdf
* TC2004A-01 - LCD module.pdf
* TRDA-2E2500VD rotary encoder.SLDDRW
* TRDA-2E2500VD rotary encoder.SLDPRT
* WP-2005 - noise suppression of diff signals.pdf
* am26lv32e - quad differential line receiver.pdf
* an1325 - choosing and using bypass capacitors.pdf
* encoderld - Light-duty Incremental Encoders.pdf
* encodermd - Medium-duty Incremental Encoders.pdf
* slls103n (am26c31) - quad differential line driver.pdf
* sn74lvc4245a - level shifter.pdf
* spru790d - enhanced quadrature encoder pulse (eQEP) module.pdf
