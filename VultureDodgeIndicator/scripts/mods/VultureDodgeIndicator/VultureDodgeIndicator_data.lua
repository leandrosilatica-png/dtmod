local mod = get_mod("VultureDodgeIndicator")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            -- Display Settings Group
            {
                setting_id = "display_settings_group",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "show_active",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "show_inactive",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "show_in_hub",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "font_size",
                        type = "numeric",
                        default_value = 26,
                        range = { 10, 64 },
                        decimals_number = 0,
                    },
                    {
                        setting_id = "offset_x",
                        type = "numeric",
                        default_value = 0,
                        range = { -1000, 1000 },
                        decimals_number = 0,
                    },
                    {
                        setting_id = "offset_y",
                        type = "numeric",
                        default_value = -200,
                        range = { -1000, 1000 },
                        decimals_number = 0,
                    },
                    {
                        setting_id = "show_detailed_stats",
                        type = "checkbox",
                        default_value = false,
                    },
                },
            },
            -- Hit Logging Settings Group
            {
                setting_id = "logging_settings_group",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_hit_logging",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "notify_on_hit_while_active",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "keybind_show_hit_log",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "show_hit_log",
                    },
                    {
                        setting_id = "keybind_clear_hit_log",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "clear_hit_log",
                    },
                },
            },
            -- Experimental Features Group (WARNING: May cause desync/TOS issues)
            {
                setting_id = "experimental_settings_group",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "show_experimental_notifications",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "keybind_toggle_force_miss",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "toggle_force_miss",
                    },
                    {
                        setting_id = "keybind_toggle_zero_damage",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "toggle_zero_damage",
                    },
                    {
                        setting_id = "keybind_toggle_inject_invuln",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "toggle_inject_invuln",
                    },
                    {
                        setting_id = "keybind_toggle_widen_cone",
                        type = "keybind",
                        default_value = {},
                        keybind_trigger = "pressed",
                        keybind_type = "function_call",
                        function_name = "toggle_widen_cone",
                    },
                },
            },
        },
    },
}