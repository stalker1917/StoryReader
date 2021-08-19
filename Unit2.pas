unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Vcl.ExtCtrls,Math, Vcl.Samples.Spin,Translator;

type
  TForm2 = class(TForm)
    PlayerCombo: TLabeledEdit;
    BotCombo: TLabeledEdit;
    Button2: TButton;
    ManTablo: TLabeledEdit;
    BotTablo: TLabeledEdit;
    Memo1: TMemo;
    LabeledEdit1: TLabeledEdit;
    Button3: TButton;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Timer1: TTimer;
//    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
TDices = Array[0..12] of SmallInt; //Для подсчёта суммы
PDices = ^TDices;
PCaption = ^TCaption;
{
TExDices = record
  case i:integer of
    1: (Dices : TDices);
    2: (i0,i1,i2,i3,i4,i5,i6,i7:SmallInt);
  end;
  }
const
HardcoreMode=False;


var
  Form2: TForm2;
  GameStage : Integer = 0;
  DiceMan,DiceBot : TDices;
  RazborMan,RazborBot,RazborBotDr : TDices; //0 - количество кубиков //1-6 -количество кубов
  MainTree : TDices;
  BotHod : Boolean;
  Debug1 : Boolean = False;//True;
  S1,S2:TDices;  //Обязательно глобальные , а то сглючит
  FileLog:Text;
  ManSecondThrow : TDices;
  Timer : Double = 0;
  BotString : String ='';
  Win : Boolean = False;

implementation


{$R *.dfm}
//---------- Расчёт дерева возможных исходов----
//Три параметра - Влияние, Двойки, Очки
//---Расчёт троек----
// Если n=6 - расчитываем особый случай, училение всех параметров на 1
// I= n div2 ..n - сколько троек используем //Мы все не можем использовать
// 0 ..1 - 0 случай , один усиливаем , два ослабляем  , 1-й случай 2 усиливаем 1 ослабляем.
// 0..2 - какой этот один параметр(который усиливаем или ослабляем)
// 0...j=i-n div 2 - на сколько мы ослабляем первый параметр(если ослабляем)
// 0..i - на сколько мы усиливаем первый из двух параметров(если 2 усиливаем)
// Если ослабляются
//---Расчёт двоек
//Исходов 0..N -  сколько в атаку, а сколько в защиту

Procedure TreeTo46Convert(var PromDices,RazbDices,PrTree : TDices);
var Max6:Integer;
begin
  if PrTree[2]>=0 then
   if  PrTree[2]=0 then
     begin
       PromDices[6] := RazbDices[6];
       PromDices[4] := RazbDices[4];
     end
   else
    if RazbDices[6] =0 then
      begin
        PromDices[6] := 1;
        PromDices[4] := RazbDices[4] + PrTree[2] - 1;
      end
    else
      begin
        PromDices[4] := RazbDices[4] + PrTree[2];
        PromDices[6] := RazbDices[6];  //Если не присвоить, всё вылитет!
      end
  else
    if RazbDices[4]+RazbDices[6]+PrTree[2]=0 then  // а что делать, если сумма меньше?
      begin
        PromDices[4] := 0;
        PromDices[6] := 0;
      end
    else if RazbDices[4]+RazbDices[6]+PrTree[2]<0 then
      begin
        PromDices[5]:=-100;
        exit;
      end
      else if  RazbDices[6]+PrTree[2]<1 then //А если шестёрок сразу 0?
         begin
           Max6 := Max(0,RazbDices[6]-1); //Что мы покрыли шестёрками
           PromDices[4]:=RazbDices[4]+Max6+PrTree[2];
           PromDices[6]:=RazbDices[6]-Max6;
           if RazbDices[4]<0 then
             begin
               PromDices[6]:=0;     //Невозможно+
               PromDices[4]:=0;
             end;
         end
        else
        begin
          PromDices[4]:=RazbDices[4];//Всё сохранили!
          PromDices[6]:=RazbDices[6]+PrTree[2];   //Вычитаем шестёрки кроме последней
        end;
end;

Function GetElemSum(var RazbDices: TDices) : TDices;
begin
  Result[0]  := -1;
  Result[1] := RazbDices[1]+RazbDices[5];
  Result[2] := RazbDices[2];
  Result[3] :=  RazbDices[3];
  Result[4]:= RazbDices[6]*Round(Power(2,RazbDices[4]));
  if Result[1]<0 then
    Result[5] := -100
  else
    Result[5] := 0;
end;

Procedure GetFullSum(var S1,S2 : TDices);
begin
  S1[5] := 0;
  S1[5] := S1[5]+1*(S1[1]-S2[1]);     //Коэф влияние - 1/2
  if S1[2]>=S2[3] then S1[5] := S1[5]+2*S1[4];    //Очки начисляются если акция состоялась. Акция состоялась если защата>=атаке.
  if S2[2]>=S1[3] then S1[5] := S1[5]-2*S2[4];
end;


Function GetSum(var RazbDices,PrTree : TDices;Mutification:Boolean=False) : TDices;
var PromDices:TDices; i:byte;
begin
  PromDices[5] := 0; //  А инициализировать Пушкин будет?
  TreeTo46Convert(PromDices,RazbDices,PrTree);
  if PromDices[5]=-100 then
   begin
     Result[5] := -100;
     exit;
   end;
  PromDices[1] := RazbDices[1]  + PrTree[0]; // И пофиг, что -1 будет!
  PromDices[2] := PrTree[4]; //Защита
  PromDices[3] := PrTree[5]; //Атака
  PromDices[5] := RazbDices[5];
  if Mutification then
     begin
       Result[0] := RazbDices[0];
       for I := 1 to 6 do Result[i] := PromDices[i];
       if Result[1]<0  then
         begin
           Result[5] := Result[5]+Result[1];
           Result[1] := 0;
         end;
     end
  else
  Result := GetElemSum(PromDices);
end;

Function GetTree(var PrimDices,SecondDices : TDices;OneStage:Boolean=False;GetScore:Boolean=False) : TDices;
var i1,i2,i3,i4,i5,i6,i7:byte;
Max3,Max2,Min3,Maxi5 :SmallInt;
MinSum,PrTree,PrTreeOS,PrSum : TDices;
Znak : ShortInt;
Cnt : Array[0..2] of ShortInt;
begin
  Min3 :=  PrimDices[3] div 2; //Минимальное число используемых троек
  Max3 :=  min(PrimDices[3],PrimDices[0] div 2);
  if SecondDices[0]>-1 then for i1 := 0 to 6 do MinSum[i1] := 120
                       else for i1 := 0 to 6 do Result[i1] := - 100;
  PrTree[3] := 9;
  //for i1 := Min3 to Max3 do //Сколько троек используем . Непонятно, зачем нужно.
    for i2 := 0 to 1 do
     begin
      if i2 = 0 then Znak := 1
                else Znak := -1;
      for i3 := 0 to 2 do
       begin
         Cnt[i2] := {i1;}Max3;
         Cnt[1-i2] := {i1}Max3 - Min3;
          for i4 := Min3*(1-i2) to Cnt[0] do  //Если 1 усиливаем, то усиление начинаем от минимального числа.
           begin
           // Maxi5 := {Min3*(i2)+}i4-(Max3-i4)*Znak;
            if i2=0 then  Maxi5 :=i4-(Max3-i4)
                    else  Maxi5 :=(i4+Max3) div 2;
            if Maxi5<0 then  Maxi5:=0;
            PrTree[i3] := i4*Znak;
            for i5 := 0 to Maxi5 do  //Сколько ослабили, столько усилили
              begin
                PrTree[(i3+1) mod 3] := -i5*Znak;
                PrTree[(i3+2) mod 3 ] := -(Maxi5-i5)*Znak;
                Max2:= PrimDices[2]+PrTree[1];
                if Max2<0 then continue; //Уменьшили двоек меньше, чем надо!
                for i6:=0 to Max2 do
                  begin
                    PrTree[4] := i6;
                    PrTree[5] := Max2-i6;
                    PrSum := GetSum(PrimDices,PrTree); //0=-1 --1- число влияние 2- защита 3 - атака 4 -сила 5- полная сумма
                    if PrSum[5]<0 then continue; //Недопустимый результат - нечего конвертировать!
                    if SecondDices[0]=-1 then
                      begin
                        GetFullSum(PrSum,SecondDices);
                        if PrSum[5]>Result[5] then  //Предполагаем, что игрок реализует наихудший вариант для бота
                          for i7:=0 to 5 do
                            begin
                              Result[i7] :=PrSum[i7];
                              if OneStage then PrTreeOS[i7]:=PrTree[i7];
                            end;
                      end
                      else
                       begin
                        PrSum :=  GetTree(SecondDices,PrSum);
                        if PrSum[5]<MinSum[5] then
                          for i7:=0 to 5 do
                           begin
                             MinSum[i7] :=PrSum[i7];
                             Result[i7] :=PrTree[i7];  //Результирующее дерево со смещением +1
                       end;
                      end;
                  end;
              end;
           end;
       end;
     end;
if OneStage then  for i7:=0 to 5 do  Result[i7] := PrTreeOS[i7];
if GetScore  then  for i7:=0 to 5 do  Result[i7] := MinSum[i7];

end;

//-----------------Расчёт переброса кубиков

Function MakeFull(RazborCorrect:TDices):Double;
var
RazrPrMan,RazrPrBot:Tdices;
I,J:Tdices;
k,Exits:Integer;
begin
  Result:=0;
  Exits:=0;
  RazrPrMan[0]:= RazborMan[0];
  RazrPrBot[0]:= RazborBot[0];  //Иногда становится не 0 , выход за гр. массива?
  for k:=1 to ManSecondThrow[0]+1 do J[k]:=1;
  Repeat
    for k:=1 to 7 do RazrPrMan[k]:= RazborMan[k]-ManSecondThrow[k];
    for k:=1 to ManSecondThrow[0] do inc(RazrPrMan[J[k]]);
    for k:=1 to RazborCorrect[0]+1 do I[k]:=1;
    Repeat
      for k:=1 to 7 do RazrPrBot[k]:= RazborBot[k]-RazborCorrect[k];
      for k:=1 to RazborCorrect[0] do inc(RazrPrBot[I[k]]);
      if not  BotHod  then Result:=Result+GetTree(RazrPrMan,RazrPrBot,False,True)[5]
                      else Result:=Result-GetTree(RazrPrBot,RazrPrMan,False,True)[5];
      inc(I[1]);
      inc(Exits);
    for k:=1 to RazborCorrect[0] do if I[k]>6 then
      begin
        I[k]:=1;  //Не 0!!
        inc(I[k+1]);
      end;
    until (I[RazborCorrect[0]+1]>1);
    inc(J[1]);
    for k:=1 to ManSecondThrow[0] do if J[k]>6 then
      begin
        J[k]:=1;
        inc(J[k+1]);
      end;
  until (J[ManSecondThrow[0]+1]>1);
  Result:=Result/Exits;
end;




Function MakeFast(var RazborCorrect:TDices):Double;   // Почти эквивалентен MakeFull
var RazrPrMan,RazrPrBot:Tdices;
i,j:Integer;
begin
  Result:=0;
  RazrPrMan[0]:= RazborMan[0];
  RazrPrBot[0]:= RazborBot[0];
  for i:=0 to 9999 do
    begin
      if BotHod and (not HardCoreMode) then  //Генерируем ход человека
        begin
          ManSecondThrow[0]:=0;
          for j:=1 to 6 do
            begin
              ManSecondThrow[j] := Random(ManSecondThrow[j]+1);
              inc(ManSecondThrow[0]);
            end;
        end;
      for j:=1 to 6 do
        begin
          RazrPrMan[j]:= RazborMan[j]-ManSecondThrow[j];
          RazrPrBot[j]:= RazborBot[j]-RazborCorrect[j];
        end;
      for j:=1 to ManSecondThrow[0] do inc(RazrPrMan[Random(6)+1]);
      for j:=1 to RazborCorrect[0] do inc(RazrPrBot[Random(6)+1]);
      if not  BotHod  then
      Result:=Result+1e-4*GetTree(RazrPrMan,RazrPrBot,False,True)[5]  //Задать опцию , что Tree не нужно, а Score очень даже.
      // А при ходе человека больше, тем лучше //не зря человек пытается минимум выцепить!
      else Result:=Result-1e-4*GetTree(RazrPrBot,RazrPrMan,False,True)[5]; //Может порядок и наоборот
      //При ходе бота чем меньше, тем лучше
    end;
end;



procedure SolveSecondThrow;
var I,IMax:Tdices;  j:Integer;
Score,ScoreMax : Double;
begin
  if BotString<>'' then exit;
  ScoreMax:=-1000;
  if BotHod and not Hardcoremode then  ManSecondThrow[0]:=0;
  for  j:= 1 to 7 do
  begin
    I[j]:=0;
    Imax[j] := 0;
  end;
  while I[6]<=RazborBot[6] - RazborBot[7] do
    begin
      i[0]:=0;
      for j:=1 to 6 do i[0]:=i[0]+i[j];
     // if BotHod then  Score := MakeFast(i,ManSecondThrow);

    if ((ManSecondThrow[0]=0) and (i[0]<7)) or ((ManSecondThrow[0]+i[0])<6)  and (not BotHod or Hardcoremode)
    then Score := MakeFull(i) //Может потом добавить <7 и т.д.
    else  Score := MakeFast(i); //10000 игр.  //And bothod
      if Score>ScoreMax then
                begin
                   ScoreMax:=Score;
                   for j:=0 to 6 do Imax[j]:=i[j];
                end;
      //Обработка шестимерного цикла.
      inc(i[1]);
      for j := 1 to 5 do
        if i[j]>RazborBot[j] then
          begin
            i[j]:=0;
            inc(i[j+1]);
          end;
      Application.ProcessMessages;
    end;
   for j:=1 to 6 do
     begin
        RazborBot[j]:=RazborBot[j]-Imax[j];
        RazborBotDr[j] := RazborBot[j];
        RazborMan[j]:=RazborMan[j]-ManSecondThrow[j];
     end;
   RazborBotDr[0] := -Imax[0];
   for j:=1 to Imax[0] do inc(RazborBot[Random(6)+1]);
   for j:=1 to ManSecondThrow[0] do inc(RazborMan[Random(6)+1]);
end;

function SecondThrowAnalisis:boolean;
var i:Integer; S:String;
begin
  //Result := False;
  //if BotString<>'' then exit;
  Result := True;
  S:=Form2.LabeledEdit1.Text;
  for I := 0 to 6 do ManSecondThrow[i] := 0;
  for I := 1 to Length(S) do
  if StrToInt(S[i])>0 then   //Если разрешить перебросить ноль, будет глючатинка.
    begin
      inc(ManSecondThrow[StrToInt(S[i])]);
      inc(ManSecondThrow[0]);
    end;
 for I := 0 to 6 do if  ManSecondThrow[i]>RazborMan[i] then Result:=False;
 if ManSecondThrow[6]>(RazborMan[6]-RazborMan[7]) then Result:=False;// Для 6 отдельная проверка.  Вычитать 6-7

end;


//-------------Вспомогательные вычисления

Function Razbor (var Dices: TDices) : TDices;
var i:Integer;
begin
   for i := 1 to 12 do Result[i] :=0;
   Result[0] := Dices[0];
   for i := 1 to Dices[0] do
     begin
       if Dices[i]>6 then  inc(Result[6]);  //+6 даёт запись и в 7 и в 6
       inc(Result[Dices[i]]);
     end;
end;

Procedure GetFirstHod;
var i:Integer;
begin
  BotHod := True;
  for i:=1 to 6 do
    if RazborMan[i]<>RazborBot[i]then
      begin
         if RazborMan[i]>RazborBot[i] then BotHod := False;
         break;
      end;
end;

Procedure GetScore(S1,S2 :TDices);
begin
  if S1[2]>=S2[3] then Scoreman := Scoreman+S1[4];       //Очки начисляются если акция состоялась. Акция состоялась если защата>=атаке.
  if S2[2]>=S1[3] then Scorebot := Scorebot+S2[4];
end;

Function MakeSum:TDices;
var PromDices:TDices; i:byte;
begin
   for I := 0 to 6 do  PromDices[i] := RazborMan[i];
   PromDices[3] := Min(RazborMan[2],Form2.SpinEdit1.Value);
   PromDices[2] := Max(0,RazborMan[2]-Form2.SpinEdit1.Value);
   RazborMan[2] := PromDices[2];
   RazborMan[3] := PromDices[3];
   Result := GetElemSum(PromDices);
end;

//Нет настоящей случайности т.к. диверсия убирает последние n карт.


//--------Генератор случайных чисел-------
Procedure Probros(NumberOfDiceMan,NumberOfDiceBot:Integer);
var i,j,FullStr:Integer;
CopyBotString : String;
begin
  if BotString<>'' then
    begin
      CopyBotString := BotString;
      FullStr := Length(BotString);
      NumberOfDiceBot := NumberOfDiceBot - 6 + FullStr;
    end;
  DiceMan[0] := NumberOfDiceMan+RazborMan[5];
  DiceBot[0] := NumberOfDiceBot+RazborBot[5];
  for i := 1 to NumberOfDiceMan do DiceMan[i] := Random(6) + 1;
  if BotString<>'' then
    for i := 1 to NumberOfDiceBot do
      begin
        j := Random(FullStr)+1;
        DiceBot[i] := StrtoInt(CopyBotString[j]);
        Delete(CopyBotString,j,1);
        Dec(FullStr);
      end
  else
    for i := 1 to NumberOfDiceBot do DiceBot[i] := Random(6) + 1;
  //Заполнение шестёрками
  for i := NumberOfDiceMan+1 to NumberOfDiceMan+RazborMan[5] do DiceMan[i] := 7;
  for i := NumberOfDiceBot+1 to NumberOfDiceBot+RazborBot[5] do DiceBot[i] := 7;

end;

Procedure Sortirovka(var Dices:TDices);  //Выбором
var
i,j : byte;
Min,Minzn :byte;
begin
  for I := 1 to Dices[0] do
    begin
    Minzn := i;
      for j := i+1 to Dices[0] do
        if Dices[MinZn]>Dices[j] then MinZn:=j;  //Поиск минимального элемента
    if Minzn>i then //Обмен
      begin
        Min := Dices[MinZn];
        Dices[MinZn] := Dices[i];
        Dices[i] := Min;
      end;
   end;
end;

//---Логгирование-----------
procedure WriteToLog(var S:String);
begin
  //Form2.Memo1.Lines.Add(S);
  WriteLn(FileLog,S);
end;
procedure ElemLog(var Dices: TDices; Sm:ShortInt=0);
var S:String;  i:Byte;
begin
  S:='';
  for I := 1+Sm to 6+Sm do  if Dices[i]>=0 then S:=S+ Chr($30+Dices[i])
                                           else S:=S+'-'+Chr($30-Dices[i]);
  WriteToLog(S);
end;

Procedure LabeledLog(var Dices: TDices; S:String;Sm:ShortInt=0);
begin
   WriteToLog(S);
   ElemLog(Dices,Sm);
end;



//------------------------Отображение---------------
procedure WriteToMemo(S:String);
begin
  Form2.Memo1.Lines.Add(S);
end;

procedure Draw2Defend(N:Byte; var Ed:TLabeledEdit);
var s:String;
begin
 case N of
        2: if (Ed.Text<>'') and (Ed.Text[High(Ed.Text)]=')')  then
          begin
            S:=Ed.Text;
            SetLength(S,Length(S)-1);
            Ed.Text := S+'2)';
          end
          else  Ed.Text := Ed.Text+'(2)';
        3: Ed.Text := Ed.Text+'2';
        7: Ed.Text := Ed.Text+'+6';
        else  Ed.Text := Ed.Text+Chr($30+N);
      end;
end;


Procedure DrawDices;
var i:Integer;
s:string;
PCapt:PCaption;
begin
  Form2.PlayerCombo.Text:='';
  for i := 1 to DiceMan[0] do  if DiceMan[i]<7 then Form2.PlayerCombo.Text:=Form2.PlayerCombo.Text+Chr($30+DiceMan[i])
                                               else Form2.PlayerCombo.Text:=Form2.PlayerCombo.Text+'+6';
  Form2.BotCombo.Text:='';
  for i := 1 to DiceBot[0] do
    if (BotString<>'') then Draw2Defend(DiceBot[i],Form2.BotCombo)
    else
      if DiceBot[i]<7  then Form2.BotCombo.Text := Form2.BotCombo.Text+Chr($30+DiceBot[i])
      else Form2.BotCombo.Text:=Form2.BotCombo.Text+'+6';

end;

Procedure RenewScore;
begin
  Form2.ManTablo.Text := IntToStr(ScoreMan);
  Form2.BotTablo.Text := IntToStr(ScoreBot);
end;




procedure DrawRazbor(var Dice:TDices; var Ed:TLabeledEdit);
var i,j:Integer;
begin
  Ed.Text:='';
  for i := 1 to 6 do
    for j := 1 to Dice[i] do
      if (Ed.Name='BotCombo') and (BotString<>'')  then Draw2Defend(i,Ed)
                                                   else Ed.Text:=Ed.Text+Chr($30+i);
  if (Dice[0]<0) then
    for j := 1 to (-Dice[0]) do  Ed.Text:=Ed.Text+'*';

end;

Procedure OutPutCombo(var Dices: TDices; S:String);
var i,j:Integer;
begin
  WriteToMemo(S);
  S:='';
  for i := 1 to 6 do
  begin
   if (i=2) and (Dices[i]>0) then S:=S+'(';
    for j := 1 to Dices[i] do
      if i=3 then S:=S+Chr($30+2)
             else S:=S+Chr($30+i);
   if (i=2) and (Dices[i]>0) then S:=S+')';
  end;
  WriteToMemo(S);
    //Form2.PlayerCombo.Text:=Form2.PlayerCombo.Text+Chr($30+i);
end;

procedure TForm2.Button2Click(Sender: TObject);
var j:Integer;
begin
  if GameStage=0 then
    begin
       randomize;
       RenewScore;
       //ScoreMan := 0;
       //ScoreBot := 0;
       RazborMan[5]:=0;
       RazborBot[5]:=0;
       Probros(6,6);
       Button2.Caption := 'Переброс';
    end;
   if (GameStage>0) and (GameStage<3) then
    begin
      S1:=MakeSum;
      OutPutCombo(RazborMan,'Ваше комбо:');
    end;
   if GameStage=1 then
     begin
       //Ход машины
        if BotString='' then
              begin
       MainTree := GetTree(RazborBot,S1,True); //Не забывать сохранять правильное дерево!
       LabeledLog(MainTree,'Дерево исходов:',-1);
       S2 := GetSum(RazborBot,MainTree); //Это всё правильно, но надо знать, что перебросила машина    //МОжет в GetSum ввести OutPut;
       RazborBot:=GetSum(RazborBot,MainTree,True);
              end
       else S2:=GetElemSum(RazborBot);
       OutPutCombo(RazborBot,'Итоговое комбо машины:');
     end;
   if (GameStage>0) and (GameStage<3) then
     begin
       GetScore(S1,S2);
       RenewScore;
       Probros(6-RazborBot[1],6-RazborMan[1]);
       BotHod:=not BotHod;
       Button2.Caption := 'Переброс';
     end;
       Sortirovka(DiceMan);
       Sortirovka(DiceBot);
       if GameStage<3 then
         begin
          DrawDices;
          RazborMan := Razbor(Diceman);
          RazborBot := Razbor(Dicebot);
         end;
       LabeledLog(RazborMan,'Количество кубиков у человека:');
       LabeledLog(RazborBot,'Количество кубиков у бота:');
       if GameStage=0 then  GetFirstHod;
       if GameStage>2 then
       begin
       if SecondThrowAnalisis then
         begin
          // Label2.Visible := True;
          // Label2.Repaint;
           if (BotString<>'') or (BotHod and (not HardcoreMode)) then
             begin
                for j:=1 to 6 do RazborMan[j]:=RazborMan[j]-ManSecondThrow[j];
                for j:=1 to ManSecondThrow[0] do inc(RazborMan[Random(6)+1]);
             end
           else
             begin
               Timer:=0;
               Timer1.Enabled := True;
               SolveSecondThrow;
               Timer1.Enabled := False;
             end;
           DrawRazbor(RazborBot,BotCombo);
           DrawRazbor(RazborMan,PlayerCombo);
         end
       else
         begin
           LabeledEdit1.Text :='';
           exit;
         end;
        Button2.Caption := 'Следующий ход';
       //Провести анализ переброса.
       if BotHod or Debug1 then
          begin
            WriteToMemo('Ход машины');
            if (not Debug1) then  GameStage := 2;
              if BotString='' then
              begin
            MainTree := GetTree(RazborBot,RazborMan);
            LabeledLog(MainTree,'Дерево исходов:',-1);

               S2 := GetSum(RazborBot,MainTree); //Это всё правильно, но надо знать, что перебросила машина    //МОжет в GetSum ввести OutPut;
               RazborBot:=GetSum(RazborBot,MainTree,True);
              end
              else S2:=GetElemSum(RazborBot);
            OutPutCombo(RazborBot,'Итоговое комбо машины:');
          end
       else
         begin
           WriteToMemo('Ход человека');
           GameStage := 1;
         end;
       end
       else
         begin
            GameStage:=3;
            if BotHod and not HardcoreMode then
              begin
                  Timer:=0;
                  Timer1.Enabled := True;
                  for j := 0 to 6 do ManSecondThrow[j] := 0;
                  SolveSecondThrow;
                  Timer1.Enabled := False;
                  if BotString='' then DrawRazbor(RazborBotDr,BotCombo);
              end;
         end;
       Button3.Visible := (GameStage<3) and (GameStage>0);
      // Label2.Visible := Button3.Visible;
       SpinEdit1.ReadOnly := not Button3.Visible;
       if Button3.Visible then LabeledEdit1.EditLabel.Caption := 'Конверсия(первая цифра что конвертируем , вторая - во что)'
                          else LabeledEdit1.EditLabel.Caption := 'Какие цифры перебрасываем';
      if (ScoreMan>5) or (ScoreBot>5) then
        if (ScoreMan<>ScoreBot) then
          begin
            GameStage := 0;
            Win := ScoreMan>ScoreBot;
            //---Очистка экрана
            Button2.Caption := 'Следующий ход';
            Memo1.Clear; //Очищаем лог
            Button2.Caption := 'Начать бой';
            ScoreMan :=0;
            ScoreBot :=0;
            PlayerCombo.Text := '';
            BotCombo.Text := '';
            LabeledEdit1.Text := '';
            Close;//Hide;
          end;
   // end;
end;

procedure TForm2.Button3Click(Sender: TObject);
var S:String; i1,i2:Byte;
begin
  S:=LabeledEdit1.Text;
  I1 := StrToint(S[1]);
  I2 := StrToint(S[2]);
  if RazborMan[3]>0 then
    begin
      Dec(RazborMan[3]);
      if RazborMan[i1]>0 then
        begin
          Dec(RazborMan[i1]);
          Inc(RazborMan[i2]);
        end;
      DrawRazbor(RazborMan,Form2.PlayerCombo);
    end;


end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //CloseFile(FileLog);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  AssignFile(FileLog,'Log.txt');
  Rewrite(FileLog);

end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  Timer:= Timer+0.5;
  Label2.Caption:=FloatToStrF(Timer,ffGeneral,3,3);
  Label2.Refresh;
end;

begin

end.
