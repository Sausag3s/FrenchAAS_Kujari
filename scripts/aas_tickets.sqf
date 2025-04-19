/*  Tickets:  minus 1 for each BLUFOR player death + bleed per flag
------------------------------------------------------------------ */

AAS_Tickets = AAS_TicketStart;
publicVariable "AAS_Tickets";

/* Count player deaths */
addMissionEventHandler ["EntityKilled", {
  params ["_dead"];
  if (isPlayer _dead && side _dead == WEST) then
  {
    AAS_Tickets = AAS_Tickets - 1 max 0;
    publicVariable "AAS_Tickets";
    if (AAS_Tickets <= 0) then { endMission "END1" };
  };
}];

/* Bleed once per 60s */
[] spawn {
  while { true } do
  {
    sleep 60;
    private _enemyFlags = { side _x == EAST } count allUnits;   // crude but OK
    AAS_Tickets = (AAS_Tickets - (_enemyFlags * AAS_BleedPerFlag)) max 0;
    publicVariable "AAS_Tickets";
    if (AAS_Tickets == 0) exitWith { endMission "END1" };
  };
};
