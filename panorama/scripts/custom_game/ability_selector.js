var m_AbilityNames = {}
var m_AbilityPanelID = null;

var passiveModeHasPassiveEffectActiveAbilities = [
	"drow_ranger_trueshot",
	"sniper_take_aim",
	"phantom_lancer_phantom_edge",
	"slark_shadow_dance",
	"phantom_assassin_blur",
	"skeleton_king_vampiric_aura",
	"chen_divine_favor",
	"obsidian_destroyer_equilibrium",
]

function ShowAbilitySelector(args) {
	Show();

	var parent = $("#ability_selector_image_panel");
	m_AbilityPanelID = args.ID
	
	// 判断是否所有的技能都全一样
	var allTheSame = true;
	for (var i in args.Abilities) {
		var abilityName = args.Abilities[i];
		if (m_AbilityNames[i] !== abilityName) {
			allTheSame = false;
			break;
		}
	}

	if (allTheSame) {
		return;
	}

	parent.RemoveAndDeleteChildren();
	
	var mapName = Game.GetMapInfo().map_display_name;
	
	for (var i in args.Abilities) {
		var abilityName = args.Abilities[i];

		var abilityData = GameUI.NpcAbilitiesKV[abilityName];
		var isPassive, isAutoCast = false
		

		m_AbilityNames[i] = abilityName;
		var abilityPanel = $.CreatePanel("Panel", parent, "Ability" + abilityName);
		abilityPanel.BLoadLayoutSnippet("AbilitySelectorAbility");


		if (abilityData != null) {
			var behavior = abilityData['AbilityBehavior'];
			if (behavior != null) {
				try {
					abilityPanel.SetHasClass('PassiveAbility', behavior.search('DOTA_ABILITY_BEHAVIOR_PASSIVE') >= 0);
					abilityPanel.SetHasClass('AutoCastAbility', behavior.search('DOTA_ABILITY_BEHAVIOR_AUTOCAST') >= 0);

					// 被动模式
					if (mapName.search("passive") >= 0) {
						abilityPanel.SetHasClass("PassiveMode", true);
						if (
							behavior.search('DOTA_ABILITY_BEHAVIOR_PASSIVE') >= 0 
							|| behavior.search('DOTA_ABILITY_BEHAVIOR_AUTOCAST') >= 0
							|| GameUI.PassiveEnabledAbilities.indexOf(abilityName) >= 0
							|| passiveModeHasPassiveEffectActiveAbilities.indexOf(abilityName) >= 0
						) {
							abilityPanel.SetHasClass("PassiveEnabled", true);
						}else{
							abilityPanel.SetHasClass("PassiveEnabled", false);
						}
					}
					
				}
				catch(err) {
				}
			}
		}

		abilityPanel.SetHasClass('CourierAbility', GameUI.CourierAbilities[abilityName] != null);
		abilityPanel.SetHasClass('BOMAbility', abilityName.includes('bom'));

		(function(panel, name) {

			panel.FindChildTraverse('ability_name').text = $.Localize("#DOTA_Tooltip_ability_" + abilityName);

			panel.FindChildTraverse("ability_image").abilityname = abilityName;
			panel.SetPanelEvent("onactivate", function(){
				GameEvents.SendCustomGameEventToServer("player_select_ability", {
					AbilityName: name,
					AbilityPanelID: m_AbilityPanelID,
					Type: args.Type
				});
				Hide();
			});
			panel.SetPanelEvent("onmouseover", function() {
				$.DispatchEvent("DOTAShowAbilityTooltip", panel, name);
			});
			panel.SetPanelEvent("onmouseout", function() {
				$.DispatchEvent("DOTAHideAbilityTooltip");
			})
		})(abilityPanel, abilityName);
	}
}

function CancelAbilitySelect() {
	Hide();
	GameEvents.SendCustomGameEventToServer("player_select_ability", {
		AbilityName: "Cancel",
		AbilityPanelID: m_AbilityPanelID,
	});
}

function Hide() {
	$("#ability_selector").AddClass("AbilitySelectorPanelHide");
}

function Show() {
	$("#ability_selector").RemoveClass("AbilitySelectorPanelHide");
}

(function() {
	Hide();
	GameEvents.Subscribe("show_ability_selector", ShowAbilitySelector);
})();