unit Translator;

interface
//uses System;
type
   TText = Array of String;
   SNumber = Record
     S : WideString;
     N : Word;
   End;
   VInteger = Record
     S : WideString;
     N : Integer;
   End;
   TElement = Object
     Picture : WideString;
     Height,Width,Top,Left,Smode,Color : Integer;
     procedure Init;
   End;
   TBlock = object
     //Init : Boolean;
     Image,Title : String;
     Text : TText;
     Format : Byte;  //1- логический блок 2-битва 3-карта мира  4- кодовый блок.
     Next : Array of SNumber;
     BattleScore : SmallInt;
     procedure SetImage(S:String);
     procedure AddTitle(S:String);
     procedure AddText(S:String;M:Boolean=True);
     procedure AddNext(S:String;Number:Integer);
     procedure Init(N:Integer=7);
     procedure Logic; //Логический параграф
     procedure Battle(S:String);
     procedure SetBattleScore(A:SmallInt);
     procedure Map;
     procedure Code;
   end;
var
  Blocks    : Array of TBlock;
  Operators : TText;//array [0..30] of string; //Список опреаторов
  Story     : TText;
  CodBattle : TText;
  OutPut    : TText;
  f         : System.text;
  //В сохранение
  CurrentBlock : Integer = 0;
  //Level        : Integer = 0; //Easy
  ScoreMan     : Integer = 0;
  ScoreBot     : Integer = 0;
  Variables    : Array of VInteger; // Объявляемые в коде перемеенные.  CurrentBlock - 0 , Level - 1;
  FLImages     : Array [0..10] of TElement; //0- Form 1..5- Label 6..9 -Images

Procedure FileToText(S:String; var Dump:TText);
function FindStrWithOperator(var Dump : TText; Number : Integer) : Integer;
function FindOperator(S:String; Number:Integer; pos:Integer=1) :Integer;
Function CheckVariable(i,j:Integer):Integer;
procedure BLoad(S:String);
procedure BSave(S:String);
function GetStringWithOperator(var S:String;Number:Integer):String;
Procedure AddTText(var T:TText; S:String);
function DeleteSpaceBars(S:String; Mode:Integer):String;
function FindVariable(S:String):Integer;

implementation
Function CheckVariable;
begin
   Operators[37] := Variables[j].S;  //Заменяем оператор Level
   result := FindOperator(Blocks[CurrentBlock].Text[i],37); //Оператор имени переменной
end;


function FindOperator;
var i,High:Integer;
begin
  High := Length(s)-Length(Operators[Number])+1;
  for I := pos to High do
    if (s[i]=Operators[Number,1]) and (Copy(S,i,Length(Operators[Number]))=Operators[Number]) then
      begin
        Result := i;
        Break;
      end;
  if i>High then  Result := -1;
end;
function FindStrWithOperator;
var i,a:Integer;
begin
  result := -1;
  for i := 0 to High(Dump) do
    begin
      a:=FindOperator(Dump[i],Number);
      if a>-1 then
        begin
          result := i;
          exit;
        end;
    end;
end;

function GetStringWithOperator;
var
Buf : String;
Pos : Integer;
begin
   Pos := FindOperator(S,Number);
   if Pos=-1 then result := ''
   else
     begin
       Buf := Copy(S,Pos+1,Length(S)-Pos);
       Pos := FindOperator(Buf,Number);
       if Pos=-1 then result := Buf
       else result:= Copy(Buf,1,Pos-1);
     end;
end;



Procedure FileToText(S:String;var Dump:TText);
var s1:Ansistring;
begin
  Assignfile(f,s); //Список операторов
  Reset(f);
  while not eof(f) do
    begin
      readln(f,s1);
      SetLength(Dump,Length(Dump)+1);
      Dump[Length(Dump)-1] := UTF8ToWideString(s1);
    end;
 closeFile(f);
end;

procedure TBlock.SetImage;
begin
  Image := S;
end;

procedure TBlock.AddTitle(S: string);
begin
   Title := S;
end;

procedure TBlock.AddText;
var i,l,f: Integer;
begin
  L:=Length(Text);
  if M then
    begin
      F:=FindOperator(S,20);
      if f>0 then
        begin
          for I := 1 to 3 do  S[i]:=' ';
          SetLength(Text,l+1);
          Text[l] :='';
          inc(l);
        end;
    end;
  SetLength(Text,l+1);
  Text[l] := S;
end;

procedure TBlock.Init;
begin
  Image := '';
  Title := '';
  Format := 0; //Неопределённый блок
  SetLength(Next,0);
  BattleScore := N;
end;

procedure TBlock.AddNext;
begin
  if Length(Next)>4 then  exit;
  SetLength(Next,Length(Next)+1);
  Next[High(Next)].S := S;
  Next[High(Next)].N := Number;
end;

procedure TBlock.Logic;
begin
   Format := 1;
end;

procedure TBlock.Battle(S: string);
begin
  Format := 2;
  Title := S;
end;

procedure TBlock.SetBattleScore(A: SmallInt);
begin
  BattleScore := A;
end;

Procedure TBlock.Map;
begin
  Format := 3;
end;

Procedure TBlock.Code;
begin
  Format := 4;
end;

Procedure TElement.Init;
begin
  Picture := '';
  Height  := -1;
  Width   := -1;
  Left    := -1;
  Top     := -1;
  Smode   := 0;
  Color   := -1;
end;


Procedure BLoad;
begin
  AssignFile(F,S);
  Reset(F);
  Readln(F,CurrentBlock);
  Readln(F,Variables[1].N);
  Readln(F,Scoreman);
  Readln(F,Scorebot);
  CloseFile(F);
end;

Procedure BSave;
begin
  AssignFile(F,S);
  Rewrite(F);
  Writeln(F,CurrentBlock);
  Writeln(F,Variables[1].N);
  Writeln(F,Scoreman);
  Writeln(F,Scorebot);
  CloseFile(F);
end;

Procedure AddTText;
begin
  SetLength(T,Length(T)+1);
  T[High(T)] := S;
end;

function ToCycle(var S:String;N:Integer=1):Integer;
var i:Integer;
begin
   if N=-1 then
     begin
       result := -1;
       N      :=  1;
     end
   else result := High(S);
   for I := N to High(S) do
     if (S[i]<>' ') and (S[i]<>#9) xor (result>0) then
      begin
        result:=i;
        break;
      end;
end;

function DowntoCycle(var S:String;N:Integer=-1):Integer;
var i:Integer;
begin
   result := -1;
   if N<0 then N:= High(S)
          else result := 1;
   for I := N downto 1 do
     if (S[i]<>' ') and (S[i]<>#9) xor (result=1) then
      begin
        result:=i+1;
        break;
      end;
end;


function DeleteSpaceBars;// Удаляем проблемы
var i,a,b:Integer;
begin

   case Mode of
     0:      // ___Vasa_123__  ---->Vasa_123
       begin
         a := ToCycle(S);
         b := DowntoCycle(S);
       end;
     1:    // ___Vasa_123__  ---->Vasa
        begin
         a := ToCycle(S);
         b := ToCycle(S,a);
        end;
     2:      // ___Vasa_123__  ---->_123
       begin
         b := DownToCycle(S);
         a := DownToCycle(S,b);
        end;
   end;

 if (a<0) or (b<0) or (a>b) then result := ''
 else result := Copy(S,a,b-a+1);
end;

Function FindVariable;      //Найти переменную по строке
var i:Integer;
begin
  result := -1;
  for I := 0 to High(Variables) do
      if S = Variables[i].S then
         begin
           result := i;
           exit;
         end;
end;


end.
