extends "res://scripts/pieces/piece.gd"

var tex_suffix: String = "i_piece"
var scene = Main.I_piece

func _ready():
	zero_to_one = [[],													# basic rotation
				[Main.moves.LEFT, Main.moves.LEFT],					# test 2
				[Main.moves.RIGHT],									# test 3
				[Main.moves.LEFT, Main.moves.LEFT, Main.moves.DOWN],	# test 4
				[Main.moves.RIGHT, Main.moves.UP, Main.moves.UP]		# test 5
				]
	one_to_zero = [[],													# basic rotation
				[Main.moves.RIGHT, Main.moves.RIGHT],				# test 2
				[Main.moves.LEFT],									# test 3
				[Main.moves.RIGHT, Main.moves.RIGHT, Main.moves.UP],	# test 4
				[Main.moves.LEFT, Main.moves.DOWN, Main.moves.DOWN]	# test 5
				]
	one_to_two = [[],													# basic rotation
				[Main.moves.LEFT],									# test 2
				[Main.moves.RIGHT, Main.moves.RIGHT],					# test 3
				[Main.moves.LEFT, Main.moves.UP, Main.moves.UP],		# test 4
				[Main.moves.RIGHT, Main.moves.RIGHT, Main.moves.DOWN]	# test 5
				]
	two_to_one = [[],													# basic rotation
				[Main.moves.RIGHT],									# test 2
				[Main.moves.LEFT, Main.moves.LEFT],					# test 3
				[Main.moves.RIGHT, Main.moves.DOWN, Main.moves.DOWN],	# test 4
				[Main.moves.LEFT, Main.moves.LEFT, Main.moves.UP]		# test 5
				]
	two_to_three = one_to_zero
	three_to_two = zero_to_one
	three_to_zero = two_to_one
	zero_to_three = one_to_two
	wall_kicks = [
				[[],			 zero_to_one, [], 			zero_to_three],
				[one_to_zero,	 [], 		  one_to_two,	[]],
				[[], 			 two_to_one,  [], 			two_to_three],
				[three_to_zero, [], 		  three_to_two, []]
				]
	super()
