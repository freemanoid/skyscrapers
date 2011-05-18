object FieldForm: TFieldForm
  Left = 277
  Top = 0
  Width = 722
  Height = 467
  Caption = #1053#1077#1073#1086#1089#1082#1088#1105#1073#1099
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object FieldSizeLabel: TLabel
    Left = 10
    Top = 15
    Width = 86
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088' '#1087#1086#1083#1103': '
  end
  object FieldSizeSpinEdit: TSpinEdit
    Left = 10
    Top = 35
    Width = 76
    Height = 22
    EditorEnabled = False
    MaxValue = 6
    MinValue = 3
    TabOrder = 0
    Value = 3
    OnChange = FieldSizeSpinEditChange
  end
  object CheckButton: TButton
    Left = 10
    Top = 75
    Width = 76
    Height = 26
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100
    TabOrder = 1
    OnClick = CheckButtonClick
  end
  object TestButton: TButton
    Left = 10
    Top = 125
    Width = 111
    Height = 41
    Caption = #1047#1072#1075#1088#1091#1079#1082#1072' '#1090#1077#1089#1090#1086#1074#1086#1075#1086' '#1091#1089#1083#1086#1074#1080#1103
    TabOrder = 2
    WordWrap = True
    OnClick = TestButtonClick
  end
  object AutoSolutionButton: TButton
    Left = 10
    Top = 195
    Width = 91
    Height = 26
    Caption = #1040#1074#1090#1086#1088#1077#1096#1077#1085#1080#1077
    TabOrder = 3
    OnClick = AutoSolutionButtonClick
  end
end
