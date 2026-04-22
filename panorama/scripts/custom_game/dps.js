function FindOrCreatePlayerPanel(playerId) {
	var parent = $.GetContextPanel();
	var childCount = parent.GetChildCount();

	for (var i = 0; i < childCount; ++i) {
		var panel = parent.GetChild(i);
		if (panel.GetAttributeInt('playerid', -1) == playerId) {
			return panel;
		}
	}

	// 如果没有 创建之
	var panel = $.CreatePanel('Panel', parent, "");
	panel.SetAttributeInt('playerid', playerId);

	panel.BLoadLayoutSnippet('DPSPlayer');
	var heroName = Players.GetPlayerSelectedHero(playerId);
	panel.FindChildTraverse('player_hero').heroname = heroName;
	panel.FindChildTraverse('hero_name').text = $.Localize("#" + heroName)

	var playerInfo = Game.GetPlayerInfo(playerId);
	var steamid = playerInfo.player_steamid;
	panel.FindChildTraverse('player_avatar').steamid = steamid;
	panel.FindChildTraverse('player_name').steamid = steamid;

	var team = Players.GetTeam(playerId);
	var color = GameUI.CustomUIConfig().team_colors[ team ];
	if (color == null) color = "#ae4545;";
	var teamColor = color.replace( ";", "" );
	panel.FindChildTraverse('dps_bar').style.backgroundColor = "gradient( linear, 0% 0%, 100% 0%, from( #22222244 ), color-stop( 0.7, " + teamColor + "44 ), to( " + teamColor + "44 ) );";
	return panel;
}

function UpdateDPSPanel(){
	$.Schedule(1, UpdateDPSPanel);
	var dpsData = CustomNetTables.GetTableValue("player_data", "dps_data");
	if (dpsData == null) {
		return;
	};

	var parent = $.GetContextPanel();
	parent.RemoveClass("Hidden");
	var lastPlayerPanel = null;
	var highestDps = null;
	for (var i in dpsData) {
		var data = dpsData[i];
		var dps = data.d;
		var playerId = data.p;
		var firstPlayer = false;
		var panel = FindOrCreatePlayerPanel(playerId);
		if (lastPlayerPanel == null) {
			highestDps = dps;
			firstPlayer = true;
		}else{
			parent.MoveChildAfter(panel, lastPlayerPanel);
		}

		dps = Math.floor(dps);
		if (highestDps == 0) continue;
		var percentage = Math.floor(dps * 100 / highestDps);
		if (dps > 1000000) {
			dps = Math.floor(dps / 1000) + " K"
		}

		panel.FindChildTraverse('dps_value').text = dps + " " + percentage + "%";
		if (firstPlayer) panel.FindChildTraverse('dps_value').text = dps + " 100%";
		panel.FindChildTraverse("dps_bar").style.width = 320 * percentage / 100 + "px;";
		lastPlayerPanel = panel;
	}
}

var m_Stash;
function ListenToshopOpenMessage() {
	$.Schedule(1/30, ListenToshopOpenMessage);
	if (m_Stash == undefined) m_Stash = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse('stash');
	if (m_Stash == undefined) {
		return;
	}
	$.GetContextPanel().SetHasClass('ShopOpen', m_Stash.BHasClass('ShopOpen'));
}

(function() {
	ListenToshopOpenMessage();
	UpdateDPSPanel();
})();