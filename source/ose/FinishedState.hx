package ose;

import flixel.FlxGame;
import flixel.FlxState;

class FinishedState extends FlxState
{
	override function create()
	{
		super.create();

		var text:FlxText = new FlxText(0, 0, 0, 'Yo! You finished the oneshot mod, congrats bro.', 16);
		if (InitState.songs.length > 1)
		{
			text.text += '\nThere are ${InitState.songs.length - 1} more songs though, '
			#if SONG_SELECTION
			+ 'so you can play those if you want.'
			#else
			+ 'so you and try to get those if you want.' + '\nIt\'s random chance unless coded otherwise.'
			#end
			+ '\n\n(Press ENTER to go back to InitState and '
			#if SONG_SELECTION
			+ ' play those other songs'
			#else
			+ ' try to get those other songs'
			#end
			+ ', if you haven\'t already)';
		}
		text.screenCenter();
		add(text);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (InitState.songs.length > 1 && FlxG.keys.justReleased.ENTER)
		{
			FlxG.switchState(new InitState());
		}
	}
}
