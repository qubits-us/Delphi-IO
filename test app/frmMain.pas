unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,System.Contnrs,System.SyncObjs,
   Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OoMisc, AdPort, AdPacket, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids;

type
  TMainFrm = class(TForm)
    ComPort: TApdComPort;
    DataPack: TApdDataPacket;
    edAddr: TEdit;
    edFunc: TEdit;
    edStart: TEdit;
    edQty: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnOpen: TButton;
    edPort: TEdit;
    Label5: TLabel;
    mDisplay: TMemo;
    btnClose: TButton;
    btnSend: TButton;
    btnRelayOn: TButton;
    btnRelayOff: TButton;
    shpInput1: TShape;
    shpInput2: TShape;
    shpInput3: TShape;
    shpInput4: TShape;
    shpInput5: TShape;
    shpInput6: TShape;
    shpInput7: TShape;
    shpInput8: TShape;
    shpOutput2: TShape;
    shpOutput3: TShape;
    shpOutput4: TShape;
    shpOutput5: TShape;
    shpOutput6: TShape;
    shpOutput7: TShape;
    shpOutput8: TShape;
    shpOutput1: TShape;
    Label6: TLabel;
    Label7: TLabel;
    edRelay: TEdit;
    cbPoll: TCheckBox;
    tmrPoll: TTimer;
    sgRegs: TStringGrid;
    Label8: TLabel;
    Label9: TLabel;
    btnReadRegisters: TButton;
    btnReadHolding: TButton;
    cbR1: TCheckBox;
    cbR2: TCheckBox;
    cbR3: TCheckBox;
    cbR4: TCheckBox;
    cbR5: TCheckBox;
    cbR6: TCheckBox;
    cbR7: TCheckBox;
    cbR8: TCheckBox;
    btnSetMultiRelay: TButton;
    btnWriteHolding: TButton;
    tmrWDP: TTimer;
    procedure ComPortPortClose(Sender: TObject);
    procedure ComPortPortOpen(Sender: TObject);
    procedure DataPackPacket(Sender: TObject; Data: Pointer; Size: Integer);
    procedure btnSendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnRelayOnClick(Sender: TObject);
    procedure btnRelayOffClick(Sender: TObject);
    procedure RelayOn(RelayNum: Word);
    procedure RelayOff(RelayNum: Word);
    procedure ReadCoils(CoilStart: Word; NumCoils:Word);
    procedure ReadInputs(InputStart: Word; NumInputs:Word);
    procedure DataPackTimeout(Sender: TObject);
    procedure UpdateDisplay;
    procedure UpdateInputs(InputByte:byte);
    procedure WritePort(const Data: tBytes);
    procedure UpdateCoils(OutputByte:byte);
    procedure tmrPollTimer(Sender: TObject);
    procedure cbPollClick(Sender: TObject);
    procedure UpdateInputReg(Data:word;Reg:Byte);
    procedure UpdateInputRegs(Data:array of word);
    procedure UpdateHoldingReg(Data:word;Reg:Byte);
    procedure UpdateHoldingRegs(Data:array of word);
    procedure CoilResponse(Coil,State:Word);
    procedure sgRegsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnReadHoldingClick(Sender: TObject);
    procedure btnReadRegistersClick(Sender: TObject);
    procedure btnSetMultiRelayClick(Sender: TObject);
    procedure sgRegsGetEditMask(Sender: TObject; ACol, ARow: Integer; var Value: string);
    procedure btnWriteHoldingClick(Sender: TObject);
    procedure tmrWDPTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;
  RecStr:String;
  RecvBytes:tBytes;
  RecvState:integer;
  RecvFunc:byte;
  RecvWordCount:byte;
  RecvDataLen:integer;
  RecvCRC:word;
  RecvRaw:String;
  InputLst:tComponentList;
  OutputLst:tComponentList;
  RelayLst:tComponentList;
  LastInputByte:byte;
  LastCoilByte:byte;
  StartAdd,QtyPoints:Word;
  InputSignals:array[0..7] of byte = (0,0,0,0,0,0,0,0);
  StateCoils:array[0..7] of byte = (0,0,0,0,0,0,0,0);
  InputRegisters:Array[0..7] of word =(0,0,0,0,0,0,0,0);
  HoldingRegisters:Array[0..7] of word=(0,0,0,0,0,0,0,0);
  OutCrit:TCriticalSection;
  Polling:boolean;
  TimedOut:boolean;
  //func 3 addr 211 get adams module name

implementation

{$R *.dfm}

uses uModBus;

procedure TMainFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
if ComPort.Open then
  ComPort.Open:=False;

OutCrit.Free;
InputLst.Free;
OutPutLst.Free;
RelayLst.Free;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
var
i:integer;
begin
//create
  OutCrit:=TCriticalSection.Create;

  RecvState:=0;
  RecvDataLen:=0;
  LastInputByte:=0;
  LastCoilByte:=0;
  StartAdd:=0;
  QtyPoints:=0;
  InputLst:=tComponentList.Create(False);
  OutputLst:=tComponentList.Create(False);
  RelayLst:=tComponentList.Create(False);
  Polling:=False;
  TimedOut:=False;

  //put the screen controls in lists for quicker access
  InputLst.Add(shpInput1);
  InputLst.Add(shpInput2);
  InputLst.Add(shpInput3);
  InputLst.Add(shpInput4);
  InputLst.Add(shpInput5);
  InputLst.Add(shpInput6);
  InputLst.Add(shpInput7);
  InputLst.Add(shpInput8);

  OutputLst.Add(shpOutput1);
  OutputLst.Add(shpOutput2);
  OutputLst.Add(shpOutput3);
  OutputLst.Add(shpOutput4);
  OutputLst.Add(shpOutput5);
  OutputLst.Add(shpOutput6);
  OutputLst.Add(shpOutput7);
  OutputLst.Add(shpOutput8);

  RelayLst.Add(cbR1);
  RelayLst.Add(cbR2);
  RelayLst.Add(cbR3);
  RelayLst.Add(cbR4);
  RelayLst.Add(cbR5);
  RelayLst.Add(cbR6);
  RelayLst.Add(cbR7);
  RelayLst.Add(cbR8);



  for I := 0 to 7 do
      begin
        tShape(InputLst[i]).Brush.Color:=clRed;
        tShape(OutputLst[i]).Brush.Color:=clRed;
        sgRegs.Cells[i,0]:='0x0000';
        sgRegs.Cells[i,1]:='0x0000';
      end;

end;



//always use this procedure to serialize output
procedure TMainFrm.WritePort(const Data: tBytes);
begin
  //
  if Length(Data)=0 then exit;//nothing to send

 OutCrit.Enter;
 try
 ComPort.PutBlock(Data[0],Length(Data));

 finally
 OutCrit.Leave;
 end;



end;


procedure TMainFrm.UpdateInputReg(Data:word;Reg:Byte);
begin
 //
 if Reg<Length(InputRegisters) then
   InputRegisters[Reg]:=Data;
end;

procedure TMainFrm.UpdateHoldingReg(Data:word;Reg:Byte);
begin
 //
 if Reg<Length(HoldingRegisters) then
   HoldingRegisters[Reg]:=Data;
end;

procedure TMainFrm.UpdateInputRegs(Data:array of word);
var
i,j:integer;
begin
 //

 if Length(Data)=0 then exit;

 if Length(Data)=8 then
   begin
     for I := Low(Data) to High(Data) do
      InputRegisters[i]:=Data[i];
    UpdateDisplay;
   end else
     begin
       if (QtyPoints>0) and (QtyPoints<8) then
         begin
           if QtyPoints=1 then
             InputRegisters[StartAdd]:=Data[0] else
           begin
             j:=0;
             for I := StartAdd to (StartAdd+QtyPoints) do
              begin
              InputRegisters[i]:=Data[j];
              Inc(j);
              end;
           end;
          UpdateDisplay;
         end;//invalid num points??!!
     end;
end;


procedure TMainFrm.UpdateHoldingRegs(Data:array of word);
var
i,j:integer;
begin
 //

 if Length(Data)=0 then exit;

 if Length(Data)=8 then
   begin
     for I := Low(Data) to High(Data) do
      HoldingRegisters[i]:=Data[i];
    UpdateDisplay;
   end else
     begin
       if (QtyPoints>0) and (QtyPoints<8) then
         begin
           if QtyPoints=1 then
             HoldingRegisters[StartAdd]:=Data[0] else
           begin
             j:=0;
             for I := StartAdd to (StartAdd+QtyPoints) do
              begin
              HoldingRegisters[i]:=Data[j];
              Inc(j);
              end;
           end;
          UpdateDisplay;
         end;//invalid num points??!!
     end;
end;




procedure TMainFrm.UpdateInputs(InputByte:byte);
var
MaskBit:byte;
i:integer;
begin
 //
 MaskBit:=1;
 if InputByte<>LastInputByte then
    begin
     LastInputByte:=InputByte;
     for I := 0 to 7 do
       begin
        if ((InputByte AND MaskBit)<>0) then
         InputSignals[i]:=1 else InputSignals[i]:=0;
        if i<7 then
        MaskBit:=(MaskBit shl 1);
       end;
     UpdateDisplay;
    end;



end;

procedure TMainFrm.UpdateCoils(OutputByte:byte);
var
MaskBit:byte;
i:integer;
begin
 //
 MaskBit:=1;
 if OutputByte<>LastCoilByte then
    begin
     LastCoilByte:=OutputByte;
     for I := 0 to 7 do
       begin
        if ((OutputByte AND MaskBit)<>0) then
         StateCoils[i]:=1 else StateCoils[i]:=0;
        if i<7 then
        MaskBit:=(MaskBit shl 1);
       end;
     UpdateDisplay;
    end;
end;


procedure TMainFrm.CoilResponse(Coil,State:Word);
begin
 //
 if Coil < Length(StateCoils) then
   begin
     if State=COIL_ON then
       StateCoils[Coil]:=1 else
     if State=COIL_OFF then
       StateCoils[Coil]:=0;
    //something changed
     UpdateDisplay;

   end;
end;



procedure TMainFrm.UpdateDisplay;
var
i:integer;
begin
//update display

for I := 0 to 7 do
     begin
       //check inputs
       if InputSignals[i]=0 then
        begin
         if tShape(InputLst[i]).Tag<>0 then
           begin
            tShape(InputLst[i]).Tag:=0;
            tShape(InputLst[i]).Brush.Color:=clRed;
           end;
        end else
           begin
            if tShape(InputLst[i]).Tag<>1 then
             begin
              tShape(InputLst[i]).Tag:=1;
              tShape(InputLst[i]).Brush.Color:=clLime;
             end;
           end;

       //check relays
       if StateCoils[i]=0 then
        begin
         if tShape(OutputLst[i]).Tag<>0 then
           begin
            tShape(OutputLst[i]).Tag:=0;
            tShape(OutputLst[i]).Brush.Color:=clRed;
           end;
        end else
           begin
            if tShape(OutputLst[i]).Tag<>1 then
             begin
              tShape(OutputLst[i]).Tag:=1;
              tShape(OutputLst[i]).Brush.Color:=clLime;
             end;
           end;

         sgRegs.Cells[i,0]:='0x'+IntToHex(InputRegisters[i],4);
         sgRegs.Cells[i,1]:='0x'+IntToHex(HoldingRegisters[i],4);


     end;






end;

procedure TMainFrm.ReadInputs(InputStart: Word; NumInputs:Word);
var
id:byte;
tmpB:TBytes;
begin
//send a packet

id:=StrToInt(edAddr.Text);


tmpB:=RTU_Buff(id,READ_INPUTS,InputStart,NumInputs,nil);
mDisplay.Lines.Add(buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;
  SetLength(tmpB,0);
end;

procedure TMainFrm.ReadCoils(CoilStart: Word; NumCoils:Word);
var
id:byte;
tmpB:Tbytes;
begin
//send a packet

id:=StrToInt(edAddr.Text);

tmpB:=RTU_Buff(id,READ_COILS,CoilStart,NumCoils,nil);
mDisplay.Lines.Add(buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;
  SetLength(tmpB,0);
end;

procedure TMainFrm.RelayOn(RelayNum: Word);
var
SlaveId:byte;
tmpB:Tbytes;
begin
//turn a relay on

SlaveID:=StrToInt(edAddr.Text);
tmpB:=RTU_Buff(SlaveId,WRITE_COIL,RelayNum,COIL_ON,nil);
mDisplay.Lines.Add(buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;

  SetLength(tmpB,0);


end;

procedure TMainFrm.sgRegsGetEditMask(Sender: TObject; ACol, ARow: Integer; var Value: string);
begin
Value:='########';
end;

procedure TMainFrm.sgRegsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
if aRow=1 then
CanSelect:=True else CanSelect:=False;
end;

procedure TMainFrm.tmrPollTimer(Sender: TObject);
var
tmpCRC:Word;
tmpB:Tbytes;
Addhi,Addlo:word;
begin

  tmrPoll.Enabled:=false;

  AddLo:=0;
  AddHi:=8;


tmpB:=RTU_Buff(1,READ_INPUTS,AddLo,AddHi,nil);



if ComPort.Open then
  begin
    WritePort(tmpB);
  end;
  SetLength(tmpB,0);




end;




procedure TMainFrm.tmrWDPTimer(Sender: TObject);
begin
//packet has timed out!!??

   tmrWDP.Enabled:=False;
   mDisplay.Lines.Add('>> Packet Timed Out');




          //reset for next packet
          RecvState:=0;
          RecvDataLen:=0;
          recStr:='';
          RecvState:=0;
          RecvDataLen:=0;
          SetLength(RecvBytes,0);
          RecvCRC:=0;
          RecvRaw:='';
          RecvWordCount:=0;



end;

//Watch dog for the packet
procedure TMainFrm.RelayOff(RelayNum: Word);
var
SlaveId:byte;
tmpB:Tbytes;
begin
//

SlaveId:=StrToInt(edAddr.Text);
tmpB:=RTU_Buff(SlaveId,WRITE_COIL,RelayNUm,COIL_OFF,nil);
mDisplay.Lines.Add('>>'+buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;
SetLength(tmpB,0);
end;

procedure TMainFrm.btnCloseClick(Sender: TObject);
begin
if Comport.Open then ComPort.Open:=False;
mDisplay.Lines.Add('Port Closed');

end;

procedure TMainFrm.btnOpenClick(Sender: TObject);
begin
if not Comport.Open then
  begin
  ComPort.ComNumber:=StrToInt(edPort.Text);
  ComPort.Open:=true;
  DataPack.Enabled:=true;
  mDisplay.Lines.Add('Port Open');
  end;

end;

procedure TMainFrm.btnReadHoldingClick(Sender: TObject);
var
tmpB:tBytes;
begin
//read the holding regs..


tmpB:=RTU_Buff(StrToInt(edAddr.Text),READ_HOLDREGS,0,8,nil);


mDisplay.Lines.Add('>>'+buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;


  SetLength(tmpB,0);



end;

procedure TMainFrm.btnReadRegistersClick(Sender: TObject);
var
tmpB:tBytes;
begin
//read the input regs..


tmpB:=RTU_Buff(StrToInt(edAddr.Text),READ_INPUTREGS,0,8,nil);


mDisplay.Lines.Add('>>'+buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;


  SetLength(tmpB,0);

end;

procedure TMainFrm.btnSendClick(Sender: TObject);
var
id,func:byte;
startAddr,endAddr:word;
tmpB:Tbytes;
begin
//send a packet

id:=StrToInt(edAddr.Text);
func:=StrToInt(edFunc.Text);
startAddr:=StrToInt(edStart.Text);
endAddr:=StrToInt(edQty.Text);


 tmpB:=RTU_Buff(id,func,startAddr,endAddr,nil);
mDisplay.Lines.Add('>>'+buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;


  SetLength(tmpB,0);


end;

procedure TMainFrm.btnSetMultiRelayClick(Sender: TObject);
//set multiple coils at once..
var
id,MaskBit,relayByte:byte;
i:integer;
tmpB,rBytes:tBytes;
begin
 //
 id:=StrToInt(edAddr.Text);
 relayByte:=0;//all off
 MaskBit:=1;

     for I := 0 to 7 do
       begin
       if tCheckBox(RelayLst[i]).Checked then
        relayByte:=relayByte or MaskBit;
        if i<7 then  //only need 7 moves
        MaskBit:=(MaskBit shl 1);
       end;

     SetLength(rBytes,1);
     rBytes[0]:=relayByte;


tmpB:=RTU_Buff(id,WRITE_MCOILS,1,8,rBytes);
SetLength(rBytes,0);

mDisplay.Lines.Add('>>'+buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;
SetLength(tmpB,0);




end;

procedure TMainFrm.btnWriteHoldingClick(Sender: TObject);
var
id,i,j:integer;
tmpStr:String;
tmpWord:Word;
Good:boolean;
hBytes,tmpB:TBytes;
begin
// write multiple holding registers..

Good:=True;
id:=StrToInt(edAddr.Text);
//check all values
   for I := 0 to 7 do
     begin
       tmpStr:=sgRegs.Cells[i,1];
       try
         tmpWord:=StrToInt(tmpStr);
       except on e:Exception do
         begin
           ShowMessage('Can not convert holding register '+intToStr(i+1)+' to a number');
           Good:=False;
           break;
         end;

       end;
     end;

   if not good then exit;

   //now split the words into bytes..
   SetLength(hBytes,16);
    j:=0;
   for I := 0 to 7 do
     begin
       tmpStr:=sgRegs.Cells[i,1];
         tmpWord:=StrToInt(tmpStr);
       hBytes[j]:=hi(tmpWord);//hi byte 1st
       inc(j);
       hBytes[j]:=lo(tmpWord);// then lo byte
       inc(j);
     end;


tmpB:=RTU_Buff(id,WRITE_MREGS,1,8,hBytes);
SetLength(hBytes,0);

mDisplay.Lines.Add('>>'+buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;
SetLength(tmpB,0);




end;

procedure TMainFrm.btnRelayOnClick(Sender: TObject);
//relay on
var
id,func:byte;
startAddr,endAddr:word;
tmpB:tBytes;
begin
//send a packet

id:=StrToInt(edAddr.Text);
func:=StrToInt(edFunc.Text);
startAddr:=StrToInt(edRelay.Text);
endAddr:=StrToInt(edQty.Text);


tmpB:=RTU_Buff(id,WRITE_COIL,startAddr,COIL_ON,nil);


mDisplay.Lines.Add('>>'+buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;
SetLength(tmpB,0);

end;

procedure TMainFrm.btnRelayOffClick(Sender: TObject);
//relay off
var
id,func:byte;
startAddr,endAddr:word;
tmpB:TBytes;
begin
//send a packet

id:=StrToInt(edAddr.Text);
func:=StrToInt(edFunc.Text);
startAddr:=StrToInt(edRelay.Text);
endAddr:=StrToInt(edQty.Text);


tmpB:=RTU_Buff(id,WRITE_COIL,startAddr,COIL_OFF,nil);
mDisplay.Lines.Add('>>'+buff2Hex(tmpB,':'));
if ComPort.Open then
  begin
    WritePort(tmpB);
  end;
  SetLength(tmpB,0);

end;

procedure TMainFrm.cbPollClick(Sender: TObject);
begin
if cbPoll.Checked then
  begin
    tmrPoll.Enabled:=true;
    Polling:=True;
  end else
     begin
     tmrPoll.Enabled:=False;
     Polling:=False;

     end;
end;

procedure TMainFrm.ComPortPortClose(Sender: TObject);
begin
//port closed

end;

procedure TMainFrm.ComPortPortOpen(Sender: TObject);
begin
//port opened

end;

procedure TMainFrm.DataPackPacket(Sender: TObject; Data: Pointer; Size: Integer);
var
recvStr:String;
i,j,k,tmp_state:integer;
pB:PByte;
tmpWordArray:array of word;
begin
//rec some data
 pB:=Data;

if Size>0 then
  begin
    //got something
      tmp_state:=RecvState;

      case tmp_state of
       0:begin //first byte is address
          RecvBytes:=RecvBytes+[pB^];
          RecvRaw:=RecvRaw+Chr(pB^);
          recStr:='Address:'+IntToHex(pB^);
         Inc(RecvState);
         tmrWDP.Enabled:=True;//enable watch dog timer..
         end;
       1:begin //function or error
          if pB^<MBE_ERROR then
          begin
          RecvBytes:=RecvBytes+[pB^];
          RecvRaw:=RecvRaw+Chr(pB^);
          RecvFunc:=pB^;
          recStr:=recStr+' Func Code:'+IntToHex(pB^);
          if (RecvFunc=5) or (RecvFunc=15) or (RecvFunc=16) then
            Inc(RecvState) else
            RecvState:=3;
          end else
            begin
            recStr:=recStr+' Error:'+IntToHex(pB^)+' Code:';
            RecvBytes:=RecvBytes+[pB^];
            RecvRaw:=RecvRaw+Chr(pB^);
            RecvFunc:=pB^;
            RecvState:=4;
            RecvDataLen:=1;
            end;

         end;
       2:begin  //receiving 2 words 4 bytes..

            RecvBytes:=RecvBytes+[pB^];
            RecvRaw:=RecvRaw+Chr(pB^);
            Inc(RecvWordCount);
            if RecvWordCount<3 then
              begin
                if RecvWordCount=1 then
                recStr:=recStr+' Addr:'+IntToHex(pB^)+';' else
                recStr:=recStr+IntToHex(pB^)+' Data:';
              end else
                begin
                recStr:=recStr+IntToHex(pB^);
                if RecvWordCount=4 then
                 RecvState:=4;//crc next
                end;
         end;
       3:begin //recv data len byte
            RecvDataLen:=pB^;
            RecvBytes:=RecvBytes+[pB^];
            RecvRaw:=RecvRaw+Chr(pB^);
            recStr:=recStr+' Data Len:'+IntToHex(pB^)+' Data:';
            Inc(RecvState);
         end;
       4:begin  //rec the datalen
          if RecvDataLen>0 then
            begin
             RecvBytes:=RecvBytes+[pB^];
             RecvRaw:=RecvRaw+Chr(pB^);
             recStr:=RecStr+IntToHex(pB^);
             Dec(RecvDataLen);

            end else
              begin
              //have all data calc crc
              RecvCRC:=calculateCRC(RecvBytes);
              //recv crc lo
              RecvBytes:=RecvBytes+[pB^];
              RecvRaw:=RecvRaw+Chr(pB^);
              recStr:=recStr+' CRC LO:'+IntToHex(pB^);
              Inc(RecvState);
              end;
         end;
       5:begin  //last byte crc hi, completes the packet
          recStr:=recStr+' CRC HI:'+IntToHex(pB^);
          RecvBytes:=RecvBytes+[pB^];
          RecvRaw:=RecvRaw+Chr(pB^);
          tmrWDP.Enabled:=false;//disbale watchdog, got our packet..
          if not ((RecvFunc=READ_INPUTS)and(Polling)) then
           begin
           mDisplay.Lines.Add(recStr);
           mDisplay.Lines.Add('<<'+buff2Hex(RecvBytes,':'));
           end;
          //check CRC
          if (RecvBytes[Length(RecvBytes)-2]=hi(RecvCRC)) and
             (RecvBytes[Length(RecvBytes)-1]=lo(RecvCRC)) then
           begin
             case RecvFunc of
               READ_COILS:begin
                           //coils 3
                           UpdateCoils(RecvBytes[3]);
                          end;
               READ_INPUTS:begin
                           //inputs 3
                           UpdateInputs(RecvBytes[3]);
                          end;
               READ_HOLDREGS:begin
                            //holding registers start at byte 3 to num of bytes.. should always be even
                            if not Odd(RecvBytes[2]) then
                              begin
                                SetLength(tmpWordArray,(RecvBytes[2] div 2));
                                 j:=3;
                                   for I := Low(tmpWordArray) to High(tmpWordArray) do
                                     begin
                                       tmpWordArray[i]:=(RecvBytes[j] shl 8 or RecvBytes[j+1]);
                                       j:=j+2;
                                     end;

                               UpdateHoldingRegs(tmpWordArray);
                               SetLength(tmpWordArray,0);
                              end;
                            end;
               READ_INPUTREGS:begin
                            //same as holding registers
                             if not Odd(RecvBytes[2]) then
                              begin
                                SetLength(tmpWordArray,(RecvBytes[2] div 2));
                                 j:=3;
                                   for I := Low(tmpWordArray) to High(tmpWordArray) do
                                     begin
                                       tmpWordArray[i]:=(RecvBytes[j] shl 8 or RecvBytes[j+1]);
                                       j:=j+2;
                                     end;

                               UpdateInputRegs(tmpWordArray);
                               SetLength(tmpWordArray,0);
                              end;
                             end;
               WRITE_COIL:begin
                          //response from write coil
                          CoilResponse((RecvBytes[2] shl 8 or RecvBytes[3]),(RecvBytes[4] shl 8 or RecvBytes[5]));
                          end;
             end;//case return func process

             if Polling then tmrPoll.Enabled:=true;


           end else
              begin
              mDisplay.Lines.Add('<< Computed CRC Failed- LO:'+IntToHex(lo(RecvCRC),2)+' HI:'+IntToHex(hi(RecvCRC),2));

              end;


          //reset for next packet
          RecvState:=0;
          RecvDataLen:=0;
          recStr:='';
          RecvState:=0;
          RecvDataLen:=0;
          SetLength(RecvBytes,0);
          RecvCRC:=0;
          RecvRaw:='';
          RecvWordCount:=0;

         end;//state 5

      end;//end state case


  end;






end;

procedure TMainFrm.DataPackTimeout(Sender: TObject);
begin
mDisplay.Lines.Add('DataPack Timed Out, you must be sleeping..');
end;


end.
