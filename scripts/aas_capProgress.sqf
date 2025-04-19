/* =====================================================================
   AAS Capture‑Progress Controller (v7 – explicit prereqs)
===================================================================== */

// 0. INITIALISE progress + owners
private _prog = createHashMap;
{
    private _sec = _x;
    private _trg = missionNamespace getVariable [_sec, objNull];
    if (isNull _trg) exitWith {};

    private _owner = civilian;
    private _val   = 0;
    switch (_sec) do {
        case "s1": { _owner = WEST;  _val =  100; };  // French Airfield start BLU
        case "s6": { _owner = EAST;  _val = -100; };  // BHQ start OPF
        default  { };                                // others start neutral
    };

    _trg setVariable ["owner", _owner, true];
    _prog set [_sec, _val];
} forEach AAS_Sectors;

// publish initial state
AAS_CapProg = _prog; publicVariable "AAS_CapProg";


// 1. MAIN LOOP – runs once per second
while { true } do {
    {
        private _sec     = _x;
        private _trg     = missionNamespace getVariable [_sec, objNull];
        if (isNull _trg) exitWith {};

        // count units inside this sector trigger
        private _bfCount = { side _x == WEST && alive _x && (_x inArea _trg) } count allUnits;
        private _rfCount = { side _x == EAST && alive _x && (_x inArea _trg) } count allUnits;

        private _oldProg = _prog get _sec;
        private _delta   = 0;

        // Bluefor leading?
        if (_bfCount > _rfCount) then {
            switch (_sec) do {
                case "s1": { _delta = 5; };
                case "s2": {
                    // can only cap s2 once s1 is held by BLUFOR
                    if ((missionNamespace getVariable ["s1", objNull]) getVariable ["owner", civilian] isEqualTo WEST) then {
                        _delta = 5;
                    };
                };
                case "s3": {
                    if ((missionNamespace getVariable ["s2", objNull]) getVariable ["owner", civilian] isEqualTo WEST) then {
                        _delta = 5;
                    };
                };
                case "s4": {
                    if ((missionNamespace getVariable ["s3", objNull]) getVariable ["owner", civilian] isEqualTo WEST) then {
                        _delta = 5;
                    };
                };
                case "s5": {
                    if ((missionNamespace getVariable ["s3", objNull]) getVariable ["owner", civilian] isEqualTo WEST) then {
                        _delta = 5;
                    };
                };
                case "s6": {
                    // needs BOTH s4 and s5 held by BLUFOR
                    private _o4 = (missionNamespace getVariable ["s4", objNull]) getVariable ["owner", civilian];
                    private _o5 = (missionNamespace getVariable ["s5", objNull]) getVariable ["owner", civilian];
                    if ((_o4 isEqualTo WEST) && (_o5 isEqualTo WEST)) then {
                        _delta = 5;
                    };
                };
                default {};
            };
        } else {
            // Redfor leading?
            if (_rfCount > _bfCount) then {
                switch (_sec) do {
                    case "s6": { _delta = -5; };
                    case "s5": {
                        if ((missionNamespace getVariable ["s6", objNull]) getVariable ["owner", civilian] isEqualTo EAST) then {
                            _delta = -5;
                        };
                    };
                    case "s4": {
                        if ((missionNamespace getVariable ["s6", objNull]) getVariable ["owner", civilian] isEqualTo EAST) then {
                            _delta = -5;
                        };
                    };
                    case "s3": {
                        private _o4 = (missionNamespace getVariable ["s4", objNull]) getVariable ["owner", civilian];
                        private _o5 = (missionNamespace getVariable ["s5", objNull]) getVariable ["owner", civilian];
                        if ((_o4 isEqualTo EAST) && (_o5 isEqualTo EAST)) then {
                            _delta = -5;
                        };
                    };
                    case "s2": {
                        if ((missionNamespace getVariable ["s3", objNull]) getVariable ["owner", civilian] isEqualTo EAST) then {
                            _delta = -5;
                        };
                    };
                    case "s1": {
                        if ((missionNamespace getVariable ["s2", objNull]) getVariable ["owner", civilian] isEqualTo EAST) then {
                            _delta = -5;
                        };
                    };
                    default {};
                };
            } else {
                // no one leading → drift *only if* not fully capped
                if (abs _oldProg < 100) then {
                    if (_oldProg > 0) then { _delta = -1; };
                    if (_oldProg < 0) then { _delta =  1; };
                };
            };
        };

        // apply and clamp to ±100
        private _newProg = _oldProg + _delta;
        if (_newProg >  100) then { _newProg =  100; };
        if (_newProg < -100) then { _newProg = -100; };
        _prog set [_sec, _newProg];

        // flip owner at thresholds
        if (_newProg ==  100) then { _trg setVariable ["owner", WEST, true]; };
        if (_newProg == -100) then { _trg setVariable ["owner", EAST, true]; };
    } forEach AAS_Sectors;

    // broadcast updated progress
    AAS_CapProg = _prog;
    publicVariable "AAS_CapProg";

    sleep 1;
};
