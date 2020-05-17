local addonName			= "ENCHANTSEARCH"
local author			= "XINXS"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require('acutil')
local frame = ui.GetFrame("market")
MARKET_OPTION_GROUP_PROP_LIST_EDIT = {
	STAT = {
		"STR",
		"DEX",
		"INT",
		"CON",
		"MNA",
	},
    UTIL = {
		"BLK",
		"BLK_BREAK",
		"ADD_HR",
		"ADD_DR",
		"CRTHR",
		"MHP",
		"MSP",
		"MSTA",
		"RHP",
		"RSP",
		"LootingChance",
	},
    MARKET_DEF = {
		"ADD_DEF",
		"ADD_MDEF",
		"AriesDEF",
		"SlashDEF",
		"StrikeDEF",
		"RES_FIRE",
		"RES_ICE",
		"RES_POISON",
		"RES_LIGHTNING",
		"RES_EARTH",
		"RES_SOUL",
		"RES_HOLY",
		"RES_DARK",
		"CRTDR",
		"Cloth_Def",
		"Leather_Def",
		"Iron_Def",
		"MiddleSize_Def",
		"ResAdd_Damage"
	},
    MARKET_ATK = {
		"PATK",
		"ADD_MATK",
		"CRTATK",
		"CRTMATK",
		"ADD_CLOTH",
		"ADD_LEATHER",
		"ADD_IRON",
		"ADD_SMALLSIZE",
		"ADD_MIDDLESIZE",
		"ADD_LARGESIZE",
		"ADD_GHOST",
		"ADD_FORESTER",
		"ADD_WIDLING",
		"ADD_VELIAS",
		"ADD_PARAMUNE",
		"ADD_KLAIDA",
		"ADD_FIRE",
		"ADD_ICE",
		"ADD_POISON",
		"ADD_LIGHTNING",
		"ADD_EARTH",
		"ADD_SOUL",
		"ADD_HOLY",
		"ADD_DARK",
		"Add_Damage_Atk",
		"ADD_BOSS_ATK"
	},
    ETC = {
		"SR",
		"MSPD",
		"SDR",
		"RareOption_MainWeaponDamageRate",
		"RareOption_SubWeaponDamageRate",
		"RareOption_BossDamageRate",
		"RareOption_MeleeReducedRate",
		"RareOption_MagicReducedRate",
		"RareOption_PVPDamageRate",
		"RareOption_PVPReducedRate",
		"RareOption_CriticalDamage_Rate",
		"RareOption_CriticalHitRate",
		"RareOption_CriticalDodgeRate",
		"RareOption_HitRate",
		"RareOption_DodgeRate",
		"RareOption_BlockBreakRate",
		"RareOption_BlockRate",		
	},
};

function ENCHANTSEARCH_ON_INIT(addon, frame)
acutil.setupHook(IS_MARKET_SEARCH_OPTION_GROUP_HOOKED, "IS_MARKET_SEARCH_OPTION_GROUP");
acutil.setupHook(MARKET_INIT_OPTION_GROUP_DROPLIST_HOOKED, "MARKET_INIT_OPTION_GROUP_DROPLIST");
acutil.setupHook(MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST_HOOKED, "MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST");
end

function IS_MARKET_SEARCH_OPTION_GROUP_HOOKED(optionName)
	for group, list in pairs(MARKET_OPTION_GROUP_PROP_LIST_EDIT) do
		for i = 1, #list do
			if optionName == list[i] then
				return true, group;
			end
		end
	end
	return false;
end

function MARKET_INIT_OPTION_GROUP_DROPLIST_HOOKED(dropList)
	dropList:ClearItems();
	dropList:AddItem('', '');
	for group, list in pairs(MARKET_OPTION_GROUP_PROP_LIST_EDIT) do		
		dropList:AddItem(group, ClMsg(group));
	end
	MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST_HOOKED(dropList:GetParent(), dropList);
end

function MARKET_INIT_OPTION_GROUP_VALUE_DROPLIST_HOOKED(optionGroupSet, groupList)
	local selectedGroup = groupList:GetSelItemKey();
	local nameList = GET_CHILD(optionGroupSet, 'nameList');
	local nameValueList = MARKET_OPTION_GROUP_PROP_LIST_EDIT[selectedGroup];	
	nameList:ClearItems();
	nameList:AddItem('', '');
	if nameValueList ~= nil then
		for i = 1,  #nameValueList do
			local valueName = nameValueList[i]
			if nameValueList[i]:find("RareOption_") ~= nil then
				valueName = nameValueList[i]:gsub("RareOption_","")
			end
			nameList:AddItem(valueName, ClMsg(nameValueList[i]));
		end
	end
end

