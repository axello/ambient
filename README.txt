About the Ambient folder

OSC contains the OSC.py python module and a test file. The test file sends OSC commands to localhost:5000
osctest contains a small Processing app which sets up an OSC channel on localhost:5000

Protocol:
osc://xbee/x <axis> <value>
	axis={0,1,2,3}, where 0 is used for x and 1 for y
	value can be between 0 and 1023
osc://xbee/reset
	sends a reset to processing, which starts again from the beginning

