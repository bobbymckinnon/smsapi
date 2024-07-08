<p align="center">
  <a href="https://mojolicious.org">
    <img src="https://raw.github.com/mojolicious/mojo/main/lib/Mojolicious/resources/public/mojo/logo.png?raw=true" style="margin: 0 auto;">
  </a>
</p>

## SMS API

### Intro
Business is asking us to build a new platform to be launched as a new product in the form of an
SMS API.
This SMS API will be offered on a prepaid basis, so customers will need to have enough credits
to be able to use this API to send SMS.
We would be operating as a hub, leveraging on our existing partners (around 50). Quality of
Service with our partners is variable, from really bad to really good in terms of latency and
reliability.

### Context
Our company is using Amazon AWS. This platform needs to be reliable.

## Installation

<div class="termy">

```console
$ docker build -t smsapi . --no-cache

$ docker run -dp 3000:3000 smsapi
```

</div>

## API Documentation (Swagger)

 - http://api.nsurio.com/api

 ## Mojolicous

 - https://mojolicious.org