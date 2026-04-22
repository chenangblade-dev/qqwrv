function OnItemWillSpawn( msg )
{
	$.GetContextPanel().SetHasClass( "item_will_spawn", true );
	$.GetContextPanel().SetHasClass( "item_has_spawned", false );
	// GameUI.PingMinimapAtLocation( msg.spawn_location );
	for (var i in msg) {
		GameUI.PingMinimapAtLocation( msg[i] );
	}
	$( "#AlertMessage_Chest" ).html = true;
	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Chest" ).text = $.Localize( "#Chest" );
	$( "#AlertMessage_Delivery" ).text = $.Localize( "#ItemWillSpawn" );

	$.Schedule( 3, ClearItemSpawnMessage );
}

function OnItemHasSpawned( msg )
{
//	$.Msg( "OnItemHasSpawned: ", msg );
	$.GetContextPanel().SetHasClass( "item_will_spawn", false );
	$.GetContextPanel().SetHasClass( "item_has_spawned", true );
	$( "#AlertMessage_Chest" ).html = true;
	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Chest" ).text = $.Localize( "#Chest" );
	$( "#AlertMessage_Delivery" ).text = $.Localize( "#ItemHasSpawned" );
				
	$.Schedule( 3, ClearItemSpawnMessage );
}
		
function ClearItemSpawnMessage()
{
	$.GetContextPanel().SetHasClass( "item_will_spawn", false );
	$.GetContextPanel().SetHasClass( "item_has_spawned", false );
	$( "#AlertMessage" ).text = "";
}

//==============================================================
//==============================================================
function OnItemDrop( msg )
{
//	$.Msg( "recent_item_drop: ", msg );
//	$.Msg( msg.hero_id )
	$.GetContextPanel().SetHasClass( "recent_item_drop", true );
	
	$( "#PickupMessage_Hero_Text" ).SetDialogVariable( "hero_id", $.Localize( "#"+msg.hero_id ) );

	$( "#PickupMessage_Item_Text" ).SetDialogVariable( "item_id", $.Localize( "#DOTA_Tooltip_Ability_"+msg.dropped_item ) );

	var hero_image_name = "file://{images}/heroes/" + msg.hero_id + ".png";
	$( "#PickupMessage_Hero" ).SetImage( hero_image_name );

	var chest_image_name = "file://{images}/econ/tools/gift_lockless_luckbox.png";
	$( "#PickupMessage_Chest" ).SetImage( chest_image_name );
			
	var item_image_name = "file://{images}/items/" + msg.dropped_item.replace( "item_", "" ) + ".png"
	$( "#PickupMessage_Item" ).SetImage( item_image_name );

	$.Schedule( 5, ClearDropMessage );
}
		
function ClearDropMessage()
{
	$.GetContextPanel().SetHasClass( "recent_item_drop", false );
}

function ShowLeaderPickMessage() {
	$.GetContextPanel().SetHasClass( "time_notification", true );
	$.GetContextPanel().SetHasClass( "time_countdown", true );
	$( "#AlertTimer_Text" ).text = $.Localize("#leader_got_nothing");
	$.Schedule(2, function() {
		$.GetContextPanel().SetHasClass( "time_notification", false );
		$.GetContextPanel().SetHasClass( "time_countdown", false );
	})

}

function OnRescaleAlert(data) {
	if (data.time_remaining == 60){
		$.GetContextPanel().SetHasClass( "time_countdown", false );
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$( "#AlertTimer_Text" ).text = $.Localize("#rescale_alert_60");
		Game.EmitSound("Tutorial.TaskProgress");
		$.Schedule(5, function() {
			$.GetContextPanel().SetHasClass( "time_notification", false );
		})
	}
	if (data.time_remaining == 30){
		$.GetContextPanel().SetHasClass( "time_countdown", false );
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$( "#AlertTimer_Text" ).text = $.Localize("#rescale_alert_30");
		Game.EmitSound("Tutorial.TaskProgress");
		$.Schedule(5, function() {
			$.GetContextPanel().SetHasClass( "time_notification", false );
		})
	}
	if (data.time_remaining <= 10) {
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$.GetContextPanel().SetHasClass( "time_countdown", true );
		$( "#AlertTimer_Text" ).text = data.time_remaining;
		Game.EmitSound("Tutorial.TaskProgress");
	}
	if (data.time_remaining == 0) {
		$( "#AlertTimer_Text" ).text = "";
	}
}

function AlertTimer( data )
{
	var remainingText = "";
	
	if ( ( data.timer_minute_01 == 2 ) && ( data.timer_second_10 == 0 ) && ( data.timer_second_01 == 0 ) )
	{
		remainingText = "2 MINUTES";
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
	if ( ( data.timer_minute_01 == 1 ) && ( data.timer_second_10 == 0 ) && ( data.timer_second_01 == 0 ) )
	{
		remainingText = "60 SECONDS";
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
	if ( ( data.timer_second_10 == 5 ) && ( data.timer_second_01 == 5 ) )
	{
		$.GetContextPanel().SetHasClass( "time_notification", false );
	}
	if ( ( data.timer_minute_01 == 0 ) && ( data.timer_second_10 == 3 ) && ( data.timer_second_01 == 0 ) )
	{
		remainingText = "30 SECONDS";
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
	if ( ( data.timer_minute_01 == 0 ) && ( data.timer_second_10 == 2 ) && ( data.timer_second_01 == 5 ) )
	{
		$.GetContextPanel().SetHasClass( "time_notification", false );
	}
	if ( ( data.timer_minute_01 == 0 ) && ( data.timer_second_10 == 1 ) && ( data.timer_second_01 == 0 ) )
	{
		remainingText = "10";
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$.GetContextPanel().SetHasClass( "time_countdown", true );
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
	if ( ( data.timer_minute_01 == 0 ) && ( data.timer_second_10 == 0 ) && ( data.timer_second_01 <= 9 ) )
	{
		remainingText += data.timer_second_01;
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
}

//==============================================================
//==============================================================
function OnOvertimeStart( data )
{
//	$.Msg( "Overtime Goal: ", data );
	var new_score_to_win = data.killcount;
	var overtimeText = "";
	overtimeText += new_score_to_win
	$.GetContextPanel().SetHasClass( "overtime_visible", true );
	$( "#Overtime_Goal" ).text = overtimeText;
}

//==============================================================
//==============================================================
function OnLeaderKilled( msg )
{
//	$.Msg( "leader_has_been_killed: ", msg );

	$.GetContextPanel().SetHasClass( "leader_has_been_killed", true );
	$( "#KillMessage_Hero" ).SetDialogVariable( "hero_id", $.Localize( "#"+msg.hero_id ) );
	$.Schedule( 5, ClearKillMessage );
}
		
function ClearKillMessage()
{
	$.GetContextPanel().SetHasClass( "leader_has_been_killed", false );
}

var mPredictCircle, mCurrentCircle;

function OnMinimapRescalePredict(data) {
	var minimap = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("minimap_block");
	var width = minimap.style.width;
	var height = minimap.style.height;
	var maxx = 16352;
	var maxy = 16532;
	var x = data.x;
	var y = data.y;
	var radius = data.radius;
	mPredictCircle = $.CreatePanel("Panel", minimap, "");
	var width = radius * 100 / 8176 * 260 / 100;
	var top = (8176 - y - radius) / 16352 * 260 - 11 + "px";
	var left = (8176 + x - radius) / 16352 * 260 - 11 + "px";
	mPredictCircle.hittest = false;
	mPredictCircle.style.width = width + "px";
	mPredictCircle.style.height = width + "px";
	mPredictCircle.style.marginTop = top;
	mPredictCircle.style.marginLeft = left;

	mPredictCircle.style.border = "5px solid green";
	mPredictCircle.style.borderRadius = "50% 50%";
}

function OnMinimapRescale(data) {
	if (mCurrentCircle !== undefined) {
		mCurrentCircle.DeleteAsync(0);
	}
	mCurrentCircle = mPredictCircle;
	mCurrentCircle.style.border = "4px solid white";
}

function ShowFightingArea() {
	var rescaleData = CustomNetTables.GetTableValue('game_state', 'minimap_rescale_data');
	if (rescaleData == null) return;

	$.Msg(rescaleData);

	OnMinimapRescalePredict(rescaleData);
	OnMinimapRescale(rescaleData);
}

(function () {
	GameEvents.Subscribe( "item_will_spawn", OnItemWillSpawn );
	GameEvents.Subscribe( "item_has_spawned", OnItemHasSpawned );
	GameEvents.Subscribe( "overthrow_item_drop", OnItemDrop );
    GameEvents.Subscribe( "time_remaining", AlertTimer );
    GameEvents.Subscribe( "overtime_alert", OnOvertimeStart );
    GameEvents.Subscribe( "kill_alert", OnLeaderKilled );
    GameEvents.Subscribe("rescale_alert", OnRescaleAlert);
    GameEvents.Subscribe("minimap_rescale_predict",	OnMinimapRescalePredict);
    GameEvents.Subscribe("minimap_rescale",	OnMinimapRescale);
    GameEvents.Subscribe("leader_got_nothing", ShowLeaderPickMessage);

    ShowFightingArea();
})();

