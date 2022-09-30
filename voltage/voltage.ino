
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

// 有些电压检测模块可以使用第三方供电电压，可以是第三方供电、单片机输出电压管脚供电
// 如果自己拉电阻实现电压检测模块，就不需要额外供电了，也不需要定义宏
// #define USE_INPUT_VOLTAGE

#if defined(USE_INPUT_VOLTAGE)
// 外部供电电压作为参考电压，也有可能是5v
const float refVoltage = 3.32;
#else
// 单片机内部运行电压
const float refVoltage = 5.00;
#endif

// 检测模块缩小电压的倍数，30KΩ和一个7.5K欧姆电阻实现缩小5倍（比如模拟电压5V，检测模块的输入电压最大25V），要是对电阻质量没信息，应实测后给出
const float sensorModuleTimes = 1.0 / (7500.0 / (30000.0 + 7500.0)); // 5.00;// = 1/（R2 /（R1+R2））

int sensorValue = 0;     // 从引脚读到的值
float outputValue = 0.0; //输出到pwm脚的值

void setup()
{
  // 设置引脚为模拟输入模式
  // pinMode(analogInPin, INPUT);
  // 设置led脚输出pwm模式
  pinMode(LED_PIN, OUTPUT);
  //高电平，灯亮
  digitalWrite(LED_PIN, HIGH);

  Serial.begin(115200);
  Serial.println("voltage detection start");
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
  Serial.print("\t voltage = ");
  // =（[数值]/4095）* [参考电压] / （R2 /（R1+R2））
  // 25@max=(4095@read / 4095@max) * (5V * 5@times)
  outputValue = ((float)sensorValue / sensorValueMax) * (refVoltage * sensorModuleTimes);
  Serial.println(outputValue);

  digitalWrite(LED_PIN, digitalRead(LED_PIN) ^ HIGH); //配置GPIO2端口为高电平，灯亮
  delay(1000);
}
