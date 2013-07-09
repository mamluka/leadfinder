// Simple JavaScript Templating
// John Resig - http://ejohn.org/ - MIT Licensed
(function(){
    var cache = {};

    this.tmpl = function tmpl(str, data){
        // Figure out if we're getting a template, or if we need to
        // load the template - and be sure to cache the result.
        var fn = !/\W/.test(str) ?
            cache[str] = cache[str] ||
                tmpl(document.getElementById(str).innerHTML) :

            // Generate a reusable function that will serve as a template
            // generator (and which will be cached).
            new Function("obj",
                "var p=[],print=function(){p.push.apply(p,arguments);};" +

                    // Introduce the data as local variables using with(){}
                    "with(obj){p.push('" +

                    // Convert the template into pure JavaScript
                    str
                        .replace(/[\r\t\n]/g, " ")
                        .split("<%").join("\t")
                        .replace(/((^|%>)[^\t]*)'/g, "$1\r")
                        .replace(/\t=(.*?)%>/g, "',$1,'")
                        .split("\t").join("');")
                        .split("%>").join("p.push('")
                        .split("\r").join("\\'")
                    + "');}return p.join('');");

        // Provide some basic currying to the user
        return data ? fn( data ) : fn;
    };
})();
/**
 * draggable - Class allows to make any element draggable
 *
 * Written by
 * Egor Khmelev (hmelyoff@gmail.com)
 *
 * Licensed under the MIT (MIT-LICENSE.txt).
 *
 * @author Egor Khmelev
 * @version 0.1.0-BETA ($Id$)
 *
 **/

(function( $ ){

    function Draggable(){
        this._init.apply( this, arguments );
    };

    Draggable.prototype.oninit = function(){

    };

    Draggable.prototype.events = function(){

    };

    Draggable.prototype.onmousedown = function(){
        this.ptr.css({ position: "absolute" });
    };

    Draggable.prototype.onmousemove = function( evt, x, y ){
        this.ptr.css({ left: x, top: y });
    };

    Draggable.prototype.onmouseup = function(){

    };

    Draggable.prototype.isDefault = {
        drag: false,
        clicked: false,
        toclick: true,
        mouseup: false
    };

    Draggable.prototype._init = function(){
        if( arguments.length > 0 ){
            this.ptr = $(arguments[0]);
            this.outer = $(".draggable-outer");

            this.is = {};
            $.extend( this.is, this.isDefault );

            var _offset = this.ptr.offset();
            this.d = {
                left: _offset.left,
                top: _offset.top,
                width: this.ptr.width(),
                height: this.ptr.height()
            };

            this.oninit.apply( this, arguments );

            this._events();
        }
    };

    Draggable.prototype._getPageCoords = function( event ){
        if( event.targetTouches && event.targetTouches[0] ){
            return { x: event.targetTouches[0].pageX, y: event.targetTouches[0].pageY };
        } else
            return { x: event.pageX, y: event.pageY };
    };

    Draggable.prototype._bindEvent = function( ptr, eventType, handler ){
        var self = this;

        if( this.supportTouches_ )
            ptr.get(0).addEventListener( this.events_[ eventType ], handler, false );

        else
            ptr.bind( this.events_[ eventType ], handler );
    };

    Draggable.prototype._events = function(){
        var self = this;

        this.supportTouches_ = 'ontouchend' in document;
        this.events_ = {
            "click": this.supportTouches_ ? "touchstart" : "click",
            "down": this.supportTouches_ ? "touchstart" : "mousedown",
            "move": this.supportTouches_ ? "touchmove" : "mousemove",
            "up"  : this.supportTouches_ ? "touchend" : "mouseup"
        };

        this._bindEvent( $( document ), "move", function( event ){
            if( self.is.drag ){
                event.stopPropagation();
                event.preventDefault();
                self._mousemove( event );
            }
        });
        this._bindEvent( $( document ), "down", function( event ){
            if( self.is.drag ){
                event.stopPropagation();
                event.preventDefault();
            }
        });
        this._bindEvent( $( document ), "up", function( event ){
            self._mouseup( event );
        });

        this._bindEvent( this.ptr, "down", function( event ){
            self._mousedown( event );
            return false;
        });
        this._bindEvent( this.ptr, "up", function( event ){
            self._mouseup( event );
        });

        this.ptr.find("a")
            .click(function(){
                self.is.clicked = true;

                if( !self.is.toclick ){
                    self.is.toclick = true;
                    return false;
                }
            })
            .mousedown(function( event ){
                self._mousedown( event );
                return false;
            });

        this.events();
    };

    Draggable.prototype._mousedown = function( evt ){
        this.is.drag = true;
        this.is.clicked = false;
        this.is.mouseup = false;

        var _offset = this.ptr.offset();
        var coords = this._getPageCoords( evt );
        this.cx = coords.x - _offset.left;
        this.cy = coords.y - _offset.top;

        $.extend(this.d, {
            left: _offset.left,
            top: _offset.top,
            width: this.ptr.width(),
            height: this.ptr.height()
        });

        if( this.outer && this.outer.get(0) ){
            this.outer.css({ height: Math.max(this.outer.height(), $(document.body).height()), overflow: "hidden" });
        }

        this.onmousedown( evt );
    };

    Draggable.prototype._mousemove = function( evt ){
        this.is.toclick = false;
        var coords = this._getPageCoords( evt );
        this.onmousemove( evt, coords.x - this.cx, coords.y - this.cy );
    };

    Draggable.prototype._mouseup = function( evt ){
        var oThis = this;

        if( this.is.drag ){
            this.is.drag = false;

            if( this.outer && this.outer.get(0) ){

                if( $.browser.mozilla ){
                    this.outer.css({ overflow: "hidden" });
                } else {
                    this.outer.css({ overflow: "visible" });
                }

                if( $.browser.msie && $.browser.version == '6.0' ){
                    this.outer.css({ height: "100%" });
                } else {
                    this.outer.css({ height: "auto" });
                }
            }

            this.onmouseup( evt );
        }
    };

    window.Draggable = Draggable;

})( jQuery );
/**
 * jquery.dependClass - Attach class based on first class in list of current element
 *
 * Written by
 * Egor Khmelev (hmelyoff@gmail.com)
 *
 * Licensed under the MIT (MIT-LICENSE.txt).
 *
 * @author Egor Khmelev
 * @version 0.1.0-BETA ($Id$)
 *
 **/

(function($) {
    $.baseClass = function(obj){
        obj = $(obj);
        return obj.get(0).className.match(/([^ ]+)/)[1];
    };

    $.fn.addDependClass = function(className, delimiter){
        var options = {
            delimiter: delimiter ? delimiter : '-'
        }
        return this.each(function(){
            var baseClass = $.baseClass(this);
            if(baseClass)
                $(this).addClass(baseClass + options.delimiter + className);
        });
    };

    $.fn.removeDependClass = function(className, delimiter){
        var options = {
            delimiter: delimiter ? delimiter : '-'
        }
        return this.each(function(){
            var baseClass = $.baseClass(this);
            if(baseClass)
                $(this).removeClass(baseClass + options.delimiter + className);
        });
    };

    $.fn.toggleDependClass = function(className, delimiter){
        var options = {
            delimiter: delimiter ? delimiter : '-'
        }
        return this.each(function(){
            var baseClass = $.baseClass(this);
            if(baseClass)
                if($(this).is("." + baseClass + options.delimiter + className))
                    $(this).removeClass(baseClass + options.delimiter + className);
                else
                    $(this).addClass(baseClass + options.delimiter + className);
        });
    };

})(jQuery);
/**
 * Copyright 2010 Tim Down.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * jshashtable
 *
 * jshashtable is a JavaScript implementation of a hash table. It creates a single constructor function called Hashtable
 * in the global scope.
 *
 * Author: Tim Down <tim@timdown.co.uk>
 * Version: 2.1
 * Build date: 21 March 2010
 * Website: http://www.timdown.co.uk/jshashtable
 */

var Hashtable = (function() {
    var FUNCTION = "function";

    var arrayRemoveAt = (typeof Array.prototype.splice == FUNCTION) ?
        function(arr, idx) {
            arr.splice(idx, 1);
        } :

        function(arr, idx) {
            var itemsAfterDeleted, i, len;
            if (idx === arr.length - 1) {
                arr.length = idx;
            } else {
                itemsAfterDeleted = arr.slice(idx + 1);
                arr.length = idx;
                for (i = 0, len = itemsAfterDeleted.length; i < len; ++i) {
                    arr[idx + i] = itemsAfterDeleted[i];
                }
            }
        };

    function hashObject(obj) {
        var hashCode;
        if (typeof obj == "string") {
            return obj;
        } else if (typeof obj.hashCode == FUNCTION) {
            // Check the hashCode method really has returned a string
            hashCode = obj.hashCode();
            return (typeof hashCode == "string") ? hashCode : hashObject(hashCode);
        } else if (typeof obj.toString == FUNCTION) {
            return obj.toString();
        } else {
            try {
                return String(obj);
            } catch (ex) {
                // For host objects (such as ActiveObjects in IE) that have no toString() method and throw an error when
                // passed to String()
                return Object.prototype.toString.call(obj);
            }
        }
    }

    function equals_fixedValueHasEquals(fixedValue, variableValue) {
        return fixedValue.equals(variableValue);
    }

    function equals_fixedValueNoEquals(fixedValue, variableValue) {
        return (typeof variableValue.equals == FUNCTION) ?
            variableValue.equals(fixedValue) : (fixedValue === variableValue);
    }

    function createKeyValCheck(kvStr) {
        return function(kv) {
            if (kv === null) {
                throw new Error("null is not a valid " + kvStr);
            } else if (typeof kv == "undefined") {
                throw new Error(kvStr + " must not be undefined");
            }
        };
    }

    var checkKey = createKeyValCheck("key"), checkValue = createKeyValCheck("value");

    /*----------------------------------------------------------------------------------------------------------------*/

    function Bucket(hash, firstKey, firstValue, equalityFunction) {
        this[0] = hash;
        this.entries = [];
        this.addEntry(firstKey, firstValue);

        if (equalityFunction !== null) {
            this.getEqualityFunction = function() {
                return equalityFunction;
            };
        }
    }

    var EXISTENCE = 0, ENTRY = 1, ENTRY_INDEX_AND_VALUE = 2;

    function createBucketSearcher(mode) {
        return function(key) {
            var i = this.entries.length, entry, equals = this.getEqualityFunction(key);
            while (i--) {
                entry = this.entries[i];
                if ( equals(key, entry[0]) ) {
                    switch (mode) {
                        case EXISTENCE:
                            return true;
                        case ENTRY:
                            return entry;
                        case ENTRY_INDEX_AND_VALUE:
                            return [ i, entry[1] ];
                    }
                }
            }
            return false;
        };
    }

    function createBucketLister(entryProperty) {
        return function(aggregatedArr) {
            var startIndex = aggregatedArr.length;
            for (var i = 0, len = this.entries.length; i < len; ++i) {
                aggregatedArr[startIndex + i] = this.entries[i][entryProperty];
            }
        };
    }

    Bucket.prototype = {
        getEqualityFunction: function(searchValue) {
            return (typeof searchValue.equals == FUNCTION) ? equals_fixedValueHasEquals : equals_fixedValueNoEquals;
        },

        getEntryForKey: createBucketSearcher(ENTRY),

        getEntryAndIndexForKey: createBucketSearcher(ENTRY_INDEX_AND_VALUE),

        removeEntryForKey: function(key) {
            var result = this.getEntryAndIndexForKey(key);
            if (result) {
                arrayRemoveAt(this.entries, result[0]);
                return result[1];
            }
            return null;
        },

        addEntry: function(key, value) {
            this.entries[this.entries.length] = [key, value];
        },

        keys: createBucketLister(0),

        values: createBucketLister(1),

        getEntries: function(entries) {
            var startIndex = entries.length;
            for (var i = 0, len = this.entries.length; i < len; ++i) {
                // Clone the entry stored in the bucket before adding to array
                entries[startIndex + i] = this.entries[i].slice(0);
            }
        },

        containsKey: createBucketSearcher(EXISTENCE),

        containsValue: function(value) {
            var i = this.entries.length;
            while (i--) {
                if ( value === this.entries[i][1] ) {
                    return true;
                }
            }
            return false;
        }
    };

    /*----------------------------------------------------------------------------------------------------------------*/

    // Supporting functions for searching hashtable buckets

    function searchBuckets(buckets, hash) {
        var i = buckets.length, bucket;
        while (i--) {
            bucket = buckets[i];
            if (hash === bucket[0]) {
                return i;
            }
        }
        return null;
    }

    function getBucketForHash(bucketsByHash, hash) {
        var bucket = bucketsByHash[hash];

        // Check that this is a genuine bucket and not something inherited from the bucketsByHash's prototype
        return ( bucket && (bucket instanceof Bucket) ) ? bucket : null;
    }

    /*----------------------------------------------------------------------------------------------------------------*/

    function Hashtable(hashingFunctionParam, equalityFunctionParam) {
        var that = this;
        var buckets = [];
        var bucketsByHash = {};

        var hashingFunction = (typeof hashingFunctionParam == FUNCTION) ? hashingFunctionParam : hashObject;
        var equalityFunction = (typeof equalityFunctionParam == FUNCTION) ? equalityFunctionParam : null;

        this.put = function(key, value) {
            checkKey(key);
            checkValue(value);
            var hash = hashingFunction(key), bucket, bucketEntry, oldValue = null;

            // Check if a bucket exists for the bucket key
            bucket = getBucketForHash(bucketsByHash, hash);
            if (bucket) {
                // Check this bucket to see if it already contains this key
                bucketEntry = bucket.getEntryForKey(key);
                if (bucketEntry) {
                    // This bucket entry is the current mapping of key to value, so replace old value and we're done.
                    oldValue = bucketEntry[1];
                    bucketEntry[1] = value;
                } else {
                    // The bucket does not contain an entry for this key, so add one
                    bucket.addEntry(key, value);
                }
            } else {
                // No bucket exists for the key, so create one and put our key/value mapping in
                bucket = new Bucket(hash, key, value, equalityFunction);
                buckets[buckets.length] = bucket;
                bucketsByHash[hash] = bucket;
            }
            return oldValue;
        };

        this.get = function(key) {
            checkKey(key);

            var hash = hashingFunction(key);

            // Check if a bucket exists for the bucket key
            var bucket = getBucketForHash(bucketsByHash, hash);
            if (bucket) {
                // Check this bucket to see if it contains this key
                var bucketEntry = bucket.getEntryForKey(key);
                if (bucketEntry) {
                    // This bucket entry is the current mapping of key to value, so return the value.
                    return bucketEntry[1];
                }
            }
            return null;
        };

        this.containsKey = function(key) {
            checkKey(key);
            var bucketKey = hashingFunction(key);

            // Check if a bucket exists for the bucket key
            var bucket = getBucketForHash(bucketsByHash, bucketKey);

            return bucket ? bucket.containsKey(key) : false;
        };

        this.containsValue = function(value) {
            checkValue(value);
            var i = buckets.length;
            while (i--) {
                if (buckets[i].containsValue(value)) {
                    return true;
                }
            }
            return false;
        };

        this.clear = function() {
            buckets.length = 0;
            bucketsByHash = {};
        };

        this.isEmpty = function() {
            return !buckets.length;
        };

        var createBucketAggregator = function(bucketFuncName) {
            return function() {
                var aggregated = [], i = buckets.length;
                while (i--) {
                    buckets[i][bucketFuncName](aggregated);
                }
                return aggregated;
            };
        };

        this.keys = createBucketAggregator("keys");
        this.values = createBucketAggregator("values");
        this.entries = createBucketAggregator("getEntries");

        this.remove = function(key) {
            checkKey(key);

            var hash = hashingFunction(key), bucketIndex, oldValue = null;

            // Check if a bucket exists for the bucket key
            var bucket = getBucketForHash(bucketsByHash, hash);

            if (bucket) {
                // Remove entry from this bucket for this key
                oldValue = bucket.removeEntryForKey(key);
                if (oldValue !== null) {
                    // Entry was removed, so check if bucket is empty
                    if (!bucket.entries.length) {
                        // Bucket is empty, so remove it from the bucket collections
                        bucketIndex = searchBuckets(buckets, hash);
                        arrayRemoveAt(buckets, bucketIndex);
                        delete bucketsByHash[hash];
                    }
                }
            }
            return oldValue;
        };

        this.size = function() {
            var total = 0, i = buckets.length;
            while (i--) {
                total += buckets[i].entries.length;
            }
            return total;
        };

        this.each = function(callback) {
            var entries = that.entries(), i = entries.length, entry;
            while (i--) {
                entry = entries[i];
                callback(entry[0], entry[1]);
            }
        };

        this.putAll = function(hashtable, conflictCallback) {
            var entries = hashtable.entries();
            var entry, key, value, thisValue, i = entries.length;
            var hasConflictCallback = (typeof conflictCallback == FUNCTION);
            while (i--) {
                entry = entries[i];
                key = entry[0];
                value = entry[1];

                // Check for a conflict. The default behaviour is to overwrite the value for an existing key
                if ( hasConflictCallback && (thisValue = that.get(key)) ) {
                    value = conflictCallback(key, thisValue, value);
                }
                that.put(key, value);
            }
        };

        this.clone = function() {
            var clone = new Hashtable(hashingFunctionParam, equalityFunctionParam);
            clone.putAll(that);
            return clone;
        };
    }

    return Hashtable;
})();