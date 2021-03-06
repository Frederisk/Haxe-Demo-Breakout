package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;
#if (openfl >= "4.0.0")
import openfl.utils.AssetType;
#end


/**
 * Atari 2600 Breakout
 *
 *
 * @author Davey, Photon Storm
 * @link http://www.photonstorm.com/archives/1290/video-of-me-coding-breakout-in-flixel-in-20-mins
 */
// sourcePlayState.hx#L25-
class PlayState extends FlxState
{
	// 在該類的頂端是一些遊戲場景內的物件：

	static inline var BAT_SPEED:Int = 350;
	static inline var SCORE_PREFIX:String = "Score: ";

	var _bat:FlxSprite;
	var _ball:FlxSprite;
	// 工具類別，其可以將多個具體物件組合在一起，
	// 並且可以提供一些方法來操作這些具體物件，
	// 將物件組合在一起有助於遊戲場景的結構化。
	var _walls:FlxGroup;
	// 遊戲場景內的物件，以FlxSprite類別來參與交互。
	var _leftWall:FlxSprite;
	var _rightWall:FlxSprite;
	var _topWall:FlxSprite;
	var _bottomWall:FlxSprite;

	var _bricks:FlxGroup;
	// 本內容聲音等不可交互的遊戲資產，
	// 都是由FlxText、FlxSound等類別來容納。
	var _number:FlxText;

	var _brickSound:FlxSound;
	var _wallSound:FlxSound;
	var _batSound:FlxSound;
	var _subSound:FlxSound;

	var _score:Int = 0;

	/**
	 * create方法提供了對該由遊戲場景的構造，
	 * 在該類實作後，該方法會首先呼叫一次，
	 * 在該方法中需要初始化所有的遊戲物件。
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;

		_bat = new FlxSprite(180, 220);
		_bat.makeGraphic(40, 6, FlxColor.MAGENTA);
		_bat.immovable = true;

		_ball = new FlxSprite(180, 160);
		_ball.makeGraphic(6, 6, FlxColor.MAGENTA);

		_ball.elasticity = 1;
		_ball.maxVelocity.set(200, 200);
		_ball.velocity.y = 200;

		_walls = new FlxGroup();

		_leftWall = new FlxSprite(0, 0);
		_leftWall.makeGraphic(10, 240, FlxColor.GRAY);
		_leftWall.immovable = true;
		_walls.add(_leftWall);

		_rightWall = new FlxSprite(310, 0);
		_rightWall.makeGraphic(10, 240, FlxColor.GRAY);
		_rightWall.immovable = true;
		_walls.add(_rightWall);

		_topWall = new FlxSprite(0, 0);
		_topWall.makeGraphic(320, 10, FlxColor.GRAY);
		_topWall.immovable = true;
		_walls.add(_topWall);

		_bottomWall = new FlxSprite(0, 239);
		_bottomWall.makeGraphic(320, 10, FlxColor.TRANSPARENT);
		_bottomWall.immovable = true;
		// _walls.add(_bottomWall);

		_number = new FlxText(0, 0, 100, SCORE_PREFIX + _score);

		_brickSound = FlxG.sound.load(AssetPaths.di__wav);
		_wallSound = FlxG.sound.load(AssetPaths.lose__wav);
		_batSound = FlxG.sound.load(AssetPaths.hurt__wav);
		_subSound = FlxG.sound.load(AssetPaths.miss__wav);

		// Some bricks
		_bricks = new FlxGroup();

		var bx:Int = 10;
		var by:Int = 30;

		var brickColors:Array<Int> = [0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6];

		for (y in 0...6)
		{
			for (x in 0...20)
			{
				var tempBrick:FlxSprite = new FlxSprite(bx, by);
				tempBrick.makeGraphic(15, 15, brickColors[y]);
				tempBrick.immovable = true;
				_bricks.add(tempBrick);
				bx += 15;
			}

			bx = 10;
			by += 15;
		}

		add(_walls);
		add(_bat);
		add(_ball);
		add(_bricks);
		add(_number);
	}
	/**
	 * update則會在遊戲場景更新時每次呼叫。
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		_bat.velocity.x = 0;

		#if FLX_TOUCH
		// Simple routine to move bat to x position of touch
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.x > 10 && touch.x < 270)
					_bat.x = touch.x;
			}
		}
		// Vertical long swipe up or down resets game state
		for (swipe in FlxG.swipes)
		{
			if (swipe.distance > 100)
			{
				if ((swipe.angle < 10 && swipe.angle > -10) || (swipe.angle > 170 || swipe.angle < -170))
				{
					FlxG.resetState();
				}
			}
		}
		#end

		if (FlxG.keys.anyPressed([LEFT, A]) && _bat.x > 10)
		{
			_bat.velocity.x = -BAT_SPEED;
		}
		else if (FlxG.keys.anyPressed([RIGHT, D]) && _bat.x < 270)
		{
			_bat.velocity.x = BAT_SPEED;
		}

		if (FlxG.keys.justReleased.R)
		{
			FlxG.resetState();
		}

		if (_bat.x < 10)
		{
			_bat.x = 10;
		}

		if (_bat.x > 270)
		{
			_bat.x = 270;
		}

		FlxG.collide(_ball, _walls, wall);
		FlxG.collide(_bat, _ball, ping);
		FlxG.collide(_ball, _bricks, hit);
		FlxG.collide(_ball, _bottomWall, sub);
	}

	inline function check():Void
	{
		if (this._score < 0)
		{
			_number.color = FlxColor.RED;
		}
		else
		{
			_number.color = FlxColor.WHITE;
		}
	}

	function wall(Ball:FlxObject, BottomWall:FlxObject):Void
	{
		_wallSound.play();
	}

	function ping(Bat:FlxObject, Ball:FlxObject):Void
	{
		var batmid:Int = Std.int(Bat.x) + 20;
		var ballmid:Int = Std.int(Ball.x) + 3;
		var diff:Int;

		if (ballmid < batmid)
		{
			// Ball is on the left of the bat
			diff = batmid - ballmid;
			Ball.velocity.x = (-10 * diff);
		}
		else if (ballmid > batmid)
		{
			// Ball on the right of the bat
			diff = ballmid - batmid;
			Ball.velocity.x = (10 * diff);
		}
		else
		{
			// Ball is perfectly in the middle
			// A little random X to stop it bouncing up!
			Ball.velocity.x = 2 + FlxG.random.int(0, 8);
		}
		_batSound.play(true);
	}
	function hit(Ball:FlxObject, Brick:FlxObject):Void
	{
		Brick.exists = false;
		_score += 1;
		_number.text = SCORE_PREFIX + _score;
		check();
		_brickSound.play(true);
	}

	function sub(Ball:FlxObject, BottomWall:FlxObject):Void
	{
		_score -= 3;
		_number.text = SCORE_PREFIX + _score;
		check();
		_subSound.play(true);
	}
}