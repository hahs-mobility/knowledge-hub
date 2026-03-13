#!/bin/bash

# Usage: ./watch_tcp.sh <port> [interval_seconds]
# Example: ./watch_tcp.sh 61613 5

PORT=${1}
INTERVAL=${2:-3}

if [ -z "$PORT" ]; then
    echo "Usage: $0 <port> [interval_seconds]"
    echo "Example: $0 61613 5"
    exit 1
fi

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

print_header() {
    clear
    echo -e "${BOLD}============================================================${RESET}"
    echo -e "${BOLD}  TCP Connection Monitor — Port: ${CYAN}${PORT}${RESET}${BOLD}  (refresh: ${INTERVAL}s)${RESET}"
    echo -e "${BOLD}  $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo -e "${BOLD}============================================================${RESET}"
}

print_summary() {
    echo -e "\n${BOLD}[ CONNECTION STATE SUMMARY ]${RESET}"
    echo -e "-----------------------------------------------------------"

    # Count each state
    ESTABLISHED=$(ss -tan | grep ":${PORT}" | grep -c "ESTAB" || true)
    CLOSE_WAIT=$(ss -tan  | grep ":${PORT}" | grep -c "CLOSE-WAIT" || true)
    TIME_WAIT=$(ss -tan   | grep ":${PORT}" | grep -c "TIME-WAIT" || true)
    FIN_WAIT1=$(ss -tan   | grep ":${PORT}" | grep -c "FIN-WAIT-1" || true)
    FIN_WAIT2=$(ss -tan   | grep ":${PORT}" | grep -c "FIN-WAIT-2" || true)
    LAST_ACK=$(ss -tan    | grep ":${PORT}" | grep -c "LAST-ACK" || true)
    SYN_SENT=$(ss -tan    | grep ":${PORT}" | grep -c "SYN-SENT" || true)
    TOTAL=$(ss -tan       | grep -c ":${PORT}" || true)

    echo -e "  Total connections   : ${BOLD}${TOTAL}${RESET}"
    echo -e "  ${GREEN}ESTABLISHED         : ${ESTABLISHED}${RESET}"

    # Warn on problematic states
    if [ "$CLOSE_WAIT" -gt 0 ]; then
        echo -e "  ${RED}CLOSE_WAIT          : ${CLOSE_WAIT}  << PROBLEM - dead connections not cleaned up${RESET}"
    else
        echo -e "  CLOSE_WAIT          : ${CLOSE_WAIT}"
    fi

    if [ "$TIME_WAIT" -gt 10 ]; then
        echo -e "  ${YELLOW}TIME_WAIT           : ${TIME_WAIT}  << HIGH - rapid connection cycling${RESET}"
    else
        echo -e "  TIME_WAIT           : ${TIME_WAIT}"
    fi

    if [ "$FIN_WAIT1" -gt 0 ]; then
        echo -e "  ${YELLOW}FIN_WAIT_1          : ${FIN_WAIT1}  << WARNING${RESET}"
    else
        echo -e "  FIN_WAIT_1          : ${FIN_WAIT1}"
    fi

    if [ "$FIN_WAIT2" -gt 0 ]; then
        echo -e "  ${YELLOW}FIN_WAIT_2          : ${FIN_WAIT2}  << WARNING${RESET}"
    else
        echo -e "  FIN_WAIT_2          : ${FIN_WAIT2}"
    fi

    if [ "$LAST_ACK" -gt 0 ]; then
        echo -e "  ${YELLOW}LAST_ACK            : ${LAST_ACK}  << WARNING${RESET}"
    else
        echo -e "  LAST_ACK            : ${LAST_ACK}"
    fi

    if [ "$SYN_SENT" -gt 0 ]; then
        echo -e "  ${YELLOW}SYN_SENT            : ${SYN_SENT}  << WARNING - connection stuck${RESET}"
    else
        echo -e "  SYN_SENT            : ${SYN_SENT}"
    fi
}

print_keepalive() {
    echo -e "\n${BOLD}[ ESTABLISHED CONNECTIONS + KEEPALIVE TIMERS ]${RESET}"
    echo -e "-----------------------------------------------------------"

    CONNS=$(ss -tanop state established | grep ":${PORT}")

    if [ -z "$CONNS" ]; then
        echo -e "  No established connections on port ${PORT}"
        return
    fi

    echo "$CONNS" | while read -r line; do
        REMOTE=$(echo "$line" | awk '{print $5}')
        TIMER=$(echo "$line"  | grep -o 'timer:([^)]*)')

        if echo "$TIMER" | grep -q "keepalive"; then
            echo -e "  ${GREEN}[KEEPALIVE OK]${RESET} ${REMOTE}  ${CYAN}${TIMER}${RESET}"
        elif echo "$TIMER" | grep -q "on"; then
            RETRIES=$(echo "$TIMER" | grep -o ',[0-9]*)'  | tr -d ',)')
            if [ "$RETRIES" -gt 3 ] 2>/dev/null; then
                echo -e "  ${RED}[RETRANSMITTING x${RETRIES}]${RESET} ${REMOTE}  ${TIMER}  << LIKELY DEAD"
            else
                echo -e "  ${YELLOW}[RETRANSMITTING x${RETRIES}]${RESET} ${REMOTE}  ${TIMER}"
            fi
        elif [ -z "$TIMER" ]; then
            echo -e "  ${YELLOW}[NO KEEPALIVE]${RESET} ${REMOTE}  << SO_KEEPALIVE not enabled on this socket"
        else
            echo -e "  ${YELLOW}[UNKNOWN TIMER]${RESET} ${REMOTE}  ${TIMER}"
        fi
    done
}

print_dead_candidates() {
    echo -e "\n${BOLD}[ CLOSE_WAIT — DEAD CONNECTION CANDIDATES ]${RESET}"
    echo -e "-----------------------------------------------------------"

    DEAD=$(ss -tanop | grep ":${PORT}" | grep "CLOSE-WAIT")

    if [ -z "$DEAD" ]; then
        echo -e "  ${GREEN}None detected${RESET}"
        return
    fi

    echo "$DEAD" | while read -r line; do
        REMOTE=$(echo "$line" | awk '{print $5}')
        echo -e "  ${RED}[CLOSE_WAIT]${RESET} ${REMOTE}  << remote closed, local app not cleaned up"
    done
}

print_top_remote_ips() {
    echo -e "\n${BOLD}[ TOP REMOTE IPs ON PORT ${PORT} ]${RESET}"
    echo -e "-----------------------------------------------------------"

    ss -tan | grep ":${PORT}" | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10 | \
    while read -r count ip; do
        if [ "$count" -gt 10 ]; then
            echo -e "  ${RED}${count}  ${ip}  << HIGH connection count${RESET}"
        else
            echo -e "  ${count}  ${ip}"
        fi
    done
}

print_os_keepalive_settings() {
    echo -e "\n${BOLD}[ OS TCP KEEPALIVE SETTINGS ]${RESET}"
    echo -e "-----------------------------------------------------------"
    KA_TIME=$(sysctl -n net.ipv4.tcp_keepalive_time)
    KA_INTVL=$(sysctl -n net.ipv4.tcp_keepalive_intvl)
    KA_PROBES=$(sysctl -n net.ipv4.tcp_keepalive_probes)
    RETRIES2=$(sysctl -n net.ipv4.tcp_retries2)

    echo -e "  tcp_keepalive_time   : ${KA_TIME}s"
    echo -e "  tcp_keepalive_intvl  : ${KA_INTVL}s"
    echo -e "  tcp_keepalive_probes : ${KA_PROBES}"
    echo -e "  tcp_retries2         : ${RETRIES2}"

    WORST_CASE=$((KA_TIME + KA_INTVL * KA_PROBES))
    echo -e "\n  Dead connection detected in worst case: ${BOLD}${WORST_CASE}s${RESET}"

    if [ "$KA_TIME" -ge 7200 ]; then
        echo -e "  ${RED}WARNING: tcp_keepalive_time is at default (2h) — consider tuning${RESET}"
    fi
}

# Main loop
while true; do
    print_header
    print_summary
    print_keepalive
    print_dead_candidates
    print_top_remote_ips
    print_os_keepalive_settings
    echo -e "\n${BOLD}Press Ctrl+C to exit${RESET}"
    sleep "$INTERVAL"
done
