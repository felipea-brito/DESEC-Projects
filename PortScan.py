#!/usr/bin/python3

import socket


def scan_port(ip, port, timeout=1):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(timeout)
        if s.connect_ex((ip, port)) == 0:
            banner = ""
            try:
                s.settimeout(2)
                banner = s.recv(1024).decode(errors="ignore").strip()
            except OSError:
                pass
            return True, banner
        return False, ""


def scan_range(ip, start, end):
    for port in range(start, end + 1):
        is_open, banner = scan_port(ip, port)
        if is_open:
            print(f"Open port: {port}" + (f" -> {banner}" if banner else ""))


def main():
    ip = input("Type the IP: ")
    print("Type [1] to scan ports 1-1024")
    print("Type [2] to scan ports 1-65535")
    print("Type [3] to scan a specific port")
    option = int(input("Type the option: "))

    match option:
        case 1:
            scan_range(ip, 1, 1024)
        case 2:
            scan_range(ip, 1, 65535)
        case 3:
            port = int(input("Type the port: "))
            is_open, banner = scan_port(ip, port)
            if is_open:
                print(f"Open port: {port}" + (f" -> {banner}" if banner else ""))
            else:
                print("Closed port")
        case _:
            print("Invalid option")


if __name__ == "__main__":
    main()
