extends Node

var bw_shader = preload("res://Shaders/blackwhite.gdshader")

func bwShaderMaterial() -> ShaderMaterial:
	var mat = ShaderMaterial.new()
	mat.shader = bw_shader
	mat.set_shader_parameter("intensity", 1.0)
	return mat
