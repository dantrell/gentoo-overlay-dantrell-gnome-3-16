# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="A calculator application for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Calculator"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

COMMON_DEPEND="
	>=dev-libs/glib-2.40:2
	dev-libs/libxml2:2
	dev-libs/mpfr:0
	>=x11-libs/gtk+-3.11.6:3
	>=x11-libs/gtksourceview-3.15.1:3.0
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-extra/gnome-utils-2.3
	!gnome-extra/gcalctool
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.50
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	# From GNOME:
	# 	https://git.gnome.org/browse/gnome-calculator/commit/?id=37cfdf497ced9d52930792c5e8581171420a7a66
	# 	https://git.gnome.org/browse/gnome-calculator/commit/?id=b0427cf0e9349fad3ac02f551e1f1c84d9b9eebc
	"${FILESDIR}"/${PN}-3.18.4-lib-prevents-segfault-when-elements-of-division-to-zero-have-null-assigned-tokens.patch
	"${FILESDIR}"/${PN}-3.18.4-complex-exponentiation-fixes.patch
)

src_configure() {
	gnome2_src_configure \
		VALAC=$(type -P true)
}
