extends Node

var crypto = Crypto.new()
enum AuthType { WHITELABEL }

func signUp(instance) -> void:
	var error_label = instance.get_node("ColorRect/ScrollContainer/Control/ConnexionMenu/SignUpMenu/error")
	var _input_email = instance.get_node("ColorRect/ScrollContainer/Control/ConnexionMenu/SignUpMenu/email").text
	var input_username = instance.get_node("ColorRect/ScrollContainer/Control/ConnexionMenu/SignUpMenu/username").text
	var input_password = instance.get_node("ColorRect/ScrollContainer/Control/ConnexionMenu/SignUpMenu/password").text
	var input_confirm_password = instance.get_node("ColorRect/ScrollContainer/Control/ConnexionMenu/SignUpMenu/confirmPassword").text
	
	var password_regex = RegEx.new()
	password_regex.compile(r"^(?=.*[A-Z])(?=.*\d).{8,}$")
	
	error_label.hide()
	
	if !input_username.is_empty() and !input_password.is_empty() and !input_confirm_password.is_empty():
		if input_username.length() > 2:
			if input_password == input_confirm_password:
				if password_regex.search(input_password):
					var new_user = await register(instance, input_username, input_password)
					if !new_user is String:
						saveCredential(input_username, input_password)
						instance.updateMenu()
					else:
						instance.returnError(error_label, new_user)
				else:
					instance.returnError(error_label, "Password must contain at least 8 characters,1 uppercase and 1 number")
			else:
				instance.returnError(error_label, "Password fields don't match.")
		else:
			instance.returnError(error_label, "Username must contain at least 2 characters")
	else:
		instance.returnError(error_label, "All fields is required.")

func saveCredential(username, password):
	var key = crypto.generate_rsa(4096)
	var encrypted_bytes = crypto.encrypt(key, password.to_utf8_buffer())
	key.save("user://generated.key")
	
	var save_data: Dictionary = {
		"username": username,
		"password": Marshalls.raw_to_base64(encrypted_bytes)
	}
	var savefile = FileAccess.open("user://credentials.json", FileAccess.WRITE)
	
	if savefile:
		savefile.store_string(JSON.stringify(save_data))
		savefile.close()

func signIn(instance, input_username: String = "", input_password: String = ""):
	var error_label = instance.get_node("ColorRect/ScrollContainer/Control/ConnexionMenu/SignInMenu/error")
	if input_username == "" and input_password == "":
		var text_username = instance.get_node("ColorRect/ScrollContainer/Control/ConnexionMenu/SignInMenu/username").text
		var text_password = instance.get_node("ColorRect/ScrollContainer/Control/ConnexionMenu/SignInMenu/password").text
		if !text_username.is_empty() and !text_password.is_empty():
			input_username = text_username
			input_password = text_password
		else:
			instance.returnError(error_label, "All fields is required.")
	
	var login_user = await instance.leaderboardControler.leaderboardAuth.startSession(input_username, input_password)
	if !login_user is String:
		if !FileAccess.file_exists("user://credentials.json"):
			saveCredential(input_username, input_password)
		instance.updateMenu()
	else:
		instance.returnError(error_label, login_user)

func autoSignIn(instance):
	if FileAccess.file_exists("user://credentials.json") and FileAccess.file_exists("user://generated.key"):
		var key_file = FileAccess.get_file_as_string("user://generated.key")
		var key = CryptoKey.new()
		key.load_from_string(key_file)
		
		var credential_file = FileAccess.open("user://credentials.json", FileAccess.READ)
		var data = JSON.parse_string(credential_file.get_as_text())
		credential_file.close()
		
		var input_username = data["username"]
		var encrypted_bytes = Marshalls.base64_to_raw(data["password"])
		var decrypted_bytes = crypto.decrypt(key, encrypted_bytes)
		var input_password = decrypted_bytes.get_string_from_utf8()
		
		signIn(instance, input_username, input_password)
	else:
		return false

func register(instance, username, password):
	var response
	match Global.leaderboardAuthMethod:
		AuthType.WHITELABEL:
			response = await LL_WhiteLabel.SignUp.new(username, password).send()
			
			if(!response.success) :
				match response.error_data.message:
					"user with that email already exists":
						return "Username already exist."
					_:
						return response.error_data.message
			else:
				var session = await instance.leaderboardControler.leaderboardAuth.startSession(username, password)
				if !session is String:
					setProfilToPublic(username)
				else:
					return session
			
func setProfilToPublic(username = ""):
	var response = await LL_Players.SetPlayerProfilePrivate.new().send()
	if(!response.success) :
		return response.error_data.message
	else:
		if username != "":
			response = await LL_Players.SetPlayerName.new(username).send()
		return(true)

func startSession(username, password):
	var response
	match Global.leaderboardAuthMethod:
		AuthType.WHITELABEL:
			response = await LL_WhiteLabel.LoginAndStartSession.new(username, password).send()
	
			if(!response.success) :
				return response.error_data.message
			else:
				Global.player_name = response.player_identifier
				return true
