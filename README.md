> [!WARNING]
> This project is for personal use only.
>
> **Use at your own risk!**

# ssh-proxy-client
A SSH Client for configure port forwarding as a container.

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
