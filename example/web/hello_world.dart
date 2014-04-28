import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

class Item
{
  String name, value;

  Item (this.name, this.value);
}

@Controller(
    selector: '[controller]',
    publishAs: 'ctrl')
class Test
{
  List<Item> items = [new Item ('Alice', 'one'), new Item ('Bob', 'two')];
  Item item;

  Scope scope;

  Test(Scope this.scope)
  {
    scope.watch('item', (newValue, _) {
      if (newValue != null) {
        print (newValue.value);
      }
    },
    context: this);
    scope.apply();
  }
}

class TestModule extends Module
{
  TestModule ()
  {
    type (Test);
  }
}

void main() {
  applicationFactory().addModule(new TestModule()).run();
}