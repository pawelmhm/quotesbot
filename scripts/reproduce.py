#!/usr/bin/env python
from shutil import which

from seleniumwire import webdriver


def main():
    driver_name = 'chrome'
    SELENIUM_DRIVER_ARGUMENTS = [
        "--headless",
        "--no-sandbox",
        "start-maximized",
        "enable-automation",
        "--disable-infobars",
        "--disable-xss-auditor",
        "--disable-setuid-sandbox",
        "--disable-xss-auditor",
        "--disable-web-security",
        "--disable-dev-shm-usage",
        "--disable-webgl",
        "--disable-popup-blocking",
        "--ignore-certificate-errors",
        "--ignore-ssl-errors",
        "--ignore-certificate-errors-spki-list",
        "--allow-insecure-localhost",
        "--ssl-insecure",
    ]
    driver_executable_path = which('chromedriver')
    driver_klass = webdriver.Chrome
    driver_options = webdriver.ChromeOptions()

    for argument in SELENIUM_DRIVER_ARGUMENTS:
        driver_options.add_argument(argument)

    driver_kwargs = {
        'executable_path': driver_executable_path,
        f'{driver_name}_options': driver_options
    }
    driver = driver_klass(**driver_kwargs)

    print("Making request")
    driver.get('https://httpbin.org/get')

    print(driver.page_source)

if __name__ == "__main__":
    main()
