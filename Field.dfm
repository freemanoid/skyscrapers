object FieldForm: TFieldForm
  Left = 419
  Top = -3
  Width = 800
  Height = 750
  Caption = #1053#1077#1073#1086#1089#1082#1088#1105#1073#1099
  Color = clBtnFace
  Constraints.MaxHeight = 750
  Constraints.MaxWidth = 800
  Constraints.MinHeight = 750
  Constraints.MinWidth = 800
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
  object GenerationLabel: TLabel
    Left = 5
    Top = 350
    Width = 151
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = #1043#1077#1085#1077#1088#1072#1094#1080#1103' '#1091#1089#1083#1086#1074#1080#1103
    Transparent = True
  end
  object GenerationProgressBar: TProgressBar
    Left = 5
    Top = 370
    Width = 150
    Height = 17
    Smooth = True
    TabOrder = 4
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
  object GenerationPanel: TPanel
    Left = 5
    Top = 225
    Width = 161
    Height = 111
    TabOrder = 5
    object DiffucaltyLabel: TLabel
      Left = 0
      Top = 18
      Width = 151
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = #1059#1088#1086#1074#1077#1085#1100' '#1089#1083#1086#1078#1085#1086#1089#1090#1080
    end
    object NewFieldButton: TButton
      Left = 0
      Top = 66
      Width = 156
      Height = 25
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1087#1086#1083#1077
      TabOrder = 0
      OnClick = NewFieldButtonClick
    end
    object DiffucaltyTrackBar: TTrackBar
      Left = 0
      Top = 30
      Width = 150
      Height = 31
      Max = 3
      Min = 1
      ParentShowHint = False
      Position = 1
      ShowHint = True
      TabOrder = 1
      OnChange = DiffucaltyTrackBarChange
    end
  end
  object ExitButton: TButton
    Left = 30
    Top = 495
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 6
    OnClick = ExitButtonClick
  end
  object MainMenu: TMainMenu
    Top = 675
    object MainMenuItemFile: TMenuItem
      Caption = #1060#1072#1081#1083
      object SaveConditionMenuItem: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1091#1089#1083#1086#1074#1080#1077
        OnClick = SaveConditionMenuItemClick
      end
      object SaveFieldMenuItem: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1087#1086#1083#1077
        OnClick = SaveFieldMenuItemClick
      end
      object OpenConditionMenuItem: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1091#1089#1083#1086#1074#1080#1077
        OnClick = OpenConditionMenuItemClick
      end
      object OpenFieldMenuItem: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1087#1086#1083#1077
        OnClick = OpenFieldMenuItemClick
      end
      object ExitMenuItem: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = ExitMenuItemClick
      end
    end
    object N1: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object HelpMenuItem: TMenuItem
        Caption = #1057#1087#1088#1072#1074#1082#1072
        OnClick = HelpMenuItemClick
      end
      object AboutMenuItem: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
        OnClick = AboutMenuItemClick
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
  object GenerationTimer: TTimer
    Enabled = False
    OnTimer = GenerationTimerTimer
    Left = 130
    Top = 675
  end
end
