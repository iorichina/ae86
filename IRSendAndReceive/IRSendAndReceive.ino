
#include <Arduino.h>

// select only NEC and the universal decoder for pulse distance protocols
#define DECODE_NEC      // Includes Apple and Onkyo
#define DECODE_DISTANCE // in case NEC is not received correctly

#define IR_RECEIVE_PIN 15  // D15
#define IR_SEND_PIN 4      // D4
#define TONE_PIN 27        // D27 25 & 26 are DAC0 and 1
#define APPLICATION_PIN 16 // RX2 pin

#define SEND_PWM_BY_TIMER // We do not have pin restrictions for this CPU's, so lets use the hardware PWM for send carrier signal generation

#if !defined(FLASHEND)
#define FLASHEND 0xFFFF // Dummy value for platforms where FLASHEND is not defined
#endif
/*
 * Helper macro for getting a macro definition as string
 */
#if !defined(STR_HELPER)
#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)
#endif

#include <WString.h>
#include <IRremote.hpp>

#define DELAY_AFTER_SEND 20
#define DELAY_AFTER_LOOP 50

uint16_t sAddress = 0xA102;
uint8_t sCommand = 0xB4;
uint8_t sRepeats = 1;

void setup()
{
    pinMode(LED_BUILTIN, OUTPUT);

    Serial.begin(115200);

    // Just to know which program is running on my Arduino
    Serial.println(F("START " __FILE__ " from " __DATE__ "\r\nUsing library version " VERSION_IRREMOTE));

    // Start the receiver and if not 3. parameter specified, take LED_BUILTIN pin from the internal boards definition as default feedback LED
    IrReceiver.begin(IR_RECEIVE_PIN, ENABLE_LED_FEEDBACK);

#if defined(IR_SEND_PIN)
    IrSender.begin(); // Start with IR_SEND_PIN as send pin and enable feedback LED at default feedback LED pin
    Serial.print(F("Start with IR_SEND_PIN"));
    Serial.println(F(IR_SEND_PIN));
#else
    IrSender.begin(3, ENABLE_LED_FEEDBACK); // Specify send pin and enable feedback LED at default feedback LED pin
#endif

    Serial.print(F("Ready to receive IR signals of protocols: "));
    printActiveIRProtocols(&Serial);
    Serial.println(F("at pin " STR(IR_RECEIVE_PIN)));

    Serial.println(F("Ready to send IR signals at pin " STR(IR_SEND_PIN)));

#if FLASHEND >= 0x3FFF // For 16k flash or more, like ATtiny1604
    // infos for receive
    Serial.print(RECORD_GAP_MICROS);
    Serial.println(F(" us is the (minimum) gap, after which the start of a new IR packet is assumed"));
    Serial.print(MARK_EXCESS_MICROS);
    Serial.println(F(" us are subtracted from all marks and added to all spaces for decoding"));
#endif

    Serial.println();
    Serial.print(F("address=0x"));
    Serial.print(sAddress, HEX);
    Serial.print(F(" command=0x"));
    Serial.print(sCommand, HEX);
    Serial.print(F(" repeats="));
    Serial.println(sRepeats);
    Serial.flush();
}

/*
 * Send NEC IR protocol
 */
void send_ir_data()
{
    Serial.print(F("Sending: 0x"));
    Serial.print(sAddress, HEX);
    Serial.print(sCommand, HEX);
    Serial.println(sRepeats, HEX);

    // clip repeats at 4
    if (sRepeats > 4)
    {
        sRepeats = 4;
    }
    // Results for the first loop to: Protocol=NEC Address=0x102 Command=0x34 Raw-Data=0xCB340102 (32 bits)
    IrSender.sendNEC(sAddress, sCommand, sRepeats);
}

void receive_ir_data()
{
    if (IrReceiver.decode())
    {
        Serial.print(F("Decoded protocol: "));
        Serial.print(getProtocolString(IrReceiver.decodedIRData.protocol));
        Serial.print(F("Decoded raw data: "));
        Serial.print(IrReceiver.decodedIRData.decodedRawData, HEX);
        Serial.print(F(", decoded address: "));
        Serial.print(IrReceiver.decodedIRData.address, HEX);
        Serial.print(F(", decoded command: "));
        Serial.println(IrReceiver.decodedIRData.command, HEX);
        IrReceiver.resume();
    }
}

void loop()
{
    /*
     * Print loop values
     */
    Serial.println();
    Serial.print(F("address=0x"));
    Serial.print(sAddress, HEX);
    Serial.print(F(" command=0x"));
    Serial.print(sCommand, HEX);
    Serial.print(F(" repeats="));
    Serial.println(sRepeats);
    Serial.flush();

    send_ir_data();
    Serial.print(F("delay after send:"));
    Serial.println(F((RECORD_GAP_MICROS / 1000) + 5));
    // wait for the receiver state machine to detect the end of a protocol
    delay((RECORD_GAP_MICROS / 1000) + 5);
    receive_ir_data();

    // Prepare data for next loop
    // sAddress += 0x0101;
    // sCommand += 0x11;
    // sRepeats++;

    delay(5000); // Loop delay
}