package mmvc.react;

import minject.Injector;
import mmvc.api.IMediator;
import react.React;
import react.ReactComponent;
import react.ReactMacro.jsx;

class ReactApplication implements mmvc.api.IViewContainer
{
	public var viewAdded:Dynamic -> Void;
	public var viewRemoved:Dynamic -> Void;
	public var injector:Injector;

	public function new()
	{
	}
	
	public function mediate(child:ReactElement)
	{
		return jsx('
			<ContextMediator viewAdded=$viewAdded viewRemoved=$viewRemoved injector=$injector>
				$child
			</ContextMediator>
		');
	}
	
	public function isAdded(view:Dynamic):Bool
	{
		return true;
	}
}

typedef ContextMediatorProps = {
	var viewAdded:Dynamic -> Void;
	var viewRemoved:Dynamic -> Void;
	var injector:Injector;
	var children:Dynamic;
}

@:reactContext
class ContextMediator extends ReactComponentOfProps<ContextMediatorProps>
{
	// lifecycle
	var listener:ILifecycleListener;
	
	static public var childContextTypes = {
		mediator: React.PropTypes.object.isRequired
	};
	
	static public var propTypes = {
		children: React.PropTypes.element.isRequired
	};

	public function new() 
	{
		super();
	}
	
	public function viewAdded(view:ReactElement)
	{
		// livereload: look for mediator override
		var t = Type.getClass(view);
		if (Reflect.hasField(t, 'mediatorClass'))
		{
			var mediatorClass = Reflect.field(t, 'mediatorClass');
			var mediator:IMediator = props.injector.instantiate(mediatorClass);
			mediator.setViewComponent(view);
			mediator.preRegister();
			untyped view.__mediator = mediator;
		}
		// default mmvc mediation
		else props.viewAdded(view);
		
		// lifecycle
		if (listener != null) listener.viewAdded(view);
	}
	
	public function viewRemoved(view:ReactElement)
	{
		// lifecycle
		if (listener != null) listener.viewRemoved(view);
		
		// livereload: remove mediator override
		if (untyped view.__mediator) {
			var mediator:IMediator = untyped view.__mediator;
			mediator.preRemove();
			mediator.setViewComponent(null);
			untyped view.__mediator = null;
		}
		// default mmvc mediation
		else props.viewRemoved(view);
	}

	public function getChildContext()
	{
		return {
			mediator: this
		};
	}
	
	override function render()
	{
		listener = props.injector.getInstance(ILifecycleListener);
		
		return React.Children.only(props.children);
	}
}