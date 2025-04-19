/*
    scripts/aas_HUDcap.sqf
    Client‑side: show flag‑capture HUD when inside a sector trigger
*/

// — wait for the custom RscTitle to be created in uiNamespace — 
waitUntil {
    private _d = uiNamespace getVariable ["FlagCaptureHUD", displayNull];
    !isNull _d
};

// grab the display
private _disp = uiNamespace getVariable ["FlagCaptureHUD", displayNull];

// main loop: check every 0.1 s
while { true } do {

    // find the first sector the player is inside
    private _inside = AAS_Sectors select {
        private _trg = missionNamespace getVariable [_x, objNull];
        !isNull _trg && (player inArea _trg)
    };

    if ((count _inside) > 0) then {
        private _sec  = _inside select 0;
        private _name = AAS_SectorNames getOrDefault [_sec, _sec];
        private _prog = AAS_CapProg      getOrDefault [_sec, 0];    // –100…100

        // choose color: blue if prog>0, red if prog<0, white if zero
        private _clr = if (_prog > 0) then {[0,0.5,1,1]}
                      else { if (_prog < 0) then {[1,0,0,1]} else {[1,1,1,1]} };

        // compute fill fraction of the 30% width
        private _frac = abs _prog / 100;

        // update capture name text
        private _ctrlText = _disp displayCtrl 1500;
        _ctrlText ctrlSetText       _name;
        _ctrlText ctrlSetTextColor  _clr;
        _ctrlText ctrlShow          true;

        // ensure background bar is shown
        private _ctrlBG = _disp displayCtrl 1501;
        _ctrlBG ctrlShow true;

        // calculate fill‑bar position & size
        private _bgPos = ctrlPosition _ctrlBG;        // [x,y,w,h]
        private _x    = _bgPos select 0;
        private _y    = _bgPos select 1;
        private _w    = (_bgPos select 2) * _frac;
        private _h    = _bgPos select 3;

        // update fill bar
        private _ctrlFG = _disp displayCtrl 1502;
        _ctrlFG ctrlSetPosition     [_x, _y, _w, _h];
        _ctrlFG ctrlSetBackgroundColor _clr;
        _ctrlFG ctrlShow            true;
    }
    else {
        // hide when not in any sector
        (_disp displayCtrl 1500) ctrlSetText "";
        (_disp displayCtrl 1502) ctrlShow false;
    };

    sleep 0.1;
};
