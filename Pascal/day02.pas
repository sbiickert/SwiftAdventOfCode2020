Program AOC_2020_Day02;
{$mode objfpc} // directive to be used for defining classes
{$m+}          // directive to be used for using constructor

Uses SysUtils, StrUtils, AoCUtils;

Type
    Password = Class
        Private
            min, max: Integer;
            chr: String;
            value: String;
        Public
            Constructor Create(line: String);
            Function IsValidPart1(): Boolean;
            Function IsValidPart2(): Boolean;
            Function DebugStr(): String;
    End;

Const
    IN_FILE = 'input/02.challenge.txt';
Var
    input: AoCStringArray;
    passwords: array of Password;

Procedure ParsePasswords();
Var
    i: Integer;
Begin
    SetLength(passwords, Length(input));
    For i := 0 To Length(input)-1 Do
    Begin
        passwords[i] := Password.Create(input[i]);
        //WriteLn(passwords[i].DebugStr);
    End;
End;

Procedure SolvePart1(values: AoCStringArray);
Var
    i, count: Integer;
Begin
    WriteLn('Part 1: How many passwords have the right number of chr?');
    count := 0;
    For i := 0 To Length(passwords)-1 Do
        If passwords[i].IsValidPart1 Then
            inc(count);
    WriteLn(Format('Part One Solution: %d passwords are valid.', [count]));
End;

Procedure SolvePart2(values: AoCStringArray);
Var
    i, count: Integer;
Begin
    WriteLn('Part 2: How many passwords have 1 chr in min or max position?');
    count := 0;
    For i := 0 To Length(passwords)-1 Do
        If passwords[i].IsValidPart2 Then
            inc(count);
    WriteLn(Format('Part Two Solution: %d passwords are valid.', [count]));
End;

// Begin Password Implementation -------------------

{
    Parses the line and populates private vars.
    min-max chr: value
}
Constructor Password.Create(line: String);
Var
    parts: TStringArray;
    minmax: TStringArray;
Begin
    parts := SplitString(line, ' ');
    minmax := SplitString(parts[0], '-');
    min := StrToInt(minmax[0]);
    max := StrToInt(minmax[1]);
    chr := LeftStr(parts[1], 1);
    value := parts[2];
End;

Function Password.IsValidPart1(): Boolean;
Var
    i, count: Integer;
Begin
    count := 0;
    result := False;
    For i := 1 To Length(value) Do
        If chr = value[i] Then
            inc(count);
    If (count <= max) And (count >= min) Then
        result := True
End;

Function Password.IsValidPart2(): Boolean;
Var
    count: Integer;
Begin
    result := False;
    count := 0;
    If value[min] = chr Then inc(count);
    If value[max] = chr Then inc(count);
    If count = 1 Then result := True;
End;

Function Password.DebugStr(): String;
Begin
    result := Format('Password(%d-%d %s: %s)', [min, max, chr, value]);
End;

// End Password Implementation

Begin
    input := ReadInput(IN_FILE);
    ParsePasswords;
    SolvePart1(input);
    SolvePart2(input);
End.
