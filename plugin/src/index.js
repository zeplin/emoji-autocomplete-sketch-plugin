var REPOSITORY_URL_STRING = "https://github.com/zeplin/emoji-autocomplete-sketch-plugin";

/**
 * Handles startup action.
 */
function onStartup(context) {
    if (!isFrameworkLoaded()) {
        var contentsPath = context.scriptPath.stringByDeletingLastPathComponent().stringByDeletingLastPathComponent();
        var resourcesPath = contentsPath.stringByAppendingPathComponent("Resources");

        var result = Mocha.sharedRuntime().loadFrameworkWithName_inDirectory("Autocomplete", resourcesPath);
        if (!result) {
            var alert = NSAlert.alloc().init();
            alert.alertStyle = NSAlertStyleCritical;
            alert.messageText = "Loading framework for “Emoji Autocomplete” failed"
            alert.informativeText = "Please try disabling and enabling the plugin or restarting Sketch. Contact support@zeplin.io, if the issue continues."

            alert.runModal();

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

/**
 * Handles about menu item.
 */
function onSelectAboutMenuItem(context) {
    var repositoryUrl = NSURL.URLWithString(REPOSITORY_URL_STRING);

    NSWorkspace.sharedWorkspace().openURL(repositoryUrl);
}
