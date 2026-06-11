local checkpoints = require("Checkpoints/checkpoints")

local tidepool3 = {
    identifier = "exam_3",
    title = "Exam 3",
    theme = THEME.TIDE_POOL,
	world = 3,
	level = 8,
    width = 6,
    height = 4,
    file_name = "exam_3.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

tidepool3.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true

	replace_drop(DROP.ARROWTRAP_WOODENARROW, ENT_TYPE.ITEM_METAL_ARROW)

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
        -- Remove Hermitcrabs
        local x, y, layer = get_position(entity.uid)
        local floor = get_entities_at(0, MASK.ANY, x, y, layer, 1)
        if #floor > 0 then
            entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
            entity:destroy()
        end
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_HERMITCRAB)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_SKULL)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_THORN_VINE)

	define_tile_code("bubble")
	local bubble_xy = {}
	level_state.callbacks[#level_state.callbacks+1] = set_pre_tile_code_callback(function(x, y, layer)
		bubble_xy[#bubble_xy + 1] = {x,y}
		return true
	end, "bubble")

	define_tile_code("bl_switch")
	set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn_grid_entity(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH_REWARD, x, y, layer)
		local switch = get_entity(block_id)
		switch.user_data = {x = x, y = y}
		
	    set_on_damage(block_id, function(self)
            if self.timer > 0 then return end
            self.timer = 90
            self.animation_frame = self.animation_frame == 86 and 96 or 86
            local rsx, rsy = get_room_index(self.user_data.x, self.user_data.y)
			
			local slidingwalls = get_entities_by_type(ENT_TYPE.FLOOR_SLIDINGWALL_CEILING)
			
            if #slidingwalls == 0 then return end
			
			for i = 1,#slidingwalls do
				local wx, wy, _ = get_position(slidingwalls[i])
				local rwx, rwy = get_room_index(wx, wy)
				local slidingwall = get_entity(slidingwalls[i])
				local wx, wy = get
				if rsx == rwx and rsy == rwy then
					slidingwall.state = slidingwall.state == 1 and 0 or 1
				end
			end
        end)
		return true
	end, "bl_switch")

	local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		if frames % 150 == 0 then
			for i = 1,#bubble_xy do
				spawn(ENT_TYPE.ACTIVEFLOOR_BUBBLE_PLATFORM, bubble_xy[i][1], bubble_xy[i][2], 0, 0, 0)
			end
		end
        frames = frames + 1
    end, ON.FRAME)

	if not options.checkpoints_disabled then
		checkpoints.activate()
	end

	toast(tidepool3.title)
end

tidepool3.unload_level = function()
    if not level_state.loaded then return end
   
	checkpoints.deactivate()
	replace_drop(DROP.ARROWTRAP_WOODENARROW, ENT_TYPE.ITEM_WOODEN_ARROW)
	
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return tidepool3