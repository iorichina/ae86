
#include "OV2640Streamer.h"
#include <assert.h>



OV2640Streamer::OV2640Streamer(OV2640 &cam) : CStreamer(cam.getWidth(), cam.getHeight()), m_cam(cam)
{
    printf("Created streamer width=%d, height=%d\n", cam.getWidth(), cam.getHeight());
}

void OV2640Streamer::streamImage(uint32_t curMsec)
{
    int64_t fr_start = 0;
    int64_t fr_ready = 0;
    int64_t fr_face = 0;
    int64_t fr_recognize = 0;
    int64_t fr_encode = 0;

    static int64_t last_frame = 0;
    if(!last_frame) {
        last_frame = esp_timer_get_time();
    }

    m_cam.run();// queue up a read for next time

    BufPtr bytes = m_cam.getfb();
    streamFrame(bytes, m_cam.getSize(), curMsec);
    m_cam.done();
}
