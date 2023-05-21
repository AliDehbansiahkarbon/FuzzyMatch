unit UnitMatch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, System.Generics.Collections,
  Vcl.ComCtrls, Data.Win.ADODB;

type
  TFormFuzzy = class(TForm)
    DataSource1: TDataSource;
    Panel1: TPanel;
    Panel2: TPanel;
    lblSearch: TLabel;
    Chk_CaseSensitive: TCheckBox;
    Edt_Search: TEdit;
    Chk_FuzzyMatch: TCheckBox;
    DBGrid1: TDBGrid;
    ADOConnection1: TADOConnection;
    ADOTable1: TADOTable;
    Timer1: TTimer;
    procedure Edt_SearchChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ADOTable1FilterRecord(DataSet: TDataSet; var Accept: Boolean);
  private
    function XPos(APattern, AStr: string; ACaseSensitive: Boolean): Integer;
    function FuzzyMatchStr(const Pattern, Str: string; MatchedIndexes: TList; CaseSensitive: Boolean): Boolean;
    function LowChar(AChar: Char): Char; inline;
    procedure HighlightCellText(AGrid :TDbGrid; const ARect : TRect; Field : TField;  MatchedIndexes : TList; AState:TGridDrawState ; BkColor : TColor = clYellow; SelectedBkColor : TColor = clGray);
    procedure HighlightCellTextFull(AGrid :TDbGrid; const ARect : TRect; Field : TField;  FilterText : string; AState:TGridDrawState ; BkColor : TColor = clYellow; SelectedBkColor : TColor = clGray);
  public
    { Public declarations }
  end;

var
  FormFuzzy: TFormFuzzy;

implementation

{$R *.DFM}

procedure TFormFuzzy.ADOTable1FilterRecord(DataSet: TDataSet; var Accept: Boolean);
begin
  if Chk_FuzzyMatch.Checked then
    Accept := FuzzyMatchStr(Edt_Search.Text, DataSet.FieldByName('Name').AsString, nil, Chk_CaseSensitive.Checked)
  else
    Accept := XPos(Edt_Search.Text, DataSet.FieldByName('Name').AsString, Chk_CaseSensitive.Checked) > 0;

//  Accept := Pos(AnsiLowerCase(Edt_Search.Text), AnsiLowerCase(DataSet.FieldByName('Name').AsString)) > 0;
end;

procedure TFormFuzzy.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  LvPattern, LvValue: string;
  LvMatchedIndexes: TList;
begin
  if not Assigned(Column.Field) then
    Exit;

  if not Chk_FuzzyMatch.Checked then
  begin
    LvPattern := Trim(Edt_Search.Text);
    HighlightCellTextFull(TDBGrid(Sender),Rect, Column.Field, LvPattern, State);
    Exit;
  end;

  DBGrid1.Canvas.Font.Color := clBlack;
  LvMatchedIndexes := TList.Create;

  try
    if (gdFocused in State) then
    begin
      DBGrid1.Canvas.Brush.Color := clBlack;
      DBGrid1.Canvas.Font.Color := clWhite;
    end
    else if Column.Field.DataType in [ftString, ftInteger, ftFloat, ftCurrency, ftMemo, ftWideString, ftLargeint, ftWideMemo, ftLongWord] then
    begin
      LvPattern := Trim(Edt_Search.Text);
      LvValue := Column.Field.AsString;

      if FuzzyMatchStr(LvPattern, LvValue, LvMatchedIndexes, Chk_CaseSensitive.Checked) then
        HighlightCellText(TDBGrid(Sender),Rect, Column.Field, LvMatchedIndexes, State);
    end
    else
      DBGrid1.Canvas.Brush.Color := clWhite;
  finally
    LvMatchedIndexes.Free;
  end;
end;

procedure TFormFuzzy.Edt_SearchChange(Sender: TObject);
begin
  if Trim(Edt_Search.Text).IsEmpty then
    ADOTable1.Filtered := False
  else
  begin
    ADOTable1.Filtered := False;
    ADOTable1.Filtered := True;
  end;

  DBGrid1.Repaint;
end;

procedure TFormFuzzy.FormCreate(Sender: TObject);
var
  LvDataSourcePath: string;
begin
  LvDataSourcePath := ExtractFilePath(Application.ExeName);
  ADOConnection1.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + LvDataSourcePath +
            ';Extended Properties="text;HDR=No;FMT=Delimited";Persist Security Info=False';

  ADOTable1.TableName := 'Sample.csv';
  ADOTable1.Open;
end;

procedure TFormFuzzy.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Ord(key) = 27 then
    Close;
end;

function TFormFuzzy.FuzzyMatchStr(const Pattern: string; const Str: string; MatchedIndexes: TList; CaseSensitive: Boolean): Boolean;
var
  PIdx, SIdx: Integer;
begin
  Result := False;
  if (Pattern = '') or (Str = '') then
    Exit;

  PIdx := 1;
  SIdx := 1;
  if MatchedIndexes <> nil then
    MatchedIndexes.Clear;

  if CaseSensitive then
  begin
    while (PIdx <= Length(Pattern)) and (SIdx <= Length(Str)) do
    begin
      if Pattern[PIdx] = Str[SIdx] then
      begin
        Inc(PIdx);
        if MatchedIndexes <> nil then
          MatchedIndexes.Add(Pointer(SIdx));
      end;
      Inc(SIdx);
    end;
  end
  else
  begin
    while (PIdx <= Length(Pattern)) and (SIdx <= Length(Str)) do
    begin
      if LowChar(Pattern[PIdx]) = LowChar(Str[SIdx]) then
      begin
        Inc(PIdx);
        if MatchedIndexes <> nil then
          MatchedIndexes.Add(Pointer(SIdx));
      end;
      Inc(SIdx);
    end;
  end;
  Result := PIdx > Length(Pattern);
end;

function TFormFuzzy.LowChar(AChar: Char): Char;
begin
  if AChar in ['A'..'Z'] then
    Result := Chr(Ord(AChar) + 32)
  else
    Result := AChar;
end;

function TFormFuzzy.XPos(APattern, AStr: string; ACaseSensitive: Boolean): Integer;
var
  PIdx, SIdx: Integer;
begin
  Result := 0;
  if (APattern.Trim.IsEmpty) or (AStr.Trim.IsEmpty) then
    Exit;

  if ACaseSensitive then
  begin
    PIdx := 1;
    SIdx := 1;
    while (PIdx <= Length(APattern)) and (SIdx <= Length(AStr)) do
    begin
      if APattern[PIdx] = AStr[SIdx] then
      begin
        Inc(PIdx);
        Result := SIdx;
        Break;
      end;
      Inc(SIdx);
    end;
  end
  else
    Result := Pos(LowerCase(APattern), LowerCase(AStr));
end;

procedure TFormFuzzy.HighlightCellText(AGrid :TDbGrid; const ARect : TRect; Field : TField;  MatchedIndexes : TList; AState:TGridDrawState ; BkColor : TColor = clYellow; SelectedBkColor : TColor = clGray);
var
  LvRectArray: array of TRect;
  I, LvPosition, LvOffset: Integer;
  LvHlText, LvDisplayText: string;
begin
  LvDisplayText := Field.AsString;
  SetLength(LvRectArray, MatchedIndexes.Count);

  for I := 0 to Pred(MatchedIndexes.Count) do
  begin
    LvPosition := Integer(MatchedIndexes.Items[I]);
    if LvPosition > 0 then
    begin
      case Field.Alignment of
        taLeftJustify: LvRectArray[I].Left := ARect.Left + AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1, LvPosition - 1)) + 1;

        taRightJustify:
        begin
          LvOffset := AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1, 1)) - 1;
          LvRectArray[I].Left :=  (ARect.Right - AGrid.Canvas.TextWidth(LvDisplayText) - LvOffset) + AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1, LvPosition - 1));
        end;

        taCenter:
        begin
          LvOffset := ((ARect.Right - ARect.Left) div 2) - (AGrid.Canvas.TextWidth(LvDisplayText) div 2) - (AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1, 1)) - 2);
          LvRectArray[I].Left := (ARect.Right - AGrid.Canvas.TextWidth(LvDisplayText) - LvOffset) + AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1, LvPosition - 1));
        end;
      end;

      LvRectArray[I].Top := ARect.Top + 1;
      LvRectArray[I].Right := LvRectArray[I].Left + AGrid.Canvas.TextWidth(Copy(LvDisplayText, LvPosition, length(LvDisplayText[LvPosition]))) + 1 ;
      LvRectArray[I].Bottom := ARect.Bottom - 1;

      if LvRectArray[I].Right > ARect.Right then  //check for  limitation of the cell
        LvRectArray[I].Right := ARect.Right;

      if gdSelected in AState then // Setup the color and draw the rectangle in a width of the matching text
        AGrid.Canvas.Brush.Color := SelectedBkColor
      else
        AGrid.Canvas.Brush.Color := BkColor;

      AGrid.Canvas.FillRect(LvRectArray[I]);
      LvHlText := Copy(LvDisplayText,LvPosition, length(LvDisplayText[LvPosition]));
      AGrid.Canvas.TextRect(LvRectArray[I], LvRectArray[I].Left + 1, LvRectArray[I].Top + 1, LvHlText);
    end;
  end;
end;

procedure TFormFuzzy.HighlightCellTextFull(AGrid: TDbGrid; const ARect: TRect; Field: TField; FilterText: string; AState: TGridDrawState ; BkColor : TColor = clYellow; SelectedBkColor : TColor = clGray);
var
  LvHlRect: TRect;
  LvPosition, LvOffset: Integer;
  LvHlText, LvDisplayText: string;
begin
  LvDisplayText := Field.AsString;
  LvPosition := Pos(AnsiLowerCase(FilterText), AnsiLowerCase(LvDisplayText));

  if LvPosition > 0 then
  begin
    case Field.Alignment of
      taLeftJustify: LvHlRect.Left := ARect.Left + AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1, LvPosition - 1)) + 1;

      taRightJustify:
      begin
        LvOffset := AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1,1)) - 1;
        LvHlRect.Left :=  (ARect.Right - AGrid.Canvas.TextWidth(LvDisplayText) - LvOffset) + AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1, LvPosition - 1));
      end;

      taCenter:
      begin
       LvOffset := ((ARect.Right - ARect.Left) div 2) - (AGrid.Canvas.TextWidth(LvDisplayText) div 2) - (AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1,1)) - 2);
       LvHlRect.Left := (ARect.Right - AGrid.Canvas.TextWidth(LvDisplayText) - LvOffset) + AGrid.Canvas.TextWidth(Copy(LvDisplayText, 1, LvPosition - 1));
      end;
    end;

    LvHlRect.Top    := ARect.Top + 1;
    LvHlRect.Right  := LvHlRect.Left + AGrid.Canvas.TextWidth(Copy(LvDisplayText, LvPosition, Length(FilterText))) + 1 ;
    LvHlRect.Bottom := ARect.Bottom - 1;

    if LvHlRect.Right > ARect.Right then  //check for  limit of the cell
      LvHlRect.Right := ARect.Right;

    if gdSelected in AState then  // setup the color and draw the rectangle in a width of the matching text
      AGrid.Canvas.Brush.Color := SelectedBkColor
    else
      AGrid.Canvas.Brush.Color := BkColor;

    AGrid.Canvas.FillRect(LvHlRect);
    LvHlText := Copy(LvDisplayText,LvPosition, Length(FilterText));
    AGrid.Canvas.TextRect(LvHlRect,LvHlRect.Left + 1, LvHlRect.Top + 1, LvHlText);
  end;
end;
end.
