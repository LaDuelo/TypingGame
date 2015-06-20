
function makeUnit(unitId){
    GameEvents.SendCustomGameEventToServer ("make_unit_click", {
        playerId: Game.GetLocalPlayerID(),
        unit: unitId
    });
}
