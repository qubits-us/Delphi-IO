/*

*/

#include <SoftwareSerial.h>
#include <ModbusRTUSlave.h>
#include <Adafruit_PCF8574.h>



const byte slave_Id = 1;
const unsigned long baud = 9600;
const unsigned int bufSize = 256;

const unsigned int numRelays = 8; // 8 relays
const unsigned int numInputs = 8; //8 digital inputs
const unsigned int numRegs = 8;// 8 registers, values get shifted out..

//define input and output pins..
const byte inputPins[numInputs] = {0, 1, 2, 3, 4, 5, 6, 7};//inputs on io expander, wrong relays long story..
//const byte relayPins[numRelays] = {0, 1, 2, 3, 4, 5, 6, 7};// on io expander
const byte relayPins[numRelays] = {4, 5, 6, 7, 8, 9, 10, 11};//
//serial comm pins
const byte rxPin = 2;
const byte txPin = 3;

/*
no room on uno for these
//clock and data ports
const byte clockPinA =10;
const byte clockPinB =12;
const byte dataPinA=11;
const byte dataPinB=13;
*/

byte buf[bufSize];
//relay coil states
byte relays[numRelays] = {0, 0, 0, 0, 0, 0, 0, 0};
//registers
word regs[numRegs] = {1, 2, 3, 4, 5, 6, 7, 8};
word inputRegs[numInputs] ={8, 7, 6, 5, 4, 3, 2, 1};

boolean inputsOnline = true;
boolean oneTime = true;

SoftwareSerial modSerial(rxPin, txPin);
ModbusRTUSlave modbus(modSerial, buf, bufSize);
Adafruit_PCF8574 pcf;

void setup() {

  



  while (!Serial) { delay(10); }
  Serial.begin(9600);
  Serial.println("Modbus RTU booting..");


  if (!pcf.begin(0x20, &Wire)) {
    Serial.println("PCF8574 Inputs offline.");
    inputsOnline=false;
  }
  
  if (inputsOnline){
  for (uint8_t p=0; p<8; p++) {
    pcf.pinMode(p, INPUT);
    } 
   Serial.println("Inputs Online..");     
  }
 
/*
our relays are low triggered.
set the pin high before config pin to input.
avoids relays chattering on power up.
*/

  for (int i=0;i<numRelays;i++)
  {
   digitalWrite(relayPins[i],HIGH);
   pinMode(relayPins[i], OUTPUT);
  }    
/*    
  pinMode(clockPinA, OUTPUT);
  pinMode(clockPinB,OUTPUT);
  pinMode(dataPinA,OUTPUT);
  pinMode(dataPinB,OUTPUT);  
 */ 

 /*
  //relay check
for (int i=0;i<numRelays;i++)
{
digitalWrite(relayPins[i],LOW);
Serial.println("Relay On");
delay(1000);
Serial.println("Relay Off");
digitalWrite(relayPins[i],HIGH);
}
*/

  
  modSerial.begin(baud);
  modbus.begin(slave_Id, baud);
  modbus.configureCoils(numRelays, coilRead, coilWrite);
  modbus.configureDiscreteInputs(numInputs, inputRead);
  modbus.configureInputRegisters(numInputs, inputRegRead);
  modbus.configureHoldingRegisters(numRegs, regRead, regWrite);
  Serial.println("Modbus RTU Ready");
  
}

void loop() {
  //just polling modbus
  modbus.poll();
  
}



char coilRead(unsigned int address) {  
return !digitalRead(relayPins[address]);
}

boolean coilWrite(unsigned int address, unsigned int value) {
/*
Serial.print("Entering Coil Write Address:");
Serial.print(address,DEC);
Serial.print(" Value:");
Serial.println(value,DEC);
 */ 
  if (value == 0)
  {
  digitalWrite(relayPins[address],LOW);
  relays[address] = 1;
/*  
Serial.print(address, DEC);  
  Serial.println(" Relay On");
Serial.print(value, DEC);
  Serial.println(" Value");  
  */
  } else
   {
  digitalWrite(relayPins[address],HIGH);
  relays[address] = 0;
 /*
 Serial.print(address, DEC);  
  Serial.println(" Relay Off");
Serial.print(value, DEC);
  Serial.println(" Value");  
  */
   }
  return true;  
}

char inputRead(unsigned int address) {
  return pcf.digitalRead(inputPins[address]);
}

long inputRegRead(unsigned int address) {
  return inputRegs[address];
}


long regRead(unsigned int address) {
  return regs[address];
}

boolean regWrite(word address, word value) {
  regs[address] = value;
/*  
  if (address=0)
{
shiftOut(dataPinA,clockPinA,LSBFIRST,value);//low byte
shiftOut(dataPinA,clockPinA,LSBFIRST,(value>>8));//high byte
}  
else
{
shiftOut(dataPinB,clockPinB,LSBFIRST,value);//low byte
shiftOut(dataPinB,clockPinB,LSBFIRST,(value>>8));//high byte
}  
*/
  return true;
}

