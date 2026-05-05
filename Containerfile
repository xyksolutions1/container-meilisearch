# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM docker.io/xyksolutions1/container-base:main

LABEL \
        org.opencontainers.image.title="Mellisearch" \
        org.opencontainers.image.description="Search API" \
        org.opencontainers.image.url="https://hub.docker.com/r/xyksolutions1/meilisearch" \
        org.opencontainers.image.documentation="https://github.com/xyksolutions1/container-meilisearch/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/xyksolutions1/container-meilisearch.git" \
        org.opencontainers.image.authors="xyksolutions1" \
        org.opencontainers.image.vendor="xyksolutions1" \
        org.opencontainers.image.licenses="MIT"

ARG \
    MELLISEARCH_VERSION="v1.30.0" \
    MELLISEARCH_REPO_URL="https://github.com/meilisearch/meilisearch"


COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    CONTAINER_ENABLE_SCHEDULING=TRUE \
    IMAGE_NAME="xyksolutions1/meilisearch" \
    IMAGE_REPO_URL="https://github.com/xyksolutions1/container-meilisearch/"

EXPOSE \
        7700/udp \
        7700/tcp

RUN echo "" && \
    MELLISEARCH_BUILD_DEPS_ALPINE=" \
                                    #cargo \
                                  " \
                                  && \
    MELLISEARCH_RUN_DEPS_ALPINE=" \
                                " \
                                && \
    \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user meilisearch 7700 meilisearch 7700 /var/lib/meilisearch && \
    package update && \
    package upgrade && \
    package install \
                        MELLISEARCH_BUILD_DEPS \
                        MELLISEARCH_RUN_DEPS \
                        && \
    \
    ## 2025-12-15 - Needs Rust > 1.89
    echo "@edgemain https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    package update && \
    package install cargo@edgemain && \
    clone_git_repo "${MELLISEARCH_REPO_URL}" "${MELLISEARCH_VERSION}" && \
    export RUSTFLAGS="-C target-feature=-crt-static" && \
    cargo build --release -p meilisearch -p meilitool && \
    cp -R target/release/{meilisearch,meilitool} /usr/local/bin && \
    container_build_log add "meilisearch" "${MELLISEARCH_VERSION}" "${MELLISEARCH_REPO_URL}" && \
    mkdir -p \
                /container/data/meilisearch \
                && \
    chown -R meilisearch:meilisearch /container/data/meilisearch && \
    container_build_log add "meilisearch" "${MELLISEARCH_VERSION}" "${MELLISEARCH_REPO_URL}" && \
    package remove \
                    MELLISEARCH_BUILD_DEPS \
                    cargo \
                    && \
    package cleanup

COPY rootfs /
