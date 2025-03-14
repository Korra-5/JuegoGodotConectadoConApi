extends Node

# Variables globales
var nombre_jugador = ""
var tiempo_jugador = 0.0

func _ready():
	print("Global inicializado")

# Método auxiliar para obtener propiedades (con nombre diferente)
func get_property(property_name):
	if property_name == "nombre_jugador":
		return nombre_jugador
	elif property_name == "tiempo_jugador":
		return tiempo_jugador
	return null
