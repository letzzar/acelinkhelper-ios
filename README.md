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

## Server Setup (Docker)

AcelinkHelper is designed to work with the AceStream engine running in **Docker** — typically on a home server, NAS, or any always-on machine on your network. The app on your iPhone or Apple TV simply connects to that address.

**Requires:** [Docker + Docker Compose](https://docs.docker.com/get-docker/) on the server machine.

---

### Option 1 — Direct (no VPN)

Save as `docker-compose.yml` on your server and run `docker compose up -d`:

```yaml
version: "3"
services:
  acelink:
    image: blaiseio/acelink
    container_name: acelink
    platform: linux/amd64
    ports:
      - 6878:6878   # AceStream engine port — AcelinkHelper connects here
    restart: always
```

In the app, set the engine address to `http://<server-ip>:6878`.

---

### Option 2 — Behind a WireGuard VPN (recommended)

All AceStream traffic is tunnelled through a VPN using [Gluetun](https://github.com/qdm12/gluetun). AceStream is invisible to your ISP.

```yaml
version: "3"
services:
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 6878:6878   # Port exposed on host — the app connects here
    environment:
      - VPN_SERVICE_PROVIDER=custom
      - VPN_TYPE=wireguard
      - WIREGUARD_PRIVATE_KEY=<your_private_key>      # From [Interface] PrivateKey
      - WIREGUARD_ADDRESSES=172.16.0.2/32             # From [Interface] Address
      - WIREGUARD_ENDPOINT_IP=162.159.192.1           # From [Peer] Endpoint (IP)
      - WIREGUARD_ENDPOINT_PORT=2408                  # From [Peer] Endpoint (port)
      - WIREGUARD_PUBLIC_KEY=<peer_public_key>        # From [Peer] PublicKey
      - TZ=Europe/Madrid
    restart: always

  acelink:
    image: blaiseio/acelink
    container_name: acelink
    platform: linux/amd64
    network_mode: "service:gluetun"   # AceLink hides behind Gluetun
    depends_on:
      - gluetun
    restart: always
```

#### How to get your WireGuard keys

**From a VPN provider** (Mullvad, ProtonVPN, IVPN, etc.):

1. Log in to your provider's dashboard and download a **WireGuard config file** (`.conf`)
2. Open it — it looks like this:

```ini
[Interface]
PrivateKey = ABC123...          ← WIREGUARD_PRIVATE_KEY
Address    = 172.16.0.2/32      ← WIREGUARD_ADDRESSES

[Peer]
PublicKey  = XYZ789...          ← WIREGUARD_PUBLIC_KEY
Endpoint   = 162.159.192.1:2408 ← IP → WIREGUARD_ENDPOINT_IP  /  port → WIREGUARD_ENDPOINT_PORT
```

**Generate your own keys** (self-hosted WireGuard server):

```bash
# Install wireguard-tools
sudo apt install wireguard-tools   # Ubuntu / Debian
brew install wireguard-tools       # macOS

# Generate private key
wg genkey > wg_private.key
cat wg_private.key            # → paste as WIREGUARD_PRIVATE_KEY

# Derive public key
cat wg_private.key | wg pubkey > wg_public.key
cat wg_public.key             # → register this on your WireGuard server
```

> **Security:** Never share your private key. Never generate WireGuard keys using online tools.

---

## Prerequisites

| Requirement | Notes |
|---|---|
| **Xcode 15+** | Download from the [Mac App Store](https://apps.apple.com/app/xcode/id497799835) |
| **Apple Developer account** | Free account works for personal device testing. Paid ($99/year) required for App Store distribution. Register at [developer.apple.com](https://developer.apple.com) |
| **VLC for Mobile** | Install [VLC](https://apps.apple.com/app/vlc-media-player/id650377962) on the target device |
| **AceStream engine** | Running in Docker on your network (see Server Setup above) |

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

## Características

- Gestiona URLs `acestream://` desde cualquier app vía Share Extension o esquema de URL
- Se conecta a un motor AceStream configurable (local o remoto)
- Convierte el hash en una URL de stream HTTP
- Lanza VLC para iOS/tvOS con la URL lista para reproducir

## Configuración del Servidor (Docker)

AcelinkHelper está diseñado para funcionar con el motor AceStream ejecutándose en **Docker** — normalmente en un servidor doméstico, NAS o cualquier máquina siempre encendida en tu red. La app en tu iPhone o Apple TV simplemente se conecta a esa dirección.

**Requisito:** [Docker + Docker Compose](https://docs.docker.com/get-docker/) en la máquina servidor.

---

### Opción 1 — Directo (sin VPN)

Guarda como `docker-compose.yml` en el servidor y ejecuta `docker compose up -d`:

```yaml
version: "3"
services:
  acelink:
    image: blaiseio/acelink
    container_name: acelink
    platform: linux/amd64
    ports:
      - 6878:6878   # Puerto del motor AceStream — al que se conecta la app
    restart: always
```

En la app, configura la dirección del motor a `http://<ip-del-servidor>:6878`.

---

### Opción 2 — Detrás de una VPN WireGuard (recomendado)

Todo el tráfico de AceStream se tuneliza a través de una VPN con [Gluetun](https://github.com/qdm12/gluetun). AceStream es invisible para tu ISP.

```yaml
version: "3"
services:
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 6878:6878   # Puerto expuesto en el host — la app se conecta aquí
    environment:
      - VPN_SERVICE_PROVIDER=custom
      - VPN_TYPE=wireguard
      - WIREGUARD_PRIVATE_KEY=<tu_clave_privada>      # De [Interface] PrivateKey
      - WIREGUARD_ADDRESSES=172.16.0.2/32             # De [Interface] Address
      - WIREGUARD_ENDPOINT_IP=162.159.192.1           # De [Peer] Endpoint (IP)
      - WIREGUARD_ENDPOINT_PORT=2408                  # De [Peer] Endpoint (puerto)
      - WIREGUARD_PUBLIC_KEY=<clave_publica_peer>     # De [Peer] PublicKey
      - TZ=Europe/Madrid
    restart: always

  acelink:
    image: blaiseio/acelink
    container_name: acelink
    platform: linux/amd64
    network_mode: "service:gluetun"   # AceLink se oculta tras Gluetun
    depends_on:
      - gluetun
    restart: always
```

#### Cómo obtener tus claves WireGuard

**Desde un proveedor de VPN** (Mullvad, ProtonVPN, IVPN, etc.):

1. Inicia sesión en el panel de tu proveedor y descarga un **archivo de configuración WireGuard** (`.conf`)
2. Ábrelo — tiene este aspecto:

```ini
[Interface]
PrivateKey = ABC123...           ← WIREGUARD_PRIVATE_KEY
Address    = 172.16.0.2/32       ← WIREGUARD_ADDRESSES

[Peer]
PublicKey  = XYZ789...           ← WIREGUARD_PUBLIC_KEY
Endpoint   = 162.159.192.1:2408  ← IP → WIREGUARD_ENDPOINT_IP  /  puerto → WIREGUARD_ENDPOINT_PORT
```

**Generar tus propias claves** (servidor WireGuard propio):

```bash
# Instalar wireguard-tools
sudo apt install wireguard-tools   # Ubuntu / Debian
brew install wireguard-tools       # macOS

# Generar clave privada
wg genkey > wg_private.key
cat wg_private.key            # → pega esto como WIREGUARD_PRIVATE_KEY

# Derivar clave pública
cat wg_private.key | wg pubkey > wg_public.key
cat wg_public.key             # → registra esto en tu servidor WireGuard
```

> **Seguridad:** Nunca compartas tu clave privada. Nunca generes claves WireGuard con herramientas online.

---

## Requisitos previos

| Requisito | Notas |
|---|---|
| **Xcode 15+** | Descarga desde la [Mac App Store](https://apps.apple.com/app/xcode/id497799835) |
| **Cuenta Apple Developer** | La cuenta gratuita funciona para pruebas en dispositivo propio. La de pago ($99/año) es necesaria para distribución en el App Store. Regístrate en [developer.apple.com](https://developer.apple.com) |
| **VLC para móvil** | Instala [VLC](https://apps.apple.com/app/vlc-media-player/id650377962) en el dispositivo destino |
| **Motor AceStream** | Ejecutándose en Docker en tu red (ver Configuración del Servidor arriba) |

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

**Esquema de URL directo:**
- Abre cualquier enlace `acestream://` — iOS lo enruta a AcelinkHelper automáticamente tras la configuración inicial

## Licencia

MIT © 2026 letzzar
