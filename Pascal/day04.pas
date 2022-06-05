Program AOC_2020_Day04;
{$mode objfpc} // directive to be used for defining classes
{$m+}          // directive to be used for using constructor

Uses SysUtils, StrUtils, AoCUtils, fgl, RegExpr;

Type
    TMap = Specialize TFPGMap<String, String>;
    Passport = Class
        Private
            cid, byr, iyr, eyr, pid: LongInt;
            hgt, hcl, ecl: String;
            src: TMap;
            eyecolors: TMap; Static;
            hclre: TRegExpr; Static;
        Public
            Constructor Create(data: TMap);
            Function HasRequiredFields(): Boolean;
            Function IsValid(): Boolean;
            Function HgtIsValid(): Boolean;
            Function HclIsValid(): Boolean;
            Function EclIsValid(): Boolean;
            Function DebugStr(): String;
    End;
Const
    IN_FILE = 'input/04.challenge.txt';

Var
    input: AoCGStringArray;
    passports: array of Passport;


// Passport Implementation ----------------------------

Constructor Passport.Create(data: TMap);
Var
    idx: Integer;
Begin
    src := data;
    If data.IndexOf('pid') >= 0 Then
        If TryStrToInt(data['pid'], pid) = False Then pid := -1;
    If data.IndexOf('byr') >= 0 Then
        If TryStrToInt(data['byr'], byr) = False Then byr := -1;
    If data.IndexOf('iyr') >= 0 Then
        If TryStrToInt(data['iyr'], iyr) = False Then iyr := -1;
    If data.IndexOf('eyr') >= 0 Then
        If TryStrToInt(data['eyr'], eyr) = False Then eyr := -1;
    If data.IndexOf('hgt') >= 0 Then
        hgt := data['hgt'];
    If data.IndexOf('hcl') >= 0 Then
        hcl := data['hcl'];
    If data.IndexOf('ecl') >= 0 Then
        ecl := data['ecl'];
    If data.IndexOf('cid') >= 0 Then
        cid := StrToInt(data['cid']);
End;

Function Passport.HasRequiredFields(): Boolean;
Begin
    result := (pid <> 0) And (byr <> 0) And (iyr <> 0) And (eyr <> 0)
        And (hgt <> '') And (hcl <> '') And (ecl <> '');
End;

Function Passport.IsValid(): Boolean;
Begin
    result := False;
    If HasRequiredFields = False Then Exit;
    If (byr < 1920) Or (byr > 2002) Then Exit;
    If (iyr < 2010) Or (iyr > 2020) Then Exit;
    If (eyr < 2020) Or (eyr > 2030) Then Exit;
    If HgtIsValid = False Then Exit;
    If HclIsValid = False Then Exit;
    If EclIsValid  = False Then Exit;
    If Length(src['pid']) <> 9 Then Exit;
    result := True;
End;

Function Passport.HgtIsValid(): Boolean;
Var
    value: Integer;
Begin
    result := True;
    If RightStr(hgt, 2) = 'in' Then
        Begin
            value := StrToInt(ReplaceStr(hgt, 'in', ''));
            If (value >= 59) And (value <= 76) Then Exit
        End
    Else If RightStr(hgt, 2) = 'cm' Then
        Begin
            value := StrToInt(ReplaceStr(hgt, 'cm', ''));
            If (value >= 150) And (value <= 193) Then Exit
        End;
    result := False;
End;

Function Passport.HclIsValid(): Boolean;
Begin
    result := False;
    If Assigned(hclre) = False then
        Begin
            hclre := TRegExpr.Create;
            hclre.Expression := '#[a-f0-9]{6}';
        End;
    If hclre.Exec(hcl) Then result := True;
End;

Function Passport.EclIsValid(): Boolean;
Var
    cl: String;
Begin
    result := False;
    If eyecolors = Nil Then
        Begin
            eyecolors := TMap.Create;
            For cl in ['amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth'] Do
                eyecolors[cl] := cl;
        End;
    If eyecolors.IndexOf(ecl) >= 0 Then result := True;
End;

Function Passport.DebugStr(): String;
Begin
    result := Format('Passport(pid:%d byr:%d iyr:%d eyr:%d hgt:%s hcl:%s ecl:%s cid:%d)',
        [pid, byr, iyr, eyr, hgt, hcl, ecl, cid]);
End;

// End Passport Implementation ------------------------

Procedure ParsePassports();
Var
    i, j, k: Integer;
    attrs, keyval: TStringArray;
    map: TMap;
Begin
    SetLength(passports, Length(input));
    For i := 0 To Length(input)-1 Do
    Begin
        map := TMap.Create;
        For j := 0 to Length(input[i])-1 Do
        Begin
            attrs := SplitString(input[i][j], ' ');
            For k := 0 To Length(attrs)-1 Do
            Begin
                keyval := SplitString(attrs[k], ':');
                map[keyval[0]] := keyval[1];
            End;
        End;
        passports[i] := Passport.Create(map);
        //WriteLn(passports[i].DebugStr);
    End;
End;

Procedure SolvePart1();
Var
    i, count: Integer;
Begin
    WriteLn('Part 1: Check for passports that have all required fields.');
    count := 0;
    For i := 0 To Length(passports)-1 Do
        If passports[i].HasRequiredFields Then
            inc(count);
    WriteLn(Format('Part One Solution: %d complete passports', [count]));
End;

Procedure SolvePart2();
Var
    i, count: Integer;
Begin
    WriteLn('Part 2: Check for valid passports.');
    count := 0;
    For i := 0 To Length(passports)-1 Do
        If passports[i].IsValid Then
            inc(count);
    WriteLn(Format('Part Two Solution: %d valid passports', [count]));
End;

Begin
    input := ReadGroupedInput(IN_FILE);
    ParsePassports;
    SolvePart1();
    SolvePart2();
End.
