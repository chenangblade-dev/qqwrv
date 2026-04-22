"use strict";

var rating = 0;

//--------------------------------------------------------------------------------------------------
// Handeler for when the unssigned players panel is clicked that causes the player to be reassigned
// to the unssigned players team
//--------------------------------------------------------------------------------------------------
function OnLeaveTeamPressed() {
    Game.PlayerJoinTeam(5); // 5 == unassigned ( DOTA_TEAM_NOTEAM )
}

function p(s) {
    $.Msg(s);
}
//--------------------------------------------------------------------------------------------------
// Update the contents of the player panel when the player information has been modified.
//--------------------------------------------------------------------------------------------------
function OnPlayerDetailsChanged() {
    var playerId = $.GetContextPanel().GetAttributeInt("player_id", -1);
    var playerInfo = Game.GetPlayerInfo(playerId);
    if (!playerInfo) return;

    $("#PlayerName").text = playerInfo.player_name;
    $("#PlayerAvatar").steamid = playerInfo.player_steamid;
    $.GetContextPanel().SetHasClass("player_is_local", playerInfo.player_is_local);
    $.GetContextPanel().SetHasClass("player_has_host_privileges", playerInfo.player_has_host_privileges);

    if (Game.GetMapInfo().map_display_name == "arena_5v5") return;

    try {
        var steamid32 = playerInfo.player_steamid.substring(4);
        steamid32 = parseInt(steamid32) - 1197960265728;
        var rating_data = CustomNetTables.GetTableValue("player_rating_data", "rating_data");
        if (rating_data != null) {
            for (var index in rating_data) {
                if (rating_data[index].steamid == steamid32) {
                    if (rating_data[index].match_count > 10) {
                        $("#EloLabel").text = rating_data[index].rating;
                    } else {
                        $("#EloLabel").text = $.Localize("#need10game");
                    }
                    $("#MatchCountLabel").text = parseInt(rating_data[index].match_count);
                    $("#Top1Label").text = parseInt(rating_data[index].top1);
                    $("#Top3Label").text = parseInt(rating_data[index].top3);
                    $("#DCLabel").text = parseInt(rating_data[index].dct);
                    var kda = (parseInt(rating_data[index].k) + parseInt(rating_data[index].a)) / (parseInt(rating_data[index].d) + 1);
                    $("#AverageKDALabel").text = kda.toString().substring(0, 4);
                }
            }
        } else {
            if (Game.GetState() == 2) {
                $.Schedule(0.3, OnPlayerDetailsChanged);
            }
        }

        var stastics_data = CustomNetTables.GetTableValue("player_rating_data", "stastics_data");
        if (stastics_data != null) {
            for (var index in rating_data) {
                if (stastics_data[index].steamid == steamid32) {
                }
            }
        } else {
            if (Game.GetState() == 2) {
                $.Schedule(0.3, OnPlayerDetailsChanged);
            }
        }
    } catch (error) {
        $.Msg(error);
    }
}

//--------------------------------------------------------------------------------------------------
// Entry point, update a player panel on creation and register for callbacks when the player details
// are changed.
//--------------------------------------------------------------------------------------------------
(function () {
    OnPlayerDetailsChanged();
    $.RegisterForUnhandledEvent("DOTAGame_PlayerDetailsChanged", OnPlayerDetailsChanged);
    CustomNetTables.SubscribeNetTableListener("player_rating_data", OnPlayerDetailsChanged);
    GameEvents.Subscribe("player_rating_data_arrived", OnPlayerDetailsChanged);
    GameEvents.Subscribe("player_stastics_data_arrived", OnPlayerDetailsChanged);
})();

function ShowRatingTooltip() {
    $.DispatchEvent("DOTAShowTextTooltip", "#rating_tooltip_" + rating);
}

function HideRatingTooltip() {
    $.DispatchEvent("DOTAHideTextTooltip");
}
