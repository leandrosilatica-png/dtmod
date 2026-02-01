local mod = get_mod("VultureDodgeIndicator")

local HUD_ELEMENT_CLASS = "HudElementVultureDodgeIndicator"
local HUD_ELEMENT_FILENAME = "VultureDodgeIndicator/scripts/mods/VultureDodgeIndicator/HudElementVultureDodgeIndicator"

mod:add_require_path(HUD_ELEMENT_FILENAME)

local hud_element_definition = {
    package = "packages/ui/views/inventory_background_view/inventory_background_view",
    use_hud_scale = true,
    class_name = HUD_ELEMENT_CLASS,
    filename = HUD_ELEMENT_FILENAME,
    visibility_groups = {
        "alive",
        "communication_wheel",
        "tactical_overlay",
    },
}

local _add_hud_element = function(element_pool)
    local found_key, _ = table.find_by_key(element_pool, "class_name", HUD_ELEMENT_CLASS)
    if found_key then
        element_pool[found_key] = hud_element_definition
    else
        table.insert(element_pool, hud_element_definition)
    end
end

mod:hook_require("scripts/ui/hud/hud_elements_player_onboarding", _add_hud_element)
mod:hook_require("scripts/ui/hud/hud_elements_player", _add_hud_element)

mod.on_setting_changed = function()
    local element = mod._hud_element
    if element and element.update_settings then
        element:update_settings()
    end
end
