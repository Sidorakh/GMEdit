package gmx;
import gml.GmlAPI;
import gml.GmlReader;
import gmx.GmxEvent;
import gmx.SfGmx;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GmxObject {
	public static var errorText:String;
	public static function getCode(gmx:SfGmx):String {
		var out = "";
		var errors = "";
		var objectIDs = GmlAPI.gmlAssetIDs["object"];
		for (evOuter in gmx.findAll("events")) {
			var events = evOuter.findAll("event");
			events.sort(function(a:SfGmx, b:SfGmx) {
				var atype = Std.parseInt(a.get("eventtype"));
				var btype = Std.parseInt(b.get("eventtype"));
				if (atype != btype) return atype - btype;
				//
				var aname = a.get("ename");
				var bname = b.get("ename");
				if (aname != null || bname != null) {
					var aid = objectIDs[aname];
					var bid = objectIDs[bname];
					if (aid != null && bid != null) return aid - bid;
					return untyped aname < bname ? 1 : -1;
				}
				//
				var anumb = Std.parseInt(a.get("enumb"));
				var bnumb = Std.parseInt(b.get("enumb"));
				return anumb - bnumb;
			});
			for (event in events) {
				var type = Std.parseInt(event.get("eventtype"));
				var ename = event.get("ename");
				var numb:Int = ename == null ? Std.parseInt(event.get("enumb")) : null;
				if (out != "") out += "\n";
				var name = GmxEvent.toString(type, numb, ename);
				out += "#define " + name;
				var actions = event.findAll("action");
				function addAction(action:SfGmx, head:Bool) {
					if (head) out += "\n\n";
					if(action.findText("libid") != "1"
					|| action.findText("id") != "603"
					|| action.findText("useapplyto") != "-1") {
						errors += "Can't read non-code block in " + name + "\n";
						return;
					}
					var code = action.find("arguments").find("argument").find("string").text;
					if (head && !StringTools.startsWith(code, "///")) {
						out += "///\n";
					}
					out += code;
				}
				if (actions.length != 0) {
					out += "\n";
					addAction(actions[0], false);
					for (i in 1 ... actions.length) {
						addAction(actions[i], true);
					}
				}
			}
		}
		if (errors != "") {
			errorText = errors;
			return null;
		} else return out;
	}
	
	
	public static function updateCode(gmx:SfGmx, gmlCode:String):Bool {
		var eventData:Array<{ data:GmxEventData, code:String }> = [];
		var errors = "";
		{ // generate eventData
			var q = new GmlReader(gmlCode);
			var evStart = 0;
			var evName = null;
			//
			var flushData:GmxEventData;
			var flushCode:String;
			inline function flush(till:Int) {
				flushCode = q.substring(evStart, till).rtrim();
				if (evName == null) {
					if (flushCode != "") {
						errors += "There's code prior to first event definition.\n";
						//trace(flushCode);
					}
				} else {
					flushData = GmxEvent.fromString(evName);
					if (flushData != null) {
						eventData.push({ data: flushData, code: flushCode + "\r\n" });
					} else errors += '`$evName` is not a known event type.\n';
				}
			}
			//
			while (q.loop) {
				var c = q.read();
				switch (c) {
					case "/".code: switch (q.peek()) {
						case "/".code: {
							q.skip();
							q.skipLine();
						};
						case "*".code: {
							q.skip();
							q.skipComment();
						};
						default:
					};
					case '"'.code, "'".code: {
						q.skipString1(c);
					};
					case "#".code: {
						if (q.pos > 1) switch (q.get(q.pos - 2)) {
							case "\r".code, "\n".code: { };
							default: continue;
						}
						if (q.substr(q.pos, 6) != "define") continue;
						//
						flush(q.pos - 1);
						q.skip(6);
						// skip spaces:
						while (q.loop) {
							c = q.peek();
							if (c.isSpace0()) {
								q.skip();
							} else break;
						}
						// read name:
						var nameStart = q.pos;
						while (q.loop) {
							c = q.peek();
							if (c.isIdent1() || c == ":".code) {
								q.skip();
							} else break;
						}
						evName = q.substring(nameStart, q.pos);
						// skip spaces after:
						while (q.loop) {
							c = q.peek();
							if (c.isSpace0()) {
								q.skip();
							} else break;
						}
						// skip line:
						if (q.loop) switch (q.peek()) {
							case "\r".code: {
								q.skip();
								if (q.loop && q.peek() == "\n".code) q.skip();
							};
							case "\n".code: q.skip();
						}
						evStart = q.pos;
					};
					default:
				} // switch (q.read)
			}
			flush(q.pos);
		} // get eventData
		if (errors != "") {
			errorText = errors;
			return false;
		}
		//
		var evCtr = gmx.find("events");
		if (evCtr == null) {
			evCtr = new SfGmx("events");
			gmx.addChild(evCtr);
		} else evCtr.clearChildren();
		//
		var objectIDs = GmlAPI.gmlAssetIDs["object"];
		eventData.sort(function(a, b) {
			var adata = a.data;
			var bdata = b.data;
			var atype = adata.type;
			var btype = bdata.type;
			if (atype != btype) return atype - btype;
			//
			var aname = adata.name;
			var bname = bdata.name;
			if (aname != null || bname != null) {
				var aid = objectIDs[aname];
				var bid = objectIDs[bname];
				if (aid != null && bid != null) return bid - aid;
				return untyped aname < bname ? 1 : -1;
			}
			//
			var anumb = adata.numb;
			var bnumb = bdata.numb;
			return bnumb - anumb;
		});
		//
		for (source in eventData) {
			var event = new SfGmx("event");
			var data = source.data;
			event.set("eventtype", "" + data.type);
			if (data.numb != null) event.set("enumb", "" + data.numb);
			if (data.name != null) event.set("ename", "" + data.name);
			evCtr.addChild(event);
			//
			var action = new SfGmx("action");
			action.addTextChild("libid", "1");
			action.addTextChild("id", "603");
			action.addTextChild("kind", "7");
			action.addTextChild("userelative", "0");
			action.addTextChild("isquestion", "0");
			action.addTextChild("useapplyto", "-1");
			action.addTextChild("exetype", "2");
			action.addTextChild("functionname", "");
			action.addTextChild("codestring", "");
			action.addTextChild("whoName", "self");
			action.addTextChild("relative", "0");
			action.addTextChild("isnot", "0");
			event.addChild(action);
			//
			var arguments = new SfGmx("arguments");
			action.addChild(arguments);
			var argument = new SfGmx("argument");
			argument.addTextChild("kind", "1");
			argument.addTextChild("string", source.code);
			arguments.addChild(argument);
			//
		}
		//
		//trace(gmx.toGmxString());
		return true;
	} // updateCode
}
