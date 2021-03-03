//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <file_chooser/file_chooser_plugin.h>
#include <file_selector_windows/file_selector_plugin.h>
#include <printing/printing_plugin.h>
#include <url_launcher_windows/url_launcher_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileChooserPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileChooserPlugin"));
  FileSelectorPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorPlugin"));
  PrintingPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PrintingPlugin"));
  UrlLauncherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherPlugin"));
}
