FROM rust:latest

ARG TOOLCHAIN=1.40

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
        libsodium-dev

RUN --mount=type=cache,target=/tmp/cache/cargo                  \
    --mount=type=cache,target=/tmp/cache/target,sharing=private \
    rustup toolchain install $TOOLCHAIN && \
    rustup default           $TOOLCHAIN && \
    rustup component add clippy

RUN     mkdir /srv/secrets
WORKDIR /srv/secrets

ENV CARGO_HOME=/tmp/cache/cargo
ENV CARGO_TARGET_DIR=/tmp/cache/target

# pre-install dependencies so they can be cached
RUN  mkdir ./src && touch ./src/lib.rs
COPY Cargo.toml .
RUN --mount=type=cache,target=/tmp/cache/cargo                  \
    --mount=type=cache,target=/tmp/cache/target,sharing=private \
    cargo build

ARG PROFILE=debug
ARG RUSTFLAGS="-A warnings"
ARG RUSTDOCFLAGS=""

# replace the dummy application with ours
COPY . .

RUN --mount=type=cache,target=/tmp/cache/cargo                  \
    --mount=type=cache,target=/tmp/cache/target,sharing=private \
    cargo clippy && \
    cargo test && \
    cargo doc
