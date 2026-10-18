extends Control

enum Mode { SIGN_IN, SIGN_UP }
var current_mode: Mode = Mode.SIGN_IN

const FIREBASE_API_KEY: String = "AIzaSyAW7iwWwVLejpb_KJN_k7F2MOfZQNQFwr0"

@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/Label
@onready var email_input: LineEdit = $Panel/MarginContainer/VBoxContainer/email
@onready var password_input: LineEdit = $Panel/MarginContainer/VBoxContainer/pass
@onready var submit_button: Button = $Panel/MarginContainer/VBoxContainer/submit
@onready var sign_up_button: Button = $"Panel/MarginContainer/VBoxContainer/HBoxContainer/sign up"
@onready var guest_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/guest
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var error_dialog: AcceptDialog = $ErrorDialog

func _ready() -> void:
	email_input.placeholder_text = "Email"
	password_input.placeholder_text = "Password"
	
	submit_button.pressed.connect(_on_submit_button_pressed)
	sign_up_button.pressed.connect(_on_mode_button_pressed)
	guest_button.pressed.connect(_on_guest_button_pressed)
	
	http_request.request_completed.connect(_on_request_completed)
	
	NetworkManager.connection_status_changed.connect(_on_network_status_changed)
	
	NetworkManager.check_connection()
	
func _on_network_status_changed(is_online: bool) -> void:
	submit_button.disabled = not is_online
	sign_up_button.disabled = not is_online

func _on_mode_button_pressed() -> void:
	if current_mode == Mode.SIGN_IN:
		current_mode = Mode.SIGN_UP
		title_label.text = "Create Account"
		submit_button.text = "Register"
		sign_up_button.text = "Back to Login"
	else:
		current_mode = Mode.SIGN_IN
		title_label.text = "Welcome Back, Chef!"
		submit_button.text = "Login"
		sign_up_button.text = "Sign up"

func _on_submit_button_pressed() -> void:
	var email = email_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	
	if email.is_empty() or password.is_empty():
		show_error_popup("Please enter both email and password.")
		return
	
	submit_button.disabled = true
	
	var url: String = ""
	if current_mode == Mode.SIGN_UP:
		url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + FIREBASE_API_KEY
	else:
		url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + FIREBASE_API_KEY

	var payload = JSON.stringify({
		"email": email,
		"password": password,
		"returnSecureToken": true
	})
	
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, HTTPClient.METHOD_POST, payload)

func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	submit_button.disabled = false
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	if response_code == 200:
		var user_id = response.get("localId", "")
		var id_token = response.get("idToken", "")
		print("Authentication Successful! User ID: ", user_id)
		
		get_tree().change_scene_to_file("res://node_2d.tscn")
	else:
		var error_data = response.get("error", {})
		var firebase_msg: String = error_data.get("message", "UNKNOWN_ERROR")
		
		match firebase_msg:
			"EMAIL_NOT_FOUND":
				show_error_popup("No account exists with this email address. Please sign up first!")
			"INVALID_PASSWORD", "INVALID_LOGIN_CREDENTIALS":
				show_error_popup("Incorrect email or password. Please try again.")
			"EMAIL_EXISTS":
				show_error_popup("An account with this email already exists.")
			"INVALID_EMAIL":
				show_error_popup("Please enter a valid email address.")
			"WEAK_PASSWORD : Password should be at least 6 characters":
				show_error_popup("Password must be at least 6 characters long.")
			_:
				show_error_popup("Authentication failed: " + firebase_msg)

func _on_guest_button_pressed() -> void:
	print("Proceeding in Guest/Offline mode...")

func show_error_popup(message: String) -> void:
	error_dialog.dialog_text = message
	error_dialog.popup_centered()
