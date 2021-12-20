program Project1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  System.RegularExpressions,
  System.Math;

{Simulates one step}
procedure Sim(
  var positionX: integer;
  var positionY: integer;
  var velocityX: integer;
  var velocityY: integer;
  var maxY: integer
  );
begin
  positionX := positionX + velocityX;
  positionY := positionY + velocityY;
  if(velocityX > 0) then begin
    velocityX := velocityX - 1;
  end
  else if(velocityX < 0) then begin
    velocityX := velocityX + 1;
  end;
  velocityY := velocityY -1;

  maxY := Max(maxY, positionY);
end;

function IsInside(
  const positionX: integer;
  const positionY: integer;
  const areaXFrom: integer;
  const areaYFrom: integer;
  const areaXTo: integer;
  const areaYTo: integer
): boolean;
begin
  Result := (positionX >= areaXFrom) And (positionX <= areaXTo) And (positionY >= areaYFrom) And (positionY <= areaYTo);
end;

function Simulate(
  const initVelocityX: integer;
  const initVelocityY: integer;
  const areaXFrom: integer;
  const areaYFrom: integer;
  const areaXTo: integer;
  const areaYTo: integer;
  var maxY: integer
  ) : boolean;
var
  currentPosX: integer;
  currentPosY: integer;
  currentVelocityX: integer;
  currentVelocityY: integer;
begin
  currentPosX := 0;
  currentPosY := 0;
  currentVelocityX := initVelocityX;
  currentVelocityY := initVelocityY;
  maxY := 0;

  repeat
    Sim(currentPosX, currentPosY, currentVelocityX, currentVelocityY, maxY);
    if(IsInside(currentPosX, currentPosY, areaXFrom, areaYFrom, areaXTo, areaYTo)) then begin
      Exit(true)
    end;
  until (currentPosY < areaYFrom) or (currentPosX > areaXTo);

  Result := false;
end;

function ExtractNumbers(const s: string): TArray<integer>;
var
    match: TMatch;

    regex: TRegEx;    matches: TMatchCollection;
    i: Integer;
begin
    Result := nil;
    i := 0;
    regex := TRegEx.Create('-?[0-9]\d*');
    matches := regex.Matches(s);
    if matches.Count > 0 then
    begin
        SetLength(Result, matches.Count);
        for match in matches do
        begin
            Result[i] := integer.Parse(match.Value);
            Inc(i);
        end;
    end;
end;

function FileLoad(const Filename: String; const Encoding: TEncoding = nil): String;
begin
  Result := TFile.ReadAllText(FileName, TEncoding.ANSI);
end;

var
  fileName: String;
  fileContent: String;
  numbers: TArray<integer>;
  simulationResult: boolean;
  overallMaxY: integer;
  maxY: integer;
  iX, iY: integer;
  distinctVelocities: integer;
begin
  fileName := 'input.txt';

  overallMaxY:=0;
  try
    fileContent := FileLoad(fileName);
    writeln(fileContent);

    numbers := ExtractNumbers(fileContent);

    for iX := -1000 to 1000 do begin
      for iY := -1000 to 1000 do begin
        maxY := 0;
        simulationResult := Simulate(iX, iY, numbers[0], numbers[2], numbers[1], numbers[3], maxY);
        if(simulationResult) then begin
          distinctVelocities := distinctVelocities + 1;
          overallMaxY := Max(overallMaxY, maxY);
        end;
      end;
    end;

    writeln('Part 1: Max Heights: ', overallMaxY);
    writeln('Part 2: Distinct Velocities ', distinctVelocities);
    ReadLn;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.




