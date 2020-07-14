package states;

import com.soundLib.SoundManager.SM;
import com.loading.basicResources.SoundLoader;
import com.loading.basicResources.SpriteSheetLoader;
import GlobalGameData;
import kha.Assets;
import kha.input.KeyCode;
import com.framework.utils.State;
import com.framework.utils.Input;
import com.gEngine.GEngine;
import com.gEngine.display.Text;
import com.gEngine.display.Layer;
import com.gEngine.display.Sprite;
import com.loading.Resources;
import com.loading.basicResources.JoinAtlas;
import com.loading.basicResources.FontLoader;
import com.loading.basicResources.ImageLoader;
import states.Credits;

/* @author Lucas (181830) */
class SuccessScreen extends State {
	var score:Int;
	var sprite:String;
	var pressContinue:Text;
	var timeSurvived:Float = 0;
	var display:Sprite;
	var simulationLayer:Layer;
	var playerStats:Array<Float>;
	var withMouse:Bool;

	public function new() {
		super();
		GlobalGameData.levelCompleted();
		score = GGD.score;
		sprite = "hero";
	}

	override function load(resources:Resources) {
		var atlas:JoinAtlas = new JoinAtlas(2048, 2048);
		atlas.add(new ImageLoader("victory"));
		atlas.add(new SpriteSheetLoader("hero", 60, 60, 0, [
			new Sequence("fall", [14, 15]),
			new Sequence("slide", [58]),
			new Sequence("jump", [13]), 
			new Sequence("rangeAttack", [49, 50, 51, 52, 49]),
			new Sequence("attack1", [32, 33, 34]),
			new Sequence("attack2", [36, 37, 38, 39]), 
			new Sequence("attack3", [40, 41, 42, 43, 44]), 
			new Sequence("run", [4, 5, 6, 7, 8, 9, 10, 11]),
			new Sequence("idle", [0, 1, 2, 3, 2, 1]), 
			new Sequence("heavyDamage", [19, 20, 21, 22, 23]), 
			new Sequence("damage", [25, 26, 27]), 
			new Sequence("rangeAttack", [11])]));
		atlas.add(new FontLoader(Assets.fonts.PixelOperator8_BoldName, 30));
		resources.add(atlas);
		resources.add(new SoundLoader(Assets.sounds.successName));
	}

	override function init() {
		var image = new Sprite("victory");
		SM.playFx(Assets.sounds.successName);
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		display = new Sprite(sprite);
		display.x = GEngine.virtualWidth * 0.5 - (display.width()/2);
		display.y = GEngine.virtualHeight * 0.75 - display.height();
		display.scaleX = 3;
		display.scaleY = 3;
		display.timeline.frameRate = 1/10;
		display.timeline.playAnimation("idle");
		simulationLayer.addChild(display);
		image.x = GEngine.virtualWidth * 0.5 - (image.width() * 0.5) / 2;
		image.y = 70;
		image.scaleX = 1 / 2;
		image.scaleY = 1 / 2;
		stage.addChild(image);

		var scoreDisplay = new Text(Assets.fonts.PixelOperator8_BoldName);
		scoreDisplay.text = "YOUR SCORE IS " + score;
		scoreDisplay.x = (GEngine.virtualWidth / 2 - scoreDisplay.width() * 0.5) - 7;
		scoreDisplay.y = GEngine.virtualHeight / 2 - 30;
		scoreDisplay.setColorMultiply(2/3, 2/3, 0, 1);
		stage.addChild(scoreDisplay);

		pressContinue = new Text(Assets.fonts.PixelOperator8_BoldName);
		pressContinue.text = "PRESS ENTER";
		pressContinue.scaleX = 2/3;
		pressContinue.scaleY = 2/3;
		pressContinue.y = 660;
		pressContinue.x = 250 - (pressContinue.width() / 3);
		stage.addChild(pressContinue);
	}

	var transcparency:Float;
	var more:Bool = false;

	override function update(dt:Float) {
		super.update(dt);
		GlobalGameData.soundControllWithoutIcon();
		if (Input.i.isKeyCodePressed(KeyCode.Return) || Input.i.isMousePressed()) {
			startNextLevel();
		}
		if (transcparency <= 0 || transcparency >= 1) {
			more = !more;
		}
		if (more) {
			transcparency += 1 / 40;
		} else {
			transcparency -= 1 / 40;
		}
		pressContinue.setColorMultiply(2/3, 2/3, 0, transcparency);
	}

	function startNextLevel() {
		if(GGD.level > GGD.maxLevel) {
			changeState(new Credits());
		} else {
			changeState(new GameState(GGD.level+''));
		}
	}
}
