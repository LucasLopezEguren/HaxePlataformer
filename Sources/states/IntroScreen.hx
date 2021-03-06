package states;

import GlobalGameData.GGD;
import com.gEngine.helper.RectangleDisplay;
import com.loading.basicResources.SpriteSheetLoader;
import com.loading.basicResources.JoinAtlas;
import com.loading.basicResources.FontLoader;
import com.loading.basicResources.SparrowLoader;
import com.loading.basicResources.ImageLoader;
import com.loading.Resources;
import com.framework.utils.Input;
import com.framework.utils.State;
import com.gEngine.display.StaticLayer;
import com.gEngine.display.Sprite;
import com.gEngine.display.Text;
import com.gEngine.display.Layer;
import com.gEngine.GEngine;
import kha.Assets;
import kha.input.KeyCode;
import gameObjects.Player;

/* @author Lucas (181830) */
class IntroScreen extends State {
	override function load(resources:Resources) {
		var atlas:JoinAtlas = new JoinAtlas(2048, 2048);
		atlas.add(new ImageLoader(Assets.images.hellsGateIntroName));
		atlas.add(new FontLoader(Assets.fonts.PixelOperator8_BoldName, 30));
		resources.add(new ImageLoader(Assets.images.logoName));
		resources.add(atlas);
	}

	var simulationLayer:Layer;
	var selectCharacter:Text;
	var selectedCharacter:String;
	var hudLayer:Layer;
	var time:Float = 0;
	var logo:Sprite;
	var pressStart:Text;
	var levelDisplay:Text;
	var background:Sprite;

	override function init() {
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);
		
		background = new Sprite(Assets.images.hellsGateIntroName);
		background.x = background.y = 0;
		stage.addChild(background);

		logo = new Sprite("logo");
		logo.x = GEngine.virtualWidth * 0.10;
		logo.y = GEngine.virtualHeight * 0.10;
		stage.addChild(logo);
		
		hudLayer = new StaticLayer();
		stage.addChild(hudLayer);

		pressStart = new Text(Assets.fonts.PixelOperator8_BoldName);
		pressStart.text = "PRESS ENTER TO PLAY";
		pressStart.scaleX = 1 / 2;
		pressStart.scaleY = 1 / 2;
		pressStart.y = 660;
		pressStart.x = 250 - (pressStart.width() / 4);

		pressStart.setColorMultiply(9 / 10, 9 / 10, 9 / 10, 1);

		hudLayer.addChild(pressStart);

		levelDisplay = new Text(Assets.fonts.PixelOperator8_BoldName);
		levelDisplay.text = "Level " + GGD.level;
		levelDisplay.x = (GEngine.virtualWidth / 2 - (levelDisplay.width() * 0.5) * (2 / 3)) - 7;
		levelDisplay.y = GEngine.virtualHeight / 2 + 60;
		levelDisplay.setColorMultiply(100 / 255, 20 / 255, 100 / 255, 0);
		hudLayer.addChild(levelDisplay);
	}

	var changeScreen:Bool = false;
	var isDrawn:Bool = false;
	var more:Bool = false;
	var debugging:Bool = false;
	var music:Bool = true;
	var transcparency:Float = 0;

	override function update(dt:Float) {
		super.update(dt);
		GlobalGameData.soundControllWithoutIcon();
		if (Input.i.isKeyCodePressed(KeyCode.T)) debugging = !debugging;
		if (debugging){
			levelDisplay.setColorMultiply(100 / 255, 20 / 255, 100 / 255, 1);
			levelDisplay.text = "Level " + GGD.level;
			if (Input.i.isKeyCodePressed(KeyCode.Up)) GGD.level = 1 + (GGD.level % GGD.maxLevel);
			if (Input.i.isKeyCodePressed(KeyCode.Down)) GGD.level = 1 - (GGD.level % GGD.maxLevel);
			
		} else {
			levelDisplay.setColorMultiply(100 / 255, 20 / 255, 100 / 255, 0);
		}
		if (Input.i.isKeyCodePressed(KeyCode.Return) && !changeScreen) {
			changeScreen = true;
			pressStart.removeFromParent();
			transcparency = 1;
		}
		if (changeScreen) {
			pressStart.setColorMultiply(1, 191 / 255, 57 / 255, 0);
			logo.colorMultiplication(transcparency, transcparency, transcparency, 1);
			background.colorMultiplication(transcparency, transcparency, transcparency, 1);
			if (transcparency > 0){
				transcparency -= 1 / 40;
			}
			if ( transcparency <= 0) {
				transcparency = 0;
				startGame();
			}
		} else {
			if (transcparency <= 0 || transcparency >= 1) {
				more = !more;
			}
			if (more) {
				transcparency += 1 / 40;
			} else {
				transcparency -= 1 / 40;
			}
			pressStart.setColorMultiply(1, 191 / 255, 57 / 255, transcparency);
		}
	}

	function sound() {
		GlobalGameData.soundControllWithoutIcon();
	}

	function startGame() {
		changeState(new GameState(''+GGD.level));
	}
}
