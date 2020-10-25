# Streamer

## What is this?

This is a docker image which provides live video stream receiving and broadcasting with an optional, fully customisable authentication pugin system via [RTMP](https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol) and [HLS](https://en.wikipedia.org/wiki/HTTP_Live_Streaming). Each stream is also automatically recorded and converted to an MP4 to allow for re-broadcasting and re-distribution.

## Purpose

I've been investigating video streaming for a while, and the UKFast Hackathon 2020 seemed like a perfect opportunity to share this with people.

With educational institutions around the world shutting their doors and moving to distance learning due to COVID-19, streaming video is rapidly growing in demand. Not every institution has the budget to pay for a video streaming service, so a lot of them are turning to open source for a more cost-effiecient solution.

Equally, I've been asked by different people about how they could host their own webinars and similar events, this will provide them with the ability to do so.

## How It Works

This docker image lsitens on port 1935 on `/live/{streamName}` for imcoming RTMP requests and exposes port 8080 on `/hls` to expose the streams.

### Prerequisites

* [Docker](https://docs.docker.com/get-docker/)

### Usage

#### Basic Usage

Pull the image:

```bash
docker pull phily245/streamer
```

Basic mounting:

```bash
docker run --network host -p 1935:1935 -p 8080:80 -d --name streamz phily245/streamer
```

#### Volume Mounting

Docker containers are disposable and easily torn down. When this happens, as docker containers are virtual file systems they hold all of the stream data and recorded streams without [mounting volumes](https://docs.docker.com/storage/volumes/) your vidoes are stored in this volatile storatge. It's higly recommended to map `/home/videos` to a file location outside of the docker image, e.g. to the host or to a kubernetes volume for example. The recommended way of doing this is using the `-v` flag:

```bash
docker run -v /path/to/storage:/home/videos phily245/streamer
```
