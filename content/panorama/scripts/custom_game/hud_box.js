/**
 * callback of the input submit
 */
function OnSubmitted(){
    var input = $('#MyEntry');

    var text = input.text;

    // What follows is a hack because passing a string does not seem to work - so we pass the string as a object key
    var obj = {};
    obj[text] = true;

    GameEvents.SendCustomGameEventToServer ("input_submit", {
        playerId: Game.GetLocalPlayerID(),
        text: obj
    });
}