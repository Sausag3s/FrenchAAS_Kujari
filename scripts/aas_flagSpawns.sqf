/* ---------------------------------------------------------------------------
      AAS  dynamic respawn positions            (v3 – stable & bullet‑proof)
      -----------------------------------------------------------------------
      · BLUFOR owns sector          →  spawn added   **if safe**
      · Enemy nearby (<150 m)       →  spawn removed
      · BLUFOR loses sector         →  spawn removed
      · Airfield flag (s1) is ignored; its BASE respawn stays untouched
--------------------------------------------------------------------------- */

#define AIRFIELD_FLAG "s1"    // never managed here
#define SAFE_DIST     150     // metres
#define CYCLE_TIME    3       // seconds between checks

/* ---- Cache static data so we don’t touch editor objects every cycle ---- */
private _sectors = [];                 // [[name, trg, posATL], ...]
{
    private _trg = missionNamespace getVariable [_x, objNull];
    if (isNull _trg) exitWith
    { diag_log text format ["flagSpawns: trigger %1 missing",_x]; };

    /* getPosATL returns surface coord; ensure Z = 0 */
    private _p = getPosATL _trg;
    _p set [2,0];

    _sectors pushBack [_x, _trg, _p];
} forEach AAS_Sectors;

/* HashMap sectorName → current spawnID */
private _spawnMap = createHashMap;

/* ----------------------------------------------------------------------- */
while { true } do
{
    {
        _x params ["_name","_trg","_pos"];
        private _owner = _trg getVariable ["owner",civilian];

        /* ----------------  If BLUFOR owns flag  ------------------------ */
        if (_owner isEqualTo WEST && { _name != AIRFIELD_FLAG }) then
        {
            /* -- enemy proximity check -- */
            private _enemyNear = false;
            {
                if (side _x == EAST && alive _x &&
                    (_x distanceSqr _pos) < (SAFE_DIST*SAFE_DIST)) exitWith
                { _enemyNear = true };
            } forEach allUnits;

            /* -- safe?  ensure spawn exists ;  unsafe? remove it -- */
            if (!_enemyNear) then
            {
                if !(_name in _spawnMap) then
                {
                    private _disp = AAS_SectorNames getOrDefault [_name,_name];
                    private _id   = [WEST, _pos, _disp] call BIS_fnc_addRespawnPosition;
                    _spawnMap set [_name, _id];
                };
            }
            else    /* enemy too close */
            {
                if (_name in _spawnMap) then
                {
                    (_spawnMap get _name) call BIS_fnc_removeRespawnPosition;
                    _spawnMap deleteAt _name;
                };
            };
        }

        /* ----------------  Flag not BLUFOR  ---------------------------- */
        else
        {
            if (_name in _spawnMap) then
            {
                (_spawnMap get _name) call BIS_fnc_removeRespawnPosition;
                _spawnMap deleteAt _name;
            };
        };
    }
    forEach _sectors;

    sleep CYCLE_TIME;
};
