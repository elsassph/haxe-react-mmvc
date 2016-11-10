package mmvc.react;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class ContextMacro
{
	static public function build() 
	{
		// Remove React views (IMediatedComponent) mediator mapping declaration from context
		// Mapping will be defined as a static reference added to the view class directly
		
		var fields:Array<Field> = Context.getBuildFields();
		for (field in fields)
		{
			switch (field.kind)
			{
				// look at the code in every function
				case FFun(_.expr.expr => EBlock(exprs)):
					for (i in 0...exprs.length)
					{
						var expr = exprs[i];
						switch (expr)
						{
							// find mediator mappings, extract mediated React views mappings
							case macro mediatorMap.mapView($viewClass, $mediatorClass):
								var fqcnView = ExprTools.toString(viewClass);
								var fqcnMediator = getFQCN(ExprTools.toString(mediatorClass));
								MediateMacro.map.set(fqcnView, fqcnMediator);
								if (isMediated(fqcnView)) 
								{
									if (fqcnView.indexOf('.') < 0) // not fully qualified
										Context.fatalError('Mediated view class $fqcnView must be fully qualified in Context.', viewClass.pos);
									exprs[i] = macro {};
								}
							default:
						}
					}
				default:
			}
		}
		return fields;
	}
	
	static function isMediated(fqcnView:String) 
	{
		var view = Context.getType(fqcnView);
		switch (view)
		{
			case TInst(_.get() => t, _):
				for (t in t.interfaces)
				{
					var interf = t.t.get();
					if (interf.module == 'mmvc.react.IMediatedComponent') return true;
				}
			default:
		}
		return false;
	}
	
	static function getFQCN(name:String) 
	{
		var type = Context.getType(name);
		return switch (type) 
		{
			case TInst(_.get() => t, p):
				if (t.module.indexOf('.${t.name}') > 0) t.module;
				else t.module + '.${t.name}';
			default: 
				Context.error('$name is not a class', Context.currentPos());
		}
	}
}
#end
