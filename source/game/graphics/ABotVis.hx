package game.graphics;

import lime.media.AudioSource;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import funkin.vis.AudioClip;
import funkin.vis.dsp.SpectralAnalyzer;
import flixel.graphics.frames.FlxAtlasFrames;

using Lambda;

class ABotVis extends FlxSpriteGroup
{
    var analyzer:SpectralAnalyzer;

    public function new(snd:AudioSource)
    {
        super();

        // The audio visualizer - Nex
        var visFrms:FlxAtlasFrames = Paths.getSparrowAtlas('aBotViz');

        // these are the differences in X position, from left to right
        var widths:Array<Float> =    [68, 58, 58,   57,  61,  67,  70];
        var positionX:Array<Float> = [ 0, 59, 56,   66,  54,  52,  51];
        var positionY:Array<Float> = [ 0, -8, -3.5, -0.4, 0.5, 4.7, 7];

        var sum = function(num:Float, total:Float) return total += num;
        var totalWidth = Lambda.fold(widths, sum, 0);

        for (i in 1...8)
        {
            var posX:Float = Lambda.fold(positionX.slice(0, i), sum, 0);
            var posY:Float = Lambda.fold(positionY.slice(0, i), sum, 0);

            var viz:FlxSprite = new FlxSprite();
            viz.frames = visFrms;
            viz.width = totalWidth;
            //viz.height = FlxG.height;
            viz.x += posX;
            viz.y += posY;
            add(viz);

            viz.animation.addByPrefix('VIZ', 'viz' + i, 0);
            viz.animation.play('VIZ', false, false, 6);
        }

        @:privateAccess
        analyzer = new SpectralAnalyzer(FlxG.sound.music._channel.__audioSource , 7, 0.01, 30);
        //analyzer.maxDb = -35;
    }

    override function draw()
    {
      if(FlxG.sound.music != null){
        var levels = analyzer.getLevels();

        var grp = group.members.length;
        var lvls = levels.length;
        for (i in 0...(grp > lvls ? lvls : grp))
        {
            var animFrame:Int = Math.round(levels[i].value * 5);
            animFrame = Math.floor(FlxMath.bound(animFrame, 0, 5));

            //animFrame = Math.floor(Math.min(5, animFrame));
            //animFrame = Math.floor(Math.max(0, animFrame));

            animFrame = Std.int(Math.abs(animFrame - 5)); // shitty dumbass flip, cuz dave got da shit backwards lol!

            group.members[i].animation.curAnim.curFrame = animFrame;
        }

      }
        super.draw();
    }
}