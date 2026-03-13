# watch_tcp.sh

A live terminal dashboard for monitoring TCP connections on a specific port. It refreshes at a configurable interval and surfaces connection states, keepalive timers, dead connection candidates, top remote IPs, and OS-level keepalive settings.

> **Platform:** Linux only — requires `ss` (`iproute2`) and `sysctl net.ipv4.*` kernel parameters.

> [!NOTE]
> This script was generated with the assistance of a Large Language Model (LLM).
> Review and test it thoroughly before using it in a production environment.

---

## Prerequisites

| Tool                          | Purpose                | Package                                          |
| ----------------------------- | ---------------------- | ------------------------------------------------ |
| `awk`, `grep`, `sort`, `uniq` | Text processing        | GNU coreutils                                    |
| `ss`                          | Socket statistics      | `iproute2` (pre-installed on most distributions) |
| `sysctl`                      | Read OS TCP parameters | `procps` (pre-installed on most distributions)   |

---

## Installation

Download the script directly from the repository and make it executable:

```bash
# Using curl
curl -fsSL https://raw.githubusercontent.com/hahs-mobility/knowledge-hub/main/scripts/watch_tcp/watch_tcp.sh \
  -o watch_tcp.sh && chmod +x watch_tcp.sh

# Using wget
wget -q https://raw.githubusercontent.com/hahs-mobility/knowledge-hub/main/scripts/watch_tcp/watch_tcp.sh \
  && chmod +x watch_tcp.sh
```

---

## Usage

```bash
./watch_tcp.sh <port> [interval_seconds]
```

| Argument           | Required | Default | Description                 |
| ------------------ | -------- | ------- | --------------------------- |
| `interval_seconds` | No       | `3`     | Refresh interval in seconds |
| `port`             | Yes      | —       | TCP port number to monitor  |

### Examples

```bash
# Monitor port 61613 with default 3-second refresh
./watch_tcp.sh 61613

# Monitor port 5432 (PostgreSQL) with 5-second refresh
./watch_tcp.sh 5432 5

# Monitor port 443 with 1-second refresh
./watch_tcp.sh 443 1
```

Press `Ctrl+C` to exit.

---

## Output Sections

### Connection State Summary

Counts all TCP connections on the monitored port grouped by state.

| State         | Indicator    | Meaning                                                                      |
| ------------- | ------------ | ---------------------------------------------------------------------------- |
| `CLOSE_WAIT`  | **Red**      | Remote side closed; local application has not cleaned up — likely a leak     |
| `ESTABLISHED` | Green        | Active, healthy connections                                                  |
| `FIN_WAIT_1`  | Yellow       | Local side sent FIN, waiting for ACK                                         |
| `FIN_WAIT_2`  | Yellow       | Local FIN acknowledged, waiting for remote FIN                               |
| `LAST_ACK`    | Yellow       | Passive close — waiting for final ACK                                        |
| `SYN_SENT`    | Yellow       | Connection stuck in handshake — potential network issue                      |
| `TIME_WAIT`   | Yellow (>10) | Normal after connection close; high counts indicate rapid connection cycling |

### Established Connections + Keepalive Timers

Shows each established connection with its socket timer state.

| Label                 | Meaning                                                                                   |
| --------------------- | ----------------------------------------------------------------------------------------- |
| `[KEEPALIVE OK]`      | `SO_KEEPALIVE` is active on the socket                                                    |
| `[NO KEEPALIVE]`      | `SO_KEEPALIVE` is not enabled — idle connections may go undetected if the peer disappears |
| `[RETRANSMITTING xN]` | Packet loss or unresponsive peer; flagged as **LIKELY DEAD** if retries exceed 3          |
| `[UNKNOWN TIMER]`     | Unexpected timer state                                                                    |

### CLOSE_WAIT — Dead Connection Candidates

Lists connections stuck in `CLOSE_WAIT`. Each entry means the remote peer already closed the connection, but the local application has not called `close()` on the socket. This is typically a bug in the application.

### Top Remote IPs

Ranks the top 10 remote IP addresses by connection count on the monitored port. IPs with more than 10 connections are highlighted in red.

### OS TCP Keepalive Settings

Reads and displays the system-wide TCP keepalive kernel parameters:

| Parameter              | Description                                                         |
| ---------------------- | ------------------------------------------------------------------- |
| `tcp_keepalive_intvl`  | Interval between subsequent probes                                  |
| `tcp_keepalive_probes` | Number of unacknowledged probes before the connection is dropped    |
| `tcp_keepalive_time`   | Idle time before the first keepalive probe is sent                  |
| `tcp_retries2`         | Number of retransmits before giving up on an established connection |

The worst-case dead connection detection time is calculated as:

```
tcp_keepalive_time + (tcp_keepalive_intvl × tcp_keepalive_probes)
```

A warning is shown if `tcp_keepalive_time` is at the Linux default of **7200 seconds (2 hours)**, which is usually too high for production services.

---

## Tuning TCP Keepalive (Linux)

To reduce dead connection detection time, tune the kernel parameters:

```bash
# Detect idle connections after 60 seconds
sudo sysctl -w net.ipv4.tcp_keepalive_time=60

# Send a probe every 10 seconds
sudo sysctl -w net.ipv4.tcp_keepalive_intvl=10

# Drop after 5 failed probes
sudo sysctl -w net.ipv4.tcp_keepalive_probes=5
```

To persist across reboots, add to `/etc/sysctl.conf`:

```
net.ipv4.tcp_keepalive_time   = 60
net.ipv4.tcp_keepalive_intvl  = 10
net.ipv4.tcp_keepalive_probes = 5
```

> **Note:** OS-level keepalive settings are only effective on sockets where `SO_KEEPALIVE` is enabled by the application.

---

## Common Diagnostic Scenarios

**Many `CLOSE_WAIT` connections**
The application is not closing sockets after the remote peer disconnects. Investigate connection lifecycle handling in the application code.

**High `TIME_WAIT` count**
Connections are being opened and closed rapidly. Consider connection pooling or enabling `SO_REUSEADDR`/`tcp_tw_reuse`.

**`[NO KEEPALIVE]` on long-lived connections**
The application does not enable `SO_KEEPALIVE`. Silent half-open connections may accumulate. Configure keepalives at the application level or use a proxy that supports them.

**`[RETRANSMITTING]` with high retry count**
The remote peer is unreachable or the network path has failed. The connection will eventually be dropped after `tcp_retries2` attempts.
