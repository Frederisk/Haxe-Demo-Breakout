package;

import flixel.FlxGame;
import openfl.display.Sprite;

// source/Main.hx#L7-L25
/**
 * 在啟動引導中，Main類別是整個遊戲的起點，
 * 其繼承自openfl.display.Sprite，
 * 實現了一個基本的展示視窗，該類別的main方法由Sprite類提供，
 * 在編寫中只需要撰寫new公共方法來實作Main類別物件。
 */
class Main extends Sprite
{
	// 對new方法的重寫。
	public function new()
	{
		// 對父類別同名方法的呼叫
		super();
		// 方法為Main添加了遊戲物件FlxGame，
		// FlxGame利用一個FlxState物件完成了對關卡的設計，
		// 而前兩個引數則指定了遊戲設計時採用的虛擬像素大小。
		addChild(new FlxGame(320, 240, PlayState));
	}
}
