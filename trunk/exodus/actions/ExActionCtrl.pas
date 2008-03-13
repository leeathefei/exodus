unit ExActionCtrl;

interface

uses ActiveX, ExActions, ExActionMap, Classes, ComObj, Contnrs, Unicode, Exodus_TLB, StdVcl;

type TActionProxy = class(TObject)
private
    _itemtype: Widestring;
    _name: Widestring;
    _delegate: IExodusAction;
    _enabling: TWidestringList; //List of name/value pairs
    _disabling: TWidestringList; //List of name/value pairs

    function enabledContainsAll(actual: TWidestringList): Boolean;
    function disabledContainsAny(actual: TWidestringList): Boolean;
    procedure Set_Delegate(const act: IExodusAction);
public
    constructor Create(itemtype, actname: Widestring);
    destructor Destroy(); override;

    procedure addToEnabling(filter: Widestring);
    procedure addToDisabling(filter: Widestring);
    function applies(enabling, disabling: TWidestringList): Boolean;

    property ItemType: Widestring read _itemtype;
    property Name: Widestring read _name;
    property Action: IExodusAction read _delegate write Set_Delegate;
    property EnablingFilter: TWidestringList read _enabling;
    property DisablingFilter: TWidestringList read _disabling;
end;

type TFilteringItem = class(TObject)
private
    _key, _val: Widestring;

public
    constructor CreateString(item: Widestring);
    constructor CreatePair(key, val: Widestring);
    destructor Destroy; override;

    property Key: Widestring read _key;
    property Value: Widestring read _val;

end;
type TFilteringSet = class(TObject)
private
    _itemcount: Integer;
    _enableHints, _disableHints: TWidestringList;
    _enableSet, _disableSet: TWidestringList;

public
    constructor Create(enableHints, disableHints: TWidestringList);
    constructor CreateFromList(filters: TWidestringList);
    destructor Destroy; override;

    procedure update(item: IExodusItem);

    property ItemCount: Integer read _itemcount;
    property Enabling: TWidestringList read _enableSet;
    property Disabling: TWidestringList read _disableSet;
end;

type TPotentialActions = class(TObject)
private
    _itemtype: Widestring;
    _proxies: TWidestringList;
    _enableHints, _disableHints: TWidestringList;

    function GetProxyCount: Integer;
    function GetProxyAt(idx: Integer): TActionProxy;

public
    constructor Create(itemtype: Widestring);
    destructor Destroy; override;

    procedure updateProxy(proxy: TActionProxy);

    function GetProxyNamed(actname: Widestring): TActionProxy;

    property ItemType: Widestring read _itemtype;
    property ProxyCount: Integer read GetProxyCount;
    property Proxy[idx: Integer]: TActionProxy read GetProxyAt;

    property EnableHints: TWidestringList read _enableHints;
    property DisableHints: TWidestringList read _disableHints;
end;

type TExodusActionController = class(TAutoObject, IExodusActionController)
private
    _actions: TWidestringList;

    function lookupActionsFor(itemtype: Widestring; create: boolean): TPotentialActions;

public
    constructor Create;
    destructor Destroy; override;

    procedure registerAction(const itemtype: Widestring; const act: IExodusAction); safecall;
    procedure addEnableFilter(const ItemType, actname, filter: WideString);
      safecall;
    procedure addDisableFilter(const ItemType, actname, filter: WideString);
      safecall;
    function buildActions(const items: IExodusItemList): IExodusActionMap; safecall;
end;

function GetActionController: IExodusActionController;

var FILTER_SELECTION_NONE, FILTER_SELECTION_SINGLE, FILTER_SELECTION_MULTI: TFilteringItem;

implementation

uses ComServ, SysUtils;

var g_ActCtrl: IExodusActionController;

{
    TProxyAction implementation
}
Constructor TActionProxy.Create(itemtype, actname: Widestring);
begin
    inherited Create;

    _name := Copy(actname, 1, Length(actname));
    _itemtype := Copy(itemtype, 1, Length(itemtype));

    _enabling := TWidestringList.Create;
    _enabling.Duplicates := dupAccept;

    _disabling := TWidestringList.Create;
    _disabling.Duplicates := dupAccept;

    if (itemtype <> '') then
        addToEnabling('type=' + itemtype);
end;
Destructor TActionProxy.Destroy;
begin
    _enabling.Free;
    _disabling.Free;

    inherited;
end;

function TActionProxy.enabledContainsAll(actual: TWideStringList): Boolean;
var
    idx, jdx: Integer;
    eval, aval: TFilteringItem;
begin
    //Assume it does contain all
    Result := true;

    //make sure we're sorted (lookups are faster)
    if not _enabling.Sorted then _enabling.Sorted := true;
    if not actual.Sorted then actual.Sorted := true;

    for idx := 0 to _enabling.Count - 1 do begin
        eval := TFilteringItem(_enabling.Objects[idx]);

        jdx := actual.IndexOf(eval.Key);
        if (jdx <> -1) then begin
            aval := TFilteringItem(actual.Objects[jdx]);
            Result := (eval.Value = aval.Value);
        end;

        if (not Result) then exit;
    end;
end;
function TActionProxy.disabledContainsAny(actual: TWidestringList): Boolean;
var
    idx, jdx: Integer;
    eval, aval: TFilteringItem;
begin
    //Assume it doesn't contain any
    Result := false;

    //make sure we're sorted (lookups are faster)
    if not _disabling.Sorted then _disabling.Sorted := true;
    if not actual.Sorted then actual.Sorted := true;

    for idx := 0 to _disabling.Count - 1 do begin
        eval := TFilteringItem(_disabling.Objects[idx]);

        jdx := actual.IndexOf(eval.Key);
        if (jdx <> -1) then begin
            aval := TFilteringItem(actual.Objects[jdx]);
            Result := (eval.Value = aval.Value);
        end;

        if (Result) then exit;
    end;
end;

procedure TActionProxy.Set_Delegate(const act: IExodusAction);
begin
    if _delegate <> nil then
        _delegate._Release;

    _delegate := act;
    if _delegate <> nil then
        _delegate._AddRef;
end;

procedure TActionProxy.addToEnabling(filter: Widestring);
var
    fitem :TFilteringItem;
begin
    fitem := TFilteringItem.CreateString(filter);

    if _enabling.Sorted then
        _enabling.Sorted := false;
    _enabling.AddObject(fitem.Key, fitem);
end;
procedure TActionProxy.addToDisabling(filter: Widestring);
var
    fitem :TFilteringItem;
begin
    fitem := TFilteringItem.CreateString(filter);

    if _disabling.Sorted then
        _disabling.Sorted := false;
    _disabling.AddObject(fitem.Key, fitem);
end;

function TActionProxy.applies(enabling, disabling: TWideStringList): Boolean;
begin
    //Check for "Do I exist?"
    If (Action = nil) then begin
        Result := false;
        exit;
    end;

    //Check for "do or die"!
    If not Action.Enabled then begin
        Result := false;
        exit;
    end;

    //Check enabling (if any are present)
    Result := (_enabling.Count = 0) or enabledContainsAll(enabling);
    if not Result then exit;

    //Check disabling
    Result := (_disabling.Count = 0) or not disabledContainsAny(disabling);
    if not Result then exit;

    Result := true;
end;

{
    TFilteringItem implementation
}
constructor TFilteringItem.CreateString(item: WideString);
var
    place: Integer;

begin
    inherited Create;

    place := Pos('=', item);
    if (place > 0) then begin
        _key := Copy(item, 1, place-1);
        _val := Copy(item, place+1, Length(item));
    end else begin
        _key := item;
        _val := 'true';
    end;

    _key := StrLowerW(PWideChar(_key));
end;
constructor TFilteringItem.CreatePair(key: WideString; val: WideString);
begin
    inherited Create;

    _key := StrLowerW(PWideChar(key));
    _val := val;
end;

destructor TFilteringItem.Destroy;
begin
    inherited Destroy;
end;
{
    TFilteringSet implementation
}
constructor TFilteringSet.Create(
        enableHints: TWideStringList;
        disableHints: TWideStringList);
begin
    _itemcount := 0;

    _enableSet := TWidestringList.Create;
    _enableHints := TWidestringList.Create;
    if (enableHints <> nil) and (enableHints.Count > 0) then
        _enableHints.Assign(enableHints);

    _disableSet := TWidestringList.Create;
    _disableHints := TWidestringList.Create;
    if (disableHints <> nil) and (disableHints.Count > 0) then
        _disableHints.Assign(disableHints);
end;
constructor TFilteringSet.CreateFromList(filters: TWideStringList);
var
    idx, jdx, loc: Integer;
    filter: TFilteringSet;
    fromList, toList: TWidestringList;
    fitem: TFilteringItem;
begin
    _itemcount := 0;

    _enableHints := TWidestringList.Create;
    _enableSet := TWidestringList.Create;

    _disableHints := TWidestringList.Create;
    _disableSet := TWidestringList.Create;

    //update hints
    for idx := 0 to filters.Count - 1 do begin
        filter := TFilteringSet(filters.Objects[idx]);

        toList := Self._disableHints;
        fromList := filter._disableHints;
        for jdx := 0 to fromList.Count - 1 do begin
            if (toList.IndexOf(fromList[jdx]) = -1) then
                toList.Add(fromList[jdx]);
        end;

        toList := Self._enableHints;
        fromList := filter._enableHints;
        for jdx := 0 to fromList.Count - 1 do begin
            if (toList.IndexOf(fromList[jdx]) = -1) then
                toList.Add(fromList[jdx]);
        end;
    end;

    //update sets
    for idx := 0 to filters.Count - 1 do begin
        filter := TFilteringSet(filters.Objects[idx]);

        //Update disable sets (unions)
        toList := Self._disableSet;
        fromList := filter._disableSet;
        for jdx := fromList.Count - 1 downto 1 do begin
            if _disableHints.IndexOf(fromList[jdx]) = -1 then
                continue;

            loc := toList.IndexOf(fromList[idx]);
            if (loc <> -1) then begin
                if TFilteringItem(toList.Objects[loc]).Value = TFilteringItem(fromList.Objects[jdx]).Value then
                    continue;
            end;

            fitem := TFilteringItem(fromList.Objects[jdx]);
            if      (fitem <> FILTER_SELECTION_NONE) and
                    (fitem <> FILTER_SELECTION_SINGLE) and
                    (fitem <> FILTER_SELECTION_MULTI) then
                fitem := TFilteringItem.CreatePair(fitem.Key, fitem.Value);

            toList.AddObject(fromList[jdx], fitem);
        end;

        //Update enable sets (intersection)
        toList := Self._enableSet;
        fromList := filter._enableSet;
        for jdx := fromList.Count - 1 downto 0 do begin
            if _enableHints.IndexOf(fromList[jdx]) = -1 then
                continue;

            loc := toList.IndexOf(fromList[jdx]);
            if (loc <> -1) then begin
                fitem := TFilteringItem(fromList.Objects[jdx]);
                if TFilteringItem(toList.Objects[loc]).Value <> fitem.Value then begin
                    fitem.Free;
                    toList.Delete(loc);
                    loc := _enableHints.IndexOf(fromList[jdx]);
                    if (loc <> -1) then _enableHints.Delete(loc);
                end;
            end else begin
                fitem := TFilteringItem(fromList.Objects[jdx]);
                if      (fitem <> FILTER_SELECTION_NONE) and
                        (fitem <> FILTER_SELECTION_SINGLE) and
                        (fitem <> FILTER_SELECTION_MULTI) then
                    fitem := TFilteringItem.CreatePair(fitem.Key, fitem.Value);

                toList.AddObject(fromList[jdx], fitem);
            end;
        end;
    end;
end;
destructor TFilteringSet.Destroy;
var
    idx: Integer;
    fitem: TFilteringItem;
begin
    for idx := 0 to _enableHints.Count - 1 do begin
        _enableHints.Objects[idx] := nil;
    end;
    _enableHints.Free;

    for idx := 0 to _enableSet.Count - 1 do begin
        fitem := TFilteringItem(_enableSet.Objects[idx]);
        _enableSet.Objects[idx] := nil;

        if      (fitem <> FILTER_SELECTION_SINGLE) and
                (fitem <> FILTER_SELECTION_MULTI) and
                (fitem <> FILTER_SELECTION_NONE) then
            fitem.Free;
    end;
    _enableSet.Free;

    for idx := 0 to _disableHints.Count - 1 do begin
        _disableHints.Objects[idx] := nil;
    end;
    _disableHints.Free;
    for idx := 0 to _disableSet.Count - 1 do begin
        fitem := TFilteringItem(_disableSet.Objects[idx]);
        _disableSet.Objects[idx] := nil;

        if      (fitem <> FILTER_SELECTION_SINGLE) and
                (fitem <> FILTER_SELECTION_MULTI) and
                (fitem <> FILTER_SELECTION_NONE) then
            fitem.Free;
    end;
    _disableSet.Free;

    inherited Destroy;
end;

procedure TFilteringSet.update(item: IExodusItem);
var
    key, val: Widestring;
    idx, place: Integer;
    currItem, foundItem: TFilteringItem;

    function lookupKeyValue: Boolean;
    begin
        Result := true;

        if (key = 'selection') then
            Result := false     //ignore this hint (always present)
        else if (key = 'type') then
            val := item.Type_
        else if (key = 'active') then
            val := StrLowerW(PWideChar(BoolToStr(item.Active, true)))
        else if (key = 'visible') then
            val := StrLowerW(PWideChar(BoolToStr(item.Active, true)))
        else begin
            //TODO:  strip off "property." ?
            val := item.value[key];
        end;
    end;
begin
    Inc(_itemcount);

    //Update disabling (walk backwards, so we can remove things)
    for idx := _disableHints.Count - 1 downto 0 do begin
        key := _disableHints[idx];
        if not lookupKeyValue then continue;

        //don't care if it's already present...
        currItem := TFilteringItem.CreatePair(key, val);
        _disableSet.AddObject(key, currItem);
    end;

    //Update enabling
    for idx := _enableHints.Count - 1 downto 0 do begin
        key := _enableHints[idx];
        if not lookupKeyValue then continue;

        //now we care if it's already there...
        place := _enableSet.IndexOf(key);
        if place = -1 then //brand-new!
            _enableSet.AddObject(key, TFilteringItem.CreatePair(key, val))
        else begin
            foundItem := TFilteringItem(_enableSet.Objects[place]);
            if foundItem.Value <> val then begin
                //remove item and hint
                foundItem.Free;
                _enableSet.Delete(place);
                _enableHints.Delete(idx);
            end;
        end;
    end;
end;

{
    TPotentialActions implementation
}
constructor TPotentialActions.Create(itemtype: WideString);
begin
    inherited Create;

    _itemtype := Copy(itemtype, 1, Length(itemtype));
    _proxies := TWidestringList.Create;
    _enableHints := TWidestringList.Create;
    _disableHints := TWidestringList.Create;
end;
destructor TPotentialActions.Destroy;
begin
    _enableHints.Free;
    _disableHints.Free;
    _proxies.Free;

    inherited;
end;

function TPotentialActions.GetProxyCount;
begin
    Result := _proxies.Count;
end;
function TPotentialActions.GetProxyAt(idx: Integer): TActionProxy;
begin
    Result := TActionProxy(_proxies.Objects[idx]);
end;
function TPotentialActions.GetProxyNamed(actname: WideString): TActionProxy;
var
    idx: Integer;
begin
    idx := _proxies.IndexOf(actname);
    if (idx <> -1) then
        Result := TActionProxy(_proxies.Objects[idx])
    else
        Result := nil;
end;

procedure TPotentialActions.updateProxy(proxy: TActionProxy);
var
    idx: Integer;
    filter: TWidestringList;
    hint: Widestring;
begin
    //add if missing
    if (_proxies.IndexOf(proxy.Name) = -1) then
        _proxies.AddObject(proxy.Name, proxy);

    //update hints
    filter := proxy.EnablingFilter;
    for idx := 0 to filter.Count - 1 do begin
        hint := filter[idx];
        if (_enableHints.IndexOf(hint) = -1) then _enableHints.Add(hint);
    end;

    filter := proxy.DisablingFilter;
    for idx := 0 to filter.Count - 1 do begin
        hint := filter[idx];
        if (_disableHints.IndexOf(hint) = -1) then _disableHints.Add(hint);
    end;
end;

{
    TExodusActionController implementation
}
constructor TExodusActionController.Create;
begin
    inherited;

    _actions := TWidestringList.Create;
end;
destructor TExodusActionController.Destroy;
begin
    _actions.Clear;
    _actions.Free;

    inherited;
end;

function TExodusActionController.lookupActionsFor(
        itemtype: WideString;
        create: Boolean): TPotentialActions;
var
    idx: Integer;
begin
    idx := _actions.IndexOf(itemtype);
    if (idx <> -1) then
        Result := TPotentialActions(_actions.Objects[idx])
    else if not create then
        Result := nil
    else begin
        Result := TPotentialActions.Create(itemtype);
        _actions.AddObject(itemtype, Result);
    end;
end;

procedure TExodusActionController.registerAction(
        const itemtype: WideString;
        const act: IExodusAction);
var
    list: TPotentialActions;
    proxy: TActionProxy;
begin
    //graceful fail
    if (itemtype = '') then exit;
    if (act = nil) then exit;

    list := lookupActionsFor(itemtype, true);
    proxy := list.GetProxyNamed(act.name);
    if (proxy = nil) then proxy := TActionProxy.Create(itemtype, act.name);

    proxy.Action := act;
    list.updateProxy(proxy);
end;

procedure TExodusActionController.addEnableFilter(const ItemType, actname,
  filter: WideString);
var
    list: TPotentialActions;
    proxy: TActionProxy;
begin
    //graceful fail
    if (itemtype = '') then exit;
    if (actname = '') then exit;
    if (filter = '') then exit;
    
    //get appropriate potentials and proxy
    list := lookupActionsFor(itemtype, true);
    proxy := list.GetProxyNamed(actname);
    if (proxy = nil) then proxy := TActionProxy.Create(itemtype, actname);

    proxy.addToEnabling(filter);
    list.updateProxy(proxy);
end;
procedure TExodusActionController.addDisableFilter(const ItemType, actname,
  filter: WideString);
var
    list: TPotentialActions;
    proxy: TActionProxy;
begin
    //graceful fail
    if (itemtype = '') then exit;
    if (actname = '') then exit;
    if (filter = '') then exit;

    //get appropriate potentials and proxy
    list := lookupActionsFor(itemtype, true);
    proxy := list.GetProxyNamed(itemtype);
    if (proxy = nil) then proxy := TActionProxy.Create(itemtype, actname);

    proxy.addToDisabling(filter);
    list.updateProxy(proxy);
end;

function TExodusActionController.buildActions(
        const items: IExodusItemList): IExodusActionMap;
var
    actmap: TExodusActionMap;
    potentials: TPotentialActions;
    proxy: TActionProxy;
    applied: TObjectList;
    allInterests: TWidestringList;
    typedInterests, mainInterests: TFilteringSet;
    idx, jdx: Integer;
    item: IExodusItem;
    itemtype: Widestring;
begin
    actmap := TExodusActionMap.Create(items);
    Result := actmap as IExodusActionMap;

    //walk items, building sets
    allInterests := TWidestringList.Create;
    for idx := 0 to items.Count - 1 do begin
        item := items.Item[idx];

        potentials := lookupActionsFor(item.Type_, false);
        if (potentials <> nil) then begin
            jdx := allInterests.IndexOf(potentials.ItemType);
            if (jdx <> -1) then begin
                typedInterests := TFilteringSet(allInterests.Objects[jdx]);
            end else begin
                typedInterests := TFilteringSet.Create(potentials.EnableHints, potentials.DisableHints);
                allInterests.AddObject(potentials.ItemType, typedInterests);
            end;

            typedInterests.update(item);
        end;
    end;

    //walk types, building action map
    mainInterests := TFilteringSet.CreateFromList(allInterests);
    applied := TObjectList.Create();
    applied.OwnsObjects := false;
    for idx := 0 to allInterests.Count - 1 do begin
        itemtype := allInterests[idx];
        potentials := lookupActionsFor(itemtype, false);
        typedInterests := TFilteringSet(allInterests.Objects[idx]);

        case typedInterests.ItemCount of
            0: begin
                typedInterests.Disabling.AddObject('selection', FILTER_SELECTION_NONE);
                typedInterests.Enabling.AddObject('selection', FILTER_SELECTION_NONE);
            end;
            1: begin
                typedInterests.Disabling.AddObject('selection', FILTER_SELECTION_SINGLE);
                typedInterests.Enabling.AddObject('selection', FILTER_SELECTION_SINGLE);
            end;
            else begin
                typedInterests.Disabling.AddObject('selection', FILTER_SELECTION_MULTI);
                typedInterests.Enabling.AddObject('selection', FILTER_SELECTION_MULTI);
            end;
        end;

        //add applicable typed actions to actionmap
        for jdx := 0 to potentials.ProxyCount - 1 do begin
            proxy := potentials.Proxy[jdx];

            if proxy.applies(typedInterests.Enabling, typedInterests.Disabling) then begin
                if (applied.IndexOf(proxy) = -1) then
                    applied.Add(proxy);
                actmap.AddAction(itemtype, proxy.Action);
            end;
        end;

        //add applicable "anytype" actions to actionmap
        potentials := lookupActionsFor('', true);
        for jdx := 0 to potentials.ProxyCount - 1 do begin
            proxy := potentials.Proxy[jdx];

            if proxy.applies(typedInterests.Enabling, typedInterests.Disabling) then begin
                if (applied.IndexOf(proxy) = -1) then
                    applied.Add(proxy);
                actmap.AddAction(itemtype, proxy.Action);
            end;
        end;

        //Free up typed interests now
        allInterests.Objects[idx] := nil;
        typedInterests.Free;
    end;

    //Build main actions
    case items.Count of
        0: begin
            mainInterests.Disabling.AddObject('selection', FILTER_SELECTION_NONE);
            mainInterests.Enabling.AddObject('selection', FILTER_SELECTION_NONE);
        end;
        1: begin
            mainInterests.Disabling.AddObject('selection', FILTER_SELECTION_SINGLE);
            mainInterests.Enabling.AddObject('selection', FILTER_SELECTION_SINGLE);
        end;
        else begin
            mainInterests.Disabling.AddObject('selection', FILTER_SELECTION_MULTI);
            mainInterests.Enabling.AddObject('selection', FILTER_SELECTION_MULTI);
        end;
    end;

    for idx := 0 to applied.Count - 1 do begin
        proxy := TActionProxy(applied[idx]);
        applied[idx] := nil;

        if proxy.applies(mainInterests.Enabling, mainInterests.Disabling) then begin
            actmap.AddAction('', proxy.Action);
        end;
    end;

    //Cleanup
    actmap.Collate;
    FreeAndNil(allInterests);
    FreeAndNil(mainInterests);
    FreeAndNil(applied);
end;

function GetActionController: IExodusActionController;
begin
    if (g_ActCtrl = nil) then begin
        g_ActCtrl := TExodusActionController.Create;
        g_ActCtrl._AddRef;
    end;
    Result := g_actCtrl as IExodusActionController;
end;

initialization
    TAutoObjectFactory.Create(ComServer,
            TExodusActionController,
            CLASS_ExodusActionController,
            ciMultiInstance, tmApartment);
    FILTER_SELECTION_NONE := TFilteringItem.CreatePair('selection', 'none');
    FILTER_SELECTION_SINGLE := TFilteringItem.CreatePair('selection', 'single');
    FILTER_SELECTION_MULTI := TFilteringItem.CreatePair('selection', 'multi');
end.
