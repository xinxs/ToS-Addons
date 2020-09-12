_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['HIDEDROPMSG'] = _G['ADDONS']['HIDEDROPMSG'] or {};
local g = _G['ADDONS']['HIDEDROPMSG']
local acutil = require('acutil');

function HIDEDROPMSG_ON_INIT(addon, frame)
	acutil.setupHook(ITEMMSG_SHOW_GET_ITEM_HOOKED, "ITEMMSG_SHOW_GET_ITEM");
	acutil.setupHook(SHOW_GET_EXP_HOOKED, "SHOW_GET_EXP");
	acutil.setupHook(SHOW_GET_JOBEXP_HOOKED, "SHOW_GET_JOBEXP");
end

function ITEMMSG_SHOW_GET_ITEM_HOOKED(frame, itemType, count)
	return
end

function SHOW_GET_EXP_HOOKED(frame, exp)
	return
end

function SHOW_GET_JOBEXP_HOOKED(frame, jobExp)
	return
end