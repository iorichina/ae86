#include <IRremote.h>

IRsend irsend;
unsigned int buf[15] = {9300, 4150, 500, 600, 700, 800, 900, 1000, 4450, 500, 600, 700, 800, 900, 1000};

void setup()
{
}

void loop()
{
    irsend.sendRaw(buf, 15, 38);
    delay(10);
}