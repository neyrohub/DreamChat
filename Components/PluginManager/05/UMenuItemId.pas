//Autor: Bajenov Andrey Bladimirovich (neyro@mail.ru)
//Saint-Petersburg, Russia.
//2011.10.22
//All right reserved.

unit UMenuItemId;

interface

uses
  Windows, Menus, VTHeaderPopup, DChatClientServerPlugin;

type
  TMenuItemId = class(TMenuItem)
  private
    { Private declarations }
  public
    { Public declarations }
    Id: Integer;
    DChatClientServerPlugin: TDChatClientServerPlugin;
  end;

implementation
end.

