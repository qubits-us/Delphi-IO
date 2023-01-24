/*
  Modbus RTU Slave Mega2560
*/


#include <ModbusRTUSlave.h>

#include <Wire.h>
#include <SSD1306Ascii.h>
#include <SSD1306AsciiWire.h>

// 0X3C+SA0 - 0x3C or 0x3D
#define I2C_ADDRESS 0x3C

// Define proper RST_PIN if required.
#define RST_PIN -1

SSD1306AsciiWire oled;


const byte slave_Id = 1;
const unsigned long baud = 9600;
const unsigned int bufSize = 256;

const unsigned int numRelays = 8; // 8 relays
const unsigned int numInputs = 8; //8 digital inputs
const unsigned int numRegs = 8;// 2 registers, values get shifted out..

//bottom of 2560
const byte inputPins[numInputs] = {30, 31, 32, 33, 34, 35, 36, 37};
//const byte relayPins[numRelays] = {0, 1, 2, 3, 4, 5, 6, 7};// on io expander
const byte relayPins[numRelays] = {22, 23, 24, 25, 26, 27, 28, 29};
//serial1 comm pins
const byte rxPin = 19;
const byte txPin = 18;
//clock and data ports
const byte clockPinA = 10;
const byte clockPinB = 12;
const byte dataPinA = 11;
const byte dataPinB = 13;

uint8_t col0 = 0;

byte buf[bufSize];
//relay coil states
boolean relays[numRelays] = {0, 0, 0, 0, 0, 0, 0, 0};
boolean dinputs[numInputs] = {0, 0, 0, 0, 0, 0, 0, 0};
boolean relaysOnline = true;
//do we need to update display
boolean updateRelay = false;
boolean updateInput = false;
//registers
word regs[numRegs] = {1, 2, 3, 4, 5, 6, 7, 8};
word inputRegs[numInputs] ={8, 7, 6, 5, 4, 3, 2, 1};
//SoftwareSerial modSerial(rxPin, txPin);
ModbusRTUSlave modbus(Serial1, buf, bufSize);
//Adafruit_PCF8574 pcf;

void setup() {

  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);  // turn the LED on 
  



  while (!Serial) { delay(10); }
  Serial.begin(9600);
  Serial.println("Modbus RTU booting..");
  digitalWrite(LED_BUILTIN, LOW);  // turn the LED off

  

  for (int i=0;i<numInputs;i++)
  {
   digitalWrite(inputPins[i],LOW); 
   pinMode(inputPins[i], INPUT);
   //set the relay pins high before switching to output..
   //stops the relays from chattering, they are low triggered..
   digitalWrite(relayPins[i],HIGH);
   pinMode(relayPins[i], OUTPUT);
  }    
    
  pinMode(clockPinA, OUTPUT);
  pinMode(clockPinB, OUTPUT);
  pinMode(dataPinA, OUTPUT);
  pinMode(dataPinB, OUTPUT);  
  digitalWrite(LED_BUILTIN, HIGH);  // turn the LED on 
  
  
  Serial1.begin(baud);
  modbus.begin(slave_Id, baud);
  modbus.configureCoils(numRelays, coilRead, coilWrite);
  modbus.configureDiscreteInputs(numInputs, inputRead);
  modbus.configureInputRegisters(numInputs, inputRegRead);
  modbus.configureHoldingRegisters(numRegs, regRead, regWrite);
  digitalWrite(LED_BUILTIN, LOW);  // turn the LED off
  Serial.println("Modbus RTU Ready");

  //init i2c screen
 Wire.begin();
 Wire.setClock(400000L);

  oled.begin(&Adafruit128x64, I2C_ADDRESS);
  oled.setFont(font5x7);
  oled.clear();
  oled.set2X(); 
  oled.println("Modbus RTU");
  oled.set1X();
  oled.println();
//save the col quicker updates later..
  col0 = oled.strWidth("Inputs: ");  
  oled.println("        12345678");
  oled.println("Inputs: 00000000");
  oled.println("Relays: 00000000");
  oled.println();
  oled.println();  
  oled.println("    QUBITS.US");  
}

void loop() {
  //just polling modbus
  modbus.poll();

if (updateRelay) {displayRelays();}
if (updateInput) {displayInputs();}
}


void displayRelays(){
  String relayStr ="";
for (int i=0;i<8;i++)
{
  if (relays[i]) {relayStr=relayStr+"0";} 
          else {relayStr=relayStr+"X";} 
}
  
  oled.setCursor(col0, 5);
  oled.print(relayStr);  
  updateRelay = false;   
}

void displayInputs(){
  String inputStr ="";
for (int i=0;i<8;i++)
{
  if (dinputs[i]) {inputStr=inputStr+"X";} 
          else {inputStr=inputStr+"0";} 
}

  oled.setCursor(col0, 4);
  oled.print(inputStr);
  updateInput = false;       
}



char coilRead(unsigned int address) {  
/*
Serial.print("Entering Coil Read Address:");
Serial.println(address,DEC);
*/

if (relaysOnline){  
return !digitalRead(relayPins[address]);
} else return 0;
}

boolean coilWrite(unsigned int address, boolean value) {
/*
Serial.print("Entering Coil Write Address:");
Serial.print(address,DEC);
Serial.print(" Value:");
Serial.println(value,DEC);
*/
if (relaysOnline){
  digitalWrite(relayPins[address],!value);
  relays[address] = !value;
  updateRelay = true;
 /* 
  Serial.print("relays:");
  Serial.println(relays[address],DEC);
 */
  }  
  return true;
}

char inputRead(unsigned int address) {
//see if we need to update screen
if (digitalRead(inputPins[address]) != dinputs[address]){
  dinputs[address]=digitalRead(inputPins[address]);
  updateInput = true;    
}
  
  return digitalRead(inputPins[address]);//notted for the pull up..
}


long inputRegRead(unsigned int address) {
  return inputRegs[address];
}



long regRead(unsigned int address) {
  return regs[address];
}

boolean regWrite(word address, word value) {
  regs[address]= value;
/*  
  if (address == 0)
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

