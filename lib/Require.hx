package;

import js.Browser;
import js.html.LinkElement;
import js.html.ScriptElement;
import js.Promise;

class Require
{
	static public var jsPath = './';
	static public var cssPath = './';
	
	static var loaded:Map<String, Promise<String>> = new Map();
	static var handlers:Map<String, String -> Void> = new Map();
	static var isHot:Bool;
	
	/**
	 * Load JS module
	 * @param	name	JS file name without extension
	 * @param	loadCss	Please also load a CSS of the same name
	 */
	static public function module(name:String, loadCss:Bool = true):Promise<String>
	{
		if (loaded.exists(name)) 
			return loaded.get(name);
		
		var p = new Promise<String>(function(resolve, reject) {
			var doc = Browser.document;
			var pending = loadCss ? 2 : 1;
			var css:LinkElement = null;
			var script:ScriptElement = null;
			var hasFailed:Bool = false;
			
			function resourceLoaded() 
			{
				if (--pending == 0) 
					resolve(name);
			}
			function resourceFailed()
			{
				if (!hasFailed)
				{
					hasFailed = true;
					
					loaded.remove(name); // retry
					if (css != null) doc.body.removeChild(css);
					doc.body.removeChild(script);
					
					reject(name);
				}
			}
			
			if (loadCss)
			{
				css = doc.createLinkElement();
				css.rel = 'stylesheet';
				css.onload = resourceLoaded;
				css.onerror = resourceFailed;
				css.href = cssPath + name + '.css';
				doc.body.appendChild(css);
			}
			
			script = doc.createScriptElement();
			script.onload = resourceLoaded;
			script.onerror = resourceFailed;
			script.src = jsPath + name + '.js';
			doc.body.appendChild(script);
		});
		
		loaded.set(name, p);
		return p;
	}
	
	static public function hot(?handler:String -> Void, ?forModule:String) 
	{
		if (handler != null)
		{
			if (forModule == null) forModule = '*';
			handlers.set(forModule, handler);
		}
		
		if (!isHot)
		{
			isHot = true;
			Browser.document.addEventListener('LiveReloadConnect', function() {
				untyped window.LiveReload.reloader.plugins.push({
					reload: Require.reload
				});
			});
		}
	}
	
	static function reload(path:String, options:Dynamic)
	{
		if (path.indexOf('.js') > 0) {
			var module = path.split('.')[0];
			if (loaded.exists(module)) {
				var script = Browser.document.querySelector('script[src$="$path"]');
				if (script != null) script.remove();
				loaded.remove(module);
				
				Require.module(module, false).then(function(id) {
					trigger(module);
					trigger('*');
				});
			}
			return true;
		}
		return false;
	}
	
	static function trigger(module:String) 
	{
		if (handlers.exists(module))
			handlers.get(module)(module);
	}
}
