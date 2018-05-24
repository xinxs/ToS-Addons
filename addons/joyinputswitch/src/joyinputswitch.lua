local acutil = require('acutil');

ui.SysMsg("Input switch loaded! To use, type /inputswitch.")
function JOYINPUTSWITCH_ON_INIT(addon, frame)
    acutil.slashCommand('/inputswitch',inputSwitch_parse);
end

function inputSwitch_parse(command)
    local cmd = table.remove(command,1);
    if (cmd == 'kb') then
        config.ChangeXMLConfig("ControlMode", 2);
        return ui.SysMsg('Keyboard mode enabled.');
    end
    if (cmd == 'mouse') then
        config.ChangeXMLConfig("ControlMode", 3);
        return ui.SysMsg('Mouse mode enabled.')
    end
    if (cmd == 'ct') then
        config.ChangeXMLConfig("ControlMode", 1);
        return ui.SysMsg('Controller mode enabled.')
    end
    if (cmd == 'toggle') then
        if config.GetXMLConfig("ControlMode") == 3 then
            config.ChangeXMLConfig("ControlMode", 2)
            return ui.SysMsg('Keyboard mode enabled.')
        end
        if config.GetXMLConfig("ControlMode") == 2 then
            config.ChangeXMLConfig("ControlMode", 1)
            return ui.SysMsg('Controller mode enabled.')
        end
        config.ChangeXMLConfig("ControlMode", 3)
        return ui.SysMsg('Mouse mode enabled.')
    end
    return ui.SysMsg('Type /inputswitch kb to enable keyboard, /inputswitch mouse to enable mouse, /inputswitch ct to enable controller, or /inputswitch toggle to toggle.')
end