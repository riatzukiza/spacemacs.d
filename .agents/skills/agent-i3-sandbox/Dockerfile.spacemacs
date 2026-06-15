ARG CORE_IMAGE=agent-i3-core
FROM ${CORE_IMAGE}

USER root
RUN apt-get update && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*
USER agent
WORKDIR /home/agent

ARG SPACEMACS_REF=develop
RUN rm -rf .emacs.d \
 && git clone --branch ${SPACEMACS_REF} --depth 1 https://github.com/syl20bnr/spacemacs .emacs.d

RUN mkdir -p /home/agent/.emacs.d/private

COPY --chown=agent:agent .spacemacs.agent /home/agent/.spacemacs
COPY --chown=agent:agent scripts/warmup-spacemacs /home/agent/bin/warmup-spacemacs
RUN chmod +x /home/agent/bin/warmup-spacemacs

# Warm Spacemacs package installation so first container boot is fast.
# This is best-effort: if a package fails or the private layer is not yet
# mounted, the build still succeeds and packages will be installed at runtime.
RUN /home/agent/bin/warmup-spacemacs || true

WORKDIR /workspace
ENTRYPOINT ["/home/agent/bin/agent-entrypoint"]
