package online.objects;
import online.gui.sidebar.SideUI;
import flixel.addons.ui.FlxInputText;
#if android
import openfl.system.System;
#end

class InputText extends FlxInputText {
    public function new(x:Float, y:Float, width:Float, onEnter:(text:String)->Void) {
        super(x, y, Std.int(width));
        backgroundColor = FlxColor.TRANSPARENT;
        fieldBorderColor = FlxColor.TRANSPARENT;
        caretColor = FlxColor.WHITE;
        textField.selectable = true;
        textField.wordWrap = false;

        var prevText:String = '';
        callback = (text, action) -> {
            if (SideUI.instance != null && SideUI.instance.active) {
                this.text = prevText;
                return;
            }
            prevText = text;
            if (action == FlxInputText.ENTER_ACTION) {
                hasFocus = false;
                onEnter(text);
            }
        };
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (hasFocus && (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this)))) {
            hasFocus = false;
        }
    }

    override function set_hasFocus(value:Bool):Bool {
        #if android
        try {
            if (value)
                lime.app.Application.current.window.textInputEnabled = true;
            else
                lime.app.Application.current.window.textInputEnabled = false;
        } catch (e:Dynamic) {
            trace("Keyboard error: " + e);
        }
        #end
        return super.set_hasFocus(value);
    }
}
