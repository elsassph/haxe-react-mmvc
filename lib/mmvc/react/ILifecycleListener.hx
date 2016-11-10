package mmvc.react;

import react.ReactComponent.ReactElement;

interface ILifecycleListener 
{
	function viewAdded (view:ReactElement):Void;
	function viewRemoved (view:ReactElement):Void;
}
