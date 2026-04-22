var m_HeroName = {};
var b_InitialTalentShown = false;
function Hide() {
    $("#hero_selector_panel").AddClass("HeroSelectorPanelHide");
}

function Show() {
    $("#hero_selector_panel").RemoveClass("HeroSelectorPanelHide");
}

function Cancel() {
    GameEvents.SendCustomGameEventToServer("player_cancel_hero_reselect", {});
    Hide();
}

function ReRandom() {
    if (GameUI.IsVIP == true) {
        GameEvents.SendCustomGameEventToServer("player_rerandom_hero", {});
        $("#vip_reselect_button").style.visibility = "collapse";
    } else {
        if (GameUI.OpenPlus != null) {
            GameUI.OpenPlus();
        }
    }
}

function OnSelect(index) {
    GameEvents.SendCustomGameEventToServer("player_reselect_hero", {
        HeroName: m_HeroName[index],
    });
    Hide();
}

function ShowHeroSelectionScreen(heroNames) {
    Show();

    var allTheSame = true;
    for (var i in heroNames) {
        if (m_HeroName[i] != heroNames[i]) {
            allTheSame = false;
            break;
        }
    }

    if (allTheSame) {
        return;
    }

    for (var i in heroNames) {
        m_HeroName[i] = heroNames[i];
        let hero_portrait_container = $("#hero_portrait_container_" + i);
        hero_portrait_container.RemoveAndDeleteChildren();
        $.CreatePanel("DOTAScenePanel", hero_portrait_container, `hero_portrait${i}`, {
            light: "global_light",
            unit: `${heroNames[i]}`,
            antialias: true,
            class: `HeroPortrait`,
            renderdeferred: false,
            particleonly: false,
        });
        $("#hero_name_" + i).text = $.Localize("#" + heroNames[i]);

        (function (heroPanel, index, name) {
            heroPanel.SetPanelEvent("onmouseover", function () {
                $.DispatchEvent("UIShowCustomLayoutParametersTooltip", heroPanel, "stat_branch_tooltip", "file://{resources}/layout/custom_game/tooltips/stat_branch.xml", "heroName=" + name);
            });
            heroPanel.SetPanelEvent("onmouseout", function () {
                $.DispatchEvent("UIHideCustomLayoutTooltip", heroPanel, "stat_branch_tooltip");
            });
        })($("#hero_portrait_container_" + i), i, heroNames[i]);
    }
}

function OnPlayerRandomHero() {
    var randomHero = CustomNetTables.GetTableValue("player_data", "player_random_hero_selection_" + Players.GetLocalPlayer());
    if (randomHero == undefined) return;
    if (randomHero["selected"] == true) return;
    // $("#hero_image_1").SetPanelEvent('onmouseover', function(){})
    // $("#hero_image_2").SetPanelEvent('onmouseover', function(){})
    // $("#hero_image_3").SetPanelEvent('onmouseover', function(){})

    ShowHeroSelectionScreen(randomHero);
}
(function () {
    OnPlayerRandomHero();
    GameEvents.Subscribe("player_random_hero_selection", ShowHeroSelectionScreen);
    CustomNetTables.GetTableValue("player_data", OnPlayerRandomHero);
})();
