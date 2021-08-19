Program Story;
var
Blocks : Array of TBlock;
begin
SetLength(Blocks,100);
Blocks[0].Logic; // Логический блок без текста
Blocjs[0].SetImage('a1.jpg');
Blocks[0].SetNextFight(12,0,3);  // Первое значение-номер следующего парагафа. Игрок начинает с 0 а бот начинает с 3
Blocks[0].AddNext(15); //Cледующий параграф 15
Blocks[0].Title('Сталеваринск');
Blocks[0].Text('
<p> Абзац 1
<p> Абзац 2 
<p> Абзац 3 
');
Blocks[12].SetEvenCombo('123456'); //Если предопределённая комбинация для чётных ходов
Blocks[12].SetOddCombo('123456'); //Если 
end.