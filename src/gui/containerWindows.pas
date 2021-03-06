unit containerWindows;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Addresses, math, inputer;

type
  TWindow = class
  public

    function getAddress( ident: integer ): integer;
    function getAddressByName( name: string; last: integer = 0 ): integer;

    function getName( addr: integer ): string;
    function getNameEx( ident: integer ): string;

    function getSize( addr: integer ): TRect;
    function getSizeEx( ident: integer ): TRect;

    procedure scrollUp( addr: integer );
    procedure scrollDown( addr: integer );
    function hiddenOffset( addr: integer ): integer;
    function scrollToSlot( addr: integer; slot: integer ): TRect;

    function windowCount( location: string = '' ): integer;

  end;

implementation

uses
  unit1;

function TWindow.getAddress( ident: integer ): integer;
var
  tmp, i: integer;
begin
  tmp := Memory.ReadPointer(Integer(ADDR_BASE) +  Addresses.guiPointer, [ $24, $24 ] );
  if ident <> 0 then
  begin
    for i := 0 to ident - 1 do
    begin
      tmp := Memory.ReadInteger( tmp + $10 );
    end;
  end;

  result := tmp;
end;

function TWindow.getAddressByName( name: string; last: integer = 0 ): integer;
var
  tmp, i: integer;
  found: boolean;
begin
  found := false;
  if last = 0 then
  begin
    tmp := Memory.ReadPointer(Integer(ADDR_BASE) +  Addresses.guiPointer, [ $24, $24 ] );
  end
  else
  begin
    tmp := Memory.ReadInteger( last + $10 );
  end;

  for i := 0 to 15 do
  begin
    if pos(lowercase(name), lowercase(getName( tmp ))) > 0 then
    begin
      found := true;
      break;
    end;

    tmp := Memory.ReadInteger( tmp + $10 );
  end;
  if found then
    result := tmp
  else
    result := 0;
end;

function TWindow.getName( addr: integer ): string;
var
  tmp: integer;
begin
  tmp := Memory.ReadInteger( addr + $60);
  tmp := Memory.ReadInteger( tmp + $24);
  Result := Memory.ReadString( tmp );
end;

function TWindow.getNameEx( ident: integer ): string;
var
  tmp: integer;
  addr: integer;
begin
  addr := getAddress( ident );

  tmp := Memory.ReadInteger( tmp + $60);
  tmp := Memory.ReadInteger( tmp + $24);
  Result := Memory.ReadString( tmp );
end;

function TWindow.getSize( addr: integer ): TRect;
begin
  result.Left := Memory.ReadInteger( addr + $14);
  result.Top := Memory.ReadInteger( addr + $18);
  result.Right := Memory.ReadInteger( addr + $1c);
  result.Bottom := Memory.ReadInteger( addr + $20);
end;

function TWindow.getSizeEx( ident: integer ): TRect;
var
  addr: integer;
begin
  addr := getAddress( ident );

  result.Left := Memory.ReadInteger( addr + $14);
  result.Top := Memory.ReadInteger( addr + $18);
  result.Right := Memory.ReadInteger( addr + $1c);
  result.Bottom := Memory.ReadInteger( addr + $20);
end;

function TWindow.hiddenOffset( addr: integer ): integer;
begin

  result := memory.ReadPointer( addr, [ $24, $10, $10, $10, $10, $10, $14 ], false ); // has parent
  if result = 4 then
  begin
    // 1 wiecej przycisk�w do obejscia (5 przyciskow i dopiero nasze okno)
    result := memory.ReadPointer( addr, [ $24, $10, $10, $10, $10, $10, $24, $24, $30 ], false );
  end
  else
  begin
    // sa tylko 4 przyciski i dopiero nasze okno
    result := memory.ReadPointer( addr, [ $24, $10, $10, $10, $10, $24, $24, $30 ], false );
  end;

end;

procedure TWindow.scrollUp( addr: integer );
var
  p: TPoint;
  hrect, crect: TRect;
begin
  hrect := GUI.Containers.getSize();
  crect := getSize( addr );

  p.x := (hrect.Left + crect.Right) - 10;
  p.Y := (hrect.Top + crect.Top) + 21;

  Inputer.SendClickPoint(p);
  //Inputer.SendScrollUp(p.X,p.Y);
end;

procedure TWindow.scrollDown( addr: integer );
var
  p: TPoint;
  hrect, crect: TRect;
begin
  hrect := GUI.Containers.getSize();
  crect := getSize( addr );

  p.x := (hrect.Left + crect.Right) - 10;
  p.Y := (hrect.Top + crect.Top + crect.Bottom) - 10;

  Inputer.SendClickPoint(p);
end;

function TWindow.scrollToSlot( addr: integer; slot: integer ): TRect;
var
  row, hidden, height, tmp: integer;
  r: TRect;

  p: TPoint;
  hrect, crect: TRect;
begin

  hidden := hiddenOffset( addr );

  height := memory.ReadInteger( addr + $20 ) - addresses.slotYStart - 4;

  // obliczamy rect slota relatywnie do okna potocznie zwanego item handler
  // (subokno z scrollem)
  row := ceil( slot / 4 );

  r.Top := ( row -1 ) * ( addresses.SlotMargin + addresses.SlotSize );
  r.Top := r.Top - hidden;
  r.Top := r.Top + addresses.SlotMargin;

  r.Left := slot - ( 4 * ( row - 1 ) );
  r.Left := ( r.Left - 1 ) * ( addresses.SlotMargin + addresses.SlotSize );
  r.Left := r.Left + addresses.SlotMargin;

  r.Right := addresses.SlotSize;
  r.Bottom := addresses.SlotSize;

  if ( r.Top < 0 ) and ( r.Top + r.Bottom < addresses.SlotMinOffset ) then
  begin
    while ( r.Top < 0 ) and ( r.Top + r.Bottom < addresses.SlotMinOffset ) do
    begin
      scrollUp( addr );
      sleep(50);
      r.Top := r.Top + 10;
    end;
  end;

  if ( r.Top > 0 ) and ( ( r.Top + addresses.SlotMinOffset ) > height ) then
  begin
    while ( r.Top > 0 ) and ( ( r.Top + addresses.SlotMinOffset ) > height ) do
    begin
      scrollDown( addr );
      sleep(50);
      r.Top := r.Top - 10;
    end;
  end;

  // dupa jasiu pierdzi stasiu... timestamp nao: 01:52 am - 24.12.2011 :D
  if ((r.Top + r.Bottom) > height) then
    r.Bottom := r.Bottom - ((r.Top + r.Bottom) - height)
  else
    r.Bottom := r.Top + r.Bottom;

  if r.Top < 0 then  r.Top := 0;

  // kod na znalezienie pozycji og�lnie :D
  hrect := GUI.Containers.getSize();
  crect := getSize( addr );

  r.Left := (hrect.Left + r.Left + addresses.SlotXStart);
  r.Top := (hrect.Top + crect.Top + r.top + addresses.slotYStart);
  r.Bottom := r.Top + r.Bottom;
  r.Right := r.Left + r.Right;

  result := r;
end;

function TWindow.windowCount( location: string = '' ): integer;
var
  tmp, i, j: integer;
begin
  result := 0;
  if length(location) = 0 then
  begin
    for i := 0 to 15 do
    begin
      tmp := getAddress(i);
      if tmp = 0 then
      begin
        result := i;
        break;
      end;
    end;
  end else
  begin
    j := 0;
    for i := 0 to 15 do
    begin
      tmp := getAddress(i);
      if tmp = 0 then
      begin
        result := j;
        break;
      end;
      if pos(lowercase(location), lowercase(getName(tmp))) > 0 then j := j + 1;
    end;
  end;
end;

end.
