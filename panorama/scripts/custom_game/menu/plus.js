var m_IsVIP = false;

function OpenPlus() {
    $("#page_plus").ToggleClass("Hidden");
    $("#menu_hit_listener").RemoveClass("MenuHidden");
}

function ClosePurchasePlus() {
    $("#page_plus").AddClass("Hidden");
}

function OnPurchase(days) {
    GameEvents.SendCustomGameEventToServer("purchase_plus", {
        days: days,
    });
}

function OnPlusDataArrived() {
    var _data = CustomNetTables.GetAllTableValues("econ_data");
    if (_data == null) return;
    $("#QueryingOverlay").style.visibility = "collapse";

    var id = Players.GetLocalPlayer();
    var data = CustomNetTables.GetTableValue("econ_data", "plus_data_" + id);
    if (data == null) {
        return;
    }

    var year = data.year;
    var month = data.month;
    var day = data.day;

    $("#plus_data").SetDialogVariableInt("year", year);
    $("#plus_data").SetDialogVariableInt("month", month);
    $("#plus_data").SetDialogVariableInt("day", day);

    GameUI.IsVIP = false;

    if (data.is_vip == 1) {
        $.GetContextPanel().AddClass("IsVIP");
        $.GetContextPanel().GetParent().GetParent().GetParent().AddClass("IsVIP");
        GameUI.IsVIP = true;
        m_IsVIP = true;
    }
}

function OnPurchaseResultArrived(keys) {
    $("#purchase_result").text = $.Localize("#plus_message_" + keys.message);
    GameEvents.SendCustomGameEventToServer("bom_player_ask_point_history", {});

    if (keys.message == "not_enough_points") {
        GameUI.OpenPayment();
    }
}

var m_AbilityPoolHero = {};

var m_Attributes = ["DOTA_ATTRIBUTE_STRENGTH", "DOTA_ATTRIBUTE_AGILITY", "DOTA_ATTRIBUTE_INTELLECT", "DOTA_ATTRIBUTE_ALL"];

function OnAbilityPoolArrived() {
    var ability_pool = CustomNetTables.GetTableValue("econ_data", "ability_pool");
    if (ability_pool == null) return;
    var abilityPoolPanel = $("#AbilityPool");

    if (GameUI.AbilityPoolData == ability_pool) {
        return;
    }

    GameUI.AbilityPoolData = ability_pool;

    $("#HeroPool_DOTA_ATTRIBUTE_STRENGTH").RemoveAndDeleteChildren();
    $("#HeroPool_DOTA_ATTRIBUTE_AGILITY").RemoveAndDeleteChildren();
    $("#HeroPool_DOTA_ATTRIBUTE_INTELLECT").RemoveAndDeleteChildren();
    $("#HeroPool_DOTA_ATTRIBUTE_ALL").RemoveAndDeleteChildren();
    $("#AbilityPool_DOTA_ATTRIBUTE_STRENGTH").RemoveAndDeleteChildren();
    $("#AbilityPool_DOTA_ATTRIBUTE_AGILITY").RemoveAndDeleteChildren();
    $("#AbilityPool_DOTA_ATTRIBUTE_INTELLECT").RemoveAndDeleteChildren();
    $("#AbilityPool_DOTA_ATTRIBUTE_ALL").RemoveAndDeleteChildren();

    Object.values(ability_pool).forEach((ability_data) => {
        let hero = ability_data.hero;
        let abilities = ability_data.abilities;
        let attribute = GameUI.vAttributeData[hero];
        if (Object.values(abilities) == null || attribute == null) return;

        let ability_parent = $("#AbilityPool_" + attribute);
        let hero_parent = $("#HeroPool_" + attribute);

        let ability_panel = $.CreatePanel("Panel", ability_parent, "");
        ability_panel.BLoadLayoutSnippet("AbilityPoolHero");
        ability_panel.FindChildTraverse("hero_avatar").heroname = hero;
        ability_panel.FindChildTraverse("pool_hero_name").text = $.Localize(`#${hero}`);

        let heroPanel = $.CreatePanel("DOTAHeroImage", hero_parent, "");
        heroPanel.heroname = hero;
        heroPanel.AddClass("HeroPoolHeroAvatar");

        Object.values(abilities).forEach((ability, i) => {
            var ability_icon = ability_panel.FindChildTraverse("ability_" + (i + 1));
            if (ability_icon != null) {
                ability_icon.abilityname = ability;
                ability_icon.SetHasClass("CourierAbility", GameUI.CourierAbilities[ability] != null);
                ability_icon.SetHasClass("BOMAbility", ability.indexOf("bom") > 0);
                ability_icon.SetPanelEvent("onmouseover", () => $.DispatchEvent("DOTAShowAbilityTooltip", ability_icon, ability));
                ability_icon.SetPanelEvent("onmouseout", () => $.DispatchEvent("DOTAHideAbilityTooltip"));
            }
        });
    });
}

function UpdatePlusPointsRemaining() {
    $("#points_remaining").text = $.Localize("#points_remaining") + GameUI.m_PointsLeft;
}

function ToggleAbilityPool() {
    if (m_IsVIP) {
        if ($("#page_ability_pool").BHasClass("Hidden")) {
            $("#page_ability_pool").ToggleClass("Hidden");
            $("#menu_hit_listener").RemoveClass("MenuHidden");
        } else {
            $("#page_ability_pool").ToggleClass("Hidden");
        }
    } else {
        if ($("#page_plus").BHasClass("Hidden")) {
            OpenPlus();
        } else {
            $("#page_plus").AddClass("Hidden");
        }
    }
}

(function () {
    OnPlusDataArrived();
    OnAbilityPoolArrived();
    GameUI.ToggleAbilityPool = ToggleAbilityPool;
    GameUI.UpdatePlusPointsRemaining = UpdatePlusPointsRemaining;
    CustomNetTables.GetTableValue("econ_data", OnPlusDataArrived);
    CustomNetTables.GetTableValue("econ_data", OnAbilityPoolArrived);
    GameEvents.Subscribe("ability_pool_update", OnAbilityPoolArrived);
    GameEvents.Subscribe("plus_purchase_result", OnPurchaseResultArrived);
    GameEvents.Subscribe("plus_data_updated", OnPlusDataArrived);

    GameUI.OpenPlus = OpenPlus;
})();
