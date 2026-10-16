extends Node

signal connection_status_changed(is_online: bool)

var is_online: bool = false
var _http_request: HTTPRequest

func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_ping_completed)
	
	check_connection()

func check_connection() -> void:
	_http_request.cancel_request()
	
	var err = _http_request.request("https://1.1.1.1")
	if err != OK:
		_set_online(false)

func _on_ping_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	_set_online(response_code == 200)

func _set_online(status: bool) -> void:
	if is_online != status:
		is_online = status
		connection_status_changed.emit(is_online)
		print("Network Status Changed: ", "ONLINE" if is_online else "OFFLINE")
