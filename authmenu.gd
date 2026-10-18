extends Control

enum Mode { SIGN_IN, SIGN_UP }
var current_mode: Mode = Mode.SIGN_IN

# 👉 PASTE YOUR SUPABASE DETAILS HERE 👈
const SUPABASE_URL: String = "https://sgudgjdlynzryhneiftk.supabase.co"       # e.g., "https://xyz.supabase.co"
const SUPABASE_ANON_KEY: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNndWRnamRseW56cnlobmVpZnRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIzMzA3NjMsImV4cCI6MjEwNzkwNjc2M30.vmpNsNX3mtU0_zhBvrCvvUg7lAAoE8_6nzW1wjAmbLI"     # Your long public anon key string

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
		url = SUPABASE_URL + "/auth/v1/signup"
	else:
		url = SUPABASE_URL + "/auth/v1/token?grant_type=password"

	var payload = JSON.stringify({
		"email": email,
		"password": password
	})
	
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_ANON_KEY
	]
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, payload)

func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	submit_button.disabled = false
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	# Supabase returns 200 or 201 on success
	if response_code == 200 or response_code == 201:
		print("Supabase Authentication Successful!")
		get_tree().change_scene_to_file("res://node_2d.tscn")
	else:
		# Extract error message cleanly from Supabase's error response structure
		var error_msg: String = "Unknown error occurred."
		if response:
			if response.has("msg"):
				error_msg = response.get("msg")
			elif response.has("error_description"):
				error_msg = response.get("error_description")
			elif response.has("message"):
				error_msg = response.get("message")
				
		show_error_popup("Authentication failed: " + error_msg)

func _on_guest_button_pressed() -> void:
	print("Proceeding in Guest/Offline mode...")

func show_error_popup(message: String) -> void:
	error_dialog.dialog_text = message
	error_dialog.popup_centered()
