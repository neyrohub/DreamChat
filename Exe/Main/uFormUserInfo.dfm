object FormUI: TFormUI
  Left = 210
  Top = 171
  BorderStyle = bsSizeToolWin
  Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077
  ClientHeight = 287
  ClientWidth = 372
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object UserInfoChatView: TsChatView
    Left = 0
    Top = 0
    Width = 372
    Height = 287
    TabStop = True
    TabOrder = 0
    Align = alClient
    Constraints.MinWidth = 32
    Tracking = True
    VScrollVisible = True
    OnClick = UserInfoChatViewClick
    OnKeyDown = UserInfoChatViewKeyDown
    OnKeyUp = UserInfoChatViewKeyUp
    FirstJumpNo = 0
    MaxTextWidth = 0
    MinTextWidth = 0
    LeftMargin = 5
    RightMargin = 5
    BackgroundStyle = bsNoBitmap
    Delimiters = ' .;,:)}'
    MergeDelimiters = '({"|'
    AllowSelection = True
    SingleClick = False
    VScrollBound = 20
    HScrollBound = 20
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -16
    BoundLabel.Font.Name = 'MS Sans Serif'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
    SkinData.SkinSection = 'EDIT'
  end
  object sSkinProvider1: TsSkinProvider
    AddedTitle.Font.Charset = DEFAULT_CHARSET
    AddedTitle.Font.Color = clNone
    AddedTitle.Font.Height = -13
    AddedTitle.Font.Name = 'Tahoma'
    AddedTitle.Font.Style = []
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 8
    Top = 56
  end
end
