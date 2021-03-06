unit settingsHelper;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, XML.VerySimple,
  Vcl.StdCtrls, Vcl.Samples.Spin, addresses;


type

  TExplodeArray = array of String;

  TxmlDataType = ( xdStatic, xdBoolean, xdInteger, xdRange, xdList, xdText,
                   xdTextList, xdScript, xdWayPoint, xdComboBox, xdRangePercent,
                   xdSubitem, xdMonster, xdDimension );
  TTreeData = record
    name: string;
    value: string;
    dataType: TxmlDataType;
    FirstRun: boolean; //for scripts, True: if it hasn't been run in Lua
    TimerStarted: boolean; //for scripts, True: we have already created the Timer
  end;


function FindIndex(control: TComboBox; value: string): integer;
function StringToCaseSelect(Selector : string; CaseList: array of string): Integer;
function Explode(const cSeparator, vString: String): TExplodeArray;
procedure ComboAddItems(control: TComboBox; value: string);
implementation

uses
  unit1;

function FindIndex(control: TComboBox; value: string): integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to control.Items.Count - 1 do
  begin
    if lowercase(control.Items[i]) = lowercase(value) then
    begin
      result := i;
      break;
    end;
  end;
end;

function StringToCaseSelect(Selector : string; CaseList: array of string): Integer;
var
  cnt: integer;
begin
   Result:=-1;
   for cnt:=0 to Length(CaseList)-1 do
   begin
     if CompareText(Selector, CaseList[cnt]) = 0 then
     begin
       Result:=cnt;
       Break;
     end;
   end;
end;

function Explode(const cSeparator, vString: String): TExplodeArray;
var
  i: Integer;
  S: String;
begin
  S := vString;
  SetLength(Result, 0);
  i := 0;
  while Pos(cSeparator, S) > 0 do begin
    SetLength(Result, Length(Result) +1);
    Result[i] := Copy(S, 1, Pos(cSeparator, S) -1);
    Inc(i);
    S := Copy(S, Pos(cSeparator, S) + Length(cSeparator), Length(S));
  end;
  SetLength(Result, Length(Result) +1);
  Result[i] := Copy(S, 1, Length(S));
end;

procedure ComboAddItems(control: TComboBox; value: string);
var
  node: TXmlNode;
  spell: string;
begin

  case StringToCaseSelect(value,
      ['AlarmOn', 'EventType', 'LootingCondition', 'LootingPolicy', 'WalkingMethod',
       'RopeToUse', 'ShovelToUse', 'OpenNextBp', 'OpenBpsAtLogin', 'HealMethod',
       'ExtraCondition', 'TrainSpell', 'ComboType', 'HotkeyCondition', 'HudPolicy',
       'KeyboardMode', 'StuckCtrlShiftPolicy', 'MouseMode', 'ScrollMode',
       'StuckCursorPolicy', 'MoveSpeed', 'FocusPolicy', 'OpenMenuPolicy',
       'Count', 'MonsterAttacks', 'DesiredStance', 'CustomDistance', 'DesiredAttack',
       'FirstSpell', 'SecondSpell', 'ThirdSpell', 'FourthSpell', 'AttackMode',
       'RangeDistance']) of

    0: // AlarmOn
      begin
        control.Items.Add('No Alarm');
        control.Items.Add('Loot Announced');
        control.Items.Add('Couldn''t Loot');
      end;

    1: // EventType
      begin
        control.Items.Add('Normal Event');
        control.Items.Add('Urgent Event');
      end;

    2: // LootingCondition
      begin
        control.Items.Add('Open all corpses');
        control.Items.Add('Open targeting corpses');
        control.Items.Add('Open corpses with listed items');
      end;

    3: // LootingPolicy
      begin
        control.Items.Add('Loot after melee kill');
        control.Items.Add('Loot after all dead');
      end;

    4: // WalkingMethod
      begin
        control.Items.Add('Walk with arrow keys');
        control.Items.Add('Walk with map clicks');
      end;

    5: // RopeToUse
      begin
        control.Items.Add('Rope');
        control.Items.Add('Elvenhari rope');
        control.Items.Add('Driller');
      end;

    6: // ShovelToUse
      begin
        control.Items.Add('Shovel');
        control.Items.Add('Light shovel');
        control.Items.Add('Driller');
      end;

    7: // OpenNextBp
      begin
        control.Items.Add('no');
        control.Items.Add('yes');
        control.Items.Add('If cavebot enabled');
      end;

    8: // OpenBpsAtLogin
      begin
        control.Items.Add('no');
        control.Items.Add('yes');
        control.Items.Add('Open and minimize');
        control.Items.Add('Open and size small');
      end;

    9: // HealMethod
      begin

        for spell in settingsHealMethod do
        begin
          control.Items.Add(spell);
        end;

      end;

    10: // ExtraCondition               --> we should add more here!
      begin
        control.Items.Add('No condition');
        control.Items.Add('If paralyzed');
        control.Items.Add('If strengthened');
        control.Items.Add('If not strengthened');
      end;

    11: // TrainSpell
      begin
        // �adowanie czar�w oraz food    --Charging spells and food
        // ...            food? wat�?  o.O
        //control.Items.Add('Food');

        for spell in settingsManaTrainMethod do
        begin
          control.Items.Add(spell);
        end;
      end;

    12: // ComboType
      begin
        control.Items.Add('Must be pressed');
        control.Items.Add('Must be depressed');
      end;

    13: // HotkeyCondition
      begin
        control.Items.Add('Client focus not required');
        control.Items.Add('Client focus required');
      end;

    14: // HudPolicy
      begin
        control.Items.Add('Show if focused');
        control.Items.Add('Hide Hud');
        control.Items.Add('Show Hud');
      end;

    15: // KeyboardMode
      begin
        //control.Items.Add('Control keyboard');
        control.Items.Add('Simulate keyboard');
      end;

    16: // StuckCtrlShiftPolicy
      begin
        control.Items.Add('Do nothing');
        control.Items.Add('Release instantly');
        control.Items.Add('Release after 1 sec');
        control.Items.Add('Release after 2 sec');
        control.Items.Add('Release after 3 sec');
        control.Items.Add('If cavebot on, release instantly');
        control.Items.Add('If cavebot on, release after 1 sec');
        control.Items.Add('If cavebot on, release after 2 sec');
        control.Items.Add('If cavebot on, release after 3 sec');
      end;

    17: // MouseMode
      begin
        //control.Items.Add('Control mouse');
        control.Items.Add('Simulate mouse');
      end;

    18: // ScrollMode
      begin
        control.Items.Add('Click on scrollbar');
        control.Items.Add('Use mouse wheel');
      end;

    19: // StuckCursorPolicy
      begin
        control.Items.Add('Do nothing');
        control.Items.Add('Release instantly');
        control.Items.Add('Release after 1 sec');
        control.Items.Add('Release after 2 sec');
        control.Items.Add('Release after 3 sec');
        control.Items.Add('If cavebot on, release instantly');
        control.Items.Add('If cavebot on, release after 1 sec');
        control.Items.Add('If cavebot on, release after 2 sec');
        control.Items.Add('If cavebot on, release after 3 sec');
      end;

    20: // MoveSpeed
      begin
        control.Items.Add('1');
        control.Items.Add('2');
        control.Items.Add('3');
        control.Items.Add('4');
        control.Items.Add('5');
        control.Items.Add('6');
        control.Items.Add('7');
        control.Items.Add('8');
        control.Items.Add('9');
        control.Items.Add('Instantaneous');
      end;

    21: // FocusPolicy
      begin
        control.Items.Add('Don''t auto-focus');
        control.Items.Add('Focus on any event');
        control.Items.Add('Focus on any except moving');
        control.Items.Add('Focus on urgent only');
      end;

    22: // OpenMenuPolicy
      begin
        control.Items.Add('Do nothing');
        control.Items.Add('Confirm menu');
        control.Items.Add('Close menu');
        control.Items.Add('Confirm after 2 secs');
        control.Items.Add('Close after 2 secs');
        control.Items.Add('Confirm after 5 secs');
        control.Items.Add('Close after 5 secs');
        control.Items.Add('Confirm if cavebotting');
        control.Items.Add('Close if cavebotting');
        control.Items.Add('Confirm if mouse idle');
        control.Items.Add('Close if mouse idle');
      end;

    23: // Count
      begin
        control.Items.Add('Any');
        control.Items.Add('1');
        control.Items.Add('2+');
        control.Items.Add('2');
        control.Items.Add('3+');
        control.Items.Add('3');
        control.Items.Add('4+');
        control.Items.Add('4');
        control.Items.Add('5+');
        control.Items.Add('5');
        control.Items.Add('6+');
        control.Items.Add('6');
        control.Items.Add('7+');
        control.Items.Add('7');
        control.Items.Add('8+');
        control.Items.Add('8');
        control.Items.Add('9+');
        control.Items.Add('9');
      end;

    24: // MonsterAttacks
      begin
        control.Items.Add('No Avoidance');
        control.Items.Add('Avoid Wave');
        control.Items.Add('Avoid Beam');
      end;

    25: // DesiredStance
      begin
        control.Items.Add('No Movement');
        control.Items.Add('Keep Away');
        control.Items.Add('Away in Line');
        control.Items.Add('Reach');
        control.Items.Add('Reach & Parry'); // "&amp;"--> Ampersand = "&"
      end;

    26: // CustomDistance
      begin
        control.Items.Add('Default');
        control.Items.Add('1');
        control.Items.Add('2');
        control.Items.Add('3');
        control.Items.Add('4');
        control.Items.Add('5');
        control.Items.Add('6');
        control.Items.Add('7');
      end;

    27: // DesiredAttack
      begin
        control.Items.Add('Attack');
      end;

    28: // FirstSpell
      begin
        control.Items.Add('No Action');
        control.Items.Add('No Avoidance');  //Sudden Death, attack spells? same for 2,3,4�
      end;

    29: // SecondSpell
      begin
        control.Items.Add('No Action');
      end;

    30: // ThirdSpell
      begin
        control.Items.Add('No Action');
      end;

    31: // FourthSpell
      begin
        control.Items.Add('No Action');
      end;

    32: // AttackMode
      begin
        control.Items.Add('No Change');
        control.Items.Add('Chase/Offensive');
        control.Items.Add('Stand/Offensive');
        control.Items.Add('Chase/Defensive');
        control.Items.Add('Stand/Defensive');
      end;

    33: // RangeDistance
      begin
        control.Items.Add('1');
        control.Items.Add('2');
        control.Items.Add('3');
        control.Items.Add('4');
        control.Items.Add('5');
        control.Items.Add('6');
        control.Items.Add('7');
      end;

  end;

end;

end.
