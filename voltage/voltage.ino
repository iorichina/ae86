#include <Wire.h>

int val11;
int val2;

void setup() {
  // pinMode(LED1, OUTPUT);
  //pinMode(6, INPUT);
  Serial.begin(115200);
  Serial.println("voltage detection start");
}

void loop() {
  Serial.println("--------");
  float temp;
  val11 = analogRead(35);//ADC7==GPIO35==NODEMCU-32.P35
  Serial.println(val11);
  temp = val11/4.092;
  val11=(int)temp;
  val2=((val11%100)/10);
  Serial.println(val2);
  delay(5000);
}
