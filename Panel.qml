import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import "I18n.js" as I18n

Panel {
  id: root
  moduleName: "io.github.jeffcortez23.omarchy-projector-cast"
  ipcTarget: "io.github.jeffcortez23.omarchy-projector-cast"
  manageIpc: true

  readonly property string scriptDir: Qt.resolvedUrl(".").toString().replace("file://", "") + "/bin"

  // Idioma (auto detectado del sistema o seleccionable)
  property string selectedLang: "auto"
  readonly property string activeLang: selectedLang === "auto" ? I18n.detectLang() : selectedLang

  function t(key) {
    return I18n.tr(key, root.activeLang)
  }

  // Estado del backend
  property bool gndInstalled: true
  property bool gndRunning: false
  property string primaryMonitor: "eDP-1"
  property string currentResolution: "1920x1080@60"
  property string currentScale: "1"
  property string nativeResolution: "1920x1080@60"
  property string nativeScale: "1"
  property bool p2pSupported: true
  property string p2pInterface: "wlp1s0"
  property var firewallState: ({ ufwActive: false, rtspAllowed: true, p2pAllowed: true, firewallOk: true })

  // Presets organizados por Relaciones de Aspecto y categorías (16:9, 16:10, 3:2, 21:9, 32:9, 4:3)
  readonly property var resolutionPresets: [
    // 16:9 Televisores y Monitores Estándar
    { label: "1080p", mode: "1920x1080@60", scale: "1", descKey: "res1080pDesc" },
    { label: "2K QHD", mode: "2560x1440@60", scale: "1.25", descKey: "res2kDesc" },
    { label: "4K UHD (2x)", mode: "3840x2160@60", scale: "2", descKey: "res4kDesc" },
    { label: "5K UHD (2x)", mode: "5120x2880@60", scale: "2", descKey: "res5kDesc" },
    { label: "720p HD", mode: "1280x720@60", scale: "1", descKey: "res720pDesc" },

    // 16:10 Proyectores Láser & Laptops OLED (Epson, WUXGA, Zenbook, ThinkPad)
    { label: "WXGA (Epson)", mode: "1280x800@60", scale: "1", descKey: "resWxgaDesc" },
    { label: "WUXGA (16:10)", mode: "1920x1200@60", scale: "1", descKey: "resWuxgaDesc" },
    { label: "2.8K OLED", mode: "2880x1800@60", scale: "1.5", descKey: "res28kDesc" },
    { label: "3.2K OLED", mode: "3200x2000@60", scale: "1.6", descKey: "res32kDesc" },
    { label: "WQXGA (2K)", mode: "2560x1600@60", scale: "1.25", descKey: "resWqxgaDesc" },

    // 3:2 Productividad (Surface / MateBook)
    { label: "3K (3:2)", mode: "3000x2000@60", scale: "1.5", descKey: "res3kDesc" },

    // 21:9 & 32:9 Monitores Ultrawide
    { label: "UW-FHD (21:9)", mode: "2560x1080@60", scale: "1", descKey: "resUwFhdDesc" },
    { label: "UW-QHD (21:9)", mode: "3440x1440@60", scale: "1.25", descKey: "resUwQhdDesc" },
    { label: "Super UW (32:9)", mode: "5120x1440@60", scale: "1.25", descKey: "resSuperUwDesc" },

    // 4:3 / 5:4 Clásicos
    { label: "XGA (4:3)", mode: "1024x768@60", scale: "1", descKey: "resXgaDesc" },
    { label: "SXGA (5:4)", mode: "1280x1024@60", scale: "1", descKey: "resSxgaDesc" }
  ]

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function launchGND() {
    actionProc.command = ["bash", "-c", root.scriptDir + "/omarchy-projector-helper launch"]
    if (!actionProc.running) actionProc.running = true
  }

  function stopGND() {
    actionProc.command = ["bash", "-c", root.scriptDir + "/omarchy-projector-helper stop"]
    if (!actionProc.running) actionProc.running = true
  }

  function setResolution(mode, scale) {
    actionProc.command = ["bash", "-c", root.scriptDir + "/omarchy-projector-helper set-res " + mode + " " + (scale || "1")]
    if (!actionProc.running) actionProc.running = true
  }

  function resetResolution() {
    actionProc.command = ["bash", "-c", root.scriptDir + "/omarchy-projector-helper reset-res"]
    if (!actionProc.running) actionProc.running = true
  }

  function fixFirewall() {
    actionProc.command = ["bash", "-c", root.scriptDir + "/omarchy-projector-helper copy-firewall-cmd"]
    if (!actionProc.running) actionProc.running = true
  }

  Component.onCompleted: root.refresh()
  onOpenedChanged: if (opened) root.refresh()

  Timer {
    interval: 2000
    running: root.opened || root.gndRunning
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: statusProc
    command: ["bash", "-c", root.scriptDir + "/omarchy-projector-helper status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var res = JSON.parse(String(text || "{}"))
          root.gndInstalled = res.gndInstalled !== undefined ? !!res.gndInstalled : true
          root.gndRunning = !!res.gndRunning
          root.primaryMonitor = res.primaryMonitor || "eDP-1"
          root.currentResolution = res.currentResolution || "1920x1080@60"
          root.currentScale = res.currentScale ? String(res.currentScale) : "1"
          root.nativeResolution = res.nativeResolution || "1920x1080@60"
          root.nativeScale = res.nativeScale ? String(res.nativeScale) : "1"
          root.p2pSupported = res.p2pSupported !== undefined ? !!res.p2pSupported : true
          root.p2pInterface = res.p2pInterface || "wlp1s0"
          if (res.firewall) root.firewallState = res.firewall
        } catch (e) {
          // Ignorar errores transitorios
        }
      }
    }
  }

  Process {
    id: actionProc
    stdout: StdioCollector { waitForEnd: true }
    onRunningChanged: if (!running) root.refresh()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Botón distintivo de Cast en la Barra Superior de Omarchy
  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.gndRunning ? "󰐻" : "󰡁"
    foreground: root.gndRunning ? Color.accent : (root.bar ? root.bar.foreground : Color.foreground)
    tooltipText: root.gndRunning ? root.t("tooltipCasting") : root.t("tooltipIdle")
    onPressed: function(b) { root.toggle() }
  }

  // Panel desplegable
  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    contentWidth: panel.fittedContentWidth(Style.space(490))
    contentHeight: panel.fittedContentHeight(panelColumn.implicitHeight)

    Column {
      id: panelColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      spacing: Style.space(12)

      // ---------- Hero / Encabezado ----------
      PanelHero {
        title: root.t("title")
        meta: root.t("meta")
        detail: root.gndRunning ? root.t("statusCasting") : root.t("statusReady")
        foreground: root.bar ? root.bar.foreground : Color.foreground
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        iconComponent: Component {
          Text {
            text: root.gndRunning ? "󰐻" : "󰡁"
            color: root.gndRunning ? Color.accent : (root.bar ? root.bar.foreground : Color.foreground)
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.display
          }
        }
        trailingControl: Component {
          Button {
            text: root.gndRunning ? root.t("btnStop") : root.t("btnMirror")
            iconText: root.gndRunning ? "󰓛" : "󰐻"
            bordered: true
            foreground: root.gndRunning ? Color.urgent : (root.bar ? root.bar.foreground : Color.foreground)
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
            onClicked: {
              if (root.gndRunning) {
                root.stopGND()
              } else {
                root.launchGND()
              }
            }
          }
        }
      }

      // Aviso si falta instalar GNOME Network Displays
      Rectangle {
        visible: !root.gndInstalled
        width: parent.width
        height: Style.space(42)
        radius: Style.radius(6)
        color: Qt.rgba(1, 0.3, 0.2, 0.15)
        border.color: Color.urgent

        Row {
          anchors.fill: parent
          anchors.margins: Style.space(8)
          spacing: Style.space(8)

          Text {
            text: "⚠️"
            font.pixelSize: Style.font.body
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: root.t("notInstalled")
            color: Color.urgent
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
            anchors.verticalCenter: parent.verticalCenter
          }
        }
      }

      PanelSeparator { foreground: root.bar ? root.bar.foreground : Color.foreground }

      // ---------- Sección 1: Transmitir / Duplicar ----------
      PanelSectionHeader {
        text: root.t("secStream")
        foreground: root.bar ? root.bar.foreground : Color.foreground
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
      }

      Button {
        width: parent.width
        text: root.gndRunning ? root.t("btnFocusGND") : root.t("btnSearchMirror")
        iconText: "󰤨"
        bordered: true
        selected: true
        foreground: root.bar ? root.bar.foreground : Color.foreground
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: root.launchGND()
      }

      PanelSeparator { foreground: root.bar ? root.bar.foreground : Color.foreground }

      // ---------- Sección 2: Ajustar Resolución & Relación de Aspecto ----------
      PanelSectionHeader {
        text: root.t("secResolution")
        foreground: root.bar ? root.bar.foreground : Color.foreground
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
      }

      Text {
        width: parent.width
        text: root.t("resIntro")
        color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.2)
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.caption
        wrapMode: Text.WordWrap
      }

      Flow {
        width: parent.width
        spacing: Style.space(6)

        Repeater {
          model: root.resolutionPresets
          Button {
            required property var modelData
            text: modelData.label
            tooltipText: root.t(modelData.descKey)
            bordered: true
            active: root.currentResolution.indexOf(modelData.mode.split("@")[0]) === 0
            foreground: (root.currentResolution.indexOf(modelData.mode.split("@")[0]) === 0) ? Color.accent : (root.bar ? root.bar.foreground : Color.foreground)
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
            fontSize: Style.font.caption
            onClicked: {
              root.setResolution(modelData.mode, modelData.scale)
            }
          }
        }
      }

      // Barra de estado de resolución actual y botón inteligente de restablecer nativa
      Row {
        spacing: Style.space(8)
        width: parent.width

        Text {
          text: root.t("currentMode") + ": " + root.currentResolution + " (" + root.t("scale") + " " + root.currentScale + "x)"
          color: Color.accent
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
          anchors.verticalCenter: parent.verticalCenter
        }

        Item { width: Style.space(8); height: 1 }

        Button {
          text: root.t("btnResetNative") + " (" + root.nativeResolution.split("@")[0] + " " + root.nativeScale + "x)"
          iconText: "󰁯"
          bordered: true
          foreground: root.bar ? root.bar.foreground : Color.foreground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          fontSize: Style.font.caption
          onClicked: root.resetResolution()
        }
      }

      PanelSeparator { foreground: root.bar ? root.bar.foreground : Color.foreground }

      // ---------- Sección 3: Diagnóstico & Red ----------
      PanelSectionHeader {
        text: root.t("secStatus")
        foreground: root.bar ? root.bar.foreground : Color.foreground
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
      }

      Row {
        spacing: Style.space(8)
        Text {
          text: "• " + root.t("p2pLabel") + ":"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }
        Text {
          text: root.p2pSupported ? root.t("supported") + " (" + root.p2pInterface + ") ✓" : root.t("notDetected") + " ✗"
          color: root.p2pSupported ? Color.accent : Color.urgent
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
        }
      }

      Row {
        spacing: Style.space(8)
        Text {
          text: "• " + root.t("firewallLabel") + ":"
          color: root.bar ? root.bar.foreground : Color.foreground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }
        Text {
          text: root.firewallState.firewallOk ? root.t("allowed") + " ✓" : root.t("blocked") + " ✗"
          color: root.firewallState.firewallOk ? Color.accent : Color.urgent
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
        }
      }

      Button {
        visible: !root.firewallState.firewallOk
        text: root.t("btnFixFirewall")
        iconText: "󰒃"
        bordered: true
        foreground: Color.urgent
        fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
        onClicked: root.fixFirewall()
      }

      PanelSeparator { foreground: root.bar ? root.bar.foreground : Color.foreground }

      // ---------- Sección 4: Selector de Idioma ----------
      Flow {
        width: parent.width
        spacing: Style.space(4)

        Repeater {
          model: [
            { code: "auto", label: "🌐 Auto" },
            { code: "es", label: "ES" },
            { code: "en", label: "EN" },
            { code: "pt", label: "PT" },
            { code: "fr", label: "FR" },
            { code: "de", label: "DE" },
            { code: "zh", label: "中文" },
            { code: "ja", label: "日本語" },
            { code: "ko", label: "한국어" }
          ]

          Button {
            required property var modelData
            text: modelData.label
            bordered: true
            active: root.selectedLang === modelData.code
            foreground: root.selectedLang === modelData.code ? Color.accent : (root.bar ? root.bar.foreground : Color.foreground)
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
            fontSize: Style.font.caption
            onClicked: root.selectedLang = modelData.code
          }
        }
      }

    }
  }
}
