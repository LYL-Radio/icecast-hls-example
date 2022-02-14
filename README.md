# Icecast To HLS

Stream Icecast source to HLS using [Liquidsoap](https://www.liquidsoap.info/)

## Description

[script.liq](script.liq) script file sets up a Liquidsoap [Harbor input](https://www.liquidsoap.info/doc-1.4.4/harbor.html) and a [HLS output](https://www.liquidsoap.info/doc-1.4.4/hls_output.html).

The output HLS files are then served by nginx using the [nginx.conf](nginx.conf).

## Usage

The repo includes a `docker-compose.yml` for a quick setup.
```bash
docker-compose up -d
```

### Input:

- **host:** localhost
- **port:** 8000
- **mountpoint:** live
- **source user:** source
- **source password:** hackme

### Output:
The HLS playlist file is served at:
```
http://localhost:8080/hls/live.m3u8
```
