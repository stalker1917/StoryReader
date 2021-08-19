unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg,Translator, Vcl.Imaging.pngimage;

type
  TForm3 = class(TForm)
    Image1: TImage;
    LabeledEdit1: TLabeledEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Image2: TImage;
    Label35: TLabel;
   // procedure Button1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label35Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
TRegion = record
Host : Byte; // 0 - нейтрал  1- змея  2- лучи 3-смерть
Combo : String;
Neighbors : Array {[0..10]} of Byte;  //Нулевой регион- никакой
end;

const
RegCount = 33;

var
  Form3: TForm3;
  NextStation : Byte = 0;
  Map : Array of TRegion;
  Turns : Byte=7;
  F:Text;
  Regions : Array[1..3] of Array of Byte;
  Labels : Array[1..RegCount] of TLabel;
  ClipMode : Boolean = False;
  ValidClose : Boolean = False;

procedure MapLoad(S:String);
Procedure Expansion(Color:Byte);
Procedure PutRegion(N,Color : Byte);
Procedure LoseRegion(N:Byte);
procedure ResetMap;

implementation

{$R *.dfm}

procedure MapLoad;
var
i,Count:Word;
a,N:longword;
begin
  Assignfile(f,s); //Список операторов
  Reset(f);
  Readln(f,Count);
  SetLength(Map,Count+1);
  //for i := 1 to Count do
  while not eof(f) do
    begin
      Read(f,N);
      Map[N].Host := 0;
      Read(f,a);
      Map[N].Combo := IntToStr(a);
      SetLength(Map[N].Neighbors,0);
      while not Eoln(f) do
        begin
          SetLength(Map[N].Neighbors,Length(Map[N].Neighbors)+1);
          Read(f,Map[N].Neighbors[High(Map[N].Neighbors)]);
        end;
      Readln(f);
    end;
  CloseFile(f);
  for i := 1 to 3 do SetLength(Regions[i],0);
end;

procedure ResetMap;
var i:Integer;
begin
  for I := 1 to 3 do SetLength(Regions[i],0);
  Turns       := 7;
  NextStation := 0;
  for I := 1 to 33 do Labels[i].Font.Color := clBlack;
  Form3.Label34.Caption:='Осталось ходов: '+IntToStr(Turns);
  for I := 0 to High(Map) do  Map[i].Host := 0;

end;

Procedure LoseRegion;
var i,j :Integer;
begin
  for i:=2 to 3 do
    for j := 0 to High(Regions[i]) do
      if Regions[i,j]=N then
        begin
          Regions[i,j] := Regions[i,High(Regions[i])];
          SetLength(Regions[i],Length(Regions[i])-1);
          exit;
        end;
end;

Function FindNeighbor(A:Byte; Color:Byte):Boolean;
var i :Integer;
begin
  Result:=False;
  for i := 0 to High(Map[A].Neighbors) do if Map[Map[A].Neighbors[i]].Host=Color then  Result:=True;
end;

Procedure PutRegion;
begin
   Map[N].Host := Color;
   SetLength(Regions[Color],Length(Regions[Color])+1);
   Regions[Color,High(Regions[Color])] := N;
   case Color of
      1: Labels[N].Font.Color := ClRed;
      2: Labels[N].Font.Color := ClGreen;
      3: Labels[N].Font.Color := ClBlue;
   end;
end;

Procedure Expansion(Color:Byte);
var i,j,k :Integer;
Neg : Array of Byte;
Coincedince : Boolean;
begin
  if Length(Regions[Color])=0 then
    begin
      repeat
        i := Random(RegCount)+1;
      until  Map[i].Host=0;
      PutRegion(i,Color);
      // if then   //Ставим нужную карту
    end
  else
    begin
      SetLength(Neg,0);
        for I := 0 to High(Regions[Color]) do
          for j := 0 to High(Map[Regions[Color,i]].Neighbors) do
            begin
              Coincedince := False;
              for k := 0 to High(Neg) do
                if Neg[k]=Map[Regions[Color,i]].Neighbors[j] then Coincedince := True;
              if (not Coincedince) and (Map[Map[Regions[Color,i]].Neighbors[j]].Host=0)  then
                begin
                  SetLength(Neg,Length(Neg)+1);
                  Neg[High(Neg)] := Map[Regions[Color,i]].Neighbors[j];
                end;
            end;
      if Length(Neg)>0 then
        begin
          i := Random(Length(Neg));  //Проверить на то, что некуда расширятся
          PutRegion(Neg[i],Color);
        end;
      // Neg[i];
    end;
end;
{
procedure TForm3.Button1Click(Sender: TObject);
var
Approved:Boolean;
a:Integer;
begin
Approved:=False;
a := StrToInt(LabeledEdit1.Text);
if Length(Regions[1])=0 then  approved := true
else  if Map[a].Host=1 then approved := false
      else approved := FindNeighbor(a,1);
if ClipMode  then  approved := True;
if approved then
  begin
    NextStation := a; //255 когда кончается ход
    dec(Turns);
    //if Turns=0 then NextStation :=255; //Кончился ход
    Label34.Caption:='Осталось ходов: '+IntToStr(Turns);
    ValidClose := True;
    Form3.Close;
  end;
end;
}

procedure TForm3.FormCreate(Sender: TObject);
begin
   Labels[StrToInt(Label1.Caption)] := Label1;
   Labels[StrToInt(Label2.Caption)] := Label2;
   Labels[StrToInt(Label3.Caption)] := Label3;
   Labels[StrToInt(Label4.Caption)] := Label4;
   Labels[StrToInt(Label5.Caption)] := Label5;
   Labels[StrToInt(Label6.Caption)] := Label6;
   Labels[StrToInt(Label7.Caption)] := Label7;
   Labels[StrToInt(Label8.Caption)] := Label8;
   Labels[StrToInt(Label9.Caption)] := Label9;
   Labels[StrToInt(Label10.Caption)] := Label10;
   Labels[StrToInt(Label11.Caption)] := Label11;
   Labels[StrToInt(Label12.Caption)] := Label12;
   Labels[StrToInt(Label13.Caption)] := Label13;
   Labels[StrToInt(Label14.Caption)] := Label14;
   Labels[StrToInt(Label15.Caption)] := Label15;
   Labels[StrToInt(Label16.Caption)] := Label16;
   Labels[StrToInt(Label17.Caption)] := Label17;
   Labels[StrToInt(Label18.Caption)] := Label18;
   Labels[StrToInt(Label19.Caption)] := Label19;
   Labels[StrToInt(Label20.Caption)] := Label20;
   Labels[StrToInt(Label21.Caption)] := Label21;
   Labels[StrToInt(Label22.Caption)] := Label22;
   Labels[StrToInt(Label23.Caption)] := Label23;
   Labels[StrToInt(Label24.Caption)] := Label24;
   Labels[StrToInt(Label25.Caption)] := Label25;
   Labels[StrToInt(Label26.Caption)] := Label26;
   Labels[StrToInt(Label27.Caption)] := Label27;
   Labels[StrToInt(Label28.Caption)] := Label28;
   Labels[StrToInt(Label29.Caption)] := Label29;
   Labels[StrToInt(Label30.Caption)] := Label30;
   Labels[StrToInt(Label31.Caption)] := Label31;
   Labels[StrToInt(Label32.Caption)] := Label32;
   Labels[StrToInt(Label33.Caption)] := Label33;
   Label34.Caption:='Осталось ходов: '+IntToStr(Turns);
end;

procedure TForm3.Label1Click(Sender: TObject);
begin
  LabeledEdit1.Text := (Sender as TLabel).Caption;
end;

procedure TForm3.Label35Click(Sender: TObject);
var
Approved:Boolean;
a:Integer;
begin
Approved:=False;
a := StrToInt(LabeledEdit1.Text);
if Length(Regions[1])=0 then  approved := true
else  if Map[a].Host=1 then approved := false
      else approved := FindNeighbor(a,1);
if ClipMode  then  approved := True;
if approved then
  begin
    NextStation := a; //255 когда кончается ход
    dec(Turns);
    //if Turns=0 then NextStation :=255; //Кончился ход
    Label34.Caption:='Осталось ходов: '+IntToStr(Turns);
    ValidClose := True;
    Form3.Close;
  end;
end;

end.
