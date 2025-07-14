# Alloria

Escape game sound system

## Design

```mermaid
graph
    mic-r["🎤"]
    mic-s["🎤"]
    speak-r["🔊"]
    speak-s["🔊"]
    noise-r("RNNoise + <br>voice detection")
    noise-s("RNNoise")
    source-e("rtp-source-e")
    sink-r("rtp-sink-r")
    source-r("rtp-source")
    sink-e("rtp-sink-e")
    echo("Echo cancel")

    mic-s@{ shape: procs}
    speak-s@{ shape: procs}

    source-e -- UDP 46000 --> sink-r
    source-r -- UDP 46000 --> sink-e

    subgraph Escape room
        sink-e --> speak-s --> echo -->
        mic-s --> noise-s --> source-e
    end

    subgraph Control room
        sink-r --> speak-r
        mic-r --> noise-r --> source-r
    end
```
