# Todo App

This is a simple application demonstrating the main components of MMVC
as it could be used in a React JS application. With hot-reload.

MMVC is a port of the ActionScript 3 RobotLegs MVC framework with signals and 
Haxe refinements. It offers a powerful Dependency Injection system for React JS.

MMVC is a "battle tested" library, used since 2012 to build dozens of large Haxe JS 
applications on all kind of platforms, from browsers to consoles and slow smart TVs.

> This application requires NPM and Haxe 3.2.1 or greater


## Overview

This is a partially implemented Todo application, demonstrating the core 
elements of MMVC:

* configuring application via a Context (`ApplicationContext`)
* loads a list of Todos from a file via a Command (`LoadTodoListCommand`)
* updating contents of a managed Model (`TodoList`) 
* triggering commands via a Signal and listens to responses (`LoadTodoList`)
* instanciating Mediators for registered Views (`ApplicationViewMediator`, 
  `TodoListViewMediator`)
* configuring a "React lifecycle consumer" for the mediated components, allowing 
  a shared controller (`FocusManager`) to see all the components added/removed.

The application is also hot-reload capable for fast iteration:

* read carefully: https://github.com/elsassph/haxe-modular

NPM dependencies are bundled into one JS file shared between the Haxe-JS bundles.


### Installation

Install NPM libraries:

	npm install

Install Haxe libraries

	haxelib install react
	haxelib install react-router
	haxelib install mmvc
	haxelib install minject
	haxelib install msignal

For more information about the libraries:

- https://github.com/massiveinteractive/haxe-react
- https://github.com/elsassph/haxe-react-router
- https://github.com/massiveinteractive/mmvc
- https://github.com/massiveinteractive/minject
- https://github.com/massiveinteractive/msignal

### NPM dependencies

NPM libraries are referenced in `src/libs.js` - add libraries your Haxe code will need.

Compile them into `bin/libs.js` for development:

	npm run libs:dev

See [Adding NPM dependencies](https://github.com/elsassph/haxe-react-redux/#adding-npm-dependencies) for a detailed process.


### Live-reload

Any LiveReload-compatible client/server should work but the simplest is `livereloadx`:

	npm run serve

Point your browser to `http://localhost:35729`

(re)Build the Haxe-JS for hot-reload: 

	haxe build.hxml -debug

That's all - no Webpack dark magic needed.

### Release build

Release build as a single Haxe-JS bundle:

	npm run release

This command does: 

- remove JS/MAP files in `bin/`
- build and minify `libs.js`
- build and minify the Haxe JS bundles 

This is obviously a naive setup - you'll probably want to add some SCSS/LESS and 
assets preprocessors.


## Application Structure

The application source contains the following classes:

### /lib

	/mcore         // Some observable collections
	/mmvc          // MMVC+React support classes

### /src

	Main.hx   // main entry point, instantiates application view and context

	/example

		/app  // main application module

			ApplicationContext.hx       // application Context
			ApplicationView.hx          // application View
			ApplicationViewMediator.hx  // application Mediator
			FocusManager.hx             // application lifecycle listener

		/todo

			/command
				LoadTodoListCommand.hx 	// MMVC Command for loading external TodoList
			/model
				Todo.hx                 // todo data object
				TodoList.hx             // collection of todos
			/signal
				LoadTodoList.hx         // signal for loading TodoList and handling responses
			/view
				TodoListView.hx         // View for TodoList
				TodoListViewMediator.hx // Mediator for TodoList. Triggers call to LoadTodoList
				TodoView.hx             // View for individual Todo items
				TodoStatsView.hx        // Summary of current todo list + button to create new Todo
				AboutView.hx            // View for About page


## Polyfills

This project loads (if needed) `core-js` and `dom4` libraries to polyfill modern JS and DOM 
features (see `index.html`).


## Haxe magic

### Code splitting and live-reload

Live-reload is implemented very simply, just using the "off the shelf" LiveReload servers and 
client libraries. LiveReload client API offers hooks to be notified of local file changes.

Haxe JS code-splitting is based on https://github.com/elsassph/haxe-modular and 
leverages [react-proxy](https://github.com/gaearon/react-proxy/tree/master) for live-reload
without state loss.

The entire setup of splitting by "route" and live-reload can be seen in the 
main `render` function which directly references the React component classes.


### Mediators live-reload

MVC isn't an approach which normally should be friendly with live-reload, but thanks to a 
good dose of Haxe macros magic, mediators can become live-reloadable!

- Mediator-view mappings are "extracted" from the monolithic context by the `ContextMacro`,
- Mediation is provided through a wrapper React component `ContextMediator` (see class
  `ReactApplication`) and logic injected in React components by the `MediateMacro`.
- Mediator is "shipped" with the view (as a generated static reference) so it can be 
  lazily loaded, and thus live-reloaded!


### Adding NPM dependencies

It's quite easy, follow the explanations here: 
https://github.com/elsassph/haxe-react-redux/
