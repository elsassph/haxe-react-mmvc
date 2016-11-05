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

package example.todo.view;

import example.todo.model.TodoList;
import mmvc.react.IMediatedComponent;
import msignal.Signal.Signal1;
import react.ReactComponent;
import react.ReactMacro.jsx;

typedef TodoListState = {
	?message: String,
	?list: TodoList
}

@:expose
class TodoListView extends ReactComponentOfState<TodoListState> implements IMediatedComponent
{
	// ship mediator with view for code-splitting / live-reload
	static var mediatorClass = TodoListViewMediator; 
	
	public var addNew:Signal1<String> = new Signal1();
	public var toggle:Signal1<String> = new Signal1();
	
	public function new()
	{
		super();
		state = { 
			message: 'Loading...' 
		};
	}

	/**
		Displays an error in the stats view
	*/
	public function showError(message:String)
	{
		setState({ 
			message: message
		});
	}
	
	/**
		Whenever the list of items of the list change
	*/
	public function setData(data:TodoList)
	{
		var message = data == null || data.size == 0
			? 'No items'
			: '${data.getRemaining()} remaining of ${data.size} items completed';
		setState({ 
			list: data,
			message: message
		});
	}
	
	override public function render():ReactElement 
	{
		return jsx('
			<div>
				<TodoStatsView message=${state.message} addNew=${addNew.dispatch}/>
				<hr/>
				<ul>
					${mapList()}
				</ul>
			</div>
		');
	}
	
	function mapList()
	{
		if (state.list == null || state.list.size == 0) return null;
		
		return [for (todo in state.list)
			jsx('<TodoView key=${todo.key} todo=$todo toggle=${toggle.dispatch}/>')
		];
	}
}
