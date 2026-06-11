local checkpoints = require("Checkpoints/checkpoints")

local level_var = {
    identifier = "final_exam",
    title = "Final Exam",
    theme = THEME.SUNKEN_CITY,
    world = 4,
	level = 8,
	width = 8,
    height = 4,
    file_name = "final_exam.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

level_var.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true
	
	replace_drop(DROP.EGGSAC_GRUB_1, ENT_TYPE.ITEM_BLOOD)
	replace_drop(DROP.EGGSAC_GRUB_2, ENT_TYPE.ITEM_BLOOD)
	replace_drop(DROP.EGGSAC_GRUB_3, ENT_TYPE.ITEM_BLOOD)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_PICKUP_SKELETON_KEY)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_SKELETON)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_SKULL)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_BONES)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_GENERIC)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_DUAT)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_THORN_VINE)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_CONVEYORBELT_LEFT)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_CONVEYORBELT_RIGHT)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_SNAKE)
	
	define_tile_code("sticky_trap_connected")
	local traps_uids = {}
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		traps_uids[#traps_uids + 1] = spawn_grid_entity(ENT_TYPE.FLOOR_STICKYTRAP_CEILING, x, y, layer)
		return true
	end, "sticky_trap_connected")

	local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		for i = 1,#traps_uids do
			local ent = get_entity(traps_uids[i])
			
			if ent.state == 1 then
				for j = 1,#traps_uids do
					if i ~= j then
						local other_ent = get_entity(traps_uids[j])
						other_ent.state = 1
					end
				end
			end
		end
        frames = frames + 1
    end, ON.FRAME)
	
	if not options.checkpoints_disabled then
		checkpoints.activate()
	end
	
	toast(level_var.title)
	
end

level_var.unload_level = function()
    if not level_state.loaded then return end
    
	checkpoints.deactivate()
	replace_drop(DROP.EGGSAC_GRUB_1, ENT_TYPE.MONS_GRUB)
	replace_drop(DROP.EGGSAC_GRUB_2, ENT_TYPE.MONS_GRUB)
	replace_drop(DROP.EGGSAC_GRUB_3, ENT_TYPE.MONS_GRUB)
	
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return level_var
