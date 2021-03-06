unit parserThreadHelper;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Xml.VerySimple, settingsHelper, addresses, Vcl.Dialogs,
  eventQueue, PriorityQueue, math, netmsg, inputer, log;

function readField( packet: TNetMsg; x,y,z: integer ): word;
function readArea( packet: TNetMsg; x,y,z: integer; p4: integer; pLoc: TLocation ): integer;
function readFloor( packet: TNetMsg; z, offset: integer ): word;

procedure readOUTFIT( packet: TNetMsg );
procedure readMESSAGE( packet: TNetMsg );
procedure readPING( packet: TNetMsg );
procedure readWAIT( packet: TNetMsg );
procedure readBUDDYDATA( packet: TNetMsg );
procedure readCREATUREPARTY( packet: TNetMsg );
procedure readQUESTLOG( packet: TNetMsg );
procedure readFIELDDATA( packet: TNetMsg );
procedure readCLOSECONTAINER( packet: TNetMsg );
procedure readLEFTROW( packet: TNetMsg );
procedure readFULLMAP( packet: TNetMsg );
procedure readMISSILEEFFECT( packet: TNetMsg );
procedure readSPELLGROUPDELAY( packet: TNetMsg );
procedure readBOTTOMROW( packet: TNetMsg );
procedure readLOGINERROR( packet: TNetMsg );
procedure readQUESTLINE( packet: TNetMsg );
procedure readCREATURESKULL( packet: TNetMsg );
procedure readTRAPPERS( packet: TNetMsg );
procedure readBUDDYLOGIN( packet: TNetMsg );
procedure readSNAPBACK( packet: TNetMsg );
procedure readOBJECTINFO( packet: TNetMsg );
procedure readCHANNELS( packet: TNetMsg );
procedure readOPENCHANNEL( packet: TNetMsg );
procedure readTOPFLOOR( packet: TNetMsg );
procedure readPRIVATECHANNEL( packet: TNetMsg );
procedure readLOGINWAIT( packet: TNetMsg );
procedure readCREATEONMAP( packet: TNetMsg );
procedure readCHALLENGE( packet: TNetMsg );
procedure readCONTAINER( packet: TNetMsg );
procedure readNPCOFFER( packet: TNetMsg );
procedure readBUDDYLOGOUT( packet: TNetMsg );
procedure readMARKETBROWSE( packet: TNetMsg );
procedure readMARKETLEAVE( packet: TNetMsg );
procedure readCOUNTEROFFER( packet: TNetMsg );
procedure readMARKETENTER( packet: TNetMsg );
procedure readCREATURESPEED( packet: TNetMsg );
procedure readMARKCREATURE( packet: TNetMsg );
procedure readSPELLDELAY( packet: TNetMsg );
procedure readDELETEONMAP( packet: TNetMsg );
procedure readCREATUREOUTFIT( packet: TNetMsg );
procedure readAMBIENTE( packet: TNetMsg );
procedure readPLAYERSKILLS( packet: TNetMsg );
procedure readCREATUREUNPASS( packet: TNetMsg );
procedure readDELETEINCONTAINER( packet: TNetMsg );
procedure readCREATEINCONTAINER( packet: TNetMsg );
procedure readCREATUREHEALTH( packet: TNetMsg );
procedure readINITGAME( packet: TNetMsg );
procedure readTOPROW( packet: TNetMsg );
procedure readBOTTOMFLOOR( packet: TNetMsg );
procedure readPLAYERDATA( packet: TNetMsg );
procedure readCREATURELIGHT( packet: TNetMsg );
procedure readTUTORIALHINT( packet: TNetMsg );
procedure readPLAYERGOODS( packet: TNetMsg );
procedure readPLAYERINVENTORY( packet: TNetMsg );
procedure readMOVECREATURE( packet: TNetMsg );
procedure readEDITLIST( packet: TNetMsg );
procedure readCLOSETRADE( packet: TNetMsg );
procedure readSETINVENTORY( packet: TNetMsg );
procedure readCHANGEONMAP( packet: TNetMsg );
procedure readDEAD( packet: TNetMsg );
procedure readCHANGEINCONTAINER( packet: TNetMsg );
procedure readDELETEINVENTORY( packet: TNetMsg );
procedure readLOGINADVICE( packet: TNetMsg );
procedure readCHANNELEVENT( packet: TNetMsg );
procedure readMARKETDETAIL( packet: TNetMsg );
procedure readTALK( packet: TNetMsg );
procedure readCLOSENPCTRADE( packet: TNetMsg );
procedure readRIGHTROW( packet: TNetMsg );
procedure readGRAPHICALEFFECT( packet: TNetMsg );
procedure readEDITTEXT( packet: TNetMsg );
procedure readOPENOWNCHANNEL( packet: TNetMsg );
procedure readCLEARTARGET( packet: TNetMsg );
procedure readCLOSECHANNEL( packet: TNetMsg );
procedure readAUTOMAPFLAG( packet: TNetMsg );
procedure readOWNOFFER( packet: TNetMsg );
procedure readPLAYERSTATE( packet: TNetMsg );

implementation

uses
  unit1;

function readField( packet: TNetMsg; x,y,z: integer ): word;
var
  loc, globalLoc: TLocation;
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  bool: boolean;
begin
  result := 0;
  bool := false;
  loc.x := x;
  loc.y := y;
  loc.z := z;
  globalLoc := GUI.GameWindow.Map.localToGlobal( loc );
  while true do
  begin
    tmpWord[0] := packet.GetU16();
    if tmpWord[0] >= 65280 then
    begin
      result := tmpWord[0] - 65280;
      break;
    end;
    if not bool then
    begin
      bool := true;
      Continue;
    end;
    if (tmpWord[0] = 99) or (tmpWord[0] = 98) or (tmpWord[0] = 97) then
    begin
      packet.skipCreature( tmpWord[0] );
    end
    else
    begin
      packet.SkipItem( tmpWord[0] );
    end;
  end;
end;

function readArea( packet: TNetMsg; x,y,z: integer; p4: integer; pLoc: TLocation ): integer;
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin

  tmpWord[5] := 0; // loc_15
  tmpWord[6] := 0; // loc_16

  tmpWord[9] := 0; // loc_12

  tmpWord[0] := 0; // loc_9
  tmpWord[1] := 0; // loc_10
  tmpInt[2] := 0; // loc_11

  if ( pLoc.z <= GROUND_LAYER ) then
  begin
    tmpWord[0] := 0;
    tmpWord[1] := GROUND_LAYER + 1;
    tmpInt[2] := 1;
  end
  else
  begin
    tmpWord[0] := 2 * UNDERGROUND_LAYER;
    tmpWord[1] := max(-1, pLoc.z - MAP_MAX_Z + 1);
    tmpInt[2] := -1;
  end;

  while not ( tmpWord[0] = tmpWord[1] ) do
  begin
    tmpWord[5] := x;
    while ( tmpWord[5] <= z ) do
    begin
      tmpWord[6] := y;
      while ( tmpWord[6] <= p4 ) do
      begin
        if ( tmpWord[9] > 0 ) then
        begin
          tmpWord[9] := tmpWord[9] - 1;
        end
        else
        begin
          tmpWord[9] := readField( packet, tmpWord[5], tmpWord[6], tmpWord[0] );
        end;

        tmpWord[6] := tmpWord[6] + 1;
      end;
      tmpWord[5] := tmpWord[5] + 1;
    end;
    tmpWord[0] := tmpWord[0] + tmpInt[2];
  end;
  result := tmpWord[9];
end;

function readFloor( packet: TNetMsg; z, offset: integer ): word;
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[9] := offset;

  tmpWord[0] := 0;
  while ( tmpWord[0] <= (MAPSIZE_X - 1) ) do
  begin
    tmpWord[1] := 0;
    while ( tmpWord[1] <= (MAPSIZE_Y - 1) ) do
    begin
      if ( tmpWord[9] > 0 ) then
      begin
          tmpWord[9] := tmpWord[9] - 1;
      end
      else
      begin
        tmpWord[9] := readField( packet, tmpWord[0], tmpWord[1], z );
      end;
      tmpWord[1] := tmpWord[1] + 1;
    end;
    tmpWord[0] := tmpWord[0] + 1;
  end;
  result := tmpWord[9];
end;

procedure readOUTFIT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2); // loc_2
  packet.Skip(5); // loc_3 .. loc_7
  packet.Skip(2); // loc_8
  tmpWord[0] := packet.GetByte(); // loc_14
  while tmpWord[0] > 0 do
  begin
    packet.Skip(2); // loc_9
    packet.SkipString();
    packet.Skip(1); // loc_11

    tmpWord[0] := tmpWord[0] - 1;
  end;

  tmpWord[0] := packet.GetByte(); // loc_14
  while tmpWord[0] > 0 do
  begin
    packet.Skip(2); // loc_9
    packet.SkipString();

    tmpWord[0] := tmpWord[0] - 1;
  end;
end;

procedure readMESSAGE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  item: TItem;
begin
  tmpInt[0] := packet.GetByte();

  case STextMessage(tmpInt[0]) of

    STextMessage.stChannelManagement:
      begin
        packet.Skip(2); // channel id
        packet.SkipString(); // text
      end;

    STextMessage.stLogin,
    STextMessage.stAdmin,
    STextMessage.stGame,
    STextMessage.stFailure,
    STextMessage.stLook,
    STextMessage.stStatus,
    STextMessage.stTradeNpc,
    STextMessage.stGuild,
    STextMessage.stPartyManagement,
    STextMessage.stParty:
      begin
        tmpStr[0] := packet.GetString(); // text
      end;

    STextMessage.stHotkeyUse: // what we want
      begin
        tmpStr[0] := packet.GetString(); // text
        if ( pos('Using the last', tmpStr[0]) > 0)  then
        begin
          tmpStr[0] := StringReplace(tmpStr[0], '...', '', [rfReplaceAll]);
          tmpStr[2] := copy(tmpStr[0], 16, length(tmpStr[0]));
          tmpStr[1] := '1';
        end else
        begin
          tmpStr[0] := StringReplace(tmpStr[0], 'Using one of ', '', [rfReplaceAll]);
          tmpStr[0] := StringReplace(tmpStr[0], 's...', '', [rfReplaceAll]);
          tmpStr[1] := copy(tmpStr[0], 1, pos(' ', tmpStr[0])-1);
          tmpStr[2] := copy(tmpStr[0], pos(' ', tmpStr[0])+1, length(tmpStr[0]));
        end;
        item.count := StrToInt(tmpStr[1]) - 1;
        item.id := xmlItemId(xmlItemList.Root.FindExPos('name', tmpStr[2]).Attribute['id']);
        GUI.setServerCount( item );
      end;

    STextMessage.stLoot:
      begin
        tmpStr[0] := packet.GetString(); // text
      end;

    STextMessage.stMarket,
    STextMessage.stReport:
      begin
        packet.SkipString();
      end;

    STextMessage.stDamageDealed,
    STextMessage.stDamageRecived,
    STextMessage.stDamageOthers:
      begin
        packet.SkipLocation(); // location
        packet.Skip(4); // value
        packet.Skip(1); // color
        packet.Skip(4); // value
        packet.Skip(1); // color
        packet.SkipString(); // text
      end;

    STextMessage.stHeal,
    STextMessage.stExp,
    STextMessage.stHealOthers,
    STextMessage.stExpOthers:
      begin
        packet.SkipLocation(); // location
        packet.Skip(4); // value
        packet.Skip(1); // color
        packet.SkipString(); // text
      end;
  end;
end;

procedure readPING( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  // nothing to do
end;

procedure readWAIT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
end;

procedure readBUDDYDATA( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.SkipString();
  packet.Skip(1);
end;

procedure readCREATUREPARTY( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(1);
end;

procedure readQUESTLOG( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[0] := packet.GetU16();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.Skip(2);
    packet.SkipString();
    packet.Skip(1);
  end;
end;

procedure readFIELDDATA( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  loc, localLoc: TLocation;
begin
  loc := packet.GetLocation();
  localLoc := GUI.GameWindow.Map.globalToLocal( loc );
  readField( packet, localLoc.x, localLoc.y, localLoc.z );
end;

procedure readCLOSECONTAINER( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
end;

procedure readLEFTROW( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  loc: TLocation;
begin
  loc := GUI.Player.getLocation();
  loc.x := loc.x - 1;
  readArea( packet , 0, 0, 0, (MAPSIZE_Y - 1), loc );
end;

procedure readFULLMAP( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  loc: TLocation;
begin
  loc := packet.GetLocation();
  readArea( packet, 0, 0, (MAPSIZE_X - 1), (MAPSIZE_Y - 1), loc );
end;

procedure readMISSILEEFFECT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.SkipLocation(); // from
  packet.SkipLocation(); // to
  packet.Skip(1); // id
end;

procedure readSPELLGROUPDELAY( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
  packet.Skip(4);
end;

procedure readBOTTOMROW( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  loc: TLocation;
begin
  loc := GUI.Player.getLocation();
  loc.y := loc.y + 1;
  readArea( packet , 0, (MAPSIZE_Y - 1), (MAPSIZE_X - 1), (MAPSIZE_Y - 1), loc );
end;

procedure readLOGINERROR( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  //showmessage(packet.GetString());
  packet.SkipString();
end;

procedure readQUESTLINE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
  tmpWord[0] := packet.GetByte();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.SkipString(); // name
    packet.SkipString(); // desc
    tmpWord[1] := tmpWord[1] + 1;
  end;
end;

procedure readCREATURESKULL( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(1);
end;

procedure readTRAPPERS( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[0] := packet.GetByte();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.Skip(4);

    tmpWord[1] := tmpWord[1] + 1;
  end;
end;

procedure readBUDDYLOGIN( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
end;

procedure readSNAPBACK( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
end;

procedure readOBJECTINFO( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[0] := packet.GetByte()-1;
  while ( tmpWord[0] >= 0 ) do
  begin
    packet.Skip(2);
    packet.Skip(1);
    packet.SkipString();
  end;
end;

procedure readCHANNELS( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[0] := packet.GetByte();
  while ( tmpWord[0] > 0 ) do
  begin
    packet.Skip(2);
    packet.SkipString();
    tmpWord[0] := tmpWord[0] - 1;
  end;
end;

procedure readOPENCHANNEL( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
  //showmessage(packet.GetString());
  //packet.SkipString();
  tmpWord[0] := packet.GetU16();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.SkipString();
    tmpWord[1] := tmpWord[1] + 1;
  end;

  tmpWord[0] := packet.GetU16();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.SkipString();
    tmpWord[1] := tmpWord[1] + 1;
  end;
end;

procedure readTOPFLOOR( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  loc: TLocation;
begin
  loc := GUI.Player.getLocation();
  loc.x := loc.x + 1;
  loc.y := loc.y + 1;
  loc.z := loc.z - 1;
  if loc.z > GROUND_LAYER then
  begin
    readFloor( packet, 2 * UNDERGROUND_LAYER, 0);
  end
  else if ( loc.z = GROUND_LAYER ) then
  begin
    tmpWord[0] := UNDERGROUND_LAYER;
    tmpWord[1] := 0;
    while ( tmpWord[0] <= GROUND_LAYER ) do
    begin
      tmpWord[1] := readFloor( packet, tmpWord[0], tmpWord[1] );
      tmpWord[0] := tmpWord[0] + 1;
    end;
  end;
end;

procedure readPRIVATECHANNEL( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.SkipString();
end;

procedure readLOGINWAIT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.SkipString();
  packet.Skip(1);
end;

procedure readCREATEONMAP( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.SkipLocation();
  packet.Skip(1);
  tmpWord[0] := packet.GetU16();
  if (tmpWord[0] = 99) or (tmpWord[0] = 98) or (tmpWord[0] = 97) then
  begin
    packet.SkipCreature( tmpWord[0] );
  end
  else
  begin
    packet.SkipItem( tmpWord[0] );
  end;
end;

procedure readCHALLENGE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(1);
end;

procedure readCONTAINER( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
  packet.skipItem();
  packet.SkipString();
  packet.Skip(1);
  packet.Skip(1);
  tmpWord[0] := 0;
  tmpWord[1] := packet.GetByte();
  while ( tmpWord[0] < tmpWord[1] ) do
  begin
    packet.SkipItem();

    tmpWord[0] := tmpWord[1] + 1;
  end;
end;

procedure readNPCOFFER( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.SkipString();
  tmpWord[0] := packet.GetU16();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.Skip(2);
    packet.Skip(1);
    packet.SkipString();
    packet.Skip(4);
    packet.Skip(4);
    packet.Skip(4);

    tmpWord[1] := tmpWord[1] + 1;
  end;
end;

procedure readBUDDYLOGOUT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
end;

procedure readMARKETBROWSE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[0] := packet.GetU16();
  tmpInt[0] := packet.GetU32()-1;
  while ( tmpInt[0] >= 0 ) do
  begin
    packet.SkipMarketOffer( tmpWord[0] );
    tmpInt[0] := tmpInt[0] - 1;
  end;

  tmpInt[0] := packet.GetU32()-1;
  while ( tmpInt[0] >= 0 ) do
  begin
    packet.SkipMarketOffer( tmpWord[0] );
    tmpInt[0] := tmpInt[0] - 1;
  end;
end;

procedure readMARKETLEAVE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  // no data here
end;

procedure readCOUNTEROFFER( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.SkipString();
  tmpWord[0] := packet.GetByte();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.SkipItem();
    tmpWord[1] := tmpWord[1] + 1;
  end;
end;

procedure readMARKETENTER( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(1);
  packet.Skip(1);
  tmpWord[0] := packet.GetU16()-1;
  while ( tmpWord[0] >= 0 ) do
  begin
    packet.Skip(2);
    packet.Skip(2);
    tmpWord[0] := tmpWord[0] - 1;
  end;
end;

procedure readCREATURESPEED( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(2);
end;

procedure readMARKCREATURE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(1);
end;

procedure readSPELLDELAY( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
  packet.Skip(4);
end;

procedure readDELETEONMAP( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[0] := packet.GetU16();
  if not ( tmpWord[0] = 65535 ) then
  begin
    packet.SkipLocation();
    packet.Skip(1);
  end
  else
  begin
    packet.Skip(4);
  end;
end;

procedure readCREATUREOUTFIT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.SkipOutfit();
  packet.SkipMount();
end;

procedure readAMBIENTE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
  packet.Skip(1);
end;

procedure readPLAYERSKILLS( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  i: integer;
begin
  for i := 1 to 7 do
  begin
    packet.Skip(1);
    packet.Skip(1);
    packet.Skip(1);
  end;
end;

procedure readCREATUREUNPASS( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(1);
end;

procedure readDELETEINCONTAINER( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
  packet.Skip(1);
end;

procedure readCREATEINCONTAINER( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
  packet.SkipItem();
end;

procedure readCREATUREHEALTH( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(1);
end;

procedure readINITGAME( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4); // player id
  packet.Skip(2); // beat duration
  packet.Skip(1); // can report bugs
end;

procedure readTOPROW( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  loc: TLocation;
begin
  loc := GUI.Player.getLocation();
  loc.y := loc.y - 1;
  readArea( packet , 0, 0, (MAPSIZE_X - 1), 0, loc );
end;

procedure readBOTTOMFLOOR( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  loc: TLocation;
begin
  loc := GUI.Player.getLocation();
  loc.x := loc.x - 1;
  loc.y := loc.y - 1;
  loc.z := loc.z + 1;
  if ( loc.z > (GROUND_LAYER+1) ) then
  begin
    if ( loc.z <= MAP_MAX_Z - UNDERGROUND_LAYER ) then
    begin
      readFloor( packet, 0, 0 );
    end;
  end
  else if ( loc.z = (GROUND_LAYER+1) ) then
  begin
    tmpWord[0] := 0;
    tmpWord[1] := UNDERGROUND_LAYER;
    while ( tmpWord[1] >= 0 ) do
    begin
      tmpWord[0] := readFloor( packet, tmpWord[1], tmpWord[0] );
      tmpWord[1] := tmpWord[1] - 1;
    end;
  end;
end;

procedure readPLAYERDATA( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
  packet.Skip(2);
  packet.Skip(4);
  packet.Skip(4);
  packet.Skip(4);
  packet.Skip(4);
  packet.Skip(2);
  packet.Skip(1);
  packet.Skip(2);
  packet.Skip(2);
  packet.Skip(1);
  packet.Skip(1);
  packet.Skip(1);
  packet.Skip(1);
  packet.Skip(2);
  packet.Skip(2);
  packet.Skip(2);
end;

procedure readCREATURELIGHT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(1);
  packet.Skip(1);
end;

procedure readTUTORIALHINT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
end;

procedure readPLAYERGOODS( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  tmpWord[0] := packet.GetByte()-1;
  while ( tmpWord[0] >= 0 ) do
  begin
    packet.Skip(2);
    packet.Skip(1);
  end;
end;

procedure readPLAYERINVENTORY( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[0] := packet.GetU16()-1;
  while ( tmpWord[0] >= 0 ) do
  begin
    packet.Skip(2);
    packet.Skip(1);
    packet.Skip(2);
  end;
end;

procedure readMOVECREATURE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[0] := packet.GetU16();
  if not ( tmpWord[0] = 65535 ) then
  begin
    packet.SkipLocation(tmpWord[0]);
    packet.Skip(1);
  end
  else
  begin
    packet.Skip(4);
  end;
  packet.SkipLocation();
  //showmessage(packet.toString);
end;

procedure readEDITLIST( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
  packet.Skip(2);
  packet.SkipString();
end;

procedure readCLOSETRADE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  // no data here
end;

procedure readSETINVENTORY( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
  packet.SkipItem();
end;

procedure readCHANGEONMAP( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  tmpWord[0] := packet.GetU16();
  if not ( tmpWord[0] = 65535 ) then
  begin
    packet.SkipLocation();
    packet.Skip(1);
    tmpWord[1] := packet.GetU16();
    if (tmpWord[1] = 99) or (tmpWord[1] = 98) or (tmpWord[1] = 97) then
    begin
      packet.SkipCreature( tmpWord[1] );
    end
    else
    begin
      packet.SkipItem( tmpWord[1] );
    end;
  end
  else
  begin
    packet.Skip(4);
    packet.Skip(2);
    tmpWord[1] := packet.GetU16();
    if (tmpWord[1] = 99) or (tmpWord[1] = 98) or (tmpWord[1] = 97) then
    begin
      packet.SkipCreature( tmpWord[1] );
    end;
  end;
end;

procedure readDEAD( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
end;

procedure readCHANGEINCONTAINER( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
  packet.Skip(1);
  packet.SkipItem();
end;

procedure readDELETEINVENTORY( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(1);
end;

procedure readLOGINADVICE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.SkipString();
end;

procedure readCHANNELEVENT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
  packet.SkipString();
  packet.Skip(1);
end;

procedure readMARKETDETAIL( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
  tmpWord[0] := 0;
  while ( tmpWord[0] <= 14 ) do
  begin
    packet.SkipString();
    tmpWord[0] := tmpWord[0] + 1;
  end;

  tmpWord[0] := packet.GetByte()-1;
  while ( tmpWord[0] >= 0 ) do
  begin
    packet.Skip(4);
    packet.Skip(4);
    packet.Skip(4);
    packet.Skip(4);
    tmpWord[0] := tmpWord[0] - 1;
  end;

  tmpWord[0] := packet.GetByte()-1;
  while ( tmpWord[0] >= 0 ) do
  begin
    packet.Skip(4);
    packet.Skip(4);
    packet.Skip(4);
    packet.Skip(4);
    tmpWord[0] := tmpWord[0] - 1;
  end;
end;

procedure readTALK( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  xmlNode: TXmlNode;
begin
  packet.Skip(4); // statement ID
  tmpStr[0] := packet.GetString(); // sender name
  tmpWord[0] := packet.GetU16(); // sender level
  tmpInt[0] := packet.GetByte(); // message type

  case SSpeechMessage(tmpInt[0]) of

    SSpeechMessage.ssSay,
    SSpeechMessage.ssWhisper,
    SSpeechMessage.ssYell:
      begin
        packet.SkipLocation(); // location
        tmpStr[1] := packet.GetString();
      end;

    SSpeechMessage.ssPrivate:
      begin
        tmpStr[1] := packet.GetString();
      end;

    SSpeechMessage.ssChannel,
    SSpeechMessage.ssChannelHighlight:
      begin
        packet.Skip(2); // channel id
        tmpStr[1] := packet.GetString();
      end;

    SSpeechMessage.ssSpell:
      begin
        packet.SkipLocation(); // location
        tmpStr[1] := packet.GetString(); // spell
        //showmessage(tmpStr[1]);
        if tmpStr[0] = GUI.Player.Name then
        begin
          xmlNode := xmlSpellList.Root.FindEx2('words', lowercase(tmpStr[1]));
          case StringToCaseSelect(xmlNode.Attribute['group1'],
               ['healing', 'attack', 'support', 'special'])  of
            0: GUI.Player.setHealingEx(1000);
            1: GUI.Player.setAttackEx(1000);
            2: ;
            3: ;
          end;

        end;
      end;

    SSpeechMessage.ssFromNpc:
      begin
        packet.SkipLocation(); // location
        tmpStr[1] := packet.GetString();
      end;

    SSpeechMessage.ssGMBroadcast:
      begin
        tmpStr[1] := packet.GetString();
      end;

    SSpeechMessage.ssGMChannel:
      begin
        packet.Skip(2); // channel id
        tmpStr[1] := packet.GetString();
      end;

    SSpeechMessage.ssGMPrivate:
      begin
        tmpStr[1] := packet.GetString();
      end;

    SSpeechMessage.ssBarkLow,
    SSpeechMessage.ssBarkLoud:
      begin
        packet.SkipLocation(); // location
        tmpStr[1] := packet.GetString();
      end;
  end;
end;

procedure readCLOSENPCTRADE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  // no data here
end;

procedure readRIGHTROW( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
  loc: TLocation;
begin
  loc := GUI.Player.getLocation();
  loc.x := loc.x + 1;
  readArea( packet , (MAPSIZE_X - 1), 0, (MAPSIZE_X - 1), (MAPSIZE_Y - 1), loc );
end;

procedure readGRAPHICALEFFECT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.SkipLocation();
  packet.Skip(1);
end;

procedure readEDITTEXT( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
  packet.Skip(2);
  packet.Skip(2);
  packet.SkipString();
  packet.SkipString();
  packet.SkipString();
end;

procedure readOPENOWNCHANNEL( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
  packet.SkipString();
  tmpWord[0] := packet.GetU16();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.SkipString();
    tmpWord[1] := tmpWord[1] + 1;
  end;
  tmpWord[0] := packet.GetU16();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.SkipString();
    tmpWord[1] := tmpWord[1] + 1;
  end;
end;

procedure readCLEARTARGET( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(4);
end;

procedure readCLOSECHANNEL( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
end;

procedure readAUTOMAPFLAG( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
  packet.Skip(2);
  packet.Skip(1);
  packet.Skip(1);
  packet.SkipString();
end;

procedure readOWNOFFER( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.SkipString();
  tmpWord[0] := packet.GetByte();
  tmpWord[1] := 0;
  while ( tmpWord[1] < tmpWord[0] ) do
  begin
    packet.SkipItem();
    tmpWord[1] := tmpWord[1] + 1;
  end;
end;

procedure readPLAYERSTATE( packet: TNetMsg );
var
  tmpStr: array[0..10] of string;
  tmpInt: array[0..10] of integer;
  tmpWord: array[0..10] of word;
begin
  packet.Skip(2);
end;

{
a whore ... It took 2 days ...
}

end.
