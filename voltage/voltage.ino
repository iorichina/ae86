#include <Wire.h>

int val11;
int val2;

void setup() {
  pinMode(LED1, OUTPUT);
  Serial.begin(115200);
  Serial.pritln("voltage detection start")
}

void loop() {
  float temp;
  val11 = analogRead(1);
  temp = val11/4.092;
  val11=(int)temp;
  val2=((val11%100)/10);
  Serial.println(val2);
  delay(5000);
}
