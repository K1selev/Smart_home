
#include "inc/LiquidCrystal_I2C.h"
#include "inc/DHT.h"

#include <Arduino.h>
#include <Wire.h>
#include <SoftwareSerial.h>
#include <Servo.h>

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

LiquidCrystal_I2C lcd(0x27,20,4);  // set the LCD address to 0x27 for a 16 chars and 2 line display
Servo servo_13;
/*
Connect pin marked "S" to Pin 2
Connect Middle pin to +5V
Connect Pin marked "-" to GND
*/

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
  while(1) {
      if((digitalRead(7) == LOW)){

      }else{
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
        servo_13.write(240);
        _delay(1);

      }
      if(rangefinder > 5){
        servo_13.write(0);

      }
      if((digitalRead(8) == LOW)){
        lcd.clear();
        lcd.setCursor(0,0);
        lcd.print("Welcome to");
        lcd.setCursor(0,1);
        lcd.print("Smart Home");
        _delay(1);

      }

      _loop();
  }

}

void _loop() {
}

void loop() {
  _loop();
}
