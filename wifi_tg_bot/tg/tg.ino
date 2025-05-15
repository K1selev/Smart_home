// ESP8266
#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <UniversalTelegramBot.h>
#include <time.h>

const char* ssid = "";
const char* password = "";

#define BOTtoken ""

WiFiClientSecure client;
UniversalTelegramBot bot(BOTtoken, client);

String keyboardJson = "[[\"On\", \"Off\"]]";

void handleNewMessages(int numNewMessages);

void setup() {
  Serial.begin(9600);
  Serial.println("Start work...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println(WiFi.localIP());

  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  while (!time(nullptr)) {
    Serial.print("*");
    delay(1000);
  }

  client.setInsecure();  // или лучше установить fingerprint
}

void loop() {
  int numNewMessages = bot.getUpdates(bot.last_message_received + 1);
  handleNewMessages(numNewMessages);
  delay(1000);  // чтобы не спамить Telegram API
}

void handleNewMessages(int numNewMessages) {
  for (int i = 0; i < numNewMessages; i++) {
    String chat_id = String(bot.messages[i].chat_id);
    String text = bot.messages[i].text;

    if (text == "On") {
      Serial.println("turnOn\n");
      bot.sendMessage(chat_id, "LED is ON", "");
    }
    else if (text == "Off") {
      Serial.println("turnOff\n");
      bot.sendMessage(chat_id, "LED is OFF", "");
    }
    else if (text == "/start") {
      bot.sendMessageWithReplyKeyboard(chat_id, 
        "Choose an option:", "", keyboardJson, true);
    }
  }
}


// Arduino
// #include <SoftwareSerial.h>

// #define REL_PIN 3  // Пин, к которому подключен светодиод (или реле)

// SoftwareSerial esp(4, 5);  // RX, TX

// void setup() {
//   Serial.begin(9600);
//   esp.begin(9600);         // Запуск программного последовательного порта
//   pinMode(REL_PIN, OUTPUT);  // Настройка пина 3 как выход
//   digitalWrite(REL_PIN, LOW); // На всякий случай выключим по умолчанию
//   Serial.println("Arduino is ready");
// }

// void loop() {
//     String command = esp.readStringUntil('\n'); // Читаем строку до новой строки
//     String str = esp.readString();
//     command.trim(); // Удаляем пробелы и символы переноса
    
//     if (command == "turnOn") {
//       esp.println("LED ON");
//       delay(100);
//       digitalWrite(REL_PIN, HIGH);
//     } 
//     else if (command == "turnOff") {
//       esp.println("LED OFF");
//       delay(100);
//       digitalWrite(REL_PIN, LOW);
//     } 
//     else {
//       esp.println("Unknown command: " + command);
//     }
// }