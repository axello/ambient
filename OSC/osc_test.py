#!/usr/bin/env python
##
# Tiny test of Processing and osc from python, on ConnectPort gateway
#
# (c)2011 Axel Roest
#
# This software is licensed under GPLv2
#

import sys, os, time, random
import OSCClient

# OSCIP='127.0.0.1'
OSCIP='192.168.8.105'
OSCPort=5000

def testSet():
	# client = OSC.OSCClient( (OSCIP, OSCPort) )
	client = OSCClient.OSCClient()
	myMessage = OSCClient.OSCMessage()
	myMessage.setAddress("/xbee/x")
	myMessage.append(0)
	myMessage.append(100)
	# print myMessage
	# hexDump(myMessage.getBinary())
	client.sendto(myMessage, (OSCIP, OSCPort) )
	client.close()
	time.sleep(0.1)

def sendReset():
	myMessage = OSCClient.OSCMessage()
	myMessage.setAddress("/xbee/reset")
	client.send(myMessage) # reset processing core

def sendCoordinate(axis,value):
	myMessage = OSCClient.OSCMessage()
	myMessage.setAddress("/xbee/x")
	myMessage.append(axis)
	myMessage.append(value)
	client.send(myMessage) # update coordinates

# move with brownian motion (sort of)
def brownian():
	global xOSC
	global yOSC
	global xDir
	global yDir
	xDir += random.randint(-2,2)
	yDir += random.randint(-2,2)
	xOSC += xDir
	yOSC += yDir
	if xOSC < 0 or xOSC > 1023 or yOSC < 0 or yOSC > 1023:
		xOSC=512
		yOSC=512
		xDir = 0
		yDir = 0
		sendReset()
	sendCoordinate(0,xOSC)
	sendCoordinate(1,yOSC)

def leftRight():
	for i in range(100,1000,20):
		myMessage = OSCClient.OSCMessage()
		myMessage.setAddress("/xbee/x")
		myMessage.append(0)
		myMessage.append(i)
		client.send(myMessage) # now we dont need to tell the client the address anymore
		time.sleep(0.02)

# setup random variables for brownian
random.seed()
xOSC = 512
yOSC = 512
xDir = 0
yDir = 0

# setup
client = OSCClient.OSCClient()
client.connect((OSCIP, OSCPort))
sendReset();
# leftRight()
#
#
while True:
	brownian();
	time.sleep(0.08)
