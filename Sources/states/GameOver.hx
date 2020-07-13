package states;

import GlobalGameData.GGD;
import com.loading.basicResources.SpriteSheetLoader;
import kha.Color;
import kha.Assets;
import kha.input.KeyCode;
import com.gEngine.GEngine;
import com.gEngine.display.Text;
import com.gEngine.display.Sprite;
import com.gEngine.display.Layer;
import com.framework.utils.Input;
import com.framework.utils.State;
import com.loading.Resources;
import com.loading.basicResources.JoinAtlas;
import com.loading.basicResources.FontLoader;
import com.loading.basicResources.SparrowLoader;
import com.loading.basicResources.ImageLoader;

/* @author Lucas */
class GameOver extends State {
	var score:String;
	var sprite:String;
	var display:Sprite;
	var simulationLayer:Layer;
	var time:Float = 0;
	var level:Int = 0;

	public function new(score:String, sprite:String, level:Int) {
		super();
		this.level = level;
		this.score = score;
		this.sprite = sprite;
		GGD.continues -= 1;
	}

	override function load(resources:Resources) {
		var atlas:JoinAtlas = new JoinAtlas(1024, 1024);
		atlas.add(new ImageLoader("gameOver"));
		atlas.add(new ImageLoader("avatar"));
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
			new Sequence("recover", [28, 29, 30, 31, 0]), 
			new Sequence("rangeAttack", [11])]));
		atlas.add(new FontLoader("Kenney_Pixel", 24));
		atlas.add(new FontLoader(Assets.fonts.PixelOperator8_BoldName, 30));
		resources.add(atlas);
	}

	override function init() {
		var image = new Sprite("gameOver");
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		display = new Sprite(sprite);
		display.x = GEngine.virtualWidth * 0.5 - (display.width()/2);
		display.y = GEngine.virtualHeight * 0.75 - display.height();
		display.scaleX = 3;
		display.scaleY = 3;
		display.timeline.playAnimation("idle", false);
		simulationLayer.addChild(display);
		image.x = GEngine.virtualWidth * 0.5 - image.width() * 0.5;
		image.y = 20;
		stage.addChild(image);
		var scoreDisplay = new Text(Assets.fonts.PixelOperator8_BoldName);
		
		var levelDisplay = new Text(Assets.fonts.PixelOperator8_BoldName);
		scoreDisplay.text = "You scored " + score;
		scoreDisplay.x = (GEngine.virtualWidth / 2 - (scoreDisplay.width() * 0.5) * (2 / 3)) - 7;
		scoreDisplay.y = GEngine.virtualHeight / 2 + 60;
		scoreDisplay.setColorMultiply(100 / 255, 20 / 255, 100 / 255, 1);
		levelDisplay.text = "LEVEL " + level;
		levelDisplay.x = (GEngine.virtualWidth / 2 - levelDisplay.width() * 0.5) - 7;
		levelDisplay.y = GEngine.virtualHeight / 2;
		levelDisplay.setColorMultiply(100 / 255, 20 / 255, 100 / 255, 1);
		scoreDisplay.scaleX = scoreDisplay.scaleY = 2 / 3;

		var avatar = new Sprite("avatar");
		avatar.smooth = true;
		avatar.x = image.x + (image.width()/2) - avatar.width() * 3;
		avatar.y = image.y + image.height() - avatar.width();
		avatar.scaleX = avatar.scaleY = 3;
		simulationLayer.addChild(avatar);
		var continues = new Text(Assets.fonts.PixelOperator8_BoldName);
		continues.x = avatar.x + avatar.width() * 3;
		continues.y = image.y + image.height() + 10;
		continues.scaleX = continues.scaleY = 1 / 2;
		continues.text = 'x' + GGD.continues;
		simulationLayer.addChild(continues);

		stage.addChild(scoreDisplay);
		stage.addChild(levelDisplay);
		
		playDeadAnimation();
	}

	function playDeadAnimation() {
		display.scaleX = 3;
		display.scaleY = 3;
		display.timeline.frameRate = 1 / 10;
		display.timeline.playAnimation("heavyDamage", false);
	}

	
	var timeCounter:Float = 0;
	var timeLimit:Float = 1;
	override function update(dt:Float) {
		super.update(dt);
		if (Input.i.isKeyCodePressed(KeyCode.Return)) {
			if (GGD.continues < 0){
				GGD.destroy();
				changeState(new IntroScreen());
			} else {
				display.timeline.playAnimation('recover', false);
			}
		}
		if (display.timeline.currentAnimation == 'recover' && timeCounter >= timeLimit){
			changeState(new GameState(GGD.level+''));
		} else if (display.timeline.currentAnimation == 'recover') {
			timeCounter += dt;
		}
	}
}
