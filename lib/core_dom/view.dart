part of angular.core.dom;

/**
* ElementWrapper is an interface for [View]s and [ViewPort]s. Its purpose is
* to allow treating [View] and [ViewPort] under same interface so that
* [View]s can be added after [ViewPort].
*/
abstract class ElementWrapper {
  List<dom.Node> elements;
  ElementWrapper next;
  ElementWrapper previous;
}

/**
 * A View is a fundamental building view of DOM. It is a chunk of DOM which
 * can not be structural changed. It can only have its attributes changed.
 * A View can have [ViewPort]s embedded in its DOM.  A [ViewPort] can
 * contain other [View]s and it is the only way in which DOM can be changed
 * structurally.
 *
 * A [View] is a collection of DOM nodes and [Directive]s for those nodes.
 *
 * A [View] is responsible for instantiating the [Directive]s and for
 * inserting / removing itself to/from DOM.
 *
 * A [View] can be created from [ViewFactory].
 *
 */
class View implements ElementWrapper {
  List<dom.Node> elements;
  ElementWrapper next;
  ElementWrapper previous;
  EventHandler2 eventHandler;
  List<_RegistrationHandle> eventRegistrations = [];

  Function onInsert;
  Function onRemove;
  Function onMove;

  List<dynamic> _directives = [];
  final NgAnimate _animate;

  View(this.elements, this.eventHandler, this._animate);

  void registerEvent(String eventName) {
    eventHandler.addListenerType(eventName);
  }

  View insertAfter(ElementWrapper previousView) {
    // Update Link List.
    next = previousView.next;
    if (next != null) {
      next.previous = this;
    }
    previous = previousView;
    previousView.next = this;

    // Update DOM
    List<dom.Node> previousElements = previousView.elements;
    dom.Node previousElement = previousElements[previousElements.length - 1];
    dom.Node insertBeforeElement = previousElement.nextNode;
    dom.Node parentElement = previousElement.parentNode;
    bool preventDefault = false;

    Function insertDomElements = () {
      _animate.insert(elements, parentElement, insertBefore: insertBeforeElement);
    };

    if (onInsert != null) {
      onInsert({
        "preventDefault": () {
          preventDefault = true;
          return insertDomElements;
        },
        "element": elements[0]
      });
    }

    if (!preventDefault) {
      insertDomElements();
    }
    return this;
  }

  View remove() {
    eventRegistrations.forEach((e) => eventHandler.unregister(e));
    bool preventDefault = false;

    Function removeDomElements = () {
      _animate.remove(elements);
    };

    if (onRemove != null) {
      onRemove({
        "preventDefault": () {
          preventDefault = true;
          removeDomElements();
          return this;
        },
        "element": elements[0]
      });
    }

    if (!preventDefault) {
      removeDomElements();
    }

    // Remove view from list
    if (previous != null && (previous.next = next) != null) {
      next.previous = previous;
    }
    next = previous = null;
    return this;
  }

  View moveAfter(ElementWrapper previousView) {
    var previousElements = previousView.elements,
        previousElement = previousElements[previousElements.length - 1],
        insertBeforeElement = previousElement.nextNode,
        parentElement = previousElement.parentNode;

    elements.forEach((el) => parentElement.insertBefore(el, insertBeforeElement));

    // Remove view from list
    previous.next = next;
    if (next != null) {
      next.previous = previous;
    }
    // Add view to list
    next = previousView.next;
    if (next != null) {
      next.previous = this;
    }
    previous = previousView;
    previousView.next = this;
    return this;
  }
}

/**
 * A ViewPort is an instance of a hole. ViewPorts designate where child
 * [View]s can be added in parent [View]. ViewPorts wrap a DOM element,
 * and act as references which allows more views to be added.
 */
class ViewPort extends ElementWrapper {
  List<dom.Node> elements;
  ElementWrapper previous;
  ElementWrapper next;

  ViewPort(this.elements);
}

