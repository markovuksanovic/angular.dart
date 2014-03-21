library foo;

import 'package:angular/angular.dart';

@NgComponent(selector: 'foo',
    publishAs: 'ctrl',
    templateUrl: 'packages/demo/component/foo.html',
    module: FooComponent.module)
    // Or one can use
    // module: CustomModule)
class FooComponent {
  final SomeType someType;
  final SomeType2 someType2;
  final SomeType3 someType3;

  static Module module() => new CustomModule();

  FooComponent(this.someType, this.someType2, this.someType3) {
    print(someType.i);
    print(someType2.i);
    print(someType3.i);
  }
}

class FooModule extends Module {
  FooModule() {
    type(FooComponent);
    install(new CustomModule());
  }
}

class CustomModule extends Module {
  CustomModule() {
    type(SomeType);
    factory(SomeType2, (_) => new SomeType2());
    type(SomeType3);
  }
}

class SomeType {
  int i = 1;
}

class SomeType2 {
  int i = 2;
}

class SomeType3 {
  SomeType someType;
  SomeType2 someType2;

  SomeType3(this.someType, this.someType2);

  int get i {
    return someType.i + someType2.i;
  }
}