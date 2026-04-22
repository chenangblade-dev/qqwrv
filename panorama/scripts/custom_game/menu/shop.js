var psz_PurchaseItemName;
var nRefreshCountDown = 0;

var m_ShopItemPanels = {}; // 所有的商店物品
var m_ShopItemFromServer = [];
var m_ShopItemFromSerever_IndexByName = [];
var m_ColletionPanels = {};
var m_PlayerEquipItemData = {};
var m_PlayerCollectionData = {}
var m_PointsLeft = -1;

function OpenShop(){
    $("#page_shop").ToggleClass("Hidden");
    $("#menu_hit_listener").RemoveClass("MenuHidden");
}

function OpenPayment() {
    // if ($.Language() == "schinese") {
        $("#alipay_charge").ToggleClass("Hidden");
    // }else{
    //     var playerInfo = Game.GetPlayerInfo(Players.GetLocalPlayer());
    //     var steamid32 = playerInfo.player_steamid.substring(4);
    //     steamid32 = parseInt(steamid32) - 1197960265728;
    //     $("#paypal_payment_tooltip").SetDialogVariableInt("steamid", steamid32);
    //     $("#paypal_payment").ToggleClass("Hidden");
    // }
    $("#menu_items").RemoveClass("Hidden")
    $("#menu_hit_listener").RemoveClass("MenuHidden");
}

function ClosePayment() {
    $("#alipay_charge").AddClass("Hidden");
    $("#paypal_payment").AddClass("Hidden");

}

function OpenCharge() {
    $("#alipay_charge").ToggleClass("Hidden");
    $("#menu_hit_listener").RemoveClass("MenuHidden");
}

function CloseShop(){
    $("#page_shop").AddClass("Hidden");
}

function OpenCollection() {
    $("#page_collection").ToggleClass("Hidden");
    $("#menu_hit_listener").RemoveClass("MenuHidden");
}

function CloseCollections(){
    $("#page_collection").AddClass("Hidden");
}

function BuildPointsHistory(pointHistory) {
    // $.Msg(pointHistory);
    var parent = $("#trade_history");
    parent.RemoveAndDeleteChildren();
    var pointsRemaining = 0;
    for (var data in pointHistory){
        var m_TradeData = pointHistory[data];
        var day = m_TradeData['day'];
        var time = m_TradeData['time'];
        var amount = m_TradeData['amount'];
        var type = m_TradeData['type'];
        var m_HistoryItem = $.CreatePanel("Panel", parent, "");
        m_HistoryItem.BLoadLayoutSnippet("TradeHistoryItem");
        m_HistoryItem.FindChildTraverse("trade_index").text = parseInt(data) + 1;
        m_HistoryItem.FindChildTraverse("trade_day").text = day;
        m_HistoryItem.FindChildTraverse("trade_time").text = time;
        m_HistoryItem.FindChildTraverse("trade_amount").text = amount;
        pointsRemaining += parseFloat(amount);
        if(parseFloat(amount) > 0) m_HistoryItem.FindChildTraverse("trade_amount").AddClass("AmountAdd");
        else m_HistoryItem.FindChildTraverse("trade_amount").AddClass("AmountReduce");
        m_HistoryItem.FindChildTraverse("trade_type").text = $.Localize("#point_methods_" + type);
        if (data % 2 === 0) m_HistoryItem.AddClass("EvenRow");
    }

    $("#my_point").text = Math.floor(pointsRemaining);
    m_PointsLeft = Math.floor(pointsRemaining);

    GameUI.m_PointsLeft = m_PointsLeft;

    UpdateShopItems();

    GameUI.UpdatePaymentPointsRemaining();
    GameUI.UpdatePlusPointsRemaining();

    $("#points_remaining_button_tip").text = m_PointsLeft;
    if (m_PointsLeft == 0) {
        $("#points_remaining_tip_panel").AddClass("Hidden");
    }else{
        $("#points_remaining_tip_panel").RemoveClass("Hidden");
    }
}

function QueryPointsDataFromServer(){
    GameEvents.SendCustomGameEventToServer('bom_player_ask_point_history', {})
}

function OnPointHistoryArrived() {
    var pointHistory = CustomNetTables.GetTableValue('econ_data', 'point_history_' + Players.GetLocalPlayer());
    if (pointHistory == null) return;

    BuildPointsHistory(pointHistory);
}

function UpdateShopItems() {
    var parent = $("#shop_items");
    var points = m_PointsLeft;
    var childCount = parent.GetChildCount();

    for (var i = 0; i < childCount; i++) {
        var child = parent.GetChild(i)
        var cost = child.cost;
        if (cost > points) {
            child.enabled = false;
            child.AddClass("NotEnoughPoints");
        }else{
            child.enabled = true;
            child.RemoveClass("NotEnoughPoints");
        }
    }
}

function BuildShopItems(data) {
    var parent = $("#shop_items");
    parent.RemoveAndDeleteChildren();

    // if (Game.IsInToolsMode()) {
    //     data['test'] = {name: "summer_2021", cost: 64 }
    // }

    for (var index in data){
        var itemData = data[index];
        var itemName = itemData.name;

        m_ShopItemFromSerever_IndexByName[itemName] = itemData;
        var itemImage = itemData.image;

        var itemCost = itemData.cost;
        var itemDiscount = itemData.discount;

        m_ShopItemPanels[itemName] = $.CreatePanel("Panel", parent, "");
        m_ShopItemPanels[itemName].BLoadLayoutSnippet("ShopItem");
        m_ShopItemPanels[itemName].FindChildTraverse("shop_item_title").text = $.Localize("#econ_" + itemName);

        m_ShopItemPanels[itemName].FindChildTraverse("shop_item_image").SetImage("file://{resources}/images/custom_game/econ/" + itemName + ".png");

        m_ShopItemPanels[itemName].FindChildTraverse("purchase_cost_text").SetDialogVariable("cost", String(itemCost));
        m_ShopItemPanels[itemName].cost = itemCost;
        if (m_PointsLeft > 0){
            if (itemCost > m_PointsLeft ) {
                m_ShopItemPanels[itemName].enabled = false;
                m_ShopItemPanels[itemName].AddClass("NotEnoughPoints")
            }else {
                m_ShopItemPanels[itemName].enabled = true;
                m_ShopItemPanels[itemName].RemoveClass("NotEnoughPoints")
            }
        }

        if (itemDiscount !== undefined){
            m_ShopItemPanels[itemName].FindChildTraverse("sale_overlay").RemoveClass("DontShow");
        }

        (function(index){
            var itemData = data[index]
            m_ShopItemPanels[itemData.name].SetPanelEvent("onactivate", function(){
                ShowConfirmPurchaseDialog(itemData.name, itemData.cost);
            });
            m_ShopItemPanels[itemData.name].FindChildTraverse('preview_button').SetPanelEvent("onactivate", function(){
                GameEvents.SendCustomGameEventToServer('bom_player_preview', {item: itemData.name})
                $("#page_shop").AddClass("Hidden");
            });
            m_ShopItemPanels[itemData.name].SetPanelEvent("onmouseover", function(){
                $.DispatchEvent("DOTAShowTextTooltip", m_ShopItemPanels[itemData.name], $.Localize('#description_'+itemData.name));
            });
            m_ShopItemPanels[itemData.name].SetPanelEvent("onmouseout", function(){
                $.DispatchEvent("DOTAHideTextTooltip");
            });
        })(index);
    }

    RebuildShopTags();
}

function RebuildShopTags() {
    if (Object.keys(m_ShopItemPanels).length <= 0 || m_PlayerCollectionData == undefined) {
        $.Schedule(1, RebuildShopTags);
        return;
    }
    for (var name in m_PlayerCollectionData) {
        if (name != "steamid" && m_ShopItemPanels[name] != null) {
            m_ShopItemPanels[name].AddClass("Owned");
        }
    }
}

function ShowConfirmPurchaseDialog(name, cost){
    $("#confirm_purchase").SetDialogVariableInt("cost", cost);
    $("#confirm_purchase").SetDialogVariable("item_name", $.Localize("#econ_" + name));
    $("#confirm_purchase").SetDialogVariable("item_description", $.Localize("#Description_" + name));
    $("#confirm_purchase_dialog").RemoveClass("Hidden");
    psz_PurchaseItemName = name;
}

function OnConfirmPurchase() {
    GameEvents.SendCustomGameEventToServer('bom_player_purchase', {
        ItemName: psz_PurchaseItemName,
    })
}

function OnPurchaseMessageArrived(args) {
    QueryShopRelatedDataFromServer();
    GameEvents.SendCustomGameEventToServer("bom_player_equip",{})
    HideConfirmPurchasePanel();
}

function HideConfirmPurchasePanel() {
    $("#confirm_purchase_dialog").AddClass("Hidden");
}


function QueryShopItemsFromServer() {
    GameEvents.SendCustomGameEventToServer('bom_player_ask_shop_items', {})
}

function OnShopItemsArrived() {
    var data = CustomNetTables.GetTableValue('econ_data', 'shop_items');
    if (data == null) QueryShopItemsFromServer();
    BuildShopItems(data);
}

function RefreshingRefreshCountDown() {
    nRefreshCountDown--;
    var label = $("#refresh_button_label");
    label.text = $.Localize("#Refresh") + "(" + nRefreshCountDown + ")";
    if (nRefreshCountDown <= 0){
        $("#refresh_button").enabled = true;
        label.text = $.Localize("#Refresh");
    }
    $.Schedule(1, RefreshingRefreshCountDown);
}

function OnConfirmEquip() {
    var playerInfo = Game.GetPlayerInfo( Players.GetLocalPlayer() );
    if ( !playerInfo )
        return;

    GameEvents.SendCustomGameEventToServer('bom_player_equip', {
        items: JSON.stringify(m_PlayerEquipItemData || {}),
    })
}

function RebuildCollections(data){
    var parent = $("#collection_cells");
    parent.RemoveAndDeleteChildren();

    m_PlayerCollectionData = data;

    if (m_ShopItemFromSerever_IndexByName === undefined){
        QueryShopItemsFromServer();
        return;
    }

    for (var name in data){
        if (name !== 'steamid') {
            m_ColletionPanels[name] = $.CreatePanel("Panel", parent, "");
            m_ColletionPanels[name].BLoadLayoutSnippet("CollectionItem");
            m_ColletionPanels[name].FindChildTraverse("collection_item_title").text = $.Localize("#econ_" + name);
            m_ColletionPanels[name].FindChildTraverse("collection_item_image").SetImage("file://{resources}/images/custom_game/econ/" + name + ".png");

            var equipt = m_PlayerCollectionData[name];
            if (equipt){
                m_PlayerEquipItemData[name] = true;
                m_ColletionPanels[name].FindChildTraverse("button_equip").visible = false;
            }else{
                m_PlayerEquipItemData[name] = false;
                m_ColletionPanels[name].FindChildTraverse("button_remove").visible = false;
            }

            (function(_name){
                var code_equip =
                    "require 'modules/econ'\n" +
                    "if Econ.OnEquip_" + _name + "_client then \n" +
                        "Econ.OnEquip_" + _name + "_client( thisEntity ) \n" +
                    "end";
                var code_remove =
                    "require 'modules/econ'\n" +
                    "if Econ.OnRemove_" + _name + "_client then\n" +
                        "Econ.OnRemove_" + _name + "_client( thisEntity ) \n" +
                    "end";
                m_ColletionPanels[_name].FindChildTraverse("button_equip").SetPanelEvent("onactivate", function(){
                    // $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "demo_hero_scene", "demo_hero", "RunScriptCode" , code_equip);
                    m_ColletionPanels[_name].FindChildTraverse("button_equip").visible=false;
                    m_ColletionPanels[_name].FindChildTraverse("button_remove").visible=true;
                    m_PlayerEquipItemData[_name] = true;
                    OnConfirmEquip();
                });
                m_ColletionPanels[_name].FindChildTraverse("button_remove").SetPanelEvent("onactivate", function() {
                    // $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "demo_hero_scene", "demo_hero", "RunScriptCode" , code_remove);
                    m_ColletionPanels[_name].FindChildTraverse("button_equip").visible=true;
                    m_ColletionPanels[_name].FindChildTraverse("button_remove").visible=false;
                    m_PlayerEquipItemData[_name] = false;
                    OnConfirmEquip();
                });
            })(name, equipt);
        }
    }
}

function OnCollectionDataArrived() {
    var data = CustomNetTables.GetTableValue('econ_data', 'collection_data_' + Players.GetLocalPlayer());
    if (data == null) return;
    RebuildCollections(data);
    RebuildShopTags(data);
}

function QueryCollectionDataFromServer() {
    GameEvents.SendCustomGameEventToServer('bom_player_ask_collection', {})
}

function TogglePointHistory() {
    $("#trade_history").ToggleClass("Hidden");
}

function ToggleChargePanel() {
    $("#alipay_charge").ToggleClass("Hidden");

    if (!$("#alipay_charge").BHasClass("Hidden")) {
        $("#AvalonPayment").InputFocus();
    }
}

var CheckDonateOrderCount = 0;
function OnPay( amount, method ) {
    CheckDonateOrderCount = 0;
    Request( "create_donate_order", {price:amount, method:method}, function (data) {
        $.Msg(data.url);
        if (data.url) {
            $("#AvalonPayment").ShowQRCode(data.url);
        } else {
            CheckDonateOrder();
        }
    })
}

function CheckDonateOrder() {
    var steamid = Game.GetLocalPlayerInfo().player_steamid;
    var table = CustomNetTables.GetTableValue("bom_plus", "donate_order_" + steamid);
    $.Msg(table)
    if (table && table['url']) {
        $.Msg(table['url']);
        $("#AvalonPayment").ShowQRCode(table['url']);
        return
    }

    if (CheckDonateOrderCount >= 5) {
        $("#AvalonPayment").InputFocus();
        return;
    }

    CheckDonateOrderCount++;
    $.Schedule(0.5, CheckDonateOrder)
}

function OnPaymentComplete() {
    if (!$("#alipay_charge").BHasClass("Hidden")) {
        $("#alipay_charge").AddClass("Hidden");
        $("#charge_button_text").text = $.Localize("#charge");
    }

    QueryPointsDataFromServer();
    $("#page_shop").RemoveClass("Hidden");
    $("#menu_hit_listener").RemoveClass("MenuHidden");
}

function QueryShopRelatedDataFromServer(){
    QueryPointsDataFromServer();
    QueryShopItemsFromServer();
    QueryCollectionDataFromServer()
    $("#refresh_button").enabled = false;
    nRefreshCountDown = 60;
    RefreshingRefreshCountDown()
}

(function(){
    OnCollectionDataArrived();
    OnShopItemsArrived();
    OnPointHistoryArrived();

    var AvalonPayment = $("#AvalonPayment");
    AvalonPayment.BLoadLayout("file://{resources}/layout/custom_game/payment.xml", false, false);
    AvalonPayment.OnPay(OnPay);

    GameEvents.Subscribe("avalon_payment_complete", OnPaymentComplete);

    QueryShopRelatedDataFromServer();
    CustomNetTables.SubscribeNetTableListener('econ_data', OnCollectionDataArrived);
    CustomNetTables.SubscribeNetTableListener('econ_data', OnShopItemsArrived);
    CustomNetTables.SubscribeNetTableListener('econ_data', OnPointHistoryArrived);
    GameEvents.Subscribe('bom_player_purchase_message', OnPurchaseMessageArrived);

    GameEvents.Subscribe('bom_dedicated_server_key', (args) => {
        $.Msg(args)
    })
    GameEvents.Subscribe('bom_dedicated_server_wtfkey', (args) => {
        $.Msg(args)
    })


    GameUI.OpenPayment = OpenPayment;
})();
