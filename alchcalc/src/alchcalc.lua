_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['ALCHCALC'] = _G['ADDONS']['ALCHCALC'] or {};
local g = _G['ADDONS']['ALCHCALC']
local acutil = require('acutil');

function ALCHCALC_ON_INIT(addon, frame)
ALCHCALC_CREATEFRAME();
acutil.slashCommand('/alchcalc', ALCHCALC_EXEC);
end

function ALCHCALC_CREATEFRAME()
local workshop = ui.GetFrame("customdrag");
	if workshop == nil then
	return
	end
local btn = workshop:CreateOrGetControl('button', 'btn', 0, 0, 50, 50); 
btn:SetText('AC'); 
btn:SetOffset(10, workshop:GetHeight() - 340);
btn:SetEventScript(ui.LBUTTONDOWN, 'ALCHCALC_EXEC');
end

function ALCHCALC_EXEC()
local uosis = session.GetInvItemByType(640028);
local dilgele = session.GetInvItemByType(640038);
local uosiscnt = 0;
local dilgelecnt = 0;
local flaskcnt = 0;
local valecnt = 0;
local varncnt = 0;
	if uosis ~= nil then
		uosiscnt = uosis.count;
		local flask = session.GetInvItemByType(645532);
		if flask ~= nil then
		flaskcnt = flask.count;
		end
		local varn = session.GetInvItemByType(640025);
		if varn ~= nil then
		varncnt = varn.count;
		end
	end
	if dilgele ~= nil then
		dilgelecnt = dilgele.count;
		local flask = session.GetInvItemByType(645532);
		if flask ~= nil then
		flaskcnt = flask.count;
		end
		local vale = session.GetInvItemByType(640026);
		if vale ~= nil then
		valecnt = vale.count;
		end
	end
local varnbuy = uosiscnt*3 - varncnt;
	if varnbuy < 0 then
	varnbuy = 0;
	end
local varnsilver = commaformat(varnbuy*125);
local valebuy = math.floor(dilgelecnt/2)*2 - valecnt;
	if valebuy < 0 then
	valebuy = 0;
	end
local valesilver = commaformat(valebuy*50);
local flaskbuy = uosiscnt + math.floor(dilgelecnt/2) - flaskcnt;
	if flaskbuy < 0 then
	flaskbuy = 0;
	end
local flasksilver = commaformat(flaskbuy*120);
local total = flaskbuy*120 + valebuy*50 + varnbuy*125;
local totalformatted = commaformat(total);

local text = ""
text = text .."Uosis in inventory: "..uosiscnt;
text = text .."{nl}";
text = text .."Varnalesa to buy: "..varnbuy ..", silver need: "..varnsilver;
text = text .."{nl}";
text = text .."---";
text = text .."{nl}";
text = text .."Dilgele in inventory: "..dilgelecnt;
text = text .."{nl}";
text = text .."Valerijonas to buy: "..valebuy..", silver need: "..valesilver;
text = text .."{nl}";
text = text .."---";
text = text .."{nl}";
text = text .."Flask to buy: "..flaskbuy..", silver need: "..flasksilver;
text = text .."{nl}";
text = text .."---";
text = text .."{nl}";
text = text .."Total silver need: "..totalformatted;
return ui.MsgBox(text,"","Nope")
end

function commaformat(price)
local formatted = price;
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
return formatted
end










