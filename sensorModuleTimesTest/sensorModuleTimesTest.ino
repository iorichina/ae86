#if defined(_STDINT_H)
// esp32
const int analogInPin = A7;      // 35; 模拟输入引脚
const int LED_PIN = 2;           // LED_BUILTIN; // led连接到pwm输出引脚
const int sensorValueMax = 4095; // 12bit
#else
// arduino
const int analogInPin = A0;      // 模拟输入引脚
const int LED_PIN = 13;          // led连接到pwm输出引脚
const int sensorValueMax = 1023; // 10bit
#endif
// 给检测模块供电的电压（模拟电压：5V或3.3V），应通过万用表或其他工具测出实际值
const float refVoltage = 3.32; // maybe 4.72
// 检测模块缩小电压的倍数，官方宣称5倍（比如模拟电压5V，检测模块的输入电压最大25V），应实测后给出
float sensorModuleTimes = 5.43; // maybe 5.09

int sensorValue = 1303;      // 从引脚读到的值
float outputValue = 5.74; //输出到pwm脚的值

void setup()
{
  // 设置引脚为模拟输入模式
  // pinMode(analogInPin, INPUT);
  // 设置led脚输出pwm模式
  pinMode(LED_PIN, OUTPUT);
  //高电平，灯亮
  digitalWrite(LED_PIN, HIGH);

  Serial.begin(115200);
  Serial.println("sensor module detection start");
}

void loop()
{
#if defined(_STDINT_H)
  Serial.println("----ESP32----");
#else
  Serial.println("----Arduino----");
#endif

  //读取模拟输入数值
  sensorValue = analogRead(analogInPin);
  // maybe more stable when the analog pin is read twice
  sensorValue = analogRead(analogInPin);

  // 在串口打印显示输入输出的数值
  Serial.print("sensor = ");
  Serial.print(sensorValue);
  Serial.print("\t times = ");
  sensorModuleTimes = outputValue * sensorValueMax / sensorValue / refVoltage;
  Serial.println(sensorModuleTimes);

  digitalWrite(LED_PIN, digitalRead(LED_PIN) ^ HIGH); //配置GPIO2端口为高电平，灯亮
  delay(1000);
}
