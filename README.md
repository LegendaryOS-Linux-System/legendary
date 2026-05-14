# legendary — LegendaryOS CLI Tool

**Version:** 0.0.1  
**Language:** Ruby  
**Distro:** LegendaryOS (Fedora-based, immutable, bootc)

---

## Project Layout

```
legendary-tool/
├── main.rb                                   # Entry point
├── src/
│   ├── cli.rb                                # Command router + VERSION constant
│   ├── colors.rb                             # ANSI color palette (phoenix-inspired)
│   ├── banner.rb                             # ASCII banner + section helpers
│   ├── system_info.rb                        # System data readers
│   ├── toml_parser.rb                        # Minimal TOML parser
│   └── commands/
│       ├── status.rb                         # legendary status
│       ├── update.rb                         # legendary update → legendaryos-update
│       ├── doctor.rb                         # legendary doctor
│       ├── info.rb                           # legendary info
│       └── help.rb                           # legendary help
├── usr/
│   ├── bin/
│   │   ├── legendary                         # Wrapper → /usr/bin/legendary
│   │   ├── legendaryos                       # Wrapper → /usr/bin/legendaryos
│   │   └── legendaryos-update               # Standalone updater script
│   └── share/
│       └── LegendaryOS/
│           └── version.toml                  # OS version metadata
```

---

## Installation

```bash
# Skopiuj kod źródłowy narzędzia
sudo mkdir -p /usr/share/LegendaryOS/tools/legendary
sudo cp -r main.rb src/ /usr/share/LegendaryOS/tools/legendary/

# Skopiuj metadane wersji systemu
sudo mkdir -p /usr/share/LegendaryOS
sudo cp usr/share/LegendaryOS/version.toml /usr/share/LegendaryOS/version.toml

# Zainstaluj wrappery i updater
sudo install -m 0755 usr/bin/legendary          /usr/bin/legendary
sudo install -m 0755 usr/bin/legendaryos        /usr/bin/legendaryos
sudo install -m 0755 usr/bin/legendaryos-update /usr/bin/legendaryos-update
```

---

## Commands

| Command                          | Description                                         |
|----------------------------------|-----------------------------------------------------|
| `legendary status`               | Pełny status systemu (OS, Fedora, KCM, hardware)    |
| `legendary update`               | Aktualizacja wszystkiego (bootc + flatpak + firmware)|
| `legendary update --bootc`       | Tylko obraz systemu (bootc upgrade)                 |
| `legendary update --flatpak`     | Tylko aplikacje Flatpak                             |
| `legendary update --firmware`    | Tylko firmware (fwupd)                              |
| `legendary doctor`               | Diagnostyka systemu                                 |
| `legendary info`                 | Szybki przegląd wersji                              |
| `legendary help`                 | Pomoc                                               |
| `legendary version`              | Wersja narzędzia                                    |

---

## Tool Paths

| Plik systemowy                                | Rola                                   |
|-----------------------------------------------|----------------------------------------|
| `/usr/share/LegendaryOS/tools/legendary/`     | Kod źródłowy narzędzia                 |
| `/usr/bin/legendary`                          | Wrapper wywołujący main.rb             |
| `/usr/bin/legendaryos`                        | Alias wrappera z welcome screenem      |
| `/usr/bin/legendaryos-update`                 | Standalone updater (bootc/flatpak/fw)  |
| `/usr/share/LegendaryOS/version.toml`         | Metadane wersji LegendaryOS            |
| `/etc/xdg/kcm-about-distrorc`                 | KDE About This System                  |
| `/etc/os-release`                             | Standard Linux OS identity             |

---

## Update Flow

```
legendary update
      │
      ▼
  [root check]
      │
      ▼
  exec /usr/bin/legendaryos-update
      │
      ├── bootc upgrade          ← aktualizacja obrazu OCI
      ├── flatpak update         ← aplikacje użytkownika
      └── fwupdmgr update        ← firmware (LVFS)
```

---

## Color Palette

Inspirowana logo LegendaryOS — feniks w kolorach fioletu i błękitu:

- Deep Purple `#5f00ff`
- Royal Purple `#8700ff`
- Vivid Magenta `#d700ff`
- Pink Magenta `#ff00ff`
- Electric Blue `#5f5fff`
- Cobalt Blue `#005fff`
- Sky Cyan `#00ffff`

