--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

--###################
--################### OCELOT AND CAT
--###################

local pr = PseudoRandom(os.time()*12)

local default_walk_chance = 70
local cat_textures = {{"mobs_mc_cat_black.png"}, {"mobs_mc_cat_red.png"}, {"mobs_mc_cat_siamese.png"}}

-- Returns true if the item is food (taming) for the cat/ocelot
local is_food = function(itemstring)
	for f=1, #mobs_mc.follow.ocelot do
		if itemstring == mobs_mc.follow.ocelot[f] then
			return true
		elseif string.sub(itemstring, 1, 6) == "group:" and minetest.get_item_group(itemstring, string.sub(itemstring, 7, -1)) ~= 0 then
			return true
		end
	end
end

-- Ocelot
local ocelot = {
	type = "animal",
	hp_min = 10,
	hp_max = 10,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.69, 0.3},
	rotate = -180,
	visual = "mesh",
	mesh = "mobs_mc_cat.b3d",
	textures = {"mobs_mc_cat_ocelot.png"},
	visual_size = {x=2.0, y=2.0},
	makes_footstep_sound = true,
	walk_chance = default_walk_chance,
	walk_velocity = 1,
	run_velocity = 3,
	drawtype = "front",
	floats = 1,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 4,
	sounds = {
		random = "mobs_kitten",
		distance = 16,
	},
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	follow = mobs_mc.follow.ocelot,
	view_range = 12,
	passive = false,
	attack_type = "dogfight",
	pathfinding = 1,
	damage = 2,
	attack_animals = true,
	specific_attack = { "mobs_mc:chicken" },
	on_rightclick = function(self, clicker)
		-- Try to tame ocelot
		local item = clicker:get_wielded_item()
		if is_food(item:get_name()) then
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			-- 1/3 chance of getting tamed
			if pr:next(1, 3) == 1 then
				local yaw = self.object:get_yaw()
				local cat = minetest.add_entity(self.object:getpos(), "mobs_mc:cat")
				cat:set_yaw(yaw)
				local ent = cat:get_luaentity()
				ent.owner = clicker:get_player_name()
				ent.tamed = true
				ent.base_texture = cat_textures[pr:next(1, #cat_textures)]
				cat:set_properties({textures = ent.base_texture})
				self.object:remove()
			end
		end

		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 30, 50, 80, false, nil) then return end
	end,
}

mobs:register_mob("mobs_mc:ocelot", ocelot)

-- Cat
local cat = table.copy(ocelot)
cat.textures = cat_textures
cat.owner = ""
cat.order = "roam" -- "sit" or "roam"
cat.owner_loyal = true
cat.tamed = true
cat.on_rightclick = function(self, clicker)
	if mobs:feed_tame(self, clicker, 1, true, false) then
		return
	end

	-- Toggle sitting order

	if not self.owner or self.owner == "" then
		-- Huh? This cat has no owner? Let's fix this! This should never happen.
		self.owner = clicker:get_player_name()
	end

	if not self.order or self.order == "" or self.order == "sit" then
		self.order = "roam"
		self.walk_chance = default_walk_chance
		self.jump = true
	else
		-- “Sit!”
		-- TODO: Add sitting model
		self.order = "sit"
		self.walk_chance = 0
		self.jump = false
	end

	if mobs:protect(self, clicker) then return end
end

mobs:register_mob("mobs_mc:cat", cat)


-- Spawn
-- TODO: Increase spawn chance if polished
mobs:register_spawn("mobs_mc:ocelot", mobs_mc.spawn.jungle, minetest.LIGHT_MAX+1, 0, 20000, 2, 31000)

-- compatibility
mobs:alias_mob("mobs:kitten", "mobs_mc:ocelot")

-- spawn eggs
mobs:register_egg("mobs_mc:ocelot", "Ocelot", "mobs_mc_spawn_icon_cat.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Ocelot loaded")
end
