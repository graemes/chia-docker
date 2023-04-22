# FROM python:3.11 as chia-build

# ARG BRANCH=latest
# ARG COMMIT=""

# RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
#     DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
#     DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
#         lsb-release sudo unzip

# WORKDIR /chia-blockchain

# RUN echo "cloning ${BRANCH}" && \
#     git clone --depth 1 --branch ${BRANCH} --recurse-submodules=mozilla-ca https://github.com/Chia-Network/chia-blockchain.git . && \
#     # If COMMIT is set, check out that commit, otherwise just continue
#     ( [ ! -z "$COMMIT" ] && git checkout $COMMIT ) || true && \
#     echo "running build-script" && \
#     /bin/sh ./install.sh

# #COPY ./libs/chiapos.cpython-311-x86_64-linux-gnu.so ./venv/lib/python3.11/site-packages/chiapos.cpython-311-x86_64-linux-gnu.so
# #RUN . ./activate ; pip3 install  --force-reinstall ./chiapos-1.0.12b9.dev5-cp311-cp311-linux_x86_64.whl 

# Get yq for chia config changes
FROM mikefarah/yq:4 AS yq

FROM python:3.11-slim as build-image

EXPOSE 8444 8447 8555 8560 9914

ENV CHIA_ROOT=/home/chia/.chia/mainnet
ENV keys="persistent"
ENV service="farmer"
ENV plots_dir="/plots"
ENV farmer_address=
ENV farmer_port=
ENV testnet="false"
ENV TZ="UTC"
ENV upnp="false"
ENV log_to_file="true"
ENV healthcheck="true"
ENV chia_args=
ENV full_node_peer=

# Deprecated legacy options
ENV harvester="false"
ENV farmer="false"

# Minimal list of software dependencies
#   sudo: Needed for alternative plotter install
#   tzdata: Setting the timezone
#   curl: Health-checks
#   netcat: Healthchecking the daemon
#   yq: changing config settings
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y sudo tzdata curl netcat unzip net-tools && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    curl -L https://download.chia.net/dev/chia-blockchain-cli_1.8.0rc2-dev31-4d60ba1b-1_amd64.deb -o chia-blockchain-cli_1.8.0rc2-dev31-4d60ba1b-1_amd64.deb && \
    dpkg -i chia-blockchain-cli_1.8.0rc2-dev31-4d60ba1b-1_amd64.deb && \
    rm chia-blockchain-cli_1.8.0rc2-dev31-4d60ba1b-1_amd64.deb && \
    curl -L https://github.com/Chia-Network/chia-exporter/releases/latest/download/chia-exporter-linux-amd64.zip -o chia-exporter-linux-amd64.zip && \
    unzip chia-exporter-linux-amd64.zip && \
    mv chia-exporter-linux-amd64/chia-exporter /usr/local/bin/ && \
    chmod +x /usr/local/bin/chia-exporter && \
    rm -rf chia-exporter-linux-amd64 

COPY --from=yq /usr/bin/yq /usr/bin/yq
#COPY --from=chia_build /chia-blockchain /chia-blockchain

ENV PATH=/chia-blockchain/venv/bin:$PATH
WORKDIR /chia-blockchain

RUN groupadd -g 10001 chia
RUN useradd -u 10001 -g 10001 chia
RUN find /chia-blockchain/ -type d -name "puzzles" -exec chown chia {} \;
RUN chown chia /usr/local/bin/chia-exporter

USER chia

COPY docker-start.sh /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/
COPY docker-healthcheck.sh /usr/local/bin/

HEALTHCHECK --interval=1m --timeout=10s --start-period=20m \
  CMD /bin/bash /usr/local/bin/docker-healthcheck.sh || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-start.sh"]
