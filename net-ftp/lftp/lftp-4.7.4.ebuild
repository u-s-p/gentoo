# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit autotools eutils libtool

DESCRIPTION="A sophisticated ftp/sftp/http/https/torrent client and file transfer program"
HOMEPAGE="http://lftp.tech/"
SRC_URI="${HOMEPAGE}ftp/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ia64 ~mips ppc ppc64 ~s390 sparc x86 ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"

IUSE="convert-mozilla-cookies +gnutls idn ipv6 libressl nls socks5 +ssl verify-file"
LFTP_LINGUAS=( cs de es fr it ja ko pl pt_BR ru uk zh_CN zh_HK zh_TW )
IUSE+=" ${LFTP_LINGUAS[@]/#/linguas_}"

RDEPEND="
	>=sys-libs/ncurses-5.1:=
	>=sys-libs/readline-5.1:=
	dev-libs/expat
	sys-libs/zlib
	convert-mozilla-cookies? ( dev-perl/DBI )
	idn? ( net-dns/libidn )
	socks5? (
		>=net-proxy/dante-1.1.12
		virtual/pam
	)
	ssl? (
		gnutls? ( >=net-libs/gnutls-1.2.3:0= )
		!gnutls? (
			!libressl? ( dev-libs/openssl:0= )
			libressl? ( dev-libs/libressl:0= )
		)
	)
	verify-file? (
		dev-perl/String-CRC32
		virtual/perl-Digest-MD5
	)
"

DEPEND="
	${RDEPEND}
	=sys-devel/libtool-2*
	app-arch/xz-utils
	nls? ( >=sys-devel/gettext-0.19 )
	virtual/pkgconfig
"

DOCS=(
	BUGS ChangeLog FAQ FEATURES MIRRORS NEWS README README.debug-levels
	README.dnssec README.modules THANKS TODO
)

PATCHES=(
	"${FILESDIR}"/${PN}-4.0.2.91-lafile.patch \
	"${FILESDIR}"/${PN}-4.5.5-am_config_header.patch \
	"${FILESDIR}"/${PN}-4.7.0-gettext.patch
)

src_prepare() {
	default

	eautoreconf
	elibtoolize # for Darwin bundles

	# bug #536036
	printf 'set fish:auto-confirm no\nset sftp:auto-confirm no\n' >> ${PN}.conf || die
}

src_configure() {
	econf \
		$(use_enable ipv6) \
		$(use_enable nls) \
		$(use_with idn libidn) \
		$(use_with socks5 socksdante "${EPREFIX}"/usr) \
		$(usex ssl "$(use_with !gnutls openssl ${EPREFIX}/usr)" '--without-openssl') \
		$(usex ssl "$(use_with gnutls)" '--without-gnutls') \
		--enable-packager-mode \
		--sysconfdir="${EPREFIX}"/etc/${PN} \
		--with-modules \
		--with-readline="${EPREFIX}"/usr \
		--without-included-regex
}

src_install() {
	default
	local script
	for script in {convert-mozilla-cookies,verify-file}; do
		use ${script} || { rm "${ED}"/usr/share/${PN}/${script} || die ;}
	done
}
