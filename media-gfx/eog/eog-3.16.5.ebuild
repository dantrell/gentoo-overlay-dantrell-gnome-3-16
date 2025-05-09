# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="The Eye of GNOME image viewer"
HOMEPAGE="https://wiki.gnome.org/Apps/EyeOfGnome https://gitlab.gnome.org/GNOME/eog"

LICENSE="GPL-2+"
SLOT="1"
KEYWORDS="*"

IUSE="debug +exif +introspection +jpeg lcms +svg tiff xmp"
REQUIRED_USE="exif? ( jpeg )"

RDEPEND="
	>=dev-libs/glib-2.38:2[dbus]
	>=dev-libs/libpeas-0.7.4:=[gtk]
	>=gnome-base/gnome-desktop-2.91.2:3=
	>=gnome-base/gsettings-desktop-schemas-2.91.92
	>=x11-libs/gtk+-3.14:3[introspection,X]
	>=x11-misc/shared-mime-info-0.20

	>=x11-libs/gdk-pixbuf-2.4.0:2[jpeg?,tiff?]
	x11-libs/libX11

	exif? ( >=media-libs/libexif-0.6.14 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.3:= )
	jpeg? ( media-libs/libjpeg-turbo:0= )
	lcms? ( media-libs/lcms:2 )
	svg? ( >=gnome-base/librsvg-2.36.2:2 )
	xmp? ( media-libs/exempi:2= )
"
DEPEND="${RDEPEND}
	>=dev-build/gtk-doc-am-1.16
	>=dev-util/intltool-0.50.1
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable introspection) \
		$(use_with jpeg libjpeg) \
		$(use_with exif libexif) \
		$(use_with lcms cms) \
		$(use_with xmp) \
		$(use_with svg librsvg)
}
