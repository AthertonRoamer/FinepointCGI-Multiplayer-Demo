extends Control

signal found_server
signal server_removed
signal joinGame

@export var listenPort : int = 8911
@export var broadcastPort : int = 8912
@export var broadcastAddress : String = '192.168.86.255'
@export var serverInfo : PackedScene


var broadcastTimer : Timer

var RoomInfo = {"name":"name", "playerCount": 0}

var broadcaster : PacketPeerUDP
var listener : PacketPeerUDP

# Called when the node enters the scene tree for the first time.
func _ready():
	broadcastTimer = $BroadcastTimer
	set_up()
	
	
func set_up():
	listener = PacketPeerUDP.new()
	var ok = listener.bind(listenPort)
	
	if ok == OK:
		print("Bound to Listener Port: " + str(listenPort) + " successful!")
		$Label2.text = "Bound to listener port"
	else:
		print("Failed to bind to listener port")
		$Label2.text = "Failed to bind to listener port"
	
	
func _process(delta):
	if listener.get_available_packet_count() > 0:
		var bytes = listener.get_packet()
		var serverport = listener.get_packet_port()
		var serverip = listener.get_packet_ip()
		var data = bytes.get_string_from_ascii()
		var roomInfo = JSON.parse_string(data)
		
		print("Server IP: " + str(serverip) + " serverPort: " + str(serverport) + " room info: " + str(roomInfo))
		
		for i in $Panel/VBoxContainer.get_children():
			if i.name == roomInfo.name:
				i.get_node("PlayerCount").text = str(roomInfo.playerCount)
				return
			
		var currentInfo = serverInfo.instantiate()
		currentInfo.name = roomInfo.name
		currentInfo.get_node("Name").text = roomInfo.name
		currentInfo.get_node("Ip").text = serverip
		currentInfo.get_node("PlayerCount").text = str(roomInfo.playerCount)
		$Panel/VBoxContainer.add_child(currentInfo)
		currentInfo.joinGame.connect(joinedByIp)
			
			
func setUpBroadCast(name):
	RoomInfo.name = name
	RoomInfo.playerCount = GameManager.Players.size()
	
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address('192.168.86.255', listenPort)
	
	var ok = broadcaster.bind(broadcastPort)
	
	if ok == OK:
		print("Bound to Broadcast Port: " + str(broadcastPort) + " successful!")
	else:
		print("Failed to bind to broadcast port")
		
	$BroadcastTimer.start()
	


func _on_broadcast_timer_timeout():
	print("Broadcasting game")
	RoomInfo.playerCount = GameManager.Players.size()
	var data = JSON.stringify(RoomInfo)
	var packet = data.to_ascii_buffer()
	broadcaster.put_packet(packet)
	
	
func clean_up():
	$BroadcastTimer.stop()
	listener.close()
	if broadcaster != null:
		broadcaster.close()
	
func _exit_tree():
	clean_up()
	
func joinedByIp(ip):
	joinGame.emit(ip)
