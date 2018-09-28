# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="GNOME Flashback session and helper application"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-flashback"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.44.0
	>=gnome-base/gnome-desktop-3.12:3=
	>=media-libs/libcanberra-0.13
	>=x11-libs/gtk+-3.15.2:3
	>=x11-wm/metacity-3.16.0
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40.6
	virtual/pkgconfig
"
