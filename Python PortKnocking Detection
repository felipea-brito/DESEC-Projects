#!/usr/bin/env python3

import socket
import struct
import time
import threading
import sys
import random
import argparse

KNOCK_SEQUENCE = [
    (1238,  13,    1306860687, 647848195,  512),
    (2879,  37,    39802457,   215263841,  512),
    (2116,  30000, 929670645,  1944988624, 512),
    (1863,  3000,  737844619,  1510394124, 512),
    (1972,  1337,  1436094750, 1739702764, 512),
]

BACKDOOR_PORT  = 1337
CALLBACK_PORT  = 1972
KNOCK_INTERVAL = 1.0
LISTEN_TIMEOUT = 8

def checksum(data: bytes) -> int:
    """Checksum RFC 793."""
    if len(data) % 2:
        data += b'\x00'
    s = sum((data[i] << 8) + data[i+1] for i in range(0, len(data), 2))
    s = (s >> 16) + (s & 0xFFFF)
    return (~(s + (s >> 16))) & 0xFFFF


def build_packet(src_ip: str, dst_ip: str,
                 sport: int, dport: int,
                 seq: int, ack_raw: int, window: int) -> bytes:

    src = socket.inet_aton(src_ip)
    dst = socket.inet_aton(dst_ip)
    ip_id  = random.randint(0, 65535)
    ip_hdr = struct.pack('!BBHHHBBH4s4s',
        0x45, 0, 40, ip_id, 0, 64, socket.IPPROTO_TCP, 0, src, dst)
    ip_hdr = struct.pack('!BBHHHBBH4s4s',
        0x45, 0, 40, ip_id, 0, 64, socket.IPPROTO_TCP,
        checksum(ip_hdr), src, dst)

    pseudo  = struct.pack('!4s4sBBH', src, dst, 0, socket.IPPROTO_TCP, 20)
    tcp_hdr = struct.pack('!HHIIBBHHH',
        sport, dport, seq, ack_raw, 0x50, 0x02, window, 0, 0)
    tcp_hdr = struct.pack('!HHIIBBHHH',
        sport, dport, seq, ack_raw, 0x50, 0x02, window,
        checksum(pseudo + tcp_hdr), 0)

    return ip_hdr + tcp_hdr


def get_local_ip() -> str:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.connect(("8.8.8.8", 80))
        return s.getsockname()[0]

def listen_for_callback(local_ip: str, timeout: int, result: dict):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_TCP)
        sock.settimeout(1.0)
        sock.bind((local_ip, 0))
    except PermissionError:
        result["error"] = "permission"
        return

    deadline = time.time() + timeout
    try:
        while time.time() < deadline:
            try:
                pkt, _ = sock.recvfrom(65535)
                if len(pkt) < 40:
                    continue

                # Parse IP
                ihl    = (pkt[0] & 0x0F) * 4
                proto  = pkt[9]
                src_ip = socket.inet_ntoa(pkt[12:16])

                if proto != socket.IPPROTO_TCP or len(pkt) < ihl + 20:
                    continue

                # Parse TCP
                tcp   = pkt[ihl:ihl + 20]
                sp, dp = struct.unpack('!HH', tcp[0:4])
                seq,   = struct.unpack('!I',  tcp[4:8])
                flags  = tcp[13]
                win,   = struct.unpack('!H',  tcp[14:16])
                if (flags & 0x12) == 0x12 and sp == BACKDOOR_PORT and dp == CALLBACK_PORT:
                    result.update(
                        detected=True, src_ip=src_ip,
                        seq=seq, window=win
                    )
                    return

            except socket.timeout:
                continue
    finally:
        sock.close()

def scan(target: str, timeout: int = LISTEN_TIMEOUT, verbose: bool = True) -> bool:
    local_ip = get_local_ip()

    if verbose:
        print("=" * 60)
        print("  DETECTOR DE MALWARE — Port Knocking Scanner")
        print("=" * 60)
        print(f"  Alvo      : {target}")
        print(f"  IP local  : {local_ip}")
        print(f"  Sequência : 13 → 37 → 30000 → 3000 → 1337")
        print(f"  Detecta   : SYN-ACK de porta {BACKDOOR_PORT} → {CALLBACK_PORT}")
        print(f"  Timeout   : {timeout}s")
        print("=" * 60)

    result = {}

    t = threading.Thread(
        target=listen_for_callback,
        args=(local_ip, timeout, result),
        daemon=True
    )
    t.start()
    time.sleep(0.3)

    if result.get("error") == "permission":
        print("[ERRO] Execute com sudo — raw socket requer root.")
        sys.exit(1)

    try:
        raw = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_RAW)
        raw.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1)
    except PermissionError:
        print("[ERRO] Execute com sudo — raw socket requer root.")
        sys.exit(1)

    if verbose:
        print("\n[*] Enviando knock sequence...\n")

    for i, (sp, dp, seq, ack_raw, win) in enumerate(KNOCK_SEQUENCE):
        pkt = build_packet(local_ip, target, sp, dp, seq, ack_raw, win)
        raw.sendto(pkt, (target, 0))
        if verbose:
            print(f"  [→] Knock {i+1}/5  dport={dp:<6}  sport={sp}  "
                  f"seq=0x{seq:08x}  win={win}")
        time.sleep(KNOCK_INTERVAL)

    raw.close()

    if verbose:
        print(f"\n[*] Aguardando callback em :{CALLBACK_PORT} ({timeout}s)...")

    t.join(timeout=timeout + 2)
    print()
    if result.get("detected"):
        print(f"{result['src_ip']:<43}")
        print(f"porta {BACKDOOR_PORT}")
        print(f"porta {CALLBACK_PORT}")
        return True
    else:
        return False

if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="Detecta malware Port Knocking replicando comportamento do pcap capturado"
    )
    ap.add_argument("target", help="IP do servidor alvo")
    ap.add_argument("-t", "--timeout", type=int, default=LISTEN_TIMEOUT,
                    help=f"Timeout em segundos (padrão: {LISTEN_TIMEOUT})")
    ap.add_argument("-q", "--quiet", action="store_true",
                    help="Saída mínima — apenas resultado final")
    args = ap.parse_args()

    infected = scan(args.target, timeout=args.timeout, verbose=not args.quiet)
    sys.exit(1 if infected else 0)
