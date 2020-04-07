object FormStart: TFormStart
  Left = 221
  Top = 201
  BorderIcons = [biSystemMenu]
  BorderStyle = bsNone
  Caption = 'FormStart'
  ClientHeight = 76
  ClientWidth = 312
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 14
  object sLabel2: TsLabel
    Left = 113
    Top = 5
    Width = 43
    Height = 14
    Caption = 'smile.gif'
  end
  object Gauge1: TsGauge
    Left = 8
    Top = 39
    Width = 290
    Height = 17
    SkinData.SkinSection = 'GAUGE'
    ForeColor = clBlack
    Progress = 0
    Suffix = '%'
  end
  object sLabel1: TsLabel
    Left = 12
    Top = 5
    Width = 95
    Height = 14
    Caption = 'Loading smileys...'
  end
  object sSkinProvider1: TsSkinProvider
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 264
    Top = 24
  end
end
