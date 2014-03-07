import 'package:angular/angular.dart';

// This annotation allows Dart to shake away any classes
// not used from Dart code nor listed in another @MirrorsUsed.
//
// If you create classes that are referenced from the Angular
// expressions, you must include a library target in @MirrorsUsed.
@MirrorsUsed(override: '*')
import 'dart:mirrors';
import 'dart:html';

@NgController(
    selector: '[hello-world-controller]',
    publishAs: 'ctrl')
class HelloWorldController {

  HelloWorldController(Element element) {
    element.onClick.listen((MouseEvent e) {
      print('${e.type}: ${e.path}, ${e.target.outerHtml}');
    });
  }

  String name = "world";
}

@NgComponent(
    selector: 'my-component',
    template: '<button>component</button><content></content>',
    publishAs: 'ctrl')
class MyComponent {
}



main() {
  ngBootstrap(
      module: new Module()
        ..type(HelloWorldController)
        ..type(MyComponent)
  );
}
