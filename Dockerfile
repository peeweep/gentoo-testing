FROM gentoo/portage:latest as portage
FROM gentoo/stage3 as production

COPY --from=portage /var/db/repos/gentoo/ /var/db/repos/gentoo
COPY gentoo.conf /etc/portage/repos.conf/

WORKDIR /
ENV PATH="/root/.local/bin:${PATH}"
RUN set -eux;                                                                               \
                                                                                            \
    eselect news read --quiet new >/dev/null 2&>1;                                          \
    echo 'FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox"' >> /etc/portage/make.conf; \
    echo 'FEATURES="${FEATURES} getbinpkg"' >> /etc/portage/make.conf;                      \
    getuto;                                                                                 \
    emerge --info;                                                                          \
    emerge --verbose --quiet --jobs $(nproc) --autounmask y --autounmask-continue y         \
        app-portage/eix                                                                     \
        dev-util/pkgcheck                                                                   \
        dev-vcs/git;                                                                        \
                                                                                            \
    sed -i '/FEATURES="${FEATURES} getbinpkg"/d' /etc/portage/make.conf;                    \
    rm --recursive /var/db/repos/gentoo;                                                    \
    eix-sync -a;

CMD ["/bin/bash"]
