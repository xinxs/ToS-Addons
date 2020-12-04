local addonName = "TOKENWARPCHAT"
local author = "XINXS"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require('acutil')

local function spairs(t, order)
   local keys = {}
   for k in pairs(t) do keys[#keys+1] = k end
   if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
   else
        table.sort(keys)
   end
   local i = 0
   return function()
        i = i + 1
       if keys[i] then
            return keys[i], t[keys[i]]
       end
   end
end

function TOKENWARPCHAT_ON_INIT(addon, frame)
	acutil.slashCommand('/twc', TOKENWARPCHAT_CMD);
end

function TOKENWARPCHAT_CMD(command)
	local cmd = "";
	if #command > 0 then
		cmd = table.remove(command, 1);
	else
		ui.SysMsg("Insert the map name");
		return
	end
	
	local search = string.lower(string.gsub(cmd, " ", ""))
	if string.len(search) <= 3 then
		ui.SysMsg("Search term is too sort");
		return
	end

	local targetMap = nil
	
	local clsList, cnt = GetClassList('worldmap2_submap_data')
	local matchlist = {};
    for i = 0, cnt-1 do
        local cls = GetClassByIndexFromList(clsList, i)
        local mapData = GetClass('Map', cls.MapName)
		local mapStr = tostring(dictionary.ReplaceDicIDInCompStr(mapData.Name))
        local mapName = string.gsub(mapStr, " ", "");

        if string.find(string.lower(mapName), search) ~= nil then
            targetMap = mapData.ClassName;
			matchlist[targetMap] = {};
			matchlist[targetMap].Name = mapStr;
        end
    end
	
	local count = 0;
	for k in pairs(matchlist) do
		count = count + 1;
	end
	
	if count == 1 then
		WORLDMAP2_TOKEN_WARP(targetMap);
	elseif count > 1 then
		TOKENWARPCHAT_UI(matchlist, search);
	end
end

function TOKENWARPCHAT_UI(list, str)
	local frame = ui.GetFrame("tokenwarpchat");
	frame:ShowWindow(1);
	
	local searchtext = frame:CreateOrGetControl('richtext', 'searchText', 30, 40, 400, 20);
	searchtext:SetText("{ol}{s18}{#629dfc}Search: {/}{#1fde6b}" .. str .. "{/}{/}{/}");
	
	local sortlist = {};
	local cnt = 1;
	for x, y in spairs(list, function(t, a, b) return t[b].Name > t[a].Name end) do
		sortlist[cnt] = {};
		sortlist[cnt].classname = x;
		sortlist[cnt].name = y.Name;
		cnt = cnt + 1;
	end
	
	local dropList = tolua.cast(frame:CreateOrGetControl('droplist', 'MapDropList', 30, 65, 400, 20), 'ui::CDropList');
	dropList:ClearItems();
	dropList:SetSkinName('droplist_normal');
	
	for i = 1, #sortlist do
		dropList:AddItem(sortlist[i].classname, sortlist[i].name);
	end
end

function TOKENWARPCHAT_WARPBTN()
	local frame = ui.GetFrame("tokenwarpchat");
	local droplist = GET_CHILD(frame, "MapDropList", "ui::CDropList");
	local mapName = tostring(droplist:GetSelItemKey());
	if session.loginInfo.IsPremiumState(ITEM_TOKEN) == false then
		ui.SysMsg("Token is not Enabled");
        return
    end
	local mapData = GetClass("Map", mapName)
    if mapData == nil then
        return
    end

    local submapData = GetClassByStrProp("worldmap2_submap_data", "MapName", mapName)
    if submapData == nil then
        return
    end

    if GetZoneName() == mapName then
        ui.SysMsg(ScpArgMsg("ThatCurrentPosition"))
        return
    end

    if GET_TOKEN_WARP_COOLDOWN() == 0 then
        WORLDMAP2_TOKEN_WARP_REQUEST(mapName)
    else
        addon.BroadMsg("NOTICE_Dm_!", ScpArgMsg("TokenWarpDisable{TIME}", "TIME", GET_TOKEN_WARP_COOLDOWN()), 5)
    end
end

function TOKENWARPCHAT_CLOSEBTN()
	local frame = ui.GetFrame("tokenwarpchat");
	frame:ShowWindow(0);
end
