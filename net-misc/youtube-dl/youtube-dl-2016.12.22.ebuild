# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=(python{2_7,3_4,3_5})
inherit bash-completion-r1 distutils-r1 eutils

DESCRIPTION="Download videos from YouTube.com (and more sites...)"
HOMEPAGE="https://rg3.github.com/youtube-dl/"
SRC_URI="http://youtube-dl.org/downloads/${PV}/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64 ~arm ~hppa ppc ppc64 x86 ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE="offensive test"

RDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"
DEPEND="
	${RDEPEND}
	test? ( dev-python/nose[coverage(+)] )
"

S="${WORKDIR}/${PN}"

python_prepare_all() {
	if ! use offensive; then
		sed -i -e "/__version__/s|'$|-gentoo_no_offensive_sites'|g" \
			youtube_dl/version.py || die
		# these have single line import statements
		local xxx=(
			alphaporno anysex behindkink camwithher chaturbate eporner
			eroprofile extremetube fourtube foxgay goshgay hellporno
			hentaistigma hornbunny keezmovies lovehomeporn mofosex motherless
			myvidster porn91 porncom pornhd pornotube pornovoisines pornoxo
			ruleporn sexu slutload spankbang spankwire sunporno thisav tube8
			vporn watchindianporn xbef xnxx xtube xvideos xxxymovies youjizz
			youporn
		)
		# these have multi-line import statements
		local mxxx=(
			drtuber pornhub redtube xhamster tnaflix
		)
		# do single line imports
		sed -i \
			-e $( printf '/%s/d;' ${xxx[@]} ) \
			youtube_dl/extractor/extractors.py \
			|| die

		# do multiple line imports
		sed -i \
			-e $( printf '/%s/,/)/d;' ${mxxx[@]} ) \
			youtube_dl/extractor/extractors.py \
			|| die

		sed -i \
			-e $( printf '/%s/d;' ${mxxx[@]} ) \
			youtube_dl/extractor/generic.py \
			|| die

		rm \
			$( printf 'youtube_dl/extractor/%s.py ' ${xxx[@]} ) \
			$( printf 'youtube_dl/extractor/%s.py ' ${mxxx[@]} ) \
			test/test_age_restriction.py \
			|| die
	fi

	epatch_user

	distutils-r1_python_prepare_all
}

src_compile() {
	distutils-r1_src_compile
}

python_test() {
	emake test
}

python_install_all() {
	dodoc README.txt
	doman ${PN}.1

	newbashcomp ${PN}.bash-completion ${PN}

	insinto /usr/share/zsh/site-functions
	newins youtube-dl.zsh _youtube-dl

	insinto /usr/share/fish/completions
	doins youtube-dl.fish

	distutils-r1_python_install_all

	rm -r "${ED}"/usr/etc || die
}
