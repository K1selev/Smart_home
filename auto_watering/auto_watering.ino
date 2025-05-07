#include "inc/LiquidCrystal_I2C.h"

#include <Arduino.h>
#include <Wire.h>
#include <SoftwareSerial.h>

float potentiometer = 0;
float lighting_level = 0;
float night_light = 0;
float soil_moisture = 0;
float water_level = 0;

LiquidCrystal_I2C lcd(0x27,20,4);  // set the LCD address to 0x27 for a 16 chars and 2 line display

void _delay(float seconds) {
  long endTime = millis() + seconds * 1000;
  while(millis() < endTime) _loop();
}

void setup() {
  lcd.init();
  lcd.init();
  lcd.init();
  lcd.backlight();
  pinMode(A0+1,INPUT);
  pinMode(A0+0,INPUT);
  pinMode(A0+3,INPUT);
  pinMode(A0+2,INPUT);
  pinMode(3,OUTPUT);
  pinMode(5,OUTPUT);
  pinMode(6,OUTPUT);
  lcd.clear();
  lcd.setBacklight(0);
  lcd.setCursor(0,0);
  lcd.print("Hello");
  _delay(1);
  while(1) {
      potentiometer = analogRead(A0+1);
      night_light = map(lighting_level, 0, 1023, 0, 255);
      lighting_level = analogRead(A0+0);
      soil_moisture = analogRead(A0+3);
      water_level = analogRead(A0+2);
      lcd.setCursor(0,0);
      lcd.print(String("SOIL:") + String(soil_moisture));
      lcd.setCursor(0,1);
      lcd.print(String("WATER:") + String(water_level));
      analogWrite(3,night_light);
      analogWrite(5,potentiometer / 4);
      digitalWrite(6,1);
      if(analogRead(A0+0) > 800){
        digitalWrite(3,1);

      }else{
        digitalWrite(3,0);

      }
      if(water_level > 50){
        digitalWrite(6,0);
        _delay(0.2);

      }
      _delay(0.2);
      lcd.clear();

      _loop();
  }

}

void _loop() {
}

void loop() {
  _loop();
}