unit Hotkey;

interface

type
  TTibiaHotkey = class
    private
      _ID: Integer;
      function GetSendAuto: Boolean;
      function GetText: String;
      function GetObjectId: Integer;
      function GetType: Integer;
      function GetId: Integer;
      procedure SetId(Value: Integer);
    public
      function Find( text: string ): integer; overload;
      function Find( itemId: integer ): integer; overload;

      property ID: Integer read GetId write SetId default 1;
      property SendAutomatically: Boolean read GetSendAuto;
      property Text: String read GetText;
      property ObjectID: Integer read GetObjectId;
      property ObjectType: Integer read GetType;      //2-self;1-target;0-crosshairs
      procedure ExecuteHotkey;
  end;

implementation

uses unit1, addresses, Dialogs, Windows, SysUtils, Inputer;

procedure TTibiaHotkey.ExecuteHotkey;
var
  ModifierValue: Integer;
begin
  ModifierValue := ID div 12;
  case ModifierValue of
  1:
  begin
    Inputer.SendKeyDown(VK_SHIFT);
    sleep(50);
    Inputer.SendKeyDown(112 + ID - 12);
    sleep(50);
    Inputer.SendKeyUp(112 + ID - 12);
    sleep(50);
    Inputer.SendKeyUp(VK_SHIFT);
  end;
  2:
  begin
    Inputer.SendKeyDown(VK_CONTROL);
    sleep(50);
    Inputer.SendKeyDown(112 + ID - 24);
    sleep(50);
    Inputer.SendKeyUp(112 + ID - 24);
    sleep(50);
    Inputer.SendKeyUp(VK_CONTROL);
  end;
  else
  begin
    Inputer.SendKeyDown(112 + ID);
    sleep(50);
    Inputer.SendKeyUp(112 + ID);
    sleep(50);
  end;
  end;
end;

function TTibiaHotkey.Find( text: string ): integer;
var
  i: integer;
  value: string;
begin

  result := -1;
  for i := 0 to hotkeyMaxHotkeys-1 do  //hay que tener en  cuenta que empieza en 0 el F1!
                                        //por lo tanto no hay 36 teclas, sino 35 ahora.
  begin
    value := Memory.ReadString(Integer(ADDR_BASE) +  Addresses.hotkeyTextStart + (i * Addresses.hotkeyTextStep));
    if lowercase(text) = lowercase(value) then
    begin
      result := i;
      break;
    end;
  end;

end;

function TTibiaHotkey.Find( itemId: integer ): integer;
var
  i: integer;
  value: integer;
begin

  result := -1;
  for i := 0 to hotkeyMaxHotkeys-1 do
  begin
    value := Memory.ReadInteger(Integer(ADDR_BASE) + Addresses.hotkeyObjectStart + (i * Addresses.hotkeyObjectStep));
    if itemId = value then
    begin
      result := i;
      break;
    end;
  end;

end;

function TTibiaHotkey.GetSendAuto: Boolean;
begin
  Result := Boolean(Memory.ReadInteger(Integer(ADDR_BASE) + Addresses.hotkeySendAutomaticallyStart +
                    (ID * Addresses.hotkeySendAutomaticallyStep)));
end;

function TTibiaHotkey.GetText: String;
begin
  Result := Memory.ReadString(Integer(ADDR_BASE) + Addresses.hotkeyTextStart +
                    (ID * Addresses.hotkeyTextStep));
end;

function TTibiaHotkey.GetObjectId: Integer;
begin
  Result := Memory.ReadInteger(Integer(ADDR_BASE) + Addresses.hotkeyObjectStart +
                    (ID * Addresses.hotkeyObjectStep));
end;

function TTibiaHotkey.GetType: Integer;
begin
  Result := Memory.ReadInteger(Integer(ADDR_BASE) + Addresses.hotkeyObjectUseTypeStart +
                    (ID * Addresses.hotkeyObjectUseTypeStep));
end;

function TTibiaHotkey.GetId: Integer;
begin
  Result := _ID;
end;

procedure TTibiaHotkey.SetId(Value: Integer);
begin
  if (Value < 0) or (Value > 35) then
  begin
    MessageBox(0, 'Value has to be between 0 and 35', 'Information', mb_Ok or mb_iconinformation);
  end
  else
  begin
    _ID := Value;
  end;
end;

end.
