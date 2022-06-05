Program AOC_2020_Day03;
{$mode objfpc} // directive to be used for defining classes
{$m+}          // directive to be used for using constructor

Uses SysUtils, StrUtils, AoCUtils;

Const
    IN_FILE = 'input/03.challenge.txt';

Var
    input: AoCStringArray;

Function DescendSlope(var forest: AoCStringArray; dx, dy: Integer): Integer;
Var
    x, y: Integer;
    width: Integer;
Begin
    result := 0;
    x := 1;
    y := 0;
    width := Length(forest[0]);
    While y < Length(forest) Do
    Begin
        If x > width Then
            x := x - width;
        If forest[y][x] = '#' Then inc(result);
        x := x + dx;
        y := y + dy;
    End;
End;

Procedure SolvePart1(forest: AoCStringArray);
Var
    hits: Integer;
Begin
    WriteLn('Part 1: How many trees will you hit?');
    hits := DescendSlope(forest, 3, 1);
    WriteLn(Format('Part One Solution: hit %d trees.', [hits]));
End;

Procedure SolvePart2(forest: AoCStringArray);
Var
    hits: Integer;
    product: Int64;
Begin
    WriteLn('Part 2: Try multiple slopes and multiply together');
    product := 1;
    hits := DescendSlope(forest, 1, 1);
    WriteLn(Format('Hit %d trees at dx %d, dy %d', [hits, 1, 1]));
    product := product * hits;
    hits := DescendSlope(forest, 3, 1);
    WriteLn(Format('Hit %d trees at dx %d, dy %d', [hits, 3, 1]));
    product := product * hits;
    hits := DescendSlope(forest, 5, 1);
    WriteLn(Format('Hit %d trees at dx %d, dy %d', [hits, 5, 1]));
    product := product * hits;
    hits := DescendSlope(forest, 7, 1);
    WriteLn(Format('Hit %d trees at dx %d, dy %d', [hits, 7, 1]));
    product := product * hits;
    hits := DescendSlope(forest, 1, 2);
    WriteLn(Format('Hit %d trees at dx %d, dy %d', [hits, 1, 2]));
    product := product * hits;

    WriteLn(Format('Part Two Solution: %d', [product]));
End;


Begin
    input := ReadInput(IN_FILE);
    SolvePart1(input);
    SolvePart2(input);
End.
