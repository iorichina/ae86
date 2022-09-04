// #include <Wire.h>

int val11;
int val2;

const int analogInPin = A7;        // 模拟输入引脚 35
const int LED_PIN = 2;//LED_BUILTIN; // led连接到pwm输出引脚 2

int sensorValue = 0; // 从引脚读到的值
int outputValue = 0; //输出到pwm脚的值

void setup()
{
  // 设置引脚为模拟输入模式
  // pinMode(analogInPin, INPUT);
  // 设置led脚输出pwm模式
  pinMode(LED_PIN, OUTPUT);

  pinMode(LED_PIN, OUTPUT);    //配置GPIO2端口模式为输出模式
  digitalWrite(LED_PIN, HIGH); //配置GPIO2端口为高电平，灯亮

  Serial.begin(115200);
  Serial.println("voltage detection start");
}

void loop()
{
  Serial.println("--------");
  //读取模拟输入数值
  sensorValue = analogRead(analogInPin);
  // 使用map函数把输入的数值进行映射
  // outputValue = map(sensorValue, 0, 4095, 0, 330);//可以修改数值映射330   3.3V
  // 改变模拟输出数值
  // analogWrite(LED_PIN, outputValue);
  // Serial.println((float)outputValue / 100.00); //保留两位小数
  // 在串口打印显示输入输出的数值
  Serial.print("sensor = ");
  Serial.print(sensorValue);
  // Serial.print("\t output = ");
  // Serial.println(outputValue);

  // float temp;
  // val11 = analogRead(analogInPin); // ADC7==GPIO35==NODEMCU-32.P35
  // Serial.println(val11);
  // temp = val11 / 4.092;
  // val11 = (int)temp;
  // val2 = ((val11 % 100) / 10);
  // Serial.println(val2);
  delay(5000);

  digitalWrite(LED_PIN, digitalRead(LED_PIN) ^ HIGH); //配置GPIO2端口为高电平，灯亮
}
