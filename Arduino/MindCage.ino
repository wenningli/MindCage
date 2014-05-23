//"services.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>
#include <Servo.h> 
#include <MP3Trigger.h>
#include <SoftwareSerial.h>

SoftwareSerial mySerial(MP3_RX, MP3_TX); // RX, TX for MP3 trigger
#define MP3_RX 2
#define MP3_TX 3
#define SERVO_PIN          7

Servo myservo;
MP3Trigger trigger;

int servoSpeed = 95;
unsigned long lastCheckAttnTime;

void setup()
{
  // MP3 trigger  
  delay(1000);
  trigger.setup(&mySerial);
  mySerial.begin(MP3Trigger::serialRate() );
  trigger.setVolume(60);
  trigger.setLooping(true,01);
  
  // Init. and start BLE library.
  ble_begin();
  
  Serial.begin(38400);  
  
  myservo.attach(SERVO_PIN);
  myservo.write(servoSpeed);
  lastCheckAttnTime = millis();
  
}

void loop()
{
  trigger.update();  
 
  // If data is ready
  while(ble_available())
  {
    
    byte data0 = ble_read();
    byte data1 = ble_read();
    byte data2 = ble_read();
    
    if (data0 == 0x03)  // Command is to control Servo pin
    {
      if ((millis() - lastCheckAttnTime) > 1000) // only check every second
      {
         lastCheckAttnTime = millis();
         int normalizedAttn = min(90, 100 - data1);
         trigger.setVolume(map(normalizedAttn, 0, 90, 0 , 60));
         myservo.write(map(normalizedAttn, 0 , 90, 0, 95));

         Serial.print("Attn ");
         Serial.println(data1);
         
         if (data1 == 95)
         {
         }
         else
         {      
         }
      }
    }
  }
 
  if (!ble_connected())
  {
    myservo.write(servoSpeed);
    trigger.setVolume(60);
  }

  
  // Allow BLE Shield to send/receive data
  ble_do_events();  
  delay(50);
  
}

