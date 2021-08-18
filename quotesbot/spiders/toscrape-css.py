# -*- coding: utf-8 -*-
import scrapy
from scrapy_selenium import SeleniumRequest


class ToScrapeCSSSpider(scrapy.Spider):
    name = "toscrape-css"
    start_urls = [
        'https://quotes.toscrape.com/',
    ]

    def parse(self, response):
        urls = [
            'https://www.farmavazquez.com/fisiocrem-60-ml-581241.html',
            'https://www.farmavazquez.com/fisiocrem-250-ml-581242.html'
        ]
        for url in urls:
            yield SeleniumRequest(url=url)
        for quote in response.css("div.quote"):
            yield {
                'text': quote.css("span.text::text").extract_first(),
                'author': quote.css("small.author::text").extract_first(),
                'tags': quote.css("div.tags > a.tag::text").extract()
            }

        next_page_url = response.css("li.next > a::attr(href)").extract_first()
        if next_page_url is not None:
            yield SeleniumRequest(url=response.urljoin(next_page_url))

