part of angular.core.dom;

typedef void EventFunction(event);

@NgInjectableService()
class EventHandler {
  Map<String, Map<List<dom.Node>, EventFunction>> _eventRegistry = {};
  Map<String, dom.EventListener> _eventToListener = {};
  dom.Node rootElement;

  EventHandler(NgApp ngApp) : rootElement = ngApp.root;
  EventHandler.fromNode(this.rootElement);

  _RegistrationHandle register(String eventName, EventFunction fn, List<dom.Node> elements) {
    // TODO: I don't think you need EventFunction. The function can be extracted from the DOM.
    _RegistrationHandle eventHandle = new _RegistrationHandle(eventName, elements);
    EventFunction eventListener = (dom.Event event) {
      if(elements.any((e) => e == event.target || e.contains(event.target))) {
        _eventRegistry[eventName][elements](event);
      }
    };

    _eventRegistry.putIfAbsent(eventName, () {
      rootElement.addEventListener(eventName, eventListener);
      _eventToListener[eventName] = eventListener;
      return {};
    });
    _eventRegistry[eventName].putIfAbsent(elements, () => fn);
    return eventHandle;
  }

  // TODO: do we need unregister? I don't think there are any benefits to removing events.
  void unregister(_RegistrationHandle registrationHandle) {
    _eventRegistry[registrationHandle.eventName].remove(registrationHandle.nodes);
    if (_eventRegistry[registrationHandle.eventName].isEmpty) {
      rootElement.removeEventListener(registrationHandle.eventName,
          _eventToListener[registrationHandle.eventName]);
      _eventRegistry.remove(registrationHandle.eventName);
    }
  }
}

class _RegistrationHandle {
  final List<dom.Node> nodes;
  String eventName;

  _RegistrationHandle(this.eventName, this.nodes);
}

class EventHandler2 {
  final dom.Element rootElement;
  final Expando expando;
  final Map<String, Function> listeners;
  final ExceptionHandler exceptionHandler;

  EventHandler2(this.rootElement, this.expando, this.exceptionHandler);

  void addListenerType(String name) {
    listeners.putIfAbsent(name, () {
      dom.EventListener eventListener = this.eventListener;
      rootElement.addEventListener(name, eventListener);
      return eventListener;
    });
  }

  eventListener(dom.Event event) {
    var attrName = 'on-$name';
    dom.Element element = event.target;
    while (element != null && element != rootElement) {
      var expression = element.attributes[attrName];
      if (expression != null) {
        try {
          getScope(element).eval(expression);
        } catch (e, s) {
          exceptionHandler(e, s);
        }
      }
      element = element.parent;
    }
  }

  Scope getScope(dom.Element element) {
    while (element != null && element != rootElement) {
      ElementProbe probe = expando[element];
      if (probe != null) {
        return probe.scope;
      }
      element = element.parent;
    }
    throw 'should never happen';
  }
}
