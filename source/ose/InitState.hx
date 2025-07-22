package ose;

import haxe.macro.Compiler;
import states.editors.MasterEditorMenu;
import states.*;
import backend.*;
import flixel.*;

using StringTools;

class InitState extends FlxState
{
	var missingText:FlxText;

	var songText:FlxText;
	var diffText:FlxText;

	var curDifficulty:Int = -1;

	private static var lastDifficultyName:String = Difficulty.getDefault();

	public static var songs:Array<String> = [];

	var songWeeks:Array<Int> = [];
	var songsFolders:Array<String> = [];

	var directoryTxt:FlxText;

	static var showOutdatedWarning:Bool = true;

	public static var init:Bool = false;

	public static var savedModDir:String = '';

	override function create()
	{
		super.create();

		if (savedModDir != '')
			Mods.currentModDirectory = savedModDir;

		trace('yo');

		if (!init)
		{
			ClientPrefs.loadPrefs();
			Language.reloadPhrases();

			if (FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				// trace('LOADED FULLSCREEN SETTING!!');
			}

			if (FlxG.save.data.weekCompleted != null)
			{
				StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
			}

			if (FlxG.save.data.flashing == null && !FlashingState.leftState)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new FlashingState());
				return;
			}

			Difficulty.resetList();

			WeekData.reloadWeekFiles(false);

			if (WeekData.weeksList.length < 1)
			{
				FlxTransitionableState.skipNextTransIn = true;
				persistentUpdate = false;
				MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED\n\nPress ACCEPT or BACK to close the game", function()
				{
					throw 'No weeks added';
				}, function()
				{
					throw 'No weeks added';
				}));
				return;
			}

			init = true;
		}
		for (i in 0...WeekData.weeksList.length)
		{
			if (FreeplayState.weekIsLocked(WeekData.weeksList[i]))
				continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}

				if (!songs.contains(song[0]))
				{
					songs.push(song[0]);
					songWeeks.push(i);
					#if MODS_ALLOWED
					songsFolders.push((Mods.currentModDirectory != null) ? Mods.currentModDirectory : '');
					#else
					songsFolders.push((Mods.currentModDirectory != null) ? Mods.currentModDirectory : '');
					#end
				}
			}
		}
		WeekData.setDirectoryFromWeek();

		#if MODS_ALLOWED
		Mods.loadTopMod();
		#end

		trace('Song list: $songs');
		if (FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		#if debug
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		continueUpdateLoop = false;
		return;
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		continueUpdateLoop = false;
		return;
		#end

		#if !NO_TITLE
		MusicBeatState.switchState(new TitleState());
		continueUpdateLoop = false;
		return;
		#end
		#end

		#if results
		MusicBeatState.switchState(new Results());
		continueUpdateLoop = false;
		return;
		#end

		#if CHECK_FOR_UPDATES
		if (showOutdatedWarning && ClientPrefs.data.checkForUpdates && substates.OutdatedSubState.updateVersion != ose.Global.OSEV)
		{
			persistentUpdate = false;
			showOutdatedWarning = false;
			openSubState(new substates.OutdatedSubState());
		}
		#end

		directoryTxt = new FlxText(0, FlxG.height - 64, FlxG.width, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		directoryTxt.scrollFactor.set();
		add(directoryTxt);

		#if !SONG_SELECTION
		play((songs.length > 1) ? FlxG.random.int(0, songs.length - 1) : 0);
		#else
		songText = new FlxText(0, 0, 0, '', 64);
		songText.screenCenter();
		songText.alignment = CENTER;
		add(songText);

		diffText = new FlxText(songText.x, songText.y + 64, 0, "", 24);
		add(diffText);

		songText.y -= 128;
		diffText.y += diffText.height + 64;
		#end

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		changeDiff();
	}

	var continueUpdateLoop = true;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if SONG_SELECTION
		if (!continueUpdateLoop)
			return;

		songText.text = ((sel > 0) ? '/\\\n' : '_\n') + songs[sel] + ((sel < songs.length - 1) ? '\n\\/' : '\n_');

		songText.screenCenter(X);
		diffText.screenCenter(X);

		if (Controls.instance.UI_LEFT_R)
			changeDiff(-1);
		if (Controls.instance.UI_RIGHT_R)
			changeDiff(1);
		if (Controls.instance.UI_UP_R)
			sel--;
		if (Controls.instance.UI_DOWN_R)
			sel++;
		#if debug
		if (Controls.instance.BACK)
			MusicBeatState.switchState(new MasterEditorMenu());
		#end

		if (sel < 0)
			sel = 0;
		if (sel > songs.length - 1)
			sel = songs.length - 1;

		#if MODS_ALLOWED
		Mods.currentModDirectory = songsFolders[sel];

		directoryTxt.text = 'Mod directory: "${Mods.currentModDirectory}"';
		if (Mods.currentModDirectory == '')
			directoryTxt.text = '';
		#end

		if (Controls.instance.ACCEPT)
		{
			savedModDir = Mods.currentModDirectory;
			Difficulty.loadFromWeek();
			play(sel);
		}
		#end
	}

	var sel = 0;

	function play(id:Int = 0)
	{
		trace('PLAYSTATE SHITZ');

		trace('Difficulty: ${Difficulty.getString(curDifficulty)}');

		persistentUpdate = false;
		var songLowercase:String = Paths.formatToSongPath(songs[id]);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

		try
		{
			Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songWeeks[id];

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
		}
		catch (e:haxe.Exception)
		{
			trace('ERROR! ${e.message}');

			var errorStr:String = e.message;
			if (errorStr.contains('There is no TEXT asset with an ID of'))
				errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length - 1); // Missing chart
			else
				errorStr += '\n\n' + e.stack;

			missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
			missingText.y = 10;
			missingText.visible = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));

			return;
		}
		@:privateAccess
		if (PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
		{
			PlayState._lastLoadedModDirectory = Mods.currentModDirectory;
			Paths.freeGraphicsFromMemory();
			Paths.clearStoredMemory();
		}
		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());

		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length - 1);
		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		final displayDiff:String = Difficulty.getString(curDifficulty);
		// trace('Current difficulty: $displayDiff');

		try
		{
			if (Difficulty.list.length > 1)
				diffText.text = '< ' + displayDiff.toUpperCase() + ' >';
			else
				diffText.text = displayDiff.toUpperCase();

			// trace('Difficulty list length: ${Difficulty.list.length}');
		}
		catch (e)
		{
			trace('huh: $e');
		}

		missingText.visible = false;
	}
}
