// Copyright 2011-2021 XMOS LIMITED.
// This Software is subject to the terms of the XMOS Public Licence: Version 1.

#ifndef _XUD_PWRSIG_H_
#define _XUD_PWRSIG_H_
void XUD_PhyReset(out port p_rst, int resetTime, unsigned rstMask);

int XUD_Init(XUD_resources_t &resources);

int XUD_Suspend(XUD_PwrConfig pwrConfig, XUD_resources_t &resources);
#endif
