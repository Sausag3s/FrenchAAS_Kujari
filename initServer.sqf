// initServer.sqf

// load constants and hashes
call compile preprocessFileLineNumbers "scripts\aas_config.sqf";

// server‑side AAS loops and spawn registration
[] execVM "scripts\aas_sectors.sqf";
[] execVM "scripts\aas_tickets.sqf";
[] execVM "scripts\aas_spawnPoints.sqf";
[] execVM "scripts\aas_capProgress.sqf";
[] execVM "scripts\aas_flagSpawns.sqf";
