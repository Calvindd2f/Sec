import socket

dns_server_ip = '8.8.8.8'

server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_socket.bind(('',53))


server_socket.setblocking(False)

# List of redirects
redirects = {
    'www.example1.com': '192.168.1.10',
    'www.example2.com': '192.168.1.20'
}

while True:
    # receive the data from the client
    try:
        data, address = server_socket.recvfrom(4096)
    except:
        pass
    else:
        # extract the domain name from the DNS query
        domain = data[12:-4].decode()
        if domain in redirects:
            ip_address = redirects[domain]
            server_socket.sendto(ip_address.encode(), address)
        else:
            # forward the DNS query to the DNS server
            server_socket.sendto(data, (dns_server_ip, 53))
