function setupTooltip() {
    var heroName = $.GetContextPanel().GetAttributeString("heroName", "");
    for (var i = 1; i< 9; i++) {
        if (GameUI.vTalentData[heroName] == undefined) continue;
        
        var talentName = GameUI.vTalentData[heroName][i];

        var value = GameUI.vTalentValueData[talentName];
        $("#branch_name_" + i).text = $.Localize("#DOTA_Tooltip_ability_" + talentName, $("#branch_name_" + i));
        if (value != null) {
        	for (var k in value) {
                var key = k == `value` ? `value` : `bonus_${k}`;
	        	$("#branch_name_" + i).SetDialogVariable(key, value[k]);
        	}
        }
    }
}

function AutoUpdateTooltip() {
    setupTooltip();
    $.Schedule(0.5, AutoUpdateTooltip);
}

(function() {
    AutoUpdateTooltip();
})();