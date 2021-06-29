# Copyright 2019-2021 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.
from usb_session import UsbSession
from usb_transaction import UsbTransaction
import pytest
from conftest import PARAMS, test_RunUsbSession
from copy import deepcopy

# EP numbers currently fixed for this test - set in params
PARAMS = deepcopy(PARAMS)
PARAMS["smoke"].update({"ep": [3], "dummy_threads": [0]})
PARAMS["default"].update({"ep": [3], "dummy_threads": [0]})


@pytest.fixture
def test_session(ep, address, bus_speed):

    session = UsbSession(
        bus_speed=bus_speed, run_enumeration=False, device_address=address
    )

    for pktLength in range(10, 20):

        session.add_event(
            UsbTransaction(
                session,
                deviceAddress=address,
                endpointNumber=ep,
                endpointType="BULK",
                direction="OUT",
                dataLength=pktLength,
            )
        )
        session.add_event(
            UsbTransaction(
                session,
                deviceAddress=address,
                endpointNumber=4,
                endpointType="BULK",
                direction="OUT",
                dataLength=pktLength,
            )
        )
        session.add_event(
            UsbTransaction(
                session,
                deviceAddress=address,
                endpointNumber=5,
                endpointType="BULK",
                direction="OUT",
                dataLength=pktLength,
            )
        )
        session.add_event(
            UsbTransaction(
                session,
                deviceAddress=address,
                endpointNumber=6,
                endpointType="BULK",
                direction="OUT",
                dataLength=pktLength,
            )
        )

    return session
