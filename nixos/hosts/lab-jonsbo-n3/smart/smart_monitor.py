#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: Andrew Hayzen <ahayzen@gmail.com>
#
# SPDX-License-Identifier: MPL-2.0

import requests
from pySMART import Device
from time import sleep

ASSESSMENT_PASS = "PASS"
GET_SELFTEST_RESULT_IN_PROGRESS = 1
TEMPERATURE_MIN = 10
TEMPERATURE_MAX = 50
TEST_RESULT_PASS = "Completed without error"
TEST_TYPE_SHORT = "short"
TEST_TYPE_LONG = "long"


def send_notification(title: str, message: str, priority: str, tags: str):
    token = ""
    with open("/etc/ntfy/token", "r") as f:
        token = f.read().strip()

    requests.post(
        "https://ntfy.hayzen.uk/lab-jonsbo-n3-health",
        data=message,
        headers={
            "Authorization": "Bearer " + token,
            "Priority": priority,
            "Title": "SMART " + title,
            "Tags": tags,
        },
    )


def self_test_start(device: Device, test_type: str):
    print(
        "%s attempting to start self test: %s"
        % (device.dev_reference, test_type)
    )

    # Ensure that there isn't a test running already
    if device.get_selftest_result()[0] == GET_SELFTEST_RESULT_IN_PROGRESS:
        print("%s self test in progress ignore" % device.dev_reference)
        return 0

    # Start a self test
    result = device.run_selftest(test_type)
    if result[0] == GET_SELFTEST_RESULT_IN_PROGRESS:
        print("%s self test in progress ignore" % device.dev_reference)
        return 0

    if result[0] != 0:
        print(
            "%s self test failed to run and wait: %s"
            % (device.dev_reference, result)
        )
        return 1

    return 0


def self_test_wait(device: Device):
    print("%s waiting for test result" % device.dev_reference)

    # Wait for the test to complete
    test_result = device.get_selftest_result()
    while test_result[0] == GET_SELFTEST_RESULT_IN_PROGRESS:
        test_result = device.get_selftest_result()
        sleep(5)

    # Check we have a successful test result
    if test_result[0] != 0:
        print(
            "%s unknown test result state: %s"
            % (device.dev_reference, test_result)
        )
        return 1

    # Check the result
    if test_result[1].status == TEST_RESULT_PASS:
        print("%s self test passed" % device.dev_reference)
        return 0
    else:
        print(
            "%s self test failed with: %s"
            % (device.dev_reference, test_result[1].status)
        )
        return 1


if __name__ == "__main__":
    from datetime import datetime
    from pySMART import DeviceList

    # Long test once per month and short test for other weeks
    day_of_year = datetime.now().timetuple().tm_yday
    week_of_year = day_of_year // 7
    monthly_cycle = week_of_year % 4 == 0
    test_type = TEST_TYPE_LONG if monthly_cycle else TEST_TYPE_SHORT

    # Find the devices
    devices = DeviceList()

    # Attempt to run SMART on each device
    for device in devices:
        if self_test_start(device, test_type) != 0:
            send_notification(
                device.dev_reference, "Test Failed to Start", "high", "warning"
            )
            exit(1)

    # Wait for completion
    for device in devices:
        # Skip the nvme0 as that doesn't have complete SMART test results
        if device.dev_reference == "/dev/nvme0":
            print("%s skipping waiting for result" % device.dev_reference)
            continue

        if self_test_wait(device) != 0:
            send_notification(
                device.dev_reference, "Test Failed", "high", "warning"
            )
            exit(1)

    # Check assessment and temperature of each device
    for device in devices:
        print(
            "%s SMART assessment: %s"
            % (device.dev_reference, device.assessment)
        )
        if device.assessment != ASSESSMENT_PASS:
            send_notification(
                device.dev_reference,
                "Assessment Failed",
                "high",
                "warning",
            )
            exit(1)

        print(
            "%s SMART temperature: %s"
            % (device.dev_reference, device.temperature)
        )
        if (
            device.temperature < TEMPERATURE_MIN
            or device.temperature > TEMPERATURE_MAX
        ):
            send_notification(
                device.dev_reference,
                "Temperature Failed",
                "high",
                "warning",
            )
            exit(1)

    print("SMART monitor passed")
    send_notification("", "Passed", "low", "tada")
    exit(0)
