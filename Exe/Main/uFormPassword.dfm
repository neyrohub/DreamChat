object FormPassword: TFormPassword
  Left = 192
  Top = 107
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsToolWindow
  Caption = #1042#1074#1077#1076#1080#1090#1077' '#1087#1072#1088#1086#1083#1100
  ClientHeight = 131
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TsLabel
    Left = 5
    Top = 11
    Width = 52
    Height = 13
    Caption = #1048#1084#1103' '#1083#1080#1085#1080#1080
  end
  object Label2: TsLabel
    Left = 5
    Top = 51
    Width = 37
    Height = 13
    Caption = #1055#1072#1088#1086#1083#1100
  end
  object Edit1: TsEdit
    Left = 72
    Top = 8
    Width = 233
    Height = 29
    TabOrder = 0
    Text = 'Edit1'
    SkinData.SkinSection = 'EDIT'
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -16
    BoundLabel.Font.Name = 'Tahoma'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
  end
  object Edit2: TsEdit
    Left = 72
    Top = 48
    Width = 233
    Height = 29
    TabOrder = 1
    Text = 'Edit2'
    SkinData.SkinSection = 'EDIT'
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -16
    BoundLabel.Font.Name = 'Tahoma'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
  end
  object Button1: TsButton
    Left = 4
    Top = 88
    Width = 152
    Height = 33
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 2
    OnClick = Button1Click
    SkinData.SkinSection = 'BUTTON'
  end
  object Button2: TsButton
    Left = 160
    Top = 88
    Width = 145
    Height = 33
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 3
    OnClick = Button2Click
    SkinData.SkinSection = 'BUTTON'
  end
  object sSkinProvider1: TsSkinProvider
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 16
    Top = 40
  end
end
