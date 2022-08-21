
#include <Arduino.h>

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

void setup()
{
    pinMode(LED_BUILTIN, OUTPUT);

    Serial.begin(115200);

    // Just to know which program is running on my Arduino
    Serial.println(F("START " __FILE__ " from " __DATE__ "\r\nUsing library version " VERSION_IRREMOTE));

    /*
     * The IR library setup. That's all!
     */
    IrSender.begin(); // Start with IR_SEND_PIN as send pin and if NO_LED_FEEDBACK_CODE is NOT defined, enable feedback LED at default feedback LED pin

    Serial.print(F("Ready to send IR signals at pin "));
    Serial.println(IR_SEND_PIN);
}

/*
 * Set up the data to be sent.
 * For most protocols, the data is build up with a constant 8 (or 16 byte) address
 * and a variable 8 bit command.
 * There are exceptions like Sony and Denon, which have 5 bit address.
 */
uint16_t sAddress = 0x0102;
uint8_t sCommand = 0x34;
uint8_t sRepeats = 0;

void loop()
{
    /*
     * Print current send values
     */
    Serial.println();
    Serial.print(F("Send now: address=0x"));
    Serial.print(sAddress, HEX);
    Serial.print(F(" command=0x"));
    Serial.print(sCommand, HEX);
    Serial.print(F(" repeats="));
    Serial.print(sRepeats);
    Serial.println();

    Serial.println(F("Send NEC with 16 bit address"));
    Serial.flush();

    // Results for the first loop to: Protocol=NEC Address=0x102 Command=0x34 Raw-Data=0xCB340102 (32 bits)
    IrSender.sendNEC(sAddress, sCommand, sRepeats);

    /*
     * If you cannot avoid to send a raw value directly like e.g. 0xCB340102 you must use sendNECRaw()
     */
    //    Serial.println(F("Send NECRaw 0xCB340102"));
    //    IrSender.sendNECRaw(0xCB340102, sRepeats);
    /*
     * Increment send values
     * Also increment address just for demonstration, which normally makes no sense
     */
    // sAddress += 0x0101;
    // sCommand += 0x11;
    sRepeats++;
    // clip repeats at 4
    if (sRepeats > 2)
    {
        sRepeats = 2;
    }

    delay(1000); // delay must be greater than 5 ms (RECORD_GAP_MICROS), otherwise the receiver sees it as one long signal
}