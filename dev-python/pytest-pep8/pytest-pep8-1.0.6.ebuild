# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="pytest plugin to check PEP8 requirements"
HOMEPAGE="https://pypi.python.org/pypi/pytest-pep8"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-python/pep8-1.3[${PYTHON_USEDEP}]
	>=dev-python/pytest-2.4.2[${PYTHON_USEDEP}]
	dev-python/pytest-cache[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

python_test() {
	${EPYTHON} test_pep8.py || die
}