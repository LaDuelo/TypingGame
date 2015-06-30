var unitHud = {};


unitHud.data = {};


unitHud.data.units = [];


unitHud.init = function () {
    unitHud.tooltip.init();
    unitHud.units.init();
    unitHud.goldDisplay.init();
    unitHud.incomeDisplay.init();

    GameEvents.SendCustomGameEventToServer("request_unit_data", {"player": Game.GetLocalPlayerID()});
    GameEvents.Subscribe("transmit_unit_data", unitHud.units.setUnitData);
};


/**
 * Tooltip stuff
 */
unitHud.tooltip = {};


/**
 *
 */
unitHud.tooltip.init = function () {
    unitHud.tooltip.hide();
};


/**
 * Shows the tooltip with the data of unit
 * @param unit
 */
unitHud.tooltip.show = function (unit) {
    $('#tooltip-title').text = unit.title;
    $('#tooltip-text').text = unit.description;
    $('#tooltip-gold').text = "cost: " + unit.price + "g"   ;
    $('#tooltip').visible = true;
};


/**
 * Hides the tooltip
 */
unitHud.tooltip.hide = function () {
    $('#tooltip').visible = false;
};


/**
 *
 */
unitHud.goldDisplay = {};


/**
 *
 */
unitHud.goldDisplay.init = function () {
    unitHud.goldDisplay.loop();
};


/**
 * Loop that show the gold
 */
unitHud.goldDisplay.loop = function () {
    $('#gold').text = Players.GetGold(Game.GetLocalPlayerID()) + "g";

    $.Schedule(0.1, unitHud.goldDisplay.loop);
};

unitHud.incomeDisplay = {};
unitHud.incomeDisplay.init = function (){
    GameEvents.Subscribe("income_updated", unitHud.incomeDisplay.callback);
};

unitHud.incomeDisplay.callback = function (data){
    unitHud.incomeDisplay.draw(data);
};

unitHud.incomeDisplay.draw = function(players){
    var incomeList = $('#income-list');

    incomeList
        .Children()
        .forEach(
            function(child){
                child.DeleteAsync(0);
            }
        );

    Object.keys(players).forEach(function(key){
        key = parseInt(key, 10);
        if(!Players.IsValidPlayer(key)){
            return;
        }
        var player = $.CreatePanel('Label', incomeList, '');
        var playerColor = Players.GetPlayerColor(key);
        $.Msg((function(){var a = {}; a[playerColor] = true;}()));
        player.AddClass('player');
        player.style.color =
            "#" +
            playerColor
                .toString(16)
                .match( /.{1,2}/g)
                .reverse()
                .join('')
                .slice(0,6);
        player.text = Players.GetPlayerName(key) + ": " + Math.floor(players[key]);
    });

};


/**
 *
 */
unitHud.units = {};


unitHud.units.perRowCount = 8;


/**
 *
 */
unitHud.units.init = function () {
    var unitsContainer = $('#units');
    var lastRow = null;
    var counter = 0;

    unitHud.units.destroy();

    unitHud.data.units.forEach(function (unit) {
        counter++;

        // create new row if necessary
        if (lastRow === null || !(counter % unitHud.units.perRowCount)) {
            lastRow = $.CreatePanel('Panel', unitsContainer, '');
            lastRow.AddClass('row');

            counter = 1;
        }

        // create button
        var unitBox = $.CreatePanel('Button', lastRow, '');
        unitBox.AddClass('box');

        // set events
        unitBox.SetPanelEvent('onactivate', function () {
            unitHud.units.onUnitClick(unit.id);
        });
        unitBox.SetPanelEvent('onmouseover', function () {
            unitHud.tooltip.show(unit);
        });
        unitBox.SetPanelEvent('onmouseout', function () {
            unitHud.tooltip.hide();
        });

        // add image
        var image = $.CreatePanel('Image', unitBox, '');
        image.SetImage(unit.image);

    });
};


unitHud.units.setUnitData = function (data) {
    data = Object.keys(data).map(function (key) {
        return data[key];
    });

    unitHud.data.units = data;
    unitHud.units.init();
};


unitHud.units.destroy = function () {
    var unitsContainer = $('#units');
    unitsContainer
        .Children()
        .forEach(function (child) {
            child.Delete();
        });
};

unitHud.units.onUnitClick = function (unitId) {
    GameEvents.SendCustomGameEventToServer("make_unit_click", {
        playerId: Game.GetLocalPlayerID(),
        unit: unitId
    });
};


unitHud.init();