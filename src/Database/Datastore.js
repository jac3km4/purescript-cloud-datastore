var ds = require('@google-cloud/datastore');

exports._connect = function(options) {
    return new ds.Datastore(options);
}

exports._createQuery = function(client, kind) {
    return client.createQuery(kind);
}

exports._delete = function(client, key, cb) {
    return client.delete(key, cb);
}

exports._save = function(client, payload, cb) {
    return client.save(payload, cb);
}

exports._get = function(client, key, options, cb) {
    return client.get(key, options, cb);
}
