/**
 * Handles startup action.
 */
function onStartup(context) {
    if (!isFrameworkLoaded()) {
        var path = context.scriptPath.stringByDeletingLastPathComponent();

        var result = Mocha.sharedRuntime().loadFrameworkWithName_inDirectory("Autocomplete", path);
        if (!result) {
            context.document.showMessage("Loading framework for “Emoji Autocomplete” failed.");

            return;
        }
    }

    ZPLAutocompletePluginController.sharedController().enabled = true;
}

/**
 * Handles shutdown action.
 */
function onShutdown(context) {
    if (isFrameworkLoaded()) {
        ZPLAutocompletePluginController.sharedController().enabled = false;
    }
}

function isFrameworkLoaded() {
    return Boolean(NSClassFromString("ZPLAutocompletePluginController"));
}
