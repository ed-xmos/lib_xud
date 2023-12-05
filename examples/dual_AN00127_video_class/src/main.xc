// Copyright 2015-2022 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.

/* Includes */
#include <platform.h>
#include <xs1.h>
#include <xscope.h>
#include <xccompat.h>

#include "usb_video.h"

/* xSCOPE Setup Function */
#if (USE_XSCOPE == 1)
void xscope_user_init(void) {
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC); /* Enable fast printing over XTAG */
}
#endif

/* USB Endpoint Defines */
#define EP_COUNT_OUT   1    // 1 OUT EP0
#define EP_COUNT_IN    3    // (1 IN EP0 + 1 INTERRUPT IN EP + 1 ISO IN EP)

/* Endpoint type tables - informs XUD what the transfer types for each Endpoint in use and also
 * if the endpoint wishes to be informed of USB bus resets
 */
XUD_EpType epTypeTableOut[EP_COUNT_OUT] = {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE};
XUD_EpType epTypeTableIn[EP_COUNT_IN] =   {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_INT, XUD_EPTYPE_ISO};

XUD_EpType epTypeTableOut2[EP_COUNT_OUT] = {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE};
XUD_EpType epTypeTableIn2[EP_COUNT_IN] =   {XUD_EPTYPE_CTL | XUD_STATUS_ENABLE, XUD_EPTYPE_INT, XUD_EPTYPE_ISO};


extern int XUD_Main_wrapper(chanend c_epOut[], int noEpOut,
                chanend c_epIn[], int noEpIn,
                NULLABLE_RESOURCE(chanend, c_sof),
                XUD_EpType epTypeTableOut[], XUD_EpType epTypeTableIn[],
                XUD_BusSpeed_t desiredSpeed,
                XUD_PwrConfig pwrConfig);

extern void Endpoint0_wrapper(chanend chan_ep0_out, chanend chan_ep0_in);

extern void VideoEndpointsHandler_wrapper(chanend c_epint_in, chanend c_episo_in);


int main() {

    chan c_ep_out[EP_COUNT_OUT], c_ep_in[EP_COUNT_IN];
    chan c_ep_out2[EP_COUNT_OUT], c_ep_in2[EP_COUNT_IN];

    /* 'Par' statement to run the following tasks in parallel */
    par
    {
        on USB_TILE: XUD_Main(c_ep_out, EP_COUNT_OUT, c_ep_in, EP_COUNT_IN,
                      null, epTypeTableOut, epTypeTableIn,
                      XUD_SPEED_HS, XUD_PWR_BUS);

        on USB_TILE: Endpoint0(c_ep_out[0], c_ep_in[0]);

        on USB_TILE: VideoEndpointsHandler(c_ep_in[1], c_ep_in[2]);

#undef USB_TILE
#define USB_TILE tile[2]

        on USB_TILE: XUD_Main_wrapper(c_ep_out2, EP_COUNT_OUT, c_ep_in2, EP_COUNT_IN,
                      null, epTypeTableOut2, epTypeTableIn2,
                      XUD_SPEED_HS, XUD_PWR_BUS);

        on USB_TILE: Endpoint0_wrapper(c_ep_out2[0], c_ep_in2[0]);

        on USB_TILE: VideoEndpointsHandler_wrapper(c_ep_in2[1], c_ep_in2[2]);


    }
    return 0;
}
