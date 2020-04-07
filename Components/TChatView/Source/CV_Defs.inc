       { Determine Delphi/C++Builder version }

//{$DEFINE ChatViewInstall}
{$IFDEF VER125}            {       not C++Builder 4.0       }
  {$DEFINE ChatViewDEF5}    (* Delphi 5.0+                  *)
{$ENDIF}
{$IFDEF VER135}       {       not C++Builder 5.0       }
  {$DEFINE ChatViewDEF6}(* Delphi 6.0+                 *)
{$ENDIF}
{$IFDEF VER150}
   {$DEFINE ChatViewDEF7}(* Delphi 7.0+                 *)
{$ENDIF}

