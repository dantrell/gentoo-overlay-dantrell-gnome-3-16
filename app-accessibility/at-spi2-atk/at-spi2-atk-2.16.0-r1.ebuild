# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools gnome2 multilib-minimal virtualx

DESCRIPTION="Gtk module for bridging AT-SPI to Atk"
HOMEPAGE="https://wiki.gnome.org/Accessibility"

LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=app-accessibility/at-spi2-core-2.15.5[${MULTILIB_USEDEP}]
	>=dev-libs/atk-2.15.4[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.32:2[${MULTILIB_USEDEP}]
	>=sys-apps/dbus-1.5[${MULTILIB_USEDEP}]
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-extra/at-spi-1.32.0-r1
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	test? ( >=dev-libs/libxml2-2.9.1 )
"

src_prepare() {
	# https://bugzilla.gnome.org/show_bug.cgi?id=751137
	eapply "${FILESDIR}"/${PN}-2.16.0-out-of-source.patch

	# Fixed in upstream git
	eapply "${FILESDIR}"/${P}-null-gobject.patch

	# Upstream forgot to put this in tarball :/
	# https://bugzilla.gnome.org/show_bug.cgi?id=751138
	cp -n "${FILESDIR}"/${PN}-2.16.0-atk_suite.h tests/atk_suite.h || die
	mkdir tests/data/ || die
	cp -n "${FILESDIR}"/${PN}-2.16.0-tests-data/*.xml tests/data/ || die

	eautoreconf
	gnome2_src_prepare
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		--enable-p2p \
		$(use_with test tests)
}

multilib_src_test() {
	virtx emake check TESTS_ENVIRONMENT="dbus-run-session"
}

multilib_src_compile() { gnome2_src_compile; }
multilib_src_install() { gnome2_src_install; }
