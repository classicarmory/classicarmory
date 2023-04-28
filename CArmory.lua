
local EventFrame = CreateFrame("frame", "EventFrame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
EventFrame:RegisterEvent("PLAYER_QUITING")
EventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")

local data = {}
EventFrame:SetScript("OnEvent", function(self, event, ...)
    
    if(event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_QUITING") then
        local name, _ = UnitName("player")
        local playerUnit = UnitGUID("player")
        local locClass, _, locRace, _, _, _, _ = GetPlayerInfoByGUID(playerUnit)
        local guildName, guildRankName, guildRankIndex = GetGuildInfo("player") 
        local englishFaction, localizedFaction = UnitFactionGroup("player")
        --local realm = GetRealmName()
        local level = UnitLevel("player")
        local powerType, powerTypeString = UnitPowerType("player");
        local powerTypeMax = UnitPowerMax("player",powerType)
        local health = UnitHealthMax("player")
        -- Get Spell Stats
        --local spellHaste = GetCombatRating(20)
        --local spellCrit = GetCombatRating(11)
        local spellHit = GetCombatRating(8)
        local bonusHeal = GetSpellBonusHealing()
        local spellDamage = GetSpellBonusDamage(2)
        local base, casting = GetManaRegen()
        local spellManaRegen = base..":"..casting

        -- Get Melee stats
        local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage("player");
        local meleeCrit = GetCombatRating(9)
        local meleeHit = GetCombatRating(6)

        -- Get Defense stats (armor already exported via getBaseArmor())
        local baseDefense, armorDefense = UnitDefense("player");
        -- Get Ranged stats
        if (level >= 19) then
            data = {
                ["name"] = name,
                ["level"] = level,
                ["realm"] = GetRealmName(),
                ["class"] = locClass,
                ["race"] = locRace,
                ["talentTabNames"] = getTalentTabNames(),
                ["primaryTalents"] = getPrimaryTalents(),
                ["powerType"] = powerTypeString,
                ["powerTypeMax"] = powerTypeMax,
                ["health"] = health,
                ["guildName"] = guildName,
                ["guildRankName"] = guildRankName,
                ["spellHaste"] = GetCombatRating(20),
                ["spellCrit"] = GetCombatRating(11),
                ["bonusHeal"] = bonusHeal,
                ["spellManaRegen"] = spellManaRegen,
                ["faction"] = englishFaction,
                ["title"] = getPlayerTitle(),
                ["baseStrength"] = getBaseStats(1),
                ["baseAgility"] = getBaseStats(2),
                ["baseStamina"] = getBaseStats(3),
                ["baseIntellect"] = getBaseStats(4),
                ["baseSpirit"] = getBaseStats(5),
                ["baseArmor"] = getBaseArmor(),
                ["spellDamage"] = spellDamage,
                ["meleeAttackSpeed"] = getAttackSpeed(),
                ["meleeDamageLow"] = lowDmg,
                ["meleeDamageHigh"] = hiDmg,
                ["meleeCrit"] = meleeCrit,
                ["meleeHit"] = meleeHit,
                ["meleeAttackPower"] = getMeleeAttackPower(),
                ["meleeExpertise"] = getMeleeExpertise(),
                ["defense"] = baseDefense,
                ["dodgeChance"] = GetDodgeChance(),
                ["parryChance"] = GetParryChance(),
                ["blockChance"] = GetBlockChance(),
            }

            for i=1, 19 do
                local getItemString = GetInventoryItemLink("player",i)
                local itemId = GetInventoryItemID("player", i);
                if(itemId) then
                    local item = Item:CreateFromEquipmentSlot(i)
                    item:ContinueOnItemLoad(function()
                        local name = item:GetItemName() 
                        local icon = item:GetItemIcon()
                        local itemLink = item:GetItemLink()
                    
                        if(itemLink) then -- getItemString
                            local itemLink = select(3, strfind(itemLink, "|H(.+)|h"))
                            local _, _, itemRarity, itemLevel, _, itemType, itemSubType, _, _, _, _ = GetItemInfo(itemLink)
                            invSlot = "InvSlot"..i

                            if (itemLevel and itemRarity and itemSubType) then
                                data[invSlot] = itemLink..":"..itemLevel..":"..itemRarity..":"..itemSubType
                            end
                            --getInvSlot(itemId, i)
                        end
                end)
            else
                invSlotNone = "InvSlot"..i
                data[invSlotNone] = "-"
            end
            end
            CArmoryData = data
            print(name.." Loaded into armory")
        end
    end -- end events
end)

-- Get inventory slots

--function getInvSlot(itemId, slot) 
--    local getItemString = GetInventoryItemLink("player",slot)
--    local itemString = select(3, strfind(getItemString, "|H(.+)|h"))
--    local _, itemLink, itemRarity, itemLevel, _, itemType, itemSubType, _, _, _, _ = GetItemInfo(itemId)
--    invSlot = "InvSlot"..slot
--    if (itemId and itemLevel and itemRarity and itemSubType) then
--        data[invSlot] = itemLink..":"..itemLevel..":"..itemRarity..":"..itemSubType
--        print("slot "..slot)
--    end
--end

-- Get base stat information from statID
function getBaseStats(statID)
    local base, stat, posBuff, negBuff = UnitStat("player", statID);
    return base
end

-- Get base armor value
function getBaseArmor()
    local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
    return base
end

-- Get current titleID and get titlename
function getPlayerTitle()
    local currentTitle = GetCurrentTitle()
    local titleName = GetTitleName(currentTitle)
    return titleName
end

-- Get melee attack speed
function getAttackSpeed()
    local mainSpeed, offSpeed = UnitAttackSpeed("player");
    return mainSpeed
end

-- get melee attack power
function getMeleeAttackPower()
    local base, posBuff, negBuff = UnitAttackPower("player");
    return base
end

-- get melee expertise rating
function getMeleeExpertise()
    local expertise, offhandExpertise = GetExpertise();
    return expertise
end

-- Get Names of talent tabs
function getTalentTabNames()
    local numTabs = GetNumTalentTabs();
    local talentTabNames = "";
    for t=1, numTabs do
        if t == 3 then
            talentTabNames = talentTabNames .. GetTalentTabInfo(t)
        else
            talentTabNames = talentTabNames .. GetTalentTabInfo(t).."/"
        end
        
    end
    return talentTabNames
end

-- Get primary talents
function getPrimaryTalents()
    local numTabs = GetNumTalentTabs();
    local talentTabs = "";
    for t=1, numTabs do

        local numTalents = GetNumTalents(t);
        local usedTalents = 0;
        for i=1, numTalents do
            nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(t,i);
            usedTalents = usedTalents + currRank;
        end
        if t == 3 then
            talentTabs = talentTabs .. usedTalents
        else
            talentTabs = talentTabs .. usedTalents.."/"
        end
        
    end
    return talentTabs
end
