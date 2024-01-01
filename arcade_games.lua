require("ggsm")

arcade_games_tab = gui.get_tab("Arcade Games")

ggsm_tab = arcade_games_tab:add_tab("Go Go Space Monkey 3")

function is_script_active(script_name)
	return SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(joaat(script_name)) ~= 0
end

ggsm_tab:add_imgui(function (script)
	if is_script_active("ggsm_arcade") then
		render_ggsm()
	else
		ggsm_godmode = false
		ggsm_selected_weapon = 0
		ggsm_selected_power = 0
		ggsm_selected_slot = 0
		ggsm_selected_sector = 0
		ImGui.Text("Game is not running.")
	end
end)