# fish-proxy

A [fish shell](https://fishshell.com) plugin to configure proxy

It is the fish version of [zsh-proxy](https://github.com/SukkaW/zsh-proxy), thanks to [Sukka](https://github.com/SukkaW)

## Install

use [fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher install kaze-k/fish-proxy
```

----

Congratulations! Open a new terminal. If you see following lines, you have successfully installed `fish-proxy`:

```
----------------------------------------
You should run following command first:
> init_proxy
----------------------------------------
```

## Usage

### `init_proxy`

The tip mentioned below will show up next time you open a new terminal if you haven't  initialized the plugin with `init_proxy`.

After you run `init_proxy`, it is time to configure the plugin.

### `config_proxy`

Execute `config_proxy` will lead you to fish-proxy configuration. Fill in socks5 & http proxy address in format `address:port` like `127.0.0.1:1080` & `127.0.0.1:8080`.

Default configuration of socks5 proxy is `127.0.0.1:1080`, and http proxy is `127.0.0.1:8080`. You can leave any of them blank during configuration to use their default configuration.

Currently `fish-proxy` doesn't support proxy with authentication, but I am working on it.

### `proxy`

After you configure the `fish-proxy`, you are good to go. Try following command will enable proxy for supported package manager & software:

```fish
proxy
```

And next time you open a new terminal, fish-proxy will automatically enable proxy for you.

### `noproxy`

If you want to disable proxy, you can run following command:

```fish
noproxy
```

### `myip`

If you forget whether you have enabled proxy or not, it is fine to run `proxy` command directly, as `proxy` will reset all the proxy before enable them. But the smarter way is to use following command to check which IP you are using now:

```fish
myip
```

Check procedure will use `curl` and the IP data come from `ipip.net`, `ip.cn` & `ip.gs`.

## Uninstallation

```fish
fisher uninstall kaze-k/fish-proxy
rm -rf ~/.fish-proxy
```

## Supported

`fish-proxy` currently support those package manager & software:

- `http_proxy`
- `https_proxy`
- `ftp_proxy`
- `rsync_proxy`
- `all_proxy`
- git (http)
- npm & yarn & pnpm

## Thanks

- [@Sukka](https://github.com/SukkaW)
