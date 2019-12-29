var Mutex = function() {
    
    this._mutex = false;
    this.waiters = [];
    
    // Locks this mutex.
    this.lock = function() {
        this._mutex = true;
        return this._mutex;
    };
    
    // Releases the mutex and invokes all callbacks
    this.release = function() {
        this._mutex = false;
        this.waiters.forEach(function(w) {
            w();
        });
        this.waiters.length = 0;
    }
    
    // Queues the callback for execution until the mutex is released.
    this.waitFor = function(callback) {
        if (this._mutex) {
            this.waiters.push(callback);
        } else {
            callback();
        }
    };
};