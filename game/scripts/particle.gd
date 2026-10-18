extends GPUParticles2D

@onready var particle: GPUParticles2D = $"."
@onready var dictionary: Node2D = $"../../../resource_dictionary"

var particle_name := ""

func set_particle(condiment: Area2D):
	for particle_list in dictionary.particles:
		if particle_list["name"] == condiment.condiment_name:
			particle.texture = particle_list["image"]
			break
