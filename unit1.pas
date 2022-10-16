unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LazFileUtils,
  LazUTF8;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private

  public
    function BreakingText(Sender: TStrings; aLineLen: PtrUInt;
                          LineBreakStr: String = sLineBreak): Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  ms: TMemoryStream = nil;
  SL_src: TStringList = nil;
begin
  ms:= TMemoryStream.Create;
  SL_src:= TStringList.Create;
  try
    ms.Clear;

    //ms.LoadFromFile(CleanAndExpandDirectory('./../..') + 'example.txt');
    ms.LoadFromFile(CleanAndExpandDirectory('./../..') + 'example_rus.txt');
    ms.Position:= 0;
    SL_src.LoadFromStream(ms);
    Memo1.Clear;

    if BreakingText(SL_src,42)
      then Memo1.Lines.Assign(SL_src)
      else Memo1.Lines.Text:= 'Не получилось';
  finally
    FreeAndNil(SL_src);
    FreeAndNil(ms);
  end;
end;

function TForm1.BreakingText(Sender: TStrings; aLineLen: PtrUInt;
  LineBreakStr: String): Boolean;
var
  CharCount: PtrInt = 0;//кол-во символов, которые надо скопировать
  TotalLen: PtrInt = 0;//общая длина текста
  PrevPos: PtrInt = 1;
  StartPos: PtrInt = 1;
  CurrPos: PtrInt = 0;
  BreakTextLen: PtrInt = 0;//длина разделителя строк
  SL: TStringList = nil;
begin
  Result:= True;
  SL:= TStringList.Create;
  try
    SL.Assign(TStrings(Sender));
    SL.LineBreak:= LineBreakStr;

    PrevPos:= 1;
    StartPos:= 1;
    CharCount:= 0;
    CurrPos:= 0;
    TotalLen:= UTF8Length(SL.Text);
    BreakTextLen:= UTF8Length(LineBreakStr);
    TStrings(Sender).Clear;

    while (UTF8Pos(' ',SL.Text,StartPos) > 0) do
    begin
      CurrPos:= UTF8Pos(' ',SL.Text,StartPos) ;

      if ((CurrPos - PrevPos) <= aLineLen) //строка с очередным пробелом меньше длины строки
      then
        begin
          if ((TotalLen - CurrPos) < aLineLen) then //оставшийся текст меньше длины строки
          begin
            //в последней строке обычно остается начальный пробел
            if (UTF8Pos(' ',UTF8Copy(SL.Text,CurrPos, TotalLen - CurrPos)) = 1)
              then CurrPos:= CurrPos + UTF8Length(' ');

            //оставшийся текст содержит символ разбивки строки
            if (UTF8Pos(LineBreakStr, UTF8Copy(SL.Text,CurrPos, TotalLen - CurrPos)) > 0)
            then
              begin
                StartPos:= UTF8Pos(LineBreakStr, UTF8Copy(SL.Text,CurrPos, TotalLen - CurrPos));
                TStrings(Sender).Add(UTF8Copy(SL.Text,CurrPos, StartPos - BreakTextLen));
              end
            else
              TStrings(Sender).Add(UTF8Copy(SL.Text,CurrPos, TotalLen - CurrPos));
            Break;
          end;

          CharCount:= (CurrPos - PrevPos);
          StartPos:= CurrPos + UTF8Length(' ');
        end
      else {(CurrPos - PrevPos) > aLineLen}
        begin
          if (UTF8Pos(LineBreakStr, UTF8Copy(SL.Text,PrevPos,CharCount)) > 0)
          then
            begin
              StartPos:= UTF8Pos(LineBreakStr, SL.Text,PrevPos);
              if (UTF8Copy(SL.Text,StartPos,BreakTextLen) = LineBreakStr) then
                begin
                  if (StartPos < (TotalLen - BreakTextLen))
                    then
                      Inc(StartPos, BreakTextLen)
                    else
                      Break
                    ;
                end;

              CharCount:= StartPos - PrevPos;
              TStrings(Sender).Add(UTF8Copy(SL.Text,PrevPos,CharCount - BreakTextLen));
            end
          else
            TStrings(Sender).Add(UTF8Copy(SL.Text,PrevPos,CharCount));

          //длина разбивки строки меньше, чем длина очередного слова
          if (PrevPos = StartPos) then
          begin
            TStrings(Sender).Assign(SL);
            Result:= False;
            Break;
          end;

          PrevPos:= StartPos;
        end;
    end;

  finally
    SL.Free;
  end;
end;

end.

