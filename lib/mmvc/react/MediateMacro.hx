package mmvc.react;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

class MediateMacro
{
	static public function build() 
	{
		var fields = Context.getBuildFields();
		
		if (!updateMount(fields)) addMount(fields);
		if (!updateUnmount(fields)) addUnmount(fields);
		addContextTypes(fields);
		
		return fields;
	}
	
	static function addContextTypes(fields:Array<Field>) 
	{
		var contextTypes = macro {
			mediator: react.React.PropTypes.object.isRequired
		};
		fields.push({
			name: 'contextTypes',
			access: [Access.APublic, Access.AStatic],
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
			access: [Access.APublic, Access.AOverride],
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
			access: [Access.APublic, Access.AOverride],
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
