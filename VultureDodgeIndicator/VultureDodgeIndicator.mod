return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`VultureDodgeIndicator` encountered an error loading the Darktide Mod Framework.")

        new_mod("VultureDodgeIndicator", {
            mod_script = "VultureDodgeIndicator/scripts/mods/VultureDodgeIndicator/VultureDodgeIndicator",
            mod_data = "VultureDodgeIndicator/scripts/mods/VultureDodgeIndicator/VultureDodgeIndicator_data",
            mod_localization = "VultureDodgeIndicator/scripts/mods/VultureDodgeIndicator/VultureDodgeIndicator_localization",
        })
    end,
    packages = {},
}