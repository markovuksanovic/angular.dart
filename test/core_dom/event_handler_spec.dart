library event_handler_spec;

import '../_specs.dart';

main() {
  describe('EventHandler', () {
    EventHandler eventHandler;
    Element root;


    beforeEach(() {
      root = document.createElement('div');
      document.body.append(root);
      var module = new Module()
                        ..value(Element, root)
                        ..type(NgApp)
                        ..type(EventHandler);
      Injector injector = new DynamicInjector(modules: [module]);

      eventHandler = injector.get(EventHandler);
    });

    it('should call function when registered event is triggered', () {
      Element el = document.createElement('p');
      var invoked = false;
      root.append(el);
      eventHandler.register('abc', (event) => invoked = true, [el]);
      Event e = new Event('abc');
      el.dispatchEvent(e);
      expect(invoked).toBe(true);
    });

    it('should not call function when registered event is triggered and handler'
        ' was unregistered.', () {
      Element el = document.createElement('p');
      var counter = 0;
      root.append(el);
      var registration = eventHandler.register('xyz',
          (event) => ++counter, [el]);
      Event e = new Event('xyz');
      el.dispatchEvent(e);
      eventHandler.unregister(registration);
      el.dispatchEvent(e);
      expect(counter).toBe(1);
    });

    it('should call function when registered event is triggered on child'
        ' node', () {
      Element el = document.createElement('p');
      Element child = document.createElement('p');
      el.append(child);
      var invoked = false;
      root.append(el);
      var registration = eventHandler.register('xyz',
          (event) => invoked = true, [el]);
      child.dispatchEvent(new Event('xyz'));
      expect(invoked).toBe(true);
    });

    it('should not call function when registered event is triggered on ancestor'
        ' node', () {
      Element el = document.createElement('p');
      var invoked = false;
      root.append(el);
      var registration = eventHandler.register('xyz',
          (event) => invoked = true, [el]);
      Event e = new Event('xyz');
      root.dispatchEvent(e);
      expect(invoked).toBe(false);
    });

    it('should call only function associated with event name and elements list',
        () {
      Element foo = document.createElement('p');
      Element bar = document.createElement('p');
      var fooInvoked = false;
      var barInvoked = false;
      root..append(foo)..append(bar);
      var fooRegistration = eventHandler.register('xyz',
          (event) => fooInvoked = true, [foo]);
      var barRegistration = eventHandler.register('xyz',
                (event) => barInvoked = true, [bar]);
      Event e = new Event('xyz');
      foo.dispatchEvent(e);
      expect(fooInvoked).toBe(true);
      expect(barInvoked).toBe(false);
    });


    // TODO(@marko) add more test to cover scenario where there are multiple
    // event and/or multiple nodes.
  });
}