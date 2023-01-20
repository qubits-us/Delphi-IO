unit uModBus;



interface
uses
  SysUtils;



type
  TWords = array of word;




const
  MB_BCAST_ID = 0;
  CRC_KEY = $A001;
  COIL_OFF = $FF00;
  COIL_ON = $0000;

// ModBus functions
const
  READ_COILS = $01;
  READ_INPUTS = $02;
  READ_HOLDREGS = $03;
  READ_INPUTREGS = $04;
  WRITE_COIL = $05;
  WRITE_REG = $06;
  WRITE_MCOILS = $0F;
  WRITE_MREGS = $10;


// ModBus exceptions
const
  MBE_Error = $80;
  MBE_Ok = $00;
  MBE_IllegalFunction = $01;
  MBE_IllegalAddress = $02;
  MBE_IllegalDataValue = $03;
  MBE_SlaveDeviceFailure = $04;
  MBE_Acknowledge = $05;
  MBE_SlaveDeviceBusy = $06;
  MBE_NegativeAcknowledge = $07;
  MBE_MemoryParityError = $08;

  const
  MB_ErrorStr: array[0..8] of string =('Ok','Illegal Function','Illegal Address','Illegal Data Value','Slave Device Failure',
                                        'Acknowledge','Slave Device Busy','Negative Acknowledge','Memory Parity Error');

const
  MaxBlockLength = 125;
  MaxRtuFrameLength = 256; //rtu
  MaxAsciiFrameLength = 513; //ascii
  MaxCoils = 2000;





function buff2hex(const buff:array of byte;delimiter:string):string;
function RTU_Buff(SlaveId,FuncCode:byte;AddrStart,NumPoints:word;Data:TBytes):tBytes;
function BufferToHex(const Buffer: array of Byte): String;
function CalculateCRC(const Buffer: array of Byte): Word;
function CalculateLRC(const Buffer: array of Byte): Byte;

function Swap16(const DataToSwap: Word): Word;



implementation



// Table of CRC values for high–order byte ref PI_MBUS_300.pdf
Const
CRC_hi: array[0..255] of byte = (
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81,
$40, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0,
$80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01,
$C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41,
$00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81,
$40, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0,
$80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41, $01,
$C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40,
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81,
$40, $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0,
$80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01,
$C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0, $80, $41,
$00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41, $00, $C1, $81,
$40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40, $01, $C0,
$80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41, $01,
$C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
$00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81,
$40
);


// Table of CRC values for low–order byte ref PI_MBUS_300.pdf
Const
CRC_lo:array[0..255] of byte= (
$00, $C0, $C1, $01, $C3, $03, $02, $C2, $C6, $06, $07, $C7, $05, $C5, $C4,
$04, $CC, $0C, $0D, $CD, $0F, $CF, $CE, $0E, $0A, $CA, $CB, $0B, $C9, $09,
$08, $C8, $D8, $18, $19, $D9, $1B, $DB, $DA, $1A, $1E, $DE, $DF, $1F, $DD,
$1D, $1C, $DC, $14, $D4, $D5, $15, $D7, $17, $16, $D6, $D2, $12, $13, $D3,
$11, $D1, $D0, $10, $F0, $30, $31, $F1, $33, $F3, $F2, $32, $36, $F6, $F7,
$37, $F5, $35, $34, $F4, $3C, $FC, $FD, $3D, $FF, $3F, $3E, $FE, $FA, $3A,
$3B, $FB, $39, $F9, $F8, $38, $28, $E8, $E9, $29, $EB, $2B, $2A, $EA, $EE,
$2E, $2F, $EF, $2D, $ED, $EC, $2C, $E4, $24, $25, $E5, $27, $E7, $E6, $26,
$22, $E2, $E3, $23, $E1, $21, $20, $E0, $A0, $60, $61, $A1, $63, $A3, $A2,
$62, $66, $A6, $A7, $67, $A5, $65, $64, $A4, $6C, $AC, $AD, $6D, $AF, $6F,
$6E, $AE, $AA, $6A, $6B, $AB, $69, $A9, $A8, $68, $78, $B8, $B9, $79, $BB,
$7B, $7A, $BA, $BE, $7E, $7F, $BF, $7D, $BD, $BC, $7C, $B4, $74, $75, $B5,
$77, $B7, $B6, $76, $72, $B2, $B3, $73, $B1, $71, $70, $B0, $50, $90, $91,
$51, $93, $53, $52, $92, $96, $56, $57, $97, $55, $95, $94, $54, $9C, $5C,
$5D, $9D, $5F, $9F, $9E, $5E, $5A, $9A, $9B, $5B, $99, $59, $58, $98, $88,
$48, $49, $89, $4B, $8B, $8A, $4A, $4E, $8E, $8F, $4F, $8D, $4D, $4C, $8C,
$44, $84, $85, $45, $87, $47, $46, $86, $82, $42, $43, $83, $41, $81, $80,
$40
);





function BufferToHex(const Buffer: array of Byte): String;
var
  i: Integer;
begin
  Result := '';
  for i := Low(Buffer) to High(Buffer) do
    Result := Result + IntToHex(Buffer[i], 2);
end;

 //calcualtes CRC for RTU -translated from c inside PI_MBUS_300.pdf
function CalculateCRC(const Buffer: array of Byte): Word;
var
  i: Integer;
  byteCRCLow,byteCRCHi,uindex:byte;
begin
  Result := 0;
  byteCRCLow:=$FF;
  byteCRCHi:=$FF;
  uindex:=0;
  for i := Low(Buffer) to High(Buffer) do
  begin
  // ^ = XOR
  // | = OR
    uindex := byteCRCHi xor Buffer[i];
    byteCRCHi := byteCRCLow xor CRC_hi[uindex];
    byteCRCLow := CRC_lo[uindex];
  end;

    Result:=(byteCRCHi shl 8 or byteCRCLow);


end;




//for modbus ascii - add all bytes and return two's compliment..
function CalculateLRC(const Buffer: array of Byte): Byte;
var
  i: Integer;
  CheckSum: byte;
begin
  CheckSum := 0;
  for i := Low(Buffer) to High(Buffer) do
    CheckSum := CheckSum + Buffer[i];
  Result := 1+(not CheckSum);
end;


function Swap16(const DataToSwap: Word): Word;
begin
  Result := (DataToSwap div 256) + ((DataToSwap mod 256) * 256);
end;




function RTU_Buff(SlaveId,FuncCode:byte;AddrStart,NumPoints:word;Data:TBytes):tBytes;
var
c:word;
datalen:byte;
i:integer;
begin
      datalen:=0;
         //dec address
        if AddrStart>0 then
                AddrStart:=AddrStart-1;


     if Assigned(Data) then
       datalen:=Length(Data);//get data byte cound

        if datalen>0 then
          begin
            //add our extra data byte
            SetLength(result,7+datalen);
            Result[0]:=SlaveId;
            Result[1]:=FuncCode;
            Result[2]:=hi(AddrStart);
            Result[3]:=lo(AddrStart);
            Result[4]:=hi(NumPoints);
            Result[5]:=lo(NumPoints);
            Result[6]:=datalen;
            //now the extra byte
            for i := Low(Data) to High(Data) do
              Result[7+i]:=Data[i];

          end else
            begin
             //no extra payload
            SetLength(result,6);
            Result[0]:=SlaveId;
            Result[1]:=FuncCode;
            Result[2]:=hi(AddrStart);
            Result[3]:=lo(AddrStart);
            Result[4]:=hi(NumPoints);
            Result[5]:=lo(NumPoints);
            end;

         //calc crc
          c:=CalculateCRC(Result);
          datalen:=Length(Result);
          setLength(Result,dataLen+2);
          Result[dataLen]:=hi(c);
          Result[dataLen+1]:=lo(c);


end;






function buff2hex(const buff:array of byte;delimiter:string):string;
var
  i:integer;
begin
result:='';
 for i := Low(buff) to High(buff) do
   result:=result+'$'+IntToHex(buff[i],2)+delimiter;
end;



end.
