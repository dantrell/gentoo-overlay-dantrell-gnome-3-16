# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Dictionary utility for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Dictionary"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="0/8" # subslot = suffix of libgdict-1.0.so
KEYWORDS="*"

IUSE="debug +introspection"

COMMON_DEPEND="
	>=dev-libs/glib-2.39:2[dbus]
	x11-libs/cairo:=
	>=x11-libs/gtk+-3.14:3
	x11-libs/pango
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
	!<gnome-extra/gnome-utils-3.4
"
# ${PN} was part of gnome-utils before 3.4
DEPEND="${COMMON_DEPEND}
	>=dev-build/gtk-doc-am-1.15
	>=dev-util/intltool-0.40
	dev-util/itstool
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable introspection) \
		--enable-ipv6
}
