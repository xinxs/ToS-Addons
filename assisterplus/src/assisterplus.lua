local addonName = "ASSISTERPLUS"
local author = "XINXS"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require('acutil')
local settingsFileLoc = string.format("../addons/%s/settings.json", string.lower(addonName));
g.settings = {saves = {}};
local loaded = false;
local filterlist = {ison = false, filtertype = "none", argN = -1};

function ASSISTERPLUS_LOAD()
	if loaded == true then return end
	local t, err = acutil.loadJSON(settingsFileLoc);
	if not err then
		g.settings = t;
		loaded = true;
	end
end

function ASSISTERPLUS_SAVEBTN()
	INPUT_STRING_BOX_CB(nil,'Set name:', 'ASSISTERPLUS_SAVESET', '', nil, nil, 10);
end

function ASSISTERPLUS_SAVESET(setname, frame)
	local delay = 0;
	local frame = ui.GetFrame("ancient_card_list");
	local cnt = session.ancient.GetAncientCardCount();
	g.settings.saves[setname] = {};
	for i = 0,3 do
		local card = session.ancient.GetAncientCardBySlot(i);
		if card ~= nil then
			if card.isLock ~= true then
			ReserveScript(string.format("ReqLockAncientCard(\"%s\")", card:GetGuid()), delay);
			delay = delay + 0.5;
			end
			g.settings.saves[setname][i+1] = card:GetGuid();
		end
	end
	acutil.saveJSON(settingsFileLoc, g.settings);
	ASSISTERPLUS_DROPLIST(frame);
end

function ASSISTERPLUS_LOADSET()
	local delay = 0;
	local frame = ui.GetFrame("ancient_card_list");
	local droplist = GET_CHILD(frame, "ADropList", "ui::CDropList");
	local setname = tostring(droplist:GetSelItemKey());
	local tab = frame:GetChild("tab");
	AUTO_CAST(tab);
	if tab ~= nil then
		tab:SelectTab(0);
		ANCIENT_CARD_LIST_TAB_CHANGE(frame)
	end
	for i = 0,3 do
		local card = session.ancient.GetAncientCardBySlot(i);
		if card ~= nil then
			ReserveScript(string.format("REQUEST_SWAP_ANCIENT_CARD(frame,\"%s\",nil)", card:GetGuid()), delay);
			delay = delay + 0.4;
		end
	end
	if g.settings.saves[setname] ~= nil then
		for slot, guid in pairs(g.settings.saves[setname]) do
			ReserveScript(string.format("REQUEST_SWAP_ANCIENT_CARD(frame,\"%s\",%d)", guid, slot-1), delay);
			delay = delay + 0.4;
		end
	end
end

function ASSISTERPLUS_DELETEBTN()
	ui.MsgBox("Delete set?","ASSISTERPLUS_DELETESET","")
end

function ASSISTERPLUS_DELETESET()
	local frame = ui.GetFrame("ancient_card_list");
	local droplist = GET_CHILD(frame, "ADropList", "ui::CDropList");
	local setname = tostring(droplist:GetSelItemKey());
	g.settings.saves[setname] = nil;
	acutil.saveJSON(settingsFileLoc, g.settings);
	ASSISTERPLUS_DROPLIST(frame);
end
	
function ASSISTERPLUS_DROPLIST(frame)
	local DropList = tolua.cast(frame:CreateOrGetControl('droplist', 'ADropList', 460, 75, 150, 20), 'ui::CDropList');
	DropList:SetSelectedScp('ASSISTERPLUS_LOADSET');
	DropList:SetSkinName('droplist_normal'); 
	DropList:EnableHitTest(1);
	DropList:ClearItems();
	if g.settings.saves ~= nil then
		for k, v in pairs(g.settings.saves) do
			DropList:AddItem(k, k)
		end
	end
	--save, delete
	local deletebtn = frame:CreateOrGetControl('button', 'delbtn', 438, 75, 20, 20);
	deletebtn:SetText("{#FF0000}{ol}X");
	deletebtn:SetEventScript(ui.LBUTTONUP,"ASSISTERPLUS_DELETEBTN");
	local savebtn = frame:CreateOrGetControl('button', 'sbtn', 612, 75, 85, 20);
	savebtn:SetText("{ol}Save");
	savebtn:SetEventScript(ui.LBUTTONUP,"ASSISTERPLUS_SAVEBTN");

	--rarityfilter
	local cIcon = frame:CreateOrGetControl('button', "btnico_1", 230, 647, 18, 24);
	cIcon:SetSkinName("test_normal_button");
	cIcon:SetText(string.format("{img normal_card %d %d}", 18, 24));
	cIcon:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	cIcon:SetEventScriptArgString(ui.LBUTTONDOWN, "rarity");
	cIcon:SetEventScriptArgNumber(ui.LBUTTONDOWN, 1);
	
	cIcon = frame:CreateOrGetControl('button', "btnico_2", 250, 647, 18, 24);
	cIcon:SetSkinName("test_normal_button");
	cIcon:SetText(string.format("{img rare_card %d %d}", 18, 24));
	cIcon:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	cIcon:SetEventScriptArgString(ui.LBUTTONDOWN, "rarity");
	cIcon:SetEventScriptArgNumber(ui.LBUTTONDOWN, 2);
	
	cIcon = frame:CreateOrGetControl('button', "btnico_3", 270, 647, 18, 24);
	cIcon:SetSkinName("test_normal_button");
	cIcon:SetText(string.format("{img unique_card %d %d}", 18, 24));
	cIcon:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	cIcon:SetEventScriptArgString(ui.LBUTTONDOWN, "rarity");
	cIcon:SetEventScriptArgNumber(ui.LBUTTONDOWN, 3);
	
	cIcon = frame:CreateOrGetControl('button', "btnico_4", 290, 647, 18, 24);
	cIcon:SetSkinName("test_normal_button");
	cIcon:SetText(string.format("{img legend_card %d %d}", 18, 24));
	cIcon:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	cIcon:SetEventScriptArgString(ui.LBUTTONDOWN, "rarity");
	cIcon:SetEventScriptArgNumber(ui.LBUTTONDOWN, 4);
	
	--starfilter
	local starbtn = frame:CreateOrGetControl('button', 'starbutton_1', 315, 645, 30, 30);
	starbtn:SetSkinName("test_normal_button");
	starbtn:SetText(string.format("{img monster_card_starmark %d %d}", 12, 12));
	starbtn:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	starbtn:SetEventScriptArgString(ui.LBUTTONDOWN, "stars");
	starbtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, 1);
	
	starbtn = frame:CreateOrGetControl('button', 'starbutton_2', 339, 645, 30, 30);
	starbtn:SetSkinName("test_normal_button");
	starbtn:SetText(string.format("{img monster_card_starmark %d %d}", 12, 12) .. string.format("{img monster_card_starmark %d %d}", 12, 12));
	starbtn:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	starbtn:SetEventScriptArgString(ui.LBUTTONDOWN, "stars");
	starbtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, 2);
	
	starbtn = frame:CreateOrGetControl('button', 'starbutton_3', 365, 645, 32, 30);
	starbtn:SetSkinName("test_normal_button");
	starbtn:SetText(string.format("{img monster_card_starmark %d %d}", 12, 12) .. string.format("{img monster_card_starmark %d %d}", 12, 12) .. string.format("{img monster_card_starmark %d %d}", 12, 12));
	starbtn:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	starbtn:SetEventScriptArgString(ui.LBUTTONDOWN, "stars");
	starbtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, 3);
	
	--allbtn
	local allbtn = frame:CreateOrGetControl('button', 'allbutton', 415, 644, 40, 32);
	allbtn:SetSkinName("test_normal_button");
	allbtn:SetText("{#BABABA}{ol}ALL");
	allbtn:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_ALLBTN');	
end

function ASSISTERPLUS_ALLBTN()
	local frame = ui.GetFrame("ancient_card_list");
	filterlist.ison = false;
	ON_ANCIENT_CARD_RELOAD(frame);
end

function ASSISTERPLUS_LOCKBTN(parent, FromctrlSet, argStr, argNum)
	local frame = ui.GetFrame("ancient_card_list");
	ReqLockAncientCard(argStr);
end

function ap_tablefind(tab,el)
	for index, value in pairs(tab) do
		if value == el then
			return index
		end
	end
end

function ASSISTERPLUS_ON_INIT(addon, frame)
	ASSISTERPLUS_LOAD();
	addon:RegisterMsg('ANCIENT_CARD_LOCK', 'ON_ASSISTERPLUS_LOCK');
	acutil.setupHook(ANCIENT_CARD_LIST_OPEN_HOOKED, "ANCIENT_CARD_LIST_OPEN");
	acutil.setupHook(SET_ANCIENT_CARD_LIST_HOOKED, "SET_ANCIENT_CARD_LIST");
	--acutil.setupHook(ANCIENT_CARD_COMBINE_CHECK_HOOKED, "ANCIENT_CARD_COMBINE_CHECK");
	acutil.setupHook(INIT_ANCIENT_CARD_INFO_TAB_HOOKED, "INIT_ANCIENT_CARD_INFO_TAB");
	acutil.setupHook(ANCIENT_CARD_COMBINE_LIST_LOAD_HOOKED, "ANCIENT_CARD_COMBINE_LIST_LOAD");
end

function ANCIENT_CARD_LIST_OPEN_HOOKED(aframe)
	local frame = ui.GetFrame("ancient_card_list");
	local tab = frame:GetChild("tab")
	AUTO_CAST(tab);
	if tab ~= nil then
	tab:SelectTab(0);
	ANCIENT_CARD_LIST_TAB_CHANGE(frame)
	end 
	local ancient_card_num = frame:GetChild('ancient_card_num')
	ancient_card_num:SetTextByKey("max",ANCIENT_CARD_SLOT_MAX)
	ANCEINT_PASSIVE_LIST_SET(frame)
	ANCIENT_SET_COST(frame)
	local ancient_card_comb_name = GET_CHILD_RECURSIVELY(frame,"ancient_card_comb_name")
	ancient_card_comb_name:SetTooltipType('ancient_passive')
	ASSISTERPLUS_DROPLIST(frame)
end

function SET_ANCIENT_CARD_LIST_HOOKED(gbox,card,isLockMode)
	local height = (gbox:GetChildCount()-1) * 51
	local ctrlSet = gbox:CreateOrGetControlSet("ancient_card_item_list", "SET_" .. card.slot, 0, height);
	--lock
	local lockbtn = ctrlSet:CreateOrGetControl('button', "lockbtn".. card.slot, 390, 16, 64, 28);
	lockbtn:SetSkinName('test_pvp_btn');
	lockbtn:SetText("{ol}Lock");
	lockbtn:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_LOCKBTN');
	lockbtn:SetEventScriptArgString(ui.LBUTTONDOWN, tostring(card:GetGuid()));
	if card.isLock == true then
		lockbtn:SetText("{#FF0000}{ol}Locked");
	end
	
	--set level
	local exp = card:GetStrExp();
	local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
	local level = xpInfo.level
	local levelText = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_level")
	levelText:SetText("{@st42b}{s16}Lv. "..level.."{/}")

	--set image
	local monCls = GetClass("Monster", card:GetClassName());
	local iconName = TryGetProp(monCls, "Icon");
	local slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_slot")
	local image = CreateIcon(slot)
	image:SetImage(iconName)

	--set name
	local nameText = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_name")
	local name = monCls.Name
	local starStr = ""
	for i = 1, card.starrank do
		starStr = starStr ..string.format("{img monster_card_starmark %d %d}", 21, 20)
	end
	local ancientCls = GetClass("Ancient_Info",monCls.ClassName)
	local rarity = ancientCls.Rarity
	AUTO_CAST(ctrlSet)
	if rarity == 1 then
		name = ctrlSet:GetUserConfig("NORMAL_GRADE_TEXT")..name..' '..starStr.."{/}"
	elseif rarity == 2 then
		name = ctrlSet:GetUserConfig("MAGIC_GRADE_TEXT")..name..' '..starStr.."{/}" 
	elseif rarity == 3 then
		name = ctrlSet:GetUserConfig("UNIQUE_GRADE_TEXT")..name..' '..starStr.."{/}"
	elseif rarity == 4 then
		name = ctrlSet:GetUserConfig("LEGEND_GRADE_TEXT")..name..' '..starStr.."{/}"
	end
	nameText:SetText(name)

	local racetypeDic = {
						Klaida="insect",
						Widling="wild",
						Velnias="devil",
						Forester="plant",
						Paramune="variation",
						None="melee"
					}
	--set type
	local type1Slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_type1_pic")
	local type1Icon = CreateIcon(type1Slot)
	type1Icon:SetImage("monster_"..racetypeDic[monCls.RaceType])

	local type2Slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_type2_pic")
	local type2Icon = CreateIcon(type2Slot)
	type2Icon:SetImage("attribute_"..monCls.Attribute)	
	
	--tooltip
	ctrlSet:SetTooltipType("ancient_card")
	ctrlSet:SetTooltipStrArg(card:GetGuid())

	ctrlSet:SetUserValue("ANCIENT_GUID",card:GetGuid())

	SET_CTRL_LOCK_MODE(ctrlSet,isLockMode)
	if card.isNew == true then
		local slot = GET_CHILD_RECURSIVELY(ctrlSet,'ancient_card_slot')
		slot:SetHeaderImage('new_inventory_icon');
	end
	return ctrlSet
end

function ASSISTERPLUS_FILTERLIST_BTN(parent, FromctrlSet, argStr, argNum)
	local frame = ui.GetFrame("ancient_card_list");
	local tab = frame:GetChild("tab");
	AUTO_CAST(tab);
	local index = tab:GetSelectItemIndex();
	if index == 0 then
		ASSISTERPLUS_FILTERLIST_INFO(frame, argStr, argNum);
	else
		ASSISTERPLUS_FILTERLIST_COMBINE(frame, argStr, argNum);
	end
end

function ASSISTERPLUS_FILTERLIST_INFO(frame, argStr, argNum)
	filterlist.ison = true;
	filterlist.filtertype = argStr;
	filterlist.argN = argNum;
	INIT_ANCIENT_CARD_SLOTS(frame,0)

	local ancient_card_list_Gbox =  GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
	if ancient_card_list_Gbox == nil then
		return;
	end
	ancient_card_list_Gbox:RemoveAllChild()
	ancient_card_list_Gbox:SetEventScript(ui.DROP,"ANCIENT_CARD_SWAP_ON_DROP")
	local cnt = session.ancient.GetAncientCardCount();

	for i = 0,cnt-1 do
		local card = session.ancient.GetAncientCardByIndex(i);
		if card.slot > 3 then
			if argStr == "rarity" and argNum == card.rarity then
				local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
				ctrlSet:SetEventScript(ui.DROP,"ANCIENT_CARD_SWAP_ON_DROP")
			elseif argStr == "stars" and argNum == card.starrank then
				local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
				ctrlSet:SetEventScript(ui.DROP,"ANCIENT_CARD_SWAP_ON_DROP")
			end
		end
	end

	local ancient_card_num = frame:GetChild('ancient_card_num')
	ancient_card_num:SetTextByKey("count",cnt)
	ANCEINT_PASSIVE_LIST_SET(frame)
	ANCIENT_SET_COST(frame)
end

function ASSISTERPLUS_FILTERLIST_COMBINE(frame, argStr, argNum)
	filterlist.ison = true;
	filterlist.filtertype = argStr;
	filterlist.argN = argNum;
	local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
	ancient_card_list_Gbox:RemoveAllChild()
	ancient_card_list_Gbox:SetEventScript(ui.DROP,"ANCIENT_CARD_SLOT_POP_COMBINE_BY_DROP")
	local slotBox = GET_CHILD_RECURSIVELY(frame,'ancient_card_slot_Gbox')
	local guidList = {}
	local index = 1
	for i = 0,3 do
		local ctrl = slotBox:GetChild("COMBINE_"..i)
		local guid = ctrl:GetUserValue("ANCIENT_GUID")
		if guid ~= "None" then
			guidList[index] = guid
			index = index + 1
		end
	end

	local count = session.ancient.GetAncientCardCount()
	for i = 0,count-1 do
		local card = session.ancient.GetAncientCardByIndex(i)
		local isSelected = false;
		for i = 1,#guidList do
			if guidList[i] == card:GetGuid() then
				isSelected = true;
				break;
			end
		end
		if card.slot >= 4 and isSelected == false then
			if argStr == "rarity" and argNum == card.rarity then
				local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
				ctrlSet:SetEventScript(ui.DROP,"ANCIENT_CARD_SLOT_POP_COMBINE_BY_DROP")
			elseif argStr == "stars" and argNum == card.starrank then
				local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
				ctrlSet:SetEventScript(ui.DROP,"ANCIENT_CARD_SLOT_POP_COMBINE_BY_DROP")
			end
		end
	end
end

function INIT_ANCIENT_CARD_INFO_TAB_HOOKED(frame)
	if filterlist.ison then
		ASSISTERPLUS_FILTERLIST_INFO(frame, filterlist.filtertype, filterlist.argN);
		return
	end
	INIT_ANCIENT_CARD_SLOTS(frame,0)

	local ancient_card_list_Gbox =  GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
	if ancient_card_list_Gbox == nil then
		return;
	end
	ancient_card_list_Gbox:RemoveAllChild()
	ancient_card_list_Gbox:SetEventScript(ui.DROP,"ANCIENT_CARD_SWAP_ON_DROP")
	local cnt = session.ancient.GetAncientCardCount()

	local height = 0
	for i = 0,cnt-1 do
		local card = session.ancient.GetAncientCardByIndex(i)
		if card.slot > 3 then
			local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
			ctrlSet:SetEventScript(ui.DROP,"ANCIENT_CARD_SWAP_ON_DROP")
		end
	end

	local ancient_card_num = frame:GetChild('ancient_card_num')
	ancient_card_num:SetTextByKey("count",cnt)
	ANCEINT_PASSIVE_LIST_SET(frame)
	ANCIENT_SET_COST(frame)
end

function ANCIENT_CARD_COMBINE_LIST_LOAD_HOOKED(frame)
	if filterlist.ison then
		ASSISTERPLUS_FILTERLIST_COMBINE(frame, filterlist.filtertype, filterlist.argN);
		return
	end
	local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
	ancient_card_list_Gbox:RemoveAllChild()
	ancient_card_list_Gbox:SetEventScript(ui.DROP,"ANCIENT_CARD_SLOT_POP_COMBINE_BY_DROP")
	local slotBox = GET_CHILD_RECURSIVELY(frame,'ancient_card_slot_Gbox')
	local guidList = {}
	local index = 1
	for i = 0,3 do
		local ctrl = slotBox:GetChild("COMBINE_"..i)
		local guid = ctrl:GetUserValue("ANCIENT_GUID")
		if guid ~= "None" then
			guidList[index] = guid
			index = index + 1
		end
	end

	local count = session.ancient.GetAncientCardCount()
	for i = 0,count-1 do
		local card = session.ancient.GetAncientCardByIndex(i)
		local isSelected = false;
		for i = 1,#guidList do
			if guidList[i] == card:GetGuid() then
				isSelected = true;
				break;
			end
		end
		if card.slot >= 4 and isSelected == false then
			local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
			ctrlSet:SetEventScript(ui.DROP,"ANCIENT_CARD_SLOT_POP_COMBINE_BY_DROP")
		end
	end
end

function ON_ASSISTERPLUS_LOCK(frame,msg,guid)
	local aframe = ui.GetFrame("ancient_card_list");
	local card = session.ancient.GetAncientCardByGuid(guid)
	local ctrlSet = GET_CHILD_RECURSIVELY(aframe,"SET_"..card.slot)
	local lckbtn = GET_CHILD_RECURSIVELY(ctrlSet,"lockbtn"..card.slot)
	if lckbtn ~= nil then
		if card.isLock == true then
			lckbtn:SetText("{#FF0000}{ol}Locked");
		else
			lckbtn:SetText("{ol}Lock");
		end
	end
end	
