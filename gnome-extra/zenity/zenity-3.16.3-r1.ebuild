# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2

DESCRIPTION="Tool to display dialogs from the commandline and shell scripts"
HOMEPAGE="https://wiki.gnome.org/Projects/Zenity"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="debug libnotify test webkit"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.8:2
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3:3
	x11-libs/libX11
	x11-libs/pango
	libnotify? ( >=x11-libs/libnotify-0.6.1:= )
	webkit? ( >=net-libs/webkit-gtk-2.8.1:4 )
"
DEPEND="${RDEPEND}
	dev-util/itstool
	gnome-base/gnome-common
	>=sys-devel/gettext-0.19.4
	virtual/pkgconfig
	test? ( app-text/yelp-tools )
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/zenity/-/commit/fac40e9c46160a0915d528062dfd19c1afaeac0e
	# 	https://gitlab.gnome.org/GNOME/zenity/-/commit/61c53a042418562c30e816fdd0c63caf2fa9f1b3
	eapply "${FILESDIR}"/${PN}-3.18.1-fixing-html-option-being-parsed-to-other-dialogs-rather-then-text-info.patch
	eapply "${FILESDIR}"/${PN}-3.18.1.1-fix-compilation-when-webkitgtk-is-not-installed.patch

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable libnotify) \
		$(use_enable webkit webkitgtk) \
		PERL=$(type -P false)
}

src_install() {
	gnome2_src_install

	# Not really needed and prevent us from needing perl
	rm "${ED}/usr/bin/gdialog" || die "rm gdialog failed!"
}
