library foo;

import 'package:angular/angular.dart';

@NgComponent(selector: 'foo',
    publishAs: 'ctrl',
    templateUrl: 'packages/demo/component/foo.html',
    module: CustomModule)
class FooComponent {
  final SomeType someType;
  final SomeType2 someType2;

  FooComponent(this.someType, this.someType2) {
    print(someType.i);
    print(someType2.i);
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
  }
}

class SomeType {
  int i = 1;
}

class SomeType2 {
  int i = 2;
}