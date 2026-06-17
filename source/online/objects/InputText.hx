package online.objects;
import online.gui.sidebar.SideUI;
import flixel.addons.ui.FlxInputText;

class InputText extends FlxInputText {
    public function new(x:Float, y:Float, width:Float, onEnter:(text:String)->Void) {
        super(x, y, Std.int(width));
        backgroundColor = FlxColor.TRANSPARENT;
        fieldBorderColor = FlxColor.TRANSPARENT;
        caretColor = FlxColor.WHITE;
        textField.selectable = true;
        textField.wordWrap = false;

        #if android
        FlxG.stage.addEventListener(openfl.events.TextEvent.TEXT_INPUT, onTextInput);
        #end

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

    #if android
    function onTextInput(e:openfl.events.TextEvent) {
        if (!hasFocus) return;
        if (e.text == "\n" || e.text == "\r") {
            hasFocus = false;
            callback(text, FlxInputText.ENTER_ACTION);
            return;
        }
        if (e.text.length > 1 || e.text.charCodeAt(0) > 127) {
            var pos = textField.caretIndex;
            text = text.substring(0, pos) + e.text + text.substring(pos);
            textField.setSelection(pos + e.text.length, pos + e.text.length);
        }
    }

    override function destroy() {
        FlxG.stage.removeEventListener(openfl.events.TextEvent.TEXT_INPUT, onTextInput);
        super.destroy();
    }
    #end

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (hasFocus && (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this)))) {
            hasFocus = false;
        }
    }

    override function set_hasFocus(value:Bool):Bool {
        #if android
        try {
            lime.app.Application.current.window.textInputEnabled = value;
        } catch (e:Dynamic) {
            trace("Keyboard error: " + e);
        }
        #end
        return super.set_hasFocus(value);
    }
}
