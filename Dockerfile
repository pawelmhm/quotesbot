# Dockfile installling chrome + chrome webdriver
FROM scrapinghub/scrapinghub-stack-scrapy:2.5

ARG CHROME_VERSION="google-chrome-stable"
ARG CHROME_DRIVER_VERSION

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install zip unzip
RUN apt-get install snap
RUN apt-get install openssl
RUN apt-get install libnss3-tools -y
RUN apt-get install ca-certificates

WORKDIR /

# Download ZYTE certificates for crawlera-headless-proxy
RUN curl https://docs.zyte.com/_downloads/753f39eae366f4d8c42249b7b1246c29/zyte-proxy-ca.crt -o zyte-proxy-ca.crt
RUN sudo cp zyte-proxy-ca.crt /usr/local/share/ca-certificates/zyte-proxy-ca.crt


RUN curl https://raw.githubusercontent.com/zytedata/zyte-smartproxy-headless-proxy/master/ca.crt -o zyte-proxy-headless.crt
RUN sudo cp zyte-proxy-headless.crt /usr/local/share/ca-certificates/zyte-proxy-headless.crt


RUN sudo update-ca-certificates

#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION;
#  e.g. google-chrome-stable=53.0.2785.101-1
#       google-chrome-beta=53.0.2785.92-1
#       google-chrome-unstable=54.0.2840.14-1
#       latest (equivalent to google-chrome-stable)
#       google-chrome-beta  (pull latest beta)
#============================================
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#============================================
# Chrome Webdriver
#============================================
# can specify versions by CHROME_DRIVER_VERSION
# Latest released version will be used by default
#============================================
RUN CHROME_STRING=$(google-chrome --version) \
  && CHROME_VERSION_STRING=$(echo "${CHROME_STRING}" | grep -oP "\d+\.\d+\.\d+\.\d+") \
  && CHROME_MAYOR_VERSION=$(echo "${CHROME_VERSION_STRING%%.*}") \
  && wget --no-verbose -O /tmp/LATEST_RELEASE "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAYOR_VERSION}" \
  && CD_VERSION=$(cat "/tmp/LATEST_RELEASE") \
  && rm /tmp/LATEST_RELEASE \
  && if [ -z "$CHROME_DRIVER_VERSION" ]; \
     then CHROME_DRIVER_VERSION="${CD_VERSION}"; \
     fi \
  && CD_VERSION=$(echo $CHROME_DRIVER_VERSION) \
  && echo "Using chromedriver version: "$CD_VERSION \
  && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CD_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CD_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CD_VERSION \
  && sudo ln -fs /opt/selenium/chromedriver-$CD_VERSION /usr/bin/chromedriver

WORKDIR /

# Copy and build Spider code
ENV TERM xterm
ENV SCRAPY_SETTINGS_MODULE quotesbot.settings
RUN mkdir -p /app
WORKDIR /app
COPY ./requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY . /app
RUN python setup.py install
