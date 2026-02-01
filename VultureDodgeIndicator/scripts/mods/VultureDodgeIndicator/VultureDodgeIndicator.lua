local mod = get_mod("VultureDodgeIndicator")

local HUD_ELEMENT_CLASS = "HudElementVultureDodgeIndicator"
local HUD_ELEMENT_FILENAME = "VultureDodgeIndicator/scripts/mods/VultureDodgeIndicator/HudElementVultureDodgeIndicator"

mod:add_require_path(HUD_ELEMENT_FILENAME)

-- Buff and keyword constants
local BUFF_TEMPLATE_NAME = "broker_vultures_mark_dodge_on_ranged_crit_dodge_buff"
local DODGE_KEYWORD_MELEE = "count_as_dodge_vs_melee"
local DODGE_KEYWORD_RANGED = "count_as_dodge_vs_ranged"

-- Experimental feature states (toggled by keybinds)
mod._experimental = {
    force_miss_enabled = false,
    zero_damage_enabled = false,
    inject_invuln_enabled = false,
    widen_cone_enabled = false,
}

-- Hit logging data
mod._hit_log = {}
mod._last_log_time = 0

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

-- Helper: Check if player has vulture dodge keyword active
local function _has_vulture_dodge_keyword(unit)
    if not unit then return false end
    local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
    if not buff_extension then return false end
    return buff_extension:has_keyword(DODGE_KEYWORD_MELEE) or buff_extension:has_keyword(DODGE_KEYWORD_RANGED)
end

-- Helper: Get local player unit
local function _get_local_player_unit()
    local player = Managers.player and Managers.player:local_player(1)
    return player and player.player_unit
end

-- Helper: Log a hit event
local function _log_hit_event(damage, attack_type, attacker_breed)
    if not mod:get("enable_hit_logging") then return end
    
    local t = Managers.time and Managers.time:time("gameplay") or 0
    local entry = {
        time = t,
        damage = damage,
        attack_type = attack_type or "unknown",
        attacker = attacker_breed or "unknown",
        had_vulture_dodge = _has_vulture_dodge_keyword(_get_local_player_unit()),
    }
    table.insert(mod._hit_log, entry)
    
    -- Keep only last 50 entries
    while #mod._hit_log > 50 do
        table.remove(mod._hit_log, 1)
    end
    
    -- Notification
    if entry.had_vulture_dodge and mod:get("notify_on_hit_while_active") then
        mod:notify("Hit while Vulture Dodge active! Dmg: " .. tostring(damage))
    end
end

-- ============================================================================
-- EXPERIMENTAL HOOK 2: Force Miss on _melee_hit (CLIENT-SIDE - MAY DESYNC)
-- ============================================================================
mod:hook_safe("MinionAttack", "_melee_hit", function(unit, breed, scratchpad, blackboard, target_unit, ...)
    if not mod._experimental.force_miss_enabled then return end
    
    local player_unit = _get_local_player_unit()
    if target_unit ~= player_unit then return end
    
    if _has_vulture_dodge_keyword(player_unit) then
        -- Log the attempted hit
        local breed_name = breed and breed.name or "unknown"
        _log_hit_event(0, "melee_blocked_by_mod", breed_name)
        
        -- NOTE: This hook_safe cannot actually prevent the hit, 
        -- but we log it. A true hook would need to return false.
    end
end)

-- ============================================================================
-- EXPERIMENTAL HOOK 3: Zero Damage on add_damage (CLIENT-SIDE - MAY DESYNC)
-- ============================================================================
mod:hook("PlayerUnitHealthExtension", "add_damage", function(func, self, damage_amount, permanent_damage, hit_actor, damage_profile, attack_type, attack_direction, attacking_unit)
    local player_unit = _get_local_player_unit()
    
    if mod._experimental.zero_damage_enabled and self._unit == player_unit then
        if _has_vulture_dodge_keyword(player_unit) and attack_type == "melee" then
            -- Log the blocked damage
            _log_hit_event(damage_amount, "damage_zeroed_by_mod", "unknown")
            
            if mod:get("show_experimental_notifications") then
                mod:notify("Experimental: Zeroed " .. tostring(damage_amount) .. " melee damage")
            end
            
            -- Zero out the damage
            return func(self, 0, 0, hit_actor, damage_profile, attack_type, attack_direction, attacking_unit)
        end
    end
    
    -- Normal damage path - log if vulture dodge was active
    if _has_vulture_dodge_keyword(player_unit) and self._unit == player_unit then
        _log_hit_event(damage_amount, attack_type, "unknown")
    end
    
    return func(self, damage_amount, permanent_damage, hit_actor, damage_profile, attack_type, attack_direction, attacking_unit)
end)

-- ============================================================================
-- EXPERIMENTAL HOOK 4: Inject Invulnerable Keyword (CLIENT-SIDE - MAY DESYNC)
-- ============================================================================
mod:hook("PlayerUnitHealthExtension", "is_invulnerable", function(func, self)
    if mod._experimental.inject_invuln_enabled then
        local player_unit = _get_local_player_unit()
        if self._unit == player_unit and _has_vulture_dodge_keyword(player_unit) then
            if mod:get("show_experimental_notifications") then
                -- Don't spam notifications, check time
                local t = Managers.time and Managers.time:time("gameplay") or 0
                if t - (mod._last_invuln_notify or 0) > 1 then
                    mod:notify("Experimental: Reporting invulnerable")
                    mod._last_invuln_notify = t
                end
            end
            return true
        end
    end
    return func(self)
end)

-- ============================================================================
-- EXPERIMENTAL HOOK 5: Widen Miss Cone (CLIENT-SIDE - Partial Effect)
-- ============================================================================
-- This hooks into the dodge reach cone calculation
mod:hook("Dodge", "is_dodging", function(func, unit, attack_type)
    local is_dodging, dodge_type = func(unit, attack_type)
    
    -- If already dodging and widen cone is enabled, we just return true
    -- The actual cone widening would need to hook _check_weapon_reach
    if mod._experimental.widen_cone_enabled then
        local player_unit = _get_local_player_unit()
        if unit == player_unit and _has_vulture_dodge_keyword(player_unit) then
            -- Force is_dodging to true with buff type
            return true, "buff"
        end
    end
    
    return is_dodging, dodge_type
end)

-- ============================================================================
-- KEYBIND HANDLERS
-- ============================================================================
mod.toggle_force_miss = function()
    mod._experimental.force_miss_enabled = not mod._experimental.force_miss_enabled
    local state = mod._experimental.force_miss_enabled and "ENABLED" or "DISABLED"
    mod:notify("Force Miss Hook: " .. state .. " (⚠️ May cause desync)")
end

mod.toggle_zero_damage = function()
    mod._experimental.zero_damage_enabled = not mod._experimental.zero_damage_enabled
    local state = mod._experimental.zero_damage_enabled and "ENABLED" or "DISABLED"
    mod:notify("Zero Damage Hook: " .. state .. " (⚠️ May cause desync)")
end

mod.toggle_inject_invuln = function()
    mod._experimental.inject_invuln_enabled = not mod._experimental.inject_invuln_enabled
    local state = mod._experimental.inject_invuln_enabled and "ENABLED" or "DISABLED"
    mod:notify("Inject Invulnerable: " .. state .. " (⚠️ May cause desync)")
end

mod.toggle_widen_cone = function()
    mod._experimental.widen_cone_enabled = not mod._experimental.widen_cone_enabled
    local state = mod._experimental.widen_cone_enabled and "ENABLED" or "DISABLED"
    mod:notify("Widen Cone Hook: " .. state .. " (⚠️ Partial client effect)")
end

mod.show_hit_log = function()
    mod:notify("=== Hit Log (last " .. tostring(#mod._hit_log) .. " entries) ===")
    for i = math.max(1, #mod._hit_log - 5), #mod._hit_log do
        local entry = mod._hit_log[i]
        if entry then
            local msg = string.format("[%.1f] %s: %d dmg | VD: %s", 
                entry.time, 
                entry.attack_type, 
                entry.damage,
                entry.had_vulture_dodge and "YES" or "NO"
            )
            mod:notify(msg)
        end
    end
end

mod.clear_hit_log = function()
    mod._hit_log = {}
    mod:notify("Hit log cleared")
end

-- ============================================================================
-- SETTINGS CHANGED HANDLER
-- ============================================================================
mod.on_setting_changed = function()
    local element = mod._hud_element
    if element and element.update_settings then
        element:update_settings()
    end
end

-- ============================================================================
-- MOD DISABLED HANDLER - Clean up experimental states
-- ============================================================================
mod.on_disabled = function()
    mod._experimental.force_miss_enabled = false
    mod._experimental.zero_damage_enabled = false
    mod._experimental.inject_invuln_enabled = false
    mod._experimental.widen_cone_enabled = false
end
