program PizzariaBackend;

{$APPTYPE CONSOLE}


uses
  System.SysUtils,
  Web.WebReq,
  Web.WebBroker,
  IdHTTPWebBrokerBridge,
  MVCFramework.REPLCommandsHandlerU,
  MVCFramework.Logger,
  UWMPizzariaBackend in '..\pas\wm\UWMPizzariaBackend.pas' {WebModule1: TWebModule},
  UPizzariaControllerImpl in '..\pas\controller\UPizzariaControllerImpl.pas';

{$R *.res}


procedure RunServer(APort: Integer);
var
  lServer: TIdHTTPWebBrokerBridge;
  lCustomHandler: TMVCCustomREPLCommandsHandler;
  lCmd, lStartupCommand: string;
begin
  if ParamCount >= 1 then
    lStartupCommand := ParamStr(1)
  else
    lStartupCommand := 'start';

  lCustomHandler := function(const Value: String; const Server: TIdHTTPWebBrokerBridge; out Handled: Boolean): THandleCommandResult
    begin
      Handled := False;
      Result := THandleCommandResult.Unknown;
    end;

  // Writeln(Format('Starting HTTP Server or port %d', [APort]));
  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := APort;
    LogI(Format('Server started on port %d', [APort]));

    { more info about MaxConnections
      http://www.indyproject.org/docsite/html/frames.html?frmname=topic&frmfile=TIdCustomTCPServer_MaxConnections.html }
    LServer.MaxConnections := 0;

    { more info about ListenQueue
      http://www.indyproject.org/docsite/html/frames.html?frmname=topic&frmfile=TIdCustomTCPServer_ListenQueue.html }
    LServer.ListenQueue := 200;

    WriteLn('Write "quit" or "exit" to shutdown the server');
    repeat
      // TextColor(RED);
      // TextColor(LightRed);
      Write('-> ');
      // TextColor(White);
      if lStartupCommand.IsEmpty then
        ReadLn(lCmd)
      else
      begin
        lCmd := lStartupCommand;
        lStartupCommand := '';
        WriteLn(lCmd);
      end;

      case HandleCommand(lCmd.ToLower, LServer, lCustomHandler) of
        THandleCommandResult.Continue:
          begin
            Continue;
          end;
        THandleCommandResult.Break:
          begin
            Break;
          end;
        THandleCommandResult.Unknown:
          begin
            REPLEmit('Unknown command: ' + lCmd);
          end;
      end;
    until false;

  finally
    LServer.Free;
  end;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    if WebRequestHandler <> nil then
      WebRequestHandler.WebModuleClass := WebModuleClass;
    WebRequestHandlerProc.MaxConnections := 1024;
    RunServer(8080);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
