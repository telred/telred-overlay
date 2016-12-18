# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils gnome2-utils

DESCRIPTION="Lync & Skype for Business client on Linux"
HOMEPAGE="https://tel.red"

SRC_URI="https://tel.red/repos/debian/pool/non-free/sky_${PV%.*}-${PV##*.}debian+jessie_amd64.deb"

LICENSE="eula_tel.red"
SLOT="0"
KEYWORDS="-* ~amd64"

QA_PREBUILT="usr/lib/${PN}/.*"
RESTRICT="mirror"

DEPEND=""

RDEPEND="
	>=dev-libs/openssl-1.0.2:0
	virtual/jpeg:62
	media-libs/libpng:1.2
	media-libs/libv4l
	media-sound/pulseaudio[alsa,X]
	media-video/ffmpeg:0/54.56.56[X]
	net-misc/curl
	x11-base/xorg-server
	x11-libs/gtk+:2[-aqua]
	x11-libs/libXinerama
	x11-libs/libxkbcommon[X]
	dev-qt/qtcore:5/5.7
	dev-qt/qtdbus:5/5.7
	dev-qt/qtgui:5/5.7[dbus,png,xcb]
	dev-qt/qtnetwork:5/5.7
	dev-qt/qtwidgets:5/5.7[png,xcb]
"

src_unpack() {
	mkdir ${P} || die
	unpack ${A}
	tar -C ${P} -Jxf data.tar.xz || die
}

src_prepare() {
	sed -i s/^Icon=.*$/Icon=sky/ "${S}"/usr/share/applications/sky.desktop
}

src_install() {
	local _sky_basedir="usr/lib/${PN}"
	local _sky_libdir="${_sky_basedir}/lib64"
	local _sky_bindir="${_sky_basedir}"
	local _sky_datadir=( "${_sky_basedir}/sounds" )

	exeinto "${_sky_bindir}"
	doexe "${S}/usr/lib/sky/"{sky,man.sh}
	dosym "${D}${_sky_bindir}/sky" /usr/bin/sky

	insinto "${_sky_libdir}"
	insopts -m0755
	doins -r "${S}/${_sky_libdir}/"*

	for dd in ${_sky_datadir[@]} ; do
		insinto "$dd"
		insopts -m0644
		doins -r "${S}/${dd}/"*
	done

	newicon "${S}"/usr/share/pixmaps/sky.png ${PN}.png
	newicon "${S}"/usr/share/pixmaps/sky.svg ${PN}.svg
	domenu "${S}"/usr/share/applications/sky.desktop
}

# vim: set ts=2 sw=2 ft=sh noet:
