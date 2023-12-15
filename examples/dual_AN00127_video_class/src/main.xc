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

extern int XUD_Main_wrapper2(chanend c_epOut[], int noEpOut,
                chanend c_epIn[], int noEpIn,
                NULLABLE_RESOURCE(chanend, c_sof),
                XUD_EpType epTypeTableOut[], XUD_EpType epTypeTableIn[],
                XUD_BusSpeed_t desiredSpeed,
                XUD_PwrConfig pwrConfig);

extern void Endpoint0_wrapper2(chanend chan_ep0_out, chanend chan_ep0_in);

extern void VideoEndpointsHandler_wrapper2(chanend c_epint_in, chanend c_episo_in);

#if APP_TILE == 0
// tile[0] resources defined by XUD and XN file
in port flag0_port = PORT_USB_FLAG0; /* For XS3: Mission: RXE, XS2 is configurable and set to RXE in mission mode */
in port flag1_port = PORT_USB_FLAG1; /* For XS3: Mission: RXA, XS2 is configuratble and set to RXA in mission mode*/
in buffered port:32 p_usb_clk  = PORT_USB_CLK;
out buffered port:32 p_usb_txd = PORT_USB_TXD;
in  buffered port:32 p_usb_rxd = PORT_USB_RXD;
out port tx_readyout           = PORT_USB_TX_READYOUT;
in port tx_readyin             = PORT_USB_TX_READYIN;
in port rx_rdy                 = PORT_USB_RX_READY;
on tile[0]: clock tx_usb_clk  = XS1_CLKBLK_4;
on tile[0]: clock rx_usb_clk  = XS1_CLKBLK_5;
#endif

#if APP_TILE == 2
// Need to declare resources on tile[2] so we have XC constructors for them
on tile[2]: in port flag0_port = XS1_PORT_1E; /* For XS3: Mission: RXE, XS2 is configurable and set to RXE in mission mode */
on tile[2]: in port flag1_port = XS1_PORT_1F; /* For XS3: Mission: RXA, XS2 is configuratble and set to RXA in mission mode*/
on tile[2]: in buffered port:32 p_usb_clk  = XS1_PORT_1J;
on tile[2]: out buffered port:32 p_usb_txd = XS1_PORT_8A;
on tile[2]: in  buffered port:32 p_usb_rxd = XS1_PORT_8B;
on tile[2]: out port tx_readyout           = XS1_PORT_1K;
on tile[2]: in port tx_readyin             = XS1_PORT_1H;
on tile[2]: in port rx_rdy                 = XS1_PORT_1I;
on tile[2]: clock tx_usb_clk  = XS1_CLKBLK_4;
on tile[2]: clock rx_usb_clk  = XS1_CLKBLK_5;
#endif

int main() {

    chan c_ep_out[EP_COUNT_OUT], c_ep_in[EP_COUNT_IN];
    chan c_ep_out2[EP_COUNT_OUT], c_ep_in2[EP_COUNT_IN];

    /* 'Par' statement to run the following tasks in parallel */
    par
    {
        on tile[0]: XUD_Main_wrapper(c_ep_out, EP_COUNT_OUT, c_ep_in, EP_COUNT_IN,
                        null, epTypeTableOut, epTypeTableIn,
                        XUD_SPEED_HS, XUD_PWR_BUS);

        on tile[0]: Endpoint0_wrapper(c_ep_out[0], c_ep_in[0]);

        on tile[0]: VideoEndpointsHandler_wrapper(c_ep_in[1], c_ep_in[2]);

        on tile[2]: XUD_Main_wrapper2(c_ep_out2, EP_COUNT_OUT, c_ep_in2, EP_COUNT_IN,
                      null, epTypeTableOut2, epTypeTableIn2,
                      XUD_SPEED_HS, XUD_PWR_BUS);

        on tile[2]: Endpoint0_wrapper2(c_ep_out2[0], c_ep_in2[0]);

        on tile[2]: VideoEndpointsHandler_wrapper2(c_ep_in2[1], c_ep_in2[2]);


    }
    return 0;
}
