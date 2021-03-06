unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Platform, FMX.Platform.Win,
  FMX.Objects, FMX.Canvas.GDIP;

type
  TDisplay = record
    funcList: TStringList;
    image: TImage;
  end;

  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Image1Paint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private

  public
    procedure delDisplayF( index: integer );
    procedure freeAllDisplays();
    function addDisplayF(): integer;
    procedure redrawDisplayF( index: integer );
    procedure addDisplayItemF( index: Integer; item: string );

    class procedure showme();
    class procedure closeme();
    class function returnHandle(): integer;
  end;

const
  DEF_ALPHA = 230;

  F_LINE = 1;
  F_TEXT = 50;
  F_FONTSTYLE = 99;

var
  Form1: TForm1;
  dindex: integer;

  FDisplays: array of TDisplay;

function AlphaColorFixer( color: integer ): TAlphaColor;
implementation

{$R *.fmx}

function split(input:string;schar:char;s:integer):string;//zoptymalizowa�, to tylko prototyp
var
   i,n:integer;
   quote, //czy badany znak pochodzi z pomiedzy cudzyslowow
   is_quote, //czy aktualny znak to cudzyslow
   is_schar, //czy aktualny znak to schar i nie pochcodzi z pomi�dzy cudzys�owow
   poprzedni_ok //czy poprzedni znak nale�y do wyrazu
   :boolean;
begin
   n := 1;
   quote := False;
   for i := 1 to length(input) do
   begin
     is_quote := input[i] = '"';
     is_schar := not quote and (input[i] = schar);
     if is_quote or is_schar then
     begin
       if quote or poprzedni_ok then
       begin
         inc(n);
         if n > s then Exit else Result := '';
       end;
       if is_quote then quote := not quote;
       poprzedni_ok := False;
     end else
     begin
       Result := Result + input[i];
       poprzedni_ok := True;
     end;
   end;
   if poprzedni_ok then inc(n); //zwiekszamy n jesli ostatni wyraz nie by� policzony
   if n <= s then Result := ''; //gdy za malo wyraz�w we frazie
end;

function AlphaColorFixer( color: integer ): TAlphaColor;
var
  bytes: array[0..3] of byte;
begin
  bytes[0] := byte(color);
  bytes[1] := byte(color shr 8);
  bytes[2] := byte(color shr 16);
  bytes[3] := byte(color shr 24);

  // je�eli alpha jest 0 wtedy ustawiamy domyslna alphe.
  if bytes[3] = 0 then bytes[3] := DEF_ALPHA;

  result := TAlphaColor( bytes[0] or
                         (bytes[1] shl 8) or
                         (bytes[2] shl 16) or
                         (bytes[3] shl 24) );
end;

function TForm1.addDisplayF(): integer;
var
  res: integer;
begin

  SetLength(FDisplays, length(FDisplays) + 1);

  res := length(FDisplays) - 1;
  //showmessage(inttostr(res));
  FDisplays[res].funcList := TStringList.Create;
  FDisplays[res].funcList.Clear();

  FDisplays[res].image := TImage.Create(nil);
  FDisplays[res].image.Parent := Form1;
  FDisplays[res].image.Tag := res;
  FDisplays[res].image.Align := TAlignLayout.alClient;
  FDisplays[res].image.OnPaint := Form1.Image1Paint;

  result := res;
end;

procedure TForm1.delDisplayF( index: integer );
var
  i: integer;
begin

  // je�eli podajemy z�� warto�� wtedy exit
  if index >= length(FDisplays) then exit;

  // uwalniamy obiekty
  FDisplays[index].funcList.Free;
  FDisplays[index].image.Free;

  // przesuwamy wszystkie obiekty by m�c skr�ci� tablice
  if index = High(FDisplays) then
    SetLength(FDisplays, length(FDisplays) - 1)
  else
  begin
    for i := index to High(FDisplays) - 1 do
      FDisplays[i] := FDisplays[i + 1];
    SetLength(FDisplays, length(FDisplays) - 1);
  end;

end;

procedure TForm1.freeAllDisplays();
var
  i: integer;
begin
  for i := 0 to High(FDisplays) - 1 do
  begin
    FDisplays[i].funcList.Free;
    FDisplays[i].image.Free;
  end;

  SetLength(FDisplays, 0);
end;

procedure TForm1.redrawDisplayF( index: Integer );
begin
  FDisplays[index].image.Repaint;
end;

procedure TForm1.addDisplayItemF( index: Integer; item: string );
begin
  FDisplays[index].funcList.Add( item );
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  FDisplays[dindex].funcList.Add('1:3:55:75:60');
  FDisplays[dindex].funcList.Add('99:"Tahoma":30:'+inttostr($FF0000));
  FDisplays[dindex].funcList.Add('50:100:100:"dupa asd adasd : asd asda"');
  FDisplays[dindex].image.Repaint;

  timer1.Enabled := false;
end;

class procedure TForm1.showme();
begin
  // musi by� tak by by�o AA
  Application.Initialize;
  Application.CreateForm( TForm1, Form1 );
  Application.Run;

  // to jest be i fuj bo nie ma AA
  //Form1 := TForm1.Create(Application);
  //Form1.Show;
end;

class procedure TForm1.closeme(); // nie dziala, uzywam killprocess w hostapp
begin
  showmessage('asd');
  // brzydki hack zwalniania wszystkiego
  //Form1.Free;
  //Application.HandleMessage();
  //Application.Terminate;
  //Application.HandleMessage();
  //Application.Free;
end;

class function TForm1.returnHandle(): integer;
begin
  result := FmxHandleToHWND(Form1.Handle);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  canclose := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  p: TPointF;
begin
  //showmessage('asd');
  // sprawdzi�!!!
  //SetWindowLong(Me.Handle.ToInt32, GWL_EXSTYLE, GetWindowLong(Me.Handle.ToInt32, WS_EXSTYLE) Or WS_EX_TRANSPARENT)

  p := Platform.GetScreenSize();
  form1.ClientWidth := round(p.X);
  form1.ClientHeight := round(p.Y);

  //dindex := addDisplayF();
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  freeAllDisplays();
end;

procedure TForm1.Image1Paint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  r:trectF;
  p1,p2: tpointf;
  i: integer;
  line, tmp: string;
begin

  Canvas.Stroke.Kind := TBrushKind.bkSolid;
  Canvas.Stroke.Color := claBlack;
  Canvas.StrokeThickness := 1;
  Canvas.Fill.Color := clablack;
  if FDisplays[ (Sender as TImage).Tag ].funcList.Count > 0 then
  begin
    for i := 0 to FDisplays[ (Sender as TImage).Tag ].funcList.Count -1 do
    begin
      line := 'kurwa:' + FDisplays[ (Sender as TImage).Tag ].funcList[i];
      //showmessage(line);
      case strtoint(split(line, ':', 2)) of
        F_LINE:
          begin
            p1.Create( strtoint(split(line, ':', 3)), strtoint(split(line, ':', 4)) );
            p2.Create( strtoint(split(line, ':', 5)), strtoint(split(line, ':', 6)) );
            Canvas.DrawLine(p1,p2,1);
          end;

        F_TEXT:
          begin
            tmp := split(line, ':', 5);
            r.Left := strtoint(split(line, ':', 3));
            r.Top := strtoint(split(line, ':', 4));
            r.Right := r.Left + Canvas.TextWidth( tmp );
            r.Bottom := r.Top + Canvas.TextHeight( tmp );

            Canvas.FillText(r, tmp, false, 1, [TFillTextFlag.ftRightToLeft], TTextAlign.taCenter, TTextAlign.taCenter);
          end;

          F_FONTSTYLE:
            begin
             // showmessage(split(line, ':', 3));
              Canvas.Font.Family := split(line, ':', 3);
              Canvas.Font.Size := strtoint(split(line, ':', 4));
              Canvas.Fill.Color := AlphaColorFixer(strtoint(split(line, ':', 5)));
              Canvas.Font.Style := Canvas.Font.Style + [TFontStyle.fsBold];
            end;


      end;

    end;

    FDisplays[ (Sender as TImage).Tag ].funcList.Clear;
  end;
end;

end.
