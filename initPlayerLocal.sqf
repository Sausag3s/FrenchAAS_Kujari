/* initPlayerLocal.sqf */

// don’t run on headless clients
if (!hasInterface) exitWith {};

// 1) load the config (must match server!)
call compile preprocessFileLineNumbers "scripts\aas_config.sqf";

// 2) Tickets HUD (you already have this)
[] spawn {
    waitUntil { !isNil "AAS_Tickets" };
    while { true } do {
        hintSilent format ["Tickets: %1", AAS_Tickets];
        uiSleep 5;
    };
};

// 3) Map markers (flags + progress bars)
[] execVM "scripts\aas_sectorUI.sqf";

// 4) Corner capture‑HUD (“Now capping…”)  
[] execVM "scripts\aas_HUDcap.sqf";
