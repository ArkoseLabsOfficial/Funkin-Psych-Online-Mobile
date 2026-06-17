package online.objects;
import online.gui.sidebar.SideUI;
import flixel.addons.ui.FlxInputText;
#if android
import lime.system.JNI;
#end

class InputText extends FlxInputText {
    #if android
    static var showSoftKeyboard:Dynamic = null;
    static var hideSoftKeyboard:Dynamic = null;
    #end

    public function new(x:Float, y:Float, width:Float, onEnter:(text:String)->Void) {
        super(x, y, Std.int(width));
        backgroundColor = FlxColor.TRANSPARENT;
        fieldBorderColor = FlxColor.TRANSPARENT;
        caretColor = FlxColor.WHITE;
        textField.selectable = true;
        textField.wordWrap = false;

        #if android
        textField.type = flash.text.TextFieldType.INPUT;
        if (showSoftKeyboard == null)
            showSoftKeyboard = JNI.createStaticMethod("org/haxe/lime/GameActivity", "showKeyboard", "()V");
        if (hideSoftKeyboard == null)
            hideSoftKeyboard = JNI.createStaticMethod("org/haxe/lime/GameActivity", "hideKeyboard", "()V");
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

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (hasFocus && (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this)))) {
            hasFocus = false;
        }
    }

    override function set_hasFocus(value:Bool):Bool {
        #if android
        if (value) {
            if (showSoftKeyboard != null) showSoftKeyboard();
        } else {
            if (hideSoftKeyboard != null) hideSoftKeyboard();
        }
        #end
        return super.set_hasFocus(value);
    }
}
