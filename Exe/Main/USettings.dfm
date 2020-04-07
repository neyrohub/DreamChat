object FSettings: TFSettings
  Left = 416
  Top = 152
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 459
  ClientWidth = 667
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Reference Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object pMess: TsPanel
    Left = 136
    Top = 0
    Width = 531
    Height = 404
    Align = alClient
    ParentBackground = False
    TabOrder = 1
    Visible = False
    SkinData.SkinSection = 'PANEL'
    DesignSize = (
      531
      404)
    object lMess: TsLabel
      Left = 6
      Top = 6
      Width = 117
      Height = 22
      Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1103':'
      ParentFont = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = [fsBold]
    end
    object tcAutoM: TsTabControl
      Left = 11
      Top = 28
      Width = 509
      Height = 211
      Anchors = [akLeft, akTop, akRight, akBottom]
      MultiLine = True
      TabOrder = 0
      Tabs.Strings = (
        #1042#1093#1086#1076' '#1074' '#1095#1072#1090':'
        #1056#1077#1078#1080#1084' "'#1053#1077' '#1073#1077#1089#1087#1086#1082#1086#1080#1090#1100' '#1085#1072' '#1084#1072#1089#1089#1086#1074#1099#1077' '#1083#1080#1095#1085#1099#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1103'":'
        #1056#1077#1078#1080#1084' "'#1053#1077' '#1073#1077#1089#1087#1086#1082#1086#1080#1090#1100' '#1085#1072' '#1074#1089#1077' '#1083#1080#1095#1085#1099#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1103'":'
        #1056#1077#1078#1080#1084' "'#1052#1077#1085#1103' '#1085#1077#1090'":')
      TabIndex = 0
      OnChange = tcAutoMChange
      OnChanging = tcAutoMChanging
      SkinData.SkinSection = 'TABCONTROL'
      DesignSize = (
        509
        211)
      object lbMessages: TsListBox
        Left = 16
        Top = 50
        Width = 403
        Height = 150
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 19
        TabOrder = 0
        OnDblClick = lbMessagesDblClick
        OnKeyDown = lbMessagesKeyDown
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = DEFAULT_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -16
        BoundLabel.Font.Name = 'Tahoma'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeft
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
        SkinData.SkinSection = 'EDIT'
      end
      object bbAdd: TsBitBtn
        Left = 425
        Top = 50
        Width = 75
        Height = 23
        Anchors = [akTop, akRight]
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100
        TabOrder = 1
        OnClick = bbAddClick
        SkinData.SkinSection = 'BUTTON'
      end
      object bbUp: TsBitBtn
        Left = 425
        Top = 134
        Width = 75
        Height = 22
        Anchors = [akTop, akRight]
        Caption = #1042#1074#1077#1088#1093
        TabOrder = 4
        OnClick = bbUpClick
        SkinData.SkinSection = 'BUTTON'
      end
      object bbDown: TsBitBtn
        Left = 425
        Top = 161
        Width = 75
        Height = 23
        Anchors = [akTop, akRight]
        Caption = #1042#1085#1080#1079
        TabOrder = 5
        OnClick = bbDownClick
        SkinData.SkinSection = 'BUTTON'
      end
      object bbEdit: TsBitBtn
        Left = 425
        Top = 106
        Width = 75
        Height = 23
        Anchors = [akTop, akRight]
        Caption = #1048#1079#1084#1077#1085#1080#1090#1100
        TabOrder = 3
        OnClick = bbEditClick
        SkinData.SkinSection = 'BUTTON'
      end
      object bbDel: TsBitBtn
        Left = 425
        Top = 78
        Width = 75
        Height = 23
        Anchors = [akTop, akRight]
        Caption = #1059#1076#1072#1083#1080#1090#1100
        TabOrder = 2
        OnClick = bbDelClick
        SkinData.SkinSection = 'BUTTON'
      end
    end
    object gReceived: TsGroupBox
      Left = 11
      Top = 252
      Width = 509
      Height = 53
      Anchors = [akLeft, akRight, akBottom]
      Caption = #1055#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077' '#1076#1086#1089#1090#1072#1074#1082#1080':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      SkinData.SkinSection = 'GROUPBOX'
      DesignSize = (
        509
        53)
      object eRes: TsEdit
        Left = 11
        Top = 20
        Width = 487
        Height = 27
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Times New Roman'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Text = #1055#1088#1086#1095#1080#1090#1072#1083'! '#1052#1085#1086#1075#1086' '#1076#1091#1084#1072#1083'...'
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
    end
    object gbBoard: TsGroupBox
      Left = 11
      Top = 317
      Width = 509
      Height = 56
      Anchors = [akLeft, akRight, akBottom]
      Caption = #1044#1086#1089#1082#1072' '#1086#1073#1100#1103#1074#1083#1077#1085#1080#1081':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 2
      SkinData.SkinSection = 'GROUPBOX'
      DesignSize = (
        509
        56)
      object feMesBoard: TsFilenameEdit
        Left = 60
        Top = 22
        Width = 312
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Times New Roman'
        Font.Style = []
        MaxLength = 255
        ParentFont = False
        TabOrder = 0
        Text = 'MessageBoard.txt'
        OnExit = feMesBoardExit
        OnKeyPress = feMesBoardKeyPress
        BoundLabel.Active = True
        BoundLabel.Caption = #1060#1072#1081#1083':'
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = RUSSIAN_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -13
        BoundLabel.Font.Name = 'MS Reference Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeft
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
        SkinData.SkinSection = 'EDIT'
        OnButtonClick = feMesBoardButtonClick
        GlyphMode.Blend = 0
        GlyphMode.Grayed = False
        Filter = #1058#1077#1082#1089#1090#1086#1074#1099#1077' '#1092#1072#1081#1083#1099' (*.txt)|*.txt|'#1042#1089#1077' '#1092#1072#1081#1083#1099' (*.*)|*.*'
        DialogOptions = [ofHideReadOnly, ofNoChangeDir, ofPathMustExist, ofFileMustExist, ofEnableSizing]
      end
      object bbEdBoard: TsBitBtn
        Left = 378
        Top = 22
        Width = 120
        Height = 22
        Anchors = [akTop, akRight]
        Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = bbEdBoardClick
        SkinData.SkinSection = 'BUTTON'
      end
    end
  end
  object pPlugins: TsPanel
    Left = 136
    Top = 0
    Width = 531
    Height = 404
    Align = alClient
    TabOrder = 3
    Visible = False
    OnClick = pPluginsClick
    SkinData.SkinSection = 'PANEL'
    object Label1: TsLabel
      Left = 71
      Top = 8
      Width = 43
      Height = 16
      Caption = 'FileList'
    end
    object Label2: TsLabel
      Left = 188
      Top = 8
      Width = 179
      Height = 16
      Caption = 'Autoloading NativePluginList'
    end
    object Label3: TsLabel
      Left = 409
      Top = 8
      Width = 96
      Height = 16
      Caption = 'Loaded Plugins'
    end
    object ButtonLoadPlugin: TsButton
      Left = 226
      Top = 376
      Width = 136
      Height = 24
      Caption = 'Load plugin'
      TabOrder = 0
      OnClick = ButtonLoadPluginClick
      SkinData.SkinSection = 'BUTTON'
    end
    object ButtonUnloadPlugin: TsButton
      Left = 369
      Top = 376
      Width = 129
      Height = 24
      Caption = 'Unload plugin'
      TabOrder = 1
      OnClick = ButtonUnloadPluginClick
      SkinData.SkinSection = 'BUTTON'
    end
    object ListBox2: TsListBox
      Left = 376
      Top = 30
      Width = 144
      Height = 152
      ItemHeight = 16
      TabOrder = 4
      OnClick = ListBox2Click
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
    object Memo1: TsMemo
      Left = 8
      Top = 188
      Width = 363
      Height = 182
      Lines.Strings = (
        'Memo1')
      TabOrder = 5
      Text = 'Memo1'#13#10
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
    object Memo2: TsMemo
      Left = 376
      Top = 188
      Width = 144
      Height = 182
      Lines.Strings = (
        'Memo2')
      TabOrder = 6
      Text = 'Memo2'#13#10
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
    object CheckListBox1: TsCheckListBox
      Left = 188
      Top = 30
      Width = 183
      Height = 152
      BorderStyle = bsSingle
      ItemHeight = 13
      TabOrder = 3
      OnClick = CheckListBox1Click
      OnDblClick = CheckListBox1DblClick
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
      OnClickCheck = CheckListBox1ClickCheck
    end
    object ListBox1: TsListBox
      Left = 8
      Top = 30
      Width = 174
      Height = 152
      ItemHeight = 16
      TabOrder = 2
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
  end
  object pUsers: TsPanel
    Left = 136
    Top = 0
    Width = 531
    Height = 404
    Align = alClient
    ParentBackground = False
    TabOrder = 8
    SkinData.SkinSection = 'PANEL'
    DesignSize = (
      531
      404)
    object lUser: TsLabel
      Left = 6
      Top = 6
      Width = 515
      Height = 18
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100': '#1053#1072#1095#1072#1083#1100#1085#1099#1077' '#1085#1072#1089#1090#1088#1086#1081#1082#1080
      ParentFont = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = [fsBold]
    end
    object gbUserFonts: TsGroupBox
      Left = 11
      Top = 26
      Width = 509
      Height = 79
      Anchors = [akLeft, akTop, akRight]
      Caption = #1064#1088#1080#1092#1090#1099':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      SkinData.SkinSection = 'GROUPBOX'
      DesignSize = (
        509
        79)
      object pChatView: TsPanel
        Left = 11
        Top = 20
        Width = 486
        Height = 48
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Color = clWindow
        ParentBackground = False
        TabOrder = 0
        OnClick = pFClick
        SkinData.CustomColor = True
        SkinData.SkinSection = 'UNKNOWN'
        object lNick: TsLabel
          Left = 6
          Top = 6
          Width = 159
          Height = 22
          Caption = #1053#1080#1082' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
          ParentColor = False
          ParentFont = False
          OnClick = FontLabelClick
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGreen
          Font.Height = -17
          Font.Name = 'MS Reference Sans Serif'
          Font.Style = []
          UseSkinColor = False
        end
        object lMouseOver: TsLabel
          Left = 6
          Top = 22
          Width = 243
          Height = 22
          Caption = #1053#1072#1078#1072#1090#1099#1081' '#1085#1080#1082' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
          ParentColor = False
          ParentFont = False
          OnClick = FontLabelClick
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = -17
          Font.Name = 'MS Reference Sans Serif'
          Font.Style = []
          UseSkinColor = False
        end
      end
    end
    object gbSounds: TsGroupBox
      Left = 11
      Top = 116
      Width = 509
      Height = 276
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = #1047#1074#1091#1082#1080':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      SkinData.SkinSection = 'GROUPBOX'
      DesignSize = (
        509
        276)
      object fbSounds: TsFrameBar
        Left = 11
        Top = 20
        Width = 485
        Height = 244
        HorzScrollBar.Visible = False
        VertScrollBar.Range = 368
        VertScrollBar.Tracking = True
        Align = alNone
        Anchors = [akLeft, akTop, akRight, akBottom]
        AutoScroll = False
        TabOrder = 0
        TabStop = True
        SkinData.SkinSection = 'BAR'
        AllowAllClose = True
        AutoFrameSize = False
        Items = <
          item
            Caption = #1055#1086#1083#1091#1095#1077#1085#1086' '#1083#1080#1095#1085#1086#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1077
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems0CreateFrame
            OnFrameDestroy = fbSoundsItems0FrameDestroy
          end
          item
            Caption = #1055#1086#1083#1091#1095#1077#1085#1086' '#1084#1072#1089#1086#1074#1086#1077' '#1083#1080#1095#1085#1086#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1077
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems1CreateFrame
            OnFrameDestroy = fbSoundsItems1FrameDestroy
          end
          item
            Caption = #1054#1073#1085#1086#1074#1083#1077#1085#1072' '#1076#1086#1089#1082#1072' '#1086#1073#1098#1103#1074#1083#1077#1085#1080#1081
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems2CreateFrame
            OnFrameDestroy = fbSoundsItems2FrameDestroy
          end
          item
            Caption = #1055#1088#1080#1096#1083#1086' '#1089#1086#1086#1073#1097#1077#1085#1080#1077
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems3CreateFrame
            OnFrameDestroy = fbSoundsItems3FrameDestroy
          end
          item
            Caption = #1055#1086#1103#1074#1080#1083#1089#1103' '#1085#1086#1074#1099#1081' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems4CreateFrame
            OnFrameDestroy = fbSoundsItems4FrameDestroy
          end
          item
            Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100' '#1091#1096#1077#1083
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems5CreateFrame
            OnFrameDestroy = fbSoundsItems5FrameDestroy
          end
          item
            Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100' '#1080#1079#1084#1077#1085#1080#1083' '#1080#1084#1103
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems6CreateFrame
            OnFrameDestroy = fbSoundsItems6FrameDestroy
          end
          item
            Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100' '#1080#1079#1084#1077#1085#1080#1083' '#1089#1090#1072#1090#1091#1089
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems7CreateFrame
            OnFrameDestroy = fbSoundsItems7FrameDestroy
          end
          item
            Caption = #1053#1072#1081#1076#1077#1085#1072' '#1083#1080#1085#1080#1103
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems8CreateFrame
            OnFrameDestroy = fbSoundsItems8FrameDestroy
          end
          item
            Caption = #1042#1093#1086#1076' '#1074' '#1083#1080#1085#1080#1102
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems9CreateFrame
            OnFrameDestroy = fbSoundsItems9FrameDestroy
          end
          item
            Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077' '#1076#1086#1089#1090#1072#1074#1083#1077#1085#1086
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems10CreateFrame
            OnFrameDestroy = fbSoundsItems10FrameDestroy
          end
          item
            Caption = #1055#1086#1083#1091#1095#1077#1085' REFRESH '#1079#1072#1087#1088#1086#1089' '
            Cursor = crDefault
            SkinSection = 'BARTITLE'
            OnCreateFrame = fbSoundsItems11CreateFrame
            OnFrameDestroy = fbSoundsItems11FrameDestroy
          end>
        Spacing = 0
      end
    end
  end
  object pFont: TsPanel
    Left = 136
    Top = 0
    Width = 531
    Height = 404
    Align = alClient
    ParentBackground = False
    TabOrder = 2
    Visible = False
    SkinData.SkinSection = 'PANEL'
    DesignSize = (
      531
      404)
    object lFonts: TsLabel
      Left = 6
      Top = 6
      Width = 90
      Height = 22
      Caption = #1064#1088#1080#1092#1090#1099':'
      ParentFont = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = [fsBold]
    end
    object tUsers: TsTreeView
      Left = 295
      Top = 28
      Width = 225
      Height = 330
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoExpand = True
      BevelInner = bvNone
      BevelOuter = bvNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = []
      Images = ImageList1
      Indent = 35
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      OnClick = tUsersClick
      Items.NodeData = {
        0102000000210000000100000000000000FFFFFFFFFFFFFFFF00000000010000
        000441006C00650078002F0000000000000000000000FFFFFFFFFFFFFFFF0000
        0000000000000B1D043E04320430044F0420003B0438043D0438044F042F0000
        000000000000000000FFFFFFFFFFFFFFFF00000000010000000B1D043E043204
        30044F0420003B0438043D0438044F04210000000100000000000000FFFFFFFF
        FFFFFFFF00000000000000000441006C0065007800}
      BoundLabel.Indent = 0
      BoundLabel.Font.Charset = DEFAULT_CHARSET
      BoundLabel.Font.Color = clWindowText
      BoundLabel.Font.Height = -16
      BoundLabel.Font.Name = 'MS Sans Serif'
      BoundLabel.Font.Style = []
      BoundLabel.Layout = sclLeft
      BoundLabel.MaxWidth = 0
      BoundLabel.UseSkinColor = True
      SkinData.CustomFont = True
      SkinData.SkinSection = 'EDIT'
    end
    object pF: TsPanel
      Left = 11
      Top = 28
      Width = 278
      Height = 330
      Anchors = [akLeft, akTop, akBottom]
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Color = clWindow
      ParentBackground = False
      TabOrder = 1
      OnClick = pFClick
      SkinData.CustomColor = True
      SkinData.SkinSection = 'UNKNOWN'
      object lNormal: TsLabel
        Left = 6
        Top = 6
        Width = 208
        Height = 22
        Caption = #1055#1086#1083#1091#1095#1077#1085#1085#1086#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1077
        ParentColor = False
        ParentFont = False
        OnClick = FontLabelClick
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        UseSkinColor = False
      end
      object lSystem: TsLabel
        Left = 6
        Top = 22
        Width = 195
        Height = 22
        Caption = #1057#1080#1089#1090#1077#1084#1085#1086#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1077
        ParentColor = False
        ParentFont = False
        OnClick = FontLabelClick
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        UseSkinColor = False
      end
      object lPrivat: TsLabel
        Left = 6
        Top = 39
        Width = 167
        Height = 22
        Caption = #1051#1080#1095#1085#1086#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1077
        ParentColor = False
        ParentFont = False
        OnClick = FontLabelClick
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        UseSkinColor = False
      end
      object lBoard: TsLabel
        Left = 6
        Top = 56
        Width = 293
        Height = 22
        Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077' '#1085#1072' '#1076#1086#1089#1082#1077' '#1086#1073#1098#1103#1074#1083#1077#1085#1080#1081
        ParentColor = False
        ParentFont = False
        OnClick = FontLabelClick
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = [fsItalic]
        UseSkinColor = False
      end
      object lLink: TsLabel
        Left = 6
        Top = 72
        Width = 66
        Height = 22
        Caption = #1057#1089#1099#1083#1082#1072
        ParentColor = False
        ParentFont = False
        OnClick = FontLabelClick
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = [fsUnderline]
        UseSkinColor = False
      end
      object lOnLink: TsLabel
        Left = 6
        Top = 89
        Width = 144
        Height = 22
        Caption = #1053#1072#1078#1072#1090#1072#1103' '#1089#1089#1099#1083#1082#1072
        ParentColor = False
        ParentFont = False
        OnClick = FontLabelClick
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clLime
        Font.Height = -17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = [fsUnderline]
        UseSkinColor = False
      end
      object lInfoName: TsLabel
        Left = 6
        Top = 106
        Width = 208
        Height = 22
        Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103', '#1053#1072#1079#1074#1072#1085#1080#1077
        ParentColor = False
        ParentFont = False
        OnClick = FontLabelClick
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        UseSkinColor = False
      end
      object lInfoText: TsLabel
        Left = 6
        Top = 122
        Width = 172
        Height = 22
        Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103', '#1058#1077#1082#1089#1090
        ParentColor = False
        ParentFont = False
        OnClick = FontLabelClick
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        UseSkinColor = False
      end
      object lMeText: TsLabel
        Left = 6
        Top = 139
        Width = 160
        Height = 22
        Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077' '#1086' '#1089#1077#1073#1077
        ParentColor = False
        ParentFont = False
        OnClick = FontLabelClick
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        UseSkinColor = False
      end
    end
    object eMess: TsEdit
      Left = 11
      Top = 364
      Width = 509
      Height = 27
      Anchors = [akLeft, akRight, akBottom]
      AutoSelect = False
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
      Text = #1058#1077#1082#1089#1090' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
      OnClick = eMessClick
      SkinData.CustomFont = True
      SkinData.SkinSection = 'EDIT'
      BoundLabel.Indent = 0
      BoundLabel.Font.Charset = DEFAULT_CHARSET
      BoundLabel.Font.Color = clWindowText
      BoundLabel.Font.Height = -16
      BoundLabel.Font.Name = 'MS Sans Serif'
      BoundLabel.Font.Style = []
      BoundLabel.Layout = sclLeft
      BoundLabel.MaxWidth = 0
      BoundLabel.UseSkinColor = True
    end
  end
  object pLangSkin: TsPanel
    Left = 136
    Top = 0
    Width = 531
    Height = 404
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Reference Sans Serif'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 6
    Visible = False
    SkinData.SkinSection = 'PANEL'
    DesignSize = (
      531
      404)
    object lLangSkin: TsLabel
      Left = 6
      Top = 6
      Width = 206
      Height = 18
      AutoSize = False
      Caption = #1057#1082#1080#1085' '#1080' '#1071#1079#1099#1082':'
      ParentFont = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = [fsBold]
    end
    object gSkin: TsGroupBox
      Left = 8
      Top = 26
      Width = 513
      Height = 94
      Anchors = [akLeft, akTop, akRight]
      Caption = #1057#1082#1080#1085':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      SkinData.SkinSection = 'GROUPBOX'
      DesignSize = (
        513
        94)
      object lColor: TsLabel
        Left = 217
        Top = 50
        Width = 84
        Height = 16
        Caption = #1062#1074#1077#1090' '#1089#1082#1080#1085#1072':'
        ParentFont = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
      end
      object eSkinPath: TsDirectoryEdit
        Left = 145
        Top = 22
        Width = 359
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = []
        MaxLength = 255
        ParentFont = False
        TabOrder = 0
        OnChange = eSkinPathChange
        OnExit = eSkinPathExit
        OnKeyPress = eSkinPathKeyPress
        OnMouseActivate = eSkinPathMouseActivate
        BoundLabel.Active = True
        BoundLabel.Caption = #1055#1072#1087#1082#1072' '#1089#1086' '#1089#1082#1080#1085#1072#1084#1080':'
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = RUSSIAN_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -13
        BoundLabel.Font.Name = 'MS Reference Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeft
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
        SkinData.SkinSection = 'EDIT'
        GlyphMode.Blend = 0
        GlyphMode.Grayed = False
        Root = 'rfDesktop'
      end
      object cbSkin: TsComboBox
        Left = 56
        Top = 50
        Width = 150
        Height = 22
        Alignment = taLeftJustify
        BoundLabel.Active = True
        BoundLabel.Caption = #1057#1082#1080#1085':'
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = RUSSIAN_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -13
        BoundLabel.Font.Name = 'MS Reference Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeft
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
        SkinData.SkinSection = 'COMBOBOX'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = []
        ItemHeight = 16
        ItemIndex = -1
        ParentFont = False
        TabOrder = 1
        Text = #1041#1077#1079' '#1089#1082#1080#1085#1072
        OnSelect = cbSkinChange
        OnChange = cbSkinChange
        Items.Strings = (
          #1041#1077#1079' '#1089#1082#1080#1085#1072)
      end
      object tColor: TsTrackBar
        Left = 306
        Top = 50
        Width = 205
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        Max = 359
        TabOrder = 2
        ThumbLength = 20
        TickStyle = tsNone
        OnChange = tColorChange
        SkinData.SkinSection = 'TRACKBAR'
      end
    end
    object gbLanguage: TsGroupBox
      Left = 8
      Top = 141
      Width = 513
      Height = 75
      Anchors = [akLeft, akTop, akRight]
      Caption = #1071#1079#1099#1082' (Language):'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      SkinData.SkinSection = 'GROUPBOX'
      DesignSize = (
        513
        75)
      object cbLangChange: TsComboBox
        Left = 11
        Top = 22
        Width = 493
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        Alignment = taLeftJustify
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = DEFAULT_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -16
        BoundLabel.Font.Name = 'MS Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeft
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
        SkinData.SkinSection = 'COMBOBOX'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ItemHeight = 16
        ItemIndex = -1
        ParentFont = False
        TabOrder = 0
        Text = #1056#1091#1089#1089#1082#1080#1081
        OnChange = cbLangChangeChange
      end
    end
  end
  object pCommon: TsPanel
    Left = 136
    Top = 0
    Width = 531
    Height = 404
    Align = alClient
    ParentBackground = False
    TabOrder = 7
    SkinData.SkinSection = 'PANEL'
    DesignSize = (
      531
      404)
    object lComm: TsLabel
      Left = 6
      Top = 6
      Width = 73
      Height = 22
      Caption = #1054#1073#1097#1080#1077':'
      ParentFont = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = [fsBold]
    end
    object gbDifferent: TsGroupBox
      Left = 11
      Top = 31
      Width = 509
      Height = 57
      Anchors = [akLeft, akTop, akRight]
      Caption = #1056#1072#1079#1085#1086#1077':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      SkinData.SkinSection = 'GROUPBOX'
      object cbCloseButton: TsCheckBox
        Left = 12
        Top = 20
        Width = 391
        Height = 20
        Caption = #1050#1085#1086#1087#1082#1072' '#1079#1072#1082#1088#1099#1090#1080#1103' '#1086#1082#1085#1072' '#1089#1074#1086#1088#1072#1095#1080#1074#1072#1077#1090' '#1087#1088#1086#1075#1088#1072#1084#1084#1091' '#1074' '#1090#1088#1077#1081
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        SkinData.SkinSection = 'CHECKBOX'
        ImgChecked = 0
        ImgUnchecked = 0
      end
    end
    object gbHotKey: TsGroupBox
      Left = 11
      Top = 91
      Width = 509
      Height = 67
      Anchors = [akLeft, akTop, akRight]
      Caption = #1043#1086#1088#1103#1095#1080#1077' '#1082#1086#1084#1073#1080#1085#1072#1094#1080#1080':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      SkinData.SkinSection = 'GROUPBOX'
      object eHotKey: TsEdit
        Left = 152
        Top = 27
        Width = 78
        Height = 23
        BevelEdges = []
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Times New Roman'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnExit = eIPAdrExit
        OnKeyPress = eHotKeyKeyPress
        SkinData.SkinSection = 'EDIT'
        BoundLabel.Active = True
        BoundLabel.Caption = #1057#1074#1077#1088#1085#1091#1090#1100' '#1074' Systray:'
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = RUSSIAN_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -13
        BoundLabel.Font.Name = 'MS Reference Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeftTop
        BoundLabel.MaxWidth = 150
        BoundLabel.UseSkinColor = True
      end
    end
  end
  object pPodkluchenie: TsPanel
    Left = 136
    Top = 0
    Width = 531
    Height = 404
    Align = alClient
    ParentBackground = False
    TabOrder = 4
    SkinData.SkinSection = 'PANEL'
    DesignSize = (
      531
      404)
    object lPodkl: TsLabel
      Left = 6
      Top = 6
      Width = 141
      Height = 22
      Caption = #1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077':'
      ParentFont = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = [fsBold]
    end
    object pNameSel: TsRadioGroup
      Left = 11
      Top = 28
      Width = 209
      Height = 364
      Anchors = [akLeft, akTop, akBottom]
      Caption = #1048#1084#1103' ('#1085#1080#1082'):'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 0
      SkinData.SkinSection = 'GROUPBOX'
    end
    object rFromName: TsRadioButton
      Left = 22
      Top = 68
      Width = 128
      Height = 20
      Caption = #1048#1084#1103' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072
      TabOrder = 4
      OnClick = rNameClick
      AutoSize = False
      SkinData.SkinSection = 'RADIOBUTTON'
    end
    object rName: TsRadioButton
      Left = 22
      Top = 89
      Width = 115
      Height = 20
      Caption = #1048#1084#1103' '#1080#1079' '#1089#1087#1080#1089#1082#1072':'
      TabOrder = 5
      OnClick = rNameClick
      AutoSize = False
      SkinData.SkinSection = 'RADIOBUTTON'
    end
    object lNames: TsListBox
      Left = 22
      Top = 111
      Width = 179
      Height = 256
      Style = lbOwnerDrawVariable
      Anchors = [akLeft, akTop, akBottom]
      Enabled = False
      ItemHeight = 20
      PopupMenu = PopupMenu1
      TabOrder = 6
      OnDblClick = lNamesDblClick
      OnKeyDown = lNamesKeyDown
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
    object rFromLogon: TsRadioButton
      Left = 22
      Top = 47
      Width = 191
      Height = 20
      Caption = #1048#1084#1103' '#1080#1079' '#1083#1086#1075#1080#1085#1072' '#1074' Windows'
      Checked = True
      TabOrder = 3
      TabStop = True
      OnClick = rNameClick
      AutoSize = False
      SkinData.SkinSection = 'RADIOBUTTON'
    end
    object gServer: TsGroupBox
      Left = 226
      Top = 102
      Width = 294
      Height = 82
      Anchors = [akLeft, akTop, akRight]
      Caption = #1042#1099#1076#1077#1083#1077#1085#1085#1099#1081' '#1089#1077#1088#1074#1077#1088':'
      Enabled = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 2
      SkinData.SkinSection = 'GROUPBOX'
      object ePortNamb: TsDecimalSpinEdit
        Left = 102
        Top = 51
        Width = 64
        Height = 21
        AutoSize = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Times New Roman'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        Text = '6666'
        SkinData.SkinSection = 'EDIT'
        BoundLabel.Active = True
        BoundLabel.Caption = #1055#1086#1088#1090':'
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = RUSSIAN_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -13
        BoundLabel.Font.Name = 'MS Reference Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeft
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
        Increment = 1.000000000000000000
        MaxValue = 65535.000000000000000000
        MinValue = 1.000000000000000000
        Value = 6666.000000000000000000
        DecimalPlaces = 0
      end
      object eIPAdr: TsEdit
        Left = 102
        Top = 22
        Width = 109
        Height = 21
        AutoSize = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Times New Roman'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Text = '127.0.0.1'
        OnExit = eIPAdrExit
        OnKeyPress = eIPAdrKeyPress
        SkinData.SkinSection = 'EDIT'
        BoundLabel.Active = True
        BoundLabel.Caption = 'IP-'#1072#1076#1088#1077#1089':'
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = RUSSIAN_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -13
        BoundLabel.Font.Name = 'MS Reference Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeft
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
      end
    end
    object gSoedinenie: TsGroupBox
      Left = 226
      Top = 28
      Width = 294
      Height = 65
      Anchors = [akLeft, akTop, akRight]
      Caption = #1057#1086#1077#1076#1080#1085#1077#1085#1080#1077' '#1095#1077#1088#1077#1079':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
      SkinData.SkinSection = 'GROUPBOX'
      object rVidelServ: TsRadioButton
        Left = 8
        Top = 39
        Width = 281
        Height = 20
        Caption = #1042#1099#1076#1077#1083#1077#1085#1085#1099#1081' '#1089#1077#1088#1074#1077#1088
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = 17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = rVidelServClick
        AutoSize = False
        SkinData.SkinSection = 'RADIOBUTTON'
      end
      object rMailSlots: TsRadioButton
        Left = 8
        Top = 18
        Width = 279
        Height = 21
        Caption = 'Windows mailSlot-'#1099
        Checked = True
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = 17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        TabStop = True
        OnClick = rMailSlotsClick
        AutoSize = False
        SkinData.SkinSection = 'RADIOBUTTON'
      end
    end
    object gbCrypto: TsGroupBox
      Left = 226
      Top = 188
      Width = 294
      Height = 93
      Anchors = [akLeft, akTop, akRight]
      Caption = #1050#1083#1102#1095' '#1096#1080#1092#1088#1086#1074#1072#1085#1080#1103':'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Verdana'
      Font.Style = []
      ParentBackground = False
      ParentFont = False
      TabOrder = 7
      SkinData.SkinSection = 'GROUPBOX'
      object rbIChatKey: TsRadioButton
        Left = 8
        Top = 19
        Width = 281
        Height = 21
        Caption = #1050#1083#1102#1095' IChat 1.3b4'
        Checked = True
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = 17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        TabStop = True
        OnClick = rbIChatKeyClick
        AutoSize = False
        SkinData.SkinSection = 'RADIOBUTTON'
      end
      object rbAntiHackKey: TsRadioButton
        Left = 8
        Top = 40
        Width = 281
        Height = 21
        Caption = #1050#1083#1102#1095' IChat 1.3b8 (not work)'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = 17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = rbAntiHackKeyClick
        AutoSize = False
        SkinData.SkinSection = 'RADIOBUTTON'
      end
      object rbUserKey: TsRadioButton
        Left = 8
        Top = 64
        Width = 281
        Height = 19
        Caption = 'Key RC4'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = 17
        Font.Name = 'MS Reference Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = rbUserKeyClick
        AutoSize = False
        SkinData.SkinSection = 'RADIOBUTTON'
      end
      object eCryptoKey: TsEdit
        Left = 96
        Top = 63
        Width = 193
        Height = 21
        AutoSize = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Times New Roman'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        Text = 'tahci'
        OnExit = eIPAdrExit
        SkinData.SkinSection = 'EDIT'
        BoundLabel.Active = True
        BoundLabel.Caption = 'Key RC4:'
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = RUSSIAN_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -13
        BoundLabel.Font.Name = 'MS Reference Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeftTop
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
      end
    end
  end
  object tPanelSel: TsTreeView
    Left = 0
    Top = 0
    Width = 136
    Height = 404
    Align = alLeft
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Verdana'
    Font.Style = []
    HideSelection = False
    Indent = 19
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    OnChange = tPanelSelChange
    Items.NodeData = {
      01060000002F0000000000000001000000FFFFFFFFFFFFFFFF00000000000000
      000B1F043E0434043A043B044E04470435043D04380435042300000000000000
      02000000FFFFFFFFFFFFFFFF0000000000000000051E04310449043804350425
      0000000000000003000000FFFFFFFFFFFFFFFF00000000000000000628044004
      3804440442044B042F0000000000000004000000FFFFFFFFFFFFFFFF00000000
      000000000B21043A0438043D042000380420002F0437044B043A042B00000000
      00000005000000FFFFFFFFFFFFFFFF00000000000000000921043E043E043104
      490435043D0438044F04310000000000000006000000FFFFFFFFFFFFFFFF0000
      0000000000000C1F043E043B044C0437043E0432043004420435043B043804}
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
  object pButtons: TsPanel
    Left = 0
    Top = 404
    Width = 667
    Height = 55
    Align = alBottom
    ParentBackground = False
    TabOrder = 5
    SkinData.SkinSection = 'PANEL_LOW'
    DesignSize = (
      667
      55)
    object bOk: TsBitBtn
      Left = 452
      Top = 12
      Width = 100
      Height = 36
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 0
      OnClick = BOkClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      NumGlyphs = 2
      SkinData.SkinSection = 'BUTTON'
    end
    object bCancel: TsBitBtn
      Left = 556
      Top = 12
      Width = 104
      Height = 36
      Anchors = [akRight, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = bCancelClick
      Kind = bkCancel
      SkinData.SkinSection = 'BUTTON'
    end
    object bAcept: TsBitBtn
      Left = 309
      Top = 12
      Width = 135
      Height = 36
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Reference Sans Serif'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 2
      OnClick = bAceptClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      NumGlyphs = 2
      SkinData.SkinSection = 'BUTTON'
    end
  end
  object sSkinManager1: TsSkinManager
    AnimEffects.FormShow.Time = 100
    AnimEffects.PageChange.Active = False
    IsDefault = False
    Active = False
    InternalSkins = <>
    MenuSupport.IcoLineSkin = 'ICOLINE'
    MenuSupport.ExtraLineFont.Charset = DEFAULT_CHARSET
    MenuSupport.ExtraLineFont.Color = clWindowText
    MenuSupport.ExtraLineFont.Height = -16
    MenuSupport.ExtraLineFont.Name = 'MS Sans Serif'
    MenuSupport.ExtraLineFont.Style = []
    SkinDirectory = 'c:\Skins'
    SkinInfo = 'N/A'
    ThirdParty.ThirdEdits = 
      'TEdit'#13#10'TMemo'#13#10'TMaskEdit'#13#10'TLabeledEdit'#13#10'THotKey'#13#10'TListBox'#13#10'TCheck' +
      'ListBox'#13#10'TDBListBox'#13#10'TRichEdit'#13#10'TDBMemo'#13#10'TSynEdit'#13#10'TSynMemo'#13#10'TDB' +
      'SynEdit'#13#10'TDBLookupListBox'#13#10'TDBRichEdit'#13#10'TDBCtrlGrid'#13#10'TDateTimePi' +
      'cker'#13#10'TDBEdit'
    ThirdParty.ThirdButtons = 'TButton'
    ThirdParty.ThirdBitBtns = 'TBitBtn'
    ThirdParty.ThirdCheckBoxes = 
      'TCheckBox'#13#10'TRadioButton'#13#10'TDBCheckBox'#13#10'TDBCheckBoxEh'#13#10'TGroupButto' +
      'n'
    ThirdParty.ThirdGroupBoxes = 'TGroupBox'#13#10'TDBRadioGroup'#13#10'TRadioGroup'
    ThirdParty.ThirdListViews = 'TListView'
    ThirdParty.ThirdPanels = 'TPanel'#13#10'TDBCtrlPanel'
    ThirdParty.ThirdGrids = 
      'TStringGrid'#13#10'TDrawGrid'#13#10'TRichView'#13#10'TDBRichViewEdit'#13#10'TRichViewEdi' +
      't'#13#10'TDBRichView'#13#10'TwwDBGrid'#13#10'TAdvStringGrid'#13#10'TDBAdvGrid'#13#10'TValueLis' +
      'tEditor'#13#10'TDBGrid'
    ThirdParty.ThirdTreeViews = 'TTreeView'#13#10'TRzTreeView'#13#10'TDBTreeView'
    ThirdParty.ThirdComboBoxes = 'TComboBox'#13#10'TColorBox'#13#10'TDBComboBox'
    ThirdParty.ThirdWWEdits = 
      'TDBLookupComboBox'#13#10'TwwDBComboBox'#13#10'TwwDBCustomCombo'#13#10'TwwDBCustomL' +
      'ookupCombo'
    ThirdParty.ThirdVirtualTrees = 
      'TVirtualStringTree'#13#10'TVirtualStringTreeDB'#13#10'TEasyListview'#13#10'TVirtua' +
      'lExplorerListview'#13#10'TVirtualExplorerTreeview'#13#10'TVirtualExplorerTre' +
      'e'#13#10'TVirtualDrawTree'
    ThirdParty.ThirdGridEh = 'TDBGridEh'
    ThirdParty.ThirdPageControl = ' '
    ThirdParty.ThirdTabControl = ' '
    ThirdParty.ThirdToolBar = ' '
    ThirdParty.ThirdStatusBar = ' '
    ThirdParty.ThirdSpeedButton = ' '
    ThirdParty.ThirdScrollControl = ' '
    ThirdParty.ThirdUpDown = ' '
    Top = 128
  end
  object sSkinProvider1: TsSkinProvider
    AddedTitle.Font.Charset = DEFAULT_CHARSET
    AddedTitle.Font.Color = clNone
    AddedTitle.Font.Height = -13
    AddedTitle.Font.Name = 'Tahoma'
    AddedTitle.Font.Style = []
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 32
    Top = 128
  end
  object PopupMenu1: TPopupMenu
    Left = 64
    Top = 128
    object mAdd: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      OnClick = mAddClick
    end
    object mChenge: TMenuItem
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      OnClick = mChengeClick
    end
    object mDel: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = mDelClick
    end
  end
  object CVStyle1: TCVStyle
    TextStyles = <
      item
        CharSet = RUSSIAN_CHARSET
        FontName = 'MS Reference Sans Serif'
        Size = 9
        Color = clWindowText
        Style = []
      end
      item
        CharSet = RUSSIAN_CHARSET
        FontName = 'MS Reference Sans Serif'
        Size = 9
        Color = clRed
        Style = []
      end
      item
        CharSet = RUSSIAN_CHARSET
        FontName = 'MS Reference Sans Serif'
        Size = 9
        Color = clGreen
        Style = []
      end
      item
        CharSet = RUSSIAN_CHARSET
        FontName = 'MS Reference Sans Serif'
        Size = 9
        Color = clMaroon
        Style = [fsItalic]
      end
      item
        CharSet = RUSSIAN_CHARSET
        FontName = 'MS Reference Sans Serif'
        Size = 9
        Color = clGreen
        Style = [fsUnderline]
      end
      item
        CharSet = RUSSIAN_CHARSET
        FontName = 'MS Reference Sans Serif'
        Size = 9
        Color = clLime
        Style = [fsUnderline]
      end
      item
        CharSet = RUSSIAN_CHARSET
        FontName = 'MS Reference Sans Serif'
        Size = 9
        Color = clRed
        Style = []
      end
      item
        CharSet = RUSSIAN_CHARSET
        FontName = 'MS Reference Sans Serif'
        Size = 9
        Color = clWindowText
        Style = []
      end
      item
        CharSet = RUSSIAN_CHARSET
        FontName = 'MS Reference Sans Serif'
        Size = 9
        Color = clBlue
        Style = []
      end>
    JumpCursor = 101
    Color = clWindow
    HoverColor = clNone
    FullRedraw = False
    SelColor = clHighlight
    SelTextColor = clHighlightText
    Left = 96
    Top = 128
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 64
    Top = 160
  end
  object sColorDialog1: TsColorDialog
    Left = 32
    Top = 160
  end
  object ImageList1: TImageList
    Width = 32
    Top = 160
    Bitmap = {
      494C010102000400040020001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000800000001000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000008000000080000000800000008000000080000000800000008000
      0000000000008000000080000000800000008000000080000000000000008000
      0000800000008000000080000000800000000000000080000000800000008000
      0000800000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000860000008600
      0000860000008600000086000000860000008600000086000000860000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080000000FF00
      0000FF000000800000008000000080000000C0C0C00080000000FF0000008000
      00008000000080000000C0C0C00080000000FF00000080000000800000008000
      0000C0C0C00080000000FF000000800000008000000080000000C0C0C0008000
      0000FF0000008000000080000000000000000000000000000000777A7A00BFBF
      BF00BFBFBF00BFBFBF00BFBFBF00BFBFBF00BFBFBF00BFBFBF00BFBFBF00BFBF
      BF00BFBFBF000000000000000000000000000000000086000000B2000000B200
      0000860000008600000086000000BFBFBF0086000000B2000000860000008600
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      000080000000C0C0C000C0C0C00000000000C0C0C00080808000800000008000
      00000000000000000000C0C0C000808080008000000080000000000000000000
      0000C0C0C0008080800080000000800000000000000000000000C0C0C0008080
      8000800000008000000000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBFBF000000000000000000000000000000000000000000860000008600
      0000BFBFBF00BFBFBF0000000000BFBFBF00777A7A0086000000860000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000008080800000000000800000000000
      0000000000000000000080808000000000008000000000000000000000000000
      0000808080000000000080000000000000000000000000000000808080000000
      0000800000000000000000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      0000777A7A000000000000000000777A7A000000000086000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C000C0C0C000C0C0C0000000
      000000000000C0C0C000C0C0C000C0C0C000C0C0C0000000000000000000C0C0
      C000C0C0C000C0C0C000C0C0C0000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      00000000000000000000BFBFBF00BFBFBF00BFBFBF00BFBFBF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000C0C0C0000000
      000000000000000000000000000000000000C0C0C00000000000000000000000
      00000000000000000000C0C0C000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      000000000000777A7A00000000000000000000000000BFBFBF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C0000000000000000000000000000000000000000000C0C0C000000000000000
      0000000000000000000000000000C0C0C0000000000000000000000000000000
      000000000000C0C0C00000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000BFBFBF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000808080000000000000000000C0C0C000FF000000C0C0
      C000000000000000000000000000C0C0C000FF000000C0C0C000000000000000
      000000000000C0C0C000FF000000C0C0C000000000000000000000000000C0C0
      C000FF000000C0C0C00000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      000000000000777A7A000000000000000000BFBFBF00B2000000BFBFBF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C00000000000808080000000
      00000000000000000000C0C0C000000000008080800000000000000000000000
      0000C0C0C0000000000080808000000000000000000000000000C0C0C0000000
      0000808080000000000000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000BFBFBF0000000000777A7A00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C0000000000000000000000000000000000000000000C0C0C000000000000000
      0000000000000000000000000000C0C0C0000000000000000000000000000000
      000000000000C0C0C00000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000BFBFBF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000777A7A000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000777A7A00777A
      7A00777A7A00777A7A00777A7A00777A7A00777A7A00777A7A00777A7A00777A
      7A00777A7A00777A7A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000080000000100000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFFFFFFFFF0000000000000000
      E0082083FFFFC01F0000000000000000C0000001C007800F0000000000000000
      E10C30C3CFF7C21F0000000000000000F31C71C7CFF7E63F0000000000000000
      E2082083CFF7C41F0000000000000000E1EFBEFBCFF7C3DF0000000000000000
      C1CF3CF3CFF7839F0000000000000000C3E79E79CFF787CF0000000000000000
      C1861861CFF7830F0000000000000000C0492493CFF7809F0000000000000000
      C0618619CFF780CF0000000000000000E0000001C007C00F0000000000000000
      F0000001C003E00F0000000000000000F8082083FFFFF01F0000000000000000
      FFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000
      000000000000}
  end
end
