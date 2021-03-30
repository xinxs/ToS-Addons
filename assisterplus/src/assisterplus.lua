local addonName = "ASSISTERPLUS"
local author = "XINXS"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require('acutil')
local settingsFileLoc = string.format("../addons/%s/settings.json", string.lower(addonName));
g.settings = {saves = {}, lastset = ""};
local loaded = false;
local filterlist = {ison = false, filtertype = "none", argN = -1};

local ANCIENT_INFO_TAB = 0
local ANCIENT_COMBINE_TAB = 1
local ANCIENT_EVOLVE_TAB = 2
local ANCIENT_PAGE_SIZE = 20
local ANCIENT_MAIN_SLOT_NUM = 4

function ASSISTERPLUS_LOAD()
	if loaded == true then return end
	local t, err = acutil.loadJSON(settingsFileLoc);
	if not err then
		g.settings = t;
		if g.settings.lastset == nil then
			g.settings.lastset = "";
		end
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
	g.settings.lastset = setname;
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
		g.settings.lastset = setname;
	end
	acutil.saveJSON(settingsFileLoc, g.settings);
end

function ASSISTERPLUS_DELETEBTN()
	ui.MsgBox("Delete set?","ASSISTERPLUS_DELETESET","")
end

function ASSISTERPLUS_DELETESET()
	local frame = ui.GetFrame("ancient_card_list");
	local droplist = GET_CHILD(frame, "ADropList", "ui::CDropList");
	local setname = tostring(droplist:GetSelItemKey());
	g.settings.saves[setname] = nil;
	if g.settings.lastset == setname then
		g.settings.lastset = "";
	end
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
		local sortlist = {};
		local cnt = 1;
		for x in spairs(g.settings.saves, function(t, a, b) return a < b end) do
			sortlist[cnt] = {};
			sortlist[cnt] = x;
			cnt = cnt + 1;
		end

		for k, v in ipairs(sortlist) do
			DropList:AddItem(v, v)
		end
	end
	if g.settings.lastset ~= nil then
		DropList:SelectItemByKey(g.settings.lastset);
	end
	
	--save, delete
	local deletebtn = frame:CreateOrGetControl('button', 'delbtn', 438, 75, 20, 20);
	deletebtn:SetText("{#FF0000}{ol}X");
	deletebtn:SetEventScript(ui.LBUTTONUP,"ASSISTERPLUS_DELETEBTN");
	local savebtn = frame:CreateOrGetControl('button', 'sbtn', 612, 75, 85, 20);
	savebtn:SetText("{ol}Save");
	savebtn:SetEventScript(ui.LBUTTONUP,"ASSISTERPLUS_SAVEBTN");

	--rarityfilter
	local cIcon = frame:CreateOrGetControl('button', "btnico_1", 230, 387, 18, 24);
	cIcon:SetSkinName("test_normal_button");
	cIcon:SetText(string.format("{img normal_card %d %d}", 18, 24));
	cIcon:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	cIcon:SetEventScriptArgString(ui.LBUTTONDOWN, "rarity");
	cIcon:SetEventScriptArgNumber(ui.LBUTTONDOWN, 1);
	
	cIcon = frame:CreateOrGetControl('button', "btnico_2", 250, 387, 18, 24);
	cIcon:SetSkinName("test_normal_button");
	cIcon:SetText(string.format("{img rare_card %d %d}", 18, 24));
	cIcon:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	cIcon:SetEventScriptArgString(ui.LBUTTONDOWN, "rarity");
	cIcon:SetEventScriptArgNumber(ui.LBUTTONDOWN, 2);
	
	cIcon = frame:CreateOrGetControl('button', "btnico_3", 270, 387, 18, 24);
	cIcon:SetSkinName("test_normal_button");
	cIcon:SetText(string.format("{img unique_card %d %d}", 18, 24));
	cIcon:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	cIcon:SetEventScriptArgString(ui.LBUTTONDOWN, "rarity");
	cIcon:SetEventScriptArgNumber(ui.LBUTTONDOWN, 3);
	
	cIcon = frame:CreateOrGetControl('button', "btnico_4", 290, 387, 18, 24);
	cIcon:SetSkinName("test_normal_button");
	cIcon:SetText(string.format("{img legend_card %d %d}", 18, 24));
	cIcon:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	cIcon:SetEventScriptArgString(ui.LBUTTONDOWN, "rarity");
	cIcon:SetEventScriptArgNumber(ui.LBUTTONDOWN, 4);
	
	--starfilter
	local starbtn = frame:CreateOrGetControl('button', 'starbutton_1', 315, 385, 30, 30);
	starbtn:SetSkinName("test_normal_button");
	starbtn:SetText(string.format("{img monster_card_starmark %d %d}", 12, 12));
	starbtn:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	starbtn:SetEventScriptArgString(ui.LBUTTONDOWN, "stars");
	starbtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, 1);
	
	starbtn = frame:CreateOrGetControl('button', 'starbutton_2', 339, 385, 30, 30);
	starbtn:SetSkinName("test_normal_button");
	starbtn:SetText(string.format("{img monster_card_starmark %d %d}", 12, 12) .. string.format("{img monster_card_starmark %d %d}", 12, 12));
	starbtn:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	starbtn:SetEventScriptArgString(ui.LBUTTONDOWN, "stars");
	starbtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, 2);
	
	starbtn = frame:CreateOrGetControl('button', 'starbutton_3', 365, 385, 32, 30);
	starbtn:SetSkinName("test_normal_button");
	starbtn:SetText(string.format("{img monster_card_starmark %d %d}", 12, 12) .. string.format("{img monster_card_starmark %d %d}", 12, 12) .. string.format("{img monster_card_starmark %d %d}", 12, 12));
	starbtn:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_FILTERLIST_BTN');
	starbtn:SetEventScriptArgString(ui.LBUTTONDOWN, "stars");
	starbtn:SetEventScriptArgNumber(ui.LBUTTONDOWN, 3);
	
	--allbtn
	local allbtn = frame:CreateOrGetControl('button', 'allbutton', 415, 384, 40, 32);
	allbtn:SetSkinName("test_normal_button");
	allbtn:SetText("{#BABABA}{ol}ALL");
	allbtn:SetEventScript(ui.LBUTTONDOWN, 'ASSISTERPLUS_ALLBTN');	
end

function ASSISTERPLUS_ALLBTN()
	local frame = ui.GetFrame("ancient_card_list");
	filterlist.ison = false;
	INIT_ANCIENT_CARD_LIST_ALL(frame);
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
	acutil.setupHook(INIT_ANCIENT_CARD_LIST_ALL_HOOKED, "INIT_ANCIENT_CARD_LIST_ALL");
	--acutil.setupHook(ANCIENT_CARD_COMBINE_LIST_LOAD_HOOKED, "ANCIENT_CARD_COMBINE_LIST_LOAD");
end

function ANCIENT_CARD_LIST_OPEN_HOOKED(aframe)
	local frame = ui.GetFrame("ancient_card_list");
	local tab = frame:GetChild("tab")
    AUTO_CAST(tab);
    if tab ~= nil then
        tab:SelectTab(0);
        ANCIENT_CARD_LIST_TAB_CHANGE(frame)
    end
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

    SET_CARD_LOCK_MODE(ctrlSet,isLockMode)
    if card.isNew == true then
        local slot = GET_CHILD_RECURSIVELY(ctrlSet,'ancient_card_slot')
        slot:SetHeaderImage('new_inventory_icon');
    end
    if card.isLock == true then
        local slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_slot")
        local lock = slot:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0);
        lock:SetGravity(ui.RIGHT, ui.TOP);
        local remove = GET_CHILD_RECURSIVELY(ctrlSet,"sell_btn")
        remove:SetEnable(0)
	end
    local pic_bg = GET_CHILD_RECURSIVELY(ctrlSet,"graybg")
												   
    if IS_VALID_ANCIENT_CARD(gbox:GetTopParentFrame(),card) == true then
        pic_bg:ShowWindow(0)
        ctrlSet:EnableHitTest(1)
    else
        pic_bg:ShowWindow(1)
        local pic = GET_CHILD(pic_bg,"gray")
        pic:SetAlpha(70)
        ctrlSet:EnableHitTest(0)
	end
    return ctrlSet

end

function ASSISTERPLUS_FILTERLIST_BTN(parent, FromctrlSet, argStr, argNum)
	local frame = ui.GetFrame("ancient_card_list");
	local tab = frame:GetChild("tab");
	AUTO_CAST(tab);
	--local index = tab:GetSelectItemIndex();
	ASSISTERPLUS_LIST_ALL(frame, argStr, argNum)
end

function ASSISTERPLUS_LIST_ALL(frame, argStr, argNum)
	filterlist.ison = true;
	filterlist.filtertype = argStr;
	filterlist.argN = argNum;
	INIT_ANCIENT_CARD_SLOTS(frame,0)

	frame = frame:GetTopParentFrame()
    local pageCtrl = GET_CHILD_RECURSIVELY(frame,"card_page_control")
    local page = pageCtrl:GetCurPage()
    local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,"ancient_card_list_Gbox")
    ancient_card_list_Gbox:RemoveAllChild()
	local count = session.ancient.GetAncientCardCount()
    for i = 0, count-1 do
        local card = session.ancient.GetAncientCardByIndex(i)
        if card == nil then
            break
        end
		if argStr == "rarity" and argNum == card.rarity then
			local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
		elseif argStr == "stars" and argNum == card.starrank then
			local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
		end    
    end
end

function INIT_ANCIENT_CARD_LIST_ALL_HOOKED(frame,func)
	if filterlist.ison then
		ASSISTERPLUS_LIST_ALL(frame, filterlist.filtertype, filterlist.argN);
		return
	end
	
	frame = frame:GetTopParentFrame()
    local pageCtrl = GET_CHILD_RECURSIVELY(frame,"card_page_control")
    local page = pageCtrl:GetCurPage()
    local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,"ancient_card_list_Gbox")
    ancient_card_list_Gbox:RemoveAllChild()
    for i = page*ANCIENT_PAGE_SIZE, (page+1)*ANCIENT_PAGE_SIZE-1 do
        local card = session.ancient.GetAncientCardByIndex(i)
        if card == nil then
            break
        end
        local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
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
