void setup() {
    Serial.begin(9600);
    pinMode(9, OUTPUT);
    pinMode(8, OUTPUT);
    pinMode(7, OUTPUT);
    pinMode(6, OUTPUT);
}

void loop() {
    if (Serial.available() > 0) {
        String command = Serial.readStringUntil('\n');
        command.trim();

        Serial.print("Command received: ");
        Serial.println(command);

        if (command == "START_OPEN" || command == "HOLD_OPEN" || command == "OPEN_FULL") {
            Serial.println("Opening curtain...");
            digitalWrite(9, HIGH);
            digitalWrite(8, LOW);
            digitalWrite(6, HIGH);
            digitalWrite(7, LOW);
        }
        else if (command == "START_CLOSE" || command == "HOLD_CLOSE" || command == "CLOSE_FULL") {
            Serial.println("Closing curtain");
            digitalWrite(9, LOW);
            digitalWrite(8, HIGH);
            digitalWrite(6, LOW);
            digitalWrite(7, HIGH);
        }
        else if (command == "STOP" || command == "PAUSE") {
            Serial.println("Stopping curtain");
            digitalWrite(9, LOW);
            digitalWrite(8, LOW);
            digitalWrite(6, LOW);
            digitalWrite(7, LOW);
        }
    }
}