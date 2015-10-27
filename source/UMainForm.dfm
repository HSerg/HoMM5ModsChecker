object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'HoMM5 Mods Checker'
  ClientHeight = 483
  ClientWidth = 767
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    767
    483)
  PixelsPerInch = 96
  TextHeight = 13
  object lblHMM5Path: TLabel
    Left = 8
    Top = 10
    Width = 165
    Height = 13
    Caption = #1055#1072#1087#1082#1072' '#1089' '#1091#1089#1090#1072#1085#1086#1074#1083#1077#1085#1085#1099#1084#1080' HoMM5'
  end
  object jvdedtHMM5Path: TJvDirectoryEdit
    Left = 8
    Top = 29
    Width = 670
    Height = 21
    DialogKind = dkWin32
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = ''
  end
  object mmLog: TMemo
    Left = 8
    Top = 56
    Width = 751
    Height = 402
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBtnFace
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object btnCheck: TButton
    Left = 684
    Top = 27
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1055#1088#1086#1074#1077#1088#1082#1072
    TabOrder = 2
    OnClick = btnCheckClick
  end
  object statusBar: TStatusBar
    Left = 0
    Top = 464
    Width = 767
    Height = 19
    Panels = <>
  end
end
