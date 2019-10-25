// Copyright (c) 2016-2018, XMOS Ltd, All rights reserved
/*
 * Test the use of the ExampleTestbench. Test that the value 0 and 1 can be sent
 * in both directions between the ports.
 *
 * NOTE: The src/testbenches/ExampleTestbench must have been compiled for this to run without error.
 *
 */
#include <xs1.h>
#include <print.h>
#include <stdio.h>
#include "xud.h"
#include "platform.h"
#include "shared.h"


#define XUD_EP_COUNT_OUT   7
#define XUD_EP_COUNT_IN    1

#define PACKET_LEN_START   10
#define PACKET_LEN_END     19

/* Endpoint type tables */
XUD_EpType epTypeTableOut[XUD_EP_COUNT_OUT] = {XUD_EPTYPE_CTL, XUD_EPTYPE_BUL, XUD_EPTYPE_BUL, XUD_EPTYPE_BUL, XUD_EPTYPE_BUL, XUD_EPTYPE_BUL, XUD_EPTYPE_BUL};
XUD_EpType epTypeTableIn[XUD_EP_COUNT_IN] =   {XUD_EPTYPE_CTL};

int main()
{
    chan c_ep_out[XUD_EP_COUNT_OUT], c_ep_in[XUD_EP_COUNT_IN];

    par
    {
        
        XUD_Main(c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
                                null, epTypeTableOut, epTypeTableIn,
                                null, null, -1, XUD_SPEED_HS, XUD_PWR_BUS);

    
        TestEp_Rx(c_ep_out[3], 3, PACKET_LEN_START, PACKET_LEN_END);
        TestEp_Rx(c_ep_out[4], 4, PACKET_LEN_START, PACKET_LEN_END);
        TestEp_Rx(c_ep_out[5], 5, PACKET_LEN_START, PACKET_LEN_END);
        {
            XUD_ep ep_out_0 = XUD_InitEp(c_ep_out[0]);
            TestEp_Rx(c_ep_out[6], 6, PACKET_LEN_START, PACKET_LEN_END);
            XUD_Kill(ep_out_0);
            exit(0);
        }
    }

    return 0;
}
