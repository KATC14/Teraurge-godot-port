extends Node


var stage_height = 720
var stage_width  = 1280
#var player_location = Vector2(2147.25, 3147.6)
var map_target
var loc_name:String
var loc_coords
var last_dialogue_func = ''

var version = 2.13
var menu_state = 'warning'
var debug_mode = false
var has_story  = false
var ex_magic   = false
var index      = ''
var lose_index
var win_index
var auto_continue_pointer = ''
var character_sprite = ''
var last_index       = ''
var override_index   = ''
var current_index    = ''
var character_name   = ''
var environment_name = ''
var ENVIROMENT_STATS = ''
var player_hand_size = 4

# script cross compatibility
var ambient_strength = null
var env_ambient = null
var scene_character = ""
var map_active = false
var debug_screen_visible = false
var whos_turn = 'player'
var in_combat = false
var diag_file = 'diag'
var main_menu_active = false
var character_leaves = false
var character_returns = false

var ALL_CARDS = ''
var ALL_ITEMS = ''
var ITEM_SLOTS = [
	"empty",# 0 MANNEQUIN mannequins/"+"default
	"empty", # 1
	"empty", # 2
	"empty", # 3
	"empty", # 4
	"empty", # 5
	"empty", # 6
	"empty", # 7
	"empty", # 8
	"empty", # 9
	"empty", # 10
	"empty", # 11
	"empty", # 12
	"empty", # 13
	"empty", # 14
	"empty",# 15 with 0 16 else
]

# SETTING OBJECT KEYS
var SLOT_KEYS = { # Equipped items saved as strings
	#Highest layer
	"twohanded": 12,# twohanded
	"sidearm": 11,  # sidearm
	"offhand": 10,  # offhand
	"mainhand": 9,  # mainhand

	"hands": 8,     # hands
	"head": 7,      # head
	"torso": 6,     # torso
	"legs": 5,      # legs
	"boots": 4,     # boots # Will go over legs slot. Legs slot will be changed to a "tucked" version when in use.
	"shoes": 3,     # shoes # Will go under legs slot
	"socks": 2,     # socks
	"underwear": 1, # underwear
	"mannequin": 0  # mannequin
	#Lowest layer
}

#SAVE VARIABLE NAMES
#ITEM_SLOTS# item slots too but its large
var RAPE_FILTER  = false
var FERAL_FILTER = false
var GORE_FILTER  = false

var player_name   = 'john'
var player_gender = "male"

var CHANGED_CHARACTERS   = {}
var CHANGED_ENCOUNTERS   = {}
var CHANGED_DIAGS        = {}
var CHANGED_ENVIRONMENTS = {}

var ITEM_INVENTORY = []
var CARD_INVENTORY = []
var player_DECK    = []

var player_base_hitpoints = 40
var player_hitpoints = player_base_hitpoints
var player_hitpoints_damage = 0

var player_A_money = 0
var player_B_money = 0

var player_stats = {
	"heat_res":   0,
	"cold_res":   0,
	"impact_res": 0,
	"slash_res":  0,
	"pierce_res": 0,
	"magic_res":  0,
	"bio_res":    0,

	"charisma":     4,
	"will":         4,
	"intelligence": 4,
#	"perception":   4,
	"agility":      4,
	"strength":     4,
	"endurance":    4
}
var FLAGS           = []
var CLICKED_OPTIONS = {}
var saved_indexs    = {}
var COUNTERS        = {}
var TIMERS          = {}
var DISCOVERED_LOCATIONS = ["sejan_witch_house"]

var DAYS = 0
var TIME = 50
