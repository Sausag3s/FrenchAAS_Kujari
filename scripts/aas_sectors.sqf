/*  aas_sectors.sqf
    – sets up sector ownership, prereqs, and first spawn point
-------------------------------------------------------------- */

private _idx = 0;                              // manual counter
{
    private _trg = missionNamespace getVariable [_x, objNull];
    if (isNull _trg) exitWith
    { diag_log format ["AAS ERROR: trigger %1 not found", _x]; };

    /* store its order number for later use if you want */
    _trg setVariable ["AAS_index", _idx];

    /* ---------- initial ownership ---------- */
    switch (_x) do
    {
        case "s1": { _trg setTriggerActivation ["WEST","PRESENT",false]; };
        case "s6": { _trg setTriggerActivation ["EAST","PRESENT",false]; };
        default   { _trg setTriggerActivation ["ANY","PRESENT",true];   };
    };

    /* ---------- first spawn at French airfield ---------- */
    if (_x isEqualTo "s1") then
    {
        private _spawnID = [WEST, getPos _trg, "Airfield"]
                           call BIS_fnc_addRespawnPosition;
        AAS_BlueSpawns   = [[_spawnID, _trg]];
    };

    /* ---------- sector‑captured handler ---------- */
    _trg setTriggerStatements
    [
        // condition – someone’s in the zone *and* prereqs are done
        "this && {[_thisTrigger] call fnc_prereqsMet}",
        // on activation – broadcast that it flipped
        "
           [_thisTrigger] spawn {
               publicVariableServer 'AAS_SectorsOwned';
           };
        ",
        ""                                           // on deact (unused)
    ];

    _idx = _idx + 1;                                // bump counter
} forEach AAS_Sectors;


/* ---------- helper: do we meet prereqs? ---------- */
fnc_prereqsMet = {
    params ["_trg"];
    private _name = triggerText _trg;

    private _row = AAS_Prereq select { _x#0 isEqualTo _name };
    if (_row isEqualTo []) exitWith { true };        // no prereqs

    private _needed = _row#0#1;                      // array of names
    {
        private _t = missionNamespace getVariable [_x, objNull];
        if (isNull _t) exitWith { false };
        if ((_t getVariable ["activated",false]) isEqualTo false) exitWith { false };
    } forEach _needed;

    true                                             // all satisfied
};
