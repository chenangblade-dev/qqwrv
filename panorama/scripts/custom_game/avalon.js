"use strict";

var _Request_QueueIndex = 0;
var _Request_Table = {};
function Request( event, data, func, timeout ) {
	var index = "-1";
	if (typeof func === "function") {
		index = (_Request_QueueIndex++).toString();
		_Request_Table[index] = func;
	}
	GameEvents.SendCustomGameEventToServer("_avalon_service_events_req", {
		event: event,
		data: JSON.stringify(data),
		queueIndex: index
	});
	timeout = timeout || 5;
	$.Schedule(timeout, function () {
		delete _Request_Table[index]
	});
}
GameEvents.Subscribe("_avalon_service_events_res", function (data) {
	var index = data.queueIndex || ""
	var func = _Request_Table[index];
	if (!func) return;
	delete _Request_Table[index];
	if (func) { func(JSON.parse(data.result)) };
});

function req_queue() {
	this._list = [];
}
req_queue.prototype.insert = function(event, data, timeout) {
	this._list.push({
		'event': event,
		'data': data,
		'timeout': timeout || 5,
	});
	return this;
};
req_queue.prototype.then = function(func) {
	var len = this._list.length;
	if (len > 0) {
		this._list[len-1].func = func;
	}
	return this;
};
req_queue.prototype.start = function( onComplete ) {
	var list = this._list;
	function send() {
		var h = list.shift();
		if (!h) {
			if (onComplete) onComplete();
			return;
		}
		Request( h.event, h.data, function (data) {
			h.func(data);
			send();
		}, h.timeout );
	}
	send();
};

function Queue() {
	return new req_queue();
}