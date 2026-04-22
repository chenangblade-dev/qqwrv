function OpenRank(){
	$("#page_rank").ToggleClass("Hidden");
	$("#menu_hit_listener").RemoveClass("MenuHidden");
}

function refreshTop50Panel(gamemode, top50) {
	var parent = $("#world_rank_players_" + gamemode);
	parent.RemoveAndDeleteChildren();
	for (var index in top50){
		var player = top50[index];
		var rating = player.rating;
		var steamid = player.steamid;
		var m_PlayerPanel = $.CreatePanel("Panel", parent, "");
		m_PlayerPanel.BLoadLayoutSnippet("LadderPlayer");
        var steamid64 = '765' + (parseInt(steamid) + 61197960265728).toString();
		m_PlayerPanel.FindChildTraverse("player_avatar").steamid = steamid64;
        m_PlayerPanel.FindChildTraverse("player_user_name").steamid = steamid64;
        m_PlayerPanel.FindChildTraverse("rank_text").text = rating;
        m_PlayerPanel.FindChildTraverse("rank_index").text = index;
        if (index === "1") m_PlayerPanel.AddClass('Top1');
	}
}

function RebuildRank(){
	var top50 = CustomNetTables.GetTableValue("top_50", "top_50");
	if (top50 === undefined) return;
	var mapName = Game.GetMapInfo().map_display_name;
	if (mapName.search("passive") >= 0) {
		refreshTop50Panel('1x10', top50['passive_1x10'])	
		refreshTop50Panel('2x6', top50['passive_2x6'])	
		refreshTop50Panel('3x4', top50['passive_3x4'])	
		$("#map_name_1x10").text = $.Localize('#passive_1x10');
		$("#map_name_2x6").text = $.Localize('#passive_2x6');
		$("#map_name_3x4").text = $.Localize('#passive_3x4');
	}else{
		refreshTop50Panel('1x10', top50['arena_1x10'])	
		refreshTop50Panel('2x6', top50['arena_2x6'])	
		refreshTop50Panel('3x4', top50['arena_3x4'])	
	}
}

(function(){
	RebuildRank();
	var now = new Date();
	var currentSeason = $("#current_season");
	currentSeason.SetDialogVariableInt("year", now.getFullYear());
	currentSeason.SetDialogVariableInt("month",now.getMonth() + 1);

	CustomNetTables.SubscribeNetTableListener("top_50", RebuildRank);
})();

