unit SendStatus;

{
    Copyright 2003, Peter Millard

    This file is part of Exodus.

    Exodus is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Exodus is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Exodus; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{$ifdef VER150}
    {$define INDY9}
{$endif}


interface

uses
    Unicode, SyncObjs, XferManager, XMLTag, IQ,   
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
    Dialogs, ComCtrls, StdCtrls, ExtCtrls, IdBaseComponent, IdComponent,
    IdTCPConnection, IdTCPClient, IdHTTP, TntStdCtrls, IdIOHandler,
    IdIOHandlerSocket, IdSocks;

const
    WM_SEND_DONE = WM_USER + 6002;
    WM_SEND_OK = WM_USER + 6021;
    WM_SEND_BAD = WM_USER + 6022;

type

    TFileSendState = (send_disco, send_ft_offer, send_get_hosts, send_get_addr,
        send_offer_hosts, send_try_connect, send_activate, send_sending,
        send_do_oob, send_do_dav, send_done, send_cancel);

    TFileSendThread = class;

    TfSendStatus = class(TFrame)
        Panel1: TPanel;
        btnCancel: TButton;
        Panel2: TPanel;
        Bar1: TProgressBar;
        Panel3: TPanel;
        httpClient: TIdHTTP;
        lblStatus: TTntLabel;
        lblFile: TTntLabel;
        lblTo: TTntLabel;
        tcpClient: TIdTCPClient;
        SocksHandler: TIdIOHandlerSocket;
        IdSocksInfo1: TIdSocksInfo;
    private
        { Private declarations }
        _thread: TFileSendThread;
        _pkg: TFileXferPkg;
        _state: TFileSendState;
        _iq: TJabberIQ;
        _sid: Widestring;
        _shost: Widestring;
        _disco_count: integer;

        procedure DoState();
        procedure BuildStreamHosts(ptag: TXMLTag);

        function getNextHostAddr(): boolean;

    protected
        procedure WMSendDone(var msg: TMessage); message WM_SEND_DONE;
        procedure WMSendOK(var msg: TMessage); message WM_SEND_OK;
        procedure WMSendBad(var msg: TMessage); message WM_SEND_BAD;

    published
        procedure RecipDiscoCallback(event: string; tag: TXMLTag);
        procedure DiscoItemsCallback(event: string; tag: TXMLTag);
        procedure DiscoInfoCallback(event: string; tag: TXMLTag);
        procedure FTCallback(event: string; tag: TXMLTag);
        procedure AddrCallback(event: string; tag: TXMLTag);
        procedure SelectHostCallback(event: string; tag: TXMLTag);
        procedure ActiveCallback(event: string; tag: TXMLTag);

    public
        { Public declarations }
        procedure Setup(pkg: TFileXferPkg);
        procedure SendStart();
        procedure SendDav();
        procedure SendIQ();
    end;

    TFileSendThread = class(TThread)
    private
        _http: TIdHTTP;
        _client: TIdTCPClient;
        _stream: TFileStream;
        _form: TfSendStatus;
        _pos_max: longint;
        _pos: longint;
        _new_txt: TWidestringlist;
        _lock: TCriticalSection;
        _url: string;
        _method: string;

        procedure Update();
        procedure setHttp(value: TIdHttp);
        procedure setClient(value: TIdTCPClient);

        procedure httpClientStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: String);
        procedure httpClientConnected(Sender: TObject);
        procedure httpClientDisconnected(Sender: TObject);
        procedure httpClientWorkEnd(Sender: TObject; AWorkMode: TWorkMode);
        procedure httpClientWork(Sender: TObject; AWorkMode: TWorkMode; const AWorkCount: Integer);
        procedure httpClientWorkBegin(Sender: TObject; AWorkMode: TWorkMode; const AWorkCountMax: Integer);

        procedure tcpClientConnected(Sender: TObject);
        procedure tcpClientDisconnected(Sender: TObject);
        procedure tcpClientStatus(ASender: TObject; const AStatus: TIdStatus;
            const AStatusText: String);

    protected
        procedure Execute; override;
    public
        constructor Create(); reintroduce;

        property client: TIdTCPClient read _client write setClient;
        property http: TIdHttp read _http write setHttp;
        property stream: TFileStream read _stream write _stream;
        property form: TfSendStatus read _form write _form;
        property url: String read _url write _url;
        property method: String read _method write _method;
    end;

var
    shosts: TWidestringlist;

implementation

{$R *.dfm}

uses
    GnuGetText, JabberID, XMLUtils, JabberConst, Session;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TFileSendThread.Create();
begin
    //
    inherited Create(true);

    _pos := 0;
    _form := nil;
    _new_txt := TWidestringlist.Create();
    _lock := TCriticalSection.Create();

end;

{---------------------------------------}
procedure TFileSendThread.setHttp(value: TIdHttp);
begin
    _client := nil;
    _http := Value;
    with _http do begin
        OnConnected := Self.httpClientConnected;
        OnDisconnected := Self.httpClientDisconnected;
        OnWork := Self.httpClientWork;
        OnWorkBegin := Self.httpClientWorkBegin;
        OnWorkEnd := Self.httpClientWorkEnd;
        OnStatus := httpClientStatus;
    end;
end;

{---------------------------------------}
procedure TFileSendThread.setClient(value: TIdTCPClient);
begin
    _http := nil;
    _client := value;
    with _client do begin
        OnConnected := Self.tcpClientConnected;
        OnDisconnected := Self.tcpClientDisconnected;
        onWork := Self.httpClientWork;
        onWorkBegin := Self.httpClientWorkBegin;
        onWorkEnd := Self.httpClientWorkEnd;
        onStatus := Self.tcpClientStatus;
    end;
end;

{---------------------------------------}
procedure TFileSendThread.Execute();
begin
    try
        try
            if (_method = 'si') then begin
                try
                    _client.Connect();
                    Self.Suspend();
                except
                    SendMessage(_form.Handle, WM_SEND_BAD, 0, 0);
                    exit;
                end;
                _client.WriteStream(_stream, true, false, 0);
            end
            else if (_method = 'get') then
                _http.Get(_url, _stream)
            else
                _http.Put(Self.url, _stream);
        finally
            FreeAndNil(_stream);
        end;
    except
    end;

    if (_http <> nil) then
        SendMessage(_form.Handle, WM_SEND_DONE, 0, _http.ResponseCode)
    else
        SendMessage(_form.Handle, WM_SEND_DONE, 0, 0);
end;

{---------------------------------------}
procedure TFileSendThread.Update();
begin
    _lock.Acquire();

    if ((Self.Suspended) or (Self.Terminated)) then begin
        _lock.Release();
        _http.DisconnectSocket();
        FreeAndNil(_stream);
        Self.Terminate();
    end;

    with _form do begin
        if (_pos_max > 0) then
            bar1.Max := _pos_max;
        bar1.Position := _pos;
        if (_new_txt.Count > 0) then begin
            lblStatus.Caption := _new_txt[_new_txt.Count - 1];
            _new_txt.Clear();
        end;
    end;
    _lock.Release();
end;

{---------------------------------------}
procedure TFileSendThread.httpClientStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
    _lock.Acquire();
    _new_txt.Add(AStatusText);
    _lock.Release();
    Synchronize(Update);
end;

{---------------------------------------}
procedure TFileSendThread.httpClientConnected(Sender: TObject);
begin
    _lock.Acquire();
    _new_txt.Add(sXferConn);
    _lock.Release();
    Synchronize(Update);
end;

{---------------------------------------}
procedure TFileSendThread.httpClientDisconnected(Sender: TObject);
begin
    // NB: For Indy9, it fires disconnected before it actually
    // connects. So if we drop the stream here, our GETs
    // never work since the response stream gets freed.
    {$ifndef INDY9}
    if (_stream <> nil) then
        FreeAndNil(_stream);
    {$endif}
end;


{---------------------------------------}
procedure TFileSendThread.httpClientWorkEnd(Sender: TObject;
  AWorkMode: TWorkMode);
begin
    _lock.Acquire();
    _new_txt.Add(sXferDone);
    _lock.Release();
    Synchronize(Update);
end;

{---------------------------------------}
procedure TFileSendThread.httpClientWork(Sender: TObject;
  AWorkMode: TWorkMode; const AWorkCount: Integer);
begin
    // Update the progress meter
    _pos := AWorkCount;
    Synchronize(Update);
end;

{---------------------------------------}
procedure TFileSendThread.httpClientWorkBegin(Sender: TObject;
  AWorkMode: TWorkMode; const AWorkCountMax: Integer);
begin
    _pos_max := AWorkCountMax;
    _pos := 0;
    Synchronize(Update);
end;


{---------------------------------------}
procedure TFileSendThread.tcpClientConnected(Sender: TObject);
begin
    // we connected, let our form know
    SendMessage(_form.Handle, WM_SEND_OK, 0, 0);
end;

{---------------------------------------}
procedure TFileSendThread.tcpClientDisconnected(Sender: TObject);
begin
    // we NOT connected, let our form know
    //SendMessage(_form.Handle, WM_RECV_SIDISCONN, 0, 0);
end;

{---------------------------------------}
procedure TFileSendThread.tcpClientStatus(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
    _lock.Acquire();
    _new_txt.Add(AStatusText);
    _lock.Release();
    Synchronize(Update);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}

procedure TfSendStatus.Setup(pkg: TFileXferPkg);
begin
    _pkg := pkg;
    lblTo.Caption := pkg.recip;
    lblFile.Caption := ExtractFilename(pkg.pathname);
    lblStatus.Caption := sXferWaiting;
end;

{---------------------------------------}
procedure TfSendStatus.SendStart();
begin
    //
    _state := send_disco;
    DoState();
end;

{---------------------------------------}
procedure TfSendStatus.DoState();
var
    fld, x: TXMLTag;
    f: File of Byte;
    size: longint;
    p: THostPortPair;
    i: integer;
    fStream: TFileStream;
    tmp_jid: TJabberID;
    tmps, hash_key: Widestring;
begin
    // do something based on our current state
    case _state of
    send_disco: begin
        _iq := TJabberIQ.Create(MainSession, MainSession.generateID(),
            Self.RecipDiscoCallback, 10);
        _iq.Namespace := XMLNS_DISCOINFO;
        _iq.iqType := 'get';
        _iq.toJid := _pkg.recip;
        _iq.Send();
        end;
    send_ft_offer: begin
        _iq := TJabberIQ.Create(MainSession, MainSession.generateID(),
            Self.FTCallback, 600);
        _iq.Namespace := XMLNS_SI;
        _iq.iqType := 'set';
        _iq.toJid := _pkg.recip;

        x := _iq.qTag;
        x.Name := 'si';
        _sid := 'exs_' + MainSession.generateID();
        x.setAttribute('id', _sid);
        x.setAttribute('mime-type', 'binary/octet-stream');
        x.setAttribute('profile', XMLNS_FTPROFILE);

        x := x.AddTagNS('file', XMLNS_FTPROFILE);
        x.setAttribute('name', ExtractFilename(_pkg.pathname));

        // get the file size
        AssignFile(f, _pkg.pathname);
        Reset(f);
        size := FileSize(f);
        CloseFile(f);
        x.setAttribute('size', IntToStr(size));

        // put in the fneg stuff
        x := _iq.qTag.AddTagNS('feature', XMLNS_FEATNEG);
        x := x.AddTagNS('x', XMLNS_XDATA);
        fld := x.AddTag('field');
        fld.setAttribute('var', 'stream-method');
        fld.setAttribute('type', 'list-single');
        x := fld.AddTag('option');
        x.AddBasicTag('value', XMLNS_BYTESTREAMS);

        _iq.Send();
        end;
    send_get_hosts: begin
        // get our hosts that we want to offer..
        if (MainSession.Prefs.getBool('xfer_proxy')) then begin
            // always use xfer_prefproxy
            if (shosts.Count > 1) then begin
                for i := 0 to shosts.Count - 1 do begin
                    p := THostPortPair(shosts.Objects[i]);
                    p.Free();
                end;
                shosts.Clear();
            end;
            p := THostPortPair.Create();
            p.jid := MainSession.Prefs.getString('xfer_prefproxy');
            shosts.AddObject(p.jid, p);
            _state := send_get_addr;
            DoState();
        end
        else begin
            _iq := TJabberIQ.Create(MainSession, MainSession.generateID(),
                Self.DiscoItemsCallback, 20);
            _iq.iqType := 'get';
            tmp_jid := TJabberID.Create(MainSession.jid);
            _iq.toJid := tmp_jid.domain;
            _iq.Namespace := XMLNS_DISCOITEMS;
            _iq.Send();
        end;

        end;
    send_get_addr: begin
        // get the addresses for each host..
        if (not getNextHostAddr()) then begin
            _state := send_offer_hosts;
            DoState();
        end;
        end;
    send_offer_hosts: begin
        // offer the hosts to the recipient..
        _iq := TJabberIQ.Create(MainSession, MainSession.generateID(),
            Self.SelectHostCallback, 600);
        _iq.iqType := 'set';
        _iq.toJid := _pkg.recip;
        _iq.Namespace := XMLNS_BYTESTREAMS;
        BuildStreamHosts(_iq.qTag);
        _iq.qTag.setAttribute('sid', _sid);
        _iq.Send();
        end;
    send_try_connect: begin
        // try to connect to the host they connected to.

        // get a handle to the stream
        try
            fStream := TFileStream.Create(_pkg.pathname, fmOpenRead);
        except
            on EStreamError do begin
                MessageDlg(sXferStreamError, mtError, [mbOK], 0);
                exit;
            end;
        end;

        i := shosts.indexOf(_shost);
        p := THostPortPair(shosts.Objects[i]);

        SocksHandler.SocksInfo.Authentication := saNoAuthentication;
        SocksHandler.SocksInfo.Version := svSocks5;
        SocksHandler.SocksInfo.Host := p.host;
        SocksHandler.SocksInfo.Port := p.Port;

        hash_key := _sid + MainSession.Jid + _pkg.recip;
        tmps := Sha1Hash(hash_key);
        tcpClient.IOHandler := SocksHandler;
        tcpClient.Host := tmps;
        tcpClient.Port := 0;

        _thread := TFileSendThread.Create();
        _thread.url := '';
        _thread.form := Self;
        _thread.client := tcpClient;
        _thread.stream := fstream;
        _thread.method := 'si';
        _thread.Resume();

        end;
    send_activate: begin
        // tell the proxy to activate the channel.
        _iq := TJabberIQ.Create(MainSession, MainSession.generateID(),
            Self.ActiveCallback, 30);
        _iq.iqType := 'set';
        _iq.toJid := _shost;
        _iq.Namespace := XMLNS_BYTESTREAMS;
        _iq.qTag.setAttribute('sid', _sid);
        x := _iq.qTag.AddTag('activate');
        x.AddCData(_pkg.recip);
        _iq.Send();
        end;
    send_sending: begin
        // start sending stuff
        assert(_thread <> nil);
        _thread.Resume();
        end;
    send_cancel: begin
        // kill the thread, etc..
        if (_thread <> nil) then
            _thread.Terminate();
        _thread := nil;
        end;
    end;
end;

{---------------------------------------}
procedure TfSendStatus.BuildStreamHosts(ptag: TXMLTag);
var
    i: integer;
    p: THostPortPair;
    s: TXMLTag;
begin
    // ptag is the parent tag
    for i := 0 to shosts.Count - 1 do begin
        p := THostPortPair(shosts.Objects[i]);
        s := ptag.AddTag('streamhost');
        s.setAttribute('jid', p.jid);
        s.setAttribute('host', p.host);
        s.setAttribute('port', IntToStr(p.Port));
    end;

end;

{---------------------------------------}
function TfSendStatus.getNextHostAddr(): boolean;
var
    i: integer;
    p: THostPortPair;
begin
    Result := false;
    for i := 0 to shosts.Count - 1 do begin
        p := THostPortPair(shosts.Objects[i]);
        if ((p.host = '') or (p.Port = 0)) then begin
            _iq := TJabberIQ.Create(MainSession, MainSession.generateID(),
                Self.AddrCallback, 30);
            _iq.toJid := p.jid;
            _iq.iqType := 'get';
            _iq.Namespace := XMLNS_BYTESTREAMS;
            _iq.Send();
            Result := true;
            exit;
        end;
    end;
end;

{---------------------------------------}
procedure TfSendStatus.sendDav();
var
    u, p: string;
    dp: integer;
    fStream: TFileStream;
begin
    // check to see if we need to auth
    u := MainSession.Prefs.getString('xfer_davusername');
    p := MainSession.Prefs.getString('xfer_davpassword');
    if (u <> '') then with httpClient.Request do begin
        BasicAuthentication := true;
        Username := u;
        Password := p;
    end;

    dp := MainSession.Prefs.getInt('xfer_davport');
    if (dp > 0) then
        httpClient.Port := dp;

    // get a handle to the stream
    try
        fStream := TFileStream.Create(_pkg.pathname, fmOpenRead);
    except
        on EStreamError do begin
            MessageDlg(sXferStreamError, mtError, [mbOK], 0);
            exit;
        end;
    end;

    _thread := TFileSendThread.Create();
    _thread.url := _pkg.url;
    _thread.form := Self;
    _thread.http := httpClient;
    _thread.stream := fstream;
    _thread.method := 'put';
    _thread.Resume();

end;

{---------------------------------------}
procedure TfSendStatus.SendIQ();
var
    iq: TXMLTag;
begin
    // normal p2p... just add it to our server,
    // and close the form.
    iq := TXMLTag.Create('iq');
    with iq do begin
        setAttribute('to', _pkg.recip);
        setAttribute('id', MainSession.generateID());
        setAttribute('type', 'set');
        with AddTag('query') do begin
            setAttribute('xmlns', XMLNS_IQOOB);
            AddBasicTag('url', _pkg.url);
            AddBasicTag('desc', _pkg.desc);
        end;
    end;
    MainSession.SendTag(iq);
end;

{---------------------------------------}
procedure TfSendStatus.RecipDiscoCallback(event: string; tag: TXMLTag);
var
    ft_support: boolean;
    x, x2, x3: TXMLTag;
begin
    // determine what mode to use based on disco results
    ft_support := false;
    if (event = 'xml') then begin
        // check for SI, and FTPROFILE
        x := tag.QueryXPTag('/iq/query/feature[@var="' + XMLNS_SI + '"]');
        x2 := tag.QueryXPTag('/iq/query/feature[@var="' + XMLNS_FTPROFILE + '"]');
        x3 := tag.QueryXPTag('/iq/query/feature[@var="' + XMLNS_BYTESTREAMS + '"]');
        if ((x <> nil) and (x2 <> nil) and (x3 <> nil)) then
            ft_support := true;
    end;

    if (not ft_support) then begin
        // they don't support FT... so either do OOB, or DAV
        if MainSession.Prefs.getBool('xfer_webdav') then begin
            _state := send_do_dav;
            SendDav()
        end
        else begin
            if (not getXferManager().httpServer.Active) then
                getXferManager().httpServer.Active := true;
            _state := send_do_oob;
            SendIQ();
        end;
        exit;
    end;

    // they do support FT, and Bytestreams, so lets forge ahead
    _state := send_ft_offer;
    DoState();
end;

{---------------------------------------}
procedure TfSendStatus.DiscoItemsCallback(event: string; tag: TXMLTag);
var
    i: integer;
    iq: TJabberIQ;
    items: TXMLTagList;
    tmps: Widestring;
    p: THostPortPair;
begin
    //
    if ((event = 'xml') and (tag.GetAttribute('type') = 'result')) then begin

        // Clear the shosts Queue..
        while (shosts.Count > 0) do begin
            p := THostPortPair(shosts.Objects[0]);
            p.Free();
            shosts.Delete(0);
        end;

        _disco_count := 0;
        items := tag.QueryXPTags('/iq/query/item');
        for i := 0 to items.count - 1 do begin
            iq := TJabberIQ.Create(MainSession, MainSession.generateID(),
                Self.DiscoInfoCallback, 10);
            iq.iqType := 'get';
            iq.toJid := items[i].getAttribute('jid');
            tmps := items[i].GetAttribute('node');
            if (tmps <> '') then
                iq.qTag.setAttribute('node', tmps);
            iq.Namespace := XMLNS_DISCOINFO;
            iq.Send();
            _disco_count := _disco_count + 1;
        end;
    end;
end;

{---------------------------------------}
procedure TfSendStatus.DiscoInfoCallback(event: string; tag: TXMLTag);
var
    x: TXMLTag;
    p: THostPortPair;
begin
    // look at the features.. if it's category=proxy, type=bytestreams
    if ((event = 'xml') and (tag.getAttribute('type') = 'result')) then begin
        x := tag.QueryXPTag('/iq/query/identity[@category="proxy"][@type="bytestreams"]');
        if (x <> nil) then begin
            p := THostPortPair.Create();
            p.jid := tag.GetAttribute('from');
            shosts.AddObject(p.jid, p);
        end;
    end;

    _disco_count := _disco_count - 1;
    if (_disco_count = 0) then begin
        _state := send_get_addr;
        DoState();
    end;

end;

{---------------------------------------}
procedure TfSendStatus.FTCallback(event: string; tag: TXMLTag);
var
    accept: boolean;
begin
    // They either accept, or deny our ft offering
    accept := false;
    if (event = 'xml') then begin
        if (tag.GetAttribute('type') = 'result') then begin
            // xxx: eventually, grovel, and get the selected stream-method
            // right now, we're only offering -65, so assume it.
            accept := true;
        end;
    end;

    if (accept) then
        _state := send_get_hosts
    else
        _state := send_cancel;

    DoState();
end;

{---------------------------------------}
procedure TfSendStatus.AddrCallback(event: string; tag: TXMLTag);
var
    i, j: integer;
    p: THostPortPair;
    sh: TXMLTagList;
begin
    // We are getting the address of a streamhost back
    if ((event = 'xml') and (tag.getAttribute('type') = 'result')) then begin
        sh := tag.QUeryXPTags('/iq/query/streamhost');
        for j := 0 to sh.Count - 1 do begin
            i := shosts.indexOf(sh[j].GetAttribute('jid'));
            if (i = -1) then begin
                p := THostPortPair.Create();
                p.jid := sh[i].GetAttribute('jid');
                shosts.AddObject(p.jid, p);
            end
            else
                p := THostPortPair(shosts.Objects[i]);

            p.host := sh[j].GetAttribute('host');
            p.port := SafeInt(sh[j].GetAttribute('port'));
        end;

    end
    else begin
        // remove this from the list
        if (tag <> nil) then
            i := shosts.indexOf(tag.getAttribute('from'))
        else
            i := shosts.indexOf(_iq.toJid);

        if (i >= 0) then begin
            p := THostPortPair(shosts.objects[i]);
            shosts.Delete(i);
            p.Free();
        end;
    end;

    if (not getNextHostAddr()) then begin
        _state := send_offer_hosts;
        DoState();
    end;

end;

{---------------------------------------}
procedure TfSendStatus.SelectHostCallback(event: string; tag: TXMLTag);
begin
    // The recip has selected a host
    if ((event = 'xml') and (tag.GetAttribute('type') = 'result')) then begin
        // they have accepted a specific streamhost
        _shost := tag.QueryXPData('/iq/query/streamhost-used@jid');

        // xxx: take into account shost being MYSELF

        _state := send_try_connect;
        DoState();
    end;

end;

{---------------------------------------}
procedure TfSendStatus.ActiveCallback(event: string; tag: TXMLTag);
begin
    // The stream host has told us that the channel is active.
    if (event = 'xml') then begin
        if (tag.GetAttribute('type') = 'result') then begin
            _state := send_sending;
            DoState();
            exit;
        end;

    end;
end;

{---------------------------------------}
procedure TfSendStatus.WMSendDone(var msg: TMessage);
begin
    // our thread completed.
    if (_pkg.mode = send_dav) then begin
        if ((msg.LParam >= 200) and
            (msg.LParam < 300)) then
            sendIQ()
        else
            MessageDlg(sXferDavError, mtError, [mbOK], 0);
        Self.Free();
    end
    else begin
        btnCancel.Caption := _('Close');
    end;
end;

{---------------------------------------}
procedure TfSendStatus.WMSendOK(var msg: TMessage);
begin
    // We got connected
    _state := send_activate;
    DoState();
end;

{---------------------------------------}
procedure TfSendStatus.WMSendBad(var msg: TMessage);
begin
    //
    _state := send_cancel;
    DoState();
end;


initialization
    shosts := TWidestringlist.Create;


end.
