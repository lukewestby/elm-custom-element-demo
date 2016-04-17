# Elm Custom Element Demo

Demonstrates an Elm application running inside of a W3C Custom Element. For
best results, use with a browser known to support the Custom Elements API. I
tested this in Chrome 49.

## How it works

The Elm application defines a `main` exposing a `Signal Html`, like a typical
start-app application. It also exposes a port named `attributes` which allows in
a `Json.Decode.Value` representing the current value of the custom element's
attributes. Lastly, it exposes a port named `events` which maps values onto
event names. Every time a new value is detected on one of the record fields in
`events`, a custom DOM event is triggered with the name of the field and the
associated value is placed on `event.detail`.

Check out `src/Main.elm` and `index.html` to see related app code, and see
`elm-custom-element.js` for the wire-up Custom Element code that comprises
`ElmCustomElement.register()`.
