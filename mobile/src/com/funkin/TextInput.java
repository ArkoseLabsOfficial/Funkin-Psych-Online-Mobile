package com.funkin;

import android.app.Activity;
import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.PopupWindow;
import org.haxe.nme.HaxeObject;
import org.haxe.nme.GameActivity;

public class TextInput {
    private static PopupWindow popup;
    private static EditText edit;

    public static void openIME(String hint, String defText) {
        Activity act = GameActivity.getInstance();
        act.runOnUiThread(()->{
            closeInput();
            edit = new EditText(act);
            edit.setHint(hint);
            edit.setText(defText);
            // 开启全功能输入法，支持中文
            edit.setInputType(android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_FLAG_MULTI_LINE);

            popup = new PopupWindow(edit,1,1);
            popup.showAtLocation(act.getWindow().getDecorView(), Gravity.NO_GRAVITY,0,0);
            InputMethodManager imm = (InputMethodManager)act.getSystemService(Context.INPUT_METHOD_SERVICE);
            edit.requestFocus();
            imm.showSoftInput(edit, InputMethodManager.SHOW_FORCED);

            // 回车确认，把文字传回Haxe
            edit.setOnEditorActionListener((v,action,event)->{
                sendText(edit.getText().toString());
                closeInput();
                return true;
            });
        });
    }

    private static void sendText(String str){
        // 调用Haxe静态方法 FlxInputText.onReceiveIMEString
        HaxeObject.callStatic("flixel.addons.ui.FlxInputText","onReceiveIMEString",str);
    }

    public static void closeInput(){
        Activity act = GameActivity.getInstance();
        act.runOnUiThread(()->{
            if(popup!=null && popup.isShowing()) popup.dismiss();
            popup=null;edit=null;
        });
    }
}
