unit hudthread;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Memory, guiclass, inputer, addresses, lua, lualib,
  Menus, settingsXML, luaClass, Vcl.ExtCtrls;

type
  THudThread = class(TThread)
  protected
    procedure Execute; override;
  end;

implementation

uses
  unit1, unitLoadDLL;

procedure THudThread.Execute;
begin
  sleep(1000);
  showme();
end;


end.
