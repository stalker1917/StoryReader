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
     procedure AddText(S:String);
     procedure AddNext(S:String;Number:Integer);
     procedure Init;
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

implementation
Function CheckVariable;
begin
   Operators[37] := Variables[j].S;
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
  F:=FindOperator(S,20);
  if f>0 then
    begin
      for I := 1 to 3 do  S[i]:=' ';
      SetLength(Text,l+1);
      Text[l] :='';
      inc(l);
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
  BattleScore := 7;
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




end.
