# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools gnome2

DESCRIPTION="A quick previewer for Nautilus, the GNOME file manager"
HOMEPAGE="https://gitlab.gnome.org/GNOME/sushi"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="office webkit"

# Optional app-office/unoconv support (OOo to pdf)
# freetype needed for font loader
# gtk+[X] optionally needed for sushi_create_foreign_window(); when wayland is more widespread, might want to not force it
COMMON_DEPEND="
	>=x11-libs/gdk-pixbuf-2.23[introspection]
	>=dev-libs/gjs-1.40
	>=dev-libs/glib-2.29.14:2
	>=dev-libs/gobject-introspection-0.9.6:=
	>=media-libs/clutter-1.11.4:1.0[introspection]
	>=media-libs/clutter-gtk-1.0.1:1.0[introspection]
	>=x11-libs/gtk+-3.13.2:3[X,introspection]

	>=app-text/evince-3.0[introspection]
	media-libs/freetype:2
	media-libs/gstreamer:1.0[introspection]
	media-libs/gst-plugins-base:1.0[introspection]
	media-libs/clutter-gst:2.0[introspection]
	media-libs/musicbrainz:5=
	webkit? ( net-libs/webkit-gtk:4[introspection] )
	x11-libs/gtksourceview:3.0[introspection]

	office? ( app-office/unoconv )
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/nautilus-3.1.90
"

src_prepare() {
	if ! use webkit; then
		# From GNOME Without Systemd:
		eapply "${FILESDIR}"/${PN}-3.15.90-make-webkit-optional.patch
	fi

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure --disable-static
}
