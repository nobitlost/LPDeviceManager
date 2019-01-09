// MIT License
//
// Copyright 2019 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.


/**
 * The device-side library for low-power device and task management 
 * 
 * NOTE: 1) the library can be instantiated only once, it should be treated as a singleton.
 * NOTE: 2) Required changes for ConnectionManager:
 *          2.1. Allow for named onConnect/onDisconnect handlers. CM would allow for multiple 
 *              handlers to registered/unregistered by handler names.    
 *          2.2. Make server.flush(flushTimeout); optional, i.e. flushTimeout == -1 means no flush.
 * NOTE: 3) imp.onidle should not be used along with the library (as there is a chance they will be overwritten)
 * 
 * @class
 */
class LPDeviceManager {

    /**
     * Initializes the library
     * @param {ConnectionManager} cm - an instance of ConnectionManager library
     * @param {table} config - configuration parameters:
     *          @tableEntry {boolean} POWER_SAVE - specifies whether the power save mode should be enabled
     */
    constructor(cm, config) {
        //
    }

    /**
     * Registers a callback to be executed on powered on (cold boot)
     */
    function onColdBoot(callback) {
        //
    }

    /**
     * Registers a callback to be executed on a software reset 
     * (eg. with imp.reset()) or an out-of-memory error occurred
     */
    function onReset(callback) {
        // 
    }

    /**
     * Registers a callback to be executed after "deep" sleep time expired
     * (set via imp.deepsleepfor() or server.sleepfor() calls).
     */
    function onTimer(callback) {
        //
    }
    
    /**
     * Registers a callback to be triggered on a wakeup pin.
     */
    function onInterrupt(callback) {
        //
    }
    
    /**
     * Adds an action to be called on idle. The imp should not go to sleep until there is a least one
     * item in the onIdle list.
     */
    function addOnIdle(callback) {
    }

    /**
     * Executes the action and go to deep sleep for the specified period of time.
     *
     * @param {Promise|Promise[]|function|function[]} actions - set of actions to be fulfilled before we go to sleep
     * @param {number} sleepTime - 
     */
    // TODO: needs a lot of good examples covering all the edge use cases
    function doAndSleepFor(actions, sleepTime, actionsTimeout = -1) {
        //
    }

    /**
     * Sleeps for the specified period of time
     */
    function sleepFor(sleepTime) {
        //
    }

    /**
     * Attempts to establish a connection between the imp and the server.
     */
    function connect() {
        // 
    }

    /**
     * Disconnects the imp from the server and turns the radio off
     */
    function disconnect() {
        //
    }

    /**
     * Registers a callback to be executed on successfull connection to the server
     */
    function onConnect(callback) {
        //
    }

    /**
     * Registers a callback to be executed on disconnect or an error occurred during connection attempt.
     */
    function onDisconnect(callback) {
        //
    }
}
