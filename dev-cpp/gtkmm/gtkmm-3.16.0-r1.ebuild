# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 multilib-minimal

DESCRIPTION="C++ interface for GTK+"
HOMEPAGE="https://www.gtkmm.org"

LICENSE="LGPL-2.1+"
SLOT="3.0"
KEYWORDS="*"

IUSE="aqua doc test wayland X"
REQUIRED_USE="|| ( aqua wayland X )"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-cpp/glibmm-2.44.0:2[${MULTILIB_USEDEP}]
	>=x11-libs/gtk+-3.16:3[aqua?,wayland?,X?,${MULTILIB_USEDEP}]
	>=x11-libs/gdk-pixbuf-2.28:2[${MULTILIB_USEDEP}]
	>=dev-cpp/atkmm-2.22.7[${MULTILIB_USEDEP}]
	>=dev-cpp/cairomm-1.10.0-r1[${MULTILIB_USEDEP}]
	>=dev-cpp/pangomm-2.34.0:1.4[${MULTILIB_USEDEP}]
	dev-libs/libsigc++:2=[${MULTILIB_USEDEP}]
	>=dev-libs/libsigc++-2.3.2:2[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		media-gfx/graphviz
		dev-libs/libxslt
		app-text/doxygen )
"
# eautoreconf needs mm-common

src_prepare() {
	if ! use test; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed 1 failed"
	fi

	# don't waste time building examples
	sed 's/^\(SUBDIRS =.*\)demos\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
		|| die "sed 2 failed"

	gnome2_src_prepare
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" \
	gnome2_src_configure \
		--enable-api-atkmm \
		$(multilib_native_use_enable doc documentation) \
		$(use_enable aqua quartz-backend) \
		$(use_enable wayland wayland-backend) \
		$(use_enable X x11-backend)
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_install_all() {
	einstalldocs

	find demos -type d -name '.deps' -exec rm -rf {} \; 2>/dev/null
	find demos -type f -name 'Makefile*' -exec rm -f {} \; 2>/dev/null
	dodoc -r demos
}
