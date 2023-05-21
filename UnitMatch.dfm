object FormFuzzy: TFormFuzzy
  Left = 193
  Top = 108
  Caption = 'String Fuzzy Match Demo'
  ClientHeight = 650
  ClientWidth = 1203
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  TextHeight = 14
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1203
    Height = 51
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 1199
    object lblSearch: TLabel
      Left = 16
      Top = 14
      Width = 41
      Height = 14
      Caption = 'Search:'
    end
    object Chk_CaseSensitive: TCheckBox
      Left = 432
      Top = 14
      Width = 97
      Height = 17
      Caption = 'Case Sensitive'
      TabOrder = 0
      OnClick = Edt_SearchChange
    end
    object Edt_Search: TEdit
      Left = 64
      Top = 12
      Width = 353
      Height = 22
      TabOrder = 1
      OnChange = Edt_SearchChange
    end
    object Chk_FuzzyMatch: TCheckBox
      Left = 543
      Top = 14
      Width = 90
      Height = 17
      Caption = 'Fuzzy Match'
      Checked = True
      Color = clLime
      Ctl3D = True
      DoubleBuffered = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentCtl3D = False
      ParentDoubleBuffered = False
      ParentFont = False
      State = cbChecked
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 51
    Width = 1203
    Height = 599
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 1199
    ExplicitHeight = 598
    object DBGrid1: TDBGrid
      Left = 1
      Top = 1
      Width = 1201
      Height = 597
      Align = alClient
      DataSource = DataSource1
      TabOrder = 0
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnDrawColumnCell = DBGrid1DrawColumnCell
      Columns = <
        item
          Expanded = False
          FieldName = 'ProductID'
          Width = 68
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Name'
          Width = 175
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ProductModel'
          Width = 180
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CultureID'
          Width = 65
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Description'
          Width = 680
          Visible = True
        end>
    end
  end
  object DataSource1: TDataSource
    DataSet = ADOTable1
    Left = 696
    Top = 8
  end
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Password="";Data Source=D:\Proj' +
      'ect\My Projects\Delphi\Rio\Component\FuzzyMatch\Sample.txt;Mode=' +
      'ReadWrite|Share Deny None;Persist Security Info=True'
    LoginPrompt = False
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 848
    Top = 8
  end
  object ADOTable1: TADOTable
    Connection = ADOConnection1
    OnFilterRecord = ADOTable1FilterRecord
    Left = 768
    Top = 8
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 250
    Left = 848
    Top = 152
  end
end
