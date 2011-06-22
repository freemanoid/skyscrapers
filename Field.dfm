object FieldForm: TFieldForm
  Left = 404
  Top = -6
  Width = 866
  Height = 754
  Caption = #1043#1086#1083#1086#1074#1086#1083#1086#1084#1082#1072' "'#1085#1077#1073#1086#1089#1082#1088#1105#1073#1099'"'
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
  object DiffucaltyLabel: TLabel
    Left = 10
    Top = 250
    Width = 151
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = #1059#1088#1086#1074#1077#1085#1100' '#1089#1083#1086#1078#1085#1086#1089#1090#1080
  end
  object FieldSizeSpinEdit: TSpinEdit
    Left = 10
    Top = 35
    Width = 76
    Height = 22
    EditorEnabled = False
    MaxValue = 6
    MinValue = 4
    TabOrder = 0
    Value = 4
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
  object NewFieldButton: TButton
    Left = 5
    Top = 310
    Width = 156
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1087#1086#1083#1077
    TabOrder = 4
    OnClick = NewFieldButtonClick
  end
  object DiffucaltyTrackBar: TTrackBar
    Left = 10
    Top = 265
    Width = 150
    Height = 31
    Max = 3
    Min = 1
    ParentShowHint = False
    Position = 1
    ShowHint = True
    TabOrder = 5
    OnChange = DiffucaltyTrackBarChange
  end
  object MainMenu: TMainMenu
    Top = 675
    object MainMenuItemFile: TMenuItem
      Caption = #1060#1072#1081#1083
      object SaveCondition: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1091#1089#1083#1086#1074#1080#1077
        OnClick = SaveConditionClick
      end
      object SaveField: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1087#1086#1083#1077
        OnClick = SaveFieldClick
      end
      object OpenCondition: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1091#1089#1083#1086#1074#1080#1077
        OnClick = OpenConditionClick
      end
      object OpenField: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1087#1086#1083#1077
        OnClick = OpenFieldClick
      end
      object Exit: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = ExitClick
      end
    end
    object N1: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object N2: TMenuItem
        Caption = #1057#1087#1088#1072#1074#1082#1072
      end
      object N3: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      end
    end
  end
  object OpenFieldDialog: TOpenDialog
    DefaultExt = 'skf'
    Filter = 'skyscraper field (*.skf)|*.skf'
    InitialDir = 'fields'
    Left = 75
    Top = 675
  end
  object SaveFieldDialog: TSaveDialog
    DefaultExt = 'skf'
    Filter = 'skyscraper field (*.skf)|*.skf'
    InitialDir = 'fields'
    Left = 25
    Top = 675
  end
  object OpenConditionDialog: TOpenDialog
    DefaultExt = 'skc'
    Filter = 'skyscraper condition (*.skc)|*.skc'
    Left = 100
    Top = 675
  end
  object SaveConditionDialog: TSaveDialog
    DefaultExt = 'skc'
    Filter = 'skyscraper condition (*.skc)|*.skc'
    InitialDir = 'conditions'
    Left = 50
    Top = 675
  end
end
