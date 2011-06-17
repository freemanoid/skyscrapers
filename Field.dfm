object FieldForm: TFieldForm
  Left = 278
  Top = -1
  Width = 866
  Height = 754
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  Menu = MainMenu
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
    Width = 96
    Height = 26
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100
    TabOrder = 1
    OnClick = CheckButtonClick
  end
  object AutoSolutionButton: TButton
    Left = 10
    Top = 110
    Width = 96
    Height = 26
    Caption = #1040#1074#1090#1086#1088#1077#1096#1077#1085#1080#1077
    TabOrder = 2
    OnClick = AutoSolutionButtonClick
  end
  object ClearButton: TButton
    Left = 10
    Top = 145
    Width = 96
    Height = 25
    Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1087#1086#1083#1077
    TabOrder = 3
    OnClick = ClearButtonClick
  end
  object Button1: TButton
    Left = 10
    Top = 180
    Width = 96
    Height = 41
    Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' (really)'
    TabOrder = 4
    WordWrap = True
    OnClick = Button1Click
  end
  object NewFieldButton: TButton
    Left = 10
    Top = 240
    Width = 96
    Height = 25
    Caption = #1053#1086#1074#1086#1077' '#1087#1086#1083#1077
    TabOrder = 5
    OnClick = NewFieldButtonClick
  end
  object MainMenu: TMainMenu
    Top = 670
    object File1: TMenuItem
      Caption = #1060#1072#1081#1083
      object Open: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1091#1089#1083#1086#1074#1080#1077
        OnClick = OpenClick
      end
    end
  end
  object OpenDialog: TOpenDialog
    Filter = '*.sks'
    InitialDir = 'cond'
    Left = 30
    Top = 670
  end
end
