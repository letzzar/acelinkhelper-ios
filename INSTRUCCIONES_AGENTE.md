# Instrucciones para agente — Reparar proyecto AcelinkHelper iOS

## Contexto

El proyecto Xcode en `/Volumes/Software/Mi software/acelinkhelper-ios/AcelinkHelper/` tiene el código fuente completo pero el archivo `project.pbxproj` está roto: **no tiene targets, no tiene build phases, y no tiene referencia a Assets.xcassets**. Hay que reescribirlo completo.

El usuario debe cerrar Xcode antes de ejecutar estas instrucciones.

---

## Estado actual del filesystem (correcto)

```
AcelinkHelper/
  AcelinkHelper.xcodeproj/
    project.pbxproj              ← ROTO, hay que reescribir
  AcelinkHelper/                 ← source files del target principal
    AcelinkHelperApp.swift
    AppState.swift
    ContentView.swift
    StreamHandler.swift
    StreamServer.swift
    VLCLauncher.swift
    Info.plist
    Assets.xcassets/
      AccentColor.colorset/Contents.json
      AppIcon.appiconset/Contents.json
      Contents.json
  AcelinkHelperShare/            ← source files de la Share Extension (target por crear)
    ShareViewController.swift
    Info.plist
```

---

## Paso 1 — Reescribir project.pbxproj

Reemplaza el contenido completo de:
`/Volumes/Software/Mi software/acelinkhelper-ios/AcelinkHelper/AcelinkHelper.xcodeproj/project.pbxproj`

Con este contenido (formato Xcode 16, objectVersion 77, PBXFileSystemSynchronizedRootGroup):

```
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 77;
	objects = {

/* Begin PBXFileReference section */
		9E323CA02FA5750000634E1F /* AcelinkHelper.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = AcelinkHelper.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFileSystemSynchronizedRootGroup section */
		9E323CA12FA5750100634E1F /* AcelinkHelper */ = {
			isa = PBXFileSystemSynchronizedRootGroup;
			path = AcelinkHelper;
			sourceTree = "<group>";
		};
/* End PBXFileSystemSynchronizedRootGroup section */

/* Begin PBXFrameworksBuildPhase section */
		9E323CA52FA5750500634E1F /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		9E323CA22FA5750200634E1F = {
			isa = PBXGroup;
			children = (
				9E323CA12FA5750100634E1F /* AcelinkHelper */,
			);
			sourceTree = "<group>";
		};
		9E323CA32FA5750300634E1F /* Products */ = {
			isa = PBXGroup;
			children = (
				9E323CA02FA5750000634E1F /* AcelinkHelper.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		9E323CA72FA5750700634E1F /* AcelinkHelper */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 9E323CAC2FA5750C00634E1F /* Build configuration list for PBXNativeTarget "AcelinkHelper" */;
			buildPhases = (
				9E323CA42FA5750400634E1F /* Sources */,
				9E323CA52FA5750500634E1F /* Frameworks */,
				9E323CA62FA5750600634E1F /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			fileSystemSynchronizedGroups = (
				9E323CA12FA5750100634E1F /* AcelinkHelper */,
			);
			name = AcelinkHelper;
			packageProductDependencies = (
			);
			productName = AcelinkHelper;
			productReference = 9E323CA02FA5750000634E1F /* AcelinkHelper.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		9E323CAE2FA5750E00634E1F /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 2640;
				LastUpgradeCheck = 2640;
				TargetAttributes = {
					9E323CA72FA5750700634E1F = {
						CreatedOnToolsVersion = 16.4;
					};
				};
			};
			buildConfigurationList = 9E323CAD2FA5750D00634E1F /* Build configuration list for PBXProject "AcelinkHelper" */;
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 9E323CA22FA5750200634E1F;
			minimizedProjectReferenceProxies = 1;
			preferredProjectObjectVersion = 77;
			productRefGroup = 9E323CA32FA5750300634E1F /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				9E323CA72FA5750700634E1F /* AcelinkHelper */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		9E323CA62FA5750600634E1F /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		9E323CA42FA5750400634E1F /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		9E323CA82FA5750800634E1F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = AcelinkHelper/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.acelinkhelper.ios;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		9E323CA92FA5750900634E1F /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = AcelinkHelper/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.acelinkhelper.ios;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
		9E323CAA2FA5750A00634E1F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		9E323CAB2FA5750B00634E1F /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		9E323CAC2FA5750C00634E1F /* Build configuration list for PBXNativeTarget "AcelinkHelper" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				9E323CA82FA5750800634E1F /* Debug */,
				9E323CA92FA5750900634E1F /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		9E323CAD2FA5750D00634E1F /* Build configuration list for PBXProject "AcelinkHelper" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				9E323CAA2FA5750A00634E1F /* Debug */,
				9E323CAB2FA5750B00634E1F /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 9E323CAE2FA5750E00634E1F /* Project object */;
}
```

### Notas sobre el pbxproj

- Usa `PBXFileSystemSynchronizedRootGroup` (formato Xcode 16) — los archivos .swift y Assets.xcassets dentro de `AcelinkHelper/` se detectan automáticamente
- Build phases (Sources, Resources, Frameworks) están vacías porque el sync se encarga
- `GENERATE_INFOPLIST_FILE = NO` + `INFOPLIST_FILE = AcelinkHelper/Info.plist` para usar nuestro Info.plist personalizado
- `IPHONEOS_DEPLOYMENT_TARGET = 16.0`
- `PRODUCT_BUNDLE_IDENTIFIER = com.acelinkhelper.ios`
- `SWIFT_VERSION = 5.0`

---

## Paso 2 — Configuración manual en Xcode (después de reabrir)

Tras reescribir el pbxproj y abrir Xcode, hay que hacer estas configuraciones que no se pueden hacer desde el pbxproj:

### 2a. App Group capability (target principal)
1. Click en el proyecto (icono azul) → target **AcelinkHelper** → pestaña **Signing & Capabilities**
2. Click **+ Capability** → busca **App Groups** → doble click
3. En la sección App Groups, click **+**
4. Escribe exactamente: `group.com.acelinkhelper.ios` → OK

### 2b. Crear el target Share Extension
1. **File → New → Target**
2. Selecciona **iOS → Share Extension → Next**
3. Product Name: `AcelinkHelperShare`
4. Bundle Identifier: `com.acelinkhelper.ios.share`
5. Click **Finish**
6. Si aparece "Activate scheme?" → click **Cancel**

### 2c. Reemplazar archivos de la extensión
Xcode habrá creado boilerplate en una nueva carpeta. En Terminal:
```bash
cd "/Volumes/Software/Mi software/acelinkhelper-ios/AcelinkHelper"

# Ver qué carpeta creó Xcode para la extensión (puede ser AcelinkHelperShare duplicada)
ls -la

# Si Xcode creó una carpeta nueva con boilerplate, borrar su contenido y copiar nuestros archivos:
# rm NuevaCarpeta/ShareViewController.swift
# rm NuevaCarpeta/Info.plist
# cp AcelinkHelperShare/ShareViewController.swift NuevaCarpeta/
# cp AcelinkHelperShare/Info.plist NuevaCarpeta/
```

### 2d. StreamHandler en ambos targets
1. En el Project Navigator, click sobre **StreamHandler.swift**
2. En el panel derecho (File Inspector), sección **Target Membership**
3. Activa la casilla **AcelinkHelperShare** (además de AcelinkHelper que ya está)

### 2e. Info.plist de la extensión
1. Target **AcelinkHelperShare** → **Build Settings** → activar **All**
2. `Generate Info.plist File` → **No**
3. `Info.plist File` → ruta al Info.plist de la extensión

### 2f. App Group en la extensión
1. Target **AcelinkHelperShare** → **Signing & Capabilities**
2. **+ Capability** → **App Groups**
3. Activa `group.com.acelinkhelper.ios`

### 2g. Deployment target de la extensión
Target **AcelinkHelperShare** → **General** → Minimum Deployments → **iOS 16.0**

---

## Paso 3 — Compilar (Cmd+B)

Si todo está correcto, el target principal debe compilar sin errores. La Share Extension puede necesitar ajustes menores según la estructura que Xcode genere.

---

## Constantes del proyecto

| Clave | Valor |
|---|---|
| App Group ID | `group.com.acelinkhelper.ios` |
| Bundle ID app | `com.acelinkhelper.ios` |
| Bundle ID extensión | `com.acelinkhelper.ios.share` |
| Puerto HTTP server | 8765 |
| Puerto AceStream NAS | 6878 |
| Esquema URL propio | `acestream://` |
| Esquema VLC | `vlc://` |
| Deployment target | iOS 16.0 |
