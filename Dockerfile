FROM ubuntu:latest
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update
RUN apt-get install --yes build-essential protobuf-compiler curl cmake golang libssl-dev vim less

# Create the non-root user.
RUN useradd tikv -m -b /home
USER tikv
RUN mkdir -p ~/tikv-example/src && mkdir ~/client-rust

# Install Rust
COPY rust-toolchain /home/tikv/tikv-example/
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain `cat /home/tikv/tikv-example/rust-toolchain` -y
ENV PATH="/home/tikv/.cargo/bin:${PATH}"

# Fetch, then prebuild all deps
COPY Cargo.toml rust-toolchain /home/tikv/tikv-example/
COPY src /home/tikv/tikv-example/src/
COPY client-rust /home/tikv/client-rust
WORKDIR /home/tikv/tikv-example
RUN cargo fetch
RUN cargo build --release
#ENTRYPOINT /home/tikv/tikv-example/target/release/tikv-example
