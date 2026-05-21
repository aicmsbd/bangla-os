#!/bin/bash
# Phase 1.7: Windows-style XFCE look and shortcuts
set -euo pipefail
source "$(dirname "$0")/00-common.sh"
require_root

log "Phase 1.7 — Windows-style desktop"

apt_install arc-theme papirus-icon-theme breeze-cursor-theme xfce4-whiskermenu-plugin

apply_xfce_config() {
    local USER_HOME="$1"
    local XFCE_CONF="$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

    mkdir -p "$XFCE_CONF"

    # Panel at bottom, 36px, whisker menu
    cat > "$XFCE_CONF/xfce4-panel.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="size" type="uint" value="36"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu"/>
    <property name="plugin-2" type="string" value="showdesktop"/>
    <property name="plugin-3" type="string" value="tasklist"/>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="pulseaudio"/>
    <property name="plugin-6" type="string" value="networkmanager"/>
    <property name="plugin-7" type="string" value="clock"/>
  </property>
</channel>
EOF

    cat > "$XFCE_CONF/xsettings.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Arc-Dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
    <property name="CursorThemeName" type="string" value="Breeze"/>
  </property>
</channel>
EOF

    # Windows-like keyboard shortcuts
    mkdir -p "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
    cat > "$XFCE_CONF/xfce4-keyboard-shortcuts.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="default" type="empty">
      <property name="Super_L" type="string" value="xfce4-popup-whiskermenu"/>
      <property name="Super+e" type="string" value="thunar"/>
      <property name="Super+d" type="string" value="xfce4-show-desktop"/>
      <property name="Super+l" type="string" value="xflock4"/>
      <property name="Print" type="string" value="xfce4-screenshooter"/>
    </property>
  </property>
</channel>
EOF
}

apply_xfce_config /etc/skel
if id banglaos &>/dev/null; then
    apply_xfce_config /home/banglaos
    chown -R banglaos:banglaos /home/banglaos/.config
fi

log "Windows-style theme applied. Re-login to see changes."
