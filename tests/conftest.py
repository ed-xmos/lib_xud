# Copyright 2021 XMOS LIMITED.
# This Software is subject to the terms of the XMOS Public Licence: Version 1.

import pytest
import os
import random
import sys
import Pyxsim
from Pyxsim import testers
from helpers import get_usb_clk_phy, do_usb_test

PARAMS = {
    "default": {
        "arch": ["xs3"],
        "ep": [1, 2, 4],
        "address": [0, 1, 127],
        "bus_speed": ["HS", "FS"],
        "dummy_threads": [0, 4, 5],
    },
    "smoke": {
        "arch": ["xs3"],
        "ep": [1],
        "address": [0],
        "bus_speed": ["HS", "FS"],
        "dummy_threads": [
            4
        ],  # TODO Set to 0 for speed of simulation vs higher for better quality testing..
    },
}


def pytest_addoption(parser):
    parser.addoption("--smoke", action="store_true", help="smoke test")


def pytest_generate_tests(metafunc):
    try:
        PARAMS = metafunc.module.PARAMS
        if metafunc.config.getoption("smoke"):
            params = PARAMS.get("smoke", PARAMS["default"])
        else:
            params = PARAMS["default"]
    except AttributeError:
        params = {}

    for name, values in params.items():
        if name in metafunc.fixturenames:
            metafunc.parametrize(name, values)


@pytest.fixture()
def test_ep(ep: int) -> int:
    return ep


@pytest.fixture()
def test_address(address: int) -> int:
    return address


@pytest.fixture()
def test_bus_speed(bus_speed: str) -> str:
    return bus_speed


@pytest.fixture()
def test_arch(arch: str) -> str:
    return arch


@pytest.fixture
def test_file(request):
    return str(request.node.fspath)


@pytest.fixture()
def test_dummy_threads(dummy_threads: int) -> int:
    return dummy_threads


def test_RunUsbSession(
    test_session, arch, ep, address, bus_speed, dummy_threads, test_file, capfd
):

    tester_list = []
    output = []
    testname, extension = os.path.splitext(os.path.basename(__file__))
    seed = random.randint(0, sys.maxsize)

    (clk_60, usb_phy) = get_usb_clk_phy(verbose=False, arch=arch)
    tester_list.extend(
        do_usb_test(
            arch,
            ep,
            address,
            bus_speed,
            dummy_threads,
            clk_60,
            usb_phy,
            [test_session],
            test_file,
            seed,
        )
    )
    cap_output, err = capfd.readouterr()
    output.append(cap_output.split("\n"))

    sys.stdout.write("\n")
    results = Pyxsim.run_tester(output, tester_list)

    # TODO only one result
    for result in results:
        if not result:
            print(cap_output)
            sys.stderr.write(err)
        assert result
