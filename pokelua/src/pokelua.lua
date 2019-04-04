-- meta
local addon_dev = "LUNAR";
local addon_name = "POKELUA";
local addon_name_tag = "PokeLua";
local addon_name_lower = string.lower(addon_name);

-- dependencies
local acutil = require("acutil");

-- globals: general
_G["ADDONS"] = _G["ADDONS"] or {};
_G["ADDONS"][addon_dev] = _G["ADDONS"][addon_dev] or {};
_G["ADDONS"][addon_dev][addon_name] = _G["ADDONS"][addon_dev][addon_name] or {};

local g = _G["ADDONS"]["LUNAR"]["POKELUA"];

-- globals: hooks
g["HOOKS"] = g["HOOKS"] or {};
g["HOOK_TABLE"] = g["HOOK_TABLE"] or {};

local hooks = g["HOOKS"];
local hook_table = g["HOOK_TABLE"];

-- addon: runtime vars
g.addon = nil;
g.frame = nil;
g.loaded = false;

-- functions: hooks
function POKELUA_HOOKS_INIT(source, target)
	if hook_table[source] == nil then
		hook_table[source] = target;
	end
end

function POKELUA_HOOKS()
	-- template:
	-- POKELUA_HOOKS_INIT("{HOOK_SOURCE}", {HOOK_TARGET});
	POKELUA_HOOKS_INIT("EARTH_TOWER_SHOP_EXEC", POKELUA_ON_EARTH_TOWER_SHOP_EXEC);

	-- Save hook sources only once
	if g.loaded == false then
		for hook, _ in pairs(hook_table) do
			hooks[hook] = _G[hook];
		end
	end

	-- Set hook targets
	for hook, fn in pairs(hook_table) do
		if _G[hook] ~= fn then
			_G[hook] = fn;
		end
	end
end

-- functions: loader
function POKELUA_ON_INIT(addon, frame)
	g.addon = addon;
	g.frame = frame;

	POKELUA_HOOKS();

	if g.loaded == false then
		g.loaded = true;
	end
end

-- functions: hook targets
-- template:
-- function POKELUA_ON_{HOOK_SOURCE}({HOOK_SOURCE_ARGS})
-- 	-- Call hook source
-- 	hooks["{HOOK_SOURCE}"]({HOOK_SOURCE_ARGS});
-- end

function POKELUA_ON_EARTH_TOWER_SHOP_EXEC(parent, ctrl)
	local hideshop = true;

	local parentcset = ctrl:GetParent();

	local frame = ctrl:GetTopParentFrame();
	local cnt = parentcset:GetChildCount();
	for i = 0, cnt - 1 do
		local eachcset = parentcset:GetChildByIndex(i);
		if string.find(eachcset:GetName(),'EACHMATERIALITEM_') ~= nil then
			local selected = eachcset:GetUserValue("MATERIAL_IS_SELECTED")
			if selected ~= 'selected' then
				ui.AddText("SystemMsgFrame", ScpArgMsg('NotEnoughRecipe'));
				return;
			end
		end
	end

	local resultlist = session.GetItemIDList();
	local someflag = 0
	for i = 0, resultlist:Count() - 1 do
		local tempitem = resultlist:PtrAt(i);

		if IS_VALUEABLE_ITEM(tempitem.ItemID) == 1 then
			someflag = 1
		end
	end

	session.ResetItemList();

	local recipeCls = GetClass("ItemTradeShop", parentcset:GetName())

	for index=1, 5 do
		local clsName = "Item_"..index.."_1";
		local itemName = recipeCls[clsName];
		local recipeItemCnt, recipeItemLv = GET_RECIPE_REQITEM_CNT(recipeCls, clsName);
		local invItem = session.GetInvItemByName(itemName);
		if "None" ~= itemName then
			if nil == invItem then
				ui.AddText("SystemMsgFrame", ClMsg('NotEnoughRecipe'));
				return;
			else
				if true == invItem.isLockState then
					ui.SysMsg(ClMsg("MaterialItemIsLock"));
					return;
				end
				session.AddItemID(invItem:GetIESID(), recipeItemCnt);

				if GetInvItemCount(GetMyPCObject(), itemName) >= recipeItemCnt * 2 then
					hideshop = false;
				end
			end
		end
	end

	local resultlist = session.GetItemIDList();
	local cntText = string.format("%s %s", recipeCls.ClassID, 1);

	local shopType = frame:GetUserValue("SHOP_TYPE");

	if shopType == 'EarthTower' then
		item.DialogTransaction("EARTH_TOWER_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'EarthTower2' then
		item.DialogTransaction("EARTH_TOWER_SHOP_TREAD2", resultlist, cntText);
	elseif shopType == 'EventShop' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'EventShop2' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD2", resultlist, cntText);
	elseif shopType == 'KeyQuestShop1' then
		item.DialogTransaction("KEYQUESTSHOP1_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'KeyQuestShop2' then
		item.DialogTransaction("KEYQUESTSHOP2_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'HALLOWEEN' then
		item.DialogTransaction("HALLOWEEN_SHOP_TREAD", resultlist, cntText);
	elseif shopType == 'EventShop3' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD3", resultlist, cntText);	
	elseif shopType == 'EventShop4' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD4", resultlist, cntText);
	elseif shopType == 'EventShop8' then
		item.DialogTransaction("EVENT_ITEM_SHOP_TREAD8", resultlist, cntText);
	elseif shopType == 'PVPMine' then
		item.DialogTransaction("PVP_MINE_SHOP", resultlist, cntText);
	elseif shopType == 'MCShop1' then
		item.DialogTransaction("MASSIVE_CONTENTS_SHOP_TREAD1", resultlist, cntText);
	elseif shopType == 'DailyRewardShop' then
		item.DialogTransaction("DAILY_REWARD_SHOP_1_TREAD1", resultlist, cntText);
	end

	if hideshop then
		frame:ShowWindow(0);
	end
end