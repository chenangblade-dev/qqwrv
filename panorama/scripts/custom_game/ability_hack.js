function HideAbilities() {
    $.Schedule(0.03, HideAbilities);
    var abilities = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AbilitiesAndStatBranch");

    if (abilities === null || abilities.FindChildTraverse("Ability3") === null || abilities.FindChildTraverse("Ability4") == null || GameUI.vAttributeData == undefined) {
        return;
    }

    var m_QueryUnit = Players.GetLocalPlayerPortraitUnit();
    var unitName = Entities.GetUnitName(m_QueryUnit);

    if (GameUI.vAttributeData[unitName] != "DOTA_ATTRIBUTE_INTELLECT") {
        abilities.FindChildTraverse("Ability3").style.visibility = "collapse";
    } else {
        abilities.FindChildTraverse("Ability3").style.visibility = "visible";
    }

    if (Abilities.GetAbilityName(Entities.GetAbility(m_QueryUnit, 4)) == "empty_a5") {
        abilities.FindChildTraverse("Ability4").style.visibility = "collapse";
    } else {
        abilities.FindChildTraverse("Ability4").style.visibility = "visible";
    }
}

function AutoShowAbilityLevel() {
    $.Schedule(0.03, AutoShowAbilityLevel);

    var abilities = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AbilitiesAndStatBranch");
    if (abilities === null) {
        return;
    }

    var m_QueryUnit = Players.GetLocalPlayerPortraitUnit();
    for (var i = 6; i < 25; ++i) {
        var abilityIndex = Entities.GetAbility(m_QueryUnit, i);
        var ability = abilities.FindChildTraverse("Ability" + i);
        var abilityName = Abilities.GetAbilityName(abilityIndex);

        if (ability != null) {
            // 修正天赋移动导致会出现的BUG
            if (abilityName.includes("special_bonus_")) {
                ability.style.visibility = "collapse";
            } else {
                ability.style.visibility = "visible";
            }

            var levelPips = ability.FindChildTraverse("AbilityLevelContainer");
            levelPips.style.visibility = "collapse";

            var buttonAndLevel = ability.FindChildTraverse("ButtonAndLevel");
            var levelNumber = buttonAndLevel.FindChildTraverse("XAbilityLevelNumbers");
            if (levelNumber == null || levelNumber == undefined) {
                levelNumber = $.CreatePanel("Label", buttonAndLevel, "XAbilityLevelNumbers");
                levelNumber.style.verticalAlign = "bottom";
                levelNumber.style.horizontalAlign = "center";
                levelNumber.style.marginBottom = "10px";
                levelNumber.style.fontSize = "22px";
            }
            var clevel = Abilities.GetLevel(abilityIndex);
            if (Entities.GetTeamNumber(m_QueryUnit) !== Entities.GetTeamNumber(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()))) clevel = "?";
            var mlevel = Abilities.GetMaxLevel(abilityIndex);

            levelNumber.text = clevel + "/" + mlevel;
            if (
                abilityName == "empty_1" ||
                abilityName == "empty_2" ||
                abilityName == "empty_3" ||
                abilityName == "empty_4" ||
                abilityName == "empty_5" ||
                abilityName == "empty_6" ||
                abilityName == "empty_6_locked"
            ) {
                levelNumber.text = "";
            }
        }
    }
}

function EnterRemoveMode() {
    m_InRemoveMode = true;
    var abilities = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AbilitiesAndStatBranch");
    var m_LocalHero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    for (var i = 0; i < 12; i++) {
        var ability = abilities.FindChildTraverse("Ability" + i);
        if (ability != null) {
            var abilityButton = ability.FindChildTraverse("AbilityButton");
            var abilityName = Abilities.GetAbilityName(Entities.GetAbility(m_LocalHero, i));
            // if (abilityName == "empty_1" ||
            // 	abilityName == "empty_2" ||
            // 	abilityName == "empty_3" ||
            // 	abilityName == "empty_4" ||
            // 	abilityName == "empty_5" ||
            // 	abilityName == "empty_6" ||
            // 	abilityName == "empty_a1" ||
            // 	abilityName == "empty_a2" ||
            // 	abilityName == "empty_a3" ||
            // 	abilityName == "empty_a4" ||
            // 	abilityName == "empty_a5" ||
            // 	abilityName == "empty_a6"
            // 	) {
            // 	continue; // 空技能无法移除
            // }
            abilityButton.style.washColor = "#881212";
            abilityButton.SetPanelEvent(
                "oncontextmenu",
                (function (arg) {
                    return function () {
                        if (!m_InRemoveMode) return;
                        var abilityName = Abilities.GetAbilityName(Entities.GetAbility(m_LocalHero, arg));
                        if (GameUI.IsControlDown()) {
                            abilityName = "Canceled";
                        }
                        GameEvents.SendCustomGameEventToServer("player_confirm_ability_remove", {
                            AbilityName: abilityName,
                        });
                        EndRemoveMode();
                    };
                })(i)
            );
        }
    }
}

function EndRemoveMode() {
    m_InRemoveMode = false;
    var abilities = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AbilitiesAndStatBranch");
    for (var i = 0; i < 20; i++) {
        var ability = abilities.FindChildTraverse("Ability" + i);
        if (ability != null) {
            var abilityButton = ability.FindChildTraverse("AbilityButton");
            abilityButton.style.washColor = "#ffffff";
        }
    }
}

function UpdateBookCount(args) {
    var stats = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("stackable_side_panels");
    if (stats == null) {
        $.Schedule(1, UpdateBookCount);
        return;
    }

    var booksNormal = args.NormalBookCount || 0;
    var booksUltimate = args.UltimateBookCount || 0;

    var headerColumn = stats.FindChildTraverse("HeaderColumn");
    var currentStatColumn = stats.FindChildTraverse("CurrentStatColumn");
    if (headerColumn.FindChildTraverse("book_title") == null) {
        $.CreatePanel("Label", headerColumn, `book_title`, {
            class: `QuickStatLabel QuickStatLabelHeader`,
            text: `#book_stats_title`,
        });
    }
    var currentStats = currentStatColumn.FindChildTraverse("book_stats");
    if (currentStats == null) {
        let book_count_panel = $.CreatePanel("Panel", currentStatColumn, `book_stats`, {
            class: `QuickStatContainerMargin LeftRightFlow`,
        });
        $.CreatePanel(`Label`, book_count_panel, `books_normal`, { class: `QuickStatValue`, text: `0` });
        $.CreatePanel(`Label`, book_count_panel, ``, { class: `SlashLabel`, text: `/` });
        $.CreatePanel(`Label`, book_count_panel, `books_ultimate`, { class: `QuickStatValue`, text: `0` });
        currentStats = currentStatColumn.FindChildTraverse("book_stats");
    }
    currentStats.FindChildTraverse("books_normal").text = booksNormal;
    currentStats.FindChildTraverse("books_ultimate").text = booksUltimate;
}

(function () {
    HideAbilities();
    AutoShowAbilityLevel();

    UpdateBookCount({});

    GameEvents.Subscribe("player_remove_ability", EnterRemoveMode);
    GameEvents.Subscribe("player_confirm_ability_remove", EndRemoveMode);
    GameEvents.Subscribe("player_update_book_count", UpdateBookCount);
})();
