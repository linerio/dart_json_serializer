part of liner_serializer;

class Serializable extends Reflectable {
  const Serializable()
      : super(instanceInvokeCapability, const NewInstanceCapability(r"^$"), metadataCapability, declarationsCapability);
}

class OneToMany {
  final Type type;

  const OneToMany(this.type);
}

class ManyToOne {
  final Type type;

  const ManyToOne(this.type);
}
