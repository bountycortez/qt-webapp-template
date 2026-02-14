# QML GUI Elements - Vollständige Demo

Diese Applikation demonstriert alle wichtigen QML GUI-Elemente mit praktischen Beispielen.

## Übersicht der 5 Tabs

### Tab 1: Basics (Grundelemente)

#### Buttons
```qml
// Standard Button
Button {
    text: "Click me"
    onClicked: { /* Aktion */ }
}

// Flat Button (ohne Hintergrund)
Button {
    text: "Flat"
    flat: true
}

// Highlighted Button (hervorgehoben)
Button {
    text: "Important"
    highlighted: true
}

// Round Button (kreisförmig)
RoundButton {
    text: "+"
}

// Tool Button (für Toolbars)
ToolButton {
    text: "Tool"
}

// Delay Button (muss gehalten werden)
DelayButton {
    text: "Hold Me"
    delay: 2000  // 2 Sekunden
    onActivated: { /* Nach Delay */ }
}
```

#### CheckBox & RadioButton
```qml
// Standard CheckBox
CheckBox {
    text: "Option"
    checked: true
    onCheckedChanged: { /* Aktion */ }
}

// Tristate CheckBox
CheckBox {
    text: "Partial"
    checkState: Qt.PartiallyChecked
    tristate: true
}

// Radio Buttons (gruppiert)
ButtonGroup { id: radioGroup }

RadioButton {
    text: "Option A"
    ButtonGroup.group: radioGroup
}
RadioButton {
    text: "Option B"
    ButtonGroup.group: radioGroup
}
```

#### Switch & Slider
```qml
// Switch (An/Aus)
Switch {
    text: "Enable Feature"
    checked: false
    onCheckedChanged: { /* Aktion */ }
}

// Slider (Wertebereich)
Slider {
    from: 0
    to: 100
    value: 50
    onValueChanged: { /* Aktion */ }
}

// RangeSlider (Min/Max Bereich)
RangeSlider {
    from: 0
    to: 100
    first.value: 25
    second.value: 75
}
```

---

### Tab 2: Input (Eingabefelder)

#### TextField
```qml
// Standard Text Input
TextField {
    placeholderText: "Name eingeben..."
    onTextChanged: { /* Aktion */ }
}

// Passwort-Feld
TextField {
    placeholderText: "Passwort..."
    echoMode: TextInput.Password
}

// Integer (0-100) mit IntValidator
TextField {
    placeholderText: "0-100"
    validator: IntValidator { bottom: 0; top: 100 }
}

// Double (max 2 Dezimalstellen) mit RegularExpressionValidator
TextField {
    placeholderText: "0,00"
    validator: RegularExpressionValidator {
        regularExpression: /^\d{0,4}([.,]\d{0,2})?$/
    }
}
```

#### SpinBox
```qml
// Integer SpinBox
SpinBox {
    from: 0
    to: 100
    value: 42
    onValueChanged: { /* Aktion */ }
}

// Double SpinBox (Dezimalzahlen)
SpinBox {
    from: 0
    to: 1000
    value: 314
    stepSize: 10

    property int decimals: 2
    property real realValue: value / 100

    textFromValue: function(value, locale) {
        return Number(value / 100).toLocaleString(locale, 'f', decimals)
    }
}
```

#### Dial mit Labels
```qml
// Rotary Input (0-360°) mit Grad-Labels
Item {
    Dial {
        from: 0; to: 360; value: 180
    }
    // Labels: 0° oben, 90° links, 180° unten, 270° rechts
}
```

#### Datum & Zeit (SpinBox-basiert)
```qml
// Datum: Tag.Monat.Jahr als drei SpinBoxes
SpinBox { from: 1; to: 31 }   // Tag
SpinBox { from: 1; to: 12 }   // Monat
SpinBox { from: 2020; to: 2099 } // Jahr

// Zeit: Stunde:Minute:Sekunde
SpinBox { from: 0; to: 23 }   // Stunde
SpinBox { from: 0; to: 59 }   // Minute
SpinBox { from: 0; to: 59 }   // Sekunde
```

#### Kalender-Widget
```qml
// Reines QML Kalender mit Monatsnavigation
// Klick auf Tag synchronisiert mit Datum-SpinBoxes
GridLayout {
    columns: 7
    // Mo Di Mi Do Fr Sa So + 42 Tageszellen
}
```

---

### Tab 3: Selection (Auswahl-Elemente)

#### ComboBox
```qml
// Standard DropDown
ComboBox {
    model: ["Option 1", "Option 2", "Option 3"]
    onCurrentTextChanged: { /* Aktion */ }
}

// Editierbare ComboBox
ComboBox {
    model: ["Deutschland", "Österreich", "Schweiz"]
    editable: true
    onAccepted: { /* editText */ }
}
```

#### Tumbler
```qml
// Roller-Auswahl (wie iOS Picker)
Tumbler {
    model: 24  // 0-23 Stunden
}
```

#### ListView
```qml
ListView {
    model: ListModel {
        ListElement { name: "Item 1"; price: 10.50 }
        ListElement { name: "Item 2"; price: 20.00 }
    }
    
    delegate: ItemDelegate {
        text: name + " - €" + price
        onClicked: { /* Aktion */ }
    }
    
    ScrollBar.vertical: ScrollBar {}
}
```

---

### Tab 4: Display (Anzeige-Elemente)

#### ProgressBar
```qml
// Fortschrittsbalken
ProgressBar {
    from: 0
    to: 100
    value: 50  // 50%
}

// Indeterminate (unbestimmte Dauer)
ProgressBar {
    indeterminate: true
}
```

#### BusyIndicator
```qml
// Lade-Animation
BusyIndicator {
    running: true
}
```

#### Labels & Text
```qml
// Standard Label
Label {
    text: "Information"
}

// Mit Tooltip
Label {
    text: "Hover me"
    ToolTip.visible: mouseArea.containsMouse
    ToolTip.text: "Dies ist ein Tooltip"
}

// Formatierter Text
Label {
    text: "Fett & Groß"
    font.bold: true
    font.pixelSize: 20
    color: "#2196F3"
}
```

#### TabBar
```qml
TabBar {
    id: tabBar
    
    TabButton { text: "Tab 1" }
    TabButton { text: "Tab 2" }
    TabButton { text: "Tab 3" }
}

StackLayout {
    currentIndex: tabBar.currentIndex
    
    Item { /* Content 1 */ }
    Item { /* Content 2 */ }
    Item { /* Content 3 */ }
}
```

---

### Tab 5: Database (Backend-Integration)

#### Login & Authentifizierte API-Calls
```qml
// Auth State
property string authToken: ""
property bool isLoggedIn: authToken !== ""

// Login
function performLogin() {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", apiBaseUrl + "/api/login");
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
            var response = JSON.parse(xhr.responseText);
            authToken = response.token;
        }
    };
    xhr.send(JSON.stringify({ username: user, password: pass }));
}

// Auth-Header bei jedem API-Call
function setAuthHeader(xhr) {
    if (authToken !== "")
        xhr.setRequestHeader("Authorization", "Bearer " + authToken);
}

// Beispiel: Authentifizierter GET Request
function loadData() {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", apiBaseUrl + "/api/greeting");
    setAuthHeader(xhr);  // Token mitsenden
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 401) {
                // Token abgelaufen → Login-Dialog
                loginDialog.open();
            } else if (xhr.status === 200) {
                var response = JSON.parse(xhr.responseText);
            }
        }
    };
    xhr.send();
}
```

#### DB-Browser
```qml
// Tabellenliste laden → ListView links
// Tabelleninhalt laden → ListView rechts
// Doppelklick → Detail-Popup (readonly)
```

#### Dialog mit Custom Buttons
```qml
Dialog {
    id: confirmDialog
    title: "Bestätigung"
    modal: true

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

    onAccepted: { /* Ja geklickt */ }
}
```

---

## Layouts

### ColumnLayout (Vertikal)
```qml
ColumnLayout {
    spacing: 10
    
    Button { text: "Oben" }
    Button { text: "Mitte" }
    Button { text: "Unten" }
}
```

### RowLayout (Horizontal)
```qml
RowLayout {
    spacing: 10
    
    Button { text: "Links" }
    Button { text: "Mitte" }
    Button { text: "Rechts" }
}
```

### GridLayout (Raster)
```qml
GridLayout {
    columns: 2
    rowSpacing: 10
    columnSpacing: 20
    
    Label { text: "Name:" }
    TextField { }
    
    Label { text: "Email:" }
    TextField { }
}
```

---

## Styling & Farben

### Material Design Farbpalette
```qml
// Blau
"#2196F3"  // Primary
"#1976D2"  // Dark
"#E3F2FD"  // Light

// Grün
"#4CAF50"  // Success
"#388E3C"  // Dark

// Rot
"#F44336"  // Error
"#C62828"  // Dark

// Grau
"#666666"  // Text Secondary
"#999999"  // Disabled
"#E0E0E0"  // Borders
```

### Custom Button Styling
```qml
Button {
    text: "Custom"
    
    background: Rectangle {
        color: parent.pressed ? "#1976D2" : 
               parent.hovered ? "#42A5F5" : "#2196F3"
        radius: 8
    }
    
    contentItem: Text {
        text: parent.text
        color: "white"
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
```

---

## Best Practices

### 1. Property Bindings
```qml
// Automatische Updates
ProgressBar {
    value: slider.value  // Binding!
}

Slider {
    id: slider
    from: 0
    to: 100
}
```

### 2. Signal Handlers
```qml
TextField {
    // onChange Event
    onTextChanged: {
        console.log("Text:", text)
    }
    
    // Mehrere Aktionen
    onTextChanged: {
        validateInput(text)
        updateDisplay()
    }
}
```

### 3. JavaScript Funktionen
```qml
ApplicationWindow {
    // Globale Funktion
    function validateEmail(email) {
        var regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        return regex.test(email)
    }
    
    TextField {
        onTextChanged: {
            if (validateEmail(text)) {
                color = "green"
            }
        }
    }
}
```

### 4. States für komplexe UI
```qml
Rectangle {
    id: item
    state: "normal"
    
    states: [
        State {
            name: "highlighted"
            PropertyChanges { target: item; color: "yellow" }
        },
        State {
            name: "disabled"
            PropertyChanges { target: item; opacity: 0.5 }
        }
    ]
    
    transitions: Transition {
        PropertyAnimation { duration: 200 }
    }
}
```

---

## Tipps für Qt Widgets Entwickler

### Unterschiede QML vs. Widgets

| Widgets (C++) | QML (Deklarativ) |
|---------------|------------------|
| `QPushButton` | `Button` |
| `QLineEdit` | `TextField` |
| `QLabel` | `Label` |
| `QVBoxLayout` | `ColumnLayout` |
| `QHBoxLayout` | `RowLayout` |
| `QComboBox` | `ComboBox` |
| `QProgressBar` | `ProgressBar` |

### Denke deklarativ, nicht imperativ!

**Widgets-Stil (imperativ):**
```cpp
QPushButton *btn = new QPushButton("Click");
connect(btn, &QPushButton::clicked, [=]() {
    label->setText("Clicked!");
});
```

**QML-Stil (deklarativ):**
```qml
Button {
    text: "Click"
    onClicked: label.text = "Clicked!"
}

Label {
    id: label
}
```

---

## Weitere Ressourcen

- Qt QML Dokumentation: https://doc.qt.io/qt-6/qmlapplications.html
- Qt Quick Controls: https://doc.qt.io/qt-6/qtquickcontrols-index.html
- Qt Quick Layouts: https://doc.qt.io/qt-6/qtquicklayouts-index.html

## Nächste Schritte

1. Experimentieren Sie mit den GUI-Elementen
2. Passen Sie Farben und Styles an
3. Erstellen Sie eigene Components
4. Integrieren Sie weitere Backend-APIs
5. Bauen Sie Ihre eigene Applikation!
