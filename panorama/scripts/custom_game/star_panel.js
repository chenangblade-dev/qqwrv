function print(s) {
    $.Msg(s);
}

var nCurrentStar = 0;
var nMaxStar = 0;
var StarStrengthBonus = 0;
var StarAgilityBonus = 0;
var StarIntellectBonus = 0;

var ism = "file://{resources}/images/custom_game/stars/star_empty.png";
var isf = "file://{resources}/images/custom_game/stars/star_full.png";

var isSpectator = false;

var starUpdated = false;

var m_ShopPanel;

function UpdateStar(data) {
    if (isSpectator) {
        return;
    }

    starUpdated = true;

    $.GetContextPanel().visible = true;
    $("#StarPanel").RemoveAndDeleteChildren();
    nCurrentStar = data.nCurrentStar;
    nMaxStar = data.nMaxStar;
    StarStrengthBonus = Math.floor(data.StarStrengthBonus * 1000) / 1000;
    StarAgilityBonus = Math.floor(data.StarAgilityBonus * 1000) / 1000;
    StarIntellectBonus = Math.floor(data.StarIntellectBonus * 1000) / 1000;
    for (var i = nCurrentStar - 1; i >= 0; i--) {
        var star = $.CreatePanel("Image", $("#StarPanel"), "star_empty_" + i);
        star.SetHasClass("Star", true);
        star.SetImage(isf);
    }
    for (var i = 0; i < nMaxStar - nCurrentStar; i++) {
        var star = $.CreatePanel("Image", $("#StarPanel"), "star_empty_" + i);
        star.SetHasClass("Star", true);
        star.SetImage(ism);
    }
    $("#StarTitle").SetDialogVariable("cur", nCurrentStar);
    $("#StarTitle").SetDialogVariable("max", nMaxStar);
    $("#StarStr").SetDialogVariable("value", StarStrengthBonus);
    $("#StarAgi").SetDialogVariable("value", StarAgilityBonus);
    $("#StarInt").SetDialogVariable("value", StarIntellectBonus);
}

function OnStarDataOrSelectedUnitChanged() {
    if (!isSpectator) {
        return;
    }

    if (Players.GetLocalPlayerPortraitUnit() == null || Players.GetLocalPlayerPortraitUnit() == undefined || Players.GetLocalPlayerPortraitUnit() == -1) {
        $.GetContextPanel().visible = false;
        return;
    }

    var starData = CustomNetTables.GetTableValue("star_data", "star_data");
    if (starData == undefined || starData == null || !typeof starData == "object") {
        return;
    }

    var data = starData[Players.GetLocalPlayerPortraitUnit()];
    if (!typeof data == "object") {
        return;
    }

    $.GetContextPanel().visible = true;
    $("#StarPanel").RemoveAndDeleteChildren();
    nCurrentStar = data.nCurrentStar;
    nMaxStar = data.nMaxStar;
    StarStrengthBonus = Math.floor(data.StarStrengthBonus * 1000) / 1000;
    StarAgilityBonus = Math.floor(data.StarAgilityBonus * 1000) / 1000;
    StarIntellectBonus = Math.floor(data.StarIntellectBonus * 1000) / 1000;
    for (var i = nCurrentStar - 1; i >= 0; i--) {
        var star = $.CreatePanel("Image", $("#StarPanel"), "star_empty_" + i);
        star.SetHasClass("Star", true);
        star.SetImage(isf);
    }
    for (var i = 0; i < nMaxStar - nCurrentStar; i++) {
        var star = $.CreatePanel("Image", $("#StarPanel"), "star_empty_" + i);
        star.SetHasClass("Star", true);
        star.SetImage(ism);
    }
    $("#StarTitle").SetDialogVariable("cur", nCurrentStar);
    $("#StarTitle").SetDialogVariable("max", nMaxStar);
    $("#StarStr").SetDialogVariable("value", StarStrengthBonus);
    $("#StarAgi").SetDialogVariable("value", StarAgilityBonus);
    $("#StarInt").SetDialogVariable("value", StarIntellectBonus);
}

function KeepAskingServerForStar() {
    if (starUpdated === true) return;
    GameEvents.SendCustomGameEventToServer("bom_ask_star", {});

    $.Schedule(1, KeepAskingServerForStar);
}

function ListenToshopOpenMessage() {
    $.Schedule(1 / 30, ListenToshopOpenMessage);
    if (m_ShopPanel == undefined) m_ShopPanel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("shop");
    if (m_ShopPanel == undefined) {
        return;
    }
    $.GetContextPanel().SetHasClass("ShopOpen", m_ShopPanel.BHasClass("ShopOpen"));
    $.GetContextPanel().SetHasClass("ShopLarge", m_ShopPanel.BHasClass("ShopLarge"));
}

function UpdateGoldCost(args) {
    $("#GoldCost").text = args.cost;
}

(function () {
    ListenToshopOpenMessage();
    var playerinfo = Game.GetPlayerInfo(Game.GetLocalPlayerID());
    if (playerinfo.player_team_id == 1) {
        // $.GetContextPanel().style.visibility = "collapse";
        $.GetContextPanel().visible = false;
        isSpectator = true;
        CustomNetTables.SubscribeNetTableListener("star_data", OnStarDataOrSelectedUnitChanged);
        GameEvents.Subscribe("dota_player_update_selected_unit", OnStarDataOrSelectedUnitChanged);
        GameEvents.Subscribe("dota_player_update_query_unit", OnStarDataOrSelectedUnitChanged);
    }
    $.GetContextPanel().visible = false; // 开局不显示UI
    GameEvents.Subscribe("update_player_star", UpdateStar);
    GameEvents.Subscribe("player_update_star_cost", UpdateGoldCost);

    // 显示被动模式
    var mapName = Game.GetMapInfo().map_display_name;
    if (mapName.search("passive") >= 0) {
        $("#GameInfo").text = $.Localize("#da_game_info_passive");
    }

    KeepAskingServerForStar();
})();

var random_star_icon = $("#random_star_icon");
var add_star_icon = $("#add_star_icon");

function OnRandomStar() {
    Game.PrepareUnitOrders({
        OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_PURCHASE_ITEM,
        UnitIndex: Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
        AbilityIndex: 1505,
        Queue: false,
        ShowEffects: true,
    });
    Game.EmitSound("General.Buy");
}

function ShowRandomStarTooltip() {
    $.DispatchEvent("DOTAShowAbilityTooltip", random_star_icon, "item_random_star");
}

function HideRandomStarTooltip() {
    $.DispatchEvent("DOTAHideAbilityTooltip", random_star_icon);
}

function OnAddStar() {
    Game.PrepareUnitOrders({
        OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_PURCHASE_ITEM,
        UnitIndex: Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
        AbilityIndex: 1504,
        Queue: false,
        ShowEffects: true,
    });
	Game.EmitSound('General.Buy');
}

function ShowAddStarTooltip() {
    $.DispatchEvent("DOTAShowAbilityTooltip", add_star_icon, "item_add_star");
}

function HideAddStarTooltip() {
    $.DispatchEvent("DOTAHideAbilityTooltip", add_star_icon);
}
