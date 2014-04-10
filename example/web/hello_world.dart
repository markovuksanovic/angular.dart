import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@NgController(
    selector: '[hello-world-controller]',
    publishAs: 'ctrl')
class HelloWorldController {
  String name = "world";
}

class TestDirectiveBase {
  @NgOneWay('baseField')
  var baseField;
}

@NgDirective(selector: '[test]')
class TestDirective {
  @NgOneWay('field')
  var field;
  Element element;

  TestDirective(this.element) {
    element.onClick.listen((e) {
      //print(baseField);
      print(field);
    });
  }
}


main() {
  applicationFactory()
      .addModule(new Module()..type(HelloWorldController)..type(TestDirective))
      .run();
}
