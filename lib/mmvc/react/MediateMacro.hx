package mmvc.react;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;

class MediateMacro
{
	// map is populated by ContextMacro by looking up the mediateMap.mapView() calls
	static public var map:Map<String, String> = new Map();
	
	static public function build() 
	{
		var type:ClassType = Context.getLocalClass().get();
		type.meta.add(':expose', [], Context.currentPos());
		
		var fields = Context.getBuildFields();
		
		addMediator(fields);
		
		if (!updateMount(fields)) addMount(fields);
		if (!updateUnmount(fields)) addUnmount(fields);
		addContextTypes(fields);
		
		return fields;
	}
	
	static function addMediator(fields:Array<Field>) 
	{
		var fqcn = getFQCN();
		if (map.exists(fqcn))
		{
			// add static reference to mediator to "ship" the mediator with the view
			var mediator = Context.parse(map.get(fqcn), Context.currentPos());
			fields.push({
				name: 'mediatorClass',
				access: [APublic, AStatic],
				kind: FVar(null, mediator),
				pos: Context.currentPos()
			});
		}
	}
	
	static function getFQCN()
	{
		var t:ClassType = Context.getLocalClass().get();
		if (t.module.indexOf('.${t.name}') > 0) return t.module;
		else return t.module + '.${t.name}';
	}
	
	static function addContextTypes(fields:Array<Field>) 
	{
		var contextTypes = macro {
			mediator: react.React.PropTypes.object.isRequired
		};
		fields.push({
			name: 'contextTypes',
			access: [APublic, AStatic],
			kind: FVar(null, contextTypes),
			pos: Context.currentPos()
		});
	}
	
	static function addUnmount(fields:Array<Field>) 
	{
		var componentWillUnmount = {
			args: [],
			ret: macro :Void,
			expr: macro this.context.mediator.viewRemoved(this)
		}
		
		fields.push({
			name: 'componentWillUnmount',
			access: [APublic, AOverride],
			kind: FFun(componentWillUnmount),
			pos: Context.currentPos()
		});
	}
	
	static function updateUnmount(fields:Array<Field>) 
	{
		for (field in fields)
		{
			if (field.name == 'componentWillUnmount')
			{
				switch (field.kind) {
					case FFun(f):
						f.expr = macro {
							${f.expr}
							this.context.mediator.viewRemoved(this);
						};
						return true;
					default:
				}
			}
		}
		return false;
	}
	
	static function addMount(fields:Array<Field>) 
	{
		var componentDidMount = {
			args: [],
			ret: macro :Void,
			expr: macro this.context.mediator.viewAdded(this)
		}
		
		fields.push({
			name: 'componentDidMount',
			access: [APublic, AOverride],
			kind: FFun(componentDidMount),
			pos: Context.currentPos()
		});
	}
	
	static function updateMount(fields:Array<Field>) 
	{
		for (field in fields)
		{
			if (field.name == 'componentDidMount')
			{
				switch (field.kind) {
					case FFun(f):
						f.expr = macro {
							this.context.mediator.viewAdded(this);
							${f.expr}
						};
						return true;
					default:
				}
			}
		}
		return false;
	}
}
#end
