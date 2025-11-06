import QtQuick 2.0
// AppPaths.qml — compatibility shim for Traktor Pro 4 bindings
// Centralizes dynamic AppProperty path creation so we only change here if NI renames things.
QtObject {
    // deckPath: returns the base path for a deck by number (1..4)
    function deckPath(deckId) {
        return "app.traktor.decks." + deckId;
    }
    function deckProp(deckId, prop) {
        return deckPath(deckId) + "." + prop;
    }
    function channelPath(channelId) {
        return "app.traktor.mixer.channels." + channelId;
    }
    function channelProp(channelId, prop) {
        return channelPath(channelId) + "." + prop;
    }
}
