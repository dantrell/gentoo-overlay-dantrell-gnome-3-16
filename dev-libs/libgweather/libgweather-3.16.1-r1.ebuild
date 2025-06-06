# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala

DESCRIPTION="Library to access weather information from online services"
HOMEPAGE="https://wiki.gnome.org/Projects/LibGWeather"

LICENSE="GPL-2+"
SLOT="2/3-6" # subslot = 3-(libgweather-3 soname suffix)
KEYWORDS="*"

IUSE="glade +introspection vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=x11-libs/gtk+-3.13.5:3[introspection?]
	>=dev-libs/glib-2.35.1:2
	>=net-libs/libsoup-2.34:2.4
	>=dev-libs/libxml2-2.6.0
	sci-geosciences/geocode-glib:0
	>=sys-libs/timezone-data-2010k

	glade? ( >=dev-util/glade-3.16:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
"
DEPEND="${RDEPEND}
	>=dev-build/gtk-doc-am-1.11
	>=dev-util/intltool-0.50
	>=sys-devel/gettext-0.18
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/libgweather/-/commit/6b0586d95f5632c92b2fbbcb68426bfe5be51098
	eapply "${FILESDIR}"/${PN}-3.18.2-switch-to-new-metar-data-provider.patch

	use vala && vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		$(use_enable glade glade-catalog) \
		$(use_enable introspection) \
		$(use_enable vala)
}
