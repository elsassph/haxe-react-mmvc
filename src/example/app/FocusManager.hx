package example.app;

import js.Browser;
import js.html.Event;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import mmvc.react.ILifecycleListener;
import react.ReactComponent;
import react.ReactDOM;

class FocusManager implements ILifecycleListener
{

	public function new() 
	{
	}
	
	public function viewAdded(view:ReactComponent)
	{
		trace('Added: ' + Type.getClassName(Type.getClass(view)));
		
		// wire Space key to click for "actionable" components
		var dom = ReactDOM.findDOMNode(view);
		if (dom.classList.contains('actionable'))
		{
			dom.addEventListener('keydown', function(e:KeyboardEvent) {
				if (e.keyCode == 32) 
				{
					var me = new MouseEvent('click', cast {
						view: Browser.window,
						bubbles: true,
						cancelable: true
					});
					dom.dispatchEvent(me);
				}
			});
		}
	}
	
	public function viewRemoved(view:ReactComponent)
	{
		trace('Removed: ' + Type.getClassName(Type.getClass(view)));
	}
	
}