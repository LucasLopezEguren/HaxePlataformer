import kha.input.KeyCode;
import com.framework.utils.Input;
import com.soundLib.SoundManager.SM;
import com.gEngine.display.Sprite;
import com.gEngine.display.Text;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Camera;
import com.gEngine.display.Layer;
import gameObjects.Player;

typedef GGD = GlobalGameData; 
class GlobalGameData {

    public static var player:Player;
    public static var simulationLayer:Layer;
    public static var camera:Camera;
    public static var gravity:Int = 2000;
    public static var playerProyectilesCollisions:CollisionGroup;
    public static var enemyProyectilesCollisions:CollisionGroup;
    public static var score:Int = 0;
    public static var continues:Int = 3;
    public static var level:Int = 1;
    public static var maxLevel:Int = 3;

    public static function levelCompleted() {
        level++;
    }

    public static function soundControll(soundIcon:Sprite){
        soundControllWithoutIcon();
        if (SM.musicMuted) {
            soundIcon.colorMultiplication (1, 0, 0, 1);
        } else {
            soundIcon.colorMultiplication (1, 1, 1, 1);
        }
    }

    public static function soundControllWithoutIcon(){
        if (Input.i.isKeyCodePressed(KeyCode.M)){
            if (SM.musicMuted) {
                SM.unMuteMusic();
                SM.unMuteSound();
            } else {
                SM.muteMusic();
                SM.muteSound();
            }
        }
    }

    public static function destroy() {
        continues = 3;
        level = 1;
        score = 0;
        player=null;
        simulationLayer=null;
        camera=null;
    }
}