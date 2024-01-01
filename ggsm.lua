local GGSMData = 703
local GameStats = 4572
local Entities = 484
local WeaponSlot = 2811
local PlayerLives = 4583
local score = 7
local kills = 5
local powerUps = 4
local timePlayed = 6
local Position = 7
local WeaponType = 48
local PlayerShipIndex = 1
local HP = 23
local MaxHP = 4

local GGSM_POWERUPS = {
	44, -- GGSM_SPRITE_POWER_UP_DECOY
	49, -- GGSM_SPRITE_POWER_UP_NUKE
	50, -- GGSM_SPRITE_POWER_UP_REPULSE
	53, -- GGSM_SPRITE_POWER_UP_SHIELD
	54  -- GGSM_SPRITE_POWER_UP_STUN
}

local ggsm_lives
local ggsm_score
local ggsm_kills
local ggsm_powerups_collected
local ggsm_time_played
local ggsm_pos

ggsm_godmode = false
ggsm_selected_weapon = 0
ggsm_selected_power = 0
ggsm_selected_slot = 0
ggsm_selected_sector = 0

function ggsm_get_time_played()
    local ggsm_time_played = (MISC.GET_GAME_TIMER() - locals.get_int("ggsm_arcade", GGSMData + GameStats + timePlayed))
    local seconds = math.floor(ggsm_time_played / 1000)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remaining_seconds = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, remaining_seconds)
end

script.register_looped("GGSM", function (script)
	PlayerShipIndex = (1 + (locals.get_int("ggsm_arcade", 703 + 2680) * 56)) -- changes when you die
	ggsm_lives = locals.get_int("ggsm_arcade", GGSMData + PlayerLives)
	ggsm_score = locals.get_int("ggsm_arcade", GGSMData + GameStats + score)
	ggsm_kills = locals.get_int("ggsm_arcade", GGSMData + GameStats + kills)
	ggsm_powerups_collected = locals.get_int("ggsm_arcade", GGSMData + GameStats + powerUps)
	ggsm_pos = locals.get_vec3("ggsm_arcade", GGSMData + Entities + PlayerShipIndex + Position)
	ggsm_time_played = ggsm_get_time_played()	
	if ggsm_godmode then
		locals.set_int("ggsm_arcade", GGSMData + Entities + PlayerShipIndex + HP, MaxHP)
	end
end)

function render_ggsm()
    local new_lives, changed = ImGui.InputInt("Lives", ggsm_lives)
	
    if changed then
        ggsm_lives = math.max(1, math.min(100, new_lives))
        locals.set_int("ggsm_arcade", GGSMData + PlayerLives, ggsm_lives)
    end
	
	local new_score, changed = ImGui.InputInt("Score", ggsm_score)
	
	if changed then
        ggsm_score = math.max(0, math.min(9999999, new_score))
        locals.set_int("ggsm_arcade", GGSMData + GameStats + score, ggsm_score)
    end
	
	if ImGui.Button("Stop Music") then
		script.run_in_fiber(function (script)
			AUDIO.TRIGGER_MUSIC_EVENT("ARCADE_SM_STOP")
		end)
	end
	
	ImGui.SameLine()
	
	if ImGui.Button("Heal") then
		locals.set_int("ggsm_arcade", GGSMData + Entities + PlayerShipIndex + HP, MaxHP)
	end
	
	ggsm_godmode = ImGui.Checkbox("God Mode", ggsm_godmode)
	
	ImGui.Separator()
	
	ImGui.Text("Kills: " .. ggsm_kills)
	ImGui.Text("Power-Ups Collected: " .. ggsm_powerups_collected)
	ImGui.Text("Time Played: " .. ggsm_time_played)
	ImGui.Text("Position: " .. string.format("%.2f", ggsm_pos.x) .. ", " .. string.format("%.2f", ggsm_pos.y))
	
	ImGui.Separator()
	
	ImGui.Text("Weapons")
	
	ggsm_selected_weapon = ImGui.Combo("Weapons", ggsm_selected_weapon, { "Default", "Beam", "Cone Spread", "Laser", "Shot", "Shot Rapid", "Spread", "Timed Spread", "Enemy Vulcan", "Cluster Bomb", "Fruit Bowl", "Granana Glasses", "Granana Glasses 2", "Granana Hair", "Granana Spread", "Granana Spread 2", "Exp Shell", "Player Vulcan", "Scatter", "Homing Rocket", "Dual Arch", "Wave Blaster", "Back Vulcan", "Bread Spread", "Smooth IE Spread", "Smooth IE Vulcan", "Dank Cannon", "Dank Rocket", "Dank Homing Rocket", "Dank Scatter", "Dank Spread", "Dank Cluster Bomb", "Acid", "Acid Vulkan", "Marine Launcher", "Marine Spread", "Test Weapon", }, 37)
	
	if ImGui.Button("Select Weapon") then
		locals.set_int("ggsm_arcade", GGSMData + Entities + PlayerShipIndex + WeaponType, ggsm_selected_weapon + 1)
	end
	
	ImGui.Separator()
	
	ImGui.Text("Power-Ups")
	
	ggsm_selected_power = ImGui.Combo("Power-Ups", ggsm_selected_power, { "Decoy", "Nuke", "Repulse", "Shield", "Stun" }, 5)	
	ggsm_selected_slot = ImGui.Combo("Slot", ggsm_selected_slot, { "Defense", "Special" }, 2)
	
	if ImGui.Button("Select Power-Up") then
		locals.set_int("ggsm_arcade", GGSMData + WeaponSlot + (ggsm_selected_slot + 1), GGSM_POWERUPS[ggsm_selected_power + 1])
	end
	
	ImGui.Separator()
	
	ImGui.Text("Sectors")
	
	ggsm_selected_sector = ImGui.Combo("Sectors", ggsm_selected_sector, { "Earth", "Asteroid Belt", "Pink Ring", "Yellow Clam", "Dough Ball", "Banana Star", "Boss Rush", "Boss Test" }, 8)
	
	if ImGui.Button("Select Sector") then
		locals.set_int("ggsm_arcade", GGSMData + GameStats + sector, ggsm_selected_sector)
	end
end