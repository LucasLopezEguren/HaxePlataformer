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
    public static var level:Int = 0;

    public static function restart() {
        continues = 3;
        level = 0;
        score = 0;
    }

    public static function destroy() {
        player=null;
        simulationLayer=null;
        camera=null;
    }
}