package states;

import com.soundLib.SoundManager.SM;
import com.loading.basicResources.SoundLoader;
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
class Credits extends State {
	var credits:Text;

	public function new() {
		super();
	}

	override function load(resources:Resources) {
		var atlas:JoinAtlas = new JoinAtlas(1024, 1024);
		atlas.add(new FontLoader(Assets.fonts.PixelOperator8_BoldName, 30));
		resources.add(atlas);
		resources.add(new SoundLoader(Assets.sounds.ffName));
	}

	override function init() {
		SM.playMusic(Assets.sounds.ffName);
		credits = new Text(Assets.fonts.PixelOperator8_BoldName);
		credits.text = 
		'\n' +
		'\n' +
		'\n' +
		"Finally you could escape from hell" +
		'\n' +
		'\n' +
		'\n' +
		"CONGRATULATIONS YOU SCORED " + GGD.score +
		'\n' +
		'\n' +
		'\n' +
		'\n Game developer: Lucas Lopez' +
		'\n' +
		'\n' +
		'\n' +
		'\n Game desaigner: Lucas Lopez' +
		'\n' +
		'\n' +
		'\n' +
		'\n Level design: Lucas Lopez ' +
		'\n' +
		'\n' +
		'\n' +
		'\n Background design: Nathaly Alvez ' +
		'\n' +
		'\n' +
		'\n' +
		'\n Sprite design: Gabriel Molfino, ' +
		'\n' +
		'\n Joaquin Bello' +
		'\n' +
		'\n Planet ceuntari, Riot,' +
		'\n' +
		'\n Josito, Z-studios, DMCA' +
		'\n' +
		'\n' +
		'\n' +
		'\n Sprite editor: Lucas Lopez' +
		'\n' +
		'\n' +
		'\n' +
		'\n Music & Sounds: Billie Elish, ' +
		'\n Final Fantasy, GFX Sounds (YouTube)' +
		'\n' +
		'\n' +
		'\n' +
		'\n Thank you for playing my game!';
		credits.x = (GEngine.virtualWidth / 2 - (credits.width() / 2));
		credits.y = GEngine.virtualHeight;
		stage.addChild(credits);
	}
	static var credistHeight:Float = 1000;
	override function update(dt:Float) {
		credits.y -= 1;
		super.update(dt);
		if (Input.i.isKeyCodePressed(KeyCode.Return) || credits.y < -credistHeight) {
			GGD.destroy();
			changeState(new IntroScreen());
		}
	}
}
