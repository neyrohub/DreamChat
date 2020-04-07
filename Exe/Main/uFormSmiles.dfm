object FormSmiles: TFormSmiles
  Left = 190
  Top = 107
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = #1058#1077#1082#1091#1097#1080#1081' '#1089#1084#1072#1081#1083#1080#1082':'
  ClientHeight = 340
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 14
  object ChatView1: TsChatView
    Left = 0
    Top = 0
    Width = 525
    Height = 340
    TabStop = True
    TabOrder = 0
    Align = alClient
    Constraints.MinWidth = 32
    Tracking = True
    VScrollVisible = True
    OnClick = ChatView1Click
    OnKeyDown = ChatView1KeyDown
    OnKeyUp = ChatView1KeyUp
    FirstJumpNo = 0
    Style = CVStyle1
    MaxTextWidth = 0
    MinTextWidth = 0
    LeftMargin = 5
    RightMargin = 5
    BackgroundStyle = bsNoBitmap
    Delimiters = ' .;,:'
    MergeDelimiters = ')(}{"|'
    AllowSelection = True
    SingleClick = False
    VScrollBound = 20
    HScrollBound = 20
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -11
    BoundLabel.Font.Name = 'MS Sans Serif'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
    SkinData.SkinSection = 'EDIT'
  end
  object CVStyle1: TCVStyle
    TextStyles = <
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'Arial'
        Size = 10
        Color = clWindowText
        Style = []
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'Arial'
        Size = 10
        Color = clBlue
        Style = [fsBold]
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'Arial'
        Size = 10
        Color = clNavy
        Style = [fsBold]
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'Arial'
        Size = 10
        Color = clMaroon
        Style = [fsItalic]
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'Arial'
        Size = 10
        Color = clGreen
        Style = [fsUnderline]
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'Arial'
        Size = 10
        Color = clGreen
        Style = [fsUnderline]
      end>
    JumpCursor = 101
    Color = clWindow
    HoverColor = clNone
    FullRedraw = False
    SelColor = clHighlight
    SelTextColor = clHighlightText
    Left = 488
    Top = 8
  end
  object sSkinProvider1: TsSkinProvider
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 456
    Top = 8
  end
end
