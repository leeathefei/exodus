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
    ComCtrls, Dialogs, ExtCtrls;

type
  TDockNotify = procedure of object;

  TfrmDockable = class(TForm)
    timFlasher: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure timFlasherTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
  private
    { Private declarations }
    _docked: boolean;
    _pos: TRect;
    _noMoveCheck: boolean;
    _edge_snap: integer;
    _top: boolean;

    _onDockStartChange: TDockNotify;
    _onDockEndChange: TDockNotify;

    procedure CheckPos();
    procedure SavePos();
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMWindowPosChanging(var msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure WMActivate(var msg: TMessage); message WM_ACTIVATE;
    procedure WMMouseActivate(var msg: TMessage); message WM_MOUSEACTIVATE;
  published
    property OnDockStartChange: TDockNotify read _onDockStartChange write _onDockStartChange;
    property OnDockEndChange: TDockNotify read _onDockEndChange write _onDockEndChange;
  public
    { Public declarations }
    TabSheet: TTabSheet;
    procedure DockForm; virtual;
    procedure FloatForm; virtual;
    procedure ShowDefault;
    procedure Flash;

    property Docked: boolean read _docked write _docked;
  end;

var
  frmDockable: TfrmDockable;

implementation

{$R *.dfm}

uses
    ExUtils,
    Session,
    Jabber1;

{---------------------------------------}
procedure TfrmDockable.FormCreate(Sender: TObject);
begin
    _docked := false;
    _noMoveCheck := true;
    _top := false;

    MainSession.Prefs.RestorePosition(Self);
    _edge_snap := MainSession.Prefs.getInt('edge_snap');
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
    Self.TabSheet := frmExodus.Tabs.Pages[frmExodus.Tabs.PageCount-1];
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
    if (not _docked) then
        MainSession.Prefs.SavePosition(Self);
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
    	if (TabSheet <> nil) then begin
            frmExodus.Tabs.ActivePage := TabSheet;
            end
        else begin
            Self.DockForm;
            Self.Show;
            Self.Visible := true;
            if ((not Application.Active) or
            (frmExodus.Tabs.ActivePage = frmExodus.tbsRoster)) then
                frmExodus.Tabs.ActivePage := TabSheet;
            end;
        end
    else begin
        if frmExodus.WindowState = wsMinimized then
            ShowWindow(Handle, SW_SHOWMINNOACTIVE)
        else
            ShowWindow(Handle, SW_SHOWNOACTIVATE);
        Self.Visible := true;
        end;

end;

{---------------------------------------}
procedure TfrmDockable.WMWindowPosChanging(var msg: TWMWindowPosChanging);
var
    r: TRect;
begin
    if _noMoveCheck then begin
        inherited;
        exit;
        end;

    {
    _top indicates that we are moving the window to the top of
    the z-order manually using SetWindowPos()
    In this case, we don't want to subvert the normal z-order raising,
    otherwise, we DO want to subvert normal behavior so toast doesn't
    bring this window to the top of the z-order
    }

    if ((not Application.Active) and (not _top)) then
        // if the application is not active, don't bring the window to the top.
        msg.WindowPos^.flags := msg.WindowPos^.flags or SWP_NOZORDER;

    If ((SWP_NOMOVE or SWP_NOSIZE) and msg.WindowPos^.flags) <>
        (SWP_NOMOVE or SWP_NOSIZE) then begin
        {  Window is moved or sized, get usable screen area. }

        SystemParametersInfo( SPI_GETWORKAREA, 0, @r, 0 );

        {
        Check if operation would move part of the window out of this area.
        If so correct position and, if required, size, to keep window fully
        inside the workarea. Note that simply adding the SWM_NOMOVE and
        SWP_NOSIZE flags to the flags field does not work as intended if
        full dragging of windows is disabled. In this case the window would
        snap back to the start position instead of stopping at the edge of the
        workarea, and you could still move the drag rectangle outside that
        area.
        }

        with msg.WindowPos^ do begin
            if abs(x -  r.left) < _edge_snap then x:= r.left;
            if abs(y -  r.top) < _edge_snap then y := r.top;

            if abs( (x + cx) - r.right ) < _edge_snap then begin
                x := r.right - cx;
                if abs(x -  r.left) < _edge_snap then begin
                    cx := cx - (r.left - x);
                    x := r.Left;
                    end; { if }
                end; { if }

            if abs( (y + cy) - r.bottom ) < _edge_snap then begin
                y := r.bottom - cy;
                if abs(y -  r.top) < _edge_snap then begin
                    cy := cy - (r.top - y);
                    y := r.top;
                    end; { if }
                end; { if }
            end; { With }
        end;

    inherited;
end;

{---------------------------------------}
procedure TfrmDockable.WMActivate(var msg: TMessage);
begin
    if ((not _top) and
        ((Application.Active) or
         (Msg.WParamLo = WA_CLICKACTIVE) )
        ) then begin
        // we are getting clicked..
        _top := true;
        SetWindowPos(Self.Handle, 0, Self.Left, Self.Top,
            Self.Width, Self.Height, HWND_TOP);
        _top := false;
        inherited;
        end
    else
        inherited;
end;

{---------------------------------------}
procedure TfrmDockable.WMMouseActivate(var msg: TMessage);
begin
    if (not _top) then begin
        _top := true;
        SetWindowPos(Self.Handle, 0, Self.Left, Self.Top,
            Self.Width, Self.Height, HWND_TOP);
        _top := false;
        end
    else
        inherited;
end;

{---------------------------------------}
procedure TfrmDockable.FormResize(Sender: TObject);
begin
    if ((MainSession <> nil)) then
        MainSession.Prefs.SavePosition(Self);
end;

{---------------------------------------}
procedure TfrmDockable.timFlasherTimer(Sender: TObject);
begin
    FlashWindow(Self.Handle, true);
    FlashWindow(Self.Handle, true);
end;

{---------------------------------------}
procedure TfrmDockable.Flash;
begin
    if Self.Active then exit;

    if MainSession.Prefs.getBool('notify_flasher') then
        timFlasher.Enabled := true
    else begin
        timFlasher.Enabled := false;
        timFlasherTimer(Self);
        end;
end;


{---------------------------------------}
procedure TfrmDockable.FormActivate(Sender: TObject);
begin
    if timFlasher.Enabled then
        timFlasher.Enabled := false;
end;

{---------------------------------------}
procedure TfrmDockable.FormEndDock(Sender, Target: TObject; X, Y: Integer);
begin
    if Self.TabSheet <> nil then
        Self.TabSheet.ImageIndex := -1;
end;

end.
