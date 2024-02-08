#!/bin/fish
#  _____ ___ ____  _   _ ____                      
# |  ___|_ _/ ___|| | | |  _ \ _ __ _____  ___   _ 
# | |_   | |\___ \| |_| | |_) | '__/ _ \ \/ / | | |
# |  _|  | | ___) |  _  |  __/| | | (_) >  <| |_| |
# |_|   |___|____/|_| |_|_|   |_|  \___/_/\_\\__, |
#                                            |___/ 
# -------------------------------------------------

function __hide_cursor -d "hide cursor"
  echo -ne "\033[?25l"
end

function __show_cursor -d "show cursor"
  echo -ne "\033[?25h"
end

function __read_proxy_config -d "read proxy configuration"
  set -g __FISHPROXY_STATUS (cat $HOME/.fish-proxy/status)
  set -g __FISHPROXY_SOCKS5 (cat $HOME/.fish-proxy/socks5)
  set -g __FISHPROXY_HTTP (cat $HOME/.fish-proxy/http)
  set -g __FISHPROXY_NO_PROXY (cat $HOME/.fish-proxy/no_proxy)
  set -g __FISHPROXY_GIT_PROXY_TYPE (cat $HOME/.fish-proxy/git_proxy_type)
end

function __check_whether_init -d "check whether fish-proxy is initialized"
  if [ ! -f "$HOME/.fish-proxy/status" ] || [ ! -f "$HOME/.fish-proxy/http" ] || [ ! -f "$HOME/.fish-proxy/socks5" ] || [ ! -f "$HOME/.fish-proxy/no_proxy" ]
    echo "----------------------------------------"
    echo "You should run following command first:"
    set_color -o green
    echo "> init_proxy"
    set_color normal
    echo "----------------------------------------"
  else
    __read_proxy_config
  end
end

function __check_ip -d "check your IP"
  __hide_cursor
  echo "========================================"
  echo "Check what your IP is"
  echo "----------------------------------------"
  set -l ipv4 (curl -s -k https://api-ipv4.ip.sb/ip -H 'user-agent: fish-proxy')
  if [ "$ipv4" != "" ]
    set_color -o green
    echo "IPv4: $ipv4"
    set_color normal
  else
    set_color -o red
    echo "IPv4: -"
    set_color normal
  end
  echo "----------------------------------------"
  set -l ipv6 (curl -s -k -m10 https://api-ipv6.ip.sb/ip -H 'user-agent: fish-proxy')
  if [ "$ipv6" != "" ]
    set_color -o blue
    echo "IPv6: $ipv6"
    set_color normal
  else
    set_color -o red
    echo "IPv6: -"
    set_color normal
  end
  if command -v python >/dev/null
    set -l geoip (curl -s -k https://api.ip.sb/geoip -H 'user-agent: fish-proxy')
    if [ "$geoip" != "" ]
      echo "----------------------------------------"
      set_color -o cyan
      echo "Info: "
      echo "$geoip" | python -m json.tool
      set_color normal
    end
  end
  echo "========================================"
  __show_cursor
end

function __config_proxy -d "config proxy"
  echo "========================================"
  echo "FISH Proxy Plugin Config"
  echo "----------------------------------------"

  echo -n "[socks5 proxy] {Default as 127.0.0.1:1080}
(address:port): "
  read -l __read_socks5

  echo -n "[socks5 type] Select the proxy type you want to use {Default as socks5}:
1. socks5
2. socks5h (resolve DNS through the proxy server)
(1 or 2): "
  read -l __read_socks5_type

  echo -n "[http proxy]   {Default as 127.0.0.1:8080}
(address:port): "
  read -l __read_http

  echo -n "[no proxy domain] {Default as 'localhost,127.0.0.1,localaddress,.localdomain.com'}
(comma separate domains): "
  read -l __read_no_proxy

  echo -n "[git proxy type] {Default as socks5}
(socks5 or http): "
  read -l __read_git_proxy_type
  echo "========================================"

  if [ -z "$__read_socks5" ]
    set __read_socks5 "127.0.0.1:1080"
  end
  if [ -z "$__read_socks5_type" ]
    set __read_socks5_type "1"
  end
  if [ -z "$__read_http" ]
    set __read_http "127.0.0.1:8080"
  end
  if [ -z "$__read_no_proxy" ]
    set __read_no_proxy "localhost,127.0.0.1,localaddress,.localdomain.com"
  end
  if [ -z "$__read_git_proxy_type" ]
    set __read_git_proxy_type "socks5"
  end

  echo "http://$__read_http" >"$HOME/.fish-proxy/http"
  if [ "$__read_socks5_type" = "2" ]
    echo "socks5h://$__read_socks5" >"$HOME/.fish-proxy/socks5"
  else
    echo "socks5://$__read_socks5" >"$HOME/.fish-proxy/socks5"
  end
  echo "$__read_no_proxy" >"$HOME/.fish-proxy/no_proxy"
  echo "$__read_git_proxy_type" >"$HOME/.fish-proxy/git_proxy_type"

  __read_proxy_config
end

# Proxy for terminal

function __enable_proxy_all -d "enable proxy for all"
  # http_proxy
  set -gx http_proxy "$__FISHPROXY_HTTP"
  set -gx HTTP_PROXY "$__FISHPROXY_HTTP"
  # https_proxy
  set -gx https_proxy "$__FISHPROXY_HTTP"
  set -gx HTTPS_PROXY "$__FISHPROXY_HTTP"
  # ftp_proxy
  set -gx ftp_proxy "$__FISHPROXY_HTTP"
  set -gx FTP_PROXY "$__FISHPROXY_HTTP"
  # rsync_proxy
  set -gx rsync_proxy "$__FISHPROXY_HTTP"
  set -gx RSYNC_PROXY "$__FISHPROXY_HTTP"
  # all_proxy
  set -gx ALL_PROXY "$__FISHPROXY_SOCKS5"
  set -gx all_proxy "$__FISHPROXY_SOCKS5"

  set -gx no_proxy "$__FISHPROXY_NO_PROXY"
end

function __disable_proxy_all -d "disable proxy for all"
  set -e http_proxy
  set -e HTTP_PROXY
  set -e https_proxy
  set -e HTTPS_PROXY
  set -e ftp_proxy
  set -e FTP_PROXY
  set -e rsync_proxy
  set -e RSYNC_PROXY
  set -e ALL_PROXY
  set -e all_proxy
  set -e no_proxy
end

# Proxy for Git

function __enable_proxy_git -d "enable proxy for git"
  if [ "$__FISHPROXY_GIT_PROXY_TYPE" = "http" ]
    git config --global http.proxy "$__FISHPROXY_HTTP"
    git config --global https.proxy "$__FISHPROXY_HTTP"
  else
    git config --global http.proxy "$__FISHPROXY_SOCKS5"
    git config --global https.proxy "$__FISHPROXY_SOCKS5"
  end
end

function __disable_proxy_git -d "disable proxy for git"
  git config --global --unset http.proxy
  git config --global --unset https.proxy
end

# NPM

function __enable_proxy_npm -d "enable proxy for npm"
  if command -v npm >/dev/null
    npm config set proxy "$__FISHPROXY_HTTP" >/dev/null 2>&1
    npm config set https-proxy "$__FISHPROXY_HTTP" >/dev/null 2>&1
    set_color -o green
    echo "- npm"
    set_color normal
  end
  if command -v yarn >/dev/null
    yarn config set proxy "$__FISHPROXY_HTTP" >/dev/null 2>&1
    yarn config set https-proxy "$__FISHPROXY_HTTP" >/dev/null 2>&1
    set_color -o blue
    echo "- yarn"
    set_color normal
  end
  if command -v pnpm >/dev/null
    pnpm config set proxy "$__FISHPROXY_HTTP" >/dev/null 2>&1
    pnpm config set https-proxy "$__FISHPROXY_HTTP" >/dev/null 2>&1
    set_color -o magenta
    echo "- pnpm"
    set_color normal
  end
end

function __disable_proxy_npm -d "disable proxy for npm"
  if command -v npm >/dev/null
    npm config delete proxy >/dev/null 2>&1
    npm config delete https-proxy >/dev/null 2>&1
  end
  if command -v yarn >/dev/null
    yarn config delete proxy >/dev/null 2>&1
    yarn config delete https-proxy >/dev/null 2>&1
  end
  if command -v pnpm >/dev/null
    pnpm config delete proxy >/dev/null 2>&1
    pnpm config delete https-proxy >/dev/null 2>&1
  end
end

# ==================================================

function __enable_proxy -d "enable proxy"
  if [ -z "$__FISHPROXY_STATUS" ] || [ -z "$__FISHPROXY_SOCKS5" ] || [ -z "$__FISHPROXY_HTTP" ]
    echo "========================================"
    echo "fish-proxy can not read configuration."
    echo "You may have to reinitialize and reconfigure the plugin."
    echo "Use following commands would help:"
    set_color -o green
    echo "> init_proxy"
    echo "> config_proxy"
    echo "> proxy"
    set_color normal
    echo "========================================"
  else
    echo "========================================"
    echo -n "Resetting proxy... "
    __disable_proxy_all
    __disable_proxy_git
    __disable_proxy_npm
    set_color -i green
    echo "Done!"
    set_color normal
    __hide_cursor
    echo "----------------------------------------"
    set_color red
    echo "Enable proxy for:"
    set_color normal
    set_color -o yellow
    echo "- shell"
    set_color normal
    __enable_proxy_all
    set_color -o cyan
    echo "- git"
    set_color normal
    __enable_proxy_git
    # npm & yarn & pnpm"
    __enable_proxy_npm
    set_color -o -i black -b green
    echo -n "Done!"
    set_color normal
    echo ""
    __show_cursor
  end
end

function __disable_proxy -d "disable proxy"
  __disable_proxy_all
  __disable_proxy_git
  __disable_proxy_npm
end

function __auto_proxy -d "auto proxy"
  if [ "$__FISHPROXY_STATUS" = "1" ]
    __enable_proxy_all
  end
end

# ==================================================

function init_proxy -d "initialize fish-proxy"
  mkdir -p "$HOME/.fish-proxy"
  touch "$HOME/.fish-proxy/status"
  echo "0" >"$HOME/.fish-proxy/status"
  touch "$HOME/.fish-proxy/http"
  touch "$HOME/.fish-proxy/socks5"
  touch "$HOME/.fish-proxy/no_proxy"
  touch "$HOME/.fish-proxy/git_proxy_type"
  echo "----------------------------------------"
  echo "Great! The fish-proxy is initialized"
  echo ""
  set_color -o blue
  echo -E '  _____ ___ ____  _   _ ____                       '
  echo -E ' |  ___|_ _/ ___|| | | |  _ \ _ __ _____  ___   _  '
  echo -E " | |_   | |\___ \| |_| | |_) | '__/ _ \ \/ / | | | "
  echo -E ' |  _|  | | ___) |  _  |  __/| | | (_) >  <| |_| | '
  echo -E ' |_|   |___|____/|_| |_|_|   |_|  \___/_/\_\\__, | '
  echo -E '                                            |___/  '
  set_color normal
  echo "----------------------------------------"
  echo "Now you might want to run following command:"
  set_color -o green
  echo "> config_proxy"
  set_color normal
  echo "----------------------------------------"
end

function config_proxy -d "config proxy"
  __config_proxy
end

function proxy -d "enable proxy"
  echo "1" >"$HOME/.fish-proxy/status"
  __enable_proxy
  __check_ip
end

function noproxy -d "disable proxy"
  echo "0" >"$HOME/.fish-proxy/status"
  __disable_proxy
  __check_ip
end

function myip -d "show your IP"
  __check_ip
end

__check_whether_init
__auto_proxy
