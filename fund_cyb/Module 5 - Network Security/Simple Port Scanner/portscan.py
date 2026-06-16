import socket

print("Basic TCP Port Scanner - Foundations of Cybersecurity @ UniPV\n\n")
print("Technique: the tool tries to establish a connection against a TCP port")
print("Parameters: target (IP or hostname), Starting Port, and Ending Port\n")



target = input("Insert the target IP address or the hostname: ")
start_port = int(input("Initial TCP Port: "))
end_port = int(input("End TCP Port: "))

addr = socket.gethostbyname(target)

print(f"\nScanning {target} / {addr} from port {start_port} to {end_port}\n")



for port in range(start_port, end_port + 1):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(0.5)  # Timeout breve per non aspettare troppo
    
    result = s.connect_ex((target, port))

    print(f"[CLOSED]: Port {port} at {target}")

    if result == 0:
        print(f"\033[31m[OPEN]: Port {port} at {target}\033[0m")
    s.close()