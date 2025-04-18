# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Graphical tool for editing the dconf configuration database"
HOMEPAGE="https://gitlab.gnome.org/GNOME/dconf-editor"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

COMMON_DEPEND="
	>=dev-libs/glib-2.39.3:2
	dev-libs/libxml2
	>=gnome-base/dconf-0.23.2
	>=x11-libs/gtk+-3.4:3
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.50
	sys-devel/gettext
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-base/dconf-0.22[X]
"
