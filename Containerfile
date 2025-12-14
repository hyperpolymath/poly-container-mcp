# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
#
# Containerfile - works with podman, nerdctl, docker, buildah
# Uses official Deno image (distroless-based, minimal attack surface)

FROM denoland/deno:2.1.4

LABEL org.opencontainers.image.title="poly-container-mcp"
LABEL org.opencontainers.image.description="Multi-runtime container management MCP server (nerdctl, podman, docker)"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="Jonathan D.A. Jewell"
LABEL org.opencontainers.image.source="https://github.com/hyperpolymath/poly-container-mcp"
LABEL org.opencontainers.image.licenses="MIT"
LABEL dev.mcp.server="true"
LABEL io.modelcontextprotocol.server.name="io.github.hyperpolymath/poly-container-mcp"

WORKDIR /app

# Copy source files
COPY index.js deno.json ./
COPY adapters/ ./adapters/
# src/ contains ReScript source (optional)
COPY src/ ./src/

# Cache dependencies using deno.json config
RUN deno cache --config=deno.json index.js

# Create non-root user
RUN addgroup --system polyglot && adduser --system --ingroup polyglot polyglot
USER polyglot

# Container CLIs (nerdctl, podman, docker) are expected to be:
# - Mounted from host, OR
# - Available via socket connection
ENV CONTAINER_RUNTIME=auto

# Default entrypoint using deno.json config
ENTRYPOINT ["deno", "run", "--config=deno.json", "--allow-run", "--allow-read", "--allow-env", "index.js"]
