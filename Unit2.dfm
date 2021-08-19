object Form2: TForm2
  Left = 192
  Top = 120
  Caption = #1054#1082#1085#1086' '#1073#1080#1090#1074#1099
  ClientHeight = 350
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 168
    Top = 77
    Width = 82
    Height = 13
    Caption = #1050#1091#1073#1080#1082#1086#1074' '#1074' '#1072#1090#1072#1082#1091
  end
  object Label2: TLabel
    Left = 632
    Top = 329
    Width = 15
    Height = 13
    Caption = '0.0'
  end
  object PlayerCombo: TLabeledEdit
    Left = 24
    Top = 40
    Width = 121
    Height = 21
    EditLabel.Width = 92
    EditLabel.Height = 13
    EditLabel.Caption = #1042#1072#1096#1072' '#1082#1086#1084#1073#1080#1085#1072#1094#1080#1103
    TabOrder = 0
  end
  object BotCombo: TLabeledEdit
    Left = 24
    Top = 96
    Width = 121
    Height = 21
    EditLabel.Width = 89
    EditLabel.Height = 13
    EditLabel.Caption = #1050#1086#1084#1073#1080#1085#1072#1094#1080#1103' '#1073#1086#1090#1072
    TabOrder = 1
  end
  object Button2: TButton
    Left = 456
    Top = 36
    Width = 145
    Height = 25
    Caption = #1053#1072#1095#1072#1090#1100' '#1073#1086#1081
    TabOrder = 2
    OnClick = Button2Click
  end
  object ManTablo: TLabeledEdit
    Left = 456
    Top = 104
    Width = 121
    Height = 21
    EditLabel.Width = 53
    EditLabel.Height = 13
    EditLabel.Caption = #1042#1072#1096#1080' '#1086#1095#1082#1080
    TabOrder = 3
  end
  object BotTablo: TLabeledEdit
    Left = 456
    Top = 144
    Width = 121
    Height = 21
    EditLabel.Width = 51
    EditLabel.Height = 13
    EditLabel.Caption = #1054#1095#1082#1080' '#1073#1086#1090#1072
    TabOrder = 4
  end
  object Memo1: TMemo
    Left = 24
    Top = 144
    Width = 377
    Height = 185
    TabOrder = 5
  end
  object LabeledEdit1: TLabeledEdit
    Left = 168
    Top = 38
    Width = 121
    Height = 21
    EditLabel.Width = 365
    EditLabel.Height = 13
    EditLabel.Caption = 
      #1050#1086#1085#1074#1077#1088#1089#1080#1103'('#1087#1077#1088#1074#1072#1103' '#1094#1080#1092#1088#1072' '#1095#1090#1086' '#1082#1086#1085#1074#1077#1088#1090#1080#1088#1091#1077#1084' , '#1074#1090#1086#1088#1072#1103' - '#1074#1086' '#1095#1090#1086')/'#1055#1077#1088#1077#1073 +
      #1088#1086#1089
    TabOrder = 6
  end
  object Button3: TButton
    Left = 305
    Top = 36
    Width = 145
    Height = 25
    Caption = #1050#1086#1085#1074#1077#1088#1089#1080#1103
    TabOrder = 7
    Visible = False
    OnClick = Button3Click
  end
  object SpinEdit1: TSpinEdit
    Left = 168
    Top = 96
    Width = 121
    Height = 22
    MaxValue = 12
    MinValue = 0
    ReadOnly = True
    TabOrder = 8
    Value = 0
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 464
    Top = 232
  end
end
