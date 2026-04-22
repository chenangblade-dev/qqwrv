"use strict";

function GoBack() {
	$("#InputPage").visible = true;
	$("#HtmlPage").visible = false;
	$("#manual_charge").visible = false;
}

var payHandle = null;
function Pay( method ) {
	$("#InputPage").visible = false;
	$("#HtmlPage").visible = true;
	if (payHandle) {
		var AvalonCoin = $("#AvalonCoin");
		var text = AvalonCoin.text;
		var amount = parseInt(text);
		if (!amount || amount < 0) return;
		payHandle( amount, method );
	}
}

function AvalonCoinInputFocus() {
	$("#AvalonCoin").SetFocus();
	$("#InputPage").visible = true;
	$("#HtmlPage").visible = false;
}

// 文本改变
var AvalonCoinLock = false;
function OnAvalonCoinChange() {
	if (AvalonCoinLock) return;
	AvalonCoinLock=true;

	var AvalonCoin = $("#AvalonCoin");
	var text = AvalonCoin.text;
	var m = text.replace(/\D+/g,"");
	var amount = parseInt(m);
	if (amount > 0) {
		AvalonCoin.text = parseInt(m);
	}
	else {
		amount = 0;
		AvalonCoin.text = "0";
	}

	var str = (amount/100).toString()
	if (str.indexOf(".") > 0) {
		$("#PrePayButton").SetDialogVariable("Amount",(amount).toFixed(2).toString());
	}
	else{
		$("#PrePayButton").SetDialogVariable("Amount",Math.floor(amount).toString());
	}
	AvalonCoinLock = false;
}

function AddAvalonCoin(num) {
	var AvalonCoin = $("#AvalonCoin");
	var text = AvalonCoin.text;
	var amount = parseInt(text);
	if (!amount || amount < 0) amount = 0;
	AvalonCoin.text = (amount + num);
}

var closeHandle = null;
function Close() {
	if (closeHandle) {
		closeHandle();
	}
}

// 显示二维码
function ShowQRCode(url) {
	$("#Html").SetURL(url)
	$("#HtmlPage").visible = true;
	$("#url_entry").text = url;
}

function UpdatePaymentPointsRemaining() {
	$("#PayTip").text = "当前剩余积分：" + GameUI.m_PointsLeft + "<br>注意事项<br>\
						通过捐助本作品可以获取积分，捐助1元可以获得1积分<br>\
						请谨慎捐助，捐助完成后将不能退款<br>\
						捐助相关问题可加<font color='#FFB207'>QQ群570058789</font>，游戏性等相关问题勿加<br>\
						由Avalon工作室提供支付服务<br>\
						You can also make a donation to my paypal to get points.<br>\
						1 CNY = 1 POINT, Converted according to exchange rate.<br>\
						My Paypal Donation Link: https://www.paypal.me/xavierchn<br>\
						DON'T FORGET to leave your DOTA2 ID(the 8 or 9 digits id) in the donation comment<br>\
						If you forgot, please contact me via email:Xavier_CHN@live.com\
						"
}

function ManualCharge() {
    $("#manual_charge").visible = true;

    var playerId = Players.GetLocalPlayer();
    var playerInfo = Game.GetPlayerInfo( playerId );
    var steamid32 = playerInfo.player_steamid.substring(4);
    steamid32 = parseInt(steamid32) - 1197960265728;
    
    $("#manual_charge_tooltip").SetDialogVariable("steamid", steamid32);
}

function ShowManualQRCode() {
	$("#manual_qrcode_alipay").visible = true;
	$("#manual_qrcode_wechat").visible = true;
}

;(function(){
	GameUI.UpdatePaymentPointsRemaining = UpdatePaymentPointsRemaining
	var AvalonCoin = $("#AvalonCoin");
	AvalonCoin.text = 8;
	$("#PrePayButton").SetDialogVariable("Amount", "8");
	$.GetContextPanel().InputFocus = AvalonCoinInputFocus;
	$.GetContextPanel().OnClose = function (f) { closeHandle = f }
	$.GetContextPanel().OnPay = function (f) { payHandle = f }
	$.GetContextPanel().ShowQRCode = ShowQRCode;
	$("#HtmlPage").visible = false;
    $("#manual_charge").visible = false;

    // $("#manual_qrcode_alipay").visible = false;
	// $("#manual_qrcode_wechat").visible = false;

	$("#PayTip").text = "注意事项<br>\
						通过捐助本作品可以获取积分，捐助1元可以获得1积分<br>\
						请谨慎捐助，捐助完成后将不能退款<br>\
						捐助相关问题可加<font color='#FFB207'>QQ群570058789</font>，游戏性等相关问题勿加<br>\
						由Avalon工作室提供支付服务<br>\
						You can also make a donation to my paypal to get points.<br>\
						1 CNY = 1 POINT, Converted according to exchange rate.<br>\
						My Paypal Donation Link: https://www.paypal.me/xavierchn<br>\
						DON'T FORGET to leave your DOTA2 ID(the 8 or 9 digits id) in the donation comment<br>\
						If you forgot, please contact me via email:Xavier_CHN@live.com\
						"
})()
