unit COMExControls;
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
ComObj, ActiveX, ExodusCOM_TLB, Forms, Classes, Controls, StdCtrls, StdVcl;

function getCOMControl(o: TObject): IExodusControl;

implementation
uses
    COMExFont,Graphics,COMExPanel,TntExtCtrls,COMExPopupMenu,COMExMenuItem,TntMenus,COMExButton,TntStdCtrls,COMExLabel,COMExEdit,COMExCheckBox,COMExRadioButton,COMExListBox,COMExComboBox,COMExRichEdit,ComCtrls;

function getCOMControl(o: TObject): IExodusControl;
begin
    if (o is TFont) then begin 
        Result := IExodusControl(TExControlFont.Create(TFont(o)));
        exit;
    end;
    if (o is TTntPanel) then begin 
        Result := IExodusControl(TExControlPanel.Create(TTntPanel(o)));
        exit;
    end;
    if (o is TTntMenuItem) then begin 
        Result := IExodusControl(TExControlMenuItem.Create(TTntMenuItem(o)));
        exit;
    end;
    if (o is TTntPopupMenu) then begin 
        Result := IExodusControl(TExControlPopupMenu.Create(TTntPopupMenu(o)));
        exit;
    end;
    if (o is TTntButton) then begin 
        Result := IExodusControl(TExControlButton.Create(TTntButton(o)));
        exit;
    end;
    if (o is TTntLabel) then begin 
        Result := IExodusControl(TExControlLabel.Create(TTntLabel(o)));
        exit;
    end;
    if (o is TTntEdit) then begin 
        Result := IExodusControl(TExControlEdit.Create(TTntEdit(o)));
        exit;
    end;
    if (o is TTntCheckBox) then begin 
        Result := IExodusControl(TExControlCheckBox.Create(TTntCheckBox(o)));
        exit;
    end;
    if (o is TTntRadioButton) then begin 
        Result := IExodusControl(TExControlRadioButton.Create(TTntRadioButton(o)));
        exit;
    end;
    if (o is TTntListBox) then begin 
        Result := IExodusControl(TExControlListBox.Create(TTntListBox(o)));
        exit;
    end;
    if (o is TTntComboBox) then begin 
        Result := IExodusControl(TExControlComboBox.Create(TTntComboBox(o)));
        exit;
    end;
    if (o is TRichEdit) then begin 
        Result := IExodusControl(TExControlRichEdit.Create(TRichEdit(o)));
        exit;
    end;
end;

end.
