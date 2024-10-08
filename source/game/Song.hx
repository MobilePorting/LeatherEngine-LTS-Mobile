package game;

/**
 * Compatibility typedef for fnf-modcharting-tools.
**/
typedef SwagSong = SongLoader.SongData;

/**
 * Compatibility class for fnf-modcharting-tools.
**/
class Song {
	public static function loadFromJson(name:String, ?folder:String):SwagSong {
		return SongLoader.loadFromJson(name, folder ?? name);
	}
}
