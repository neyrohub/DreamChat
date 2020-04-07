object Form1: TForm1
  Left = 139
  Top = 1
  Width = 509
  Height = 500
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 501
    Height = 245
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    object ChatView1: TChatView
      Left = 1
      Top = 1
      Width = 499
      Height = 243
      TabStop = True
      TabOrder = 0
      Align = alClient
      Constraints.MinWidth = 50
      Tracking = True
      VScrollVisible = True
      FirstJumpNo = 0
      Style = CVStyle1
      MaxTextWidth = 0
      MinTextWidth = 0
      LeftMargin = 5
      RightMargin = 5
      BackgroundStyle = bsNoBitmap
      Delimiters = ' .;,:)}"'
      MergeDelimiters = '({"|'
      AllowSelection = True
      SingleClick = False
      VScrollBound = 20
      HScrollBound = 20
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 245
    Width = 501
    Height = 228
    Align = alBottom
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 32
      Height = 13
      Caption = 'Label1'
    end
    object Button1: TButton
      Left = 398
      Top = 1
      Width = 99
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 398
      Top = 32
      Width = 99
      Height = 25
      Caption = 'Button2'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 398
      Top = 64
      Width = 99
      Height = 25
      Caption = 'AddText'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 398
      Top = 96
      Width = 99
      Height = 25
      Caption = 'AddStyle'
      TabOrder = 3
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 400
      Top = 128
      Width = 97
      Height = 25
      Caption = 'Delete Style'
      TabOrder = 4
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 400
      Top = 160
      Width = 97
      Height = 25
      Caption = 'Delete link'
      TabOrder = 5
      OnClick = Button6Click
    end
    object Edit1: TEdit
      Left = 400
      Top = 192
      Width = 97
      Height = 21
      TabOrder = 6
    end
    object Button7: TButton
      Left = 320
      Top = 192
      Width = 73
      Height = 25
      Caption = 'Clear'
      TabOrder = 7
      OnClick = Button7Click
    end
  end
  object CVStyle1: TCVStyle
    TextStyles = <
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 10
        Color = clWindowText
        Style = []
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 9
        Color = clRed
        Style = []
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 8
        Color = clGreen
        Style = []
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 8
        Color = clBlack
        Style = []
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 8
        Color = clGreen
        Style = [fsUnderline]
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 8
        Color = clAqua
        Style = [fsUnderline]
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 8
        Color = clRed
        Style = []
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 8
        Color = clWindowText
        Style = []
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 12
        Color = clBlue
        Style = []
      end
      item
        CharSet = DEFAULT_CHARSET
        FontName = 'MS Sans Serif'
        Size = 11
        Color = clSilver
        Style = []
      end>
    JumpCursor = 101
    Color = clWindow
    HoverColor = clNone
    FullRedraw = False
    SelColor = clHighlight
    SelTextColor = clHighlightText
    Left = 168
    Top = 160
  end
end
