
exports._filter = function(property, operator, value, query) {
    return query.filter(property, operator, value);
}

exports._hasAncestor = function(key, query) {
    return query.hasAncestor(key);
}

exports._order = function(property, options, query) {
    return query.order(property, options);
}

exports._groupBy = function(properties, query) {
    return query.groupBy(properties);
}

exports._select = function(properties, query) {
    return query.select(properties);
}

exports._limit = function(limit, query) {
    return query.limit(limit);
}

exports._offset = function(offset, query) {
    return query.offset(offset);
}

exports._run = function(query, cb) {
    return query.run(cb);
}
