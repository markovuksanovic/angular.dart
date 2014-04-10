import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@NgController(
    selector: '[hello-world-controller]',
    publishAs: 'ctrl')
class HelloWorldController {
  String name = "world";
}

@NgDirective(selector: '[test]')
class TestDirectiveBase {
  @NgAttr('baseField')
  var baseField;
}

@NgDirective(selector: '[test]')
class TestDirective extends TestDirectiveBase {
  @NgAttr('field')
  var field;
  Element element;

  TestDirective(this.element) {
    element.onClick.listen((e) {
      print(this.baseField);
      print(this.field);
    });
  }
}


main() {
  applicationFactory()
      .addModule(new Module()..type(HelloWorldController)..type(TestDirective))
      .run();
}
