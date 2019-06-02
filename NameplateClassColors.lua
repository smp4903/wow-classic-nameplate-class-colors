-- NAMESPACE: NameplateClassColors
NameplateClassColors = {} 

-- STATE VARIABLES

local defaults = {
    ["playersOnly"] = true,
    ["enabled"] = true,
}

local loaded = false
local linkKey = "nameplateclasscolors"

-- INTERFACE
local NameplateClassColorsFrame = CreateFrame("Frame") -- Root frame

-- REGISTER EVENTS
NameplateClassColorsFrame:RegisterEvent("ADDON_LOADED")
NameplateClassColorsFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
NameplateClassColorsFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

-- REGISTER EVENT LISTENERS
NameplateClassColorsFrame:SetScript("OnEvent", function(self, event, arg1, ...) 
    if event == "ADDON_LOADED" then
        local addonName = arg1

        if addonName == "NameplateClassColors" then
            -- Initialize Settings
            NameplateClassColors_Options = NameplateClassColors_Options or defaults

            -- Print Information
            NameplateClassColorsFrame:PrintHelp()
            print("# ")
            NameplateClassColorsFrame:PrintOptions()

            -- Flag loaded for Nameplate Recoloring to begin
            loaded = true
        end
    end

    if event == "NAME_PLATE_UNIT_ADDED" then
        local unitID = arg1
        NameplateClassColorsFrame:AddNamePlate(unitID)
    end

    if event == "NAME_PLATE_UNIT_REMOVED"  then
        local unitID = arg1
        NameplateClassColorsFrame:RemoveNameplate(unitID)
    end 
end);

-- EVENT HANDLERS
function NameplateClassColorsFrame:AddNamePlate(unitId)
    if (not loaded) or (not NameplateClassColors_Options.enabled) then return end

    local localizedClass, englishClass, classIndex = UnitClass(unitId)
    local playerControlled = UnitPlayerControlled(unitId)

    local doRecolor = (not NameplateClassColors_Options.playersOnly) or (NameplateClassColors_Options.playersOnly and playerControlled)

    if doRecolor then
        local classColor = C_ClassColor.GetClassColor(englishClass)

        local nameplate = C_NamePlate.GetNamePlateForUnit(unitId)
        local unitframe = nameplate.UnitFrame
        local healthBar = unitframe.healthBar

        healthBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
        healthBar:GetStatusBarTexture():SetHorizTile(false)
        healthBar:GetStatusBarTexture():SetVertTile(false)
        healthBar:SetStatusBarColor(classColor:GetRGB())
    end
end


function NameplateClassColorsFrame:RemoveNameplate(unitId)
    if (not loaded) or (not NameplateClassColors_Options.enabled) then return end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unitId)
    local unitframe = nameplate.UnitFrame
    local healthBar = unitframe.healthBar
end

-- HELPERS
local function startsWith(text, prefix)
    print("looking for: "..prefix.. " in :"..text)

    return text:sub(1, #prefix) == prefix
end

function NameplateClassColorsFrame:PrintOptions()
    print("# Nameplate Class Colors -- Options")
    print("# ")
    print("#            "..NameplateClassColorsFrame:createChatLink("enabled", NameplateClassColors_Options.enabled))
    print("# ")
    print("#            "..NameplateClassColorsFrame:createChatLink("playersOnly", NameplateClassColors_Options.playersOnly))
    print("# ")
    print("# ----------------------------------")
end

function NameplateClassColorsFrame:createChatLink(option, value)
    local color1 = "f9a825"
    local color2 = "f9a825"
    local template = "\124cff"..color1.."\124H"..linkKey..":%s\124h%s (%s) - click to toggle\124h"

    local stringValue = ""

    if type(value) == "boolean" then
        if value then stringValue = "true" else stringValue = "false" end
    else
        stringValue = ""..value
    end

    return string.format(template, option, option, stringValue)
end

-- Create a local reference to the SetHyperLink function
local SetHyperlink = ItemRefTooltip.SetHyperlink

-- Then override it to intercept our Recount links
function ItemRefTooltip:SetHyperlink(link)
  -- If the link doesn't start with "recountlink", pass it on
  if not startsWith(link, linkKey) then
    SetHyperlink(self, link)
    return
  end

  local option = link:match(linkKey..":%a+.*")

  if not (option == nil) then
    local key = option:match(":%a+.*"):match("%a+.*")
    if not (key == nil) then
        NameplateClassColors_Options[key] = not NameplateClassColors_Options[key]
        ReloadUI()
    end
  end
  
end

-- COMMANDS
SLASH_FSR1 = '/ncc'; 
function SlashCmdList.FSR(msg, editbox)
    local cmd = string.lower(msg)

    if cmd == "" or cmd == "help" then
       PrintHelp()  
    end
    if cmd == "reset" then
        NameplateClassColors_Options.playersOnly = false
        ReloadUI();
    end
    if cmd == "enable" then
        NameplateClassColors_Options.enabled = true
        ReloadUI();
    end
    if cmd == "disable" then
        NameplateClassColors_Options.enabled = false
        ReloadUI();
    end
    if cmd == "options" then
        NameplateClassColorsFrame:PrintOptions()
    end
    if cmd == "players only" or cmd == "playersonly" then
        NameplateClassColors_Options.playersOnly = not NameplateClassColors_Options.playersOnly;
        ReloadUI();

        if NameplateClassColors_Options.playersOnly then
            print("Recolor nameplates for PLAYERS only.")
        else
            print("Recolor nameplates for PLAYERS and NPCs.")
        end
    end
end

-- HELP
function NameplateClassColorsFrame:PrintHelp() 
    print("# Nameplate Class Colors - Commands")
    print("# ")
    print("#            /ncc playersOnly: Toggle option (true/false): either recolor ALL nameplates or only nameplates owned by PLAYERS (hostile and friendly). Reloads UI.")
    print("#            /ncc reset: Resets options to default. Reloads UI.")
    print("#            /ncc enable: Enables recolouring. Reloads UI.")
    print("#            /ncc disable: Disables recolouring. Reloads UI.")
    print("#            /ncc options: Prints the current options set for the addon.")
    print("#            /ncc help: Print this help message.")
    print("# ")
    print("# Thank you for using Nameplate Class colors!")
    print("# Source: https://github.com/smp4903/wow-classic-nameplate-class-colors")
end