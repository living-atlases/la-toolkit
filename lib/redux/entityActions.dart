// Based in:
// https://github.com/careapp-inc/dart_redux_entity/blob/master/lib/src/remote_entity_actions.dart

// Crud
class RequestCreateOne<T> {
  const RequestCreateOne(this.entity);
  final T entity;
  Map<String, dynamic> toJson() => {
        'entity': entity,
      };
}

class SuccessCreateOne<T> {
  const SuccessCreateOne(this.entity);
  final T entity;
  Map<String, dynamic> toJson() => {
        'entity': entity,
      };
}

class FailCreateOne<T> {
  const FailCreateOne({this.entity, this.error});
  final T? entity;
  final dynamic error;
  Map<String, dynamic> toJson() => {'entity': entity, 'error': error};
}

class RequestCreateMany<T> {
  const RequestCreateMany(this.entities);
  final List<T> entities;
  Map<String, dynamic> toJson() => {
        'entites': entities,
      };
}

class SuccessCreateMany<T> {
  const SuccessCreateMany(this.entities);
  final List<T> entities;
  Map<String, dynamic> toJson() => {
        'entites': entities,
      };
}

class FailCreateMany<T> {
  const FailCreateMany({required this.entities, this.error});
  final List<T> entities;
  final dynamic error;
  Map<String, dynamic> toJson() => {'entites': entities, 'error': error};
}

// cRud
class RequestRetrieveOne<T> {
  const RequestRetrieveOne(this.id, {this.forceRefresh = false});

  /// The ID of the entity to fetch
  final String id;

  /// Whether to force a refresh (if you are using a caching mechanism)
  final bool forceRefresh;

  Map<String, dynamic> toJson() => {
        'id': id,
        'forceRefresh': forceRefresh,
      };
}

class SuccessRetrieveOne<T> {
  const SuccessRetrieveOne(this.entity);
  final T entity;
  Map<String, dynamic> toJson() => {
        'entity': entity,
      };
}

/// A recent copy of the entity was already in the store
/// so returning with the cached copy
class SuccessRetrieveOneFromCache<T> {
  const SuccessRetrieveOneFromCache(this.entity);
  final T entity;
  Map<String, dynamic> toJson() => {
        'entity': entity,
      };
}

class FailRetrieveOne<T> {
  const FailRetrieveOne({
    required this.id,
    this.error,
  });
  final String id;
  final dynamic error;
  Map<String, dynamic> toJson() => {'id': id, 'error': error};
}

class RequestRetrieveMany<T> {
  const RequestRetrieveMany(this.ids);
  final List<String> ids;
  Map<String, dynamic> toJson() => {
        'ids': ids,
      };
}

class SuccessRetrieveMany<T> {
  const SuccessRetrieveMany(this.entities);
  final List<T> entities;
  Map<String, dynamic> toJson() => {
        'entities': entities,
      };
}

class FailRetrieveMany<T> {
  const FailRetrieveMany(this.ids, this.error);
  final List<String> ids;
  final dynamic error;
  Map<String, dynamic> toJson() => {'ids': ids, 'error': error};
}

class RequestRetrieveAll<T> {
  const RequestRetrieveAll({
    this.forceRefresh = false,
  });

  /// Whether to force a refresh (if you are using a caching mechanism)
  final bool forceRefresh;

  Map<String, dynamic> toJson() => {
        'forceRefresh': forceRefresh,
      };
}

class SuccessRetrieveAll<T> {
  const SuccessRetrieveAll(this.entities);
  final List<T> entities;
  Map<String, dynamic> toJson() => {
        'entities': entities,
      };
}

/// A recent copy of the entity was already in the store
/// so returning with the cached copy
class SuccessRetrieveAllFromCache<T> {
  const SuccessRetrieveAllFromCache(this.entities);
  final List<T> entities;
  Map<String, dynamic> toJson() => {
        'entities': entities,
      };
}

class FailRetrieveAll<T> {
  const FailRetrieveAll(this.error);
  final dynamic error;
  Map<String, dynamic> toJson() => {
        'error': error,
      };
}

// crUd
class RequestUpdateOne<T> {
  const RequestUpdateOne(this.entity);
  final T entity;
  Map<String, dynamic> toJson() => {
        'entity': entity,
      };
}

class RequestUpdateOneProps<T> {
  const RequestUpdateOneProps(this.id, this.props);
  final String id;
  final Map<String, dynamic> props;

  Map<String, dynamic> toJson() => props;
}

class SuccessUpdateOne<T> {
  const SuccessUpdateOne(this.entity);
  final T entity;
  Map<String, dynamic> toJson() => {
        'entity': entity,
      };
}

class FailUpdateOne<T> {
  const FailUpdateOne({required this.entity, this.error});
  final T entity;
  final dynamic error;
  Map<String, dynamic> toJson() => {'entity': entity, 'error': error};
}

class RequestUpdateMany<T> {
  const RequestUpdateMany(this.entities);
  final List<T> entities;
  Map<String, dynamic> toJson() => {
        'entities': entities,
      };
}

class SuccessUpdateMany<T> {
  const SuccessUpdateMany(this.entities);
  final List<T> entities;
  Map<String, dynamic> toJson() => {
        'entities': entities,
      };
}

class FailUpdateMany<T> {
  const FailUpdateMany({required this.entities, this.error});
  final List<T> entities;
  final dynamic error;
  Map<String, dynamic> toJson() => {'entities': entities, 'error': error};
}

// cruD

class RequestDeleteOne<T> {
  const RequestDeleteOne(this.id);
  final String id;
  Map<String, dynamic> toJson() => {
        'id': id,
      };
}

class SuccessDeleteOne<T> {
  const SuccessDeleteOne(this.id);
  final String id;
  Map<String, dynamic> toJson() => {
        'id': id,
      };
}

class FailDeleteOne<T> {
  const FailDeleteOne({required this.id, this.error});
  final String id;
  final dynamic error;
  Map<String, dynamic> toJson() => {'id': id, 'error': error};
}

class RequestDeleteMany<T> {
  const RequestDeleteMany(this.ids);
  final List<String> ids;
  Map<String, dynamic> toJson() => {
        'ids': ids,
      };
}

class SuccessDeleteMany<T> {
  const SuccessDeleteMany(this.ids);
  final List<String> ids;
  Map<String, dynamic> toJson() => {
        'ids': ids,
      };
}

class FailDeleteMany<T> {
  const FailDeleteMany({required this.ids, this.error});
  final List<String> ids;
  final dynamic error;
  Map<String, dynamic> toJson() => {
        'ids': ids,
        'error': error,
      };
}
