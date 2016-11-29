# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit autotools eutils vcs-snapshot

DESCRIPTION="A VNC server for real X displays"
HOMEPAGE="https://libvnc.github.io/"
SRC_URI="https://github.com/LibVNC/x11vnc/archive/0.9.14.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="crypt fbcon libressl ssl xinerama zeroconf"

RDEPEND=">=net-libs/libvncserver-0.9.8
	x11-libs/libX11
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	>=x11-libs/libXtst-1.1.0
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= )
	)
	xinerama? ( x11-libs/libXinerama )
	zeroconf? ( >=net-dns/avahi-0.6.4 )
"
DEPEND="${RDEPEND}
	x11-libs/libXt
	x11-proto/inputproto
	x11-proto/trapproto
	x11-proto/recordproto
	x11-proto/xproto
	x11-proto/xextproto
	xinerama? ( x11-proto/xineramaproto )"

DOCS=(ChangeLog README)

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.9.13-fix-compiler-detection.patch
	epatch "${FILESDIR}"/${P}-libvncserver-defines-1.patch #567612
	epatch "${FILESDIR}"/${P}-libvncserver-defines-2.patch #567612
	eautoreconf
}

src_configure() {
	# --without-v4l because of missing video4linux 2.x support wrt #389079
	econf \
		$(use_with crypt) \
		$(use_with fbcon fbdev) \
		$(use_with ssl) \
		$(use_with ssl crypto) \
		--without-v4l \
		$(use_with xinerama) \
		$(use_with zeroconf avahi)
}

src_install() {
	default
	doinitd "${FILESDIR}/x11vnc.init.d"
	doconfd "${FILESDIR}/x11vnc.conf.d"
}