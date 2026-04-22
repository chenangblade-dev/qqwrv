function OpenMenu() {
    var menu = $("#Menu");
    menu.AddClass('Show');
    menu.RemoveClass('Hide');
    $("#menu_hit_listener").RemoveClass("MenuHidden");
}

function ToggleMenuItems() {
    $("#menu_items").ToggleClass("Hidden")
}

function CloseMenu() {
    var menu = $("#Menu");
    menu.RemoveClass('Show');
    menu.AddClass('Hide');
}

function OnClickCloseMenu(){
    $("#menu_hit_listener").AddClass("MenuHidden");
    $("#page_shop").AddClass("Hidden");
    $("#page_ability_pool").AddClass("Hidden");
    $("#page_collection").AddClass("Hidden");
    $("#alipay_charge").AddClass("Hidden");
    $("#paypal_payment").AddClass("Hidden");
    $("#page_rank").AddClass("Hidden");
    $("#menu_items").AddClass("Hidden")
    $("#page_plus").AddClass("Hidden");
}

function OpenRules() {
}

function CloseNewGame() {
    $("#new_game_panel").AddClass("Hidden");
}

var n_CurrentPage = 1;
function NextPage(){
    n_CurrentPage ++;
    for(var i = 1; i <= 5; i++){

    }
}

(function() {
    if (Game.GetState() != 9) {
        $.Schedule(30, function() { $("#menu_items").AddClass("Hidden") });
    }
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse('courier').style.visibility = "collapse";
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse('StickyItemSlotContainer').style.visibility = "collapse";
    
})();