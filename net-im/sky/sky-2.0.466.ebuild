# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils gnome2-utils

DESCRIPTION="Lync & Skype for business on Linux"
HOMEPAGE="http://tel.red"

SRC_URI="http://tel.red/linux/sky_ubuntu64_v${PV}.deb"

LICENSE="eula_tel.red"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="strip mirror"

DEPEND="app-admin/chrpath"

RDEPEND="media-libs/alsa-lib
	media-libs/gstreamer
	media-libs/libv4l
	media-sound/pulseaudio[X]
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXScrnSaver"

src_unpack() {
	mkdir ${P} || die
	unpack ${A}
	tar -C ${P} -zxf data.tar.gz || die
}

src_prepare() {
	local icu_libs freerdp_libs
	icu_libs="libicudata libicule libicutest libicuio libicui18n libicutu libicuuc libiculx"

	# fix broken rpaths
	chrpath -d "${S}"/opt/sky_linux/sky || die
	for lib in libsipw ${icu_libs}; do
		chrpath -d "${S}"/opt/sky_linux/lib/${lib}.so* || die "Failed chrpath on ${lib}"
	done
	chrpath -d "${S}/opt/sky_linux/platforminputcontexts/libfcitxplatforminputcontextplugin.so" || die

	sed -i -e "s:Games;::g" "${S}"/usr/share/applications/sky.desktop || die

	default
}

src_install() {
	newicon "${S}"/usr/share/pixmaps/sky.png sky.png
	domenu "${S}"/usr/share/applications/sky.desktop

	cp -pPR "${S}"/etc "${D}"/ || die

	dodir opt/sky_linux
	mv "${S}"/opt/sky_linux/* "${D}"opt/sky_linux || die

	dosym "${D}"opt/sky_linux/sky.sh /usr/bin/sky
}
