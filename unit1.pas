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
    procedure BreakingText(Sender: TStrings; aLineLen: PtrUInt; LineBreakStr: String = sLineBreak);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
const
  len = 10;
  //LineBreakText = '~';
  LineBreakText = sLineBreak;
var
  ms: TMemoryStream = nil;
  CharCount: PtrInt = 0;//кол-во символов, которые надо скопировать
  TotalLen: PtrInt = 0;//общая длина текста
  PrevPos: PtrInt = 1;
  StartPos: PtrInt = 1;
  CurrPos: PtrInt = 0;
  BreakTextLen: PtrInt = 0;//длина разделителя строк

  SL_src: TStringList = nil;
  SL_dest: TStringList = nil;
  str1: String = '';
  str2: String = '';

  i: Integer;
begin
  ms:= TMemoryStream.Create;
  SL_src:= TStringList.Create;
  SL_dest:= TStringList.Create;
  try
    ms.Clear;

    //ms.LoadFromFile(CleanAndExpandDirectory('./../..') + 'example.txt');
    ms.LoadFromFile(CleanAndExpandDirectory('./../..') + 'example_rus.txt');
    ms.Position:= 0;
    SL_src.LoadFromStream(ms);
    Memo1.Clear;
//
//    SL_src.LineBreak:= sLineBreak;
//    //SL_src.Text:= UTF8StringReplace(SL_src.Text,sLineBreak,LineBreakText,[rfReplaceAll, rfIgnoreCase]);
//
//    Memo1.Clear;
//
//    Memo1.Lines.Add('====== SL_src.Text ======');
//    Memo1.Lines.Add(SL_src.Text);
//
//    Memo1.Lines.Add('');
//    Memo1.Lines.Add('====== lines by ' + IntToStr(len) + ' char ======');
//    PrevPos:= 1;
//    StartPos:= 1;
//    TotalLen:= UTF8Length(SL_src.Text);
//    BreakTextLen:= UTF8Length(LineBreakText);
//
//    while (UTF8Pos(' ',SL_src.Text,StartPos) > 0) do
//    begin
//      CurrPos:= UTF8Pos(' ',SL_src.Text,StartPos);
//
//      if ((CurrPos - PrevPos) < len) //строка с очередным пробелом меньше длины строки
//      then
//        begin
//          if ((TotalLen - CurrPos) < len) then //оставшийся текст меньше длины строки
//          begin
//            str1:= UTF8Copy(SL_src.Text,CurrPos, TotalLen - CurrPos);
//
//            if (UTF8Pos(LineBreakText, str1) > 0) //оставшийся текст содержит символ разбивки строки
//            then
//              begin
//                StartPos:= UTF8Pos(LineBreakText, str1);
//                str2:= UTF8Copy(SL_src.Text,CurrPos, StartPos - BreakTextLen);
//                SL_dest.Add(str2);
//              end
//            else
//              SL_dest.Add(str1);
//
//            Break;
//          end;
//
//          CharCount:= (CurrPos - PrevPos);
//          StartPos:= Succ(CurrPos);
//        end
//      else
//        if ((CurrPos - PrevPos) >= len)
//        then
//          begin
//            str1:= UTF8Copy(SL_src.Text,PrevPos,CharCount);
//
//            if (UTF8Pos(LineBreakText, str1) > 0)
//            then
//              begin
//                StartPos:= UTF8Pos(LineBreakText, SL_src.Text,PrevPos);
//
//                if (UTF8Copy(SL_src.Text,StartPos,BreakTextLen) = LineBreakText) then
//                  begin
//                    if (StartPos < (TotalLen - BreakTextLen))
//                      then
//                        Inc(StartPos, BreakTextLen)
//                      else
//                        Break
//                      ;
//                  end;
//
//                CharCount:= StartPos - PrevPos;
//                str2:= UTF8Copy(SL_src.Text,PrevPos,CharCount - BreakTextLen);
//                SL_dest.Add(str2);
//              end
//            else
//                SL_dest.Add(str1);
//
//            PrevPos:= StartPos;
//          end;
//    end;
//
//    //SL_dest.Text:= UTF8StringReplace(SL_dest.Text,LineBreakText,sLineBreak,[rfReplaceAll, rfIgnoreCase]);
//
//    //for i:= 0 to Pred(SL_dest.Count) do
//    //  Memo1.Lines.Add(SL_dest.Strings[i]);
//    Memo1.Lines.Assign(SL_dest);
      BreakingText(SL_src,9);
      Memo1.Lines.Assign(SL_src);

  finally
    FreeAndNil(SL_dest);
    FreeAndNil(SL_src);
    FreeAndNil(ms);
  end;
end;

procedure TForm1.BreakingText(Sender: TStrings; aLineLen: PtrUInt;
  LineBreakStr: String);
var
  CharCount: PtrInt = 0;//кол-во символов, которые надо скопировать
  TotalLen: PtrInt = 0;//общая длина текста
  PrevPos: PtrInt = 1;
  StartPos: PtrInt = 1;
  CurrPos: PtrInt = 0;
  BreakTextLen: PtrInt = 0;//длина разделителя строк

  str1: String = '';
  str2: String = '';
  SL: TStringList = nil;
begin
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
      CurrPos:= UTF8Pos(' ',SL.Text,StartPos);

      if ((CurrPos - StartPos) > aLineLen) then ShowMessage('{3}');

      if ((CurrPos - PrevPos) < aLineLen) //строка с очередным пробелом меньше длины строки
      then
        begin
          if ((TotalLen - CurrPos) < aLineLen) then //оставшийся текст меньше длины строки
          begin
            //в последней строке обычно остается начальный пробел
            if (UTF8Pos(' ',UTF8Copy(SL.Text,CurrPos, TotalLen - CurrPos)) = 1)
              then CurrPos:= CurrPos + UTF8Length(' ');

            str1:= UTF8Copy(SL.Text,CurrPos, TotalLen - CurrPos);

            if (UTF8Pos(LineBreakStr, UTF8Copy(SL.Text,CurrPos, TotalLen - CurrPos)) > 0)
            then //оставшийся текст содержит символ разбивки строки
              begin
                StartPos:= UTF8Pos(LineBreakStr, str1);
                str2:= UTF8Copy(SL.Text,CurrPos, StartPos - BreakTextLen);
                TStrings(Sender).Add(str2);
              end
            else
              //TStrings(Sender).Add(str1);
              TStrings(Sender).Add(UTF8Copy(SL.Text,CurrPos, TotalLen - CurrPos));
            Break;
          end;

          CharCount:= (CurrPos - PrevPos);
          StartPos:= CurrPos + UTF8Length(' ');
        end
      else
        if ((CurrPos - PrevPos) >= aLineLen)
        then
          begin
            str1:= UTF8Copy(SL.Text,PrevPos,CharCount);

            if ((CurrPos - StartPos) > aLineLen) then ShowMessage(str1);

            if (UTF8Pos(LineBreakStr, str1) > 0)
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
                str2:= UTF8Copy(SL.Text,PrevPos,CharCount - BreakTextLen);
                TStrings(Sender).Add(str2);
              end
            else
                TStrings(Sender).Add(str1);

            PrevPos:= StartPos;
            StartPos:= CurrPos + UTF8Length(' ');
          end;
    end;

  finally
    SL.Free;
  end;
end;

end.

