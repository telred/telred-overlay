# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils gnome2-utils

DESCRIPTION="Lync & Skype for business on Linux"
HOMEPAGE="http://tel.red"

SRC_URI="
    amd64?  ( http://tel.red/linux/sky_ubuntu64_v${PV}.deb )
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="ibus"

RESTRICT="strip mirror"

DEPEND="
    app-admin/chrpath
"

RDEPEND="
    ibus? ( app-i18n/ibus )
    media-libs/alsa-lib
    media-libs/gstreamer
    media-sound/pulseaudio[X]
    =net-misc/freerdp-1.2*[server]
    x11-libs/libX11
    x11-libs/libXext
    x11-libs/libXScrnSaver
"

src_unpack() {
    mkdir ${P}
    if [[ ${ARCH} == "amd64" ]] ; then
        unpack sky_ubuntu64_v${PV}.deb
    fi
    tar -C ${P} -zxf data.tar.gz
}

src_prepare() {
    local icu_libs freerdp_libs
    icu_libs="libicudata libicudata libicudata libicule libiculx
        libicutest libicutu libicuuc libicui18n libicuio"
    freerdp_libs="libfreerdp libfreerdp-client libfreerdp-server
        libfreerdp-shadow librdtk libwinpr libxfreerdp-client"

    # fix broken rpaths
    chrpath -d "${S}"/opt/sky_linux/sky
    for lib in libsipw ${icu_libs}; do
        chrpath -d "${S}"/opt/sky_linux/lib/${lib}.so*
    done

    # remove bundled freerdp libs dependent on openssl
    for lib in ${freerdp_libs}; do
        rm -f "${S}"/opt/sky_linux/lib/${lib}.so*
    done

    sed -i -e "s:Games;::g" "${S}"/usr/share/applications/sky.desktop
}

src_install() {
    newicon "${S}"/usr/share/pixmaps/sky.png sky.png
    domenu "${S}"/usr/share/applications/sky.desktop

    cp -pPR "${S}"/etc "${D}"/

    dodir opt/sky_linux
    mv "${S}"/opt/sky_linux/* "${D}"opt/sky_linux

    dosym "${D}"opt/sky_linux/sky.sh /usr/bin/sky
}
