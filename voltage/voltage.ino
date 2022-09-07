#if defined(_STDINT_H)
// esp32
const int analogInPin = A7; // 35;        // 模拟输入引脚
const int LED_PIN = 2;      // LED_BUILTIN; // led连接到pwm输出引脚
#else
// arduino
const int analogInPin = A0; //       // 模拟输入引脚
const int LED_PIN = 13;     // led连接到pwm输出引脚
#endif
// 给检测模块供电的电压，应通过万用表或其他工具测出实际值
const int analogPinVoltage = 5.00; // maybe 4.72
// 检测模块降压的倍数，官方宣称5倍，应实测后给出
const int sensorModuleTimes = 5; // maybe 3.57328

int sensorValue = 0; // 从引脚读到的值
int outputValue = 0; //输出到pwm脚的值

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
  //读取模拟输入数值
  sensorValue = analogRead(analogInPin);
  // maybe more stable when the analog pin is read twice
  sensorValue = analogRead(analogInPin);
  // 使用map函数把输入的数值进行映射
#if defined(_STDINT_H)
  Serial.println("----ESP32----");
  // esp32 模拟输入电压5v，检测输入电压最大25v（被缩小了5倍）
  outputValue = map(sensorValue, 0, 4095, 0, 499); //可以修改数值映射500   5V
  // 在串口打印显示输入输出的数值
  Serial.print("sensor = ");
  Serial.print(sensorValue);
  Serial.print("\t mapper = ");
  Serial.print(outputValue);
  Serial.print("\t voltage = ");
  outputValue = (int)(sensorValue * (analogPinVoltage * analogPinVoltage) * 100 / 4096);
  Serial.print(outputValue % 1000 / 100.0);
#else
  // arduino
  Serial.println("----Arduino----");
  outputValue = map(sensorValue, 0, 1023, 0, 499); //可以修改数值映射330   3.3V
  // 在串口打印显示输入输出的数值
  Serial.print("sensor = ");
  Serial.print(sensorValue);
  Serial.print("\t mapper = ");
  Serial.print(outputValue);
  Serial.print("\t voltage = ");
  outputValue = (int)(sensorValue * (analogPinVoltage * analogPinVoltage) * 100 / 1024);
  Serial.println(outputValue % 1000 / 100.0);
#endif

  digitalWrite(LED_PIN, digitalRead(LED_PIN) ^ HIGH); //配置GPIO2端口为高电平，灯亮
  delay(1000);
}
