/* =========================================================================
   Sector Map UI with Next‑Objective Halo (v16 + explicit prereqs)
   • Draws halo + flag + progress bar for each sector
   • Halo only on the one next Bluefor can attack (owner≠WEST + prereqs met)
   • Halo disappears once owner==WEST
========================================================================= */

//////////////////////////////////////////////////
// 0. WAIT FOR AAS DATA (captures + names map) //
//////////////////////////////////////////////////

waitUntil {
    !isNil "AAS_CapProg" && !isNil "AAS_SectorNames"
};

////////////////////////
// 1. SAFE LOOKUP HELPER
////////////////////////

private _safe = {
    params ["_c"];
    if (isClass (configFile >> "CfgMarkers" >> _c)) exitWith { _c };
    "mil_flag"
};

//////////////////////////////////////////////////////
// 2. PRE‑PASS: CREATE HALOS, FLAGS, AND PROGRESS BARS
//////////////////////////////////////////////////////

{
    private _sec   = _x;                                 // e.g. "s1"
    private _trg   = missionNamespace getVariable [_sec, objNull];
    if (isNull _trg) exitWith {};

    private _pos   = getPos _trg;
    private _prog  = AAS_CapProg getOrDefault [_sec, 0];
    private _owner = _trg getVariable ["owner", civilian];

    // 2a) Halo (invisible at start)
    private _halo = createMarkerLocal [format ["m_%1_halo", _sec], _pos];
    _halo setMarkerShapeLocal   "ELLIPSE";
    _halo setMarkerSizeLocal    [75, 75];     // adjust radius as needed
    _halo setMarkerColorLocal   "ColorYellow";
    _halo setMarkerAlphaLocal   0;
    _trg setVariable ["ui_halo", _halo];

    // 2b) Flag icon + text
    private _disp = AAS_SectorNames getOrDefault [_sec, _sec];
    private _icon = "white";
    if (abs _prog == 100) then {
        if (_owner isEqualTo WEST) then { _icon = "flag_france" };
        if (_owner isEqualTo EAST) then { _icon = "lop_flag_isis" };
    };
    private _type = [_icon] call _safe;
    private _flag = createMarkerLocal [format ["m_%1_flag", _sec], _pos];
    _flag setMarkerShapeLocal  "ICON";
    _flag setMarkerTypeLocal   _type;
    _flag setMarkerSizeLocal   [0.7, 0.7];
    _flag setMarkerTextLocal   _disp;
    _trg setVariable ["ui_flag", _flag];

    // 2c) Bar background
    private _bgPos = [_pos select 0, (_pos select 1) + 30];
    private _bg    = createMarkerLocal [format ["m_%1_bg", _sec], _bgPos];
    _bg setMarkerShapeLocal    "RECTANGLE";
    _bg setMarkerSizeLocal     [20, 1];
    _bg setMarkerColorLocal    "ColorGrey";
    _bg setMarkerAlphaLocal    0.7;

    // 2d) Bar fill
    private _fill = createMarkerLocal [format ["m_%1_fill", _sec], _bgPos];
    _fill setMarkerShapeLocal  "RECTANGLE";
    _fill setMarkerSizeLocal   [0.1, 1];
    _fill setMarkerColorLocal  "ColorBlue";
    _trg setVariable ["ui_fill", _fill];

} forEach AAS_Sectors;

///////////////////////////////////////////////////////
// 3. UPDATE LOOP: EVERY SECOND, REFRESH ICONS + HALO
///////////////////////////////////////////////////////

while { true } do {
    {
        private _sec   = _x;
        private _trg   = missionNamespace getVariable [_sec, objNull];
        if (isNull _trg) exitWith {};

        private _halo  = _trg getVariable ["ui_halo", displayNull];
        private _flag  = _trg getVariable ["ui_flag", ""];
        private _fill  = _trg getVariable ["ui_fill", ""];

        private _prog   = AAS_CapProg getOrDefault [_sec, 0];
        private _owner  = _trg getVariable ["owner", civilian];

        // 3a) Update flag icon
        private _icon = "white";
        if (abs _prog == 100) then {
            if (_owner isEqualTo WEST) then { _icon = "flag_france" };
            if (_owner isEqualTo EAST) then { _icon = "lop_flag_isis" };
        };
        _flag setMarkerTypeLocal ([_icon] call _safe);

        // 3b) Update progress bar
        private _width = (abs _prog) * 0.20;  // maps 100→20 m
        _fill setMarkerSizeLocal [_width max 0.1, 1];
        if (_prog >= 0) then {
            _fill setMarkerColorLocal "ColorBlue";
        } else {
            _fill setMarkerColorLocal "ColorRed";
        };

        // 3c) Determine if this is the next Bluefor target
        private _canDo = false;
        switch (_sec) do {
            case "s2": {
                if ((missionNamespace getVariable ["s1", objNull]) getVariable ["owner", civilian] isEqualTo WEST) then {
                    _canDo = true;
                };
            };
            case "s3": {
                if ((missionNamespace getVariable ["s2", objNull]) getVariable ["owner", civilian] isEqualTo WEST) then {
                    _canDo = true;
                };
            };
            case "s4": {
                if ((missionNamespace getVariable ["s3", objNull]) getVariable ["owner", civilian] isEqualTo WEST) then {
                    _canDo = true;
                };
            };
            case "s5": {
                if ((missionNamespace getVariable ["s3", objNull]) getVariable ["owner", civilian] isEqualTo WEST) then {
                    _canDo = true;
                };
            };
            case "s6": {
                private _o4 = (missionNamespace getVariable ["s4", objNull]) getVariable ["owner", civilian];
                private _o5 = (missionNamespace getVariable ["s5", objNull]) getVariable ["owner", civilian];
                if ((_o4 isEqualTo WEST) && (_o5 isEqualTo WEST)) then {
                    _canDo = true;
                };
            };
            default {};
        };

        // Show halo only if:
        //  • we do NOT already own it (owner != WEST)
        //  • AND _canDo == true
        if ((_owner != WEST) && _canDo) then {
            _halo setMarkerAlphaLocal 0.50;
        } else {
            _halo setMarkerAlphaLocal 0;
        };

    } forEach AAS_Sectors;

    uiSleep 1;
};
