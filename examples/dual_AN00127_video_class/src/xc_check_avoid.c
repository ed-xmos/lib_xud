#include <xccompat.h>

typedef unsigned int XUD_EpType;

typedef enum XUD_BusSpeed
{
    XUD_SPEED_FS = 1,
    XUD_SPEED_HS = 2,
    XUD_SPEED_KILL = 3
} XUD_BusSpeed_t;

typedef enum XUD_PwrConfig
{
    XUD_PWR_BUS,
    XUD_PWR_SELF
} XUD_PwrConfig;

typedef struct XUD_resources
{
    int flag0_port;
    int flag1_port;
    int flag2_port;
    int p_usb_clk;
    int p_usb_txd;
    int p_usb_rxd ;
    int tx_readyout;
    int tx_readyin;
    int rx_rdy;
    int tx_usb_clk;
    int rx_usb_clk;
} XUD_resources_t;

int XUD_Main(   chanend c_epOut[], int noEpOut,
                chanend c_epIn[], int noEpIn,
                NULLABLE_RESOURCE(chanend, c_sof),
                XUD_EpType epTypeTableOut[], XUD_EpType epTypeTableIn[],
                XUD_BusSpeed_t desiredSpeed,
                XUD_PwrConfig pwrConfig,
                REFERENCE_PARAM(XUD_resources_t, resources));

void VideoEndpointsHandler(chanend c_epint_in, chanend c_episo_in);
void Endpoint0(chanend chan_ep0_out, chanend chan_ep0_in);

int XUD_Main_wrapper(chanend c_epOut[], int noEpOut,
                chanend c_epIn[], int noEpIn,
                NULLABLE_RESOURCE(chanend, c_sof),
                XUD_EpType epTypeTableOut[], XUD_EpType epTypeTableIn[],
                XUD_BusSpeed_t desiredSpeed,
                XUD_PwrConfig pwrConfig,
                REFERENCE_PARAM(XUD_resources_t, resources)
){

    return XUD_Main(c_epOut, noEpOut, c_epIn, noEpOut,
                          c_sof, epTypeTableOut, epTypeTableIn,
                          desiredSpeed, pwrConfig, resources);
}

void Endpoint0_wrapper(chanend chan_ep0_out, chanend chan_ep0_in){
    Endpoint0(chan_ep0_out, chan_ep0_in);
}

void VideoEndpointsHandler_wrapper(chanend c_epint_in, chanend c_episo_in){
    VideoEndpointsHandler(c_epint_in, c_episo_in);
}