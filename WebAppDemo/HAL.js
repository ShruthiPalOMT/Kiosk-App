//
//
//
//
//  Created by Yilei He on 14/04/2016.
//  Copyright © 2016 Omnimarkettide.com. All rights reserved.
//

//HAL = Hardware Abstraction Layer
/*
 - message is the command that web app would like to send to device to trigger a task.
 - payload is a json object containing other information that is needed to execute the action.
 - callback is a function which is called after the task is completed.
 callback function will be passed in two parameters. The first one is the execution result, the second one is an error message.
 
 current supported message:
 "ScanBarcode"
 */

function HAL(jsHandlerName) {
    this.jsHandlerName = jsHandlerName;
    this.sendMessage = function(message, payload, callback) {
        if (window.webkit == undefined) {
            if (typeof callback === "function") {
                callback(null, "device not supported");
            }
            
            return;
        }
        var callbackString = undefined;
        if (typeof callback === "function") {
            callbackString = callback.toString();
        }
        window.webkit.messageHandlers[jsHandlerName].postMessage({
                                                                 "message": message,
                                                                 "payload": payload,
                                                                 "callback": callbackString
                                                                 });
    };
    
    this.eventHandlerMap = {};
    this.addEventListener = function(event, handler) {
        if (this.eventHandlerMap[event] == undefined) {
            this.eventHandlerMap[event] = new Set();
        }
        this.eventHandlerMap[event].add(handler);
    };
    
    this.triggerEvent = function(event) {
        var args = Array.prototype.slice.call(arguments, 1);
        if (this.eventHandlerMap[event]) {
            for (let item of this.eventHandlerMap[event]) {
                item.apply(null, args);
            }
        }
        
    };
}

var rc_hal = new HAL("swiftJSHandler");
