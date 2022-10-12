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
    procedure FormatText(Sender: TStringList; aBreakLine: String; aStrLen: PtrInt);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
const
  len = 50;
  LineBreakText = '#0';
var
  ms: TMemoryStream = nil;
  CharCount: PtrInt = 0;//кол-во символов, которые надо скопировать
  RemainLen: PtrInt = 0;//остаточная длина строки
  PrevPos: PtrInt = 1;
  StartPos: PtrInt = 1;
  CurrPos: PtrInt = 0;
  BreakTextLen: PtrInt = 0;

  SL_src: TStringList = nil;
  SL_dest: TStringList = nil;
  SB: TStringBuilder = nil;
  {$IFDEF MSWINDOWS}
  str1: RawByteString = '';
  str2: RawByteString = '';
  {$ELSE}
  str1: String = '';
  str2: String = '';
  {$ENDIF}
  i: Integer;
begin
  ms:= TMemoryStream.Create;
  SL_src:= TStringList.Create;
  SL_dest:= TStringList.Create;
  SB:= TStringBuilder.Create;
  try
    ms.Clear;
    ms.LoadFromFile('example.txt');
    ms.Position:= 0;
    SL_src.LoadFromStream(ms);

    SL_src.LineBreak:= sLineBreak;
    SL_src.Text:= UTF8StringReplace(SL_src.Text,sLineBreak,LineBreakText,[rfReplaceAll, rfIgnoreCase]);

    for i:= 0 to Pred(SL_src.Count) do
      SB.Append(SL_src.Strings[i]);

    SB.;
    Memo1.Clear;

    Memo1.Text:= SB.ToString;
    Memo1.Lines.Insert(0, '====== SB.ToString ======');
    Memo1.Lines.Add('');

    //Memo1.Lines.Add('====== SL_src.CommaText ======');
    //Memo1.Lines.Add(SL_src.CommaText);
    //Memo1.Lines.Add('====== SL_src.DelimitedText ======');
    //Memo1.Lines.Add(SL_src.DelimitedText);
    //Memo1.Lines.Add('====== SL_src.Text ======');
    //Memo1.Lines.Add(SL_src.Text);
    //
    //Memo1.Lines.Add('');
    Memo1.Lines.Add('====== lines by ' + IntToStr(len) + ' char ======');
    PrevPos:= 1;
    StartPos:= 1;
    RemainLen:= UTF8Length(SL_src.Text);
    BreakTextLen:= UTF8Length(LineBreakText);

    while (UTF8Pos(' ',SL_src.Text,StartPos) > 0) do
    begin
      CurrPos:= UTF8Pos(' ',SL_src.Text,StartPos);

      if ((CurrPos - PrevPos) < len)
      then
        begin
          if ((RemainLen - CurrPos) < len) then
          begin
            str1:= UTF8Copy(SL_src.Text,CurrPos, RemainLen - CurrPos);
            SL_dest.Add(str1);
            Break;
          end;

          CharCount:= (CurrPos - PrevPos);
          StartPos:= Succ(CurrPos);
        end
      else
        if ((CurrPos - PrevPos) >= len)
        then
          begin
            //CharCount:= (CurrPos - PrevPos);
            str1:= UTF8Copy(SL_src.Text,PrevPos,CharCount);

            (*----------------*)

            if (UTF8Pos(LineBreakText, str1) > 0)
            then
              begin
                StartPos:= UTF8Pos(LineBreakText, SL_src.Text,PrevPos);
                //CharCount:= StartPos - PrevPos;
                //str2:= UTF8Copy(SL_src.Text,PrevPos,CharCount);
                //SL_dest.Add(str2);
                //PrevPos:= StartPos;
                //StartPos:= Succ(StartPos);

                while (
                  (UTF8Pos(LineBreakText, SL_src.Text, StartPos) > 0)
                    and (UTF8Copy(SL_src.Text,StartPos,BreakTextLen) = LineBreakText)
                      ) do
                begin
                  //SL_dest.Text:= SL_dest.Text + LineBreakText;
                  StartPos:= UTF8Pos(LineBreakText, SL_src.Text, StartPos) + BreakTextLen;
                end;

                CharCount:= StartPos - PrevPos;
                str2:= UTF8Copy(SL_src.Text,PrevPos,CharCount);
                SL_dest.Add(str2);

                PrevPos:= StartPos;
                //StartPos:= Succ(StartPos);
              end
            else
            (*----------------*)
              begin
                SL_dest.Add(str1);
                PrevPos:= StartPos;
              end;
          end;
    end;

    SL_dest.Text:= UTF8StringReplace(SL_dest.Text,LineBreakText,sLineBreak,[rfReplaceAll, rfIgnoreCase]);

    for i:= 0 to Pred(SL_dest.Count) do
      Memo1.Lines.Add(SL_dest.Strings[i]);


  finally
    FreeAndNil(SB);
    FreeAndNil(SL_dest);
    FreeAndNil(SL_src);
    FreeAndNil(ms);
  end;
end;

procedure TForm1.FormatText(Sender: TStringList; aBreakLine: String;
  aStrLen: PtrInt);
begin

end;

end.

