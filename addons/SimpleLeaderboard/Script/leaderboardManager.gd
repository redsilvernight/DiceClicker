class_name leaderboardManager
extends Node

var leaderboardAuth = preload("res://addons/SimpleLeaderboard/Script/leaderboardAuth.gd").new()
var leaderboardCard = preload("res://addons/SimpleLeaderboard/Scene/leaderboardCard.tscn")

func submitScore(leaderboard, score, player):
	await LL_Leaderboards.SubmitScore.new(leaderboard, score, player).send()

func getLeaderboard(leaderboard, nbr_entrie):
	var response = await LL_Leaderboards.GetScoreList.new(leaderboard, nbr_entrie).send()
	if response.success:
		var leaderboardEntries: Dictionary
		for item in response.items:
			leaderboardEntries[item.player.name] = {"rank": item.rank, "score": item.score}
		
		return leaderboardEntries
	else:
		return false

func getPlayerRank(leaderboard, player):
	var playerRank: Dictionary
	var response = await LL_Leaderboards.GetMemberRank.new(leaderboard, str(player)).send()
	if(response.success) :
		playerRank[response.player.name] = {"rank": response.rank, "score" : response.score}
		return playerRank
