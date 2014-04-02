library registry_spec;

import '../_specs.dart';
import 'package:angular/application_factory.dart';

main() {
  ddescribe('RegistryMap', () {
    it('should allow for multiple registry keys to be added', () {
      var module = new Module()
          ..type(MyMap)
          ..type(A1)
          ..type(A2);

      var injector = applicationFactory().addModule(module).createInjector();
      expect(() {
        injector.get(MyMap);
      }).not.toThrow();
    });

    it('should iterate over all types', () {
      var module = new Module()
          ..type(MyMap)
          ..type(A1);

      var injector = applicationFactory().addModule(module).createInjector();
      var keys = [];
      var types = [];
      var map = injector.get(MyMap);
      map.forEach((k, t) { keys.add(k); types.add(t); });
      expect(keys).toEqual([new MyAnnotation('A'), new MyAnnotation('B')]);
      expect(types).toEqual([A1, A1]);
    });

    it('should safely ignore typedefs', () {
      var module = new Module()
          ..type(MyMap)
          ..value(MyTypedef, (String _) => null);

      var injector = applicationFactory().addModule(module).createInjector();
      expect(() => injector.get(MyMap), isNot(throws));
    });

    it('should merge parameter map defined in annotation', () {
      var module = new Module()
        ..type(MyMap2)
        ..type(B2);

      var injector = dynamicApplication().addModule(module).createInjector();
      var keys = [];
      var types = [];
      var map = injector.get(MyMap2);
      map.forEach((k, t) { keys.add(k); types.add(t); });
      expect(keys).toEqual([new AnnotationWithMap(map: const { 'foo': 'bar', 'baz': 'cux'})]);
      expect(types).toEqual([B2]);
    });
  });
}

typedef void MyTypedef(String arg);

class MyMap extends AnnotationMap<MyAnnotation> {
  MyMap(Injector injector, MetadataExtractor metadataExtractor)
      : super(injector, metadataExtractor);
}

class MyMap2 extends AnnotationMap<AnnotationWithMap> {
  MyMap2(Injector injector, MetadataExtractor metadataExtractor)
  : super(injector, metadataExtractor);
}


class MyAnnotation {
  final String name;

  const MyAnnotation(String this.name);

  toString() => name;
  get hashCode => name.hashCode;
  operator==(other) => this.name == other.name;
}

@MyAnnotation('A') @MyAnnotation('B') class A1 {}
@MyAnnotation('A') class A2 {}

class AnnotationWithMap extends NgAnnotation {
  const AnnotationWithMap({map}):super(map: map);

  AnnotationWithMap cloneWithNewMap(newMap) {
    return new AnnotationWithMap(map: newMap);
  }
  String toString() {
    StringBuffer buffer = new StringBuffer("AnnotationWithMap: [");
    map.forEach((k, v) => buffer.write('${k}:${v} '));
    buffer.write("]");
    return buffer.toString();
  }
  operator==(other) => map.keys.every((k) => other.map.keys.contains(k));
}

@AnnotationWithMap(map: const { 'foo': 'bar'}) class B1 {}
@AnnotationWithMap(map: const { 'baz': 'cux'}) class B2 extends B1 {}
