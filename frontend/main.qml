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
                    model: ["Basics", "Input", "Selection", "Display", "Database"]
                    
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
                            spacing: 20
                            
                            // Text Input
                            GroupBox {
                                title: "Text Input"
                                Layout.fillWidth: true
                                
                                GridLayout {
                                    columns: 2
                                    columnSpacing: 20
                                    rowSpacing: 15
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
                                        Layout.preferredHeight: 100
                                        onTextChanged: outputText = "TextArea (" + text.length + " Zeichen): " + text.substring(0, 50)
                                    }
                                }
                            }
                            
                            // Numerische Eingabe + Datum/Zeit nebeneinander
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 15

                                // LINKS: Numerische Eingabe
                                GroupBox {
                                    title: qsTr("Numerische Eingabe")
                                    Layout.fillWidth: true

                                    GridLayout {
                                        columns: 3
                                        columnSpacing: 15
                                        rowSpacing: 12

                                        Label { text: "SpinBox:" }
                                        SpinBox {
                                            id: spinBox1
                                            from: 0; to: 100; value: 42
                                            onValueChanged: outputText = "SpinBox: " + value
                                        }
                                        Text { text: qsTr("Wert: ") + spinBox1.value; color: "#E57373" }

                                        Label { text: "Integer (0-100):" }
                                        TextField {
                                            id: intField
                                            placeholderText: "0 - 100"
                                            Layout.preferredWidth: 120
                                            validator: IntValidator { bottom: 0; top: 100 }
                                            inputMethodHints: Qt.ImhDigitsOnly
                                            onTextChanged: {
                                                if (text !== "") {
                                                    var v = parseInt(text);
                                                    if (v >= 0 && v <= 100) outputText = "Integer: " + v;
                                                }
                                            }
                                        }
                                        Text {
                                            text: intField.text !== "" ? (intField.acceptableInput ? "✓" : "✗ 0-100") : ""
                                            color: intField.acceptableInput ? "#4CAF50" : "#F44336"
                                            font.bold: true
                                        }

                                        Label { text: "Double (2 Dez.):" }
                                        TextField {
                                            id: doubleField
                                            placeholderText: "z.B. 3.14"
                                            Layout.preferredWidth: 120
                                            validator: RegularExpressionValidator {
                                                regularExpression: /^\d{0,4}([.,]\d{0,2})?$/
                                            }
                                            onTextChanged: {
                                                if (text !== "" && acceptableInput) outputText = "Double: " + text;
                                            }
                                        }
                                        Text {
                                            text: doubleField.text !== "" ? (doubleField.acceptableInput ? "✓ " + doubleField.text : "✗") : ""
                                            color: doubleField.acceptableInput ? "#4CAF50" : "#F44336"
                                            font.bold: true
                                        }

                                        Label { text: "Double SpinBox:" }
                                        SpinBox {
                                            id: doubleSpinBox
                                            from: 0; to: 1000; value: 314; stepSize: 10

                                            property int decimals: 2
                                            property real realValue: value / 100

                                            validator: DoubleValidator {
                                                bottom: Math.min(doubleSpinBox.from, doubleSpinBox.to)
                                                top: Math.max(doubleSpinBox.from, doubleSpinBox.to)
                                            }
                                            textFromValue: function(value, locale) {
                                                return Number(value / 100).toLocaleString(locale, 'f', doubleSpinBox.decimals)
                                            }
                                            valueFromText: function(text, locale) {
                                                return Number.fromLocaleString(locale, text) * 100
                                            }
                                            onValueChanged: outputText = "Double SpinBox: " + realValue.toFixed(2)
                                        }
                                        Text { text: "€ " + doubleSpinBox.realValue.toFixed(2); color: "#4CAF50"; font.bold: true }

                                        // Dial
                                        Label { text: "Dial:" }
                                        Item {
                                            Layout.preferredWidth: 180
                                            Layout.preferredHeight: 180

                                            Dial {
                                                id: dial1
                                                from: 0; to: 360; value: 180
                                                anchors.centerIn: parent
                                                width: 130; height: 130
                                                onValueChanged: outputText = "Dial: " + Math.round(value) + "°"
                                            }
                                            Text {
                                                anchors.centerIn: parent
                                                text: Math.round(dial1.value) + "°"
                                                font.pixelSize: 18; font.bold: true; color: "#C62828"
                                            }
                                            Text { text: "0°"; font.pixelSize: 10; color: "#999"; x: 10; y: 155 }
                                            Text { text: "360°"; font.pixelSize: 10; color: "#999"; x: 145; y: 155 }
                                            Text { text: "270°"; font.pixelSize: 10; color: "#999"; x: 160; y: 75 }
                                            Text { text: "180°"; font.pixelSize: 10; color: "#999"; x: 75; y: 0 }
                                            Text { text: "90°"; font.pixelSize: 10; color: "#999"; x: -5; y: 75 }
                                        }
                                        Item {}
                                    }
                                }

                                // RECHTS: Datum & Zeit
                                GroupBox {
                                    title: qsTr("Datum & Zeit")
                                    Layout.preferredWidth: 350
                                    Layout.fillHeight: true

                                    ColumnLayout {
                                        spacing: 12
                                        width: parent.width

                                        // Datum (SpinBox)
                                        RowLayout {
                                            spacing: 4
                                            Label { text: qsTr("Datum:"); font.bold: true; Layout.preferredWidth: 50 }
                                            SpinBox {
                                                id: dayBox
                                                from: 1; to: 31; value: new Date().getDate()
                                                editable: true; implicitWidth: 72
                                                onValueChanged: updateDateOutput()
                                            }
                                            Text { text: "."; font.pixelSize: 14; font.bold: true }
                                            SpinBox {
                                                id: monthBox
                                                from: 1; to: 12; value: new Date().getMonth() + 1
                                                editable: true; implicitWidth: 72
                                                onValueChanged: updateDateOutput()
                                            }
                                            Text { text: "."; font.pixelSize: 14; font.bold: true }
                                            SpinBox {
                                                id: yearBox
                                                from: 2000; to: 2099; value: new Date().getFullYear()
                                                editable: true; implicitWidth: 90
                                                onValueChanged: updateDateOutput()
                                            }
                                        }
                                        Text {
                                            id: dateDisplay; text: ""
                                            color: "#C62828"; font.bold: true; font.pixelSize: 13
                                            Layout.leftMargin: 55
                                        }

                                        // Trennlinie
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#e0e0e0" }

                                        // Zeit
                                        RowLayout {
                                            spacing: 4
                                            Label { text: qsTr("Zeit:"); font.bold: true; Layout.preferredWidth: 50 }
                                            SpinBox {
                                                id: hourBox
                                                from: 0; to: 23; value: new Date().getHours()
                                                editable: true; implicitWidth: 72
                                                onValueChanged: updateTimeOutput()
                                                textFromValue: function(value) { return String(value).padStart(2, '0'); }
                                            }
                                            Text { text: ":"; font.pixelSize: 16; font.bold: true }
                                            SpinBox {
                                                id: minuteBox
                                                from: 0; to: 59; value: new Date().getMinutes()
                                                editable: true; implicitWidth: 72
                                                onValueChanged: updateTimeOutput()
                                                textFromValue: function(value) { return String(value).padStart(2, '0'); }
                                            }
                                            Text { text: ":"; font.pixelSize: 16; font.bold: true }
                                            SpinBox {
                                                id: secondBox
                                                from: 0; to: 59; value: 0
                                                editable: true; implicitWidth: 72
                                                onValueChanged: updateTimeOutput()
                                                textFromValue: function(value) { return String(value).padStart(2, '0'); }
                                            }
                                        }
                                        Text {
                                            id: timeDisplay; text: ""
                                            color: "#C62828"; font.bold: true; font.pixelSize: 13
                                            Layout.leftMargin: 55
                                        }

                                        // Trennlinie
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#e0e0e0" }

                                        // Kalender-Widget
                                        Label { text: qsTr("Kalender:"); font.bold: true }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 220
                                            border.color: "#E57373"
                                            border.width: 1
                                            radius: 6
                                            color: "#FFFFFF"
                                            clip: true

                                            property int calYear: yearBox.value
                                            property int calMonth: monthBox.value - 1
                                            property int calDay: dayBox.value

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 6
                                                spacing: 4

                                                // Monat/Jahr Navigation
                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    Button {
                                                        text: "◀"
                                                        flat: true
                                                        implicitWidth: 30; implicitHeight: 28
                                                        onClicked: {
                                                            if (monthBox.value > 1) monthBox.value--;
                                                            else { monthBox.value = 12; yearBox.value--; }
                                                        }
                                                    }
                                                    Item { Layout.fillWidth: true }
                                                    Text {
                                                        text: ["", "Januar", "Februar", "März", "April", "Mai", "Juni",
                                                               "Juli", "August", "September", "Oktober", "November", "Dezember"][monthBox.value] + " " + yearBox.value
                                                        font.bold: true; font.pixelSize: 14; color: "#C62828"
                                                    }
                                                    Item { Layout.fillWidth: true }
                                                    Button {
                                                        text: "▶"
                                                        flat: true
                                                        implicitWidth: 30; implicitHeight: 28
                                                        onClicked: {
                                                            if (monthBox.value < 12) monthBox.value++;
                                                            else { monthBox.value = 1; yearBox.value++; }
                                                        }
                                                    }
                                                }

                                                // Wochentage Header
                                                Row {
                                                    Layout.fillWidth: true
                                                    Repeater {
                                                        model: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
                                                        Text {
                                                            width: (parent.width) / 7
                                                            text: modelData
                                                            font.pixelSize: 10; font.bold: true
                                                            color: "#999"
                                                            horizontalAlignment: Text.AlignHCenter
                                                        }
                                                    }
                                                }

                                                // Tage-Grid
                                                Grid {
                                                    id: calGrid
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    columns: 7

                                                    property int daysInMonth: new Date(yearBox.value, monthBox.value, 0).getDate()
                                                    property int firstDayOfWeek: (new Date(yearBox.value, monthBox.value - 1, 1).getDay() + 6) % 7

                                                    Repeater {
                                                        model: 42

                                                        Rectangle {
                                                            property int dayNum: index - calGrid.firstDayOfWeek + 1
                                                            property bool isValid: dayNum >= 1 && dayNum <= calGrid.daysInMonth
                                                            property bool isSelected: isValid && dayNum === dayBox.value

                                                            width: calGrid.width / 7
                                                            height: 24
                                                            radius: 12
                                                            color: isSelected ? "#C62828" : (calDayMouse.containsMouse && isValid ? "#FFEBEE" : "transparent")

                                                            Text {
                                                                anchors.centerIn: parent
                                                                text: isValid ? dayNum : ""
                                                                font.pixelSize: 12
                                                                font.bold: isSelected
                                                                color: isSelected ? "white" : "#424242"
                                                            }

                                                            MouseArea {
                                                                id: calDayMouse
                                                                anchors.fill: parent
                                                                hoverEnabled: true
                                                                onClicked: {
                                                                    if (isValid) {
                                                                        dayBox.value = dayNum;
                                                                        outputText = qsTr("Kalender: ") + dayNum + "." + monthBox.value + "." + yearBox.value;
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

    // ListModel für DB-Tabelle
    ListModel {
        id: tableModel
    }

    // Beim Start Login-Dialog öffnen
    Component.onCompleted: {
        loginDialog.open();
        loginUserField.forceActiveFocus();
    }
}
