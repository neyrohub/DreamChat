object FormPopUpMessage: TFormPopUpMessage
  Left = 258
  Top = 239
  Caption = 'FormPopUpMessage'
  ClientHeight = 193
  ClientWidth = 263
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TsPanel
    Left = 0
    Top = 136
    Width = 263
    Height = 57
    Align = alBottom
    TabOrder = 0
    SkinData.SkinSection = 'PANEL'
    object Button1: TsButton
      Left = 32
      Top = 16
      Width = 89
      Height = 33
      Caption = 'OK'
      TabOrder = 0
      OnClick = Button1Click
      SkinData.SkinSection = 'BUTTON'
    end
    object Button2: TsButton
      Left = 152
      Top = 16
      Width = 81
      Height = 33
      Caption = #1054#1090#1074#1077#1090#1080#1090#1100
      TabOrder = 1
      OnClick = Button2Click
      SkinData.SkinSection = 'BUTTON'
    end
  end
  object Panel2: TsPanel
    Left = 0
    Top = 0
    Width = 263
    Height = 136
    Align = alClient
    TabOrder = 1
    SkinData.SkinSection = 'PANEL'
  end
  object SkinProvider1: TsSkinProvider
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 8
    Top = 8
  end
end
