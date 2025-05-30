# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="An IRC client for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Polari https://gitlab.gnome.org/GNOME/polari"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

COMMON_DEPEND="
	>=x11-libs/gtk+-3.15.6:3[introspection]
	net-libs/telepathy-glib[introspection]
	>=dev-libs/glib-2.43.4:2
	>=dev-libs/gobject-introspection-0.9.6:=
	dev-libs/gjs
"
RDEPEND="${COMMON_DEPEND}
	>=net-irc/telepathy-idle-0.2
"
DEPEND="${COMMON_DEPEND}
	dev-libs/appstream-glib
	>=dev-util/intltool-0.50
	virtual/pkgconfig
"
