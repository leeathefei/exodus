unit Dockable;
{
    Copyright 2001, Peter Millard

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

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    ComCtrls, Dialogs, ExtCtrls, TntComCtrls;

type
  TDockNotify = procedure of object;

  TfrmDockable = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
  private
    { Private declarations }
    _docked: boolean;
    _pos: TRect;
    _noMoveCheck: boolean;

    _onDockStartChange: TDockNotify;
    _onDockEndChange: TDockNotify;

    procedure CheckPos();
    procedure SavePos();

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    //procedure WMWindowPosChanging(var msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMActivate(var msg: TMessage); message WM_ACTIVATE;
    //procedure WMMouseActivate(var msg: TMessage); message WM_MOUSEACTIVATE;
    procedure WMDisplayChange(var msg: TMessage); message WM_DISPLAYCHANGE;
  published
    property OnDockStartChange: TDockNotify read _onDockStartChange write _onDockStartChange;
    property OnDockEndChange: TDockNotify read _onDockEndChange write _onDockEndChange;
  public
    { Public declarations }
    TabSheet: TTntTabSheet;
    procedure DockForm; virtual;
    procedure FloatForm; virtual;
    procedure ShowDefault;
    procedure gotActivate; virtual;

    property Docked: boolean read _docked write _docked;
  end;

var
  frmDockable: TfrmDockable;

implementation

{$R *.dfm}

uses
    XMLUtils, ChatWin, Debug, JabberUtils, ExUtils,  GnuGetText, Session, Jabber1;

{---------------------------------------}
procedure TfrmDockable.FormCreate(Sender: TObject);
begin
    _docked := false;
    _noMoveCheck := true;

    // do translation magic
    AssignUnicodeFont(Self);
    TranslateComponent(Self);

    if (Self is TfrmChat) then
        // do nothing
    else
        MainSession.Prefs.RestorePosition(Self);

    SnapBuffer := MainSession.Prefs.getInt('edge_snap');

    Self.SavePos();

    _noMoveCheck := false;
end;

{---------------------------------------}
procedure TfrmDockable.DockForm;
begin
    // dock the window to the main form
    if Assigned(_onDockStartChange) then
        Self.OnDockStartChange();

    Self.SavePos();
    Self.ManualDock(frmExodus.Tabs);
    Self.Align := alClient;
    _docked := true;
    Self.TabSheet := TTntTabSheet(frmExodus.Tabs.Pages[frmExodus.Tabs.PageCount-1]);
    if (Self.TabSheet <> nil) then
        Self.TabSheet.ImageIndex := -1;

    if Assigned(_onDockEndChange) then
        Self.OnDockEndChange();
end;

{---------------------------------------}
procedure TfrmDockable.CheckPos();
begin
    if (_pos.Right - _pos.Left) <= 100 then
        _pos.Right := _pos.Left + 150;

    if (_pos.Bottom - _pos.Top) <= 100 then
        _pos.Bottom := _pos.Top + 150;
end;

{---------------------------------------}
procedure TfrmDockable.SavePos();
begin
    _pos.Left := Self.Left;
    _pos.Right := Self.Left + Self.Width;
    _pos.Top := Self.Top;
    _pos.Bottom := Self.Top + Self.Height;
end;

{---------------------------------------}
procedure TfrmDockable.FloatForm;
begin
    if Assigned(_onDockStartChange) then
        Self.OnDockStartChange();
    Self.CheckPos();
    Self.ManualFloat(_pos);
    _docked := false;
    Self.TabSheet := nil;
    if Assigned(_onDockEndChange) then
        Self.OnDockEndChange();
end;

{---------------------------------------}
procedure TfrmDockable.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    if ((not _docked) and (MainSession <> nil)) then begin
        if (Self is TfrmChat) then
            MainSession.Prefs.SavePosition(Self, MungeName(Self.Caption))
        else
            MainSession.Prefs.SavePosition(Self);
    end;

    CanClose := true;
end;

{---------------------------------------}
procedure TfrmDockable.CreateParams(var Params: TCreateParams);
begin
    // Make each window appear on the task bar.
    inherited CreateParams(Params);
    with Params do begin
        ExStyle := ExStyle or WS_EX_APPWINDOW;
        // WndParent := GetDesktopWindow();
    end;
end;

{---------------------------------------}
procedure TfrmDockable.ShowDefault;
begin
    // show this form using the default behavior
    if MainSession.Prefs.getBool('expanded') then begin
        if (TabSheet = nil) then begin
            // dock the form
            Self.DockForm();
            Self.Show();
        end;

        // always make sure we are visible
        Self.Visible := true;

        // focus on the new tab if we are on the roster.
        if ((not Application.Active) or
            (frmExodus.Tabs.ActivePage = frmExodus.tbsRoster)) then begin
            frmExodus.Tabs.ActivePage := TabSheet;
        end;
    end
    else begin
        if (frmExodus.isMinimized()) then
            ShowWindow(Handle, SW_SHOWMINNOACTIVE)
        else
            ShowWindow(Handle, SW_SHOWNOACTIVATE);
        Self.Visible := true;
    end;

end;

{---------------------------------------}
procedure TfrmDockable.WMDisplayChange(var msg: TMessage);
begin
    checkAndCenterForm(Self);
end;

{---------------------------------------}
procedure TfrmDockable.WMActivate(var msg: TMessage);
begin
    if ((Application.Active) or (Msg.WParamLo = WA_CLICKACTIVE)) then begin
        // we are getting clicked..
        OutputDebugString('frmDockable.WMActivate');
        StopTrayAlert();
        gotActivate();
        inherited;
    end
    else
        inherited;
end;

{---------------------------------------}
procedure TfrmDockable.gotActivate();
begin
    // implement this in sub-classes.
end;

{---------------------------------------}
procedure TfrmDockable.FormResize(Sender: TObject);
begin
    if ((MainSession <> nil)) then
        MainSession.Prefs.SavePosition(Self);
end;

{---------------------------------------}
procedure TfrmDockable.FormEndDock(Sender, Target: TObject; X, Y: Integer);
begin
    if (Target <> frmExodus.Tabs) then exit;

    if Self.TabSheet <> nil then begin
        Self.TabSheet.ImageIndex := -1;
        frmExodus.Tabs.ActivePage.ImageIndex := -1;
    end;
end;

end.
