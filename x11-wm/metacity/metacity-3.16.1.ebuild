# Distributed under the terms of the GNU General Public License v2

EAPI="5"
# debug only changes CFLAGS
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="GNOME default window manager"
HOMEPAGE="https://blogs.gnome.org/metacity/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="test xinerama"

# XXX: libgtop is automagic, hard-enabled instead
RDEPEND="
	>=x11-libs/gtk+-3.15.2:3
	>=x11-libs/pango-1.2[X]
	>=dev-libs/glib-2.25.10:2
	>=gnome-base/gsettings-desktop-schemas-3.3
	>=x11-libs/startup-notification-0.7
	>=x11-libs/libXcomposite-0.3
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXdamage
	x11-libs/libXcursor
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrandr
	x11-libs/libSM
	x11-libs/libICE
	media-libs/libcanberra[gtk3]
	gnome-base/libgtop:2=
	gnome-extra/zenity
	xinerama? ( x11-libs/libXinerama )
	!x11-misc/expocity
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	virtual/pkgconfig
	test? ( app-text/docbook-xml-dtd:4.5 )
	xinerama? ( x11-proto/xineramaproto )
	x11-proto/xextproto
	x11-proto/xproto
"

src_configure() {
	DOCS="AUTHORS ChangeLog HACKING NEWS README *.txt doc/*.txt"
	gnome2_src_configure \
		--disable-static \
		--enable-canberra \
		--enable-compositor \
		--enable-render \
		--enable-shape \
		--enable-sm \
		--enable-startup-notification \
		--enable-xsync \
		--enable-themes-documentation \
		$(use_enable xinerama) \
		ITSTOOL=$(type -P true)
}