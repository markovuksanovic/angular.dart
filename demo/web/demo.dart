import 'package:angular/angular.dart';
import 'package:demo/component/foo.dart';

main() => ngBootstrap(module: new MainModule());

class MainModule extends Module {
  MainModule() {
    install(new FooModule());
  }
}