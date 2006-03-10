unit COMChatController;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
    ExodusCOM_TLB, 
    Session, ChatController, ChatWin, Chat, Room, MsgRecv, Unicode,
    Windows, Classes, ComObj, ActiveX, StdVcl;

type
  TExodusChat = class(TAutoObject, IExodusChat)
  protected
    function Get_jid: WideString; safecall;
    function AddContextMenu(const Caption: WideString): WideString; safecall;
    function Get_MsgOutText: WideString; safecall;
    function UnRegister(ID: Integer): WordBool; safecall;
    function RegisterPlugin(const Plugin: IExodusChatPlugin): Integer;
      safecall;
    function getMagicInt(Part: ChatParts): Integer; safecall;
    procedure RemoveContextMenu(const ID: WideString); safecall;
    procedure AddMsgOut(const Value: WideString); safecall;
    function AddMsgOutMenu(const Caption: WideString): WideString; safecall;
    procedure RemoveMsgOutMenu(const MenuID: WideString); safecall;
    procedure SendMessage(var Body: WideString; var Subject: WideString; var XML: WideString); safecall;
    function Get_CurrentThreadID: WideString; safecall;
    procedure DisplayMessage(const Body, Subject, From: WideString); safecall;
    procedure AddRoomUser(const JID, Nickname: WideString); safecall;
    procedure RemoveRoomUser(const JID: WideString); safecall;
    function Get_CurrentNick: WideString; safecall;
    function GetControl(const Name: WideString): IUnknown; safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;  function IExodusChat.GetControl = IExodusChat_GetControl;
  
    function IExodusChat_GetControl(const Name: WideString): IExodusControl;
      safecall;
    { Protected declarations }

  public
    constructor Create();
    destructor Destroy(); override;

    procedure setIM(im: TfrmMsgRecv);
    procedure setRoom(room: TfrmRoom);
    procedure setChatSession(chat_session: TChatController);
    procedure fireMsgKeyPress(Key: Char);
    function  fireBeforeMsg(var body: Widestring): boolean;
    function  fireAfterMsg(var body: WideString): Widestring;
    procedure fireRecvMsg(body, xml: Widestring);
    procedure fireMenuClick(Sender: TObject);
    procedure fireNewWindow(new_hwnd: HWND);
    procedure fireClose();

  private
    _im: TfrmMsgRecv;
    _room: TfrmRoom;
    _chat: TChatController;
    _plugs: TList;
    _menu_items: TWidestringlist;
    _nextid: longint;
  end;

  TChatPlugin = class
    com: IExodusChatPlugin;
end;


implementation

uses
    COMExControls, 
    Controls, BaseMsgList, RTFMsgList, XMLTag, ComServ, Menus, SysUtils;

{---------------------------------------}
constructor TExodusChat.Create();
begin
    inherited Create();
    _plugs := TList.Create();
    _menu_items := TWidestringlist.Create();
    _nextid := 0;
end;

{---------------------------------------}
destructor TExodusChat.Destroy();
var
    i: integer;
begin
    // free all of our plugin proxies
    for i := _plugs.Count - 1 downto 0 do begin
        TChatPlugin(_plugs[i]).com.onClose();
    end;

    // free all of our plugin menu items
    for i := 0 to _menu_items.Count - 1 do
        TMenuItem(_menu_items.Objects[i]).Free();
    _menu_items.Clear();
    _menu_items.Free();


    _plugs.Clear();
    _plugs.Free();

    inherited Destroy();
end;

procedure TExodusChat.setIM(im: TfrmMsgRecv);
begin
    _im := im;
    _room := nil;
    _chat := nil;
end;

{---------------------------------------}
procedure TExodusChat.setChatSession(chat_session: TChatController);
begin
    _im   := nil;
    _room := nil;
    _chat := chat_session;
end;

{---------------------------------------}
procedure TExodusChat.setRoom(room: TfrmRoom);
begin
  _im   := nil;
  _chat := nil;
  _room := room;
end;

{---------------------------------------}
procedure TExodusChat.fireMsgKeyPress(Key: Char);
var
    i: integer;
begin
    for i := 0 to _plugs.count - 1 do
        TChatPlugin(_plugs[i]).com.onKeyPress(Key);
end;

{---------------------------------------}
function TExodusChat.fireBeforeMsg(var body: Widestring): boolean;
var
    i: integer;
begin
    Result := true;
    for i := 0 to _plugs.Count - 1 do begin
        Result := TChatPlugin(_plugs[i]).com.onBeforeMessage(body);
        if (Result = false) then exit;
    end;
end;

{---------------------------------------}
function TExodusChat.fireAfterMsg(var body: WideString): Widestring;
var
    i: integer;
    buff: Widestring;
begin
    buff := '';
    for i := 0 to _plugs.Count - 1 do
        buff := buff + TChatPlugin(_plugs[i]).com.onAfterMessage(body);
    Result := buff;
end;

{---------------------------------------}
procedure TExodusChat.fireRecvMsg(body, xml: Widestring);
var
    i: integer;
begin
    for i := 0 to _plugs.Count - 1 do
        TChatPlugin(_plugs[i]).com.onRecvMessage(body, xml);
end;

{---------------------------------------}
procedure TExodusChat.fireNewWindow(new_hwnd: HWND);
var
    i: integer;
begin
    for i := 0 to _plugs.Count - 1 do
        TChatPlugin(_plugs[i]).com.OnNewWindow(new_hwnd);
end;

{---------------------------------------}
procedure TExodusChat.fireClose();
var
    i: integer;
begin
    for i := _plugs.Count - 1 downto 0 do
        TChatPlugin(_plugs[i]).com.onClose();
end;

{---------------------------------------}
procedure TExodusChat.fireMenuClick(Sender: TObject);
var
    i, idx: integer;
begin
    idx := _menu_items.IndexOfObject(Sender);
    if (idx >= 0) then begin
        for i := 0 to _plugs.Count - 1 do
            TChatPlugin(_plugs[i]).com.onMenu(_menu_items[idx]);
    end;
end;

{---------------------------------------}
function TExodusChat.Get_jid: WideString;
begin
    Result := '';
    if (_chat <> nil) then Result := _chat.JID
    else if (_im <> nil) then Result := _im.JID
    else if (_room <> nil) then Result := _room.getJid;
end;

{---------------------------------------}
function TExodusChat.AddContextMenu(const Caption: WideString): WideString;
var
    id: Widestring;
    mi: TMenuItem;
    idx: integer;
begin
    // add a new TMenuItem to the Plugins menu
    inc(_nextid);
    idx := _nextid;
    id := 'plugin_' + IntToStr(idx);
    
    if (_room <> nil) then begin
        mi := TMenuItem.Create(_room);
        mi.Name := id;
        mi.OnClick := _room.pluginMenuClick;
        mi.Caption := caption;
        _room.popRoom.Items.Add(mi);
    end
    else if (_chat <> nil) then begin
        mi := TMenuItem.Create(TfrmChat(_chat.window));
        mi.Name := id;
        mi.OnClick := TfrmChat(_chat.window).pluginMenuClick;
        mi.Caption := caption;
        TfrmChat(_chat.window).popContact.Items.Add(mi);
    end
    else if (_im <> nil) then begin
        mi := TMenuItem.Create(_im);
        mi.Name := id;
        mi.OnClick := _im.pluginMenuClick;
        mi.Caption := caption;
        _im.popContact.Items.Add(mi);
    end
    else
        exit;

    _menu_items.AddObject(id, mi);
    Result := id;
end;

{---------------------------------------}
function TExodusChat.AddMsgOutMenu(const Caption: WideString): WideString;
var
    id: Widestring;
    mi: TMenuItem;
begin
    // add a new TMenuItem to the Plugins menu
    id := 'plugin_' + IntToStr(_menu_items.Count);
    if (_room <> nil) then begin
        mi := TMenuItem.Create(_room);
        mi.Name := id;
        mi.OnClick := _room.pluginMenuClick;
        mi.Caption := caption;
        _room.popOut.Items.Add(mi);
    end
    else if (_chat <> nil) then begin
        mi := TMenuItem.Create(TfrmChat(_chat.window));
        mi.Name := id;
        mi.OnClick := TfrmChat(_chat.window).pluginMenuClick;
        mi.Caption := caption;
        TfrmChat(_chat.window).popOut.Items.Add(mi);
    end
    else if (_im <> nil) then begin
        mi := TMenuItem.Create(_im);
        mi.Name := id;
        mi.OnClick := _im.pluginMenuClick;
        mi.Caption := caption;
        _im.popClipboard.Items.Add(mi);
    end
    else
        exit;

    _menu_items.AddObject(id, mi);
    Result := id;
end;

{---------------------------------------}
procedure TExodusChat.RemoveContextMenu(const ID: WideString);
var
    idx: integer;
    mi: TMenuItem;
begin
    // remove this menu item.
    idx := _menu_items.indexOf(ID);
    if (idx < 0) then exit;
    mi := TMenuItem(_menu_items.Objects[idx]);
    _menu_items.Delete(idx);
    mi.Free();
end;

{---------------------------------------}
procedure TExodusChat.RemoveMsgOutMenu(const MenuID: WideString);
begin
    // remove this menu item.
    RemoveContextMenu(MenuID);
end;

{---------------------------------------}
function TExodusChat.Get_MsgOutText: WideString;
begin
    if (_chat <> nil) then
        Result := TfrmChat(_chat.window).MsgOut.Text
    else if (_room <> nil) then
        Result := _room.MsgOut.Text
    else if (_im <> nil) then
        Result := _im.MsgOut.Text;

end;

{---------------------------------------}
function TExodusChat.UnRegister(ID: Integer): WordBool;
var
    cp: TChatPlugin;
begin
    if ((id >= 0) and (id < _plugs.count)) then begin
        cp := TChatPlugin(_plugs[id]);
        _plugs.Delete(id);
        cp.Free();
        Result := true;
    end
    else
        Result := false;
end;

{---------------------------------------}
function TExodusChat.RegisterPlugin(
  const Plugin: IExodusChatPlugin): Integer;
var
    cp: TChatPlugin;
begin
    cp := TChatPlugin.Create;
    cp.com := Plugin;
    Plugin._AddRef();
    Result := _plugs.Add(cp);
end;

{---------------------------------------}
function TExodusChat.getMagicInt(Part: ChatParts): Integer;
var
    p: Pointer;
begin
    Result := -1;
    case Part of
    HWND_MsgInput: begin
        if (_chat <> nil) then
            Result := TfrmChat(_chat.window).MsgOut.Handle
        else if (_room <> nil) then
            Result := _room.MsgOut.Handle
        else if (_im <> nil) then
            Result := _im.MsgOut.Handle
        else exit;
    end;
    HWND_MsgOutput: begin
        if (_chat <> nil) then
            Result := TfrmChat(_chat.window).MsgList.getHandle()
        else if (_room <> nil) then
            Result := _room.MsgOut.Handle
        else if (_im <> nil) then
            Result := _im.txtMsg.Handle
        else exit;
    end;
    Ptr_MsgInput: begin
        if (_chat <> nil) then begin
            p := @(TfrmChat(_chat.window).MsgOut);
            Result := integer(p);
        end
        else if (_room <> nil) then begin
            p := @(_room.MsgOut);
            Result := integer(p);
        end
        else if (_im <> nil) then begin
            p := @(_im.MsgOut);
            Result := integer(p);
        end;
    end;
    Ptr_MsgOutput: begin
        if (_chat <> nil) then begin
            // If we have an RTF msg list, use that
            if (TfrmChat(_chat.window).MsgList is TfRTFMsgList) then begin
                p := @(TfRTFMsgList(TfrmChat(_chat.window).MsgList).MsgList);
                Result := integer(p);
            end
            else
                Result := -1;
        end
        else if (_room <> nil) then begin
            if (_room.MsgList is TfRTFMsgList) then begin
                p := @(TfRTFMsgList(_room.MsgList).MsgList);
                Result := integer(p);
            end
            else
                Result := -1;
        end
        else if (_im <> nil) then begin
            p := @(_im.txtMsg);
            Result := integer(p);
        end;
    end;
    end;

end;

{---------------------------------------}
procedure TExodusChat.AddMsgOut(const Value: WideString);
begin
    // add something to the RichEdit control
    if (_chat <> nil) then
        TfrmChat(_chat.window).MsgOut.WideLines.Add(Value)
    else if (_room <> nil) then
        _room.MsgOut.WideLines.Add(Value)
    else if (_im <> nil) then
        _im.txtMsg.WideLines.Add(Value);
end;

{---------------------------------------}
procedure TExodusChat.SendMessage(var Body: WideString; var Subject: WideString;
    var XML: WideString);
begin
    // spin up a message and send it..
    if (_chat <> nil) then
        TfrmChat(_chat.window).SendRawMessage(Body, Subject, XML, false)
    else if (_room <> nil) then
        _room.SendRawMessage(Body, Subject, XML, false);
end;

{---------------------------------------}
function TExodusChat.Get_CurrentThreadID: WideString;
begin
    //
    if (_chat <> nil) then
        Result := TfrmChat(_chat.window).CurrentThread
    else
        Result := '';
end;

{---------------------------------------}
procedure TExodusChat.DisplayMessage(const Body, Subject,
  From: WideString);
var
    tag: TXMLTag;
begin
    tag := TXMLTag.Create('message');
    tag.setAttribute('from', from);
    if (Body <> '') then
        tag.AddBasicTag('body', Body);
    if (Subject <> '') then
        tag.AddBasicTag('subject', Subject);

    if (_chat <> nil) then
        TfrmChat(_chat.window).showMsg(tag)
    else if (_room <> nil) then
        _room.ShowMsg(tag);

    tag.Free();
end;

{---------------------------------------}
procedure TExodusChat.AddRoomUser(const JID, Nickname: WideString);
begin
    if (_room <> nil) then
        _room.addRoomUser(JID, Nickname);
end;

{---------------------------------------}
procedure TExodusChat.RemoveRoomUser(const JID: WideString);
begin
    if (_room <> nil) then
        _room.removeRoomUser(Jid);
end;

{---------------------------------------}
function TExodusChat.Get_CurrentNick: WideString;
begin
    if (_room <> nil) then
        Result := _room.myNick;
end;

{---------------------------------------}
function TExodusChat.GetControl(const Name: WideString): IUnknown;
var
    i: IExodusControl;
    comp : TComponent;
begin
    i := nil;
    result := nil;
    try
        if (_chat <> nil) then begin
            comp := TfrmChat(_chat.window).FindComponent(Name);
            if comp <> nil then
                i := getCOMControl(comp);
        end
        else if (_room <> nil) then begin
            comp := _room.FindComponent(Name);
            if (comp <> nil) then
                i := getCOMControl(comp);
        end;
    except
        on EComponentError do
            Result := nil;
    end;
end;

{---------------------------------------}
function TExodusChat.Get_Caption: WideString;
begin
    if (_chat <> nil) then
        Result := TfrmChat(_chat.Window).Caption
    else if (_room <> nil) then
        Result := _room.Caption
    else
        Result := '';
end;

{---------------------------------------}
procedure TExodusChat.Set_Caption(const Value: WideString);
begin
    if (_chat <> nil) then
        TfrmChat(_chat.Window).Caption := Value
    else if (_room <> nil) then
        _room.Caption := Value;
end;

function TExodusChat.IExodusChat_GetControl(
  const Name: WideString): IExodusControl;
begin

end;

initialization
  TAutoObjectFactory.Create(ComServer, TExodusChat, Class_ExodusChat,
    ciMultiInstance, tmApartment);
end.
