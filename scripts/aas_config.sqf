/* --- SECTORS ----------------------------------------------------------- */
// Trigger names from Eden, in capture order *for BLUFOR*:
AAS_Sectors = ["s1","s2","s3","s4","s5","s6"];

/* --- PREREQUISITES ---------------------------------------------------- */
// Bluefor capture order
AAS_PrereqBlue = [
  ["s2", ["s1"]],
  ["s3", ["s2"]],
  ["s4", ["s3"]],
  ["s5", ["s3"]],
  ["s6", ["s4","s5"]]
];

// Redfor capture order (reverse of Bluefor)
AAS_PrereqRed = [
  ["s4", ["s6"]],
  ["s5", ["s6"]],
  ["s3", ["s4","s5"]],
  ["s2", ["s3"]],
  ["s1", ["s2"]]
];

/* --- TICKETS ---------------------------------------------------------- */
AAS_TicketStart    = 300;     // French start tickets (BLUFOR)
AAS_BleedPerFlag   = 1;       // tickets lost per enemy‑held sector per minute

/* --- RESPAWN WAVES ---------------------------------------------------- */
AAS_WaveInterval   = 60;      // seconds between mass respawns

/* --- SPAWN BLOCK ------------------------------------------------------ */
AAS_SpawnSafeDist  = 150;     // disable spawn if enemy < this (m)

 /* --- ROLES / KITS ---------------------------------------------------- */
AAS_RoleLimits = [
  // role, max per *squad size bracket* (1‑3, 4‑6, 7‑8+)
  ["sl",      [1,1,1]],
  ["medic",   [0,1,2]],
  ["ar",      [0,1,1]],
  ["lat",     [0,1,1]],
  ["marks",   [0,0,1]],
  ["engi",    [0,0,1]],
  ["rifle",   [8,6,4]]      // filler slots
];

/* ================================================================
   Human‑readable names for each sector
   The key MUST match the trigger’s Var Name (s1 … s6)
=================================================================*/
AAS_SectorNames = createHashMapFromArray
[
  ["s1", "French Airfield"],
  ["s2", "Sheikh Market"],
  ["s3", "Central Village"],
  ["s4", "River Bridge"],
  ["s5", "City"],
  ["s6", "Boko Haram HQ"]
];
