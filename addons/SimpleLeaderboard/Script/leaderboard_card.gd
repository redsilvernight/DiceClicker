extends Control

func setup(rank, player_name, score):
	$Panel/Rank.text = str(rank)
	$Panel/Name.text = str(player_name)
	$Panel/Score.text = str(score)
