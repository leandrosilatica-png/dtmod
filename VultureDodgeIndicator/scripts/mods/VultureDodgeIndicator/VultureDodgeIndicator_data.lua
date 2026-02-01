local mod = get_mod("VultureDodgeIndicator")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
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
        },
    },
}