import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: window
    visible: true
    width: 1200
    height: 900
    title: "Qt6 QML GUI Elements Demo"
    
    // Hintergrundfarbe zartrot
    color: "#FFF0F0"

    // Auth State
    property string authToken: ""
    property string authUser: ""
    property bool isLoggedIn: authToken !== ""

    // State für Tab-Navigation
    property int currentTab: 0

    // Output-Text für alle Interaktionen
    property string outputText: qsTr("Bitte anmelden...")
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // ===== HEADER =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#E57373" }
                GradientStop { position: 1.0; color: "#C62828" }
            }
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5
                
                Text {
                    text: "Qt6 QML GUI Elements Showcase"
                    font.pixelSize: 28
                    font.bold: true
                    color: "white"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "WebAssembly • PostgreSQL Backend • NGINX"
                    font.pixelSize: 14
                    color: "#FFCDD2"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
        
        // ===== TAB BAR =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "white"
            border.color: "#e0e0e0"
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                spacing: 0
                
                Repeater {
                    model: ["Basics", "Input", "Selection", "Display", "Database", "Produkte"]
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: currentTab === index ? "#C62828" : (tabMouseArea.containsMouse ? "#FFEBEE" : "white")
                        border.color: "#e0e0e0"
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 16
                            font.bold: currentTab === index
                            color: currentTab === index ? "white" : "#333"
                        }
                        
                        MouseArea {
                            id: tabMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: currentTab = index
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
        
        // ===== CONTENT AREA =====
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFF5F5"
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 20
                clip: true
                
                StackLayout {
                    width: parent.width
                    currentIndex: currentTab
                    
                    // ===== TAB 1: BASICS =====
                    Item {
                        ColumnLayout {
                            width: parent.width
                            spacing: 20
                            
                            // Buttons
                            GroupBox {
                                title: "Buttons"
                                Layout.fillWidth: true
                                
                                ColumnLayout {
                                    width: parent.width
                                    spacing: 15
                                    
                                    RowLayout {
                                        spacing: 10
                                        
                                        Button {
                                            text: "Standard Button"
                                            onClicked: outputText = "Standard Button geklickt"
                                        }
                                        
                                        Button {
                                            text: "Flat Button"
                                            flat: true
                                            onClicked: outputText = "Flat Button geklickt"
                                        }
                                        
                                        Button {
                                            text: "Highlighted"
                                            highlighted: true
                                            onClicked: outputText = "Highlighted Button geklickt"
                                        }
                                        
                                        Button {
                                            text: "Disabled"
                                            enabled: false
                                        }
                                    }
                                    
                                    RowLayout {
                                        spacing: 10
                                        
                                        RoundButton {
                                            text: "+"
                                            onClicked: outputText = "Round Button '+' geklickt"
                                        }
                                        
                                        RoundButton {
                                            text: "−"
                                            onClicked: outputText = "Round Button '−' geklickt"
                                        }
                                        
                                        ToolButton {
                                            text: "Tool"
                                            onClicked: outputText = "ToolButton geklickt"
                                        }
                                        
                                        DelayButton {
                                            text: "Hold Me"
                                            delay: 2000
                                            onActivated: outputText = "DelayButton aktiviert nach 2 Sekunden"
                                        }
                                    }
                                }
                            }
                            
                            // CheckBox & RadioButton
                            GroupBox {
                                title: "Checkboxes & Radio Buttons"
                                Layout.fillWidth: true
                                
                                ColumnLayout {
                                    spacing: 10
                                    
                                    RowLayout {
                                        CheckBox {
                                            id: check1
                                            text: "Option 1"
                                            onCheckedChanged: outputText = "CheckBox 1: " + (checked ? "aktiviert" : "deaktiviert")
                                        }
                                        CheckBox {
                                            id: check2
                                            text: "Option 2"
                                            checked: true
                                            onCheckedChanged: outputText = "CheckBox 2: " + (checked ? "aktiviert" : "deaktiviert")
                                        }
                                        CheckBox {
                                            text: "Partial"
                                            checkState: Qt.PartiallyChecked
                                            tristate: true
                                            onCheckStateChanged: outputText = "CheckBox State: " + checkState
                                        }
                                    }
                                    
                                    RowLayout {
                                        ButtonGroup { id: radioGroup }
                                        
                                        RadioButton {
                                            text: "Radio A"
                                            checked: true
                                            ButtonGroup.group: radioGroup
                                            onCheckedChanged: if (checked) outputText = "Radio A ausgewählt"
                                        }
                                        RadioButton {
                                            text: "Radio B"
                                            ButtonGroup.group: radioGroup
                                            onCheckedChanged: if (checked) outputText = "Radio B ausgewählt"
                                        }
                                        RadioButton {
                                            text: "Radio C"
                                            ButtonGroup.group: radioGroup
                                            onCheckedChanged: if (checked) outputText = "Radio C ausgewählt"
                                        }
                                    }
                                }
                            }
                            
                            // Switch & Slider
                            GroupBox {
                                title: "Switch & Slider"
                                Layout.fillWidth: true
                                
                                ColumnLayout {
                                    spacing: 15
                                    
                                    RowLayout {
                                        Switch {
                                            id: demoSwitch
                                            text: "Switch Element"
                                            onCheckedChanged: outputText = "Switch: " + (checked ? "ON" : "OFF")
                                        }
                                        Text {
                                            text: demoSwitch.checked ? "Aktiviert ✓" : "Deaktiviert"
                                            color: demoSwitch.checked ? "#4CAF50" : "#999"
                                            font.bold: true
                                        }
                                    }
                                    
                                    RowLayout {
                                        Text { text: "Slider:" }
                                        Slider {
                                            id: demoSlider
                                            from: 0
                                            to: 100
                                            value: 50
                                            Layout.fillWidth: true
                                            onValueChanged: outputText = "Slider Wert: " + Math.round(value)
                                        }
                                        Text {
                                            text: Math.round(demoSlider.value)
                                            font.bold: true
                                            color: "#E57373"
                                        }
                                    }
                                    
                                    RowLayout {
                                        Text { text: "Range:" }
                                        RangeSlider {
                                            id: rangeSlider
                                            from: 0
                                            to: 100
                                            first.value: 25
                                            second.value: 75
                                            Layout.fillWidth: true
                                            first.onValueChanged: outputText = "Range: " + Math.round(first.value) + " - " + Math.round(second.value)
                                            second.onValueChanged: outputText = "Range: " + Math.round(first.value) + " - " + Math.round(second.value)
                                        }
                                        Text {
                                            text: Math.round(rangeSlider.first.value) + " - " + Math.round(rangeSlider.second.value)
                                            color: "#E57373"
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // ===== TAB 2: INPUT =====
                    Item {
                        ColumnLayout {
                            width: parent.width
                            spacing: 16

                            // ── Text Input (volle Breite) ──────────────────────────
                            GroupBox {
                                title: "Text Input"
                                Layout.fillWidth: true

                                GridLayout {
                                    columns: 2
                                    columnSpacing: 20; rowSpacing: 12
                                    width: parent.width

                                    Label { text: "TextField:" }
                                    TextField {
                                        id: textField1
                                        placeholderText: "Name eingeben..."
                                        Layout.fillWidth: true
                                        onTextChanged: outputText = "TextField: " + text
                                    }

                                    Label { text: "Passwort:" }
                                    TextField {
                                        id: passwordField
                                        placeholderText: "Passwort..."
                                        echoMode: TextInput.Password
                                        Layout.fillWidth: true
                                        onTextChanged: outputText = "Passwort eingegeben (Länge: " + text.length + ")"
                                    }

                                    Label { text: "Mit Validator:" }
                                    TextField {
                                        placeholderText: "Nur Zahlen"
                                        validator: IntValidator { bottom: 0; top: 999 }
                                        Layout.fillWidth: true
                                        onTextChanged: outputText = "Zahl: " + text
                                    }

                                    Label { text: "TextArea:" }
                                    TextArea {
                                        id: textArea
                                        placeholderText: "Mehrzeiliger Text..."
                                        wrapMode: TextArea.Wrap
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 80
                                        onTextChanged: outputText = "TextArea (" + text.length + " Zeichen): " + text.substring(0, 50)
                                    }
                                }
                            }

                            // ── Links: Numerische Eingabe | Rechts: Datum+Zeit+Kalender (feste Größe) ──
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 16

                                // LINKS ── Numerische Eingabe (füllt verbleibende Breite) ─
                                GroupBox {
                                    title: qsTr("Numerische Eingabe")
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    GridLayout {
                                        columns: 3
                                        columnSpacing: 10; rowSpacing: 10
                                        width: parent.width

                                        Label { text: "SpinBox:" }
                                        SpinBox {
                                            id: spinBox1
                                            from: 0; to: 100; value: 42
                                            Layout.columnSpan: 2
                                            onValueChanged: outputText = "SpinBox: " + value
                                        }

                                        Label { text: "Integer:" }
                                        TextField {
                                            id: intField
                                            placeholderText: "0–100"
                                            Layout.fillWidth: true
                                            validator: IntValidator { bottom: 0; top: 100 }
                                            inputMethodHints: Qt.ImhDigitsOnly
                                            onTextChanged: {
                                                if (text !== "") {
                                                    var v = parseInt(text)
                                                    if (v >= 0 && v <= 100) outputText = "Integer: " + v
                                                }
                                            }
                                        }
                                        Text {
                                            text: intField.text !== "" ? (intField.acceptableInput ? "✓" : "✗") : ""
                                            color: intField.acceptableInput ? "#4CAF50" : "#F44336"
                                            font.bold: true
                                        }

                                        Label { text: "Double:" }
                                        TextField {
                                            id: doubleField
                                            placeholderText: "3.14"
                                            Layout.fillWidth: true
                                            validator: RegularExpressionValidator {
                                                regularExpression: /^\d{0,4}([.,]\d{0,2})?$/
                                            }
                                            onTextChanged: {
                                                if (text !== "" && acceptableInput) outputText = "Double: " + text
                                            }
                                        }
                                        Text {
                                            text: doubleField.text !== "" ? (doubleField.acceptableInput ? "✓" : "✗") : ""
                                            color: doubleField.acceptableInput ? "#4CAF50" : "#F44336"
                                            font.bold: true
                                        }

                                        Label { text: "€-SpinBox:" }
                                        SpinBox {
                                            id: doubleSpinBox
                                            from: 0; to: 1000; value: 314; stepSize: 10
                                            Layout.columnSpan: 2
                                            property int decimals: 2
                                            property real realValue: value / 100
                                            validator: DoubleValidator {
                                                bottom: Math.min(doubleSpinBox.from, doubleSpinBox.to)
                                                top:    Math.max(doubleSpinBox.from, doubleSpinBox.to)
                                            }
                                            textFromValue: function(value, locale) {
                                                return Number(value / 100).toLocaleString(locale, 'f', doubleSpinBox.decimals)
                                            }
                                            valueFromText: function(text, locale) {
                                                return Number.fromLocaleString(locale, text) * 100
                                            }
                                            onValueChanged: outputText = "Double SpinBox: " + realValue.toFixed(2)
                                        }

                                        Label { text: "Dial:" }
                                        Item {
                                            Layout.columnSpan: 2
                                            Layout.preferredWidth: 130
                                            Layout.preferredHeight: 130
                                            Dial {
                                                id: dial1
                                                from: 0; to: 360; value: 180
                                                anchors.centerIn: parent
                                                width: 100; height: 100
                                                onValueChanged: outputText = "Dial: " + Math.round(value) + "°"
                                            }
                                            Text {
                                                anchors.centerIn: parent
                                                text: Math.round(dial1.value) + "°"
                                                font.pixelSize: 15; font.bold: true; color: "#C62828"
                                            }
                                            Text { text: "0°";   font.pixelSize: 9; color: "#999"; x: 5;   y: 105 }
                                            Text { text: "360°"; font.pixelSize: 9; color: "#999"; x: 95;  y: 105 }
                                            Text { text: "180°"; font.pixelSize: 9; color: "#999"; x: 45;  y: 2   }
                                        }
                                    }
                                }

                                // RECHTS ── Datum, Zeit & Kalender (feste Zellgröße, kein Overflow) ──
                                GroupBox {
                                    id: calGroupBox
                                    title: qsTr("Datum, Zeit & Kalender")
                                    Layout.alignment: Qt.AlignTop

                                    // Feste Zellgröße 44px → Kalender 308×264px ≈ 8 cm bei 96 dpi
                                    readonly property int cellSz: 44
                                    readonly property int calW:   cellSz * 7   // 308 px
                                    readonly property int calH:   cellSz * 6   // 264 px

                                    // Innerer Container – Größe vom Inhalt bestimmt (kein anchors.fill)
                                    Rectangle {
                                        width:          parent.width
                                        implicitWidth:  dtCol.implicitWidth  + 16
                                        implicitHeight: dtCol.implicitHeight + 16
                                        border.color: "#E57373"; border.width: 1
                                        radius: 6; color: "#FFFFFF"

                                        ColumnLayout {
                                            id: dtCol
                                            anchors.left: parent.left; anchors.right: parent.right
                                            anchors.top:  parent.top;  anchors.margins: 8
                                            spacing: 4

                                            // ── Datum: Label-Anzeige + 3× +/- (kein Wert sichtbar) ──
                                            RowLayout {
                                                spacing: 4
                                                Text {
                                                    id: dateDisplay
                                                    text: ""; color: "#C62828"
                                                    font.bold: true; font.pixelSize: 14
                                                    Layout.minimumWidth: 92
                                                }
                                                Item { Layout.fillWidth: true }
                                                SpinBox {
                                                    id: dayBox
                                                    from: 1; to: 31; value: new Date().getDate()
                                                    implicitWidth: 72; editable: false
                                                    textFromValue: function(value) { return "" }
                                                    onValueChanged: updateDateOutput()
                                                }
                                                SpinBox {
                                                    id: monthBox
                                                    from: 1; to: 12; value: new Date().getMonth() + 1
                                                    implicitWidth: 72; editable: false
                                                    textFromValue: function(value) { return "" }
                                                    onValueChanged: updateDateOutput()
                                                }
                                                SpinBox {
                                                    id: yearBox
                                                    from: 2000; to: 2099; value: new Date().getFullYear()
                                                    implicitWidth: 72; editable: false
                                                    textFromValue: function(value) { return "" }
                                                    onValueChanged: updateDateOutput()
                                                }
                                            }

                                            // ── Zeit: Label-Anzeige + 3× +/- ────────────────────
                                            RowLayout {
                                                spacing: 4
                                                Text {
                                                    id: timeDisplay
                                                    text: ""; color: "#C62828"
                                                    font.bold: true; font.pixelSize: 14
                                                    Layout.minimumWidth: 92
                                                }
                                                Item { Layout.fillWidth: true }
                                                SpinBox {
                                                    id: hourBox
                                                    from: 0; to: 23; value: new Date().getHours()
                                                    implicitWidth: 72; editable: false
                                                    textFromValue: function(value) { return "" }
                                                    onValueChanged: updateTimeOutput()
                                                }
                                                SpinBox {
                                                    id: minuteBox
                                                    from: 0; to: 59; value: new Date().getMinutes()
                                                    implicitWidth: 72; editable: false
                                                    textFromValue: function(value) { return "" }
                                                    onValueChanged: updateTimeOutput()
                                                }
                                                SpinBox {
                                                    id: secondBox
                                                    from: 0; to: 59; value: 0
                                                    implicitWidth: 72; editable: false
                                                    textFromValue: function(value) { return "" }
                                                    onValueChanged: updateTimeOutput()
                                                }
                                            }

                                            Rectangle { height: 1; Layout.fillWidth: true; color: "#FFCDD2" }

                                            // ── Monat/Jahr Navigation (Breite = calW) ────────────
                                            RowLayout {
                                                Layout.preferredWidth: calGroupBox.calW
                                                Layout.alignment: Qt.AlignHCenter
                                                Button {
                                                    text: "◀"; flat: true
                                                    implicitWidth: 36; implicitHeight: 34
                                                    onClicked: {
                                                        if (monthBox.value > 1) monthBox.value--
                                                        else { monthBox.value = 12; yearBox.value-- }
                                                    }
                                                }
                                                Item { Layout.fillWidth: true }
                                                Text {
                                                    text: ["", "Januar", "Februar", "März", "April", "Mai", "Juni",
                                                           "Juli", "August", "September", "Oktober", "November", "Dezember"
                                                          ][monthBox.value] + "  " + yearBox.value
                                                    font.bold: true; font.pixelSize: 15; color: "#C62828"
                                                }
                                                Item { Layout.fillWidth: true }
                                                Button {
                                                    text: "▶"; flat: true
                                                    implicitWidth: 36; implicitHeight: 34
                                                    onClicked: {
                                                        if (monthBox.value < 12) monthBox.value++
                                                        else { monthBox.value = 1; yearBox.value++ }
                                                    }
                                                }
                                            }

                                            // ── Wochentage-Header (je cellSz breit) ──────────────
                                            Row {
                                                Layout.alignment: Qt.AlignHCenter
                                                Repeater {
                                                    model: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
                                                    Text {
                                                        width: calGroupBox.cellSz
                                                        text: modelData
                                                        font.pixelSize: 12; font.bold: true
                                                        color: index >= 5 ? "#C62828" : "#666"
                                                        horizontalAlignment: Text.AlignHCenter
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                height: 1; color: "#FFCDD2"
                                                Layout.preferredWidth: calGroupBox.calW
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                            // ── Kalender-Grid: FESTE Größe → nie abgeschnitten ───
                                            Item {
                                                id: calGridItem
                                                Layout.preferredWidth:  calGroupBox.calW   // 308 px (fest)
                                                Layout.preferredHeight: calGroupBox.calH   // 264 px (fest)
                                                Layout.alignment: Qt.AlignHCenter

                                                Grid {
                                                    id: calGrid
                                                    anchors.fill: parent
                                                    columns: 7

                                                    property int  daysInMonth:    new Date(yearBox.value, monthBox.value, 0).getDate()
                                                    property int  firstDayOfWeek: (new Date(yearBox.value, monthBox.value - 1, 1).getDay() + 6) % 7
                                                    property real cellW: calGroupBox.cellSz   // fest 44 px
                                                    property real cellH: calGroupBox.cellSz   // fest 44 px

                                                    Repeater {
                                                        model: 42
                                                        Rectangle {
                                                            property int  dayNum:     index - calGrid.firstDayOfWeek + 1
                                                            property bool isValid:    dayNum >= 1 && dayNum <= calGrid.daysInMonth
                                                            property bool isSelected: isValid && dayNum === dayBox.value
                                                            property bool isWeekend:  (index % 7) >= 5

                                                            width:  calGrid.cellW; height: calGrid.cellH
                                                            radius: Math.min(width, height) * 0.45
                                                            color:  isSelected ? "#C62828" :
                                                                    (calDayMouse.containsMouse && isValid ? "#FFEBEE" : "transparent")

                                                            Text {
                                                                anchors.centerIn: parent
                                                                text:           isValid ? dayNum : ""
                                                                font.pixelSize: 14
                                                                font.bold:      isSelected
                                                                color: isSelected ? "white" :
                                                                       (isWeekend && isValid ? "#E53935" : "#424242")
                                                            }
                                                            MouseArea {
                                                                id: calDayMouse
                                                                anchors.fill: parent
                                                                hoverEnabled: true
                                                                onClicked: {
                                                                    if (isValid) {
                                                                        dayBox.value = dayNum
                                                                        outputText = qsTr("Kalender: ") + dayNum + "." + monthBox.value + "." + yearBox.value
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // ===== TAB 3: SELECTION =====
                    Item {
                        ColumnLayout {
                            width: parent.width
                            spacing: 20
                            
                            // ComboBox
                            GroupBox {
                                title: "ComboBox & Tumbler"
                                Layout.fillWidth: true
                                
                                GridLayout {
                                    columns: 2
                                    columnSpacing: 20
                                    rowSpacing: 15
                                    width: parent.width
                                    
                                    Label { text: "Einfach:" }
                                    ComboBox {
                                        id: combo1
                                        model: ["Option 1", "Option 2", "Option 3", "Option 4"]
                                        Layout.fillWidth: true
                                        onCurrentTextChanged: outputText = "ComboBox: " + currentText + " (Index: " + currentIndex + ")"
                                    }
                                    
                                    Label { text: "Editierbar:" }
                                    ComboBox {
                                        model: ["Deutschland", "Österreich", "Schweiz"]
                                        editable: true
                                        Layout.fillWidth: true
                                        onAccepted: outputText = "ComboBox editiert: " + editText
                                    }
                                    
                                    Label { text: "Tumbler:" }
                                    Rectangle {
                                        Layout.preferredWidth: 70
                                        Layout.preferredHeight: 120
                                        border.color: "#E57373"
                                        border.width: 1
                                        radius: 6
                                        color: "#FFF5F5"
                                        clip: true

                                        Tumbler {
                                            id: tumbler1
                                            model: 24
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            visibleItemCount: 5
                                            wrap: true

                                            delegate: Text {
                                                text: String(modelData).padStart(2, '0')
                                                font.pixelSize: index === tumbler1.currentIndex ? 18 : 14
                                                font.bold: index === tumbler1.currentIndex
                                                color: index === tumbler1.currentIndex ? "#C62828" : "#999"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler1.visibleItemCount / 2)
                                            }

                                            onCurrentIndexChanged: outputText = "Tumbler: " + currentIndex + " Uhr"
                                        }

                                        // Untere Markierungslinie
                                        Rectangle {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: parent.width - 10
                                            height: 1
                                            color: "#E57373"
                                            y: parent.height / 2 + 12
                                        }
                                    }
                                }
                            }
                            
                            // ListView
                            GroupBox {
                                title: "ListView"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 250
                                
                                ListView {
                                    id: listView
                                    anchors.fill: parent
                                    clip: true
                                    
                                    model: ListModel {
                                        ListElement { name: "Apple"; quantity: 5; price: 2.50 }
                                        ListElement { name: "Banana"; quantity: 12; price: 1.80 }
                                        ListElement { name: "Orange"; quantity: 8; price: 3.20 }
                                        ListElement { name: "Grape"; quantity: 20; price: 4.50 }
                                        ListElement { name: "Mango"; quantity: 3; price: 5.00 }
                                    }
                                    
                                    delegate: ItemDelegate {
                                        width: listView.width
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 20
                                            
                                            Text {
                                                text: name
                                                font.bold: true
                                                font.pixelSize: 16
                                                Layout.preferredWidth: 100
                                            }
                                            
                                            Text {
                                                text: "Menge: " + quantity
                                                color: "#666"
                                            }
                                            
                                            Item { Layout.fillWidth: true }
                                            
                                            Text {
                                                text: "€ " + price.toFixed(2)
                                                color: "#4CAF50"
                                                font.bold: true
                                            }
                                        }
                                        
                                        onClicked: outputText = "ListView Item: " + name + " (€" + price + ")"
                                    }
                                    
                                    ScrollBar.vertical: ScrollBar {}
                                }
                            }
                        }
                    }
                    
                    // ===== TAB 4: DISPLAY =====
                    Item {
                        ColumnLayout {
                            width: parent.width
                            spacing: 20
                            
                            // ProgressBar & BusyIndicator
                            GroupBox {
                                title: "Progress & Indicators"
                                Layout.fillWidth: true
                                
                                ColumnLayout {
                                    spacing: 15
                                    width: parent.width
                                    
                                    RowLayout {
                                        Label { text: "ProgressBar:" }
                                        ProgressBar {
                                            id: progressBar1
                                            from: 0
                                            to: 100
                                            value: demoSlider.value
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: Math.round(progressBar1.value) + "%"
                                            color: "#E57373"
                                        }
                                    }
                                    
                                    RowLayout {
                                        Label { text: "Indeterminate:" }
                                        ProgressBar {
                                            indeterminate: true
                                            Layout.fillWidth: true
                                        }
                                    }
                                    
                                    RowLayout {
                                        Label { text: "BusyIndicator:" }
                                        BusyIndicator {
                                            running: busySwitch.checked
                                        }
                                        Switch {
                                            id: busySwitch
                                            text: "Running"
                                            checked: true
                                            onCheckedChanged: outputText = "BusyIndicator: " + (checked ? "läuft" : "gestoppt")
                                        }
                                    }
                                }
                            }
                            
                            // Labels mit Farben
                            GroupBox {
                                title: "Labels & Text"
                                Layout.fillWidth: true
                                
                                GridLayout {
                                    columns: 2
                                    columnSpacing: 20
                                    rowSpacing: 10
                                    
                                    Label {
                                        text: "Standard Label"
                                    }
                                    Label {
                                        text: "Mit Tooltip"
                                        color: "#E57373"

                                        ToolTip {
                                            id: labelToolTip
                                            visible: labelMouseArea.containsMouse
                                            text: "Dies ist ein Tooltip!"
                                            delay: 300

                                            contentItem: Text {
                                                text: labelToolTip.text
                                                color: "black"
                                                font.pixelSize: 13
                                            }
                                            background: Rectangle {
                                                color: "#FFEE58"
                                                border.color: "#F9A825"
                                                border.width: 1
                                                radius: 4
                                            }
                                        }

                                        MouseArea {
                                            id: labelMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: outputText = "Label mit Tooltip geklickt"
                                        }
                                    }
                                    
                                    Label {
                                        text: "Fett & Groß"
                                        font.bold: true
                                        font.pixelSize: 20
                                    }
                                    Label {
                                        text: "Kursiv & Rot"
                                        font.italic: true
                                        color: "#F44336"
                                    }
                                    
                                    Label {
                                        text: "Link Style"
                                        color: "#E57373"
                                        font.underline: true
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: outputText = "Link geklickt"
                                        }
                                    }
                                    Label {
                                        text: "Durchgestrichen"
                                        font.strikeout: true
                                        color: "#999"
                                    }
                                }
                            }
                            
                            // TabBar Demo
                            GroupBox {
                                title: "TabBar (Nested)"
                                Layout.fillWidth: true
                                
                                ColumnLayout {
                                    width: parent.width
                                    
                                    TabBar {
                                        id: nestedTabBar
                                        Layout.fillWidth: true
                                        
                                        TabButton { text: "Tab 1" }
                                        TabButton { text: "Tab 2" }
                                        TabButton { text: "Tab 3" }
                                        
                                        onCurrentIndexChanged: outputText = "Nested Tab gewechselt: " + currentIndex
                                    }
                                    
                                    StackLayout {
                                        currentIndex: nestedTabBar.currentIndex
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 100
                                        
                                        Rectangle {
                                            color: "#FFEBEE"
                                            Text {
                                                anchors.centerIn: parent
                                                text: "Content Tab 1"
                                                font.pixelSize: 18
                                            }
                                        }
                                        Rectangle {
                                            color: "#E3F2FD"
                                            Text {
                                                anchors.centerIn: parent
                                                text: "Content Tab 2"
                                                font.pixelSize: 18
                                            }
                                        }
                                        Rectangle {
                                            color: "#E8F5E9"
                                            Text {
                                                anchors.centerIn: parent
                                                text: "Content Tab 3"
                                                font.pixelSize: 18
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // ===== TAB 5: DATABASE =====
                    Item {
                        ColumnLayout {
                            width: parent.width
                            spacing: 20

                            // Greeting Anzeige
                            GroupBox {
                                title: qsTr("Datenbank-Abfrage")
                                Layout.fillWidth: true

                                ColumnLayout {
                                    spacing: 15
                                    width: parent.width

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 100
                                        color: "#FFF5F5"
                                        border.color: "#E57373"
                                        border.width: 2
                                        radius: 8

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 8

                                            Text {
                                                id: greetingText
                                                text: qsTr("Lade...")
                                                font.pixelSize: 28
                                                font.bold: true
                                                color: "#E57373"
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            Text {
                                                id: statusText
                                                text: ""
                                                font.pixelSize: 11
                                                color: "#999"
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 10
                                        Layout.alignment: Qt.AlignHCenter

                                        Button { text: "Deutsch"; onClicked: loadGreeting("de") }
                                        Button { text: "English"; onClicked: loadGreeting("en") }
                                        Button { text: "Español"; onClicked: loadGreeting("es") }
                                        Button { text: qsTr("Neu laden"); highlighted: true; onClicked: loadGreeting("de") }
                                    }
                                }
                            }

                            // ===== DB-BROWSER =====
                            GroupBox {
                                title: qsTr("Datenbank-Browser")
                                Layout.fillWidth: true
                                Layout.preferredHeight: 350

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 15

                                    // Tabellen-Liste (links)
                                    ColumnLayout {
                                        Layout.preferredWidth: 180
                                        Layout.fillHeight: true
                                        spacing: 5

                                        Label {
                                            text: qsTr("Tabellen")
                                            font.bold: true
                                            color: "#C62828"
                                        }

                                        ListView {
                                            id: tableList
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            clip: true
                                            model: dbTables

                                            delegate: ItemDelegate {
                                                width: tableList.width
                                                text: modelData
                                                highlighted: modelData === selectedTable
                                                font.bold: modelData === selectedTable

                                                background: Rectangle {
                                                    color: modelData === selectedTable ? "#FFEBEE" : (parent.hovered ? "#FFF5F5" : "transparent")
                                                    border.color: modelData === selectedTable ? "#E57373" : "transparent"
                                                    border.width: 1
                                                    radius: 4
                                                }

                                                onClicked: loadTableData(modelData)
                                            }

                                            ScrollBar.vertical: ScrollBar {}
                                        }

                                        Button {
                                            text: qsTr("Aktualisieren")
                                            Layout.fillWidth: true
                                            onClicked: loadTables()
                                        }
                                    }

                                    Rectangle {
                                        width: 1
                                        Layout.fillHeight: true
                                        color: "#e0e0e0"
                                    }

                                    // Daten-Liste (rechts)
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 5

                                        Label {
                                            text: selectedTable ? (selectedTable + " (" + tableRows.length + " " + qsTr("Zeilen") + ")") : qsTr("Tabelle wählen...")
                                            font.bold: true
                                            color: "#C62828"
                                        }

                                        // Spalten-Header
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 30
                                            color: "#C62828"
                                            radius: 4
                                            visible: tableColumns.length > 0

                                            Row {
                                                anchors.fill: parent
                                                anchors.leftMargin: 10
                                                anchors.rightMargin: 10
                                                spacing: 15

                                                Repeater {
                                                    model: tableColumns
                                                    Text {
                                                        text: modelData
                                                        color: "white"
                                                        font.bold: true
                                                        font.pixelSize: 12
                                                        width: Math.max(80, (parent.width - tableColumns.length * 15) / tableColumns.length)
                                                        elide: Text.ElideRight
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }
                                            }
                                        }

                                        // Daten-Zeilen
                                        ListView {
                                            id: dataListView
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            clip: true
                                            model: tableModel

                                            delegate: ItemDelegate {
                                                width: dataListView.width
                                                height: 36

                                                property var parsedRow: JSON.parse(rowData)

                                                background: Rectangle {
                                                    color: index % 2 === 0 ? "#FFFFFF" : "#FFF8F8"
                                                    border.color: parent.hovered ? "#E57373" : "transparent"
                                                    border.width: 1
                                                }

                                                Row {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 10
                                                    anchors.rightMargin: 10
                                                    spacing: 15

                                                    Repeater {
                                                        model: tableColumns
                                                        Text {
                                                            text: {
                                                                var val = parsedRow[modelData];
                                                                return val !== null && val !== undefined ? String(val) : "NULL";
                                                            }
                                                            font.pixelSize: 12
                                                            color: "#424242"
                                                            width: Math.max(80, (parent.width - tableColumns.length * 15) / tableColumns.length)
                                                            elide: Text.ElideRight
                                                            anchors.verticalCenter: parent.verticalCenter
                                                        }
                                                    }
                                                }

                                                onDoubleClicked: {
                                                    detailDialog.rowData = parsedRow;
                                                    detailDialog.title = qsTr("Datensatz Details") + " — " + selectedTable + " #" + (index + 1);
                                                    detailDialog.open();
                                                    outputText = qsTr("Detail-Ansicht: ") + selectedTable + " Zeile " + (index + 1);
                                                }

                                                onClicked: {
                                                    outputText = selectedTable + " Zeile " + (index + 1) + " — " + qsTr("Doppelklick für Details");
                                                }
                                            }

                                            ScrollBar.vertical: ScrollBar {}
                                        }
                                    }
                                }
                            }

                            // Server Kontrolle + API Info (kompakt)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 15

                                GroupBox {
                                    title: qsTr("Server Kontrolle")
                                    Layout.fillWidth: true

                                    RowLayout {
                                        spacing: 15

                                        Button {
                                            text: qsTr("Backend beenden")

                                            background: Rectangle {
                                                color: parent.pressed ? "#C62828" : (parent.hovered ? "#EF5350" : "#F44336")
                                                radius: 4
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                font: parent.font
                                                color: "white"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: shutdownDialog.open()
                                        }

                                        Text {
                                            text: qsTr("Nur Development!")
                                            color: "#999"
                                            font.italic: true
                                        }
                                    }
                                }

                                GroupBox {
                                    title: qsTr("API Informationen")
                                    Layout.fillWidth: true

                                    ColumnLayout {
                                        spacing: 3
                                        Label { text: "POST /api/login"; font.family: "monospace"; font.pixelSize: 11; color: "#4CAF50" }
                                        Label { text: "GET  /api/greeting?lang=de"; font.family: "monospace"; font.pixelSize: 11 }
                                        Label { text: "GET  /api/tables"; font.family: "monospace"; font.pixelSize: 11 }
                                        Label { text: "GET  /api/table?name=X"; font.family: "monospace"; font.pixelSize: 11 }
                                        Label { text: "GET  /api/styles"; font.family: "monospace"; font.pixelSize: 11 }
                                    }
                                }
                            }
                        }
                    }
                    // ===== TAB 6: PRODUKTE =====
                    Item {
                        ColumnLayout {
                            width: parent.width
                            spacing: 10

                            // Toolbar
                            GroupBox {
                                title: qsTr("Produkt-Verwaltung")
                                Layout.fillWidth: true

                                RowLayout {
                                    spacing: 8

                                    Button {
                                        text: qsTr("＋ Neu")
                                        highlighted: true
                                        onClicked: {
                                            productDialog.editId = -1
                                            productDialog.clearForm()
                                            productDialog.open()
                                        }
                                    }
                                    Button {
                                        text: qsTr("✎ Bearbeiten")
                                        enabled: selectedProductId >= 0
                                        onClicked: {
                                            productDialog.editId = selectedProductId
                                            productDialog.fillForm(selectedProductData)
                                            productDialog.open()
                                        }
                                    }
                                    Button {
                                        text: qsTr("✕ Löschen")
                                        enabled: selectedProductId >= 0
                                        background: Rectangle {
                                            color: parent.enabled
                                                   ? (parent.pressed ? "#C62828" : (parent.hovered ? "#EF5350" : "#F44336"))
                                                   : "#ccc"
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: parent.text; font: parent.font
                                            color: parent.enabled ? "white" : "#888"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: productDeleteDialog.open()
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: productData.length + qsTr(" Produkte")
                                        color: "#999"; font.pixelSize: 12
                                    }

                                    Button {
                                        text: qsTr("⟳ Aktualisieren")
                                        onClicked: loadProducts()
                                    }
                                }
                            }

                            // Tabellen-Header
                            Rectangle {
                                Layout.fillWidth: true
                                height: 34
                                color: "#C62828"
                                radius: 4
                                visible: productData.length > 0

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    Repeater {
                                        model: [
                                            {label: "ID",        w: 50},
                                            {label: "Art.-Nr.",  w: 100},
                                            {label: "Name",      w: 260},
                                            {label: "Einheit",   w: 60},
                                            {label: "EK-Preis",  w: 80},
                                            {label: "VK-Preis",  w: 80},
                                            {label: "MwSt.",     w: 55},
                                            {label: "Aktiv",     w: 50}
                                        ]

                                        Text {
                                            width: modelData.w
                                            height: parent.height
                                            text: modelData.label
                                            color: "white"; font.bold: true; font.pixelSize: 12
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }

                            // Produktliste
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 460
                                color: "white"
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 4
                                clip: true

                                ListView {
                                    id: productListView
                                    anchors.fill: parent
                                    clip: true
                                    model: productModel

                                    delegate: Item {
                                        width: productListView.width
                                        height: 36

                                        property var pdata: JSON.parse(rowJson)
                                        property bool isSelected: pdata.product_id === selectedProductId

                                        Rectangle {
                                            anchors.fill: parent
                                            color: isSelected ? "#FFEBEE"
                                                   : (index % 2 === 0 ? "#FFFFFF" : "#FFF8F8")
                                            border.color: isSelected ? "#E57373" : "transparent"
                                            border.width: isSelected ? 1 : 0
                                        }

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 10

                                            Repeater {
                                                model: [
                                                    {key: "product_id",     w: 50,  fmt: "int"},
                                                    {key: "product_number", w: 100, fmt: "str"},
                                                    {key: "name",           w: 260, fmt: "str"},
                                                    {key: "unit",           w: 60,  fmt: "str"},
                                                    {key: "purchase_price", w: 80,  fmt: "eur"},
                                                    {key: "sales_price",    w: 80,  fmt: "eur"},
                                                    {key: "vat_code",       w: 55,  fmt: "vat"},
                                                    {key: "active",         w: 50,  fmt: "bool"}
                                                ]

                                                Text {
                                                    width: modelData.w
                                                    height: 36
                                                    font.pixelSize: 12
                                                    color: {
                                                        if (modelData.fmt === "eur") return "#4CAF50"
                                                        if (modelData.fmt === "bool") return pdata[modelData.key] == 1 ? "#4CAF50" : "#F44336"
                                                        return "#424242"
                                                    }
                                                    font.bold: modelData.fmt === "bool"
                                                    verticalAlignment: Text.AlignVCenter
                                                    elide: Text.ElideRight
                                                    text: {
                                                        var v = pdata[modelData.key]
                                                        if (v === null || v === undefined) return "—"
                                                        if (modelData.fmt === "eur")  return "€ " + Number(v).toFixed(2)
                                                        if (modelData.fmt === "vat")  return v == 1 ? "7%" : "19%"
                                                        if (modelData.fmt === "bool") return v == 1 ? "✓ Ja" : "✗ Nein"
                                                        return String(v)
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                selectedProductId   = pdata.product_id
                                                selectedProductData = pdata
                                                outputText = "Produkt gewählt: " + pdata.name + " (ID " + pdata.product_id + ")"
                                            }
                                            onDoubleClicked: {
                                                selectedProductId   = pdata.product_id
                                                selectedProductData = pdata
                                                productDialog.editId = pdata.product_id
                                                productDialog.fillForm(pdata)
                                                productDialog.open()
                                            }
                                        }
                                    }

                                    ScrollBar.vertical: ScrollBar {}
                                }

                                // Leer-Hinweis
                                Text {
                                    anchors.centerIn: parent
                                    text: qsTr("Keine Produkte geladen — bitte anmelden und 'Aktualisieren' klicken")
                                    color: "#ccc"; font.pixelSize: 14; font.italic: true
                                    visible: productModel.count === 0
                                }
                            }

                            // API-Info
                            GroupBox {
                                title: qsTr("API Endpunkte (Produkte)")
                                Layout.fillWidth: true

                                ColumnLayout {
                                    spacing: 2
                                    Label { text: "GET    /api/products";       font.family: "monospace"; font.pixelSize: 11; color: "#2196F3" }
                                    Label { text: "POST   /api/products";       font.family: "monospace"; font.pixelSize: 11; color: "#4CAF50" }
                                    Label { text: "PUT    /api/products/{id}";  font.family: "monospace"; font.pixelSize: 11; color: "#FF9800" }
                                    Label { text: "DELETE /api/products/{id}";  font.family: "monospace"; font.pixelSize: 11; color: "#F44336" }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ===== OUTPUT CONSOLE =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            color: "#263238"
            border.color: "#37474F"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5
                
                Text {
                    text: "Output Console:"
                    color: "#EF9A9A"
                    font.bold: true
                    font.pixelSize: 12
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#1E1E1E"
                    radius: 4
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        Text {
                            text: "> " + outputText
                            color: "#4CAF50"
                            font.family: "monospace"
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            width: parent.width
                        }
                    }
                }
            }
        }
        
        // ===== FOOTER =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#37474F"

            RowLayout {
                anchors.centerIn: parent
                spacing: 15

                Text {
                    text: isLoggedIn ? ("✓ " + authUser) : qsTr("Nicht angemeldet")
                    color: isLoggedIn ? "#81C784" : "#EF9A9A"
                    font.pixelSize: 12
                    font.bold: true
                }

                Rectangle { width: 1; height: 20; color: "#546E7A" }

                Text {
                    text: "Qt " + Application.version
                    color: "#B0BEC5"
                    font.pixelSize: 12
                }

                Rectangle { width: 1; height: 20; color: "#546E7A" }

                Text {
                    text: "WebAssembly"
                    color: "#B0BEC5"
                    font.pixelSize: 12
                }

                Rectangle { width: 1; height: 20; color: "#546E7A" }

                Text {
                    text: "Style:"
                    color: "#B0BEC5"
                    font.pixelSize: 12
                }

                ComboBox {
                    id: styleSelector
                    model: ["Material", "Fusion", "Basic", "Universal"]
                    currentIndex: model.indexOf(currentStyle)
                    implicitWidth: 120
                    font.pixelSize: 12

                    onActivated: function(index) {
                        var style = model[index]
                        outputText = "Style: " + style
                        styleHelper.switchWithParams("style", style)
                    }
                }

                Rectangle { width: 1; height: 20; color: "#546E7A" }

                Text {
                    text: qsTr("Sprache:")
                    color: "#B0BEC5"
                    font.pixelSize: 12
                }

                ComboBox {
                    id: langSelector
                    model: ["Deutsch", "English"]
                    currentIndex: currentLang === "en" ? 1 : 0
                    implicitWidth: 110
                    font.pixelSize: 12

                    onActivated: function(index) {
                        var lang = index === 1 ? "en" : "de"
                        outputText = "Sprache: " + model[index]
                        styleHelper.switchWithParams("lang", lang)
                    }
                }
            }
        }
    }
    
    // ===== LOGIN DIALOG =====
    Dialog {
        id: loginDialog
        title: qsTr("Anmeldung")
        modal: true
        anchors.centerIn: parent
        width: 380
        closePolicy: Popup.NoAutoClose

        ColumnLayout {
            width: parent.width
            spacing: 15

            // Logo/Titel
            Text {
                text: "Qt6 WebApp"
                font.pixelSize: 22
                font.bold: true
                color: "#C62828"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: qsTr("Bitte melden Sie sich an")
                color: "#666"
                font.pixelSize: 13
                Layout.alignment: Qt.AlignHCenter
            }

            // Fehlermeldung
            Rectangle {
                id: loginErrorBox
                Layout.fillWidth: true
                height: loginErrorText.implicitHeight + 16
                color: "#FFEBEE"
                border.color: "#F44336"
                border.width: 1
                radius: 4
                visible: loginErrorText.text !== ""

                Text {
                    id: loginErrorText
                    text: ""
                    color: "#C62828"
                    font.pixelSize: 12
                    anchors.centerIn: parent
                    width: parent.width - 20
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            GridLayout {
                columns: 2
                columnSpacing: 10
                rowSpacing: 10
                Layout.fillWidth: true

                Label { text: qsTr("Benutzer:"); font.bold: true }
                TextField {
                    id: loginUserField
                    placeholderText: qsTr("Benutzername")
                    Layout.fillWidth: true
                    text: "admin"
                    onAccepted: loginPasswordField.forceActiveFocus()
                }

                Label { text: qsTr("Passwort:"); font.bold: true }
                TextField {
                    id: loginPasswordField
                    placeholderText: qsTr("Passwort")
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    onAccepted: performLogin()
                }
            }
        }

        footer: DialogButtonBox {
            Button {
                text: qsTr("Anmelden")
                highlighted: true
                enabled: loginUserField.text !== "" && loginPasswordField.text !== ""
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            }
        }

        onAccepted: performLogin()
    }

    // ===== SHUTDOWN DIALOG (Ja/Nein) =====
    Dialog {
        id: shutdownDialog
        title: qsTr("Server beenden?")
        modal: true
        anchors.centerIn: parent
        width: 400

        Label {
            text: qsTr("Möchten Sie das Qt-Backend wirklich beenden?\n\nDie Applikation ist danach nicht mehr funktionsfähig.")
            wrapMode: Text.WordWrap
            width: parent.width
        }

        footer: DialogButtonBox {
            Button {
                text: qsTr("Ja")
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            }
            Button {
                text: qsTr("Nein")
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
        }

        onAccepted: shutdownServer()
    }

    // ===== DETAIL POPUP (Readonly) =====
    Dialog {
        id: detailDialog
        title: qsTr("Datensatz Details")
        modal: true
        anchors.centerIn: parent
        width: 500
        height: Math.min(450, detailColumn.implicitHeight + 120)

        property var rowData: ({})

        ScrollView {
            anchors.fill: parent
            clip: true

            ColumnLayout {
                id: detailColumn
                width: parent.width
                spacing: 8

                Repeater {
                    model: Object.keys(detailDialog.rowData)

                    RowLayout {
                        spacing: 10
                        Layout.fillWidth: true

                        Label {
                            text: modelData + ":"
                            font.bold: true
                            Layout.preferredWidth: 140
                            color: "#C62828"
                        }
                        Label {
                            text: String(detailDialog.rowData[modelData] !== null ? detailDialog.rowData[modelData] : "NULL")
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }

        footer: DialogButtonBox {
            Button {
                text: qsTr("Schließen")
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
        }
    }

    // ===== PRODUKT EDIT DIALOG =====
    Dialog {
        id: productDialog
        title: editId < 0 ? qsTr("Neues Produkt") : qsTr("Produkt bearbeiten")
        modal: true
        anchors.centerIn: parent
        width: 640
        height: 680

        property int editId: -1

        // Beim Öffnen Dialog so groß wie möglich skalieren
        onAboutToShow: {
            var ov = Overlay.overlay
            if (ov && ov.width > 0 && ov.height > 0) {
                // Breite: Fensterbreite minus kleiner Rand
                width = Math.min(1000, Math.max(480, ov.width - 40))

                // Höhe: Formularinhalt + Dialog-Overhead (Titelzeile ~56px + Footer 64px + Padding ~48px)
                var contentH = pfFormColumn.implicitHeight
                var overhead = 56 + 64 + 48
                var needed   = (contentH > 0 ? contentH : 750) + overhead
                height = Math.min(Math.max(needed, 400), ov.height - 40)
            }
        }

        function clearForm() {
            pfNumber.text      = ""
            pfGtin.text        = ""
            pfName.text        = ""
            pfUnit.currentIndex = 0
            pfPurchase.text    = ""
            pfSales.text       = ""
            pfVat.currentIndex = 0
            pfCatId.text       = ""
            pfSuppId.text      = ""
            pfDesc.text        = ""
            pfActive.checked   = true
            pfError.text       = ""
        }

        function fillForm(p) {
            pfNumber.text      = p.product_number || ""
            pfGtin.text        = p.gtin !== null && p.gtin !== undefined ? String(p.gtin) : ""
            pfName.text        = p.name || ""
            var units = ["ST","KG"]
            pfUnit.currentIndex = Math.max(0, units.indexOf(p.unit))
            pfPurchase.text    = p.purchase_price !== null && p.purchase_price !== undefined
                                 ? Number(p.purchase_price).toFixed(2).replace('.', ',') : ""
            pfSales.text       = p.sales_price !== undefined
                                 ? Number(p.sales_price).toFixed(2).replace('.', ',') : ""
            pfVat.currentIndex = p.vat_code == 1 ? 0 : 1
            pfCatId.text       = p.category_id !== null && p.category_id !== undefined ? String(p.category_id) : ""
            pfSuppId.text      = p.supplier_id !== null && p.supplier_id !== undefined ? String(p.supplier_id) : ""
            pfDesc.text        = p.description || ""
            pfActive.checked   = p.active == 1
            pfError.text       = ""
        }

        ScrollView {
            id: pfScrollView
            anchors.fill: parent
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: pfFormColumn
                width: pfScrollView.width
                spacing: 0

                // Fehlermeldung
                Rectangle {
                    id: pfErrorBox
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    height: pfError.implicitHeight + 14
                    color: "#FFEBEE"; border.color: "#F44336"; border.width: 1; radius: 4
                    visible: pfError.text !== ""
                    Text {
                        id: pfError
                        text: ""
                        color: "#C62828"; font.pixelSize: 12
                        anchors.centerIn: parent
                        width: parent.width - 16
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // ── Sektion: Stammdaten ──────────────────────────────────
                Label {
                    text: qsTr("Stammdaten")
                    font.bold: true; font.pixelSize: 12
                    color: "#C62828"
                    Layout.topMargin: 2
                }
                Rectangle {
                    Layout.fillWidth: true; height: 1
                    color: "#FFCDD2"; Layout.bottomMargin: 10
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 16; rowSpacing: 12
                    Layout.fillWidth: true
                    Layout.bottomMargin: 14

                    Label {
                        text: qsTr("Art.-Nr. *"); font.bold: true
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    TextField {
                        id: pfNumber
                        placeholderText: "z.B. P001"
                        Layout.fillWidth: true
                        maximumLength: 20
                    }

                    Label {
                        text: "GTIN"
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    TextField {
                        id: pfGtin
                        placeholderText: "14-stellige EAN"
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: RegularExpressionValidator { regularExpression: /^\d{0,14}$/ }
                    }

                    Label {
                        text: qsTr("Name *"); font.bold: true
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    TextField {
                        id: pfName
                        placeholderText: qsTr("Produktname")
                        Layout.fillWidth: true
                        maximumLength: 100
                    }

                    Label {
                        text: qsTr("Einheit *"); font.bold: true
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    ComboBox {
                        id: pfUnit
                        model: ["ST", "KG"]
                        Layout.preferredWidth: 140
                    }
                }

                // ── Sektion: Preise & Steuern ────────────────────────────
                Label {
                    text: qsTr("Preise & Steuern")
                    font.bold: true; font.pixelSize: 12
                    color: "#C62828"
                }
                Rectangle {
                    Layout.fillWidth: true; height: 1
                    color: "#FFCDD2"; Layout.bottomMargin: 10
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 16; rowSpacing: 12
                    Layout.fillWidth: true
                    Layout.bottomMargin: 14

                    Label {
                        text: qsTr("EK-Preis €")
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    TextField {
                        id: pfPurchase
                        placeholderText: "0,00"
                        Layout.preferredWidth: 160
                        validator: RegularExpressionValidator { regularExpression: /^\d{0,8}(,\d{0,2})?$/ }
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }

                    Label {
                        text: qsTr("VK-Preis € *"); font.bold: true
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    TextField {
                        id: pfSales
                        placeholderText: "0,00"
                        Layout.preferredWidth: 160
                        validator: RegularExpressionValidator { regularExpression: /^\d{0,8}(,\d{0,2})?$/ }
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }

                    Label {
                        text: qsTr("MwSt.-Satz *"); font.bold: true
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    ComboBox {
                        id: pfVat
                        model: ["1 — ermäßigt (10%)", "2 — normal (20%)"]
                        Layout.fillWidth: true
                    }
                }

                // ── Sektion: Klassifizierung ─────────────────────────────
                Label {
                    text: qsTr("Klassifizierung")
                    font.bold: true; font.pixelSize: 12
                    color: "#C62828"
                }
                Rectangle {
                    Layout.fillWidth: true; height: 1
                    color: "#FFCDD2"; Layout.bottomMargin: 10
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 16; rowSpacing: 12
                    Layout.fillWidth: true
                    Layout.bottomMargin: 14

                    Label {
                        text: qsTr("Kategorie-ID")
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    TextField {
                        id: pfCatId
                        placeholderText: qsTr("optional")
                        Layout.preferredWidth: 140
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 999999999 }
                    }

                    Label {
                        text: qsTr("Lieferanten-ID")
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    TextField {
                        id: pfSuppId
                        placeholderText: qsTr("optional")
                        Layout.preferredWidth: 140
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 999999999 }
                    }
                }

                // ── Sektion: Weitere Angaben ─────────────────────────────
                Label {
                    text: qsTr("Weitere Angaben")
                    font.bold: true; font.pixelSize: 12
                    color: "#C62828"
                }
                Rectangle {
                    Layout.fillWidth: true; height: 1
                    color: "#FFCDD2"; Layout.bottomMargin: 10
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 16; rowSpacing: 12
                    Layout.fillWidth: true

                    Label {
                        text: qsTr("Beschreibung")
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignTop
                        topPadding: 8
                    }
                    TextArea {
                        id: pfDesc
                        placeholderText: qsTr("Freitext, max. 500 Zeichen")
                        wrapMode: TextArea.Wrap
                        Layout.fillWidth: true
                        Layout.preferredHeight: 88
                    }

                    Label {
                        text: qsTr("Aktiv")
                        Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter
                    }
                    CheckBox {
                        id: pfActive
                        checked: true
                        text: pfActive.checked ? qsTr("Ja") : qsTr("Nein")
                    }
                }
            }
        }

        // ── Fußleiste: Buttons + Resize-Griff ───────────────────────
        footer: Item {
            height: 64

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 32
                anchors.topMargin: 10
                anchors.bottomMargin: 14
                spacing: 8

                Item { Layout.fillWidth: true }

                Button {
                    text: productDialog.editId < 0 ? qsTr("Anlegen") : qsTr("Speichern")
                    highlighted: true
                    enabled: pfNumber.text !== "" && pfName.text !== "" && pfSales.text !== ""
                    onClicked: productDialog.accept()
                }
                Button {
                    text: qsTr("Abbrechen")
                    onClicked: productDialog.reject()
                }
            }

            // Resize-Griff — rechte untere Ecke des Dialogs
            Item {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: 22; height: 22

                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.strokeStyle = "#BDBDBD"
                        ctx.lineWidth = 1.5
                        ctx.lineCap = "round"
                        for (var i = 0; i < 3; i++) {
                            var o = i * 5 + 4
                            ctx.beginPath()
                            ctx.moveTo(width - o, height - 2)
                            ctx.lineTo(width - 2, height - o)
                            ctx.stroke()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeFDiagCursor
                    property real startX: 0
                    property real startY: 0

                    onPressed: function(mouse) {
                        startX = mouse.x
                        startY = mouse.y
                    }
                    onPositionChanged: function(mouse) {
                        if (pressed) {
                            productDialog.width  = Math.max(480, productDialog.width  + mouse.x - startX)
                            productDialog.height = Math.max(360, productDialog.height + mouse.y - startY)
                        }
                    }
                }
            }
        }

        onAccepted: saveProduct()
    }

    // ===== PRODUKT LÖSCH-BESTÄTIGUNG =====
    Dialog {
        id: productDeleteDialog
        title: qsTr("Produkt löschen?")
        modal: true
        anchors.centerIn: parent
        width: 420

        Label {
            text: selectedProductData
                  ? qsTr("Möchten Sie folgendes Produkt wirklich löschen?\n\n")
                    + selectedProductData.product_number + " — " + selectedProductData.name
                  : ""
            wrapMode: Text.WordWrap
            width: parent.width
        }

        footer: DialogButtonBox {
            Button {
                text: qsTr("Löschen")
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                background: Rectangle {
                    color: parent.pressed ? "#C62828" : (parent.hovered ? "#EF5350" : "#F44336")
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text; font: parent.font; color: "white"
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                text: qsTr("Abbrechen")
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }
        }

        onAccepted: deleteProduct(selectedProductId)
    }

    // ===== JAVASCRIPT FUNKTIONEN =====

    function performLogin() {
        var user = loginUserField.text;
        var pass = loginPasswordField.text;
        loginErrorText.text = "";

        var xhr = new XMLHttpRequest();
        xhr.open("POST", apiBaseUrl + "/api/login");
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        authToken = response.token;
                        authUser = response.username;
                        outputText = "✓ " + qsTr("Angemeldet als: ") + authUser;
                        loginDialog.close();
                        // Nach Login Daten laden
                        loadGreeting("de");
                        loadTables();
                    } catch (e) {
                        loginErrorText.text = qsTr("Serverfehler beim Login");
                    }
                } else if (xhr.status === 401) {
                    loginErrorText.text = qsTr("Ungültige Anmeldedaten");
                    loginPasswordField.text = "";
                    loginPasswordField.forceActiveFocus();
                } else {
                    loginErrorText.text = qsTr("Verbindungsfehler: ") + xhr.status;
                }
            }
        };

        xhr.send(JSON.stringify({ username: user, password: pass }));
    }

    function updateDateOutput() {
        var d = String(dayBox.value).padStart(2, '0');
        var m = String(monthBox.value).padStart(2, '0');
        var y = yearBox.value;
        dateDisplay.text = d + "." + m + "." + y;
        outputText = qsTr("Datum: ") + dateDisplay.text;
    }

    function updateTimeOutput() {
        var h = String(hourBox.value).padStart(2, '0');
        var min = String(minuteBox.value).padStart(2, '0');
        var s = String(secondBox.value).padStart(2, '0');
        timeDisplay.text = h + ":" + min + ":" + s;
        outputText = qsTr("Zeit: ") + timeDisplay.text;
    }

    // DB-Browser State
    property var dbTables: []
    property string selectedTable: ""
    property var tableColumns: []
    property var tableRows: []

    // Helper: Auth-Header setzen
    function setAuthHeader(xhr) {
        if (authToken !== "") {
            xhr.setRequestHeader("Authorization", "Bearer " + authToken);
        }
    }

    // Helper: 401-Handling (Token abgelaufen)
    function handleAuthError(xhr) {
        if (xhr.status === 401) {
            authToken = "";
            authUser = "";
            outputText = "✗ " + qsTr("Sitzung abgelaufen — bitte erneut anmelden");
            loginErrorText.text = qsTr("Sitzung abgelaufen");
            loginDialog.open();
            return true;
        }
        return false;
    }

    function loadGreeting(language) {
        if (!language) language = "de";
        if (!isLoggedIn) return;

        greetingText.text = qsTr("Lade...");
        statusText.text = qsTr("Verbinde mit Backend...");
        outputText = qsTr("Lade Greeting (Sprache: ") + language + ")...";

        var xhr = new XMLHttpRequest();
        xhr.open("GET", apiBaseUrl + "/api/greeting?lang=" + language);
        setAuthHeader(xhr);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (handleAuthError(xhr)) return;
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        greetingText.text = response.message;
                        statusText.text = qsTr("Geladen: ") + response.timestamp;
                        outputText = "✓ Greeting: " + response.message;
                    } catch (e) {
                        greetingText.text = qsTr("Fehler beim Parsen");
                        outputText = "✗ JSON Parse Fehler: " + e;
                    }
                } else {
                    greetingText.text = qsTr("Fehler: ") + xhr.status;
                    statusText.text = qsTr("Backend nicht erreichbar");
                    outputText = "✗ Backend Fehler: HTTP " + xhr.status;
                }
            }
        };

        xhr.send();
    }

    function loadTables() {
        if (!isLoggedIn) return;

        var xhr = new XMLHttpRequest();
        xhr.open("GET", apiBaseUrl + "/api/tables");
        setAuthHeader(xhr);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (handleAuthError(xhr)) return;
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    dbTables = response.tables;
                    outputText = "✓ " + dbTables.length + " Tabellen geladen";
                    if (dbTables.length > 0 && selectedTable === "") {
                        loadTableData(dbTables[0]);
                    }
                }
            }
        };
        xhr.send();
    }

    function loadTableData(tableName) {
        if (!isLoggedIn) return;
        selectedTable = tableName;
        tableRows = [];
        tableColumns = [];

        var xhr = new XMLHttpRequest();
        xhr.open("GET", apiBaseUrl + "/api/table?name=" + tableName);
        setAuthHeader(xhr);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (handleAuthError(xhr)) return;
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    tableColumns = response.columns;
                    tableRows = response.rows;
                    tableModel.clear();
                    for (var i = 0; i < response.rows.length; i++) {
                        tableModel.append({ rowData: JSON.stringify(response.rows[i]), rowIndex: i });
                    }
                    outputText = "✓ " + tableName + ": " + response.rowCount + " Zeilen";
                }
            }
        };
        xhr.send();
    }

    function shutdownServer() {
        if (!isLoggedIn) return;
        statusText.text = qsTr("Sende Shutdown-Befehl...");
        outputText = qsTr("Sende Shutdown-Befehl an Backend...");

        var xhr = new XMLHttpRequest();
        xhr.open("POST", apiBaseUrl + "/api/shutdown");
        setAuthHeader(xhr);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (handleAuthError(xhr)) return;
                if (xhr.status === 200) {
                    greetingText.text = qsTr("Server wird beendet");
                    statusText.text = qsTr("Shutdown erfolgreich");
                    outputText = "✓ Backend wird beendet...";
                } else {
                    statusText.text = qsTr("Shutdown-Fehler: ") + xhr.status;
                    outputText = "✗ Shutdown fehlgeschlagen: HTTP " + xhr.status;
                }
            }
        };

        xhr.send();
    }

    // ===== PRODUKTE STATE =====
    property var productData: []
    property int selectedProductId: -1
    property var selectedProductData: null

    // ===== PRODUKTE FUNKTIONEN =====

    function loadProducts() {
        if (!isLoggedIn) return
        outputText = qsTr("Lade Produkte...")

        var xhr = new XMLHttpRequest()
        xhr.open("GET", apiBaseUrl + "/api/products")
        setAuthHeader(xhr)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (handleAuthError(xhr)) return
            if (xhr.status === 200) {
                var resp = JSON.parse(xhr.responseText)
                productData = resp.products
                productModel.clear()
                for (var i = 0; i < resp.products.length; i++) {
                    productModel.append({ rowJson: JSON.stringify(resp.products[i]) })
                }
                selectedProductId   = -1
                selectedProductData = null
                outputText = "✓ " + resp.count + qsTr(" Produkte geladen")
            } else {
                outputText = "✗ Produkte laden fehlgeschlagen: HTTP " + xhr.status
            }
        }
        xhr.send()
    }

    function saveProduct() {
        if (!isLoggedIn) return

        var salesText = pfSales.text.replace(",", ".")
        var purchText = pfPurchase.text.replace(",", ".")

        var payload = {
            product_number: pfNumber.text,
            gtin:           pfGtin.text === "" ? null : parseInt(pfGtin.text),
            name:           pfName.text,
            unit:           pfUnit.currentText,
            purchase_price: purchText === "" ? null : parseFloat(purchText),
            sales_price:    parseFloat(salesText),
            vat_code:       pfVat.currentIndex === 0 ? 1 : 2,
            category_id:    pfCatId.text === "" ? null : parseInt(pfCatId.text),
            supplier_id:    pfSuppId.text === "" ? null : parseInt(pfSuppId.text),
            description:    pfDesc.text === "" ? null : pfDesc.text,
            active:         pfActive.checked ? 1 : 0
        }

        var isNew = productDialog.editId < 0
        var method = isNew ? "POST" : "PUT"
        var url    = apiBaseUrl + "/api/products" + (isNew ? "" : "/" + productDialog.editId)

        var xhr = new XMLHttpRequest()
        xhr.open(method, url)
        xhr.setRequestHeader("Content-Type", "application/json")
        setAuthHeader(xhr)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (handleAuthError(xhr)) return
            if (xhr.status === 200 || xhr.status === 201) {
                outputText = isNew ? "✓ Produkt angelegt" : "✓ Produkt aktualisiert"
                loadProducts()
            } else {
                try {
                    var err = JSON.parse(xhr.responseText)
                    pfError.text = err.message || qsTr("Unbekannter Fehler")
                } catch(e) {
                    pfError.text = "HTTP " + xhr.status
                }
                productDialog.open()
            }
        }
        xhr.send(JSON.stringify(payload))
    }

    function deleteProduct(productId) {
        if (!isLoggedIn || productId < 0) return
        outputText = qsTr("Lösche Produkt ID ") + productId + "..."

        var xhr = new XMLHttpRequest()
        xhr.open("DELETE", apiBaseUrl + "/api/products/" + productId)
        setAuthHeader(xhr)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (handleAuthError(xhr)) return
            if (xhr.status === 200) {
                outputText = "✓ Produkt gelöscht"
                selectedProductId   = -1
                selectedProductData = null
                loadProducts()
            } else {
                outputText = "✗ Löschen fehlgeschlagen: HTTP " + xhr.status
            }
        }
        xhr.send()
    }

    // ListModel für DB-Tabelle
    ListModel {
        id: tableModel
    }

    // ListModel für Produkte
    ListModel {
        id: productModel
    }

    // Beim Start Login-Dialog öffnen
    Component.onCompleted: {
        loginDialog.open();
        loginUserField.forceActiveFocus();
    }
}
