object SoundFrame: TSoundFrame
  Left = 0
  Top = 0
  Width = 610
  Height = 77
  AutoScroll = False
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Verdana'
  Font.Style = []
  ParentBackground = False
  ParentFont = False
  TabOrder = 0
  OnResize = FrameResize
  DesignSize = (
    610
    77)
  object sbPlay: TsSpeedButton
    Left = 544
    Top = 32
    Width = 28
    Height = 28
    Anchors = [akTop, akRight]
    OnClick = sbPlayClick
    SkinData.SkinSection = 'SPEEDBUTTON'
  end
  object sbStop: TsSpeedButton
    Left = 576
    Top = 32
    Width = 28
    Height = 28
    Anchors = [akTop, akRight]
    OnClick = sbStopClick
    SkinData.SkinSection = 'SPEEDBUTTON'
  end
  object fePath: TsFilenameEdit
    Left = 8
    Top = 32
    Width = 529
    Height = 28
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Verdana'
    Font.Style = []
    MaxLength = 255
    ParentFont = False
    TabOrder = 0
    OnKeyPress = fePathKeyPress
    BoundLabel.Active = True
    BoundLabel.Caption = #1055#1091#1090#1100' '#1082' '#1079#1074#1091#1082#1086#1074#1086#1084#1091' '#1092#1072#1081#1083#1091':'
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = RUSSIAN_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -17
    BoundLabel.Font.Name = 'Verdana'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclTopLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
    SkinData.SkinSection = 'EDIT'
    GlyphMode.Grayed = False
    Filter = #1047#1074#1091#1082#1086#1074#1099#1077' '#1092#1072#1081#1083#1099'|*.wav|'#1042#1089#1077' '#1092#1072#1081#1083#1099'|*.*'
  end
  object sFrameAdapter1: TsFrameAdapter
    SkinData.SkinSection = 'BARPANEL'
    Left = 280
  end
end
