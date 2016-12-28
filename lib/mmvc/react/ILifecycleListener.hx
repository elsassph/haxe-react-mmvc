package mmvc.react;

import react.ReactComponent;

interface ILifecycleListener 
{
	function viewAdded (view:ReactComponent):Void;
	function viewRemoved (view:ReactComponent):Void;
}
