
_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['AUTOPAMOKA'] = _G['ADDONS']['AUTOPAMOKA'] or {};
local g = _G['ADDONS']['AUTOPAMOKA']
local acutil = require('acutil');
local addonName = "AutoPamoka";
local settingsFileLoc = string.format("../addons/%s/settings.json", string.lower(addonName));
g.settings = {on = 0, alert = 0, map = {}};
local loaded = false;

function AUTOPAMOKA_LOAD()
  if loaded == true then return end
  local t, err = acutil.loadJSON(settingsFileLoc);
  if not err then
    g.settings = t;
    loaded = true;
  end
end

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

function AUTOPAMOKA_FRAME_CREATE()
	local frame = ui.GetFrame('autopamoka');
	frame:EnableHitTest(1);
	--enablebox
	local Enablebox = frame:CreateOrGetControl('checkbox', 'enablebox', 30, 65, 100, 20)
    Enablebox:SetText("{ol}Enable Auto Pamoka");
	Enablebox:SetEventScript(ui.LBUTTONUP,"AUTOPAMOKA_SAVEFROMFRAME");
	local Enableboxchild = GET_CHILD(frame, "enablebox");
	Enableboxchild:SetCheck(g.settings.on);
	--alertbox
	local Alertbox = frame:CreateOrGetControl('checkbox', 'alertbox', 30, 95, 100, 20)
    Alertbox:SetText("{ol}Enable map alert");
	Alertbox:SetEventScript(ui.LBUTTONUP,"AUTOPAMOKA_SAVEFROMFRAME");
	Alertbox:SetTextTooltip("Popup an alert if you dont have any pamoka to fill when entering in the selected maps below:");
	local Alertboxchild = GET_CHILD(frame, "alertbox");
	Alertboxchild:SetCheck(g.settings.alert);
	--setting maps droplist
	local settingList = tolua.cast(frame:CreateOrGetControl('droplist', 'SettingMapDropList', 30, 125, 260, 20), 'ui::CDropList');
	settingList:SetSkinName('droplist_normal'); 
	settingList:EnableHitTest(1);
	settingList:ClearItems();
	if g.settings.map ~= nil then
		for k, v in pairs(g.settings.map) do
		settingList:AddItem(k, g.settings.map[k].name)
		end
	end
	local deletebtn = frame:CreateOrGetControl('button', 'delbtn', 300, 125, 40, 20);
	deletebtn:SetText("{ol}Delete");
	deletebtn:SetEventScript(ui.LBUTTONUP,"AUTOPAMOKA_DELETESETTING");
	--all maps droplist
	local Addtext = frame:CreateOrGetControl('richtext', 'addtext', 30, 170, 40, 20);
	Addtext:SetText("{ol}Add:");
	local dropList = tolua.cast(frame:CreateOrGetControl('droplist', 'MapDropList', 30, 200, 320, 20), 'ui::CDropList');
	dropList:SetSelectedScp('AUTOPAMOKA_SAVEMSG');
	dropList:SetSkinName('droplist_normal'); 
	dropList:EnableHitTest(1);
	local list = AUTOPAMOKA_GETMAPLIST();
	for i = 1, #list do
		local text = list[i].name
		text = text.." Lv"..(list[i].level);
		dropList:AddItem(list[i].classname, text);
	end
end

function AUTOPAMOKA_FRAME_OPEN()
	AUTOPAMOKA_FRAME_CREATE()
	local frame = ui.GetFrame('autopamoka');
	frame:ShowWindow(1);
end

function AUTOPAMOKA_FRAME_CLOSE()
	local frame = ui.GetFrame('autopamoka');
	frame:ShowWindow(0);
end

function AUTOPAMOKA_SAVEFROMFRAME()
	local frame = ui.GetFrame('autopamoka');
	local Enableboxchild = GET_CHILD(frame, "enablebox");
	local Alertboxchild = GET_CHILD(frame, "alertbox");
	g.settings.on = Enableboxchild:IsChecked();
	g.settings.alert = Alertboxchild:IsChecked();
	acutil.saveJSON(settingsFileLoc, g.settings);
	AUTOPAMOKA_EXEC();
end

function AUTOPAMOKA_GETMAPLIST()
	local mapcnt = GetClassCount('Map');
	local Mlist = {};
	for i = 0, mapcnt-1 do
		local mapcls = GetClassByIndex('Map', i);
		local classname = mapcls.ClassName;
		if mapcls.QuestLevel > 99 then
			Mlist[classname] = {};
			Mlist[classname].name = mapcls.Name;
			Mlist[classname].level = mapcls.QuestLevel;
		end
	end
	local sortlist = {};
	local cnt = 1;
	for x, y in spairs(Mlist, function(t, a, b) return t[b].level < t[a].level end) do
		sortlist[cnt] = {};
		sortlist[cnt].classname = x;
		sortlist[cnt].name = y.name;
		sortlist[cnt].level =y.level;
		cnt = cnt + 1;
	end
	return sortlist
end

function AUTOPAMOKA_SAVEMSG()
	local frame = ui.GetFrame('autopamoka');
	frame:EnableHitTest(0);
	ui.MsgBox("Want to save the selected map?","AUTOPAMOKA_SAVE","AUTOPAMOKA_FRAME_CREATE")
end

function AUTOPAMOKA_SAVE()
	local frame = ui.GetFrame('autopamoka'); 
	local droplist = GET_CHILD(frame, "MapDropList", "ui::CDropList");
	local key = tostring(droplist:GetSelItemKey());
	local text = tostring(droplist:GetText());
	g.settings.map[key] = {name = ""};
	g.settings.map[key].name = text;
	acutil.saveJSON(settingsFileLoc, g.settings);
	AUTOPAMOKA_FRAME_CREATE();
end

function AUTOPAMOKA_DELETESETTING()
	local frame = ui.GetFrame('autopamoka'); 
	local settinglist = GET_CHILD(frame, "SettingMapDropList", "ui::CDropList");
	local key = tostring(settinglist:GetSelItemKey());
	g.settings.map[key] = nil;
	acutil.saveJSON(settingsFileLoc, g.settings);
	AUTOPAMOKA_FRAME_CREATE();
end

function AUTOPAMOKA_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'AUTOPAMOKA_TIMER');
	addon:RegisterMsg('GAME_START_3SEC', 'AUTOPAMOKA_TIMER2');
	acutil.slashCommand('/autopamoka', AUTOPAMOKA_CMD);
	AUTOPAMOKA_LOAD();
	AUTOPAMOKA_FRAME_CREATE();
end

function AUTOPAMOKA_CMD(command)
	AUTOPAMOKA_FRAME_OPEN();
end

function AUTOPAMOKA_EXEC()
	if g.settings.on == 1 then
		local frame = ui.GetFrame('quickslotnexpbar');
		if config.GetXMLConfig("ControlMode") == 1 then 
			frame = ui.GetFrame('joystickquickslot');
		end
		local expOrb = frame:GetUserValue("EXP_ORB_EFFECT"); 
		for i = 0, MAX_QUICKSLOT_CNT - 1 do
			local quickSlotInfo = quickslot.GetInfoByIndex(i);
			if tonumber(quickSlotInfo.type) == 699011 then
				if tonumber(expOrb) == 0 or expOrb == "None" then
					local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot"); 
					local icon = slot:GetIcon();
					local iconInfo = icon:GetInfo();
					if iconInfo:GetImageName() == "icon_item_empty_partis" then
						ICON_USE(icon);
						AUTOPAMOKA_TIMER();
						return 
					end
				else
					AUTOPAMOKA_TIMER();
					return 
				end
			end
		end
		AUTOPAMOKA_TIMER();
	else 
	return
	end
end

function AUTOPAMOKA_CHECKMAP()
	if g.settings.alert == 1 and g.settings.map ~= nil then
		local sessionmap = session.GetMapName();
		local invList = session.GetInvItemList();
		for k, v in pairs(g.settings.map) do
			if k == sessionmap then
				local foundT = {found = 0};
				FOR_EACH_INVENTORY(invList, function(invList, invItem, founT)
					if invItem.type == 699011 then
							foundT.found = 1;
					end
				end, true, foundT);
				-- local frame = ui.GetFrame('quickslotnexpbar');
				-- local found = 0;
				-- if config.GetXMLConfig("ControlMode") == 1 then 
					-- frame = ui.GetFrame('joystickquickslot');
				-- end
				-- for i = 0, MAX_QUICKSLOT_CNT - 1 do
					-- local quickSlotInfo = quickslot.GetInfoByIndex(i);
					-- if tonumber(quickSlotInfo.type) == 699011 then
						-- local slot = GET_CHILD_RECURSIVELY(frame, "slot"..i+1, "ui::CSlot");
						-- local icon = slot:GetIcon();
						-- local iconInfo = icon:GetInfo();
						-- if iconInfo:GetImageName() == "icon_item_empty_partis" and icon:GetStringColorTone() ~= "FFFF0000" then
							-- found = 1;
						-- end
					-- end	
				-- end
				if foundT.found == 0 then
					ui.MsgBox("Auto Pamoka{nl}{#FF0000}No empty pamoka found in your Inventory!{/}{nl}Press YES to continue{nl}NO to open settings.","","AUTOPAMOKA_FRAME_OPEN");
					return
				end
			end
		end
	end
end

function AUTOPAMOKA_TIMER()
	if g.settings.on == 1 then
	ReserveScript("AUTOPAMOKA_EXEC()", 5);
	end
end

function AUTOPAMOKA_TIMER2()
	if g.settings.alert == 1 then
	ReserveScript("AUTOPAMOKA_CHECKMAP()", 10);
	end
end
