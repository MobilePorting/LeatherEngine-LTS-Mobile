package mobile.utilities;

import lime.system.System as LimeSystem;
#if android
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/**
 * A storage utility class for mobile platforms.
 * Provides methods for handling storage directories, creating directories, saving content, and requesting permissions for android.
 * 
 * @author Mihai Alexandru (M.A. Jigsaw) and Lily Ross (mcagabe19)
 */
class SUtil {
	#if sys
	/**
	 * The root directory for application storage.
	 */
	public static final rootDir:String = LimeSystem.applicationStorageDirectory;

	/**
	 * Gets the storage directory based on the platform and optional forced storage type.
	 * 
	 * @param forcedType The optional forced storage type.
	 * @return The path to the storage directory.
	 */
	 public static function getStorageDirectory(?forcedType:Null<String>):String {
		var daPath:String = Sys.getCwd();
		#if android
		if (!FileSystem.exists(rootDir + 'storagetype.txt'))
			File.saveContent(rootDir + 'storagetype.txt', Options.getData("storageType"));
		var curStorageType:String = File.getContent(rootDir + 'storagetype.txt');
		if (forcedType != null)
			curStorageType = forcedType;
		daPath = switch (curStorageType) {
			case "EXTERNAL": AndroidEnvironment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');
			case "OBB": android.content.Context.getObbDir();
			case "MEDIA": AndroidEnvironment.getExternalStorageDirectory() + '/Android/media/' + lime.app.Application.current.meta.get('packageName');
			default: android.content.Context.getExternalFilesDir();
		}
		daPath = haxe.io.Path.addTrailingSlash(daPath);
		#elseif ios
		daPath = LimeSystem.documentsDirectory;
		#end

		return daPath;
	}

	/**
	 * Creates directories along the specified path.
	 * 
	 * @param directory The path of the directory to create.
	 */
	public static function mkDirs(directory:String):Void {
		try {
			if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
				return;
		} catch (e:haxe.Exception) {
			trace('Something went wrong while looking at folder. (${e.message})');
		}
		var total:String = '';
		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');
		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts) {
			if (part != '.' && part != '') {
				if (total != '' && total != '/')
					total += '/';

				total += part;

				try {
					if (!FileSystem.exists(total))
						FileSystem.createDirectory(total);
				} catch (e:haxe.Exception)
					CoolUtil.coolError('Error while creating folder. (${e.message})');
			}
		}
	}

	/**
	 * Saves content to a file in the saves directory.
	 * 
	 * @param fileName The name of the file.
	 * @param fileExtension The extension of the file. Defaults to '.json'.
	 * @param fileData The content to save in the file. Defaults to a placeholder string.
	 */
	public static function saveContent(fileName:String, fileData:String):Void
	{
		try
		{
			if (!FileSystem.exists('saves'))
				FileSystem.createDirectory('saves');

			File.saveContent('saves/$fileName', fileData);
			showPopUp('$fileName has been saved.', "Success!");
		}
		catch (e:haxe.Exception)
			CoolUtil.coolError('$fileName couldn\'t be saved. (${e.message})');
	}

	#if android
	/**
	 * Requests Android permissions for external storage access.
	 */
	public static function doPermissionsShit():Void {
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO']);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
		{
			if (AndroidVersion.SDK_INT >= AndroidVersionCode.S)
				AndroidSettings.requestSetting('REQUEST_MANAGE_MEDIA');
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}

		if ((AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU && !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES')) || (AndroidVersion.SDK_INT < AndroidVersionCode.TIRAMISU && !AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')))
			showPopUp('If you accepted the permissions you are all good!' + '\nIf you didn\'t then expect a crash' + '\nPress OK to see what happens', 'Notice!');

		try
		{
			if (!FileSystem.exists(SUtil.getStorageDirectory()))
				mkDirs(SUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			showPopUp('Please create folder to\n' + SUtil.getStorageDirectory() + '\nPress OK to close the game', 'Error!');
			LimeSystem.exit(1);
		}
	}
	#end
	#end

	/**
	 * Displays a pop-up message.
	 * 
	 * @param message The message to display in the pop-up.
	 * @param title The title of the pop-up.
	 */
	public static function showPopUp(message:String, title:String):Void
	{
		#if android
		android.Tools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#else
		lime.app.Application.current.window.alert(message, title);
		#end
	}
}
