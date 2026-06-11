meta = {
    name = 'Kaizo for Single-Celled Organisms',
	description = "Levels for building kaizo confidence.",
    version = '1.1',
    author = 'JawnGC',
}

register_option_int("level_selected", "Level number for shortcut door (1 to 32)", 1, 1, 32)
register_option_bool("checkpoints_disabled", "Disable checkpoints", false)

local level_sequence = require("LevelSequence/level_sequence")
local telescopes = require("Telescopes/telescopes")
local DIFFICULTY = require('difficulty')
local SIGN_TYPE = level_sequence.SIGN_TYPE
local save_state = require('save_state')
local horizontal_forcefields = require('horizontal_forcefields')
local olmec_pillars = require('olmec_pillars')
local blockchain_and_firebug = require("blockchain_and_firebug")

local update_continue_door_enabledness
local force_save
local save_data
local save_context

--Levels
local l1 = require("bone_blocks")
local l2 = require("push_blocks")
local l3 = require("powder_kegs")
local l4 = require("snakes")
local l5 = require("moles")
local l6 = require("lizards")
local l7 = require("arrow_traps")
local l8 = require("exam_1")

local l9 = require("falling_platforms")
local l10 = require("conveyor_belts")
local l11 = require("robots")
local l12 = require("ropes")
local l13 = require("spikeballs")
local l14 = require("rockdogs")
local l15 = require("vlads_cape")
local l16 = require("exam_2")

local l17 = require("precision")
local l18 = require("damage_boosts")
local l19 = require("metal_arrows")
local l20 = require("climbing_gloves")
local l21 = require("sliding_walls")
local l22 = require("bubbles")
local l23 = require("flying_fish")
local l24 = require("exam_3")

local l25 = require("crush_traps")
local l26 = require("large_crush_traps")
local l27 = require("spring_traps")
local l28 = require("forcefields")
local l29 = require("landmines")
local l30 = require("pipes")
local l31 = require("egg_sacs")
local l32 = require("final_exam")

local ending = require("ending")

--Set level order
levels = {l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15, l16, l17, l18, l19, l20, l21, l22, l23, l24, l25, l26, l27, l28, l29, l30, l31, l32, ending}
level_sequence.set_levels(levels)

--Do not spawn Ghost
set_time_ghost_enabled(false)

local create_stats = require('stats')
local function create_saved_run()
	return {
		has_saved_run = false,
		saved_run_attempts = nil,
		saved_run_time = nil,
		saved_run_level = nil,
	}
end

local game_state = {
	difficulty = DIFFICULTY.NORMAL,
	stats = create_stats(),
	normal_saved_run = create_saved_run(),
}

local continue_door

function update_continue_door_enabledness()
	if not continue_door then return end
	local current_saved_run = game_state.normal_saved_run
	continue_door.update_door(current_saved_run.saved_run_level, current_saved_run.saved_run_attempts, current_saved_run.saved_run_time)
end

-- "Continue Run" Door
define_tile_code("continue_run")
local function continue_run_callback()
	return set_pre_tile_code_callback(function(x, y, layer)
		continue_door = level_sequence.spawn_continue_door(
			x,
			y,
			layer,
			game_state.normal_saved_run.saved_run_level,
			game_state.normal_saved_run.saved_run_attempts,
			game_state.normal_saved_run.saved_run_time,
			SIGN_TYPE.RIGHT)
		return true
	end, "continue_run")
end

-- Tile Codes for Shortcuts
define_tile_code("shortcuts")
local function shortcut_callback()
	return set_pre_tile_code_callback(function(x, y, layer)
		if options.level_selected < 1 then
			options.level_selected = 1
		elseif options.level_selected > #levels - 1 then
			options.level_selected = #levels - 1
		end
		
		level_sequence.spawn_shortcut(x, y, layer, levels[options.level_selected], SIGN_TYPE.RIGHT)
		return true
	end, "shortcuts")
end

define_tile_code("large_pushblock")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x+0.5, y, layer, 0, 0)
	local block = get_entity(block_id)
	block.hitboxx = block.hitboxx * 2
	block.hitboxy = block.hitboxy * 2
	block.width = block.width * 2
	block.height = block.height * 2
	return true
end, "large_pushblock")

define_tile_code("m_arrow")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_METAL_ARROW, x, y, layer, 0, 0)
	return true
end, "m_arrow")

define_tile_code("floating_firebug")
set_pre_tile_code_callback(function(x, y, layer)
	local bug_id = spawn(ENT_TYPE.MONS_FIREBUG_UNCHAINED, x, y, layer, 0, 0)
	local bug = get_entity(bug_id)
	bug.flags = set_flag(bug.flags, ENT_FLAG.FACING_LEFT)
	bug.user_data = {x = x, y = y}
	
	if bug ~= nil then
		bug:set_post_update_state_machine(function(self)
			bug.x = bug.user_data.x
			bug.y = bug.user_data.y
		end)
	end
	
	return true
end, "floating_firebug")

define_tile_code("skelekey")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_PICKUP_SKELETON_KEY, x, y, layer, 0, 0)
	return true
end, "skelekey")

define_tile_code("climbers")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES, x, y, layer, 0, 0)		
	return true
end, "climbers")

level_sequence.set_on_win(function(attempts, total_time)
	local frames = total_time
	local hours = 0
	local minutes = 0
	local seconds = 0
	local milliseconds = 0
	
	hours = frames // 216000
	frames = frames - (hours * 216000)
	
	minutes = frames // 3600
	frames = frames - (minutes * 3600)
	
	seconds = frames // 60
	frames = frames - (seconds * 60)
	
	milliseconds = math.floor(frames * 16.667)

	--print("Total Deaths: " .. tostring(attempts - 1))
	print("Total Time: " .. hours .. "h " .. minutes .. "m " .. seconds .. "s " .. milliseconds .. "ms")
	warp(1, 1, THEME.BASE_CAMP)
end)

--Dark Level stuff
set_callback(function()
	if state.theme == THEME.BASE_CAMP then
		state.level_flags = clr_flag(state.level_flags, 18)
	else	
		state.level_flags = clr_flag(state.level_flags, 18)
	end	
end, ON.POST_ROOM_GENERATION)

set_post_entity_spawn(function(entity) 
	entity.flags = clr_flag(entity.flags, 22) 
end, SPAWN_TYPE.ANY, MASK.ITEM, nil)

set_callback(function()
    if state.loading == 1 and state.screen_next == SCREEN.TRANSITION then
        for _, p in ipairs(players) do
            for _, v in ipairs(p:get_powerups()) do
                p:remove_powerup(v)
            end
        end
    end
end, ON.LOADING)

--Remove resources from the player and set health to 1
--Remove held item from the player
level_sequence.set_on_post_level_generation(function(level)
	if #players == 0 then return end
	
	players[1].inventory.bombs = 0
	players[1].inventory.ropes = 0
	players[1].health = 1
	
	if players[1].holding_uid ~= -1 then
		players[1]:get_held_entity():destroy()
	end
end)

level_sequence.set_on_completed_level(function(completed_level, next_level)
	if not next_level then return end

	local current_stats = game_state.stats
	local best_level_index = level_sequence.index_of_level(current_stats.best_level)
	local current_level_index = level_sequence.index_of_level(next_level)

	if (not best_level_index or current_level_index > best_level_index) and
			not level_sequence.took_shortcut() then
				current_stats.best_level = next_level
	end
end)

-- Manage saving data and keeping the time in sync during level transitions and resets.
function save_data()
	if save_context then
		force_save(save_context)
	end
end

function save_current_run_stats()
	local run_state = level_sequence.get_run_state()
	-- Save the current run
	if state.theme ~= THEME.BASE_CAMP and
		level_sequence.run_in_progress() then
		local saved_run = game_state.normal_saved_run
		saved_run.saved_run_attempts = run_state.attempts
		saved_run.saved_run_level = run_state.current_level
		saved_run.saved_run_time = run_state.total_time
		saved_run.has_saved_run = true
	end
end

function save_current_run_stats2()
	local run_state = level_sequence.get_run_state()
	-- Save the current run
	if state.theme ~= THEME.BASE_CAMP and
		level_sequence.run_in_progress() then
		local saved_run = game_state.normal_saved_run
		saved_run.saved_run_level = run_state.current_level
		saved_run.has_saved_run = true
	end
end

-- Saves the current state of the run so that it can be continued later if exited.
local function save_current_run_stats_callback()
	return set_callback(function()
		save_current_run_stats()
	end, ON.FRAME)
end

local function save_current_run_stats_callback2()
	return set_callback(function()
		save_current_run_stats2()
	end, ON.TRANSITION)
end

local function clear_variables_callback()
	return set_callback(function()
		continue_door = nil
	end, ON.PRE_LOAD_LEVEL_FILES)
end

set_callback(function(ctx)
	game_state = save_state.load(game_state, level_sequence, ctx)
end, ON.LOAD)

function force_save(ctx)
	save_state.save(game_state, level_sequence, ctx)
end

local function on_save_callback()
	return set_callback(function(ctx)
		save_context = ctx
		force_save(ctx)
	end, ON.SAVE)
end

local active = false
local callbacks = {}

local function activate()
	if active then return end
	active = true
	level_sequence.activate()

	local function add_callback(callback_id)
		callbacks[#callbacks+1] = callback_id
	end

	add_callback(continue_run_callback())
	add_callback(shortcut_callback())
	add_callback(clear_variables_callback())
	add_callback(on_save_callback())
	add_callback(save_current_run_stats_callback())
	add_callback(save_current_run_stats_callback2())
end

set_callback(function()
    activate()
end, ON.LOAD)

set_callback(function()
    activate()
end, ON.SCRIPT_ENABLE)

set_callback(function()
    if not active then return end
	active = false
	level_sequence.deactivate()

	for _, callback in pairs(callbacks) do
		clear_callback(callback)
	end

	callbacks = {}

end, ON.SCRIPT_DISABLE)

--Instant Restart on death
set_callback(function()
	if state.screen ~= 12 then
		return
	end

	local health = 0
	for i = 1,#players do
		health = health + players[i].health
	end

	if health == 0 then
		state.quest_flags = set_flag(state.quest_flags, 1)
		warp(state.world_start, state.level_start, state.theme_start)
	end
end, ON.FRAME)