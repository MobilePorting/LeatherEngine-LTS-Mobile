package shaders.custom;

import flixel.addons.display.FlxRuntimeShader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * Basically just FlxRuntimeShader but it has tween support
 */
class CustomShader extends FlxRuntimeShader {
    public function update(elapsed:Float) {
		// nothing yet
	}
	/**
	 * Tweens a shader to a value
	 * @param property The property to tween
	 * @param to The value of the property to end up at
	 * @param duration How long it will take
	 * @param ease What ease should be used
	 * @param startDelay The delay to start
	 * @param onComplete When to do when the tween is done
	 */
	public function tween(property:String, to:Float, duration:Float = 1, ease:EaseFunction, ?startDelay:Float = 0.0, ?onComplete:Dynamic){
		FlxTween.num(getFloat(property), to, duration, {ease: ease, onComplete: function(twn) {
			if (onComplete != null)
				onComplete();
		},startDelay: startDelay,}, (value)->{setFloat(property, value);});
	}
}
