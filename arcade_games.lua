-- TO-DO: Add more games
local arcade_games_tab = gui.get_tab("Arcade Games")

local ggsm_tab = arcade_games_tab:add_tab("Go Go Space Monkey 3")

local GGSM_DATA = 705

local GGSM_POWERUPS = { 44, 49, 50, 53, 54 }
local GGSM_WEAPONS  = {
    "Default", "Beam", "Cone Spread", "Laser", "Shot", "Shot Rapid", "Spread", 
    "Timed Spread", "Enemy Vulcan", "Cluster Bomb", "Fruit Bowl", "Granana Glasses", 
    "Granana Glasses 2", "Granana Hair", "Granana Spread", "Granana Spread 2", 
    "Exp Shell", "Player Vulcan", "Scatter", "Homing Rocket", "Dual Arch", 
    "Wave Blaster", "Back Vulcan", "Bread Spread", "Smooth IE Spread", 
    "Smooth IE Vulcan", "Dank Cannon", "Dank Rocket", "Dank Homing Rocket", 
    "Dank Scatter", "Dank Spread", "Dank Cluster Bomb", "Acid", "Acid Vulkan", 
    "Marine Launcher", "Marine Spread", "Test Weapon"
}
local GGSM_SECTORS = {
    "Earth (Unused)", "Ocyans Belt", "The Pink Ring", "Yellow Clam", "Doughball", 
    "That's No Banana", "Boss Rush (Debug)", "Boss Test (Debug)"
}

local ggsm_player_index       = 1
local ggsm_lives              = 0
local ggsm_score              = 0
local ggsm_kills              = 0
local ggsm_powerups_collected = 0
local ggsm_pos                = vec3:new(0, 0, 0)
local ggsm_time_played        = ""

local ggsm_selected_lives  = 0
local ggsm_selected_score  = 0
local ggsm_selected_weapon = 0
local ggsm_selected_power  = 0
local ggsm_selected_slot   = 0
local ggsm_selected_sector = 1
local ggsm_godmode         = false

local sp_patch = scr_patch:new("ggsm_arcade", "GGSM Allow in SP", "56 ? ? 5D ? ? ? 55 ? ? 5D ? ? ? 4F", 0, { 0x2B, 0x00, 0x00 })

local function START_GAME(script_name)
    script.run_in_fiber(function(script)
        if SCRIPT.DOES_SCRIPT_EXIST(script_name) then
            while not SCRIPT.HAS_SCRIPT_LOADED(script_name) do
                SCRIPT.REQUEST_SCRIPT(script_name)
                script:yield()
            end
            local thread = SYSTEM.START_NEW_SCRIPT(script_name, 8344) -- SCRIPT_XML
            SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(script_name)
            if thread == 0 then
                gui.show_error("Arcade Games", "Failed to start game.")
            end
        end
    end)
end

local function GGSM_CLEANUP()
    ggsm_selected_lives  = 0
    ggsm_selected_score  = 0
    ggsm_selected_weapon = 0
    ggsm_selected_power  = 0
    ggsm_selected_slot   = 0
    ggsm_selected_sector = 1
    ggsm_godmode         = false
end

local function GGSM_GET_TIME_PLAYED()
    local time_played = (MISC.GET_GAME_TIMER() - locals.get_int("ggsm_arcade", GGSM_DATA + 4572 + 6))
    local ms_to_sec   = math.floor(time_played / 1000)
    local minutes     = math.floor((ms_to_sec % 3600) / 60)
    local seconds     = ms_to_sec % 60
    return string.format("%02d:%02d", minutes, seconds)
end

local function GGSM_LOOP()
    if not script.is_active("ggsm_arcade") then
        return
    end
    
    ggsm_player_index       = locals.get_int("ggsm_arcade", GGSM_DATA + 2680) -- Changes when you die
    ggsm_lives              = locals.get_int("ggsm_arcade", GGSM_DATA + 4583)
    ggsm_score              = locals.get_int("ggsm_arcade", GGSM_DATA + 4572 + 7)
    ggsm_kills              = locals.get_int("ggsm_arcade", GGSM_DATA + 4572 + 5)
    ggsm_powerups_collected = locals.get_int("ggsm_arcade", GGSM_DATA + 4572 + 4)
    ggsm_time_played        = GGSM_GET_TIME_PLAYED()    
    ggsm_pos                = locals.get_vec3("ggsm_arcade", GGSM_DATA + 484 + (1 + (ggsm_player_index * 56)) + 7)
    
    if ggsm_godmode then
        locals.set_int("ggsm_arcade", GGSM_DATA + 484 + (1 + (ggsm_player_index * 56)) + 23, 4)
    end
end

script.register_looped("Arcade Games", function()
    GGSM_LOOP()
end)

ggsm_tab:add_imgui(function()
    if not script.is_active("ggsm_arcade") then
        GGSM_CLEANUP()
        ImGui.Text("Game is not running.")
        if ImGui.Button("Start Game") then
            START_GAME("ggsm_arcade")
        end
        return
    end
    
    ImGui.SeparatorText("Self")
    
    ggsm_selected_lives, changed = ImGui.InputInt("Lives", ggsm_lives)    
    if changed then
        ggsm_lives = math.max(1, math.min(100, ggsm_selected_lives))
        locals.set_int("ggsm_arcade", GGSM_DATA + 4583, ggsm_lives)
    end

    ggsm_selected_score, changed = ImGui.InputInt("Score", ggsm_score)
    if changed then
        ggsm_score = math.max(0, math.min(9999999, ggsm_selected_score))
        locals.set_int("ggsm_arcade", GGSM_DATA + 4572 + 7, ggsm_score)
    end

    if ImGui.Button("Heal") then
        locals.set_int("ggsm_arcade", GGSM_DATA + 484 + (1 + (ggsm_player_index * 56)) + 23, 4)
    end

    ImGui.SameLine()

    if ImGui.Button("Stop Music") then
        script.run_in_fiber(function()
            AUDIO.TRIGGER_MUSIC_EVENT("ARCADE_SM_STOP")
        end)
    end
    
    ImGui.SameLine()
    
    ggsm_godmode = ImGui.Checkbox("God Mode", ggsm_godmode)
    
    ImGui.Text("Kills: " .. ggsm_kills)
    ImGui.Text("Power-Ups Collected: " .. ggsm_powerups_collected)
    ImGui.Text("Position: " .. string.format("%.2f", ggsm_pos.x) .. ", " .. string.format("%.2f", ggsm_pos.y))
    ImGui.Text("Time Played: " .. ggsm_time_played)

    ImGui.SeparatorText("Weapons")

    ggsm_selected_weapon = ImGui.Combo("Weapons", ggsm_selected_weapon, GGSM_WEAPONS, #GGSM_WEAPONS)

    if ImGui.Button("Select Weapon") then
        locals.set_int("ggsm_arcade", GGSM_DATA + 484 + (1 + (ggsm_player_index * 56)) + 48, ggsm_selected_weapon + 1)
    end

    ImGui.SeparatorText("Power-Ups")

    ggsm_selected_power = ImGui.Combo("Power-Ups", ggsm_selected_power, {"Decoy", "Nuke", "Repulse", "Shield", "Stun"}, 5)
    ggsm_selected_slot  = ImGui.Combo("Slot", ggsm_selected_slot, {"Defense", "Special"}, 2)

    if ImGui.Button("Select Power-Up") then
        locals.set_int("ggsm_arcade", GGSM_DATA + 2811 + (ggsm_selected_slot + 1), GGSM_POWERUPS[ggsm_selected_power + 1])
    end

    ImGui.SeparatorText("Sectors")

    ggsm_selected_sector = ImGui.Combo("Sectors", ggsm_selected_sector, GGSM_SECTORS, #GGSM_SECTORS)

    if ImGui.Button("Select Sector") then
        locals.set_int("ggsm_arcade", GGSM_DATA + 4572 + 3, ggsm_selected_sector)
    end    
end)