extends Node
## ScoreManager Singleton
## Tracks score and combo
## AC 6.1: Score Awarding (All Sources)

var score: int = 0
var combo_count: int = 0

signal score_changed(new_score: int)
signal combo_triggered(bonus: int)

func _ready() -> void:
	print("[ScoreManager] Ready")

func add_points(amount: int) -> void:
	score += amount
	emit_signal("score_changed", score)
	print("[ScoreManager] +%d points (total: %d)" % [amount, score])

	# Check for new high score
	if score > SaveSystem.get_high_score():
		SaveSystem.set_high_score(score)

func increment_combo() -> void:
	combo_count += 1
	if combo_count == 5:
		# AC 6.3: Optional Combo Bonus (5 correct sorts in a row)
		add_points(25)
		emit_signal("combo_triggered", 25)
		AudioManager.play_sfx("combo")
		SaveSystem.increment_stat("total_combos")
		combo_count = 0
		print("[ScoreManager] COMBO! +25 bonus")

func reset_combo() -> void:
	if combo_count > 0:
		print("[ScoreManager] Combo reset (%d streak)" % combo_count)
	combo_count = 0
