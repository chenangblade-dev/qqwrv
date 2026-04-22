function VoteForFreeMode() {
    GameEvents.SendCustomGameEventToServer("player_vote_for_free_mode", {});
}

function AgreeToShuffle() {
    GameEvents.SendCustomGameEventToServer("player_agree_to_shuffle", {});
}

function VoteFor(option) {
    GameEvents.SendCustomGameEventToServer("player_vote", { option: option });
}

function OnFreeModeChanged() {
    var freeModePlayers = CustomNetTables.GetTableValue("game_state", "agree_to_free_mode_players");
    if (freeModePlayers == null) return;

    if (Object.keys(freeModePlayers).length >= 6) {
        $("#free_model_panel").AddClass("FreeModeActivated");
    } else {
        $("#free_model_panel").RemoveClass("FreeModeActivated");
    }

    var parent = $("#vote_free_mode");
    var childCount = parent.GetChildCount();
    for (var j = 0; j < childCount; ++j) {
        var avatar = parent.GetChild(j);
        avatar.RemoveClass("Active");
        avatar.steamid = null;
    }

    for (var i in freeModePlayers) {
        var playerId = freeModePlayers[i];
        var playerInfo = Game.GetPlayerInfo(playerId);
        var steamid = playerInfo.player_steamid;
        var parent = $("#vote_free_mode");
        var childCount = parent.GetChildCount();

        for (var j = 0; j < childCount; ++j) {
            var avatar = parent.GetChild(j);
            if (!avatar.BHasClass("Active")) {
                avatar.steamid = steamid;
                avatar.AddClass("Active");
                avatar.enabled = false;
                break;
            }
        }
    }
}

function OnAgreeToShuffleChanged() {
    var agreeToShufflePlayers = CustomNetTables.GetTableValue("game_state", "agree_to_shuffle_players");
    if (agreeToShufflePlayers == null) return;

    for (var i in agreeToShufflePlayers) {
        var playerId = agreeToShufflePlayers[i];
        var playerInfo = Game.GetPlayerInfo(playerId);
        var steamid = playerInfo.player_steamid;

        var parent = $("#vote_agree_to_shuffle");
        var childCount = parent.GetChildCount();
        var hasSelected = false;
        for (var j = 0; j < childCount; ++j) {
            var avatar = parent.GetChild(j);
            if (avatar.steamid == steamid && avatar.BHasClass("Active")) {
                hasSelected = true;
                break;
            }
        }

        if (!hasSelected) {
            for (var j = 0; j < childCount; ++j) {
                var avatar = parent.GetChild(j);
                if (!avatar.BHasClass("Active")) {
                    avatar.steamid = steamid;
                    avatar.AddClass("Active");
                    avatar.enabled = false;
                    break;
                }
            }
        }
    }
    if (Object.keys(agreeToShufflePlayers).length >= 6) {
        $.GetContextPanel().AddClass("AgreeToShuffle");
        $("#UnassignedPlayersButton").enabled = true;
    }
}

function OnVoteChanged() {
    var voteState = CustomNetTables.GetTableValue("game_state", "vote_state");
    try {
        for (var option in voteState) {
            var votePlayers = voteState[option] ?? {};
            for (var index in votePlayers) {
                var playerId = votePlayers[index];
                var playerInfo = Game.GetPlayerInfo(playerId);
                var steamid = playerInfo.player_steamid;

                // 遍历所有选项，寻找玩家头像
                for (var i = 1; i < 4; ++i) {
                    var parent = $("#vote_players_" + i);
                    var childCount = parent.GetChildCount();

                    if (i == option) {
                        var hasSelected = false;
                        for (var j = 0; j < childCount; ++j) {
                            var avatar = parent.GetChild(j);
                            if (avatar.steamid == steamid && avatar.BHasClass("Active")) {
                                hasSelected = true;
                                break;
                            }
                        }
                        if (!hasSelected) {
                            for (var j = 0; j < childCount; ++j) {
                                var avatar = parent.GetChild(j);
                                if (!avatar.BHasClass("Active")) {
                                    avatar.steamid = steamid;
                                    avatar.AddClass("Active");
                                    avatar.enabled = false;
                                    break;
                                }
                            }
                        }
                    } else {
                        for (var j = 0; j < childCount; ++j) {
                            var avatar = parent.GetChild(j);
                            if (avatar.steamid == steamid) {
                                avatar.RemoveClass("Active");
                                avatar.steamid = null;
                            }
                        }
                    }
                }
            }
        }
    } catch (error) {
        $.Msg(error);
    }
}

function SetupVoteOptions() {
    var options = CustomNetTables.GetTableValue("game_state", "vote_options");
    if (options == null) return;
    for (var i = 1; i < 4; ++i) {
        $("#vote_options_" + i).text = options["option" + i];
    }
}

function OnAddBot() {
    GameEvents.SendCustomGameEventToServer("player_add_bot", {});
}

function ToggleShowAddBot() {
    // var mapName = Game.GetMapInfo().map_display_name;
    // if (mapName.search("passive") >= 0) {
    // 	$("#AddBotButton").style.visibility = "visible";
    // }else{
    // 	$("#AddBotButton").style.visibility = "collapse";
    // }
}

(function () {
    ToggleShowAddBot();
    SetupVoteOptions();
    CustomNetTables.SubscribeNetTableListener("game_state", SetupVoteOptions);
    CustomNetTables.SubscribeNetTableListener("game_state", OnVoteChanged);
    CustomNetTables.SubscribeNetTableListener("game_state", OnAgreeToShuffleChanged);
    CustomNetTables.SubscribeNetTableListener("game_state", OnFreeModeChanged);

    var date = new Date();
    var weekday = date.getDay();
    if (weekday == 6 || weekday == 0) {
        $("#free_model_panel").enabled = true;
    } else {
        $("#free_model_panel").enabled = false;
        $("#bom_free_mode").text = $.Localize("#free_mode_disabled");
    }

    $("#UnassignedPlayersButton").enabled = false;
})();
