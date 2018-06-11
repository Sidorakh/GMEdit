package editors;
import gml.file.GmlFile;
import js.html.Element;

/**
 * ...
 * @author YellowAfterlife
 */
class Editor {
	
	public static var container:Element;
	public static function init() {
		EditCode.container = Main.document.getElementById("ace_container");
		container = EditCode.container.parentElement;
	}
	
	public var element:Element;
	public var file:GmlFile;
	
	public function new(file:GmlFile) {
		this.file = file;
	}
	
	/** new -> load -> ready */
	public function ready():Void {
		
	}
	
	public function stateSave() {
		// may save state to LS
	}
	public function stateLoad() {
		// may load previously saved state
	}
	
	public function focusGain(prev:Editor):Void {
		if (prev.element != element) {
			container.appendChild(element);
		}
	}
	public function focusLost(next:Editor):Void {
		if (next.element != element) {
			container.removeChild(element);
		}
	}
	
	public function load(data:Dynamic):Void {
		
	}
	public function save():Bool {
		return false;
	}
	public function checkChanges():Void {
		
	}
}
