package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import openfl.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxInput.FlxInputState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDirectionFlags;
import lime.utils.Assets;
import flixel.system.FlxSound;
import haxe.io.Path;
import openfl.utils.Assets as OpenFlAssets;
#if MODS_ALLOWED
import sys.FileSystem;
#end
using StringTools;

class BallsFreeplay extends MusicBeatState
{  
    var songs:Array<String> = [
        'breakout',
        'soulless-endeavors',
        'vista',
        'meltdown',
        'cascade',
        'my-horizon',
        'color-crash'
    ];

    var songtext:Array<String> = [
        'Breakout',
        'Hellspawn',
        'Vista',
        'Meltdown',
        'Cascade',
        'My Horizon',
        'Color Crash'
    ];

    var characters:Array<String> = [
        'duke',
        'duke',
        'chaotix',
        'chotix',
        'ashura',
        'wechidna',
        'wechnia'
    ];
 
    var playables:Array<String> = [
        'bf-pixel',
        'bf-pixel',
        'bf-pixel',
        'BFLMAO',
        'bf-pixel',
        'bf-pixel',
        'mighty'
    ];
	
    var backgroundShits:FlxTypedGroup<FlxSprite>;

    var screenSong:FlxTypedGroup<FlxText>;

    var screenInfo:FlxTypedGroup<FlxSprite>;
    var screenCharacters:FlxTypedGroup<FlxSprite>;
    var screenPlayers:FlxTypedGroup<FlxSprite>;

    //bf settings
    var player:FlxSprite; //player is FlxSprite
    public var isHoldingLeft:Bool = false; // left button pressed checker
    public var isHoldingRight:Bool = false; // right button pressed checker
    public var isJumping:Bool = false; // jumping checker
    var holdTimer:FlxTimer = new FlxTimer(); // Timer for how long we're holding movement keys. Because holding keys should be timed like fine wine.
    public var speed:Float = 125; // needs for bf's moves
    public var speedMultiplier:Float = 1.25; // bf's default walk speed
    var jumpSpeed:Float = -300; // Vertical speed when jumping. Think of it as the character’s "I believe I can fly" moment.
    var gravity:Float = 600; // How fast we fall. Gravity's way of reminding us that the ground is always waiting.
    var maxJumpHeight:Float = 200; // Maximum height of our jump. Like reaching for the last slice of pizza.
    var jumpStartY:Float = 0; // Y position where we started jumping. Because you gotta know where you began your epic leap.

    //I'm alone people, so i decided to add some funni comments

    public var numSelect:Int = 0;

    override function create()
    {
        Paths.clearStoredMemory();
	Paths.clearUnusedMemory();

        transIn = FlxTransitionableState.defaultTransIn;
	transOut = FlxTransitionableState.defaultTransOut;

        FlxG.mouse.visible = true;

        #if desktop
        // Updating Discord Rich Presence
	DiscordClient.changePresence("Selecting The New World.", null);
	#end

        var blackFuck:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
        blackFuck.screenCenter();
        add(blackFuck);

        holdTimer = new FlxTimer();

        backgroundShits = new FlxTypedGroup<FlxSprite>();
		  add(backgroundShits);

	screenSong = new FlxTypedGroup<FlxText>();
	          add(screenSong);

        screenInfo = new FlxTypedGroup<FlxSprite>();
		  add(screenInfo);

        screenCharacters = new FlxTypedGroup<FlxSprite>();
		  add(screenCharacters);

	screenPlayers = new FlxTypedGroup<FlxSprite>();
	         add(screenPlayers);

        var characterText:FlxText;
        var scoreText:FlxText;
        var proceedText:FlxText;
        var yn:FlxText;

        for(i in 0...songs.length)
        {
            var songPortrait:FlxSprite = new FlxSprite();

            songPortrait.loadGraphic(Paths.image('freeplay/screen/${songs[i]}'));

            songPortrait.screenCenter();
            songPortrait.antialiasing = false;
            songPortrait.scale.set(4.5, 4.5);
            songPortrait.y -= 60;
            songPortrait.alpha = 0;
            screenInfo.add(songPortrait);

	    characterText = new FlxText(0, 0, '${songtext[i]}');
            characterText.setFormat(Paths.font("pixel.otf"), 17, FlxColor.RED, CENTER);
	    characterText.x -= 50;
	    characterText.y -= 50;
            characterText.color = FlxColor.RED;
	    characterText.alpha = 0;
	    screenSong.add(characterText);

            var songCharacter:FlxSprite = new FlxSprite();
            songCharacter.frames = Paths.getSparrowAtlas('freeplay/characters/' + characters[i]);
            songCharacter.animation.addByPrefix('idle', characters[i], 24, true);
            songCharacter.animation.play('idle');
            songCharacter.screenCenter();
            songCharacter.scale.set(3, 3);
            songCharacter.x -= 360;
            songCharacter.y -= 70;
            songCharacter.alpha = 0;

            var songPlayable:FlxSprite = new FlxSprite();
            songPlayable.frames = Paths.getSparrowAtlas('freeplay/playables/${playables[i]}');
            songPlayable.animation.addByPrefix('idle', '${playables[i]}', 24, true);
            songPlayable.animation.play('idle');
            songPlayable.screenCenter();
            songPlayable.scale.set(5.5, 5.5);
            songPlayable.x += 360;
            songPlayable.y -= 60;
            songPlayable.alpha = 0;

	    songPortrait.ID = i;
            songCharacter.ID = i;
            songPlayable.ID = i;
	    characterText.ID = i;
		
            if(i == 0)

	    screenCharacters.add(songCharacter);
            screenPlayers.add(songPlayable);

	    if(characterText.ID == curSelected)
		characterText.alpha = 1;

            if(songPortrait.ID == curSelected)
                songPortrait.alpha = 1;

            if(songCharacter.ID == curSelected)
                songCharacter.alpha = 1;
      
            if(songPlayable.ID == curSelected)
                songPlayable.alpha = 1;

            /* 
            After those make a screen shit for each pixel background all in 1 location and then add
            them to pixelShits
            */

            //Each song has a background
        }

        var screen:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/Frame'));
        screen.setGraphicSize(FlxG.width, FlxG.height);
        screen.updateHitbox();
        add(screen);

	var screenLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/logo'));
	screenLogo.scale.set(1.5, 1.25);
	screenLogo.screenCenter(X);
	screenLogo.updateHitbox();
	screenLogo.x -= 30;
	screenLogo.y += 75;
	add(screenLogo);

	player = new FlxSprite(455, 250);
        player.frames = Paths.getSparrowAtlas('freeplay/encore/BFMenu');
        player.animation.addByPrefix('idle', 'BF_Idle', 24, true);
        player.animation.addByPrefix('jump', 'BF_Jump', 24, true);
        player.animation.addByPrefix('walk', 'BF_Walk', 24, true);
        player.animation.addByPrefix('run', 'BF_Run', 24, true);
        player.antialiasing = true;
        add(player);

	#if !android
        yn = new FlxText(0, 0, 'PRESS 3 TO SWITCH FREEPLAY \nTHEMES');
        #else
        yn = new FlxText(0, 0, 'PRESS X TO SWITCH FREEPLAY \nTHEMES');
        #end
        yn.setFormat(Paths.font("chaotix.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        yn.visible = true;
	yn.y += 650;
        yn.color = FlxColor.WHITE;
        yn.borderSize = 0.9;
        add(yn);

	#if android
        addVirtualPad(LEFT_FULL, A_B_X_Y);
        #end

	if (ClientPrefs.ducclyMix)
        {
                FlxG.sound.playMusic(Paths.music('freeplayThemeDuccly'), 0);
		FlxG.sound.music.fadeIn(4, 0, 0.85);
        }
        else
        {
                FlxG.sound.playMusic(Paths.music('freeplayTheme'), 0);
		FlxG.sound.music.fadeIn(4, 0, 0.85);
	}

        super.create();
    }

    var infoScreen:Bool = false;
    var curSelected:Int = 0;

    // Main update function, where all the magic happens
    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.THREE #if android || _virtualpad.buttonX.justPressed #end)
        {
            ClientPrefs.ducclyMix = !ClientPrefs.ducclyMix;
            FlxG.sound.music.stop();

	    if (ClientPrefs.ducclyMix)
            {
                   FlxG.sound.playMusic(Paths.music('freeplayThemeDuccly'), 0);
		   FlxG.sound.music.fadeIn(4, 0, 0.85);
            }
            else
            {
                   FlxG.sound.playMusic(Paths.music('freeplayTheme'), 0);
		   FlxG.sound.music.fadeIn(4, 0, 0.85);
	    }
        }
	    
        if (controls.UI_UP_P)
        {
            changeSelection(-1);
        }
        if (controls.UI_DOWN_P)
        {
            changeSelection(1);
        }
        if (controls.ACCEPT)
        {
            doTheLoad();
        }
        if (controls.BACK)
        {
            switchToBack();
        }

       //Handle left and right movement
       if (controls.UI_LEFT_P && !controls.UI_RIGHT_P)
       {
           player.flipX = false; //Facing left. Because left is where the cool kids hang out.
           if (!isHoldingLeft)
           {
               isHoldingLeft = true;
               holdTimer.start(1, onHoldComplete); //Start the timer. Time to see if you really wanna go left.
           }
       }
       else if (controls.UI_LEFT_R)
       {
           isHoldingLeft = false;
           player.animation.play('walk'); //Play walking animation when the left key is released. Like, “Alright, I’m done here.”
           holdTimer.cancel(); //Cancel the timer. You’ve officially made your decision. Left no longer has your heart.
       }

        if (controls.UI_RIGHT_P && !controls.UI_LEFT_P)
        {
            player.flipX = true; //Facing right. Right is where the party’s at!
            if (!isHoldingRight)
            {
                isHoldingRight = true;
                holdTimer.start(0.1, onHoldComplete); //Start the timer. Because holding right should come with a timer.
            }
        }
        else if (controls.UI_RIGHT_R)
        {
           isHoldingRight = false;
           player.animation.play('walk'); //Play walking animation when the right key is released. “Okay, I’m outta here.”
           holdTimer.cancel(); //Timer’s over. Right is taking a break.
        }

        if (FlxG.keys.pressed.SPACE #if mobile || _virtualpad.buttonY.pressed #end && !isJumping && isOnGround())
        {
            isJumping = true;
            jumpStartY = player.y; // Record where we started the jump. Like marking the launch pad.
            player.velocity.y = jumpSpeed; //Apply upward velocity. “Blast off!”
            player.animation.play('jump'); //Play jump animation. “We’re going to the moon, baby!”
            FlxG.sound.play(Paths.sound('jump'), 0.62); // Play jump sound. “Jumpin’ Jack Flash!”
        }

        if (isJumping)
        {
           //Apply gravity while jumping.
           player.velocity.y += gravity * elapsed;

           //Check if we've reached the max jump height.
           if (player.y <= jumpStartY - maxJumpHeight)
           {
               player.velocity.y = 0; // Stop upward movement. “Houston, we’ve hit the ceiling.”
           }

           //Check if we've hit the ground.
           if (player.y + player.height >= FlxG.height - 100)
           {
               player.y = FlxG.height - player.height - 100; // Keep player grounded. “And touchdown! Welcome back to Earth.”
               isJumping = false;
               player.velocity.y = 0; // Stop falling. “Gravity: 1, You: 0.”
           }
       }

    	//Screen boundaries
       if (player.x < -80)
       {
           player.x = -80; // Prevent moving off the left edge. “Nope, not today!”
           player.velocity.x = 0; // Stop horizontal movement. “Left field is off-limits!”
       }
       else if (player.x + player.width > FlxG.width + 80)
       {
           player.x = FlxG.width + 80 - player.width; // Prevent moving off the right edge. “Right field is closed for business!”
           player.velocity.x = 0; // Stop horizontal movement. “Right edge, not on my watch!”
       }

       if (player.y < 100)
       {
           player.y = 100; //Prevent moving off the top edge. “Not climbing the sky today!”
           player.velocity.y = 0; //Stop vertical movement. “Stay grounded, buddy!”
       }
       else if (player.y + player.height > FlxG.height - 100)
       {
           player.y = FlxG.height - player.height - 100; // Prevent moving off the bottom edge. “No free-fall here!”
           player.velocity.y = 0; //Stop vertical movement. “Gravity: still winning.”
       }


        // Movement and animation
       if (isOnGround())
       {
           if (isHoldingLeft && !isHoldingRight)
           {
               player.velocity.x = -speed * speedMultiplier; // Move left. “Left is the new black.”
               player.animation.play('run'); // Play running animation. “Like Sonic on a sugar rush!”
           }
           else if (isHoldingRight && !isHoldingLeft)
           {
               player.velocity.x = speed * speedMultiplier; // Move right. “Right side up and running!”
               player.animation.play('run'); // Play running animation. “Faster than your Wi-Fi!”
           }
           else
           {
               player.velocity.x = 0; // Stop horizontal movement. “Chillin’ like a villain.”
               player.animation.play('idle'); // Play idle animation. “Not moving, just vibin’.”
           }
       }
       else
       {
          if (player.velocity.y < 0)
          {
              player.animation.play('jump'); // Play jump animation while in the air. “Sky high and still fabulous!”
          }
       } 

        super.update(elapsed);
    }

    // go to main menu
    public function switchToBack() 
    {
	FlxG.sound.play(Paths.sound('cancelMenu'));
	FlxG.mouse.visible = false;
        MusicBeatState.switchState(new MainMenuState());
    }

    //song selection changing function
    function changeSelection(direction:Int)
    {
        curSelected += direction;
        var newIndex:Int = curSelected;
        if (newIndex < 0) 
	    newIndex = songs.length - 1;
        else if (newIndex >= songs.length) 
	    newIndex = 0;

        updateSelection(newIndex);
    }

    //selection update
    function updateSelection(newIndex:Int)
    {
        screenInfo.members[curSelected].alpha = 0;
        screenCharacters.members[curSelected].alpha = 0;
        screenPlayers.members[curSelected].alpha = 0;
	
        curSelected = newIndex;

        screenInfo.members[curSelected].alpha = 1;
        screenCharacters.members[curSelected].alpha = 1;
        screenPlayers.members[curSelected].alpha = 1;

	if (curSelected == 3 && playables[3] == 'BFLMAO') 
	{
           screenPlayers.members[curSelected].scale.set(0.5, 0.5);
	   screenPlayers.members[curSelected].y -= 60;
        } 
	else if (curSelected == 6 && playables[6] == 'mighty') 
	{
              screenPlayers.members[curSelected].scale.set(3, 3);
	      screenPlayers.members[curSelected].y -= 70;
        }
        else
	{
	      screenPlayers.members[curSelected].scale.set(5.5, 5.5);
	      screenPlayers.members[curSelected].y -= 50;
	}
    }
	
    function doTheLoad()
    {
        var songLowercase:String = Paths.formatToSongPath(songs[curSelected]);
        PlayState.SONG = Song.loadFromJson(songLowercase + '-hard', songLowercase);
        PlayState.isStoryMode = false;
        PlayState.storyDifficulty = 2;
        LoadingState.loadAndSwitchState(new PlayState());
	FlxG.sound.music.volume = 0;
	FreeplayState.destroyFreeplayVocals();
    }

    // Called when the hold timer completes
   function onHoldComplete(timer:FlxTimer):Void
   {
       if (isHoldingLeft || isHoldingRight)
       {
           player.animation.play('run'); // Start running animation if a direction is held. “Running like there’s no tomorrow!”
           speedMultiplier = 2.05; // Increase speed while running. “Turbo mode: ON!”
       }
    }

   // Checks if the player is on the ground
   function isOnGround():Bool
   {
       return player.y + player.height >= FlxG.height - 1; // Simple ground check. “Ground status: definitely grounded.”
   }
}
