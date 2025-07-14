# Alloria

Escape game sound system

## Design

```mermaid
graph
    mic-r["🎤"]
    mic-s["🎤"]
    speak-r["🔊"]
    speak-s["🔊"]
    noise-r["RNNoise + <br>voice detection"]
    noise-s["RNNoise"]
    source-e["rtp-source-e-i"]
    sink-r["rtp-sink-r-i"]
    source-r["rtp-source-r-i"]
    sink-e["rtp-sink-e-i"]
    echo["Echo cancel"]

    mic-s@{ shape: procs}
    speak-s@{ shape: procs}
    rtp-source-r@{ shape: procs}
    rtp-sink-r@{ shape: procs}

    source-e -- UDP 46000+i --> sink-r
    source-r -- UDP 46000+i --> sink-e

    subgraph "Escape room N°i"
        sink-e --> speak-s --> echo -->
        mic-s --> noise-s --> source-e
    end

    subgraph "Control room"
        sink-r --> speak-r
        mic-r --> noise-r --> source-r
    end
```
