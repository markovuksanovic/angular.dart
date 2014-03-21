library foo;

import 'package:angular/angular.dart';

@NgComponent(selector: 'foo',
    publishAs: 'ctrl',
    templateUrl: 'packages/demo/component/foo.html')
class FooComponent {

}

class FooModule extends Module {
  FooModule() {
    type(FooComponent);
  }
}