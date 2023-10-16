extends Control


@export var Address := "127.0.0.1"
@export var port := 8910
@export var player_count := 2
var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#called on server and clients
func player_connected(id):
	print("Player Connected: " + str(id))
	GameManager.active = true
	
	
#called on server and clients
func player_disconnected(id):
	print("Player Disconnected: " + str(id))
	if multiplayer.get_peers().size() == 0:
		GameManager.active = false
	
#called only on clients
func connected_to_server():
	print("Connected to server")
	SendPlayerInformation.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
	
#called only on clients
func connection_failed():
	print("Connection failed")
	
	
@rpc("any_peer")
func SendPlayerInformation(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name" : name,
			"id" : id,
			"score" : 0,
		}
		
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
	
	
@rpc("any_peer", "call_local")
func StartGame():
	var scene = load("res://test.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()


func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, player_count)
	if error != OK:
		print("Cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())
	$ServerBrowser.setUpBroadCast($LineEdit.text )
	

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_pressed():
	StartGame.rpc()
	

func _on_button_pressed():
	GameManager.Players[GameManager.Players.size() + 1] = {
		"name" : "test",
			"id" : 1,
			"score" : 0,
	}
