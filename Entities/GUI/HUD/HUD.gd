extends CanvasLayer


func _ready():
	$Control/VBoxContainer/HBoxContainer/HPEnergy/HPContainer/HPBar.value = 100
	$Control/VBoxContainer/HBoxContainer/HPEnergy/EnergyContainer/EnergyBar.value = 100
	$Control/VBoxContainer/HBoxContainer/FPS.text = str(50)
	
	if(PlayerStats.connect("player_hp", self, "update_player_hp")):
		OS.alert("Error connecting player_hd in HUD", "Signaling error")
	if(PlayerStats.connect("player_energy", self, "update_player_energy")):
		OS.alert("Error connecting player_energy in HUD", "Signaling error")
	if(PlayerStats.connect("fps", self, "update_fps")):
		OS.alert("Error connecting fps in HUD", "Signaling error")
	
func update_player_hp():
	$Control/VBoxContainer/HBoxContainer/HPEnergy/HPContainer/HPBar.value = PlayerStats.player_hp

func update_player_energy():
	$Control/VBoxContainer/HBoxContainer/HPEnergy/EnergyContainer/EnergyBar.value = PlayerStats.player_energy
	
func update_fps():
	$Control/VBoxContainer/HBoxContainer/FPS.text = str(PlayerStats.fps)