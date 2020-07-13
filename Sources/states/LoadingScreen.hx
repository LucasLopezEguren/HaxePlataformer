package states;

import com.gEngine.display.Sprite;
import com.loading.basicResources.ImageLoader;
import com.soundLib.SoundManager.SM;
import com.loading.basicResources.SoundLoader;
import com.loading.Resources;
import com.gEngine.helper.RectangleDisplay;
import com.framework.Simulation;
import com.framework.utils.State;
import com.gEngine.GEngine;
import kha.Assets;

/* @author Lucas (181830) */
class LoadingScreen extends State {
	public function new() {
		super();
	}

	override function load(resources:Resources) {
		resources.add(new ImageLoader(Assets.images.logoName));
		// resources.add(new SoundLoader(Assets.sounds.backgroundName));
	}

	var allLoaded:Bool;
	var backgroundLoader:RectangleDisplay;
	var bar:RectangleDisplay;
    var barColor:Int;

	override function init() {
		stageColor(0.2, 0.2, 0.2);
		Assets.loadEverything(onAllLoaded);
		backgroundLoader = new RectangleDisplay();
		backgroundLoader.x = 50;
		backgroundLoader.y = GEngine.virtualHeight * 0.5;
		backgroundLoader.scaleX = GEngine.virtualWidth - 50 * 2;
		backgroundLoader.scaleY = 25;
		stage.addChild(backgroundLoader);

        var title = new Sprite("logo");
        title.scaleX = 12/25;
        title.scaleY = 12/25;
        title.x = GEngine.virtualWidth * 0.5 - ((title.width() * 0.5)/25)*12;
        title.y = GEngine.virtualHeight * 0.5 - 250;
        stage.addChild(title);

		bar = new RectangleDisplay();
		bar.x = 50;
		bar.y = GEngine.virtualHeight * 0.5;
		bar.scaleX = 0;
		bar.scaleY = 25;
		bar.setColor(150, 0, 0);
		stage.addChild(bar);
	}

	function onAllLoaded() {
		allLoaded = true;
	}

	override function update(aDt:Float):Void {
		super.update(aDt);
		bar.scaleX = Assets.progress * GEngine.virtualWidth - 50 * 2;
        barColor = Math.floor(Assets.progress * 150);
        bar.setColor(255, barColor, 0);
		if (allLoaded) {
			Simulation.i.manualLoad = true;
			// SM.playMusic("background");
			// SM.musicVolume(2 / 100);
			startGame();
		}
	}

	function startGame() {
		changeState(new IntroScreen());
	}
}