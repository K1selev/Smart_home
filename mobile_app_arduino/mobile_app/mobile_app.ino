
#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <UniversalTelegramBot.h>
#include <ESP8266WebServer.h>
#include <time.h>
#include <ArduinoJson.h> 

const char* ap_ssid = "SmartHomeESP8266"; // Название точки доступа
const char* ap_password = "12345678";     // Можно оставить "" для открытой сети

#define BOTtoken ""

WiFiClientSecure client;
UniversalTelegramBot bot(BOTtoken, client);
ESP8266WebServer server(80);

String keyboardJson = "[[\"Light on\", \"Light off\", \"Get info\", \"Open door\"]]";

void handleNewMessages(int numNewMessages);
void handleWebRequests();
void sendCommandToArduino(String cmd);

void setup() {
  Serial.begin(9600);

  // Запускаем точку доступа
  WiFi.softAP(ap_ssid, ap_password);
  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(IP);

  client.setInsecure();
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");

  server.on("/", []() {
    server.send(200, "text/html", R"rawliteral(
      <!DOCTYPE html><html><head><meta charset="UTF-8"><title>Smart Home</title></head><body>
      <h1>Smart Home Control</h1>
      <button onclick="fetch('/cmd?act=on')">Light ON</button>
      <button onclick="fetch('/cmd?act=off')">Light OFF</button>
      <button onclick="fetch('/cmd?act=info')">Get Info</button>
      <button onclick="fetch('/cmd?act=door')">Open Door</button>
      </body></html>
    )rawliteral");
  });

  server.on("/cmd", []() {
    if (!server.hasArg("act")) return server.send(400, "text/plain", "Bad Request");
    String act = server.arg("act");
    String cmd = "";

    if (act == "on") cmd = "turnOn";
    else if (act == "off") cmd = "turnOff";
    else if (act == "info") cmd = "getInfo";
    else if (act == "door") cmd = "openDoor";
    else return server.send(400, "text/plain", "Invalid Command");

    sendCommandToArduino(cmd);

    if (cmd == "getInfo") {
      delay(500);
      String info = "";
      unsigned long timeout = millis() + 2000;
      while (Serial.available() == 0 && millis() < timeout);
      while (Serial.available()) info += Serial.readString();
      if (info.length() > 0)
        server.send(200, "text/plain", info);
      else
        server.send(200, "text/plain", "No response from Arduino");
    } else {
      server.send(200, "text/plain", "OK");
    }
  });

  server.on("/setLight", []() {
    if (!server.hasArg("on") || !server.hasArg("r") || !server.hasArg("g") || !server.hasArg("b") || !server.hasArg("brightness")) {
      server.send(400, "text/plain", "Missing args");
      return;
    }

    String cmd = "rgb:";
    cmd += server.arg("on") + ",";
    cmd += server.arg("r") + ",";
    cmd += server.arg("g") + ",";
    cmd += server.arg("b") + ",";
    cmd += server.arg("brightness");

    sendCommandToArduino(cmd);
    server.send(200, "text/plain", "OK");
  });

  server.on("/sensors", []() {
    sendCommandToArduino("getSensors");
    unsigned long t0 = millis();
    String payload;
    while (millis() - t0 < 3000) {
      if (Serial.available()) {
        payload += Serial.readStringUntil('\n');
      }
    }
    if (payload.length() == 0) {
      server.send(500, "text/plain", "No data");
    } else {
      server.send(200, "application/json", payload);
    }
  });

  server.on("/open", []() {
    sendCommandToArduino("openDoor");
    server.send(200, "text/plain", "Открыта");
  });

  server.on("/close", []() {
    sendCommandToArduino("closeDoor");
    server.send(200, "text/plain", "Закрыта");
  });

  server.on("/doorState", []() {
    sendCommandToArduino("getDoorState");

    String state = "";
    unsigned long timeout = millis() + 2000;
    while (Serial.available() == 0 && millis() < timeout);
    while (Serial.available()) state += Serial.readStringUntil('\n');

    state.trim();
    if (state == "") state = "Неизвестно";

    server.send(200, "text/plain", state);
  });

  server.on("/ping", []() {
    server.send(200, "text/plain", "ok");
  });

  server.begin();
}

void loop() {
  server.handleClient();

  int numNewMessages = bot.getUpdates(bot.last_message_received + 1);
  if (numNewMessages) handleNewMessages(numNewMessages);

  delay(1000);
}

void handleNewMessages(int numNewMessages) {
  for (int i = 0; i < numNewMessages; i++) {
    String chat_id = String(bot.messages[i].chat_id);
    String text = bot.messages[i].text;

    if (text == "Light on") {
      sendCommandToArduino("turnOn");
      bot.sendMessage(chat_id, "LED is ON", "");
    } else if (text == "Light off") {
      sendCommandToArduino("turnOff");
      bot.sendMessage(chat_id, "LED is OFF", "");
    } else if (text == "Open door") {
      sendCommandToArduino("openDoor");
      bot.sendMessage(chat_id, "Door opened", "");
    } else if (text == "Get info") {
      sendCommandToArduino("getInfo");
      delay(500);
      String info = "";
      unsigned long timeout = millis() + 2000;
      while (Serial.available() == 0 && millis() < timeout);
      while (Serial.available()) info += Serial.readString();
      if (info.length() > 0)
        bot.sendMessage(chat_id, info, "");
      else
        bot.sendMessage(chat_id, "No response from Arduino.", "");
    } else if (text == "/start") {
      bot.sendMessageWithReplyKeyboard(chat_id, "Choose an option:", "", keyboardJson, true);
    }
  }
}

void sendCommandToArduino(String cmd) {
  Serial.println(cmd);
}

// ESP8266




// // Arduino
#include <SoftwareSerial.h>
#include <ArduinoJson.h>  
#include "LiquidCrystal_I2C.h"
#include "DHT.h"
#include <Arduino.h>
#include <Wire.h>
#include <Servo.h>

#define REL_PIN 6  // Пин, к которому подключен светодиод (или реле)


float potentiometer = 0;
float lighting_level = 0;
float night_light = 0;
float soil_moisture = 0;
float water_level = 0;
float room_temperature = 0;
float air_humidity = 0;
float rangefinder = 0;
float gas_smoke_detector = 0;
float presence_of_fire = 0;
float X_axis_joystick = 0;
float Y_axis_joystick = 0;

bool isDoorOpen = false;

SoftwareSerial esp(8, 10);  // RX, TX

LiquidCrystal_I2C lcd(0x27,20,4);  // set the LCD address to 0x27 for a 16 chars and 2 line display
Servo servo_13;
DHT dht(2, DHT11);

float getDistance(int trig,int echo){
    pinMode(trig,OUTPUT);
    digitalWrite(trig,LOW);
    delayMicroseconds(2);
    digitalWrite(trig,HIGH);
    delayMicroseconds(10);
    digitalWrite(trig,LOW);
    pinMode(echo, INPUT);
    return pulseIn(echo,HIGH,30000)/58.0;
}

void _delay(float seconds) {
  long endTime = millis() + seconds * 1000;
  while(millis() < endTime) _loop();
}

void setup() {
  Serial.begin(9600);
  esp.begin(9600); 
  pinMode(REL_PIN, OUTPUT);
  digitalWrite(REL_PIN, LOW);
  Serial.println("Arduino is ready");


  lcd.init();
  lcd.init();
  servo_13.attach(13);
  pinMode(7,INPUT_PULLUP);
  lcd.init();
  lcd.backlight();
  dht.begin();
  pinMode(A0+2,INPUT);
  pinMode(A0+3,INPUT);
  pinMode(9,OUTPUT);
  pinMode(12,OUTPUT);
  pinMode(8,INPUT_PULLUP);
  lcd.clear();
  lcd.setBacklight(0);
  servo_13.write(0);
}

void _loop() {
}

void loop() {
  int lightSensorValue = analogRead(A0);
  bool allowLight = lightSensorValue < 700;

    String command = esp.readStringUntil('\n');
    String str = esp.readString();
    command.trim();

    Serial.println("command");
    Serial.println(command);

    if (command.startsWith("rgb:")) { // rgb:1,255,100,50,0.8
      command = command.substring(4); // delete "rgb:"
      int on = command.substring(0, command.indexOf(',')).toInt();
      command = command.substring(command.indexOf(',') + 1);

      int r = command.substring(0, command.indexOf(',')).toInt();
      command = command.substring(command.indexOf(',') + 1);

      int g = command.substring(0, command.indexOf(',')).toInt();
      command = command.substring(command.indexOf(',') + 1);

      int b = command.substring(0, command.indexOf(',')).toInt();
      command = command.substring(command.indexOf(',') + 1);

      float brightness = command.toFloat();
      if (on) {
        analogWrite(5, int(r * brightness));  // R (Pin ~5)
        analogWrite(9, int(g * brightness));  // G (Pin ~9)
        analogWrite(11, int(b * brightness)); // B (Pin ~11)
        esp.println("RGB включен");
      } else {
        analogWrite(5, 0);
        analogWrite(9, 0);
        analogWrite(11, 0);
        esp.println("RGB выключен");
      }
    }

    else if (command == "getSensors") {
      int lightVal = analogRead(A0);
      int gasVal   = analogRead(A2);
      int fireVal  = analogRead(A3);
      float temp   = dht.readTemperature();
      float hum    = dht.readHumidity();

      StaticJsonDocument<200> doc;
      doc["light"]       = lightVal;
      doc["temperature"] = temp;
      doc["humidity"]    = hum;
      doc["gas"]         = gasVal;
      doc["fire"]        = fireVal;

      String out;
      serializeJson(doc, out);
      esp.println(out);
    }

    else if (command == "turnOn") {
      esp.println("LED ON");
      delay(100);
      digitalWrite(REL_PIN, HIGH);
    } 
    else if (command == "turnOff") {
      esp.println("LED OFF");
      delay(100);
      digitalWrite(REL_PIN, LOW);
    } 
    else if (command == "openDoor") {
      esp.println("Open Door");
      servo_13.write(240);
      _delay(1);
    } 

    else if (command == "closeDoor") {
      esp.println("Close Door");
      servo_13.write(0);
      _delay(1);
    } 

    else if (command == "getInfo") {
      room_temperature = dht.readTemperature();
      air_humidity = dht.readHumidity();
      gas_smoke_detector = analogRead(A0+2);
      presence_of_fire = analogRead(A0+3);
      
      String info = "";
      info += "Temp: " + String(room_temperature) + "C \n";
      info += "Hum: " + String(air_humidity) + "% \n";
      info += "Detector: " + String(gas_smoke_detector) + " \n";
      info += "Fire: " + String(presence_of_fire) + " \n";
      
      // esp.println(info);  // отправляем обратно на ESP
      esp.println("Temp: " + String(room_temperature) + " C");
      esp.println("Hum: " + String(air_humidity) + " %");
      esp.println("Detector: " + String(gas_smoke_detector));
      esp.println("Fire: " + String(presence_of_fire));
    }
    // else if (command == "getDoorState") {
    //   rangefinder = getDistance(4, 3);
    //   if (rangefinder < 5) {
    //     isDoorOpen = true;
    //     esp.println("Открыта");
    //   } else {
    //     isDoorOpen = false;
    //     esp.println("Закрыта");
    // }
    // else if (command == "toggleDoor") {
    // if (isDoorOpen) {
    //   servo_13.write(0);  // Закрыть
    //   _delay(1);
    //   isDoorOpen = false;
    //   esp.println("Закрыта");
    // } else {
    //   servo_13.write(240);  // Открыть
    //   _delay(1);
    //   isDoorOpen = true;
    //   esp.println("Открыта");
    // }
  // } 
// }

    else {
      // esp.println("Unknown command: " + command);
    }

    if((digitalRead(7) != LOW)){
        lcd.setBacklight(1);
        lcd.setCursor(0,0);
        lcd.print("Welcome to");
        lcd.setCursor(0,1);
        lcd.print("Smart Home");
        _delay(0.5);
        room_temperature = (0 == 0 ? dht.readTemperature() : dht.readHumidity());
        air_humidity = (1 == 0 ? dht.readTemperature() : dht.readHumidity());
        gas_smoke_detector = analogRead(A0+2);
        presence_of_fire = analogRead(A0+3);
        lcd.setCursor(0,0);
        lcd.print(String("Temp: ") + String(room_temperature));
        lcd.setCursor(0,1);
        lcd.print(String("Hum: ") + String(air_humidity));
        _delay(2);
        lcd.clear();
        lcd.setCursor(0,0);
        lcd.print(String("Detector: ") + String(gas_smoke_detector));
        lcd.setCursor(0,1);
        lcd.print(String("Fire: ") + String(presence_of_fire));
        if(presence_of_fire > 100){
          digitalWrite(9,1);
          tone(12,262,5*1000);
          delay(5*1000);
          digitalWrite(9,0);

        }
        _delay(2);
        lcd.clear();
        lcd.setBacklight(0);

      }
      rangefinder = getDistance(4,3);
      _delay(0.2);
      lcd.clear();
      if(rangefinder < 5){
        isDoorOpen = true;
        servo_13.write(240);
        _delay(1);
        servo_13.write(0);

      }
      // if(rangefinder > 5){
      //   isDoorOpen = false;
      //   servo_13.write(0);
      // }

      if((digitalRead(8) == LOW)){
        lcd.clear();
        lcd.setCursor(0,0);
        lcd.print("Welcome to");
        lcd.setCursor(0,1);
        lcd.print("Smart Home");
        _delay(1);

      }
}