package example.app;

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
		var dom = ReactDOM.findDOMNode(view);
		untyped console.log(dom);
	}
	
	public function viewRemoved(view:ReactElement)
	{
		trace('Removed: ' + Type.getClassName(Type.getClass(view)));
	}
	
}