> [!WARNING]
> This project is for personal use only. **Use at your own risk!**

# About
A SSH Client in a container for configure remote port forwarding using Reverse SSH Tunnelling.


### SSH Tunneling Explained

**Exposing service running in localhost of a server behind NAT to the internet**

Consider the scenario below. The client runs a web server on port 3000 but cannot expose this web server to the public internet as the client 
machine is behind NAT. The remote server, on the other hand, can be reachable via the internet. The client can SSH into this remote server. In this situation, how can the client expose the webserver on port `3000` to the internet? Via reverse SSH tunnel!

![diagram](https://github.com/chocolatefrappe/ssh-proxy-client/assets/4363857/4340e986-3e27-420d-a373-41e78c3053ba)

**Example**
1. Run a web server on client localhost port `3000`. 
2. Configure reverse tunnel with command.

   ```bash
   $ ssh -R 80:127.0.0.1:3000 user@<remote_server_ip>
   ```

3. Now, when users from distant internet visit port `80` of the remote server as `http://<remote_server_ip>`, the request is redirected back to the client's local server (port `3000`) via SSH tunnel where the local server handles the request and response.

By default, the remote port forwarding tunnel will bind to the `localhost` of the remote server. To enable it to listen on the public interface (for a scenario like above), set the SSH configuration `GatewayPorts yes` in `sshd_config`.


## Usage

### Important

First, make a copy of the `example` directory to configure for your own use.

### Generate a SSH key pair
Generate a key pair for the SSH Forward Client container.

```sh
ssh-keygen -t ed25519 -f key -C "ssh-proxy-client"
```

> [!NOTE]
> Please do not set a passphrase for the key pair.

### Deploy the stack
To deploy the stack, run the following command:

```sh
make deploy
```

> [!NOTE]
> You might need to set the REMOTE_USER & REMOTE_HOST variable for the `make deploy` command.
> e.g. `make deploy REMOTE_USER=ubuntu REMOTE_HOST=192.168.0.10`
>
> Or create a `.env` file with the following content:
> ```env
> REMOTE_USER=ubuntu
> REMOTE_HOST=192.168.0.10
> ```

### Teardown the stack
To teardown the stack, run the following command:

```sh
make teardown
```

## License
Licensed under Apache License, Version 2.0. See [LICENSE](LICENSE) for more details.
