package online.objects;

import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import online.gui.sidebar.SideUI;
import flixel.text.FlxText;

class InputText extends FlxText {

	var inputBuffer:String = '';
	var inputCursor:Int = 0;

	public var inputText(get, never):String;
	function get_inputText() return inputBuffer;

	public var hasFocus(default, set):Bool = false;
	function set_hasFocus(v:Bool) {
		if (hasFocus == v)
			return v;
		hasFocus = v;

		if (v) {
			Application.current.window.textInputEnabled = true;
			updateTextInputRect();
		}
		else {
			Application.current.window.textInputEnabled = false;
		}

		caretVisible = v;
		caretTimer = 0;
		caret.visible = v;
		renderText();
		return hasFocus;
	}

	public function clear() {
		inputBuffer = '';
		inputCursor = 0;
		_lastRendered = '\x00';
		renderText();
	}

	public var backgroundColor:FlxColor = FlxColor.TRANSPARENT;
	public var fieldBorderColor:FlxColor = FlxColor.TRANSPARENT;
	public var caretColor:FlxColor = FlxColor.WHITE;

	var caret:FlxSprite;
	var caretTimer:Float = 0;
	var caretVisible:Bool = false;
	static inline final CARET_INTERVAL:Float = 0.5;

	var _lastRendered:String = '\x00';

	var onEnter:(text:String)->Void;

	var _onTextInput:String->Void;
	var _onLimeKeyDown:KeyCode->KeyModifier->Void;

	public function new(x:Float, y:Float, width:Float, onEnter:(text:String)->Void) {
		super(x, y, Std.int(width));

		this.onEnter = onEnter;

		setFormat("chin.ttf", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		caret = new FlxSprite();
		caret.makeGraphic(2, Std.int(size), FlxColor.WHITE);
		caret.visible = false;

		_onTextInput = onLimeTextInput;
		_onLimeKeyDown = onLimeKeyDown;
		Application.current.window.onTextInput.add(_onTextInput);
		Application.current.window.onKeyDown.add(_onLimeKeyDown);

		renderText();
	}

	function updateTextInputRect() {
		var screenPos = getScreenPosition();
		var scaleX = FlxG.scaleMode.scale.x;
		var scaleY = FlxG.scaleMode.scale.y;
		Application.current.window.setTextInputRect(new lime.math.Rectangle(
			screenPos.x * scaleX,
			screenPos.y * scaleY,
			width  * scaleX,
			size   * scaleY
		));
		screenPos.put();
	}

	override function draw() {
		super.draw();

		if (hasFocus && caretVisible) {
			var ratio = inputBuffer.length > 0 ? (inputCursor / inputBuffer.length) : 0;
			@:privateAccess
			var caretX = x + textField.textWidth * ratio;
			caret.x = caretX;
			caret.y = y;
			caret.cameras = cameras;
			caret.draw();
		}
	}

	override function destroy() {
		super.destroy();
		caret.destroy();

		if (Application.current != null && Application.current.window != null) {
			Application.current.window.onTextInput.remove(_onTextInput);
			Application.current.window.onKeyDown.remove(_onLimeKeyDown);
		}
	}

	function onLimeTextInput(text:String) {
		if (!hasFocus)
			return;
		if (SideUI.instance != null && SideUI.instance.active)
			return;

		inputBuffer = inputBuffer.substr(0, inputCursor) + text + inputBuffer.substr(inputCursor);
		inputCursor += text.length;
		renderText();
	}

	function onLimeKeyDown(key:KeyCode, mod:KeyModifier) {
		if (!hasFocus)
			return;
		if (SideUI.instance != null && SideUI.instance.active)
			return;

		switch (key) {
			case RETURN | NUMPAD_ENTER:
				var t = inputBuffer;
				inputBuffer = '';
				inputCursor = 0;
				hasFocus = false;
				renderText();
				onEnter(t);

			case BACKSPACE:
				if (inputCursor > 0) {
					inputBuffer = inputBuffer.substr(0, inputCursor - 1) + inputBuffer.substr(inputCursor);
					inputCursor--;
					renderText();
				}

			case DELETE:
				if (inputCursor < inputBuffer.length) {
					inputBuffer = inputBuffer.substr(0, inputCursor) + inputBuffer.substr(inputCursor + 1);
					renderText();
				}

			case LEFT:
				if (inputCursor > 0) { inputCursor--; renderText(); }

			case RIGHT:
				if (inputCursor < inputBuffer.length) { inputCursor++; renderText(); }

			case HOME:
				inputCursor = 0; renderText();

			case END:
				inputCursor = inputBuffer.length; renderText();

			case V if (mod.ctrlKey):
				var clip = lime.system.Clipboard.text;
				if (clip != null && clip.length > 0) {
					inputBuffer = inputBuffer.substr(0, inputCursor) + clip + inputBuffer.substr(inputCursor);
					inputCursor += clip.length;
					renderText();
				}

			default:
		}
	}

	function renderText() {
		if (inputBuffer == _lastRendered)
			return;
		_lastRendered = inputBuffer;
		text = inputBuffer;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (hasFocus) {
			if (FlxG.keys.justPressed.ESCAPE
				|| (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(this))) {
				hasFocus = false;
			}

			caretTimer += elapsed;
			if (caretTimer >= CARET_INTERVAL) {
				caretTimer = 0;
				caretVisible = !caretVisible;
				caret.visible = caretVisible;
			}
		}
	}
}