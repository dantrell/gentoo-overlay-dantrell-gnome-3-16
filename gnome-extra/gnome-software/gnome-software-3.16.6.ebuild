# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"
PYTHON_COMPAT=( python2_7 )

inherit eutils gnome2 python-any-r1 virtualx

DESCRIPTION="Gnome install & update software"
HOMEPAGE="http://wiki.gnome.org/Apps/Software"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RDEPEND="
	>=app-admin/packagekit-base-1
	dev-db/sqlite:3
	>=dev-libs/appstream-glib-0.3.4:0
	>=dev-libs/glib-2.39.1:2
	gnome-base/gnome-desktop:3=
	>=gnome-base/gsettings-desktop-schemas-3.11.5
	net-libs/libsoup:2.4
	sys-auth/polkit
	>=x11-libs/gtk+-3.16:3
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	app-text/docbook-xml-dtd:4.2
	dev-libs/libxslt
	>=dev-util/intltool-0.35
	virtual/pkgconfig
	test? ( dev-util/dogtail )
"
# test? ( dev-util/valgrind )

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	# valgrind fails with SIGTRAP
	sed -e 's/TESTS = .*/TESTS =/' \
		-i "${S}"/src/Makefile.{am,in} || die

	# From GNOME:
	# 	https://git.gnome.org/browse/gnome-software/commit/?id=4de9bc66873f6bb054fe0b4d26f2b24079c8d354
	epatch "${FILESDIR}"/${PN}-3.16.6-support-the-new-appstreamglib-v5.0-api.patch

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--enable-man \
		$(use_enable test dogtail)
}

src_test() {
	Xemake check TESTS_ENVIRONMENT="dbus-run-session"
}
