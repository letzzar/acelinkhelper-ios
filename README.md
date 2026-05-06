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

## Requirements

- Xcode 15+
- iOS 16+ / tvOS 16+
- [VLC for Mobile](https://apps.apple.com/app/vlc-media-player/id650377962) installed on the device
- An AceStream engine accessible on the network

## Build

Open `AcelinkHelper.xcodeproj` in Xcode, select the desired scheme (AcelinkHelper, AcelinkHelperTV, or AcelinkHelperShare), and build.

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

## Características

- Gestiona URLs `acestream://` desde cualquier app vía Share Extension o esquema de URL
- Se conecta a un motor AceStream configurable (local o remoto)
- Convierte el hash en una URL de stream HTTP
- Lanza VLC para iOS/tvOS con la URL lista para reproducir

## Requisitos

- Xcode 15+
- iOS 16+ / tvOS 16+
- [VLC para móvil](https://apps.apple.com/app/vlc-media-player/id650377962) instalado en el dispositivo
- Un motor AceStream accesible en la red

## Compilar

Abre `AcelinkHelper.xcodeproj` en Xcode, selecciona el scheme deseado y compila.

## Licencia

MIT © 2026 letzzar
