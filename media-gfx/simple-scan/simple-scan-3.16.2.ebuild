# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2 vala

DESCRIPTION="Simple document scanning utility"
HOMEPAGE="https://launchpad.net/simple-scan"
SRC_URI="https://launchpad.net/${PN}/$(ver_cut 1-2)/${PV}/+download/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

IUSE=""

DEPEND="
	>=dev-libs/glib-2.32:2
	>=media-gfx/sane-backends-1.0.20:=
	>=sys-libs/zlib-1.2.3.1:=
	virtual/jpeg:0=
	dev-libs/libgudev:=
	x11-libs/cairo:=
	>=x11-libs/gtk+-3:3
	>=x11-misc/colord-0.1.24:=[udev]
"
RDEPEND="${DEPEND}
	x11-misc/xdg-utils
	x11-themes/adwaita-icon-theme
"
BDEPEND="
	$(vala_depend)
	app-text/yelp-tools
	>=dev-util/intltool-0.35.0
	virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_install() {
	default

	# From AppStream (the /usr/share/appdata location is deprecated):
	# 	https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#spec-component-location
	# 	https://bugs.gentoo.org/709450
	mv "${ED}"/usr/share/{appdata,metainfo} || die
}
