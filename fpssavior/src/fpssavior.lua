local addonName = "FPSSAVIOR"
local author = "XINXS"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName];
g.saviormode = {"{#2D9B27}{ol}HIGH","{#F2F407}{ol}MEDIUM","{#284B7E}{ol}LOW","{#532881}{ol}UltraLOW"};

local acutil = require("acutil");
CHAT_SYSTEM("FPS Savior loaded! Help: /fpssavior help");

function FPSSAVIOR_ON_INIT(addon, frame)
	frame:ShowWindow(1);
	acutil.slashCommand("/fpssavior",FPSSAVIOR_CMD);
	addon:RegisterMsg("GAME_START", "FPSSAVIOR_START");
	addon:RegisterMsg("FPS_UPDATE", "FPSSAVIOR_SHOWORHIDE_OBJ");
	
	FPSSAVIOR_LOADSETTINGS();
end

function FPSSAVIOR_LOADSETTINGS()
	local settings, error = acutil.loadJSON("../addons/fpssavior/settings.json");
	if error then
		FPSSAVIOR_SAVESETTINGS();
		return
	end
	if settings.allplayers == nil then
		settings.allplayers = 0;
		settings.onlypt = 0;
		settings.allsum = 0;
		settings.onlymy = 0;
	end
		g.settings = settings;
end

function FPSSAVIOR_SAVESETTINGS()
	if g.settings == nil then
		g.settings = {
			saviorToggle = 2,
			displayX = 510,
			displayY = 920,
			lock = 1,
			allplayers = 0,
			onlypt = 0,
			allsum = 0,
			onlymy = 0
		};
	end
	acutil.saveJSON("../addons/fpssavior/settings.json", g.settings);
end

function FPSSAVIOR_START_DRAG()
	saviorFrame.isDragging = true;
end

function FPSSAVIOR_END_DRAG()
	g.settings.displayX = saviorFrame:GetX();
	g.settings.displayY = saviorFrame:GetY();
	FPSSAVIOR_SAVESETTINGS();
	saviorFrame.isDragging = false;
end

function FPSSAVIOR_START()
	saviorFrame = ui.GetFrame("fpssaviorframe");
	if saviorFrame == nil then
		saviorFrame = ui.CreateNewFrame("fpssavior","fpssaviorframe");
		saviorFrame:SetBorder(0, 0, 0, 0);
		saviorFrame:Resize(100,60)
		saviorFrame:SetOffset(g.settings.displayX, g.settings.displayY);
		saviorFrame:ShowWindow(1);
		saviorFrame:SetLayerLevel(61);
		saviorFrame.isDragging = false;
		saviorFrame:SetEventScript(ui.LBUTTONDOWN, "FPSSAVIOR_START_DRAG");
		saviorFrame:SetEventScript(ui.LBUTTONUP, "FPSSAVIOR_END_DRAG");
		saviorFrame:EnableMove(0);
		g.settings.lock = 1;
		FPSSAVIOR_SAVESETTINGS();
		
		saviorText = saviorFrame:CreateOrGetControl("richtext","saviortext",0,0,0,0);
		saviorText = tolua.cast(saviorText,"ui::CRichText");
		saviorText:SetGravity(ui.LEFT,ui.CENTER_VERT);
		saviorText:SetText("{s18}".. g.saviormode[g.settings.saviorToggle]);
		
		btnsaviorC = saviorFrame:CreateOrGetControl('button', 'btnc', 0, 0, 16, 16); 
		btnsaviorC:SetOffset(84, 20);
		btnsaviorC:SetText(string.format("{img chat_option2_btn %d %d}", 16, 16));
		btnsaviorC:SetEventScript(ui.LBUTTONDOWN, 'FPSSAVIOR_OPENCONFIG');
		
		btnsaviorH = saviorFrame:CreateOrGetControl('button', 'btnh', 0, 0, 25, 20); 
		btnsaviorH:SetOffset(0, 40); 
		btnsaviorH:SetText("{s16}{#2D9B27}{ol}H");
		btnsaviorH:SetEventScript(ui.LBUTTONDOWN, 'FPSSAVIOR_HIGH');
		
		btnsaviorM = saviorFrame:CreateOrGetControl('button', 'btnm', 0, 0, 25, 20); 
		btnsaviorM:SetOffset(25, 40); 
		btnsaviorM:SetText("{s16}{#F2F407}{ol}M");
		btnsaviorM:SetEventScript(ui.LBUTTONDOWN, 'FPSSAVIOR_MEDIUM');
		
		btnsaviorL = saviorFrame:CreateOrGetControl('button', 'btnl', 0, 0, 25, 20); 
		btnsaviorL:SetOffset(50, 40); 
		btnsaviorL:SetText("{s16}{#284B7E}{ol}L");
		btnsaviorL:SetEventScript(ui.LBUTTONDOWN, 'FPSSAVIOR_LOW');

		btnsaviorUlow = saviorFrame:CreateOrGetControl('button', 'btnul', 0, 0, 25, 20); 
		btnsaviorUlow:SetOffset(75, 40); 
		btnsaviorUlow:SetText("{s16}{#532881}{ol}UL");
		btnsaviorUlow:SetEventScript(ui.LBUTTONDOWN, 'FPSSAVIOR_ULOW');
	end
	if not saviorFrame.isDragging then
		saviorFrame:SetOffset(g.settings.displayX, g.settings.displayY);
	end
	if g.settings.saviorToggle == 1 then
		FPSSAVIOR_HIGH();
	elseif g.settings.saviorToggle == 2 then
		FPSSAVIOR_MEDIUM();
	elseif g.settings.saviorToggle == 3 then
		FPSSAVIOR_LOW();
	else
		FPSSAVIOR_ULOW();
	end
end

function FPSSAVIOR_OPENCONFIG()
	local configframe = ui.GetFrame('fpssaviorconfig');
	if  configframe ~= nil and configframe:IsVisible() == 1  then
		configframe:ShowWindow(0);
	else
		FPSSAVIOR_CONFIGFRAME();
	end
end

function FPSSAVIOR_CONFIGFRAME()
	local configframe = ui.GetFrame('fpssaviorconfig');
	if configframe == nil then
		configframe = ui.CreateNewFrame("fpssavior","fpssaviorconfig");
		configframe:SetSkinName("pip_simple_frame");
		configframe:Resize(170,152);
		configframe:SetLayerLevel(62);
	end
	configframe:ShowWindow(1);
	local mainX = ui.GetFrame("fpssaviorframe"):GetX();
	local mainY = ui.GetFrame("fpssaviorframe"):GetY();
	if mainY < 210 then
		configframe:SetOffset(mainX,mainY+60);
	else
		configframe:SetOffset(mainX,mainY-134);
	end
	
	local playerText = configframe:CreateOrGetControl("richtext","playertext",5,10,0,0);
	playerText:SetText("{ol}Players:");
	local playerBox = configframe:CreateOrGetControl('checkbox', 'allplayersbox', 5, 32, 100, 20)
	playerBox:SetText("{ol}Hide all");
	playerBox:SetEventScript(ui.LBUTTONUP,"FPSSAVIOR_SAVECONFIGFRAME1");
	--playerBox:SetEventScriptArgString(ui.LBUTTONUP, "allplayers");
	local playerBoxchild = GET_CHILD(configframe, "allplayersbox");
	playerBoxchild:SetCheck(g.settings.allplayers);
	playerBox = configframe:CreateOrGetControl('checkbox', 'onlyptbox', 5, 54, 100, 20)
	playerBox:SetText("{ol}Show pt/guild only");
	playerBox:SetEventScript(ui.LBUTTONUP,"FPSSAVIOR_SAVECONFIGFRAME2");
	--playerBox:SetEventScriptArgString(ui.LBUTTONUP, "onlypt");
	playerBoxchild = GET_CHILD(configframe, "onlyptbox");
	playerBoxchild:SetCheck(g.settings.onlypt);
		
	local summonText = configframe:CreateOrGetControl("richtext","summontext",5,80,0,0);
	summonText:SetText("{ol}Summons:");
	local summonBox = configframe:CreateOrGetControl('checkbox', 'allsumbox', 5, 102, 100, 20)
	summonBox:SetText("{ol}Hide all");
	summonBox:SetEventScript(ui.LBUTTONUP,"FPSSAVIOR_SAVECONFIGFRAME3");
	--summonBox:SetEventScriptArgString(ui.LBUTTONUP, "allsum");
	local summonBoxchild = GET_CHILD(configframe, "allsumbox");
	summonBoxchild:SetCheck(g.settings.allsum);
	summonBox = configframe:CreateOrGetControl('checkbox', 'onlymybox', 5, 124, 100, 20)
	summonBox:SetText("{ol}Show mine only");
	summonBox:SetEventScript(ui.LBUTTONUP,"FPSSAVIOR_SAVECONFIGFRAME4");
	--summonBox:SetEventScriptArgString(ui.LBUTTONUP, "onlymy");
	summonBoxchild = GET_CHILD(configframe, "onlymybox");
	summonBoxchild:SetCheck(g.settings.onlymy);	
end

function FPSSAVIOR_SAVECONFIGFRAME1()
	local configframe = ui.GetFrame('fpssaviorconfig');
	local playerBoxchild = GET_CHILD(configframe, "allplayersbox");
	if playerBoxchild:IsChecked() == 1 then
			g.settings.allplayers = 1;
			g.settings.onlypt = 0;
			playerBoxchild = GET_CHILD(configframe, "onlyptbox");
			playerBoxchild:SetCheck(g.settings.onlypt);
	else
			g.settings.allplayers = 0;
	end
	acutil.saveJSON("../addons/fpssavior/settings.json", g.settings);
	--FPSSAVIOR_CONFIGFRAME()
end
function FPSSAVIOR_SAVECONFIGFRAME2()
	local configframe = ui.GetFrame('fpssaviorconfig');
	local playerBoxchild = GET_CHILD(configframe, "onlyptbox");
	if playerBoxchild:IsChecked() == 1 then
			g.settings.allplayers = 0;
			g.settings.onlypt = 1;
			playerBoxchild = GET_CHILD(configframe, "allplayersbox");
			playerBoxchild:SetCheck(g.settings.allplayers);
	else
			g.settings.onlypt = 0;
	end
	acutil.saveJSON("../addons/fpssavior/settings.json", g.settings);
	--FPSSAVIOR_CONFIGFRAME()
end
function FPSSAVIOR_SAVECONFIGFRAME3()
	local configframe = ui.GetFrame('fpssaviorconfig');
	local summonBoxchild = GET_CHILD(configframe, "allsumbox");
	if summonBoxchild:IsChecked() == 1 then
			g.settings.allsum = 1;
			g.settings.onlymy = 0;
			summonBoxchild = GET_CHILD(configframe, "onlymybox");
			summonBoxchild:SetCheck(g.settings.onlymy);
	else
			g.settings.allsum = 0;
	end
	acutil.saveJSON("../addons/fpssavior/settings.json", g.settings);
	--FPSSAVIOR_CONFIGFRAME()
end
function FPSSAVIOR_SAVECONFIGFRAME4()
	local configframe = ui.GetFrame('fpssaviorconfig');
	local summonBoxchild = GET_CHILD(configframe, "onlymybox");
	if summonBoxchild:IsChecked() == 1 then
			g.settings.allsum = 0;
			g.settings.onlymy = 1;
			summonBoxchild = GET_CHILD(configframe, "allsumbox");
			summonBoxchild:SetCheck(g.settings.allsum);
	else
			g.settings.onlymy = 0;
	end
	acutil.saveJSON("../addons/fpssavior/settings.json", g.settings);
	--FPSSAVIOR_CONFIGFRAME()
end

function FPSSAVIOR_CMD(command)
	local cmd = "";
	if #command > 0 then
		cmd = table.remove(command, 1);
	else
		FPSSAVIOR_TOGGLE();
		return;
	end
	if cmd == "help" then
		CHAT_SYSTEM("FPS Savior Help:{nl}'/fpssavior' to toggle between 3 predefined settings High, Low, and Ultra Low.{nl}'/fpssavior lock' to unlock/lock the settings display in order to move it around.{nl}'/fpssavior default' to restore the settings display to its default location.");
		return;
	end
	if cmd == "lock" then
		if g.settings.lock == 1 then
			g.settings.lock = 0;
			saviorFrame:EnableHitTest(1);
			saviorText:EnableHitTest(0);
			saviorFrame:EnableMove(1);
			saviorFrame.EnableHittestFrame(saviorFrame, 1);
			CHAT_SYSTEM("Settings display unlocked.");
			FPSSAVIOR_SAVESETTINGS();
		else
			g.settings.lock = 1;
			saviorFrame:EnableHitTest(1);
			saviorFrame:EnableMove(0);
			saviorFrame.EnableHittestFrame(saviorFrame, 1);
			CHAT_SYSTEM("Settings display locked.");
			FPSSAVIOR_SAVESETTINGS();
		end
		return;
	end
	if cmd == "default" then
		g.settings.displayX = 510;
		g.settings.displayY = 920;
		g.settings.lock = 1;
		saviorFrame:SetOffset(g.settings.displayX, g.settings.displayY);
		saviorFrame:EnableHitTest(1);
		saviorFrame:EnableMove(0);
		saviorFrame.EnableHittestFrame(saviorFrame, 1);
		FPSSAVIOR_SAVESETTINGS();
		return;
	end
	CHAT_SYSTEM("Invalid command. Available commands:{nl}/fpssavior{nl}/fpssavior lock{nl}/fpssavior default");
	return;
end

function FPSSAVIOR_SETTEXT()
	if saviorFrame ~= nil then
		saviorText:SetText("{s18}".. g.saviormode[g.settings.saviorToggle]);
	end
end


function FPSSAVIOR_HIGH()
	g.settings.saviorToggle = 1;

	graphic.SetDrawActor(100);
	graphic.SetDrawMonster(100);
	--graphic.EnableFastLoading(0);
	--graphic.EnableBlur(0);
	graphic.EnableBloom(1);
	graphic.EnableCharEdge(1);
	--graphic.EnableDepth(1);
	graphic.EnableFXAA(1);
	graphic.EnableGlow(1);
	graphic.EnableHighTexture(1);
	--graphic.EnableSharp(0);
	graphic.EnableSoftParticle(1);
	graphic.EnableWater(1);  
	imcperfOnOff.EnableIMCEffect(1);
	imcperfOnOff.EnableEffect(1);
	imcperfOnOff.EnableRenderShadow(1); 
	imcperfOnOff.EnablePlaneLight(1);
	imcperfOnOff.EnableWater(1);
	
	--lowmodeconfig
	graphic.EnableLowOption(0);
	config.SetAutoAdjustLowLevel(2);
	config.SaveConfig();
	
	FPSSAVIOR_SETTEXT();
	FPSSAVIOR_SAVESETTINGS();
end

function FPSSAVIOR_MEDIUM()
	g.settings.saviorToggle = 2;
		
	graphic.SetDrawActor(40);
	graphic.SetDrawMonster(50);
	--graphic.EnableFastLoading(1);
	--graphic.EnableBlur(0);
	graphic.EnableBloom(0);
	graphic.EnableCharEdge(1);
	--graphic.EnableDepth(0);
	graphic.EnableFXAA(1);
	graphic.EnableGlow(1);
	graphic.EnableHighTexture(1);
	--graphic.EnableSharp(0);
	graphic.EnableSoftParticle(0);
	graphic.EnableWater(0); 
	imcperfOnOff.EnableIMCEffect(1);
	imcperfOnOff.EnableEffect(1);
	imcperfOnOff.EnableRenderShadow(0);
	imcperfOnOff.EnablePlaneLight(1);
	imcperfOnOff.EnableWater(1);
		
	--lowmodeconfig
	graphic.EnableLowOption(0);
	config.SetAutoAdjustLowLevel(2);
	config.SaveConfig();
		
	FPSSAVIOR_SETTEXT();
	FPSSAVIOR_SAVESETTINGS()
end

function FPSSAVIOR_LOW()
	g.settings.saviorToggle = 3;
		
	graphic.SetDrawActor(30);
	graphic.SetDrawMonster(30);
	--graphic.EnableFastLoading(1);
	--graphic.EnableBlur(0);
	graphic.EnableBloom(0);
	graphic.EnableCharEdge(0);
	--graphic.EnableDepth(0);
	graphic.EnableFXAA(0);
	graphic.EnableGlow(1);
	graphic.EnableHighTexture(0);
	--graphic.EnableSharp(0);
	graphic.EnableSoftParticle(0);
	graphic.EnableWater(0); 
	imcperfOnOff.EnableIMCEffect(1);
	imcperfOnOff.EnableEffect(1);
	imcperfOnOff.EnableRenderShadow(0); 
	imcperfOnOff.EnablePlaneLight(0);
	imcperfOnOff.EnableWater(0);
		
	--lowmodeconfig
	graphic.EnableLowOption(1);
	config.SetAutoAdjustLowLevel(0);
	config.SaveConfig();
	
	FPSSAVIOR_SETTEXT();
	FPSSAVIOR_SAVESETTINGS()
end

function FPSSAVIOR_ULOW()
	g.settings.saviorToggle = 4;
		
	graphic.SetDrawActor(20);
	graphic.SetDrawMonster(30);
	--graphic.EnableFastLoading(1);
	--graphic.EnableBlur(0);
	graphic.EnableBloom(0);
	graphic.EnableCharEdge(0);
	--graphic.EnableDepth(0);
	graphic.EnableFXAA(0);
	graphic.EnableGlow(0);
	graphic.EnableHighTexture(0);
	--graphic.EnableSharp(0);
	graphic.EnableSoftParticle(0);
	graphic.EnableWater(0); 
	imcperfOnOff.EnableIMCEffect(0);
	imcperfOnOff.EnableEffect(0);
	imcperfOnOff.EnableRenderShadow(0); 
	imcperfOnOff.EnablePlaneLight(0);
	imcperfOnOff.EnableWater(0);
		
	--lowmodeconfig
	graphic.EnableLowOption(1);
	config.SetAutoAdjustLowLevel(0);
	config.SaveConfig();
	
	FPSSAVIOR_SETTEXT();
	FPSSAVIOR_SAVESETTINGS()
end

function FPSSAVIOR_TOGGLE()
	if g.settings.saviorToggle == 1 then
		FPSSAVIOR_MEDIUM();
	elseif g.settings.saviorToggle == 2 then
		FPSSAVIOR_LOW();
	elseif g.settings.saviorToggle == 3 then
		FPSSAVIOR_ULOW();
	else
		FPSSAVIOR_HIGH();
	end
end

function FPSSAVIOR_SHOWORHIDE_OBJ()
	if (g.settings.allplayers + g.settings.onlypt + g.settings.allsum + g.settings.onlymy) > 0 then
		local list, cnt = SelectObject(GetMyPCObject(), 650, "ALL");
		for i = 1, cnt do			
			local ObHandle = GetHandle(list[i]);
			local OwHandle = info.GetOwner(ObHandle);
			if (g.settings.allplayers + g.settings.onlypt) > 0 and info.IsPC(ObHandle) == 1 then
				if g.settings.allplayers == 1 then
					world.Leave(ObHandle, 0.0 );
				elseif session.party.GetPartyMemberInfoByName(PARTY_NORMAL, info.GetFamilyName(ObHandle)) == nil and session.party.GetPartyMemberInfoByName(PARTY_GUILD, info.GetFamilyName(ObHandle)) == nil then
					world.Leave(ObHandle, 0.0 );
				end
			elseif (g.settings.allsum + g.settings.onlymy) > 0 and OwHandle ~= 0 then
				if g.settings.allsum == 1 then
					world.Leave(ObHandle, 0.0 );
				elseif OwHandle ~= session.GetMyHandle() then
					world.Leave(ObHandle, 0.0 );
				end
			end
        end
	end	
end