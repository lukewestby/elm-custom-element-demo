window.ElmCustomElement = (function () {

  function attributesToObject(attributes) {
    return Array.prototype.slice.call(attributes)
      .reduce(function (current, next) {
        current[next.name] = next.value;
        return current;
      }, {});
  }

  function register(tagName, elmModule) {
    var ElementProto = Object.create(HTMLElement.prototype);

    ElementProto.createdCallback = function createdCallback() {
      var self = this;
      self._attributesJson = attributesToObject(this.attributes);
      self._wrapper = document.createElement('div');
      self._elmApp = elmModule.embed(this._wrapper, { attributes: this._attributesJson });
      self._shadow = this.createShadowRoot();
      self._shadow.appendChild(this._wrapper);
      self._previousEventValues = {};
      self._elmApp.ports.events.subscribe(function (nextValues) {
        Object.keys(nextValues).forEach(function (key) {
          var nextValue = nextValues[key];
          if (self._previousEventValues[key] === nextValue) return;
          self._previousEventValues[key] = nextValue;
          var event = new CustomEvent(key, { detail: nextValue });
          self.dispatchEvent(event);
        });
      });
    };

    ElementProto.attachedCallback = function attachedCallback() {
      var self = this;
      self._attributesJson = attributesToObject(self.attributes);
      self._elmApp.ports.attributes.send(self._attributesJson);
    }

    ElementProto.attributeChangedCallback = function attributeChangedCallback() {
      var self = this;
      self._attributesJson = attributesToObject(self.attributes);
      self._elmApp.ports.attributes.send(self._attributesJson);
    };

    document.registerElement(tagName, {
      prototype: ElementProto,
    });
  }

  return {
    register,
  };
}());
