#include <xccompat.h>

#include "xud.h"

// Protos
void VideoEndpointsHandler(chanend c_epint_in, chanend c_episo_in);
void Endpoint0(chanend chan_ep0_out, chanend chan_ep0_in);


int XUD_Main_wrapper(chanend c_epOut[], int noEpOut,
                chanend c_epIn[], int noEpIn,
                NULLABLE_RESOURCE(chanend, c_sof),
                XUD_EpType epTypeTableOut[], XUD_EpType epTypeTableIn[],
                XUD_BusSpeed_t desiredSpeed,
                XUD_PwrConfig pwrConfig,
                XUD_resources_t *resources
){

    return XUD_Main_wrapper2(c_epOut, noEpOut, c_epIn, noEpOut,
                          c_sof, epTypeTableOut, epTypeTableIn,
                          desiredSpeed, pwrConfig, resources);
}

void Endpoint0_wrapper(chanend chan_ep0_out, chanend chan_ep0_in){
    Endpoint0(chan_ep0_out, chan_ep0_in);
}

void VideoEndpointsHandler_wrapper(chanend c_epint_in, chanend c_episo_in){
    VideoEndpointsHandler(c_epint_in, c_episo_in);
}