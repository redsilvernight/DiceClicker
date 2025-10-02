class_name leaderboardManager
extends Node

var leaderboardAuth = preload("res://Script/Hud/leaderboardAuth.gd").new()

func submitScore(leaderboard, score, player):
	await LL_Leaderboards.SubmitScore.new(leaderboard, score, player).send()

func getLeaderboard(leaderboard, nbr_entrie):
	var response = await LL_Leaderboards.GetScoreList.new(leaderboard, nbr_entrie).send()
	if response.success:
		var leaderboardEntries: Dictionary
		for item in response.items:
			leaderboardEntries[item.player.name] = [item.rank, item.score]
			
		return leaderboardEntries
	else:
		return false
