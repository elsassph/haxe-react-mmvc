package mmvc.react;

import minject.Injector;
import mmvc.api.IMediator;
import react.React;
import react.ReactComponent;
import react.ReactMacro.jsx;
import react.ReactPropTypes;

/**
	Base class for the root view of a React MMVC application
	React rendering should be wrapped by the `mediate` function:

		ReactDOM.render( mediate(jsx('<MyApp/>')), root);

**/
class ReactApplication implements mmvc.api.IViewContainer
{
	public var viewAdded:Dynamic -> Void;
	public var viewRemoved:Dynamic -> Void;
	public var injector:Injector;

	public function new()
	{
	}

	/**
		Wrap React root with a context/mediator provider
	**/
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


/* CONTEXT MEDIATOR */

typedef ContextMediatorProps = {
	var viewAdded:Dynamic -> Void;
	var viewRemoved:Dynamic -> Void;
	var injector:Injector;
	var children:Dynamic;
}

/**
	ContextMediator provides the viewAdded/viewRemoved methods allowing the
	automatic creation of mediators when components are added/removed.

	For lazy-loading/live-reload, the mediator is looked up as a static
	`mediatorClass` property of the view class.

	Additionally, if a ILifecycleListener is in the context, it will also
	be called when components are added/removed.
**/
class ContextMediator extends ReactComponentOfProps<ContextMediatorProps>
{
	// lifecycle
	var listener:ILifecycleListener;

	static public var childContextTypes = {
		mediator: ReactPropTypes.object.isRequired
	};

	static public var propTypes = {
		children: ReactPropTypes.element.isRequired
	};

	public function new()
	{
		super();
	}

	public function viewAdded(view:ReactComponent)
	{
		// look for mediator override
		var t = Type.getClass(view);
		if (Reflect.hasField(t, 'mediatorClass'))
		{
			var mediatorClass = Reflect.field(t, 'mediatorClass');
			var mediator:IMediator = props.injector.instantiate(mediatorClass);
			mediator.setViewComponent(view);
			mediator.preRegister();
			untyped view.__mediator = mediator;
		}
		// mmvc mediation
		else props.viewAdded(view);

		// lifecycle
		if (listener != null) listener.viewAdded(view);
	}

	public function viewRemoved(view:ReactComponent)
	{
		// lifecycle
		if (listener != null) listener.viewRemoved(view);

		// remove mediator override
		if (untyped view.__mediator) {
			var mediator:IMediator = untyped view.__mediator;
			mediator.preRemove();
			mediator.setViewComponent(null);
			untyped view.__mediator = null;
		}
		// mmvc mediation
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