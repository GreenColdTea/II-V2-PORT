package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import sys.FileSystem;
import lime.system.System;

class Main extends Sprite
{
    var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
    var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
    var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
    var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
    var framerate:Int = 60; // How many frames per second the game should run at.
    var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
    var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
    public static var fpsVar:FPS;

    // You can pretty much ignore everything from here on - your code should go in your states.
    public static var path:String = System.applicationStorageDirectory;

    public static function main():Void
    {
        Lib.current.addChild(new Main());
    }

    public function new()
    {
        super();

        if (stage != null)
        {
            init();
        }
        else
        {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
    }

    private function init(?E:Event):Void
    {
        if (hasEventListener(Event.ADDED_TO_STAGE))
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
        }

        setupGame();
    }

    private function setupGame():Void
    {
        var stageWidth:Int = Lib.current.stage.stageWidth;
        var stageHeight:Int = Lib.current.stage.stageHeight;

        if (zoom == -1 && !ClientPrefs.noBordersScreen) {
            zoom = 1;
        }

        if (ClientPrefs.noBordersScreen) {
            resizeGame();
        }

        Generic.mode = ROOTDATA;
	if (!FileSystem.exists(Generic.returnPath() + 'assets')) {
		FileSystem.createDirectory(Generic.returnPath() + 'assets');
        }

        ClientPrefs.loadDefaultKeys();
	// fuck you, persistent caching stays ON during sex
	FlxGraphic.defaultPersist = true;
	// the reason for this is we're going to be handling our own cache smartly

        addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

        fpsVar = new FPS(10, 3, 0xFFFFFF);
        addChild(fpsVar);
        Lib.current.stage.align = "tl";
        Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
        if(fpsVar != null) {
            fpsVar.visible = ClientPrefs.showFPS;
        }
    }

    private function resizeGame():Void
    {
        var stageWidth:Int = Lib.current.stage.stageWidth;
        var stageHeight:Int = Lib.current.stage.stageHeight;

        var aspectRatio:Float = 16.0 / 9.0;

        if (stageWidth / stageHeight > aspectRatio)
        {
            gameHeight = stageHeight;
            gameWidth = Std.int(gameHeight * aspectRatio);
        }
        else
        {
            gameWidth = stageWidth;
            gameHeight = Std.int(gameWidth / aspectRatio);
        }

        var ratioX:Float = stageWidth / gameWidth;
        var ratioY:Float = stageHeight / gameHeight;
        zoom = Math.min(ratioX, ratioY);

        FlxG.resizeGame(gameWidth, gameHeight);

        var camera:FlxCamera = FlxG.camera;
        camera.setScrollBoundsRect(0, 0, gameWidth, gameHeight);
        camera.zoom = zoom;
    }
}
