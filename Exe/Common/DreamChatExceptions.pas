unit DreamChatExceptions;

interface

uses
  SysUtils;

type

  DreamChatBaseException = class(Exception)

  end;

  DreamChatTechnicalException = class(DreamChatBaseException)
  private
    m_message: string;
    m_line: cardinal;
  public
    constructor Create(Mess: string); overload;

  end;

  DreamChatWinsockException = class(DreamChatTechnicalException)
  public
    constructor Create(Mess: string);
  end;

  DreamChatApplicationException = class(DreamChatBaseException)

  end;

  DreamChatNotImplementedException = class(DreamChatBaseException)

  end;

  DreamChatWin32Exception = class(DreamChatBaseException)

  end;

implementation

{ DreamChatTechnicalException }

constructor DreamChatTechnicalException.Create(Mess: string);
begin
  inherited Create(Mess);
end;

{ DreamChatWinsockException }

constructor DreamChatWinsockException.Create(Mess: string);
begin

end;

end.
