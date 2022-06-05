Program AOC_2020_Day01;

Uses SysUtils, AoCUtils;

Const
    IN_FILE = 'input/01.challenge.txt';
    TARGET = 2020;

Var
    input: AoCStringArray;
    inputValues: AoCIntArray;

Procedure SolvePart1(values: AoCIntArray);
Var
    a, b: Integer;
Begin
    WriteLn('Part 1: find two numbers adding to ', TARGET);
    For a := 0 To Length(values)-2 Do
        For b := a + 1 To Length(values)-1 Do
            If values[a] + values[b] = TARGET Then
            Begin
                WriteLn(Format('%d and %d sum to %d', [values[a], values[b], TARGET]));
                WriteLn('The product is ', (values[a] * values[b]));
                Break;
            End;
End;

Procedure SolvePart2(values: AoCIntArray);
Var
    a, b, c: Integer;
Begin
    WriteLn('Part 2: find three numbers adding to ', TARGET);
    For a := 0 To Length(values)-3 Do
        For b := a + 1 To Length(values)-2 Do
            For c := b + 1 To Length(values)-1 Do
                If values[a] + values[b] + values[c] = TARGET Then
                Begin
                    WriteLn(Format('%d + %d + %d = %d', [values[a], values[b], values[c], TARGET]));
                    WriteLn('The product is ', (values[a] * values[b] * values[c]));
                    Break;
                End;
End;


Begin
    input := ReadInput(IN_FILE);
    inputValues := StrArrayToIntArray(input);
    SolvePart1(inputValues);
    SolvePart2(inputValues);
End.