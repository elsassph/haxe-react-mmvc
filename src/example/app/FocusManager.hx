package example.app;

import js.Browser;
import js.html.Event;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import mmvc.react.ILifecycleListener;
import react.ReactComponent.ReactElement;
import react.ReactDOM;

class FocusManager implements ILifecycleListener
{

	public function new() 
	{
	}
	
	public function viewAdded(view:ReactElement)
	{
		trace('Added: ' + Type.getClassName(Type.getClass(view)));
		
		// wire Space key to click for "actionable" components
		var dom = ReactDOM.findDOMNode(view);
		if (dom.classList.contains('actionable'))
		{
			dom.addEventListener('keydown', function(e:KeyboardEvent) {
				if (e.keyCode == 32) 
				{
					var me = new MouseEvent('click', {
						view: Browser.window,
						bubbles: true,
						cancelable: true
					});
					dom.dispatchEvent(me);
				}
			});
		}
	}
	
	public function viewRemoved(view:ReactElement)
	{
		trace('Removed: ' + Type.getClassName(Type.getClass(view)));
	}
	
}