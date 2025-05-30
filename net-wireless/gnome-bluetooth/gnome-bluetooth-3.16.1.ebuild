# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 udev

DESCRIPTION="Bluetooth graphical utilities integrated with GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeBluetooth"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="2/13" # subslot = libgnome-bluetooth soname version
KEYWORDS="*"

IUSE="debug +introspection"

COMMON_DEPEND="
	>=dev-libs/glib-2.38:2
	>=x11-libs/gtk+-3.12:3[introspection?]
	virtual/udev
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
"
RDEPEND="${COMMON_DEPEND}
	acct-group/plugdev
	>=net-wireless/bluez-5
"
DEPEND="${COMMON_DEPEND}
	!net-wireless/bluez-gnome
	app-text/docbook-xml-dtd:4.1.2
	dev-libs/libxml2:2
	dev-util/gdbus-codegen
	>=dev-build/gtk-doc-am-1.9
	>=dev-util/intltool-0.40.0
	dev-util/itstool
	virtual/libudev:=
	virtual/pkgconfig
	x11-base/xorg-proto
"
# eautoreconf needs:
#	gnome-base/gnome-common

src_prepare() {
	# Regenerate gdbus-codegen files to allow using any glib version; bug #436236
	# https://bugzilla.gnome.org/show_bug.cgi?id=758096
	rm -v lib/bluetooth-client-glue.{c,h} || die
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(usex debug --enable-debug=yes ' ') \
		$(use_enable introspection) \
		--enable-documentation \
		--disable-desktop-update \
		--disable-icon-update \
		--disable-static
}

src_install() {
	gnome2_src_install
	udev_dorules "${FILESDIR}"/61-${PN}.rules
}

pkg_postinst() {
	udev_reload
	gnome2_pkg_postinst
	if ! has_version 'sys-auth/consolekit[acl]' && ! has_version 'sys-auth/elogind[acl]' && ! has_version 'sys-apps/systemd[acl]' ; then
		elog "Don't forget to add yourself to the plugdev group "
		elog "if you want to be able to control bluetooth transmitter."
	fi
}

pkg_postrm() {
	udev_reload
}
