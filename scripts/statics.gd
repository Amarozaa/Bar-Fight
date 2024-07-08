class_name Statics
extends Node


const MAX_CLIENTS = 1
const PORT = 5409


class PlayerData:
    var id: int
    var name: String
    
    func _init(new_id: int, new_name: String) -> void:
        id = new_id
        name = new_name
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
        }
