import 'package:test/test.dart';
import 'package:liner_serializer/liner_serializer.dart';

@Serializable()
class A {
  int a;
  String b;
}

@Serializable()
class B {
  @ManyToOne(A)
  A a;
}

@Serializable()
class C {
  @OneToMany(A)
  List<A> list = [];
}

@Serializable()
class D extends A {
  int c;
}

void main() {
  test("Check basic", () {
    var a = new A();
    a.a = 42;
    a.b = "test";

    var out = new Serializer().serialize(a);
    expect(out, equals({"a": 42, "b": "test"}));

    var a2 = new Serializer().deserialize(out, A);
    expect(a2.a, equals(a.a));
    expect(a2.b, equals(a.b));
  });

  test("Check subtype", () {
    var b = new B()..a = new A();
    b.a
      ..a = 42
      ..b = "test";

    var out = new Serializer().serialize(b);
    expect(
        out,
        equals({
          "a": {"a": 42, "b": "test"}
        }));

    var b2 = new Serializer().deserialize(out, B);
    expect(b2.a, isNotNull);
    expect(b2.a.a, equals(b.a.a));
    expect(b2.a.b, equals(b.a.b));
  });

  test("Check subtype list", () {
    var c = new C();

    c.list
      ..add(new A()
        ..a = 10
        ..b = "test1")
      ..add(new A()
        ..a = 11
        ..b = "test2");

    var out = new Serializer().serialize(c);
    expect(
        out,
        equals({
          "list": [
            {"a": 10, "b": "test1"},
            {"a": 11, "b": "test2"}
          ]
        }));

    var c2 = new Serializer().deserialize(out, C);
    expect(c2.list, isList);
    expect(c2.list.length, equals(c.list.length));
    for (int i = 0; i < c.list.length; i++) {
      expect(c2.list[i].a, equals(c.list[i].a));
      expect(c2.list[i].b, equals(c.list[i].b));
    }
  });

  test("Check extends", () {
    var d = new D()
      ..a = 42
      ..b = "test"
      ..c = 2;

    var out = new Serializer().serialize(d);
    expect(out, equals({"a": 42, "b": "test", "c": 2}));

    var d2 = new Serializer().deserialize(out, D);
    expect(d2.a, equals(d.a));
    expect(d2.b, equals(d.b));
    expect(d2.c, equals(d.c));
  });
}
