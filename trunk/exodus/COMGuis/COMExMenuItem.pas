unit COMExMenuItem;
{
    Copyright 2006, Peter Millard

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


{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ This is autogenerated code using the COMGuiGenerator. DO NOT MODIFY BY HAND }
{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}


{$WARN SYMBOL_PLATFORM OFF}

interface
uses
    TntMenus, ComObj, ActiveX, ExodusCOM_TLB, Forms, Classes, Controls, StdCtrls, StdVcl;

type
    TExControlMenuItem = class(TAutoObject, IExodusControl, IExodusControlMenuItem)
    public
        constructor Create(control: TTntMenuItem);

    private
        _control: TTntMenuItem;

    protected
        function Get_ControlType: ExodusControlTypes; safecall;
        function Get_Name: Widestring; safecall;
        procedure Set_Name(const Value: Widestring); safecall;
        function Get_Tag: Integer; safecall;
        procedure Set_Tag(Value: Integer); safecall;
        function Get_AutoCheck: Integer; safecall;
        procedure Set_AutoCheck(Value: Integer); safecall;
        function Get_AutoHotkeys: Integer; safecall;
        procedure Set_AutoHotkeys(Value: Integer); safecall;
        function Get_AutoLineReduction: Integer; safecall;
        procedure Set_AutoLineReduction(Value: Integer); safecall;
        function Get_Break: Integer; safecall;
        procedure Set_Break(Value: Integer); safecall;
        function Get_Caption: Widestring; safecall;
        procedure Set_Caption(const Value: Widestring); safecall;
        function Get_Checked: Integer; safecall;
        procedure Set_Checked(Value: Integer); safecall;
        function Get_Default: Integer; safecall;
        procedure Set_Default(Value: Integer); safecall;
        function Get_Enabled: Integer; safecall;
        procedure Set_Enabled(Value: Integer); safecall;
        function Get_GroupIndex: Integer; safecall;
        procedure Set_GroupIndex(Value: Integer); safecall;
        function Get_HelpContext: Integer; safecall;
        procedure Set_HelpContext(Value: Integer); safecall;
        function Get_Hint: Widestring; safecall;
        procedure Set_Hint(const Value: Widestring); safecall;
        function Get_ImageIndex: Integer; safecall;
        procedure Set_ImageIndex(Value: Integer); safecall;
        function Get_RadioItem: Integer; safecall;
        procedure Set_RadioItem(Value: Integer); safecall;
        function Get_ShortCut: Integer; safecall;
        procedure Set_ShortCut(Value: Integer); safecall;
        function Get_Visible: Integer; safecall;
        procedure Set_Visible(Value: Integer); safecall;
    end;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation


constructor TExControlMenuItem.Create(control: TTntMenuItem);
begin
     _control := control; 
end;

function TExControlMenuItem.Get_ControlType: ExodusControlTypes;
begin
    Result := ExodusControlMenuItem;
end;

function TExControlMenuItem.Get_Name: Widestring;
begin
      Result := _control.Name;
end;

procedure TExControlMenuItem.Set_Name(const Value: Widestring);
begin
      _control.Name := Value;
end;

function TExControlMenuItem.Get_Tag: Integer;
begin
      Result := _control.Tag;
end;

procedure TExControlMenuItem.Set_Tag(Value: Integer);
begin
      _control.Tag := Value;
end;

function TExControlMenuItem.Get_AutoCheck: Integer;
begin
    if (_control.AutoCheck = False) then Result := 0;
    if (_control.AutoCheck = True) then Result := 1;
end;

procedure TExControlMenuItem.Set_AutoCheck(Value: Integer);
begin
   if (Value = 0) then _control.AutoCheck := False;
   if (Value = 1) then _control.AutoCheck := True;
end;

function TExControlMenuItem.Get_AutoHotkeys: Integer;
begin
    if (_control.AutoHotkeys = maAutomatic) then Result := 0;
    if (_control.AutoHotkeys = maManual) then Result := 1;
    if (_control.AutoHotkeys = maParent) then Result := 2;
end;

procedure TExControlMenuItem.Set_AutoHotkeys(Value: Integer);
begin
   if (Value = 0) then _control.AutoHotkeys := maAutomatic;
   if (Value = 1) then _control.AutoHotkeys := maManual;
   if (Value = 2) then _control.AutoHotkeys := maParent;
end;

function TExControlMenuItem.Get_AutoLineReduction: Integer;
begin
    if (_control.AutoLineReduction = maAutomatic) then Result := 0;
    if (_control.AutoLineReduction = maManual) then Result := 1;
    if (_control.AutoLineReduction = maParent) then Result := 2;
end;

procedure TExControlMenuItem.Set_AutoLineReduction(Value: Integer);
begin
   if (Value = 0) then _control.AutoLineReduction := maAutomatic;
   if (Value = 1) then _control.AutoLineReduction := maManual;
   if (Value = 2) then _control.AutoLineReduction := maParent;
end;

function TExControlMenuItem.Get_Break: Integer;
begin
    if (_control.Break = mbNone) then Result := 0;
    if (_control.Break = mbBreak) then Result := 1;
    if (_control.Break = mbBarBreak) then Result := 2;
end;

procedure TExControlMenuItem.Set_Break(Value: Integer);
begin
   if (Value = 0) then _control.Break := mbNone;
   if (Value = 1) then _control.Break := mbBreak;
   if (Value = 2) then _control.Break := mbBarBreak;
end;

function TExControlMenuItem.Get_Caption: Widestring;
begin
      Result := _control.Caption;
end;

procedure TExControlMenuItem.Set_Caption(const Value: Widestring);
begin
      _control.Caption := Value;
end;

function TExControlMenuItem.Get_Checked: Integer;
begin
    if (_control.Checked = False) then Result := 0;
    if (_control.Checked = True) then Result := 1;
end;

procedure TExControlMenuItem.Set_Checked(Value: Integer);
begin
   if (Value = 0) then _control.Checked := False;
   if (Value = 1) then _control.Checked := True;
end;

function TExControlMenuItem.Get_Default: Integer;
begin
    if (_control.Default = False) then Result := 0;
    if (_control.Default = True) then Result := 1;
end;

procedure TExControlMenuItem.Set_Default(Value: Integer);
begin
   if (Value = 0) then _control.Default := False;
   if (Value = 1) then _control.Default := True;
end;

function TExControlMenuItem.Get_Enabled: Integer;
begin
    if (_control.Enabled = False) then Result := 0;
    if (_control.Enabled = True) then Result := 1;
end;

procedure TExControlMenuItem.Set_Enabled(Value: Integer);
begin
   if (Value = 0) then _control.Enabled := False;
   if (Value = 1) then _control.Enabled := True;
end;

function TExControlMenuItem.Get_GroupIndex: Integer;
begin
      Result := _control.GroupIndex;
end;

procedure TExControlMenuItem.Set_GroupIndex(Value: Integer);
begin
      _control.GroupIndex := Value;
end;

function TExControlMenuItem.Get_HelpContext: Integer;
begin
      Result := _control.HelpContext;
end;

procedure TExControlMenuItem.Set_HelpContext(Value: Integer);
begin
      _control.HelpContext := Value;
end;

function TExControlMenuItem.Get_Hint: Widestring;
begin
      Result := _control.Hint;
end;

procedure TExControlMenuItem.Set_Hint(const Value: Widestring);
begin
      _control.Hint := Value;
end;

function TExControlMenuItem.Get_ImageIndex: Integer;
begin
      Result := _control.ImageIndex;
end;

procedure TExControlMenuItem.Set_ImageIndex(Value: Integer);
begin
      _control.ImageIndex := Value;
end;

function TExControlMenuItem.Get_RadioItem: Integer;
begin
    if (_control.RadioItem = False) then Result := 0;
    if (_control.RadioItem = True) then Result := 1;
end;

procedure TExControlMenuItem.Set_RadioItem(Value: Integer);
begin
   if (Value = 0) then _control.RadioItem := False;
   if (Value = 1) then _control.RadioItem := True;
end;

function TExControlMenuItem.Get_ShortCut: Integer;
begin
      Result := _control.ShortCut;
end;

procedure TExControlMenuItem.Set_ShortCut(Value: Integer);
begin
      _control.ShortCut := Value;
end;

function TExControlMenuItem.Get_Visible: Integer;
begin
    if (_control.Visible = False) then Result := 0;
    if (_control.Visible = True) then Result := 1;
end;

procedure TExControlMenuItem.Set_Visible(Value: Integer);
begin
   if (Value = 0) then _control.Visible := False;
   if (Value = 1) then _control.Visible := True;
end;




end.
