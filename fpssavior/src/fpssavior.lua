_G["FPSSAVIOR"] = {};
_G["FPSSAVIOR"]["saviorMode"] = {"{#2D9B27}{ol}High","{#F2F407}{ol}Medium","{#284B7E}{ol}Low","{#532881}{ol}Ultra Low"};
local acutil = require("acutil");
CHAT_SYSTEM("FPS Savior loaded! Help: /fpssavior help");

function FPSSAVIOR_ON_INIT(addon, frame)
	frame:ShowWindow(1);
	acutil.slashCommand("/fpssavior",FPSSAVIOR_CMD);
	addon:RegisterMsg("GAME_START", "FPSSAVIOR_START");
	addon:RegisterMsg("FPS_UPDATE", "FPSSAVIOR_SHOWORHIDE_FRAMES");
	
	_G["FPSSAVIOR"]["hidden"] = {};
	FPSSAVIOR_LOADSETTINGS();
end

function FPSSAVIOR_LOADSETTINGS()
	local settings, error = acutil.loadJSON("../addons/fpssavior/settings.json");
	if error then
		FPSSAVIOR_SAVESETTINGS();
	else
		_G["FPSSAVIOR"]["settings"] = settings;
	end
end

function FPSSAVIOR_SAVESETTINGS()
	if _G["FPSSAVIOR"]["settings"] == nil then
		_G["FPSSAVIOR"]["settings"] = {
			saviorToggle = 2;
			displayX = 510;
			displayY = 920;
			lock = 1;
		};
	end
	acutil.saveJSON("../addons/fpssavior/settings.json", _G["FPSSAVIOR"]["settings"]);
end

function FPSSAVIOR_START_DRAG()
	saviorFrame.isDragging = true;
end

function FPSSAVIOR_END_DRAG()
	_G["FPSSAVIOR"]["settings"].displayX = saviorFrame:GetX();
	_G["FPSSAVIOR"]["settings"].displayY = saviorFrame:GetY();
	FPSSAVIOR_SAVESETTINGS();
	saviorFrame.isDragging = false;
end

function FPSSAVIOR_START()
	saviorFrame = ui.GetFrame("fpssaviorframe");
	if saviorFrame == nil then
		saviorFrame = ui.CreateNewFrame("fpssavior","fpssaviorframe");
		saviorFrame:SetBorder(0, 0, 0, 0);
		saviorFrame:Resize(100,60)
		saviorFrame:SetOffset(_G["FPSSAVIOR"]["settings"].displayX, _G["FPSSAVIOR"]["settings"].displayY);
		saviorFrame:ShowWindow(1);
		saviorFrame:SetLayerLevel(61);
		saviorFrame.isDragging = false;
		saviorFrame:SetEventScript(ui.LBUTTONDOWN, "FPSSAVIOR_START_DRAG");
		saviorFrame:SetEventScript(ui.LBUTTONUP, "FPSSAVIOR_END_DRAG");
		saviorFrame:EnableMove(0);
		_G["FPSSAVIOR"]["settings"].lock = 1;
		FPSSAVIOR_SAVESETTINGS();
		
		saviorText = saviorFrame:CreateOrGetControl("richtext","saviortext",0,0,0,0);
		saviorText = tolua.cast(saviorText,"ui::CRichText");
		saviorText:SetGravity(ui.LEFT,ui.CENTER_VERT);
		saviorText:SetText("{s16}{#D2B02E}{ol}FPS SAVIOR");
		btnsavior = saviorFrame:CreateOrGetControl('button', 'btn', 0, 0, 100, 20); 
		btnsavior:SetOffset(0, 40); 
		btnsavior:SetText("{s16}".._G["FPSSAVIOR"]["saviorMode"][_G["FPSSAVIOR"]["settings"].saviorToggle]);
		btnsavior:SetEventScript(ui.LBUTTONDOWN, 'FPSSAVIOR_TOGGLE');
	end
	if not saviorFrame.isDragging then
		saviorFrame:SetOffset(_G["FPSSAVIOR"]["settings"].displayX, _G["FPSSAVIOR"]["settings"].displayY);
	end
	if tonumber(config.GetAutoAdjustLowLevel()) ~= 2 then
		config.SetAutoAdjustLowLevel(2);
		config.SaveConfig();
	end
	if _G["FPSSAVIOR"]["settings"].saviorToggle == 1 then
		FPSSAVIOR_HIGH();
	elseif _G["FPSSAVIOR"]["settings"].saviorToggle == 2 then
		FPSSAVIOR_MEDIUM();
	elseif _G["FPSSAVIOR"]["settings"].saviorToggle == 3 then
		FPSSAVIOR_LOW();
	else
		FPSSAVIOR_ULOW();
	end
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
		CHAT_SYSTEM("FPS Savior Help:{nl}'/fpssavior' to toggle between 3 predefined settings High, Low, and Super Low.{nl}'/fpssavior lock' to unlock/lock the settings display in order to move it around.{nl}'/fpssavior default' to restore the settings display to its default location.");
		return;
	end
	if cmd == "lock" then
		if _G["FPSSAVIOR"]["settings"].lock == 1 then
			_G["FPSSAVIOR"]["settings"].lock = 0;
			saviorFrame:EnableHitTest(1);
			saviorText:EnableHitTest(0);
			saviorFrame:EnableMove(1);
			saviorFrame.EnableHittestFrame(saviorFrame, 1);
			CHAT_SYSTEM("Settings display unlocked.");
			FPSSAVIOR_SAVESETTINGS();
		else
			_G["FPSSAVIOR"]["settings"].lock = 1;
			saviorFrame:EnableHitTest(1);
			saviorFrame:EnableMove(0);
			saviorFrame.EnableHittestFrame(saviorFrame, 1);
			CHAT_SYSTEM("Settings display locked.");
			FPSSAVIOR_SAVESETTINGS();
		end
		return;
	end
	if cmd == "default" then
		_G["FPSSAVIOR"]["settings"].displayX = 510;
		_G["FPSSAVIOR"]["settings"].displayY = 920;
		_G["FPSSAVIOR"]["settings"].lock = 1;
		saviorFrame:SetOffset(_G["FPSSAVIOR"]["settings"].displayX, _G["FPSSAVIOR"]["settings"].displayY);
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
		btnsavior:SetText("{s16}".._G["FPSSAVIOR"]["saviorMode"][_G["FPSSAVIOR"]["settings"].saviorToggle]);
	end
end


function FPSSAVIOR_HIGH()
	_G["FPSSAVIOR"]["settings"].saviorToggle = 1;

	graphic.SetDrawActor(100);
	graphic.SetDrawMonster(100);
	graphic.EnableFastLoading(0);
	graphic.EnableBlur(0);
	graphic.EnableBloom(1);
	graphic.EnableCharEdge(1);
	graphic.EnableDepth(1);
	graphic.EnableFXAA(1);
	graphic.EnableGlow(1);
	graphic.EnableHighTexture(1);
	graphic.EnableSharp(0);
	graphic.EnableSoftParticle(1);
	graphic.EnableWater(1);  
	imcperfOnOff.EnableIMCEffect(1);
	imcperfOnOff.EnableEffect(1);
	
	FPSSAVIOR_SETTEXT();
	FPSSAVIOR_SAVESETTINGS();
end

function FPSSAVIOR_MEDIUM()
	_G["FPSSAVIOR"]["settings"].saviorToggle = 2;
		
		graphic.SetDrawActor(30);
		graphic.SetDrawMonster(50);
		graphic.EnableFastLoading(1);
		graphic.EnableBlur(0);
		graphic.EnableBloom(0);
		graphic.EnableCharEdge(1);
		graphic.EnableDepth(0);
		graphic.EnableFXAA(1);
		graphic.EnableGlow(1);
		graphic.EnableHighTexture(1);
		graphic.EnableSharp(0);
		graphic.EnableSoftParticle(0);
		graphic.EnableWater(0); 
		imcperfOnOff.EnableIMCEffect(1);
		imcperfOnOff.EnableEffect(1);
		
		FPSSAVIOR_SETTEXT();
		FPSSAVIOR_SAVESETTINGS()
end

function FPSSAVIOR_LOW()
	_G["FPSSAVIOR"]["settings"].saviorToggle = 3;
		
		graphic.SetDrawActor(15);
		graphic.SetDrawMonster(30);
		graphic.EnableFastLoading(1);
		graphic.EnableBlur(0);
		graphic.EnableBloom(0);
		graphic.EnableCharEdge(0);
		graphic.EnableDepth(0);
		graphic.EnableFXAA(0);
		graphic.EnableGlow(1);
		graphic.EnableHighTexture(0);
		graphic.EnableSharp(0);
		graphic.EnableSoftParticle(0);
		graphic.EnableWater(0); 
		imcperfOnOff.EnableIMCEffect(1);
		imcperfOnOff.EnableEffect(1);
		
		FPSSAVIOR_SETTEXT();
		FPSSAVIOR_SAVESETTINGS()
end

function FPSSAVIOR_ULOW()
	_G["FPSSAVIOR"]["settings"].saviorToggle = 4;
		
		graphic.SetDrawActor(-100);
		graphic.SetDrawMonster(30);
		graphic.EnableFastLoading(1);
		graphic.EnableBlur(0);
		graphic.EnableBloom(0);
		graphic.EnableCharEdge(0);
		graphic.EnableDepth(0);
		graphic.EnableFXAA(0);
		graphic.EnableGlow(0);
		graphic.EnableHighTexture(0);
		graphic.EnableSharp(0);
		graphic.EnableSoftParticle(0);
		graphic.EnableWater(0); 
		imcperfOnOff.EnableIMCEffect(0);
		imcperfOnOff.EnableEffect(0);
		
		FPSSAVIOR_SETTEXT();
		FPSSAVIOR_SAVESETTINGS()
end

function FPSSAVIOR_TOGGLE()
	if _G["FPSSAVIOR"]["settings"].saviorToggle == 1 then
		FPSSAVIOR_MEDIUM();
	elseif _G["FPSSAVIOR"]["settings"].saviorToggle == 2 then
		FPSSAVIOR_LOW();
	elseif _G["FPSSAVIOR"]["settings"].saviorToggle == 3 then
		FPSSAVIOR_ULOW();
	else
		FPSSAVIOR_HIGH();
	end
end

function FPSSAVIOR_SHOWORHIDE_FRAMES()
	if _G["FPSSAVIOR"]["settings"].saviorToggle == 4 then
		_G["FPSSAVIOR"].wasHidden = true;
		for i = 0,200 do
			local charbaseinfo = ui.GetFrame("charbaseinfo1_"..i);
			if charbaseinfo ~= nil then
				if charbaseinfo:IsVisible() == 1 then
					table.insert(_G["FPSSAVIOR"]["hidden"],"charbaseinfo1_"..i);
					charbaseinfo:ShowWindow(0);
				end
			end
		end
		local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 1000000, "ALL");
		for i = 1, selectedObjectsCount do
			local handle = GetHandle(selectedObjects[i]);
			if handle ~= nil then
				if info.IsPC(handle) == 1 then
					local shopFrame = ui.GetFrame("SELL_BALLOON_"..handle);
					if shopFrame ~= nil then
						if shopFrame:IsVisible() == 1 then
							table.insert(_G["FPSSAVIOR"]["hidden"],"SELL_BALLOON_"..handle);
							shopFrame:ShowWindow(0);
						end
					end
					local ytxtFrame = ui.GetFrame(handle.."_pctitle");
					if ytxtFrame ~= nil then
						if ytxtFrame:IsVisible() == 1 then
							table.insert(_G["FPSSAVIOR"]["hidden"],handle.."_pctitle");
							ytxtFrame:ShowWindow(0);
						end
					end
				end
			end
		end
	else
		if _G["FPSSAVIOR"].wasHidden == true then
			for k,v in pairs(_G["FPSSAVIOR"]["hidden"]) do
				local frame = ui.GetFrame(v);
				if frame ~= nil then
					frame:ShowWindow(1);
				end
			end
			_G["FPSSAVIOR"].wasHidden = false;
		end
	end
end