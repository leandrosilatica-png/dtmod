local mod = get_mod("VultureDodgeIndicator")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local BUFF_TEMPLATE_NAME = "broker_vultures_mark_dodge_on_ranged_crit_dodge_buff"
local ACTIVE_COLOR = { 255, 0, 255, 0 }
local INACTIVE_COLOR = { 255, 255, 64, 64 }

local indicator_text_style = table.clone(UIFontSettings.body)
indicator_text_style.text_horizontal_alignment = "center"
indicator_text_style.text_vertical_alignment = "center"
indicator_text_style.horizontal_alignment = "center"
indicator_text_style.vertical_alignment = "center"
indicator_text_style.size = { 400, 40 }
indicator_text_style.offset = { 0, 0, 10 }
indicator_text_style.text_color = INACTIVE_COLOR

local ui_definitions = {
    scenegraph_definition = {
        screen = UIWorkspaceSettings.screen,
        indicator = {
            parent = "screen",
            vertical_alignment = "center",
            horizontal_alignment = "center",
            size = { 400, 40 },
            position = { 0, 0, 0 },
        },
    },
    widget_definitions = {
        indicator = UIWidget.create_definition({
            {
                pass_type = "text",
                value_id = "text",
                style_id = "text",
                value = "",
                style = indicator_text_style,
            },
        }, "indicator"),
    },
}

local HudElementVultureDodgeIndicator = class("HudElementVultureDodgeIndicator", "HudElementBase")

HudElementVultureDodgeIndicator.init = function(self, parent, draw_layer, start_scale)
    HudElementVultureDodgeIndicator.super.init(self, parent, draw_layer, start_scale, ui_definitions)
    mod._hud_element = self
    self:update_settings()
    self:_update_indicator()
end

HudElementVultureDodgeIndicator.destroy = function(self)
    if mod._hud_element == self then
        mod._hud_element = nil
    end

    HudElementVultureDodgeIndicator.super.destroy(self)
end

function HudElementVultureDodgeIndicator:_is_in_hub()
    local game_mode_manager = Managers.state and Managers.state.game_mode
    if not game_mode_manager then
        return false
    end

    local game_mode_name = game_mode_manager:game_mode_name()
    if not game_mode_name then
        return false
    end

    return string.find(game_mode_name, "hub") ~= nil
end

function HudElementVultureDodgeIndicator:_is_buff_active()
    local player = Managers.player and Managers.player:local_player(1)
    local player_unit = player and player.player_unit

    if not player_unit then
        return false
    end

    local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
    if not buff_extension or not buff_extension.has_buff_using_buff_template then
        return false
    end

    return buff_extension:has_buff_using_buff_template(BUFF_TEMPLATE_NAME)
end

function HudElementVultureDodgeIndicator:_update_indicator()
    local widget = self._widgets_by_name.indicator
    if not widget then
        return
    end

    local is_active = self:_is_buff_active()
    local show = mod:is_enabled() and ((is_active and mod:get("show_active")) or (not is_active and mod:get("show_inactive")))

    if not mod:get("show_in_hub") and self:_is_in_hub() then
        show = false
    end

    widget.visible = show
    widget.content.text = mod:localize(is_active and "indicator_active" or "indicator_inactive")
    widget.style.text.text_color = is_active and ACTIVE_COLOR or INACTIVE_COLOR
end

function HudElementVultureDodgeIndicator:update_settings()
    local widget = self._widgets_by_name.indicator
    if not widget then
        return
    end

    local style = widget.style.text
    local font_size = mod:get("font_size") or 26

    style.font_size = font_size
    style.size[2] = math.max(20, font_size + 6)
    style.offset[1] = mod:get("offset_x") or 0
    style.offset[2] = mod:get("offset_y") or -200
end

HudElementVultureDodgeIndicator.draw = function(self, dt, t, ui_renderer, render_settings, input_service)
    self:_update_indicator()
    HudElementVultureDodgeIndicator.super.draw(self, dt, t, ui_renderer, render_settings, input_service)
end

return HudElementVultureDodgeIndicator
