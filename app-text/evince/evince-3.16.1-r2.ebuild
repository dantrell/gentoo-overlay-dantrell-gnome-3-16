# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_EAUTORECONF="yes"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="Simple document viewer for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Evince"

LICENSE="GPL-2+ CC-BY-SA-3.0"
# subslot = evd3.(suffix of libevdocument3)-evv3.(suffix of libevview3)
SLOT="0/evd3.4-evv3.3"
KEYWORDS="*"

IUSE="djvu dvi gnome gnome-keyring +introspection nautilus nsplugin postscript t1lib tiff xps"

# atk used in libview
# gdk-pixbuf used all over the place
COMMON_DEPEND="
	dev-libs/atk
	>=dev-libs/glib-2.36:2[dbus]
	>=dev-libs/libxml2-2.5:2
	sys-libs/zlib:=
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3.15.3:3[introspection?]
	gnome-base/gsettings-desktop-schemas
	>=x11-libs/cairo-1.10:=
	>=app-text/poppler-0.24:=[cairo]
	djvu? ( >=app-text/djvu-3.5.17:= )
	dvi? (
		virtual/tex-base
		dev-libs/kpathsea:=
		t1lib? ( >=media-libs/t1lib-5:= ) )
	gnome? ( gnome-base/gnome-desktop:3= )
	gnome-keyring? ( >=app-crypt/libsecret-0.5 )
	introspection? ( >=dev-libs/gobject-introspection-1:= )
	nautilus? ( >=gnome-base/nautilus-2.91.4 )
	postscript? ( >=app-text/libspectre-0.2:= )
	tiff? ( >=media-libs/tiff-3.6:0= )
	xps? ( >=app-text/libgxps-0.2.1:= )
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gvfs
	gnome-base/librsvg
	|| (
		>=x11-themes/adwaita-icon-theme-2.17.1
		>=x11-themes/hicolor-icon-theme-0.10 )
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.3
	app-text/yelp-tools
	dev-util/gdbus-codegen
	>=dev-build/gtk-doc-am-1.13
	>=dev-util/intltool-0.35
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"
# eautoreconf needs:
#  app-text/yelp-tools

PATCHES=(
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/evince/-/commit/b18b3dc51a93e12172d22c6b8bb92d32b6e8ebb0
	# 	https://gitlab.gnome.org/GNOME/evince/-/commit/335c0536c137a8bcc886ca33c1aba6abaf32b99c
	# 	https://gitlab.gnome.org/GNOME/evince/-/commit/f932396d1c51646a1535eb28d7c8b1281e794a1a
	# 	https://gitlab.gnome.org/GNOME/evince/-/commit/8bbcdee7aacd2a1c0e5015108978321a31c9ef66
	# 	https://gitlab.gnome.org/GNOME/evince/-/commit/ef6c1d98e0702d6849d6bbbe4d08cfccb033d243
	"${FILESDIR}"/${PN}-3.20.2-ev-toolbar-fix-ev-toolbar-has-visible-popups-after-cb3d4b2.patch
	"${FILESDIR}"/${PN}-3.20.2-comics-add-application-vnd-comicbookzip-support.patch
	"${FILESDIR}"/${PN}-3.20.2-comics-fix-mime-type-comparisons.patch
	"${FILESDIR}"/${PN}-3.20.2-comics-remove-support-for-tar-and-tar-like-commands.patch
	"${FILESDIR}"/${PN}-3.20.2-comics-fix-extra-leading-to-a-warning-during-installation.patch
	# From GNOME:
	# 	https://bugzilla.gnome.org/show_bug.cgi?id=784947 (CVE-2017-1000159)
	"${FILESDIR}"/${PN}-3.24.2-CVE-2017-1000159.patch
)

src_prepare() {
	gnome2_src_prepare

	# Do not depend on adwaita-icon-theme, bug #326855, #391859
	# https://bugs.freedesktop.org/show_bug.cgi?id=29942
	sed -e 's/adwaita-icon-theme >= $ADWAITA_ICON_THEME_REQUIRED//g' \
		-i configure || die "sed failed"
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--enable-pdf \
		--enable-comics \
		--enable-thumbnailer \
		--with-platform=gnome \
		--enable-dbus \
		$(use_enable djvu) \
		$(use_enable dvi) \
		$(use_enable gnome libgnome-desktop) \
		$(use_with gnome-keyring keyring) \
		$(use_enable introspection) \
		$(use_enable nautilus) \
		$(use_enable nsplugin browser-plugin) \
		$(use_enable postscript ps) \
		$(use_enable t1lib) \
		$(use_enable tiff) \
		$(use_enable xps) \
		BROWSER_PLUGIN_DIR="${EPREFIX}"/usr/$(get_libdir)/nsbrowser/plugins
}
