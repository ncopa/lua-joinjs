# lua-joinjs

A Lua module to join various javascript modules in a directory.

##

lua-joinjs concatenates various javascript module files in a directory
into a single file in dependency order. Each javascript file is
considered to be a separate module which can depend on others.
Dependencies is specified as comments:

```
// depends: module.js
```

It wil also define a javascript function 'require(file)' which will
return the javascript module in the file.


## Example ##
If you for example have the following files in a directory called _js_:

 js/foo.js
 js/bar.js


Where bar.js depends on foo.js.

The foo.js javascript module should be defined as:
```
var foo = {}
foo.hello = function() { return "hello from foo"; }
return foo
```

The js/bar.js looks like:
```
// depends: foo.js
var bar = {};
bar.sayhello = function() {
    var foo = require('foo.js');
    alert(foo.hello());
}

return bar;
```

To join them with lua-joinjs (with Lua code):
```
js = require('joinjs')
js.read_dir('js')
-- print the concatenated javascript to stdout
js.dump()
```

To use the module from main javascript code you can do:
```
var bar = require('bar.js');
bar.sayhello();
```
