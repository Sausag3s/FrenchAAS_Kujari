/*  Adds a respawn position when BLUFOR captures a sector.
    Periodically scans for enemies nearby and toggles enable/disable.   */

AAS_BlueSpawns = [];   // holds [spawnID, triggerName]

["MPRespawn", {
  params ["_unit"];
  [_unit] call fnc_updateSpawnList;
}] call CBA_fnc_addEventHandler;


fnc_updateSpawnList = {
  {
    _id = _x#0; _trg = _x#1;
    private _pos = getPos _trg;
    private _enemyNear = {side _x == EAST && alive _x && _x distance _pos < AAS_SpawnSafeDist} count allUnits > 0;
    if (_enemyNear) then {
      _id call BIS_fnc_removeRespawnPosition;
    } else {
      [WEST, _pos, format["%1 Spawn", triggerText _trg], _id] call BIS_fnc_addRespawnPosition;
    };
  } forEach AAS_BlueSpawns;
};
