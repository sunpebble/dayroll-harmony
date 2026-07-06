# Dayroll HarmonyOS

HarmonyOS build of Dayroll, using the shared Sunpebble ArkUI components in `packages/sunpebble_ui`.

## Build

```sh
cd apps/dayroll
/Applications/DevEco-Studio.app/Contents/tools/ohpm/bin/ohpm install
DEVECO_SDK_HOME=/path/to/openharmony/sdk hvigorw assembleApp --no-daemon
```
