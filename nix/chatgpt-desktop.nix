# ChatGPT Desktop (official OpenAI Linux preview build), packaged from the .deb.
# To update: download the new .deb, run `sha256sum` on it, and bump `version` + `sha256` below.
{ stdenv
, lib
, fetchurl
, dpkg
, gnutar
, autoPatchelfHook
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, gdk-pixbuf
, glib
, gtk3
, libdrm
, libnotify
, libusb1
, libxkbcommon
, mesa
, nspr
, nss
, openssl
, pango
, systemd
, tpm2-tss
, xorg
}:

stdenv.mkDerivation rec {
  pname = "chatgpt-desktop";
  version = "26.924.22138";

  src = fetchurl {
    # OpenAI's rolling "latest" URL; hash is pinned so bump it on updates.
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_arm64.deb";
    sha256 = "6570f078c5ea25461ce103b2e31fa7dd6c5e717136fa9237c701d22db62b5e3f";
  };

  nativeBuildInputs = [ dpkg gnutar autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libnotify
    libusb1
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    stdenv.cc.cc.lib
    systemd
    tpm2-tss
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* $out/
    runHook postInstall
  '';

  dontStrip = true;

  # Qt shims are optional dlopens (KDE file dialogs) and the serialport
  # android-arm64 prebuild is never loaded on Linux; safe to skip.
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "liblog.so"
    "libc++_shared.so"
  ];

  meta = {
    description = "ChatGPT desktop application by OpenAI";
    homepage = "https://openai.com/chatgpt/desktop/";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-linux" ];
  };
}
