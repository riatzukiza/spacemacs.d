FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    XDG_RUNTIME_DIR=/tmp/runtime-agent \
    HOME=/home/agent \
    SHELL=/bin/bash \
    EMACS_DAEMON_NAME=agent-core

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    dbus-x11 \
    emacs \
    i3-wm \
    jq \
    procps \
    rofi \
    rxvt-unicode \
    x11-apps \
    xauth \
    xdotool \
    x11-utils \
    xvfb \
    xterm \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash agent \
 && mkdir -p /workspace /tmp/runtime-agent /opt/agent \
 && chown -R agent:agent /workspace /tmp/runtime-agent /home/agent /opt/agent

USER agent
WORKDIR /workspace

RUN mkdir -p /home/agent/.config/i3 /home/agent/.emacs.d /home/agent/bin

COPY --chown=agent:agent i3.config /home/agent/.config/i3/config
COPY --chown=agent:agent init.el /home/agent/.emacs.d/init.el
COPY --chown=agent:agent scripts/ /home/agent/bin/
RUN chmod +x /home/agent/bin/*

ENTRYPOINT ["/home/agent/bin/agent-entrypoint"]
