# AcelinkHelper iOS / tvOS

**English** | [Español](#español)

---

A native Swift app for iPhone, iPad, and Apple TV that intercepts `acestream://` URLs and opens the converted HTTP stream in VLC.

## Components

| Target | Platform | Description |
|---|---|---|
| **AcelinkHelper** | iOS / iPadOS | Main app |
| **AcelinkHelperTV** | tvOS | Apple TV version |
| **AcelinkHelperShare** | iOS Share Extension | Allows sharing acestream links from Safari or other apps |

## Features

- Handles `acestream://` URLs from any app via the Share Extension or URL scheme
- Connects to a configurable AceStream engine (local or remote)
- Converts the hash to an HTTP stream URL
- Launches VLC for iOS/tvOS with the ready-to-play URL

## Prerequisites

| Requirement | Notes |
|---|---|
| **Xcode 15+** | Download from the [Mac App Store](https://apps.apple.com/app/xcode/id497799835) |
| **Apple Developer account** | Free account works for personal device testing. Paid ($99/year) required for App Store distribution. Register at [developer.apple.com](https://developer.apple.com) |
| **VLC for Mobile** | Install [VLC](https://apps.apple.com/app/vlc-media-player/id650377962) on the target device |
| **AceStream engine** | Accessible on the local network (e.g. running [acestream-server](https://github.com/letzzar/acestream-server)) |

No API keys required.

## Build & Run

```bash
git clone https://github.com/letzzar/acelinkhelper-ios.git
cd acelinkhelper-ios
open AcelinkHelper/AcelinkHelper.xcodeproj
```

In Xcode:

1. Select the **AcelinkHelper** scheme (or AcelinkHelperTV for Apple TV)
2. Go to **Signing & Capabilities** tab for each target
3. Set your **Team** (select your Apple ID from the dropdown — Xcode creates a free provisioning profile automatically)
4. Select your connected device or a simulator
5. Press **⌘R** to build and run

> **Note:** The `project.pbxproj` has `DEVELOPMENT_TEAM = ""` intentionally. You must set your own Team in Xcode before building.

## Usage

**From Safari / any browser:**
1. Tap the Share button on a page containing an `acestream://` link
2. Select **AcelinkHelper** from the share sheet
3. VLC opens and starts playing

**Direct URL scheme:**
- Open any `acestream://` link — iOS routes it to AcelinkHelper automatically after initial setup

---

## Español

App nativa Swift para iPhone, iPad y Apple TV que intercepta URLs `acestream://` y abre el stream HTTP convertido en VLC.

## Componentes

| Target | Plataforma | Descripción |
|---|---|---|
| **AcelinkHelper** | iOS / iPadOS | App principal |
| **AcelinkHelperTV** | tvOS | Versión Apple TV |
| **AcelinkHelperShare** | Extensión Share iOS | Permite compartir enlaces acestream desde Safari u otras apps |

## Requisitos previos

| Requisito | Notas |
|---|---|
| **Xcode 15+** | Descarga desde la [Mac App Store](https://apps.apple.com/app/xcode/id497799835) |
| **Cuenta Apple Developer** | La cuenta gratuita funciona para pruebas en dispositivo propio. La de pago ($99/año) es necesaria para distribución en el App Store. Regístrate en [developer.apple.com](https://developer.apple.com) |
| **VLC para móvil** | Instala [VLC](https://apps.apple.com/app/vlc-media-player/id650377962) en el dispositivo destino |
| **Motor AceStream** | Accesible en la red local (p. ej. ejecutando [acestream-server](https://github.com/letzzar/acestream-server)) |

No se necesitan claves API.

## Compilar y ejecutar

```bash
git clone https://github.com/letzzar/acelinkhelper-ios.git
cd acelinkhelper-ios
open AcelinkHelper/AcelinkHelper.xcodeproj
```

En Xcode:

1. Selecciona el scheme **AcelinkHelper** (o AcelinkHelperTV para Apple TV)
2. Ve a la pestaña **Signing & Capabilities** de cada target
3. Establece tu **Team** (selecciona tu Apple ID en el desplegable — Xcode crea un perfil de aprovisionamiento gratuito automáticamente)
4. Selecciona tu dispositivo conectado o un simulador
5. Pulsa **⌘R** para compilar y ejecutar

> **Nota:** El `project.pbxproj` tiene `DEVELOPMENT_TEAM = ""` de forma intencionada. Debes establecer tu propio Team en Xcode antes de compilar.

## Uso

**Desde Safari / cualquier navegador:**
1. Toca el botón Compartir en una página con un enlace `acestream://`
2. Selecciona **AcelinkHelper** en la hoja de compartir
3. VLC se abre y comienza la reproducción

## Licencia

MIT © 2026 letzzar
