unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Vcl.ExtCtrls,Translator,JPEG,Unit2,Unit3,
  Vcl.Imaging.pngimage,math, Vcl.MPlayer, Vcl.Buttons, Vcl.ComCtrls, MMSystem;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Memo1: TMemo;
    Image1: TImage;
    Button6: TButton;
    Edit2: TEdit;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    MediaPlayer1: TMediaPlayer;
    BitBtn1: TBitBtn;
    TrackBar1: TTrackBar;
    Timer1: TTimer;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StartTranslate;
    procedure LabelsShow;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure MediaPlayer1Notify(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
//TDices = Array[0..6] of Byte;

var
  Form1: TForm1;
  GameStage:Integer = 0;
  //Buttons : Array [0..4] of TButton;
  Labels  : Array [0..5] of TLabel;
  Images  : Array [1..4] of TImage;
  Cheat : Integer = 0;
  iddqdMode : Boolean = False;  //Все битвы автоматически выигрываются.
  FullScreen : Boolean=False;
  TextTimer : Boolean=False;
  TextPosition : LongWord = 1;
  LinePosition : LongWord = 0;
  ByWords : Boolean = False;
  SmallFont : Integer = 10;
  BigFont : Integer = 15;
  Center : Boolean = False;
procedure SetVolume(const volL, volR: Word);

implementation

{$R *.dfm}


procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  CurrentBlock := Blocks[CurrentBlock].Next[0].N;
  StartTranslate;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  CurrentBlock := Blocks[CurrentBlock].Next[1].N;
  StartTranslate;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  CurrentBlock := Blocks[CurrentBlock].Next[2].N;
  StartTranslate;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  CurrentBlock := Blocks[CurrentBlock].Next[3].N;
  StartTranslate;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  CurrentBlock := Blocks[CurrentBlock].Next[4].N;
  StartTranslate;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if Edit2.Text='iddqd' then
    begin
      iddqdmode := True;
      Color := ClRed;
      Image2.Visible := False;
      exit;
    end;
  if Edit2.Text='idclip' then
    begin
      ClipMode := True;
      Color := ClBlue;
      Image2.Visible := False;
      exit;
    end;
  if Edit2.Text='' then
    begin
      ClipMode := False;
      iddqdmode := False;
      Color := clBtnFace;
      Image2.Visible := True;
      exit;
    end;
  CurrentBlock := StrToInt(Edit2.Text);
  StartTranslate;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   {$I-}
  //ShowWindow(FindWindow(PWidechar('Shell_TrayWnd'), nil), SW_SHOW);
  if FullScreen then SetVolume(65535,65535);

  CloseFile(FileLog);
   {$I+}
end;

Function ParseBulkNumber(S:String;A,Num:Integer):Integer;
var b : Integer;
begin
   b := FindOperator(S,Num);
   if (a>-1) and (b>-1) and (b>a+1) then
     result := StrToInt(Copy(S,a+1,b-a-1))
   else result := -1;
end;

Function ParseNumber(S:String) : Integer;
var a,b : Integer;
begin
   a := FindOperator(S,0);
   result := ParseBulkNumber(S,a+1,5);
end;

Procedure ParsePosition(S:String;N:Integer);
var a : Integer;
begin
  // b := FindOperator(Story[i],29);  //Ecли Left
  a := FindOperator(S,43); //  Height
  if a>-1 then FLImages[N].Height := ParseNumber(S);
  a := FindOperator(S,44); //  Left
  if a>-1 then FLImages[N].Left := ParseNumber(S);
  a := FindOperator(S,45); //  Top
  if a>-1 then FLImages[N].Top := ParseNumber(S);
  a := FindOperator(S,46); //  Width
  if a>-1 then FLImages[N].Width := ParseNumber(S);
  a := FindOperator(S,48); //  Width
  if a>-1 then FLImages[N].Smode := ParseNumber(S);
  a := FindOperator(S,49);
    if a>-1 then FLImages[N].Picture := GetStringWithOperator(S,50);
  a := FindOperator(S,51); //  Color
    if a>-1 then FLImages[N].Color := ParseNumber(S);
if N=0 then
begin
  a := FindOperator(S,56); //  FullScreen
    if (a>-1) then
      begin
        //ShowWindow(FindWindow(PWidechar('Shell_TrayWnd'), nil), SW_HIDE);
        form1.Width := Screen.Width;
        form1.Height := Screen.Height;
        form1.Top := 0;
        form1.Left := 0;
        form1.BorderStyle:=bsNone;
        form1.align:=altop;  //alCLient;
        form1.windowstate:=wsMaximized;
        Form1.formstyle:=fsStayOnTop;    //Отключамем при отладке
        form1.BitBtn1.Left := form1.Width-23;
        form1.BitBtn1.Top := 0;
        form1.BitBtn1.Visible := True;
        form1.TrackBar1.Left := form1.Width-200;
        form1.TrackBar1.Top := 0;
        form1.TrackBar1.Visible := True;
        FullScreen := True;
      end;
  a := FindOperator(S,57); //  TextTimer
    if (a>-1)  then  TextTimer := True;
  a := FindOperator(S,58); //  ByWords
    if (a>-1) then ByWords := True;
  a := FindOperator(S,59); //  Center
    if (a>-1) then Center := True;
  a := FindOperator(S,60); //  Font
    if (a>-1) then SmallFont := ParseNumber(S);
  a := FindOperator(S,61); //  BigFont
    if (a>-1) then BigFont := ParseNumber(S);
end;


end;

Function GetNumBlock(S:String):Integer;
var b,c:Integer;
begin
b := FindOperator(S,25);
c := FindOperator(S,26);
result := StrToInt(Copy(S,b+1,c-b-1));
end;

Function GetStrInParenthesis(S:String;i:Integer=0):String;   //(4)
var b,c:Integer;
begin
b := FindOperator(S,22);
c := FindOperator(S,23);
result := Copy(S,b+1+i,c-b-1-(2*i));
end;

function Scale(A:Integer;Y:Boolean):Integer;
begin
if FullScreen then
  if Y then result := Round(A*Form1.ClientHeight/1080)
       else result := Round(A*Form1.ClientWidth/1920)
else result := A;
end;

procedure Parser;
var i,j,a,b,c,NumBlock:Integer;
s:WideString;
begin
  MapLoad('map.txt');
  FileToText('operators.txt',Operators);
  FileToText('story.pas',Story);
  SetLength(Variables,2);
  Variables[0].S := 'CurrentBlock';
  Variables[1].S := 'Level';
  a := FindStrWithOperator(Story,13);
  if a<0 then exit; //Ошибка - не найден оператор var
  b := FindOperator(Story[a+1],21); //:
  if b<0 then exit; //Ошибка - не понятно, где блоки
  S := Copy(Story[a+1],1,b-2);
  SetLength(Operators,Length(Operators)+1);
  Operators[Length(Operators)-1] := s; //Добавляем оператор Block;
  c:=2;
  while FindOperator(Story[a+c],16,1,True)>0 do // inteber
   begin
     b := FindOperator(Story[a+c],21);
     if b<0 then exit;
     SetLength(Variables,c+1);
     Variables[c].S := Copy(Story[a+c],1,b-2);
     Variables[c].N := 0;
     inc(c);
   end;
  a := FindStrWithOperator(Story,27); //SetLength
  if a<0 then exit;
  b := FindOperator(Story[a],6);//,
  c := FindOperator(Story[a],23);//)
  S := Copy(Story[a],b+1,c-b-1);
  SetLength(Blocks,StrtoInt(s)); // Выставляем количество параграфов.
  for i := 0 to High(Blocks) do Blocks[i].Init;
  for I := 0 to High(FLImages) do FLImages[i].Init;
  for I := a+1 to High(Story) do
    begin
     // if i=404 then
      // b:=0;

      b := FindOperator(Story[i],High(Operators));
      if b>-1 then
        begin
         NumBlock := GetNumBlock(Story[i]);
         //if NumBlock=58 then
          //b:=1;

         b := FindOperator(Story[i],28);   //Logic
         if b>-1 then
           begin
             Blocks[NumBlock].Logic;
             continue;
           end;
         b := FindOperator(Story[i],29);
         if b>-1 then
           begin
             b := FindOperator(Story[i],22);
             c:=0;
             while FindOperator(Story[i],6,c+1)>-1 do  c := FindOperator(Story[i],6,c+1);
             S := Copy(Story[i],b+2,c-b-3);
             b:=0;
             b := FindOperator(Story[i],23,c);  //)
             Blocks[NumBlock].AddNext(s,StrToInt(Copy(Story[i],c+1,b-c-1)));
             continue;
           end;
         b := FindOperator(Story[i],30);
         if b>-1 then
          begin
            Blocks[NumBlock].SetImage({s}GetStrInParenthesis(Story[i],1));
            continue;
          end;
        b := FindOperator(Story[i],32);
         if b>-1 then
          begin
            j:=i+1;
            while Copy(Story[j],1,3)<>(#39+');') do
              begin
                Blocks[NumBlock].AddText(Story[j]);
                inc(j);
              end;
            continue;
          end;
        b := FindOperator(Story[i],31);
         if b>-1 then
          begin
            Blocks[NumBlock].AddTitle(GetStrInParenthesis(Story[i],1));
            continue;
          end;
        //end;
        b := FindOperator(Story[i],34);
         if (b>-1) then
          begin
            Blocks[NumBlock].SetBattleScore(StrToInt({}GetStrInParenthesis(Story[i],0)));
            continue;
          end;
        b := FindOperator(Story[i],33);
         if (b>-1) and (FindOperator(Story[i],10,b-1)=b-1)  then
          begin
            Blocks[NumBlock].Battle(GetStrInParenthesis(Story[i],1));
            continue;
          end;
        b := FindOperator(Story[i],35);
        if (b>-1)  and (FindOperator(Story[i],10,b-1)=b-1) then
          Blocks[NumBlock].Map;
        b := FindOperator(Story[i],36); //Code
        if (b>-1) and (FindOperator(Story[i],10,b-1)=b-1)  then
          Blocks[NumBlock].Code;
        b := FindOperator(Story[i],54); //Game
        if (b>-1) and (FindOperator(Story[i],10,b-1)=b-1) then
          Blocks[NumBlock].Game;
        b := FindOperator(Story[i],55); //Sound
        if b>-1 then
          Blocks[NumBlock].Sound := GetStrInParenthesis(Story[i],1);
        end;

        b := FindOperator(Story[i],41);  //Winform
          if b>-1 then ParsePosition(Story[i],0);
        b := FindOperator(Story[i],42);  //Image
          if b>-1 then ParsePosition(Story[i],6+ParseBulkNumber(Story[i],b+4,10));
        b := FindOperator(Story[i],47);  //Label
          if b>-1 then ParsePosition(Story[i],ParseBulkNumber(Story[i],b+4,10));
    end;
  BLoad('save.txt');
  if FullScreen then
    begin
      FLImages[9].Left := Round(FLImages[9].Left*Form1.ClientWidth/1920);
      FLImages[9].Width := Round(FLImages[9].Width*Form1.ClientWidth/1920);
      FLImages[9].Top := Round(FLImages[9].Top*Form1.ClientHeight/1080);
      FLImages[9].Height := Round(FLImages[9].Height*Form1.ClientHeight/1080);
      Form1.Memo1.Left := Round(FLImages[9].Left +30*Form1.ClientWidth/1920);
      Form1.Memo1.Width := Round(FLImages[9].Width -60*Form1.ClientWidth/1920);
      Form1.Memo1.Top := Round(FLImages[9].Top  +10*Form1.ClientHeight/1080);
      Form1.Memo1.Height := Round(FLImages[9].Height -20*Form1.ClientHeight/1080);

    end;
end;

procedure FindAndCheckIf(var q,c:Integer; S:String);
const
LogicArray : Array [1..5,0..1] of Byte = ((0,4),(0,7),(0,8),(1,52),(1,53));  //= .<,> ,=> ,>=
var b,i:Integer;
begin
 for i := 1 to High(LogicArray) do
   begin
     b := FindOperator(S,LogicArray[i,1]);
      if b>-1 then
       begin
        q := i;
        c := b+LogicArray[i,0];
       end;
    end;
end;

function TranslateHigh:Boolean;
var a,b,c,d,i,j,k,l,CurrentBlockbuf,q,q2 : Integer;
s,s1 : string;
begin
  result := False;
  while Blocks[CurrentBlock].Format>1 do  //Суперцикл пока не дойдём до логического блока
    begin
     if Blocks[CurrentBlock].Format=5 then  //Смена игры.
       begin
         S := GetCurrentDir+Blocks[CurrentBlock].Next[0].S;
         SetCurrentDir(S);
         result := True;
         Form1.FormCreate(nil);
         exit;
       end;

// ---------Обработка кодового блока    -4
   if Blocks[CurrentBlock].Format=4 then
     begin
       CurrentBlockbuf:=-1;
       for I := 0 to High(Blocks[CurrentBlock].Text) do
         begin
            //Если if не сработал
            a := FindOperator(Blocks[CurrentBlock].Text[i],38);  //if xxx>yyy выполняем.
              if a>-1 then
                begin
                   q  := 0;
                   q2 := 1;
                   c  := 0;
                  for j := 0 to High(Variables) do
                    begin
                      b := CheckVariable(i,j);
                       if b>-1 then
                         begin
                           d := b; //Оператор
                           FindAndCheckIf(q,c,Blocks[CurrentBlock].Text[i]);
                           b := FindOperator(Blocks[CurrentBlock].Text[i],40);
                           //if d<c then
                           if (b<d) or (c<d) then  //Оператора b нет или он левее нашей переменной или он левее нашего символа
                             begin
                                q := 0;
                                continue; //q:=0
                             end
                           else
                             begin
                               s := Copy(Blocks[CurrentBlock].Text[i],c+1,b-c-2);
                               q2:=StrTOInt(S);
                               if (q=4) or (q=5) then
                                 begin
                                   q:=3;
                                   dec(q2);  //x=>5 это тоже, что x>4
                                 end;

                               if Variables[j].N=q2 then  q2:=1
                               else if Variables[j].N<q2 then q2:=2
                                    else q2:=3;
                             end;
                           break;
                         end;
                    end;
                  if q<>q2 then continue //if не выполнен.
                  else Blocks[CurrentBlock].Text[i] :=  Copy(Blocks[CurrentBlock].Text[i],b+4,Length(Blocks[CurrentBlock].Text[i])-b-3);
                end;
            //else
           // begin
           //Если if сработал, то продолжаем.
            a := FindOperator(Blocks[CurrentBlock].Text[i],0); //Присваивание
              if a>-1 then
               begin
                for j := 0 to High(Variables) do
                begin
                  b := CheckVariable(i,j);
                  if b>-1 then  //Проверить опция a := a+1;
                   begin
                      b := FindOperator(Blocks[CurrentBlock].Text[i],5);
                      s := Copy(Blocks[CurrentBlock].Text[i],a+2,b-a-2);
                      b := FindOperator(S,2); //+
                      if b>-1 then
                        begin
                          s1 := Copy(S,1,b-1);
                          s := Copy(S,b+1,High(S)-b);
                          for k := 0 to High(Variables) do
                           begin
                              a := CheckVariable(S1,k);  //a := b +
                              if a>-1 then
                               begin
                                 c := -1;
                                 for l := 0 to High(Variables) do
                                   begin
                                     c := CheckVariable(S,l);
                                     if c>-1 then  //a:= b + c;
                                       begin
                                         Variables[j].N := Variables[k].N+Variables[l].N;
                                         break;
                                       end;
                                   end;
                                   if c=-1 then  //a :=  b + 1;
                                     begin
                                       Variables[j].N := Variables[k].N+StrToInt(s);
                                       if j=0 then  CurrentBlockBuf := Variables[j].N;
                                     end;
                                 break;
                               end;
                           end;
                        end
                      else
                        begin
                          Variables[j].N := StrToInt(s);
                          if j=0 then  CurrentBlockBuf := Variables[j].N;
                        end;
                      //Level := StrToInt(s);
                      break;
                   end;
                end;
               end;
            //end;
            a := FindOperator(Blocks[CurrentBlock].Text[i],High(Operators)); //Blocks[10].Disable(2);
             if a>-1 then
               begin
                 S := Blocks[CurrentBlock].Text[i];
                 a := GetNumBlock(S);
                 //b := FindOperator(S,23);
                 //c := FindOperator(S,24);
                 b := StrToInt({Copy(S,b+1,c-b-1)}GetStrInParenthesis(S,0));
                 Blocks[a].Disable(b);
               end;
         end;
       if CurrentBlockbuf=-1 then CurrentBlock := Blocks[CurrentBlock].Next[0].N //Т.к. по ходу кода возможны изменения
                             else
                               begin
                                 CurrentBlock := CurrentBlockBuf;
                                 break;
                               end;
     end;
// Ищем оператор := Если нашли, то то, что слева присваиваем.
//---------------------------Обработка карты--------------------------
      if Blocks[CurrentBlock].Format=3 then
        begin
          //if Win - захват региона
         if Variables[1].N<10 then   //Если Лёгкий Level, то сразу победа на карте.
            begin
              CurrentBlock := Blocks[CurrentBlock].Next[1].N;
              break;
            end;
          if (Win) and (NextStation>0) then
            begin
              LoseRegion(NextStation);
              PutRegion(NextStation,1);
              NextStation := 0;
            end;
          //Вот здесь тоже можно обработать ход врага
          if Turns<7 then
            begin
              if Random(100)>15 then Expansion(2);   //Для упрощения 85 вероятность экспансмм
              if Random(100)>15 then Expansion(3);
            end;
          NextStation := 0;
          if Turns=0 then  NextStation :=255 //Кончился ход
          else
            begin
              ValidClose := False;
              if FullScreen then  Form1.formstyle:=fsNormal;
              Form3.ShowModal;
              if FullScreen then Form1.formstyle:=fsStayOnTop;
              if not ValidClose then
                begin
                  result := True;
                  Form1.Close;
                  exit;
                end;
            end;
          if NextStation>0  then
            begin
              if NextStation<255 then
                begin
                  CurrentBlock := Blocks[CurrentBlock].Next[0].N;
                  if Map[NextStation].Host=0 then Blocks[CurrentBlock].Battle(Map[NextStation].Combo)
                  else Blocks[CurrentBlock].Battle('');
                end
              else
                begin
                   if (Length(Regions[1])>Length(Regions[2])) and (Length(Regions[1])>Length(Regions[3])) then CurrentBlock := Blocks[CurrentBlock].Next[1].N
                   else
                     CurrentBlock := Blocks[CurrentBlock].Next[2].N;
                   ResetMap;
                end;
              //В противном случае считаем, кто победил.
            end;

        end;
//-----------------------Обработка битвы -------------------------------
      if Blocks[CurrentBlock].Format=2 then   //Боевой блок.
        begin
          if iddqdmode then  Win := True
          else
            begin
              Win := False;
              BotString := Blocks[CurrentBlock].Title;
              if FullScreen then  Form1.formstyle:=fsNormal;
              Form2.ShowModal;
              if FullScreen then Form1.formstyle:=fsStayOnTop;

            end;
          if Win then CurrentBlock :=  Blocks[CurrentBlock].Next[0].N
                 else CurrentBlock :=  Blocks[CurrentBlock].Next[1].N;
        end;
   //Обработка хода врага
    end;
end;

procedure ResetVariables;
var i:Integer;
begin
  for i := 0 to High(Variables) do Variables[i].N := 0;
end;

function SolveNextBlock(a:Integer):Word;
var i,j:Integer;
begin
  j := 0;
  result := CurrentBlock;
  for I := 0 to High(Blocks[CurrentBlock].Next) do
    if Blocks[CurrentBlock].Next[i].D=False then
      begin
        if j=a then
          begin
            result := Blocks[CurrentBlock].Next[i].N;
            break;
          end;
        inc(j);
      end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i:Integer;
begin
  Parser;
  Labels[0]  := Label1;
  Labels[1]  := Label2;
  Labels[2]  := Label3;
  Labels[3]  := Label4;
  Labels[4]  := Label5;
  Labels[5]  := Label6;
  Images[1]  := Image1;
  Images[2]  := Image2;
  Images[3]  := Image3;
  Images[4]  := Image4;
  if FLImages[0].Height>0 then Height := FLImages[0].Height;
  if FLImages[0].Width>0 then Width := FLImages[0].Width;
  for I := 0 to High(Labels) do
    begin
      if FLImages[i+1].Top>=0 then Labels[i].Top :=  Scale(FLImages[i+1].Top,True);
      if FLImages[i+1].Left>=0 then Labels[i].Left :=  Scale(FLImages[i+1].Left,False);
      if FLImages[i+1].Height>=0 then Labels[i].Height :=  Scale(FLImages[i+1].Height,True);
      if FLImages[i+1].Width>=0 then Labels[i].Width :=  Scale(FLImages[i+1].Width,False);
      if FLImages[i+1].Color>=0 then Labels[i].Font.Color := TColor(FLImages[i+1].Color);
      if i<High(Labels) then Labels[i].Font.Height := Round(SmallFont*1.3)
                        else Labels[i].Font.Height := Round(BigFont*1.3);
      if Center then Labels[i].AutoSize := True;
    end;
   for I := 1 to High(Images) do
    begin
      if FLImages[High(Labels)+1+i].Top>=0 then Images[i].Top :=  FLImages[High(Labels)+1+i].Top;
      if FLImages[High(Labels)+1+i].Left>=0 then Images[i].Left :=  FLImages[High(Labels)+1+i].Left;
      if FLImages[High(Labels)+1+i].Height>=0 then Images[i].Height :=  FLImages[High(Labels)+1+i].Height;
      if FLImages[High(Labels)+1+i].Width>=0 then Images[i].Width :=  FLImages[High(Labels)+1+i].Width;
      if FLImages[High(Labels)+1+i].Picture<>'' then  Images[i].Picture.LoadFromFile(FLImages[High(Labels)+1+i].Picture);
      if FLImages[High(Labels)+1+i].Smode=1 then Images[i].Stretch := True;
    end;
  if FLImages[7].Height<0 then FLImages[7].Height := 145;
  if FLImages[7].Width<0 then FLImages[7].Width := 190;
  if not byWords then Timer1.Interval := 50;
  Blocks[CurrentBlock].Image := CurrImage;
  Blocks[CurrentBlock].Sound := CurrSound;
  CurrSound := '';
  StartTranslate;
end;



procedure TForm1.FormPaint(Sender: TObject);
var a:Byte;
begin
if TrackBar1.Visible then
  begin   //Видно же , что перерисовывает, но не там.
    //TrackBar1.Invalidate;
    //TrackBar1.Repaint;
    //a:= TrackBar1.Position;
    //TrackBar1.Position := 20;
    //if TrackBar1.Position=100 then TrackBar1.Position := 99
                              //else TrackBar1.Position := TrackBar1.Position + 1;
    //TrackBar1.Position := a;
  end;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  inc(Cheat);
  if Cheat>10 then
    begin
      Edit2.Visible := not Edit2.Visible;
      Button6.Visible := not Button6.Visible;
    end;
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
  CurrentBlock := SolveNextBlock(0);//Blocks[CurrentBlock].Next[0].N;
  StartTranslate;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin
  CurrentBlock := SolveNextBlock(1);//Blocks[CurrentBlock].Next[1].N;
  StartTranslate;
end;

procedure TForm1.Label3Click(Sender: TObject);
begin
  CurrentBlock := SolveNextBlock(2);//Blocks[CurrentBlock].Next[2].N;
  StartTranslate;
end;

procedure TForm1.Label4Click(Sender: TObject);
begin
  CurrentBlock := SolveNextBlock(3);//Blocks[CurrentBlock].Next[3].N;
  StartTranslate;
end;

procedure TForm1.Label5Click(Sender: TObject);
begin
  CurrentBlock := SolveNextBlock(4);//Blocks[CurrentBlock].Next[4].N;
  StartTranslate;
end;

procedure TForm1.Label6Click(Sender: TObject);
begin
  CurrentBlock := 0;
  ResetMap;
  ResetVariables;
  StartTranslate;
end;

procedure TForm1.MediaPlayer1Notify(Sender: TObject);
begin
if MediaPlayer1.NotifyValue = nvSuccessful then
  begin
    MediaPlayer1.Notify := true;
    MediaPlayer1.Play;
  end;
end;



procedure TForm1.Memo1Click(Sender: TObject);
var i:LongWord;
begin
  if  (TextTimer) and (Timer1.Enabled) then with Blocks[CurrentBlock] do
    begin
      Timer1.Enabled := False;
      Memo1.Lines.Clear;
      for I := 0 to Length(Text)-1 do Memo1.Lines.Add(Text[i]);
      LabelsShow;
    end;
end;


procedure TForm1.LabelsShow;
var i,j : Integer;
begin
   J:=0;
  with Blocks[CurrentBlock] do
    for I := 0 to Length(Next)-1 do
      if (Next[i].D=false) and (j<High(Labels)) then
          begin
            Labels[j].Visible := True;
            Labels[j].Caption := Next[i].S;
            if (Center) and (FLImages[j+1].Left>=0 ) then Labels[j].Left :=  Scale(FLImages[j+1].Left  - Round(SmallFont*0.35*Length(Next[i].S)),False);
            inc(j);
          end;
end;

procedure TForm1.StartTranslate;
var i,j,h,w:Integer;
hw : Double;
begin
   if TranslateHigh then exit;
//--------------Обработка логического блока --------------------------------
  with Blocks[CurrentBlock] do
    begin
      for I := {Length(Next)}0 to 4 do  Labels[i].Visible := False;

      if not FullScreen then LabelsShow;
      if Image<>'' then
      begin
       if FullScreen then
         begin
           Image2.Picture.LoadFromFile(Image);
           //Image2.Refresh;
           TrackBar1.SetTick(TrackBar1.Position);
           //TrackBar1.Invalidate;
         end
       else
        begin
          Image1.Visible := True;
          Image4.Visible := True;
          Image1.Picture.LoadFromFile(Image);
          if FLImages[7].Smode=1 then
            begin
              if Image1.Picture.Width>0 then hw := Image1.Picture.Height/Image1.Picture.Width
              else hw := 10;
              h := min(FLImages[7].Height,Image1.Picture.Height);
              w := min(FLImages[7].Width,Image1.Picture.Width);
              if h>w*hw then h:=Round(w*hw)
              else if (hw>0.01) then w:=Round(h/hw);
            end
          else
            begin
              h := min(FLImages[7].Height,Image1.Picture.Height);
              w := min(FLImages[7].Width,Image1.Picture.Width);
            end;
          Image1.Height := h;
          Image1.Width := w;
          Image4.Height := Round(Image1.Height*1.1);
          Image4.Width :=  Round(Image1.Width*1.1);
          Image1.Left := Round(Image4.Left + Image1.Width*0.05);
          Image1.Top := Round(Image4.Top + Image1.Height*0.05);
        end;
        CurrImage := Image;
      end
      else
        begin
          Image1.Visible := False;
          Image4.Visible := False;
        end;
     Edit1.Text := Title;
     Form1.Caption := Title;
     Memo1.Lines.Clear;
     if not TextTimer then
       for I := 0 to Length(Text)-1 do Memo1.Lines.Add(Text[i])
     else
       begin
         TextPosition := 1;
         LinePosition := 0;
         Timer1.Enabled := True;
         Memo1.Lines.Add('');
       end;
     Memo1.SelStart := 0;  //Установить вначало курсора
     SendMessage(Memo1.Handle, EM_SCROLLCARET, 0, 0);
     //Memo1.SelStart := 0;     Установить курсор в начало.
     //Здесь обрабатываем Sound
     if Sound='None' then
       begin
         MediaPlayer1.Stop;
         CurrSound := '';
       end
     else
       if (Sound<>CurrSound) and (Sound<>'') then
                   begin
                     CurrSound := Sound;
                     MediaPlayer1.FileName := Sound;
                     MediaPlayer1.Open;
                     MediaPlayer1.Notify := true;
                     MediaPlayer1.Play;
                   end;

     if BattleScore<7 then
     if BattleScore>0 then
       begin
         ScoreMan := BattleScore;
         ScoreBot := 0;
       end
     else
       begin
         ScoreMan := 0;
         ScoreBot := -BattleScore;
       end;
     BSave('save.txt');
    end;

end;


procedure SetVolume(const volL, volR: Word);
var hWO: HWAVEOUT;
    waveF: TWAVEFORMATEX;
    vol: DWORD;
begin
  FillChar(waveF, SizeOf(waveF), 0);
  waveOutOpen(@hWO, WAVE_MAPPER, @waveF, 0, 0, 0);
  vol := volL + volR shl 16;
  waveOutSetVolume(hWO, vol);
  waveOutClose(hWO);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var a:Integer;
begin
with Blocks[CurrentBlock] do
  if LinePosition>High(Text) then
    begin
      Timer1.Enabled := False;
      LabelsShow;
    end
else
if ByWords then
begin
  a:= FindSpaceBar(Text[LinePosition],TextPosition);
  if a>-1 then
    begin
      Memo1.Lines[Memo1.lines.count-1] :=  Memo1.Lines[Memo1.lines.count-1] + Copy(Text[LinePosition],TextPosition,a-TextPosition+1);//Copy(Text[LinePosition],1,a);
      TextPosition := a+1;
    end
  else
    begin
      Memo1.Lines[Memo1.lines.count-1] := Memo1.Lines[Memo1.lines.count-1] + Copy(Text[LinePosition],TextPosition,Length(Text[LinePosition])-TextPosition+1);
      Memo1.Lines.Add('');
      TextPosition :=1;
      Inc(LinePosition);
    end;
end
else
  begin
    if TextPosition>Length(Text[LinePosition]) then
      begin
        Memo1.Lines.Add('');
        TextPosition :=1;
        Inc(LinePosition);
        exit;
      end;
    Memo1.Lines[Memo1.lines.count-1] :=  Memo1.Lines[Memo1.lines.count-1] + Text[LinePosition,TextPosition];
     inc(TextPosition);
    if (LinePosition=0) and (TextPosition=10) and (TrackBar1.Visible) then
        begin
          //TrackBar1.Invalidate;
          //TrackBar1.Repaint;

          //TrackBar1.InitiateAction;
        end;
  end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  SetVolume(TrackBar1.Position*655,TrackBar1.Position*655);
end;

end.
