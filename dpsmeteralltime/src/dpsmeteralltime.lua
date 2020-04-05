local addonName			= "DPSMETERALLTIME"
local author			= "XINXS"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require('acutil')
local settingsFileLoc = string.format("../addons/%s/settings.json", string.lower(addonName));
g.settings = {x = 500, y = 50, mini = 0, skillN = 10};
local loaded = false;
local isON = false;
local damage_meter_info_total = {}

function DPSMETERALLTIME_LOAD()
  if loaded == true then return end
  local t, err = acutil.loadJSON(settingsFileLoc);
  if not err then
    g.settings = t;
    loaded = true;
  end
end

function DPSMETERALLTIME_ON_INIT(addon, frame)
	DPSMETERALLTIME_LOAD()
    addon:RegisterMsg('GAME_START', 'DPSMETERALLTIME_UI_OPEN');
	addon:RegisterMsg('WEEKLY_BOSS_DPS_START', 'DPSMETERALLTIME_CHECK');
	frame:SetEventScript(ui.LBUTTONUP, "DPSMETERALLTIME_SAVEPOS");
	acutil.slashCommand('/dmat', DPSMETERALLTIME_CMD);
	acutil.slashCommand('/DMAT', DPSMETERALLTIME_CMD);
end
function DPSMETERALLTIME_CMD()
	local frame = ui.GetFrame('dpsmeteralltime')
	if frame:IsVisible() == 1 then
		DPSMETERALLTIME_STOP()
		frame:ShowWindow(0)
	else
		DPSMETERALLTIME_UI_OPEN(frame)
	end
end
function DPSMETERALLTIME_CHECK()
	local frame = ui.GetFrame('dpsmeteralltime')
    frame:StopUpdateScript("DPSMETERALLTIME_UPDATE_DPS")
	frame:ShowWindow(0)
end

function DPSMETERALLTIME_UI_OPEN(frame)
	local frame = ui.GetFrame('dpsmeteralltime')
    frame:ShowWindow(1)
    local button = GET_CHILD_RECURSIVELY(frame,"startmeter")
    button:SetEnable(1)
	button = GET_CHILD_RECURSIVELY(frame,"stopmeter")
    button:SetEnable(0)
	DPSMETERALLTIME_INIT(frame)
end

function DPSMETERALLTIME_INIT(frame)
	
	local rbutton = GET_CHILD_RECURSIVELY(frame,"resetmeter")
	local cbutton = GET_CHILD_RECURSIVELY(frame,"config")
	
	if g.settings.mini == 1 then
		rbutton:ShowWindow(0)
		cbutton:ShowWindow(0)
		frame:Resize(120,35)
	else
		rbutton:ShowWindow(1)
		cbutton:ShowWindow(1)
		frame:SetUserValue("DPSINFO_INDEX","0")
		frame:SetUserValue("TOTAL_DAMAGE","0")
		frame:Resize(253,175)
	end

	frame:SetOffset(g.settings.x, g.settings.y)

    damage_meter_info_total = {}
    
    DPSMETERALLTIME_RESET_GAUGE(frame)
end

function DPSMETERALLTIME_RESET_GAUGE(frame)
    local damageRankGaugeBox = GET_CHILD_RECURSIVELY(frame,"damageRankGaugeBox")
    damageRankGaugeBox:RemoveAllChild()

    DPSMETERALLTIME_TOTAL_DAMAGE(frame,0)
end

function DPSMETERALLTIME_TOTAL_DAMAGE(frame,accDamage)
    accDamage = STR_KILO_CHANGE(accDamage)
    local font = frame:GetUserConfig('GAUGE_FONT');
    local damageAccGaugeBox = GET_CHILD_RECURSIVELY(frame,'damageAccGaugeBox')
    local ctrlSet = damageAccGaugeBox:CreateOrGetControlSet('gauge_with_two_text', 'GAUGE_ACC', 0, 0);

    DPSMETERALLTIME_GAUGE_SET(ctrlSet,'',100,font..accDamage,'gauge_damage_meter_accumulation')
end

function DPSMETERALLTIME_GAUGE_SET(ctrl,leftStr,point,rightStr,skin)
    local leftText = GET_CHILD_RECURSIVELY(ctrl,'leftText')
    leftText:SetTextByKey('value',leftStr)
    
    local rightText = GET_CHILD_RECURSIVELY(ctrl,'rightText')
    rightText:SetTextByKey('value',rightStr)
    
    local guage = GET_CHILD_RECURSIVELY(ctrl,'gauge')
    guage:SetPoint(point,100)
    guage:SetSkinName(skin)
end

function DPSMETERALLTIME_UPDATE_DPS(frame)

    local idx = frame:GetUserValue("DPSINFO_INDEX")
    if idx == nil then
        return 1;
    end
    local cnt = session.dps.Get_allDpsInfoSize()
    if idx == cnt then
        return 1;
    end
    
    AUTO_CAST(frame)
    local totalDamage = frame:GetUserValue("TOTAL_DAMAGE");

    local damageRankGaugeBox = GET_CHILD_RECURSIVELY(frame,"damageRankGaugeBox")
    local gaugeCnt = damageRankGaugeBox:GetChildCount()
    local maxGaugeCount = 5

    for i = idx, cnt - 1 do
        local info = session.dps.Get_alldpsInfoByIndex(i)
            local damage = info:GetStrDamage();
            if damage ~= '0' then
                local sklID = info:GetSkillID();
                local sklCls = GetClassByType("Skill",sklID)
                local keyword = TryGetProp(sklCls,"Keyword","None")
                keyword = StringSplit(keyword,';')
                for i = 1,#keyword do
                    if keyword[i] == 'NormalSkill' then
                        sklID = 1
                        break;
                    end
                end
                --if table.find(keyword, "pcSummonSkill") > 0 then
                 --   sklID = 163915
                --end
                --update gauge damage info
                local function getIndex(table, val)
                    for i=1,#table do
                    if table[i][1] == val then 
                        return i
                    end
                    end
                    return #table+1
                end

                --add damage info
                local info_idx = getIndex(damage_meter_info_total,sklID)
                if damage_meter_info_total[info_idx] == nil then
                    damage_meter_info_total[info_idx] = {sklID,damage}
                else
                    damage_meter_info_total[info_idx][2] = SumForBigNumberInt64(damage,damage_meter_info_total[info_idx][2])
                end

                totalDamage = SumForBigNumberInt64(damage,totalDamage)
            end
    end
    table.sort(damage_meter_info_total,function(a,b) return IsGreaterThanForBigNumber(a[2],b[2])==1 end)
    frame:SetUserValue("DPSINFO_INDEX",cnt)
    UPDATE_DPSMETERALLTIME_GUAGE(frame,damageRankGaugeBox)
    DPSMETERALLTIME_TOTAL_DAMAGE(frame,totalDamage)
    frame:SetUserValue("TOTAL_DAMAGE",totalDamage)
    return 1;
end

function UPDATE_DPSMETERALLTIME_GUAGE(frame,groupbox)
    if #damage_meter_info_total == 0 then
        return
    end
    local maxDamage = damage_meter_info_total[1][2]
    local font = frame:GetUserConfig('GAUGE_FONT');
    local cnt = math.min(g.settings.skillN,#damage_meter_info_total)
    for i = 1, cnt do
        local sklID = damage_meter_info_total[i][1]
        local damage = damage_meter_info_total[i][2]
        local skl = GetClassByType("Skill",sklID)

        if skl ~= nil then
            local ctrlSet = groupbox:GetControlSet('gauge_with_two_text', 'GAUGE_'..i)
            if ctrlSet == nil then
                ctrlSet = DPSMETERALLTIME_GAUGE_APPEND(frame,groupbox,i)
            end
            local point = MultForBigNumberInt64(damage,"100")
            point = DivForBigNumberInt64(point,maxDamage)
            local skin = 'gauge_damage_meter_0'..math.min(i,4)
            damage = font..STR_KILO_CHANGE(damage)
			
			local finalSkillName = skl.Name;
			local keyword = TryGetProp(skl,"Keyword","None");
            keyword = StringSplit(keyword,';');
			if table.find(keyword, "pcSummonSkill") > 0 then
				finalSkillName = DPSMETERALLTIME_CLEANSUMMONSTRING(skl.ClassName);
			end
			
            DPSMETERALLTIME_GAUGE_SET(ctrlSet,font..finalSkillName,point,font..damage,skin);
        end
    end
end

function DPSMETERALLTIME_GAUGE_APPEND(frame,groupbox, index)
    local height = 17
    local ctrlSet = groupbox:CreateControlSet('gauge_with_two_text', 'GAUGE_'..index, 0, (index-1)*height);
    if index <= g.settings.skillN then
        frame:Resize(frame:GetWidth(),frame:GetHeight()+height)
        groupbox:Resize(groupbox:GetWidth(),groupbox:GetHeight()+height)
    end
    return ctrlSet
end

function DPSMETERALLTIME_CLEANSUMMONSTRING(summonskill)
	summonskill = string.gsub(summonskill, "Mon_pc_summon_", "");
	summonskill = string.gsub(summonskill, "Mon_pcskill_", "");
	summonskill = string.gsub(summonskill, "boss_", "");
	summonskill = string.gsub(summonskill, "Mon_", "");
	summonskill = string.gsub(summonskill, "shogogoth", "Shoggoth");
	summonskill = string.gsub(summonskill, "Saloon", "Salamion");
	summonskill = string.gsub(summonskill, "skullarcher", "SkullArcher");
	summonskill = string.gsub(summonskill, "skullwizard", "SkullWizard");
	summonskill = string.gsub(summonskill, "bone", "BonePointing");
	summonskill = string.gsub(summonskill, "Zawra", "Zaura");
	summonskill = string.gsub(summonskill, "froster_lord", "FrosterLord");
	summonskill = string.gsub(summonskill, "Marnoks", "Marnox");
	summonskill = string.gsub(summonskill, "lecifer", "Rexipher");
	summonskill = string.gsub(summonskill, "SwordBallista", "Gorkas");
	summonskill = string.gsub(summonskill, "_", " ");
	return summonskill;
end


function DPSMETERALLTIME_STOP()
	local frame = ui.GetFrame('dpsmeteralltime')
    frame:StopUpdateScript("DPSMETERALLTIME_UPDATE_DPS");
    session.dps.ReqStopDps();

    local button = GET_CHILD_RECURSIVELY(frame,"startmeter")
    button:SetEnable(1)
	button = GET_CHILD_RECURSIVELY(frame,"stopmeter")
    button:SetEnable(0)
	isON = false
end

function DPSMETERALLTIME_START()
	local frame = ui.GetFrame('dpsmeteralltime')
	session.dps.ReqStartDpsPacket();
    frame:RunUpdateScript("DPSMETERALLTIME_UPDATE_DPS", 0.1);
	
	local button = GET_CHILD_RECURSIVELY(frame,"startmeter")
    button:SetEnable(0)
	button = GET_CHILD_RECURSIVELY(frame,"stopmeter")
    button:SetEnable(1)
	isON = true
end

function DPSMETERALLTIME_RESET()
	local frame = ui.GetFrame('dpsmeteralltime')
	
	frame:StopUpdateScript("DPSMETERALLTIME_UPDATE_DPS");
    session.dps.ReqStopDps();
	
	DPSMETERALLTIME_INIT(frame)
	
	if isON == true then
		session.dps.ReqStartDpsPacket();
		frame:RunUpdateScript("DPSMETERALLTIME_UPDATE_DPS", 0.1);
	end
end

function DPSMETERALLTIME_MINIMIZE()
	local frame = ui.GetFrame('dpsmeteralltime')
	
	if g.settings.mini == 0 then
		g.settings.mini = 1
		DPSMETERALLTIME_RESET()
		DPSMETERALLTIME_STOP()
		DPSMETERALLTIME_INIT(frame)
	else
		g.settings.mini = 0
		DPSMETERALLTIME_INIT(frame)
	end
	acutil.saveJSON(settingsFileLoc, g.settings)
end

function DPSMETERALLTIME_SAVEPOS()
	local frame = ui.GetFrame("dpsmeteralltime");
	g.settings.x = frame:GetX();
	g.settings.y = frame:GetY();
	acutil.saveJSON(settingsFileLoc, g.settings)
end

function DPSMETERALLTIME_CONFIG()
	INPUT_STRING_BOX_CB(nil,'How many skills to show?  (Default = 10)', 'DPSMETERALLTIME_SKILLNUMBER', '', nil, nil, 2);
end

function DPSMETERALLTIME_SKILLNUMBER(n, frame)
	if tonumber(n) ~= nil and tonumber(n) >= 1 then
		if tonumber(n) < g.settings.skillN then 
			g.settings.skillN = tonumber(n)
			DPSMETERALLTIME_RESET()
			acutil.saveJSON(settingsFileLoc, g.settings)
		else
			g.settings.skillN = tonumber(n)
			acutil.saveJSON(settingsFileLoc, g.settings)
		end
	end
end