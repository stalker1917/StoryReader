Program Story;
var
Blocks : Array of TBlock;
begin
SetLength(Blocks,100);
Blocks[0].Logic; // ���������� ���� ��� ������
Blocjs[0].SetImage('a1.jpg');
Blocks[0].SetNextFight(12,0,3);  // ������ ��������-����� ���������� ��������. ����� �������� � 0 � ��� �������� � 3
Blocks[0].AddNext(15); //C�������� �������� 15
Blocks[0].Title('������������');
Blocks[0].Text('
<p> ����� 1
<p> ����� 2 
<p> ����� 3 
');
Blocks[12].SetEvenCombo('123456'); //���� ��������������� ���������� ��� ������ �����
Blocks[12].SetOddCombo('123456'); //���� 
end.