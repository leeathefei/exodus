{
    Copyright 2001-2008, Estate of Peter Millard
	
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
unit COMExPopupMenu;



{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ This is autogenerated code using the COMGuiGenerator. DO NOT MODIFY BY HAND }
{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}


{$WARN SYMBOL_PLATFORM OFF}

interface
uses
    ActiveX,Classes,COMExMenuItem,ComObj,Controls,Exodus_TLB,Forms,Menus,StdCtrls,StdVcl,TntMenus;

type
    TExControlPopupMenu = class(TAutoObject, IExodusControl, IExodusControlPopupMenu)
    public
        constructor Create(control: TTntPopupMenu);

    private
        _control: TTntPopupMenu;

    protected
        function Get_ControlType: ExodusControlTypes; safecall;
        function Get_Name: Widestring; safecall;
        procedure Set_Name(const Value: Widestring); safecall;
        function Get_Tag: Integer; safecall;
        procedure Set_Tag(Value: Integer); safecall;
        function Get_ItemsCount: integer; safecall;
        function Get_Items(Index: integer): IExodusControlMenuItem; safecall;
        function Get_Alignment: Integer; safecall;
        procedure Set_Alignment(Value: Integer); safecall;
        function Get_AutoHotkeys: Integer; safecall;
        procedure Set_AutoHotkeys(Value: Integer); safecall;
        function Get_AutoLineReduction: Integer; safecall;
        procedure Set_AutoLineReduction(Value: Integer); safecall;
        function Get_AutoPopup: Integer; safecall;
        procedure Set_AutoPopup(Value: Integer); safecall;
        function Get_BiDiMode: Integer; safecall;
        procedure Set_BiDiMode(Value: Integer); safecall;
        function Get_HelpContext: Integer; safecall;
        procedure Set_HelpContext(Value: Integer); safecall;
        function Get_OwnerDraw: Integer; safecall;
        procedure Set_OwnerDraw(Value: Integer); safecall;
        function Get_ParentBiDiMode: Integer; safecall;
        procedure Set_ParentBiDiMode(Value: Integer); safecall;
        function Get_TrackButton: Integer; safecall;
        procedure Set_TrackButton(Value: Integer); safecall;
    end;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation


constructor TExControlPopupMenu.Create(control: TTntPopupMenu);
begin
     _control := control; 
end;

function TExControlPopupMenu.Get_ControlType: ExodusControlTypes;
begin
    Result := ExodusControlPopupMenu;
end;

function TExControlPopupMenu.Get_Name: Widestring;
begin
      Result := _control.Name;
end;

procedure TExControlPopupMenu.Set_Name(const Value: Widestring);
begin
      _control.Name := Value;
end;

function TExControlPopupMenu.Get_Tag: Integer;
begin
      Result := _control.Tag;
end;

procedure TExControlPopupMenu.Set_Tag(Value: Integer);
begin
      _control.Tag := Value;
end;

function TExControlPopupMenu.Get_ItemsCount: integer;
begin
    Result := _control.Items.Count;
end;

function TExControlPopupMenu.Get_Items(Index: integer): IExodusControlMenuItem;
begin
   if ((Index >= 0) and (Index < _control.Items.Count)) then
      Result := TExControlMenuItem.Create(TTntMenuItem(_control.Items[Index])) as IExodusControlMenuItem
   else 
      Result := nil;
end;

function TExControlPopupMenu.Get_Alignment: Integer;
begin
    if (_control.Alignment = paLeft) then Result := 0;
    if (_control.Alignment = paRight) then Result := 1;
    if (_control.Alignment = paCenter) then Result := 2;
end;

procedure TExControlPopupMenu.Set_Alignment(Value: Integer);
begin
   if (Value = 0) then _control.Alignment := paLeft;
   if (Value = 1) then _control.Alignment := paRight;
   if (Value = 2) then _control.Alignment := paCenter;
end;

function TExControlPopupMenu.Get_AutoHotkeys: Integer;
begin
    if (_control.AutoHotkeys = maAutomatic) then Result := 0;
    if (_control.AutoHotkeys = maManual) then Result := 1;
end;

procedure TExControlPopupMenu.Set_AutoHotkeys(Value: Integer);
begin
   if (Value = 0) then _control.AutoHotkeys := maAutomatic;
   if (Value = 1) then _control.AutoHotkeys := maManual;
end;

function TExControlPopupMenu.Get_AutoLineReduction: Integer;
begin
    if (_control.AutoLineReduction = maAutomatic) then Result := 0;
    if (_control.AutoLineReduction = maManual) then Result := 1;
end;

procedure TExControlPopupMenu.Set_AutoLineReduction(Value: Integer);
begin
   if (Value = 0) then _control.AutoLineReduction := maAutomatic;
   if (Value = 1) then _control.AutoLineReduction := maManual;
end;

function TExControlPopupMenu.Get_AutoPopup: Integer;
begin
    if (_control.AutoPopup = False) then Result := 0;
    if (_control.AutoPopup = True) then Result := 1;
end;

procedure TExControlPopupMenu.Set_AutoPopup(Value: Integer);
begin
   if (Value = 0) then _control.AutoPopup := False;
   if (Value = 1) then _control.AutoPopup := True;
end;

function TExControlPopupMenu.Get_BiDiMode: Integer;
begin
    if (_control.BiDiMode = bdLeftToRight) then Result := 0;
    if (_control.BiDiMode = bdRightToLeft) then Result := 1;
    if (_control.BiDiMode = bdRightToLeftNoAlign) then Result := 2;
    if (_control.BiDiMode = bdRightToLeftReadingOnly) then Result := 3;
end;

procedure TExControlPopupMenu.Set_BiDiMode(Value: Integer);
begin
   if (Value = 0) then _control.BiDiMode := bdLeftToRight;
   if (Value = 1) then _control.BiDiMode := bdRightToLeft;
   if (Value = 2) then _control.BiDiMode := bdRightToLeftNoAlign;
   if (Value = 3) then _control.BiDiMode := bdRightToLeftReadingOnly;
end;

function TExControlPopupMenu.Get_HelpContext: Integer;
begin
      Result := _control.HelpContext;
end;

procedure TExControlPopupMenu.Set_HelpContext(Value: Integer);
begin
      _control.HelpContext := Value;
end;

function TExControlPopupMenu.Get_OwnerDraw: Integer;
begin
    if (_control.OwnerDraw = False) then Result := 0;
    if (_control.OwnerDraw = True) then Result := 1;
end;

procedure TExControlPopupMenu.Set_OwnerDraw(Value: Integer);
begin
   if (Value = 0) then _control.OwnerDraw := False;
   if (Value = 1) then _control.OwnerDraw := True;
end;

function TExControlPopupMenu.Get_ParentBiDiMode: Integer;
begin
    if (_control.ParentBiDiMode = False) then Result := 0;
    if (_control.ParentBiDiMode = True) then Result := 1;
end;

procedure TExControlPopupMenu.Set_ParentBiDiMode(Value: Integer);
begin
   if (Value = 0) then _control.ParentBiDiMode := False;
   if (Value = 1) then _control.ParentBiDiMode := True;
end;

function TExControlPopupMenu.Get_TrackButton: Integer;
begin
    if (_control.TrackButton = tbRightButton) then Result := 0;
    if (_control.TrackButton = tbLeftButton) then Result := 1;
end;

procedure TExControlPopupMenu.Set_TrackButton(Value: Integer);
begin
   if (Value = 0) then _control.TrackButton := tbRightButton;
   if (Value = 1) then _control.TrackButton := tbLeftButton;
end;




end.
