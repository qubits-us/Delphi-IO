object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'Modbus Test'
  ClientHeight = 412
  ClientWidth = 613
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 12
    Top = 147
    Width = 40
    Height = 15
    Caption = 'Slave Id'
  end
  object Label2: TLabel
    Left = 7
    Top = 180
    Width = 47
    Height = 15
    Caption = 'Function'
  end
  object Label3: TLabel
    Left = 30
    Top = 214
    Width = 24
    Height = 15
    Caption = 'Start'
  end
  object Label4: TLabel
    Left = 37
    Top = 243
    Width = 19
    Height = 15
    Caption = 'Qty'
  end
  object Label5: TLabel
    Left = 33
    Top = 341
    Width = 22
    Height = 15
    Caption = 'Port'
  end
  object shpInput1: TShape
    Left = 200
    Top = 8
    Width = 15
    Height = 15
    Brush.Color = clRed
    Shape = stCircle
  end
  object shpInput2: TShape
    Left = 221
    Top = 8
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpInput3: TShape
    Left = 242
    Top = 8
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpInput4: TShape
    Left = 263
    Top = 8
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpInput5: TShape
    Left = 284
    Top = 8
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpInput6: TShape
    Left = 305
    Top = 8
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpInput7: TShape
    Left = 326
    Top = 8
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpInput8: TShape
    Left = 347
    Top = 8
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpOutput2: TShape
    Left = 221
    Top = 27
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpOutput3: TShape
    Left = 242
    Top = 27
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpOutput4: TShape
    Left = 263
    Top = 27
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpOutput5: TShape
    Left = 284
    Top = 27
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpOutput6: TShape
    Left = 305
    Top = 27
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpOutput7: TShape
    Left = 326
    Top = 27
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpOutput8: TShape
    Left = 347
    Top = 27
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object shpOutput1: TShape
    Left = 200
    Top = 27
    Width = 15
    Height = 15
    Shape = stCircle
  end
  object Label6: TLabel
    Left = 144
    Top = 8
    Width = 33
    Height = 15
    Caption = 'Inputs'
  end
  object Label7: TLabel
    Left = 145
    Top = 29
    Width = 33
    Height = 15
    Caption = 'Relays'
  end
  object Label8: TLabel
    Left = 103
    Top = 96
    Width = 78
    Height = 15
    Caption = 'Input Registers'
  end
  object Label9: TLabel
    Left = 91
    Top = 117
    Width = 93
    Height = 15
    Caption = 'Holding Registers'
  end
  object edAddr: TEdit
    Left = 60
    Top = 144
    Width = 121
    Height = 23
    TabOrder = 0
    Text = '1'
  end
  object edFunc: TEdit
    Left = 60
    Top = 176
    Width = 121
    Height = 23
    TabOrder = 1
    Text = '1'
  end
  object edStart: TEdit
    Left = 60
    Top = 208
    Width = 121
    Height = 23
    TabOrder = 2
    Text = '1'
  end
  object edQty: TEdit
    Left = 60
    Top = 240
    Width = 121
    Height = 23
    TabOrder = 3
    Text = '8'
  end
  object btnOpen: TButton
    Left = 25
    Top = 367
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 4
    OnClick = btnOpenClick
  end
  object edPort: TEdit
    Left = 61
    Top = 338
    Width = 120
    Height = 23
    TabOrder = 5
    Text = '10'
  end
  object mDisplay: TMemo
    Left = 187
    Top = 144
    Width = 409
    Height = 250
    TabOrder = 6
  end
  object btnClose: TButton
    Left = 106
    Top = 367
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 7
    OnClick = btnCloseClick
  end
  object btnSend: TButton
    Left = 60
    Top = 269
    Width = 75
    Height = 25
    Caption = 'Send'
    TabOrder = 8
    OnClick = btnSendClick
  end
  object btnRelayOn: TButton
    Left = 440
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Relay On'
    TabOrder = 9
    OnClick = btnRelayOnClick
  end
  object btnRelayOff: TButton
    Left = 521
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Relay Off'
    TabOrder = 10
    OnClick = btnRelayOffClick
  end
  object edRelay: TEdit
    Left = 376
    Top = 8
    Width = 58
    Height = 23
    TabOrder = 11
    Text = '1'
  end
  object cbPoll: TCheckBox
    Left = 92
    Top = 8
    Width = 47
    Height = 17
    Caption = 'Poll'
    TabOrder = 12
    OnClick = cbPollClick
  end
  object sgRegs: TStringGrid
    Left = 187
    Top = 88
    Width = 409
    Height = 50
    ColCount = 8
    DefaultColWidth = 48
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 2
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing, goFixedRowDefAlign]
    ParentFont = False
    TabOrder = 13
    OnGetEditMask = sgRegsGetEditMask
    OnSelectCell = sgRegsSelectCell
  end
  object btnReadRegisters: TButton
    Left = 40
    Top = 92
    Width = 50
    Height = 20
    Caption = 'Read'
    TabOrder = 14
    OnClick = btnReadRegistersClick
  end
  object btnReadHolding: TButton
    Left = 40
    Top = 112
    Width = 50
    Height = 20
    Caption = 'Read'
    TabOrder = 15
    OnClick = btnReadHoldingClick
  end
  object cbR1: TCheckBox
    Left = 200
    Top = 50
    Width = 15
    Height = 17
    TabOrder = 16
  end
  object cbR2: TCheckBox
    Left = 222
    Top = 50
    Width = 20
    Height = 17
    TabOrder = 17
  end
  object cbR3: TCheckBox
    Left = 245
    Top = 50
    Width = 20
    Height = 17
    TabOrder = 18
  end
  object cbR4: TCheckBox
    Left = 265
    Top = 50
    Width = 20
    Height = 17
    TabOrder = 19
  end
  object cbR5: TCheckBox
    Left = 285
    Top = 50
    Width = 20
    Height = 17
    TabOrder = 20
  end
  object cbR6: TCheckBox
    Left = 305
    Top = 50
    Width = 20
    Height = 17
    TabOrder = 21
  end
  object cbR7: TCheckBox
    Left = 325
    Top = 50
    Width = 20
    Height = 17
    TabOrder = 22
  end
  object cbR8: TCheckBox
    Left = 345
    Top = 50
    Width = 20
    Height = 17
    TabOrder = 23
  end
  object btnSetMultiRelay: TButton
    Left = 376
    Top = 48
    Width = 50
    Height = 20
    Caption = 'Write'
    TabOrder = 24
    OnClick = btnSetMultiRelayClick
  end
  object btnWriteHolding: TButton
    Left = 1
    Top = 112
    Width = 40
    Height = 20
    Caption = 'Write'
    TabOrder = 25
    OnClick = btnWriteHoldingClick
  end
  object ComPort: TApdComPort
    ComNumber = 10
    Baud = 9600
    PromptForPort = False
    DTR = False
    RTS = False
    Tracing = tlOn
    TraceName = 'APRO.TRC'
    TraceAllHex = True
    Logging = tlOn
    LogName = 'APRO.LOG'
    OnPortClose = ComPortPortClose
    OnPortOpen = ComPortPortOpen
    Left = 576
    Top = 264
  end
  object DataPack: TApdDataPacket
    Enabled = True
    StartCond = scAnyData
    EndCond = [ecPacketSize]
    IgnoreCase = False
    ComPort = ComPort
    PacketSize = 1
    OnPacket = DataPackPacket
    OnTimeout = DataPackTimeout
    Left = 576
    Top = 208
  end
  object tmrPoll: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmrPollTimer
    Left = 8
  end
end
