/*
Copyright (c) 2012 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

package example.app;

import example.todo.view.AboutView;
import example.todo.view.TodoListView;
import js.Browser;
import js.html.DivElement;
import mmvc.react.ReactApplication;
import react.ReactDOM;
import react.ReactMacro.jsx;
import router.Link;
import router.ReactRouter;
import router.RouteComponentProps;

/**
	Main Application View.

	Implements IViewContainer to provide view added/removed events back to the Context.mediatorMap

	Extends core view class for basic event bubbling across platforms

	@see mmvc.api.IViewContainer
*/

class ApplicationView extends ReactApplication
{
	public function new()
	{
		super();
	}

	/**
		Called by ApplicationViewMediator once application is wired up to the context
		@see ApplicationViewMediator.onRegister;
	*/
	public function createViews()
	{
		var doc = Browser.document;
		var root = doc.createDivElement();
		doc.body.appendChild(root);
		
		render(root);
	}
	
	function render(root:DivElement) 
	{
		var history = ReactRouter.browserHistory;
		
		var app = ReactDOM.render( mediate(jsx('
		
			<Router history=$history>
				<Route path="/" component=$pageWrapper>
					<IndexRoute getComponent=${RouteBundle.load(TodoListView)}/>
					<Route path="about" getComponent=${RouteBundle.load(AboutView)}/>
				</Route>
			</Router>
			
		')), root);
		
		#if (debug && react_hot)
		ReactHMR.autoRefresh(app);
		#end
	}
	
	static function pageWrapper(props:RouteComponentProps)
	{
		return jsx('
			<div>
				<nav>
					<Link to="/">Todo</Link> | <Link to="/about">About</Link> 
				</nav>
				${props.children}
			</div>
		');
	}
}
