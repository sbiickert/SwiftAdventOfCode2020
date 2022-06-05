// Utility module for Advent of Code
{$mode objfpc} // directive to be used for defining classes
{$m+}          // directive to be used for using constructor

Unit aocutils;

Interface

Uses SysUtils, StrUtils;


Type
    AoCIntArray = array Of Integer;
    AoCStringArray =   array Of String;
    AoCGStringArray =   array Of AoCStringArray;
    Coord2D =   Class
        Private
            _x, _y:   Integer;
        Public
            Constructor Create(x, y: Integer);
            Function GetX(): Integer;
            Function GetY(): Integer;
            Function Equals(other: Coord2D): Boolean;
            Function DeltaTo(other: Coord2D): Coord2D;
            Function DistanceTo(other: Coord2D): Double;
            Function ManhattanDistanceTo(other: Coord2D): Integer;
            Function DebugStr(): String;
    End;
    Coord2DArray =   array Of Coord2D;

Function ReadInput(inputFilename: String):   AoCStringArray;
Function ReadGroupedInput(inputFilename: String):   AoCGStringArray;
Function StrArrayToIntArray(var input: AoCStringArray): AoCIntArray;

Implementation

{
    Reads the text from inputFilename, assuming no empty lines.
    Returns an AoCStringArray of the lines up to the first empty line or EOF.
}
Function ReadInput(inputFilename: String):   AoCStringArray;

Var
    gString:   AoCGStringArray;
Begin
    gString := ReadGroupedInput(inputFilename);
    result := gString[0];
End;

{
    Reads the text from inputFilename, breaking into groups on empty lines.
    Returns an AoCGStringArray (i.e. an array of AoCStringArrays).
}
Function ReadGroupedInput(inputFilename: String):   AoCGStringArray;

Var
    inputFile:   TextFile;
    line:   String;
    group:   AoCStringArray;
Begin
    If FileExists(inputFilename) = False Then
    Begin
        WriteLn('File ', inputFilename, ' does not exist.');
        Exit;
    End;

    WriteLn('Will read data from: ', inputFilename);
    Assign(inputFile, inputFilename);
    Reset(inputFile);
    SetLength(result, 0);
    SetLength(group, 0);

    // Make sure the ANSI string compiler flag is on, or will trunc at 255!
    While Not Eof(inputFile) Do
        Begin
            ReadLn(inputFile, line);
            //WriteLn(line);
            If Length(line) = 0 Then
                Begin
                    SetLength(result, Length(result)+1);
                    result[Length(result)-1] := group;
                    SetLength(group, 0);
                    continue;
                End;
            SetLength(group, Length(group)+1);
            group[Length(group)-1] := line;
        End;

    If Length(group) > 0 Then
        Begin
            SetLength(result, Length(result)+1);
            result[Length(result)-1] := group;
        End;

    Close(inputFile);
End;

{ Utility function to transform an array of strings to ints }
Function StrArrayToIntArray(var input: AoCStringArray): AoCIntArray;
Var
    i: Integer;
Begin
    SetLength(result, Length(input));
    For i := 0 To Length(input)-1 Do
    Begin
        result[i] := StrToInt(input[i]);
    End;
End;

// Coord2D -----------------------------------------

Constructor Coord2D.Create(x, y: Integer);
Begin
    _x := x;
    _y := y;
End;

Function Coord2D.GetX(): Integer;
Begin
    result := _x;
End;

Function Coord2D.GetY(): Integer;
Begin
    result := _y;
End;

Function Coord2D.Equals(other: Coord2D):   Boolean;
Begin
    If (GetX = other.GetX) And (GetY = other.GetY) Then
        result := true
    Else
        result := false;
End;

Function Coord2D.DeltaTo(other: Coord2D): Coord2D;
Begin
    result := Coord2D.Create(other.GetX - GetX, other.GetY - GetY);
End;

Function Coord2D.DistanceTo(other: Coord2D): Double;
Var
    delta: Coord2D;
Begin
    delta := DeltaTo(other);
    result := Sqrt(Sqr(delta.GetX) + Sqr(delta.GetY));
End;

Function Coord2D.ManhattanDistanceTo(other: Coord2D): Integer;
Var
    delta: Coord2D;
Begin
    delta := DeltaTo(other);
    result := Abs(delta.GetX) + Abs(delta.GetY);
End;

Function Coord2D.DebugStr(): String;
Begin
    result := Format('Coord2D(%d,%d)', [ _x, _y]);
End;

End.
