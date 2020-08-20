# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils gnome2-utils

DESCRIPTION="Lync & Skype for Business client on Linux"
HOMEPAGE="https://tel.red"

SRC_URI="
	amd64? (
		!legacy-openssl? ( https://tel.red/repos/gentoo/sky-gentoo-${PV%.*}-${PV##*.}-x86_64.tar.xz )
		legacy-openssl? ( https://tel.red/repos/gentoo/sky-gentoo-ossl10-${PV%.*}-${PV##*.}-x86_64.tar.xz )
	)
"

LICENSE="eula_tel.red"
SLOT="0"
KEYWORDS="-* ~amd64"

QA_PREBUILT="usr/lib/${PN/-*/}/.*"
RESTRICT="mirror strip"
IUSE="legacy-openssl"

DEPEND=""

RDEPEND="
	!net-im/sky-ng
	dev-db/sqlite:3
	>=dev-qt/qtcore-5.6:5
	|| ( >=dev-qt/qtgui-5.6:5[dbus,gif,jpeg,png,xcb] >=dev-qt/qtgui-5.14:5[dbus,gif,jpeg,png] )
	>=dev-qt/qtnetwork-5.6:5
	>=dev-qt/qtwidgets-5.6:5
	!legacy-openssl? ( dev-libs/openssl:0/1.1 )
	legacy-openssl? ( dev-libs/openssl:0/0 )
	media-libs/libv4l
	media-sound/pulseaudio
	media-video/ffmpeg:0/56.58.58[X]
	net-misc/curl
	sys-apps/util-linux
	>=sys-libs/glibc-2.28:2.2
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libxkbfile
	x11-libs/libXmu
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libXv
"

src_unpack() {
	mkdir ${P} || die
	unpack ${A}
}

src_prepare() {
	sed -i s/^Icon=.*$/Icon=sky/ "${WORKDIR}"/usr/share/applications/sky.desktop
	sed -i /^Path=.*$/d "${WORKDIR}"/usr/share/applications/sky.desktop
}

src_install() {
	local _sky_basedir="usr/lib64/${PN/-*/}"
	local _sky_libdir="${_sky_basedir}/lib64"
	local _sky_bindir="${_sky_basedir}"
	local _sky_datadir=(
		"${_sky_basedir}/sounds"
		"${_sky_basedir}/stylesheets"
	)

	exeinto "${_sky_bindir}"
	doexe "${WORKDIR}/${_sky_basedir}/"{sky,sky_sender,man.sh}
	dosym "${D}${_sky_bindir}/sky" /usr/bin/sky

	insinto "${_sky_libdir}"
	insopts -m0755
	doins -r "${WORKDIR}/${_sky_libdir}/"*

	for dd in ${_sky_datadir[@]} ; do
		insinto "$dd"
		insopts -m0644
		doins -r "${WORKDIR}/${dd}/"*
	done

	newicon "${WORKDIR}"/usr/share/pixmaps/sky.png ${PN/-*/}.png
	newicon "${WORKDIR}"/usr/share/pixmaps/sky.svg ${PN/-*}.svg
	domenu "${WORKDIR}"/usr/share/applications/sky.desktop
}

pkg_postinst() {
	if [[ "${PN}" == "sky-ng" ]] ; then
		ewarn "The net-im/sky-ng package is planned to be replaced with net-im/sky alias eventually."
		ewarn "Please consider switching to net-im/sky when possible"
	fi
}

# vim: set ts=4 sw=4 ft=sh noet:
