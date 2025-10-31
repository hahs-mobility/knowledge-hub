---
icon: material/console
title: AutoSSH Step-by-Step Guide
---

This guide will walk you through the process of setting up and configuring AutoSSH to create persistent SSH tunnels.

!!! note "About Host Key Verification"

    The examples in this guide include `StrictHostKeyChecking=no` and `UserKnownHostsFile=/dev/null` options, which are suitable for **dynamic environments** where remote hosts may change (containers, cloud instances, auto-scaling). 

    **For static environments** with consistent hosts, you can remove these options for better security.

## Prerequisites

Before you begin, ensure you have:

- SSH access to the target server
- SSH key-based authentication configured (recommended)
- AutoSSH installed on your local machine
- Basic understanding of SSH and port forwarding concepts

## Step 1: Install AutoSSH

### On Ubuntu/Debian

```bash title="Install AutoSSH on Ubuntu/Debian"
sudo apt update
sudo apt install autossh
```

### On CentOS/RHEL/Fedora

```bash title="Install AutoSSH on CentOS/RHEL/Fedora"
sudo yum install autossh
# or for newer versions
sudo dnf install autossh
```

## Step 2: Configure SSH Key Authentication

1. Generate SSH key pair (if you don't have one):

   ```bash title="Generate SSH key pair"
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

2. Copy your public key to the remote server:

   ```bash title="Copy SSH public key to remote server"
   ssh-copy-id username@remote-server.com
   ```

3. Test the connection:

   ```bash title="Test SSH connection"
   ssh username@remote-server.com
   ```

## Step 3: Basic AutoSSH Usage

### Simple Port Forwarding

Forward local port 8080 to remote server's port 80:

```bash title="Simple port forwarding with AutoSSH" hl_lines="1-4"
autossh -M 0 -i ~/.ssh/ssh_key \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -L 8080:localhost:80 username@remote-server.com
```

### Reverse Port Forwarding

Forward remote port 8080 to local port 80:

```bash title="Reverse port forwarding with AutoSSH" hl_lines="1-4"
autossh -M 0 -i ~/.ssh/ssh_key \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -R 8080:localhost:80 username@remote-server.com
```

### Dynamic Port Forwarding (SOCKS Proxy)

Create a SOCKS proxy on local port 1080:

```bash title="Dynamic port forwarding (SOCKS proxy)" hl_lines="1-4"
autossh -M 0 -i ~/.ssh/ssh_key \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -D 1080 username@remote-server.com
```

## Step 4: Advanced Configuration

### Complete CLI Command

Instead of using SSH config files, specify all options directly in the command line:

```bash title="Complete CLI command with all options" hl_lines="1 4-5"
autossh -M 0 -N -i ~/.ssh/ssh_key \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=10 \
  -o ConnectTimeout=30 \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o IdentitiesOnly=yes \
  -o PasswordAuthentication=no \
  -o TCPKeepAlive=yes \
  -L 8080:localhost:80 \
  username@remote-server.com
```

### Background Operation

Run AutoSSH in the background:

```bash title="Background AutoSSH operation" hl_lines="1"
autossh -M 0 -f -N -i ~/.ssh/ssh_key \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=10 \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -L 8080:localhost:80 \
  username@remote-server.com
```

Options explained:

- `-M 0`: Disable AutoSSH's built-in monitoring ports, rely on SSH's ServerAliveInterval instead
- `-f`: Run in background
- `-N`: Don't execute remote commands
- `-i ~/.ssh/ssh_key`: Specify the SSH private key to use
- `-L`: Local port forwarding
- `-o ServerAliveInterval=60`: Send keepalive every 60 seconds
- `-o ServerAliveCountMax=10`: Allow 10 failed keepalives before disconnecting

## Command Line Options Reference

Here's a comprehensive breakdown of AutoSSH and SSH options commonly used in production environments:

### Example Production Command

```bash title="Production AutoSSH command with all options" hl_lines="1-12"
autossh -M 0 -N -i ~/.ssh/ssh_key \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=10 \
  -o ConnectTimeout=30 \
  -o ExitOnForwardFailure=no \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o IdentitiesOnly=yes \
  -o PasswordAuthentication=no \
  -o TCPKeepAlive=yes \
  -L 8080:localhost:80 \
  user@ipaddr
```

### AutoSSH Options

- **`-M 0`**: Disable AutoSSH's built-in monitoring port mechanism. When set to 0, AutoSSH relies on SSH's `ServerAliveInterval` and `ServerAliveCountMax` for connection monitoring instead of creating its own monitoring ports.

- **`-N`**: Don't execute any remote commands. This is essential for port forwarding as you only want the tunnel, not an interactive shell session.

### SSH Connection Options (`-o` flags)

#### Connection Monitoring
- **`ServerAliveInterval=60`**: Send a keepalive message to the server every 60 seconds. This helps detect if the connection has been dropped and prevents NAT timeouts.

- **`ServerAliveCountMax=10`**: Maximum number of server alive messages that can be sent without receiving a response before SSH disconnects. Combined with `ServerAliveInterval=60`, the connection will timeout after 10 minutes (60s × 10) of no response.

- **`TCPKeepAlive=yes`**: Enable TCP keepalive messages. This works at the TCP level (below SSH) to detect dead connections and prevent intermediate devices from dropping idle connections.

#### Connection Establishment
- **`ConnectTimeout=30`**: Maximum time (in seconds) to wait when establishing the initial connection. If the connection cannot be established within 30 seconds, it will timeout and fail.

#### Error Handling
- **`ExitOnForwardFailure=no`**: Don't exit if port forwarding fails. This allows the SSH connection to remain active even if the specific port forward cannot be established, which can be useful for resilient connections.

#### Security Options
- **`StrictHostKeyChecking=no`**: Don't prompt to verify the server's host key. This bypasses the "unknown host" prompt but reduces security as it won't detect man-in-the-middle attacks. Use with caution.

- **`UserKnownHostsFile=/dev/null`**: Don't save or read host keys from the known_hosts file. Combined with `StrictHostKeyChecking=no`, this prevents host key verification entirely.

- **`IdentitiesOnly=yes`**: Only use explicitly specified SSH keys, ignore SSH agent and default key locations. This ensures predictable authentication behavior.

- **`PasswordAuthentication=no`**: Disable password authentication, forcing key-based authentication only. This improves security and prevents password prompts.

!!! warning "When to Use Host Key Bypass Options"

    The options `StrictHostKeyChecking=no` and `UserKnownHostsFile=/dev/null` should **only** be used when the remote host is expected to change:

    - **Dynamic environments**: Container deployments, auto-scaling groups, load balancers
    - **Cloud infrastructure**: Instances with changing IP addresses or host keys
    - **Development environments**: Frequently recreated servers

    **For stable environments** with consistent hosts, **remove these options** and use proper host key verification for better security.

#### Port Forwarding
- **`-L 8080:localhost:80`**: Create a local port forward from local port 8080 to port 80 on the remote server's localhost. Format is `local_port:remote_host:remote_port`.

## Step 5: Create Persistent Service

### Using systemd (Linux)

Create `/etc/systemd/system/autossh-tunnel.service`:

```ini title="systemd service configuration for AutoSSH" hl_lines="8-17"
[Unit]
Description=AutoSSH Tunnel
After=network.target

[Service]
Type=simple
User=yourusername
ExecStart=/usr/bin/autossh -M 0 -N -i /home/yourusername/.ssh/ssh_key \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=10 \
  -o ConnectTimeout=30 \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o IdentitiesOnly=yes \
  -o PasswordAuthentication=no \
  -o TCPKeepAlive=yes \
  -L 8080:localhost:80 username@remote-server.com
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash title="Enable and start AutoSSH systemd service"
sudo systemctl daemon-reload
sudo systemctl enable autossh-tunnel.service
sudo systemctl start autossh-tunnel.service
```

## Step 6: Testing and Troubleshooting

### Verify the Tunnel

Test that your tunnel is working:

```bash title="Verify tunnel functionality" hl_lines="2 5"
# For local port forwarding
curl http://localhost:8080

# Check if the process is running
ps aux | grep autossh
```

### Advanced Testing with Netcat

For more comprehensive tunnel testing, use netcat (nc) to test connectivity:

```bash title="Test tunnel connectivity with netcat" hl_lines="2 5 8 11"
# Test if local port is listening
nc -zv localhost 8080

# Test connection from the tunnel endpoint (run on remote server)
nc -l 80

# Send test data through the tunnel
echo "test message" | nc localhost 8080

# Test UDP forwarding (if configured)
nc -u localhost 8080
```

Test scenarios:

1. **Port availability**: Use `nc -zv` to verify the local port is listening
2. **Data transmission**: Send test data through the tunnel to verify bidirectional communication
3. **Connection persistence**: Monitor if connections remain stable over time
4. **Multiple connections**: Test concurrent connections through the tunnel

### Common Issues and Solutions

1. **Connection Refused**: Check if the remote service is running and accessible
2. **Port Already in Use**: Choose a different local port
3. **SSH Key Issues**: Verify SSH key authentication works manually
4. **Firewall Blocking**: Ensure required ports are open

### Monitoring Options

Set environment variables for better monitoring:

```bash title="AutoSSH monitoring environment variables" hl_lines="1-3"
export AUTOSSH_LOGFILE=/var/log/autossh.log
export AUTOSSH_LOGLEVEL=7
export AUTOSSH_DEBUG=1
```

## Step 7: Security Best Practices

1. **Use Key-Based Authentication**: Never use password authentication
2. **Restrict SSH Access**: Configure SSH to allow only key-based auth
3. **Limit Port Forwarding**: Use `PermitTunnel` and `AllowTcpForwarding` directives
4. **Monitor Connections**: Regularly check tunnel status and logs
5. **Use Non-Standard Ports**: Avoid well-known ports when possible

## Example Use Cases

### Database Access Through Bastion

```bash title="Database access through bastion host" hl_lines="6"
autossh -M 0 -i ~/.ssh/ssh_key \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=10 \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -L 5432:database-server:5432 \
  username@bastion-host.com
```

### Web Development Server Access

```bash title="Web development server access" hl_lines="6"
autossh -M 0 -i ~/.ssh/ssh_key \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=10 \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -L 3000:internal-dev-server:3000 \
  username@gateway.company.com
```

### Multiple Port Forwarding

```bash title="Multiple port forwarding example" hl_lines="6-8"
autossh -M 0 -i ~/.ssh/ssh_key \
  -o ServerAliveInterval=60 \
  -o ServerAliveCountMax=10 \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -L 8080:web-server:80 \
  -L 3306:db-server:3306 \
  -L 6379:redis-server:6379 \
  username@bastion.com
```

!!! tip "Pro Tips"

    - When using `-M 0`, always include `-o ServerAliveInterval=60` and `-o ServerAliveCountMax=10` for proper connection monitoring
    - Always specify the SSH key explicitly with `-i ~/.ssh/ssh_key` for predictable authentication
    - Consider using SSH multiplexing for multiple connections to the same host
    - Always test your tunnels in a non-production environment first
