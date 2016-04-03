part of liner_serializer;

class Serializer {
  var serializable = const Serializable();
  final Map<Type, ClassMirror> classes = <Type, ClassMirror>{};

  static final Serializer _singleton = new Serializer._internal();

  factory Serializer() {
    return _singleton;
  }

  Serializer._internal() {
    for (ClassMirror classMirror in serializable.annotatedClasses) {
      classes[classMirror.reflectedType] = classMirror;
    }
  }

  Iterable<MethodMirror> _getPublicFields(ClassMirror classMirror) {
    Map<String, MethodMirror> instanceMembers = classMirror.instanceMembers;
    return instanceMembers.values.where((MethodMirror method) {
      return method.isGetter &&
          method.isSynthetic &&
          instanceMembers[method.simpleName + '='] != null &&
          !method.isPrivate;
    });
  }

  List<String> _getPublicFieldNames(ClassMirror classMirror) =>
      _getPublicFields(classMirror).map((MethodMirror method) => method.simpleName).toList();

  dynamic serialize(Object o) {
    if (o is List) {
      return o.map(serialize).toList();
    } else if (o is String || o is num) {
      return o;
    } else if (o is Map) {
      return o;
    }
    Map result = {};
    InstanceMirror im = serializable.reflect(o);
    ClassMirror classMirror = im.type;
    for (String fieldName in _getPublicFieldNames(classMirror)) {
      result[fieldName] = serialize(im.invokeGetter(fieldName));
    }
    return result;
  }

  Object deserialize(dynamic m, Type type) {
    if (!classes.containsKey(type)) {
      return null;
    }

    ClassMirror classMirror = classes[type];
    Object instance = classMirror.newInstance("", []);
    InstanceMirror im = serializable.reflect(instance);
    for (MethodMirror method in _getPublicFields(classMirror)) {
      var name = method.simpleName;
      if (m.containsKey(name)) {
        bool notFound = true;
        classMirror.declarations[name]?.metadata?.forEach((obj) {
          if (obj is OneToMany) {
            var list = new List();
            for (var elem in m[name]) {
              list.add(deserialize(elem, obj.type));
            }
            im.invokeSetter(name, list);
            notFound = false;
          } else if (obj is ManyToOne) {
            im.invokeSetter(name, deserialize(m[name], obj.type));
            notFound = false;
          }
        });
        if (notFound) {
          im.invokeSetter(name, m[name]);
        }
      }
    }
    return instance;
  }
}
